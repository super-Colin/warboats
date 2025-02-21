extends Node

# Server Signals
signal s_otherPlayerConnected
signal s_otherPlayerDisconnected
# Client Signals
signal s_connectingAsClient
signal s_connectedAsClient
# General Update Signals
signal s_networkStatusChanged


var otherPlayerId # for convience in a 2 player only game
var role:String = "None" # for printing / debugging 

# Host only vars
var maxClients:int = 2
var truth={} # this is what the host will update and supply info to clients from
var players={} # a list of player network id's that will contain info like ready, score, etc. 



#func addCustomPlayerVars(varsWithDefaultsDict):

## This will be customized each game if needed
func newPlayerTemplate(_playerId):
	return {
		"ready": false,
		"score": 0,
	}

func addNewPlayer(pId):
	players[pId] = newPlayerTemplate(pId)
func removePlayer(pId):
	players.erase(pId)

# Network.areAllPlayers("ready")
## check all players for a property, and set a default if it's missing
func areAllPlayers(property:String, desiredValue=true, defaultValue=null):
	var allPlayersAre = true
	for p in players:
		if p.has(property):
			if p[property] != desiredValue:
				allPlayersAre = false
		else:
			allPlayersAre = false
			if defaultValue != null: # if a default was supplied
				p[property] = defaultValue
	return allPlayersAre

# setAllPlayers("score", 0)
func setAllPlayers(property:String, newValue:Variant):
	var allPlayersAre = true
	for p in players:
		players[p][property] = newValue

# getAllPlayers("score")
## Returns a dict with {"pId" : val, "pId2":val} format
func getAllPlayers(property:String):
	var dict = {}
	for p in players.keys():
		dict[p] = players[p][property]
	return dict



func setMaxClients(newVal:int):
	maxClients = newVal

func startHost(port:int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, maxClients)
	print(peer)
	multiplayer.multiplayer_peer = peer
	print("network - started ENet host server")
	# connect signals
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	addNewPlayer(id())
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
	role = "Client"



func id():
	return multiplayer.get_unique_id()

# Host
func _peer_connected(id:int):
	print("network [host] - Player %s connected" % id)
	addNewPlayer(id)
	setRole()
	otherPlayerId = id
	s_otherPlayerConnected.emit()
	s_networkStatusChanged.emit()

func _peer_disconnected(id:int):
	print("network [host] - Player %s disconnected" % id)
	removePlayer(id)
	s_networkStatusChanged.emit()

# Client
func _connected_to_server():
	otherPlayerId = 1 # since we're only dealing with 2 players at a time
	print("network [client] - connected to server")
	setRole()
	s_connectedAsClient.emit()
	s_otherPlayerConnected.emit()
	s_networkStatusChanged.emit()

func _connection_failed():
	s_networkStatusChanged.emit()
	print("network [client] - connection failed")

func _server_disconnected():
	print("network [client] - server disconnected")
	s_networkStatusChanged.emit()
