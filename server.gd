extends Node

# The server takes in info and processes it, returning the result
# This is built on top of the (hopefully) more portable network manager
# Server is more specific to this game, but still uses network manager as the source of truth
# Clients will call these functions through rpc, and the server will run them


## a list of player network id's that will contain info like ready, score, etc. 
var players={} 

## These will be customized each game if needed

func blankPlayerTemplate(_playerId=null):
	return {
		"ready": false,
		"score": 0,
		"shipsContained": {}
	}


var shipStartingPositions = []
var shotsEachTurn = []
var turnNumber = 1

var defaultMaxClients:int = 2






@rpc("any_peer", "call_local", "reliable")
func registerConfirmedShots(pId, shots):
	if not Network.isAuthority():
		return
	if shotsEachTurn.size() < turnNumber:
		shotsEachTurn.append({})
	shotsEachTurn[turnNumber-1][pId] = shots
	#print("board -  shots to play out: ", shotsToPlayOut)
	if shotsEachTurn[turnNumber-1].size() == 2:
		print("Server - both players have confirmed shots: ", shotsEachTurn[turnNumber-1])
		# confirm friendly shots against enemy
		var results = Globals.boardRef.getResultsFromShots(shotsEachTurn[turnNumber-1][Network.id()], false)
		print("Server - results on enemy board: ", results)
		Client.handleShotResults.rpc_id(Network.otherPlayerId, results, true)
		# shots against the host results
		results = Globals.boardRef.getResultsFromShots(shotsEachTurn[turnNumber-1][Network.otherPlayerId], true)
		print("Server - results on friendly board: ", results)
		Client.handleShotResults.rpc_id(Network.otherPlayerId, results, false)
		turnNumber += 1

var killedShips = []
@rpc("authority", "call_local", "reliable")
func addKill(ship, friendlyKilled):
	if not Network.isAuthority() or killedShips.has(ship): 
		return
	if friendlyKilled:
		players[Network.otherPlayerId].score += ship.targetPoints
	else:
		players[Network.id()].score += ship.targetPoints
	killedShips.append(ship)
	Client.updateScoreLabels.rpc(getScores())
	if not checkForWinConditions():
		checkForStalemateConditions()


func checkForWinConditions():
	var playerScores = getScores()
	if playerScores[Network.id()] > Globals.boardRef.minTargetPoints:
		Client.declareWinner.rpc(Network.id(), playerScores)
		return true
	elif playerScores[Network.otherPlayerId] > Globals.boardRef.minTargetPoints:
		Client.declareWinner.rpc(Network.otherPlayerId, playerScores)
		return true
	return false

func checkForStalemateConditions():
	if Globals.boardRef.isStalemate():
		Client.declareStalemate.rpc()





func getScores():
	return {
		Network.id():players[Network.id()].score,
		Network.otherPlayerId:players[Network.otherPlayerId].score,
	}

@rpc("any_peer", "call_local", "reliable")
func registerPlayerShipDicts(pId, shipsDict):
	if not Network.isAuthority():
		return
	players[pId].shipsContained = shipsDict
	players[pId].ready = true
	if Network.connected and areAllPlayers("ready"): # > 1 player, and both are ready
		#shipStartingPositions[pId].shipsContained
		Client.addShipsToBoard(players[Network.otherPlayerId].shipsContained, false) # add ships to hosts's enemy board
		Client.beginBattlePhase.rpc()



func resetPlayerVars():
	print("board - ", Network.role, " - reseting player vars with other player id: ", Network.otherPlayerId)
	Network.resetAllPlayers(blankPlayerTemplate())



#func addShipsToEnemyBoard(shipDicts:Array):
	#for sd in shipDicts:
		#Globals.enemyGrid.addShipFromDict(sd, true)




















#@rpc("authority", "call_local", "reliable")
#func declareStalemate():
	#print("board [", Network.role, "] - Stalemate")
	#%Grids/Friendly/Label.text = "Stalemate"
	#%Grids/Enemy/Label.text = "Stalemate"
	#Globals.currentBattlePhase = Globals.BattlePhases.BATTLE_OVER
#
#@rpc("authority", "call_local", "reliable")
#func declareWinner(pId, scores):
	#print("board [", Network.role, "] - ", pId, " wins")
	#%Grids/Friendly/Label.text = str(pId) + " Wins"
	#%Grids/Enemy/Label.text = str(pId) + " Wins"
	#Globals.currentBattlePhase = Globals.BattlePhases.BATTLE_OVER





#func sendScores():
	#if not Network.isAuthority():
		#return
	#var scores = Network.getAllPlayers("score")
	#updateScoreLabels.rpc(scores)



## Network will connect this to its' 'multiplayer' on starting a server
func _peer_connected(pId:int):
	print("network [host] - Player %s connected" % pId)
	addNewPlayer(pId)
	Network.setRole()
	Network.otherPlayerId = pId
	Network.connected = true
	Network.s_networkStatusChanged.emit()

## Network will connect this to its' 'multiplayer' on starting a server
func _peer_disconnected(pId:int):
	print("Server - Player %s disconnected" % pId)
	removePlayer(pId)
	Network.connected = false
	Network.s_popupWorthyMessage.emit("peer disconnected")
	Network.s_networkStatusChanged.emit()



func addNewPlayer(pId):
	players[pId] = blankPlayerTemplate(pId)

func removePlayer(pId):
	players.erase(pId)
	Network.otherPlayerId = null

# Network.areAllPlayers("ready")
## check all players for a property, and set a default if it's missing
func areAllPlayers(property:String, desiredValue=true, defaultValue=null):
	var allPlayersAre = true
	for p in players:
		if players[p].has(property):
			if players[p][property] != desiredValue:
				print("network - player [", p, "]:  ", property, " != ", players[p][property])
				allPlayersAre = false
		else:
			allPlayersAre = false
			if defaultValue != null: # if a default was supplied
				players[p][property] = defaultValue
	return allPlayersAre

# setAllPlayers("score", 0)
func setAllPlayers(property:String, newValue:Variant):
	var allPlayersAre = true
	for p in players:
		players[p][property] = newValue

func resetAllPlayers(template:Dictionary):
	for p in players:
		players[p] = template

# getAllPlayers("score")
## Returns a dict with {"pId" : val, "pId2":val} format
func getAllPlayers(property:String):
	var dict = {}
	for p in players.keys():
		dict[p] = players[p][property]
	return dict
