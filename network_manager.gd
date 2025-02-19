extends Node

var maxClients:int = 2
var otherPlayerId

signal s_otherPlayerConnected
signal s_otherPlayerDisconnected

signal s_connectingAsClient
signal s_connectedAsClient
signal s_networkStatusChanged

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

func isAuthorityAsString():
	if isAuthority():
		return "Host"
	return "Client"

func id():
	return multiplayer.get_unique_id()

# Host
func _peer_connected(id:int):
	print("network [host] - Player %s connected" % id)
	otherPlayerId = id
	s_networkStatusChanged.emit()
	s_otherPlayerConnected.emit()

func _peer_disconnected(id:int):
	print("network [host] - Player %s disconnected" % id)
	s_networkStatusChanged.emit()

# Client
func _connected_to_server():
	otherPlayerId = 1 # since we're only dealing with 2 players at a time
	print("network [client] - connected to server")
	s_networkStatusChanged.emit()
	s_connectedAsClient.emit()
	s_otherPlayerConnected.emit()

func _connection_failed():
	s_networkStatusChanged.emit()
	print("network [client] - connection failed")

func _server_disconnected():
	s_networkStatusChanged.emit()
	print("network [client] - server disconnected")
