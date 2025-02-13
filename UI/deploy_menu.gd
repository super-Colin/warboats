extends Control


func _ready() -> void:
	%Ready.pressed.connect(func():Globals.s_deployReady.emit())
