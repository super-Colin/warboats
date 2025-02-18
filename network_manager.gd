extends Node

var maxClients:int = 2
var otherPlayerId

signal s_connectingAsClient
signal s_connectedAsClient

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


func isAuthority():
	return get_multiplayer_authority() == multiplayer.get_unique_id()

func id():
	return multiplayer.get_unique_id()

# Host
func _peer_connected(id:int):
	print("network [host] - Player %s connected" % id)
	otherPlayerId = id

func _peer_disconnected(id:int):
	print("network [host] - Player %s disconnected" % id)

# Client
func _connected_to_server():
	print("network [client] - connected to server")
	s_connectedAsClient.emit()

func _connection_failed():
	print("network [client] - connection failed")

func _server_disconnected():
	print("network [client] - server disconnected")
