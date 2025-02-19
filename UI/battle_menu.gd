extends Control

signal s_confirmShotMarkers
signal s_resetShotMarkers

func _ready() -> void:
	%ResetShots.pressed.connect(func():s_resetShotMarkers.emit())
	%ConfirmShots.pressed.connect(func():s_confirmShotMarkers.emit())


func _beginBattlePhase():
	$'.'.visible = true
	resetShotsLeft()


func updateShotsLeft(shotsLeft:int):
	%ShotsLeft.text = "Shots left: " + str(shotsLeft)

func resetShotsLeft():
	%ShotsLeft.text = "Shots left: " + str(Globals.friendlyGrid.calcTotalShots())
