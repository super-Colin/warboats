extends Control


func _ready() -> void:
	Globals.s_beginDeployPhase.connect(_beginDeployPhase)


func _beginDeployPhase():
	$MultiPlayerMenu.visible = false
	$Board.visible = true
