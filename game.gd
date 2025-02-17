extends Node2D


func _ready() -> void:
	#Globals.gameRef = $'.'
	Globals.s_sideReady.connect(_sideReadied)
	Globals.s_deployReady.connect(_deployReady)
	Globals.s_beginDeployPhase.connect(_beginDeployPhase)


func _beginDeployPhase():
	$Menus/DeployMenu.visible = true
	$freindly.visible = true
	$enemy.visible = true

func _deployReady():
	Globals.s_beginBattlePhase.emit()

func _sideReadied(isFriendly=true):
	if isFriendly:
		Globals.friendlySideReady = true
	else:
		Globals.enemySideReady = true
	#Globals.s_beginBattlePhase.emit()

func proceedTurn(sideThatJust):
	if Globals.friendlySideReady and Globals.enemySideReady:
		print("globals - proceeding turn")
		Globals.enemySideReady= false
		Globals.friendlySideReady= false
