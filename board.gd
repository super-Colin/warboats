extends Control

# Multiplayer
var playersReady = [] 
# Board / Round related
var startingDeployPoints = 20
var minTargetPoints = 10
# Passed through the network each turn
var shotsToPlayOut = {}
var shotResultsForClient = [] # {"hit":false, "coords":Vector2.ZERO}, ...
#var shipPositions = {} # for passing the position of enemy ships 
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
	Network.s_otherPlayerConnected.connect(resetNetworkVars)




func resetNetworkVars():
	print("board - ", Network.role, " - reseting player vars with other player id: ", Network.otherPlayerId)
	Network.setAllPlayers("score", 0)
	Network.setAllPlayers("ready", false)
	#if Globals.currentBattlePhase == Globals.BattlePhases.BATTLE:
		#sendScores()
	#reestPlayerScores()
	#updateScoreLabels()
	

#func reestPlayerScores():
	#playerScores[Network.id()] = 0
	#playerScores[Network.otherPlayerId] = 0
	#updateScoreLabels(playerScores)

func resetForNextTurn():
	turnNumber += 1
	shotsToPlayOut = {}
	shotResultsForClient = []



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
		if not checkForWinConditions():
			checkForStalemateConditions()


func checkForWinConditions():
	if playerScores[Network.id()] > minTargetPoints:
		declareWinner.rpc(Network.id(), playerScores)
		return true
	elif playerScores[Network.otherPlayerId] > minTargetPoints:
		declareWinner.rpc(Network.otherPlayerId, playerScores)
		return true
	return false

func checkForStalemateConditions():
	if %Grids/Friendly/Grid.calcTotalShots() == 0 and %Grids/Enemy/Grid.calcTotalShots() == 0:
		declareStalemate.rpc()


@rpc("authority", "call_local", "reliable")
func declareStalemate():
	print("board [", Network.role, "] - Stalemate")
	%Grids/Friendly/Label.text = "Stalemate"
	%Grids/Enemy/Label.text = "Stalemate"
	Globals.currentBattlePhase = Globals.BattlePhases.BATTLE_OVER

@rpc("authority", "call_local", "reliable")
func declareWinner(pId, scores):
	print("board [", Network.role, "] - ", pId, " wins")
	%Grids/Friendly/Label.text = str(pId) + " Wins"
	%Grids/Enemy/Label.text = str(pId) + " Wins"
	Globals.currentBattlePhase = Globals.BattlePhases.BATTLE_OVER


func sendScores():
	if not Network.isAuthority():
		return
	var scores = Network.getAllPlayers("score")
	updateScoreLabels.rpc(scores)

@rpc("authority", "call_local", "reliable")
func updateScoreLabels(scores):
	#print("board - ", str(Network.id()), ", updating score labels:", scores)
	%Grids/Friendly/Label.text = "Score: " + str(scores[Network.id()]) + " / " + str(minTargetPoints)
	%Grids/Enemy/Label.text = "Score: " + str(scores[Network.otherPlayerId]) + " / " + str(minTargetPoints)



func deployConfirmed():
	%Grids/Friendly/Grid.lockShipsIntoPlace()
	updateReadyStateLabels.rpc(Network.id(), %Grids/Friendly/Grid.getShipDicts())
	var ships = %Grids/Friendly/Grid.getShipDicts()
	# Don't send host's info to client
	if not Network.isAuthority(): 
		sendShipDicts.rpc(Network.id(), ships)
	else:
		registerPlayerShipDicts(Network.id(), ships)

# Send ships and locations to host
@rpc("any_peer", "call_remote", "reliable")
func sendShipDicts(pId, shipsContainedDicts):
	if Network.isAuthority():
		registerPlayerShipDicts(pId, shipsContainedDicts)



func registerPlayerShipDicts(pId, shipsDict):
	if not Network.isAuthority(): 
		return
	Network.players[pId].shipsContained = shipsDict
	Network.players[pId].ready = true
	if Network.connected and Network.areAllPlayers("ready"):
		addShipsToEnemyBoard(Network.players[Network.otherPlayerId].shipsContained)
		_beginBattlePhase.rpc()


@rpc("authority", "call_local", "reliable")
func _beginBattlePhase():
	#print("board - start battle")
	$DeployMenu.visible = false
	$BattleMenu.visible = true
	#%Grids/Friendly/Grid.lockShipsIntoPlace()
	Globals.currentBattlePhase = Globals.BattlePhases.BATTLE



@rpc("any_peer", "call_local", "reliable")
func updateReadyStateLabels(pId, gridShipsContainedDicts):
	#print("board - ", Network.role," updating ready label state:  : ", gridShipsContainedDicts)
	if pId == Network.id():
		%Grids/Friendly/Label.text = "Deployed"
	else:
		%Grids/Enemy/Label.text = "Deployed"
	#if not playersReady.has(pId):
		#playersReady.append(pId)
		#shipPositions[pId] = gridShipsContainedDicts
	#if Network.isAuthority():
		#Network.players["shipPositions"] = gridShipsContainedDicts
		#if Network.areAllPlayers("ready"):
			#addShipsToEnemyBoard(shipPositions[Network.otherPlayerId])
			#_beginBattlePhase.rpc()










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
	#print("board - ", Network.role,": shotResults: ", shotResults)
	for s in shotsToPlayOut[1]: # 1 is always server authority 
		%Grids/Friendly/Grid.placeShotMarker(s, true)
	for s in shotResults: # 1 is always server authority 
		%Grids/Enemy/Grid.forceAddShotFromHost(s.coords, s.hit)
	resetForNextTurn()








func addShipsToEnemyBoard(shipDicts:Array):
	for sd in shipDicts:
		%Grids/Enemy/Grid.addShipFromDict(sd, true)




func _boardUpdated():
	$DeployMenu.updateDeployPoints(startingDeployPoints - %Grids/Friendly/Grid.calcSpentDeployPoints())
	$DeployMenu.updateTargetPoints(%Grids/Friendly/Grid.calcTotalTargetPoints(), minTargetPoints)
	if minTargetPoints <= %Grids/Friendly/Grid.calcTotalTargetPoints():
		#print("board - deploy can be confirmed")
		$DeployMenu.deployCanBeConfirmed()



func _beginDeployPhase():
	$DeployMenu.visible = true
	$BattleMenu.visible = false
	if Network.isAuthority():
		resetNetworkVars()
