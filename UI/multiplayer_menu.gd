extends Control





func _ready() -> void:
	%HostServerButton.pressed.connect(_startHost)
	%JoinServerButton.pressed.connect(_startClient)
	Network.s_connectingAsClient.connect(showConnecting)
	Network.s_connectedAsClient.connect(nextPhaseOfGame)
	
	


func _startHost():
	Network.startHost(int(%Port.text))
	nextPhaseOfGame()


func _startClient():
	Network.startClient(%IP.text, int(%Port.text))
	# wait for connected signal
	

func showConnecting():
	%Connecting.visible = true

func nextPhaseOfGame():
	$'.'.visible = false
	Globals.s_beginDeployPhase.emit()
	print("multiplayer - starting next phase")
