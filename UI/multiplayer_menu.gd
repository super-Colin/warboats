extends Control





func _ready() -> void:
	%HostServerButton.pressed.connect(_startHost)
	%JoinServerButton.pressed.connect(_startClient)
	Network.s_connectingAsClient.connect(showConnecting)
	Network.s_connectedAsClient.connect(startDeployPhase)
	
	


func _startHost():
	Network.startHost(int(%Port.text))
	startDeployPhase()


func _startClient():
	Network.startClient(%IP.text, int(%Port.text))
	# wait for connected signal
	

func showConnecting():
	%Connecting.visible = true

func startDeployPhase():
	$'.'.visible = false
	Globals.s_beginDeployPhase.emit()
	Globals.currentBattlePhase = Globals.BattlePhases.DEPLOY
	print("multiplayer - starting deploy phase")
