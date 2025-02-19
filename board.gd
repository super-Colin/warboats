extends Control

# Multiplayer role
var isHost = true 
var playersReady = [] 
# Board / Round related
var startingDeployPoints = 20
var minTargetPoints = 10
# Passed through the network each turn
var shotsToPlayOut = {}
var shotResultsForClient = [] # {"hit":false, "coords":Vector2.ZERO}, ...
var shipPositions = {} # for passing the position of enemy ships 
# Local vars
var turnNumber = 1
var unconfirmedShots = 0
var confirmedShotCoords = []
var playerScores = {}
var killedShips = []



func _ready() -> void:
	#Globals.boardRef = $'.'
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




func resetVarsWithOtherPlayer():
	print("board - ", str(Network.id()), " reseting player vars with other player id: ", Network.otherPlayerId)
	reestPlayerScores()

func reestPlayerScores():
	playerScores[Network.id()] = 0
	playerScores[Network.otherPlayerId] = 0
	updateScoreLabels(playerScores)

func resetForNextTurn():
	turnNumber += 1
	shotsToPlayOut = {}
	shotResultsForClient = []


# Detrevni


@rpc("authority", "call_local", "reliable")
func addKill(ship, friendlyKilled):
	if not Network.isAuthority() or killedShips.has(ship): 
		return
	if friendlyKilled:
		playerScores[Network.otherPlayerId] += ship.targetPoints
	else:
		playerScores[Network.id()] += ship.targetPoints
	killedShips.append(ship)
	updateScoreLabels.rpc(playerScores)
	if Network.isAuthority():
		checkForWinConditions() 


func checkForWinConditions():
	if playerScores[Network.id()] > minTargetPoints:
		declareWinner.rpc(Network.id(), playerScores)
	elif playerScores[Network.otherPlayerId] > minTargetPoints:
		declareWinner.rpc(Network.otherPlayerId, playerScores)

@rpc("authority", "call_local", "reliable")
func declareWinner(pId, scores):
	print("board [", Network.id(), "] - ", pId, " wins")
	%Grids/Friendly/Label.text = str(pId) + " Wins"
	%Grids/Enemy/Label.text = str(pId) + " Wins"


@rpc("authority", "call_local", "reliable")
func updateScoreLabels(scores):
	#print("board - ", str(Network.id()), ", updating score labels:", scores)
	%Grids/Friendly/Label.text = "Score: " + str(scores[Network.id()]) + " / " + str(minTargetPoints)
	%Grids/Enemy/Label.text = "Score: " + str(scores[Network.otherPlayerId]) + " / " + str(minTargetPoints)



@rpc("authority", "call_local", "reliable")
func _confirmShotMarkers():
	confirmedShotCoords = %Grids/Enemy/Grid.getUnconfirmedShotPlacements(true)
	#print("board - confirming shots: ", confirmedShotCoords)
	registerConfirmedShots.rpc(Network.id(), confirmedShotCoords)


func _resetUnconfirmedShots():
	%Grids/Enemy/Grid.resetShotMarkers()
	_boardUpdated()
	#print("board - confirming shots: ", confirmedShotCoords)




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


## Adds/confirms markers on both sides
## Called and initiated by host only,
func handleConfirmedShots_host():
	for clientShot in shotsToPlayOut[Network.otherPlayerId]:
		# create results of shots against host side, to pass to client
		shotResultsForClient.append(%Grids/Friendly/Grid.placeShotMarker(clientShot, true))
	for hostShot in shotsToPlayOut[Network.id()]:
		%Grids/Enemy/Grid.confirmShot_bool(hostShot)
	handleConfirmedShots_client.rpc(shotResultsForClient)
	resetForNextTurn()
## Adds/confirms markers on both sides
## Only visually calcs hits on own board, forces hits/misses on empty enemy board
## Called by client only, but initiated by host
@rpc("authority", "call_remote", "reliable")
func handleConfirmedShots_client(shotResults):
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
	if minTargetPoints <= %Grids/Friendly/Grid.calcTotalTargetPoints():
		#print("board - deploy can be confirmed")
		$DeployMenu.deployCanBeConfirmed()



func _beginDeployPhase():
	resetVarsWithOtherPlayer()
	$DeployMenu.visible = true
	$BattleMenu.visible = false
