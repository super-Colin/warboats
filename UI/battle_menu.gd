extends Control

var activeShots = []

func _ready() -> void:
	%ResetShots.pressed.connect(func():Globals.s_resetShots.emit())
	%ResetShots.pressed.connect(func():Globals.s_resetShots.emit())
	Globals.s_deployReady.connect(updateShotsLeft)


func updateShotsLeft():
	var shotsLeft = Globals.friendlyGridRef.calcTotalShots() - activeShots.size()
	%ShotsLeft.text = "Shots left: " + str(shotsLeft)
