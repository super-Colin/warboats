extends Node



# The client sends info and requests
# and acts on the return / requests regardless




@rpc("authority", "call_local", "reliable")
func beginBattlePhase():
	#print("client - start battle")
	Globals.boardRef.showBattlePhaseUi()
	Globals.currentBattlePhase = Globals.BattlePhases.BATTLE

## Gets the results of shots against this client and sends back to the server
@rpc("authority", "call_local", "reliable")
func handleConfirmedShots(confirmedShots):
	var results = Globals.boardRef.getResultsFromShots(confirmedShots[Network.otherPlayerId])
	Server.registerShotResults.rpc(Network.id(), results)

## Adds/confirms markers on both sides
@rpc("authority", "call_local", "reliable")
func handleShotResults(shotResults):
	Globals.boardRef.addResultMarkersToBoard(shotResults[Network.otherPlayerId])




@rpc("authority", "call_local", "reliable")
func addShipsToBoard(shipDicts:Array, friendlyBoard=false):
	Globals.boardRef.addShipsToBoard(shipDicts, friendlyBoard)
	#Globals.boardRef.addShipsToBoard(shipDicts[Network.otherPlayerId], false)




# Send ships and locations to host
@rpc("any_peer", "call_remote", "reliable")
func sendShipDicts(pId, shipsContainedDicts):
	if Network.isAuthority():
		Server.registerPlayerShipDicts(pId, shipsContainedDicts)




#addShipsToFriendlyBoard
