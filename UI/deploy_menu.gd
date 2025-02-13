extends Control


func _ready() -> void:
	%Ready.pressed.connect(func():Globals.s_deployReady.emit())
	Globals.s_beginBattlePhase.connect(_beginBattlePhase)

func _beginBattlePhase():
	$'.'.visible = false
