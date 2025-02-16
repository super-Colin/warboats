extends Control





func startClient():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(%IP.text, int(%Port.text))
	multiplayer.multiplayer_peer = peer





func startHost():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(int(%Port.text), 2, )
