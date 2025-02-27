extends Node

# Server Signals
signal s_playerConnected(playerId)
signal s_playerDisconnected(playerId)
# Client Signals
signal s_connectingAsClient
signal s_connectedAsClient
# General Update Signals
signal s_networkStatusChanged

## Direct request signals
signal s_popupWorthyMessage(msg:String)

var otherPlayerId # for convience in a 2 player only game
var role:String = "Not Connected" # for printing / debugging 
var connected:bool = false

### a list of player network id's that will contain info like ready, score, etc. 
### this should only store information that is visible to all players (clients) 
#var players={}

#func addNewPlayer(pId):
	#players[pId] = newPlayerTemplate(pId)
#func removePlayer(pId):
	#players.erase(pId)
#
## Network.areAllPlayers("ready")
### check all players for a property, and set a default if it's missing
#func areAllPlayers(property:String, desiredValue=true, defaultValue=null):
	#var allPlayersAre = true
	#for p in players:
		#if players[p].has(property):
			#if players[p][property] != desiredValue:
				#print("network - player [", p, "]:  ", property, " != ", players[p][property])
				#allPlayersAre = false
		#else:
			#allPlayersAre = false
			#if defaultValue != null: # if a default was supplied
				#players[p][property] = defaultValue
	#print("network [", id(),"] - all players are:  ", property, " == ", allPlayersAre)
	#return allPlayersAre
#
## setAllPlayers("score", 0)
#func setAllPlayers(property:String, newValue:Variant):
	#var allPlayersAre = true
	#for p in players:
		#players[p][property] = newValue
#
#func resetAllPlayers(template:Dictionary):
	#for p in players:
		#players[p] = template
#
## getAllPlayers("score")
### Returns a dict with {"pId" : val, "pId2":val} format
#func getAllPlayers(property:String):
	#var dict = {}
	#for p in players.keys():
		#dict[p] = players[p][property]
	#return dict



#func setMaxClients(newVal:int):
	#maxClients = newVal

func startHost(port:int, maxClients=0):
	if maxClients == 0:
		maxClients = Server.defaultMaxClients
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, maxClients)
	#print(peer)
	multiplayer.multiplayer_peer = peer
	#print("network - started ENet host server")
	# connect signals
	multiplayer.peer_connected.connect(Server._peer_connected)
	multiplayer.peer_disconnected.connect(Server._peer_disconnected)
	Server.addNewPlayer(id())
	s_networkStatusChanged.emit()

func startClient(ip, port:int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("network - started ENet client")
	# connect signals
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.server_disconnected.connect(_server_disconnected)
	s_connectingAsClient.emit()
	s_networkStatusChanged.emit()


func isAuthority():
	return get_multiplayer_authority() == multiplayer.get_unique_id()

func setRole():
	if isAuthority():
		role = "Host"
	elif connected:
		role = "Client"
	else:
		role = "Not Connected"



func id():
	return multiplayer.get_unique_id()

## Host
#func _peer_connected(pId:int):
	#print("network [host] - Player %s connected" % pId)
	#Server.addNewPlayer(pId)
	#setRole()
	#otherPlayerId = pId
	#connected = true
	##s_otherPlayerConnected.emit()
	#Network.s_networkStatusChanged.emit()
#
#func _peer_disconnected(pId:int):
	#print("network [host] - Player %s disconnected" % pId)
	#Server.removePlayer(pId)
	#connected = false
	#s_popupWorthyMessage.emit("peer disconnected")
	#s_networkStatusChanged.emit()

# Client
func _connected_to_server():
	otherPlayerId = 1 # since we're only dealing with 2 players at a time
	connected = true
	print("network [client] - connected to server")
	setRole()
	s_connectedAsClient.emit()
	#s_otherPlayerConnected.emit()
	s_networkStatusChanged.emit()

func _connection_failed():
	connected = false
	setRole()
	s_networkStatusChanged.emit()
	s_popupWorthyMessage.emit("Failed to connect")
	print("network [client] - connection failed")

func _server_disconnected():
	connected = false
	setRole()
	print("network [client] - server disconnected")
	s_popupWorthyMessage.emit("Host disconnected")
	s_networkStatusChanged.emit()
