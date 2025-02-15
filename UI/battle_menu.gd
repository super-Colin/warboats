extends Control

var activeShots = []

func _ready() -> void:
	%ResetShots.pressed.connect(func():Globals.s_resetShotMarkers.emit())
	%ConfirmShots.pressed.connect(func():Globals.s_confirmShotMarkers.emit())
	Globals.s_beginBattlePhase.connect(_beginBattlePhase)
	Globals.s_placedShotMarker.connect(updateShotsLeft)
	Globals.s_resetShotMarkers.connect(resetShotsLeft)




func _beginBattlePhase():
	$'.'.visible = true
	resetShotsLeft()


func updateShotsLeft():
	print("battle menu - updating shots: ", Globals.friendlyGrid.calcRemainingShots())
	%ShotsLeft.text = "Shots left: " + str(Globals.calcRemainingShots())

func resetShotsLeft():
	%ShotsLeft.text = "Shots left: " + str(Globals.friendlyGrid.calcTotalShots())
