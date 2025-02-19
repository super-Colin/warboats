extends Control

var isHost = true
#var bothPlayersReady = false # This will be used each cycle
var playersReady = []

var turnNumber = 1

var shotsToPlayOut = {}
var shotResultsForClient = [] # {"hit":false, "coords":Vector2.ZERO}, ...


var unconfirmedShots = 0
var confirmedShotCoords = []
var startingDeployPoints = 20
var minTargetPoints = 10


var shipPositions = {} # for passing the position of the clients ships

var playerScores = {}

var killedShips=[]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.s_beginDeployPhase.connect(_beginDeployPhase)
	Globals.s_beginBattlePhase.connect(_beginBattlePhase)
	
	%Grids/Friendly/Grid.s_boardChanged.connect(_boardUpdated)
	%Grids/Friendly/Grid.s_try_placeShotMarker.connect(try_placeUnconfirmedShotMarker)
	%Grids/Friendly/Grid.s_shipKilled.connect(addKill)
	%Grids/Enemy/Grid.s_try_placeShotMarker.connect(try_placeUnconfirmedShotMarker)
	%Grids/Enemy/Grid.s_shipKilled.connect(addKill)
	
	$DeployMenu.s_deployConfirmed.connect(deployConfirmed)
	
	$BattleMenu.s_confirmShotMarkers.connect(_confirmShotMarkers)
	$BattleMenu.s_resetShotMarkers.connect(_resetUnconfirmedShots)
	## Will establish needed vars once Network.otherPlayerId is defined
	Network.s_otherPlayerConnected.connect(resetVarsWithOtherPlayer)
	reestPlayerScores()
	



func resetVarsWithOtherPlayer():
	print("board - ", str(Network.id()), " reseting player vars with other player id: ", Network.otherPlayerId)
	reestPlayerScores()

func reestPlayerScores():
	playerScores[Network.id()] = 0
	playerScores[Network.otherPlayerId] = 0
	updateScoreLabels(playerScores)

func resetForNextTurn():
	shotsToPlayOut = {}
	shotResultsForClient = []




# detrevnI
# Detrevni


@rpc("authority", "call_local", "reliable")
func addKill(ship, friendlyKilled):
	if not Network.isAuthority() or killedShips.has(ship): 
		return
	print("board - ", str(Network.id()), " adding kill. For friendly: ", friendlyKilled)
	print("board - playerScores:", playerScores)
	if friendlyKilled:
		playerScores[Network.otherPlayerId] += ship.targetPoints
	else:
		playerScores[Network.id()] += ship.targetPoints
	killedShips.append(ship)
	updateScoreLabels.rpc(playerScores)



@rpc("authority", "call_local", "reliable")
func updateScoreLabels(scores):
	%Grids/Friendly/Label.text = "Score: " + str(scores[Network.id()]) + " / " + str(minTargetPoints)
	%Grids/Enemy/Label.text = "Score: " + str(scores[Network.otherPlayerId]) + " / " + str(minTargetPoints)





@rpc("authority", "call_local", "reliable")
func _confirmShotMarkers():
	confirmedShotCoords = %Grids/Enemy/Grid.getUnconfirmedShotPlacements(true)
	#print("board - confirming shots: ", confirmedShotCoords)
	registerConfirmedShots.rpc(Network.id(), confirmedShotCoords)


#@rpc("authority", "call_local", "reliable")
func _resetUnconfirmedShots():
	%Grids/Enemy/Grid.resetShotMarkers()
	_boardUpdated()
	#print("board - confirming shots: ", confirmedShotCoords)
	#registerConfirmedShots.rpc(Network.id(), confirmedShotCoords)




func try_placeUnconfirmedShotMarker(coord):
	var remaining = calcRemainingShots()
	if remaining <= 0:
		return
	%Grids/Enemy/Grid.placeShotMarker(coord)
	$BattleMenu.updateShotsLeft(remaining-1)

func calcRemainingShots():
	return %Grids/Friendly/Grid.calcTotalShots() - %Grids/Enemy/Grid.calcTotalUnconfirmedMarkers()




@rpc("any_peer", "call_local", "reliable")
func registerConfirmedShots(pId, shots):
	#print("board - shots from player: ", pId, ", adding shots to play out: ", shots)
	shotsToPlayOut[pId] = shots
	#print("board -  shots to play out: ", shotsToPlayOut)
	if Network.isAuthority() and shotsToPlayOut.size() == 2:
			#print("board - [host] both players have confirmed shots: ", shotsToPlayOut)
			#playOutConfirmedShots.rpc()
			handleConfirmedShots_host()



func handleConfirmedShots_host():
	turnNumber += 1
	#print("board - shotResultsForClient: ", shotResults)
	for clientShot in shotsToPlayOut[Network.otherPlayerId]:
		# create results of shots against host side, to pass to client
		shotResultsForClient.append(%Grids/Friendly/Grid.placeShotMarker(clientShot, true))
	for hostShot in shotsToPlayOut[Network.id()]:
		%Grids/Enemy/Grid.confirmShot_bool(hostShot)
	handleConfirmedShots_client.rpc(shotResultsForClient)
	resetForNextTurn()
	#%Grids/Friendly/Label.text = "Score: " + str(%Grids/Enemy) + " / " + str(minTargetPoints)
	%Grids/Enemy/Label.text = "Deployed"

#@rpc("any_peer", "call_remote", "reliable")
@rpc("authority", "call_remote", "reliable")
func handleConfirmedShots_client(shotResults):
	turnNumber += 1
	#print("board - ", Network.id(),": shotResults: ", shotResults)
	for s in shotsToPlayOut[1]: # 1 is always server authority 
		%Grids/Friendly/Grid.placeShotMarker(s, true)
	for s in shotResults: # 1 is always server authority 
		%Grids/Enemy/Grid.forceAddShotFromHost(s.coords, s.hit)
	resetForNextTurn()




func deployConfirmed():
	updateReadyStateLabels.rpc(Network.id(), %Grids/Friendly/Grid.getShipDicts())
	#if not Network.isAuthority():
	#else:

@rpc("any_peer", "call_local", "reliable")
func updateReadyStateLabels(pId, gridShipsContainedDicts):
	#print("board - ", Network.id()," updating ready label state:  : ", gridShipsContainedDicts)
	if pId == Network.id():
		%Grids/Friendly/Label.text = "Deployed"
	else:
		%Grids/Enemy/Label.text = "Deployed"
	playersReady.append(pId)
	shipPositions[pId] = gridShipsContainedDicts
	if Network.isAuthority() and playersReady.size() == 2:
		#print("board - both players ready")
		#shipPositions[Network.otherPlayerId]
		addShipsToEnemyBoard(shipPositions[Network.otherPlayerId])
		_beginBattlePhase.rpc()



func addShipsToEnemyBoard(shipDicts:Array):
	for sd in shipDicts:
		%Grids/Enemy/Grid.addShipFromDict(sd, true)


@rpc("authority", "call_local", "reliable")
func _beginBattlePhase():
	#print("board - start battle")
	playersReady = []
	$DeployMenu.visible = false
	$BattleMenu.visible = true
	%Grids/Friendly/Grid.lockShipsIntoPlace()
	Globals.currentBattlePhase = Globals.BattlePhases.BATTLE


func _boardUpdated():
	$DeployMenu.updateDeployPoints(startingDeployPoints - %Grids/Friendly/Grid.calcSpentDeployPoints())
	$DeployMenu.updateTargetPoints(%Grids/Friendly/Grid.calcTotalTargetPoints(), minTargetPoints)
	if Globals.roundMinTargetPoints <= %Grids/Friendly/Grid.calcTotalTargetPoints():
		#print("board - deploy can be confirmed")
		$DeployMenu.deployCanBeConfirmed()



func _beginDeployPhase():
	$DeployMenu.visible = true
	$BattleMenu.visible = false
