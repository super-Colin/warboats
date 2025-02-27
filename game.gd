extends Control


func _ready() -> void:
	Globals.s_beginDeployPhase.connect(_beginDeployPhase)
	Globals.s_toMainMenu.connect(toMainMenu)

func toMainMenu():
	$MultiPlayerMenu.visible = true
	$Board.visible = false

func _beginDeployPhase():
	$MultiPlayerMenu.visible = false
	$Board.visible = true
