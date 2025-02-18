extends Control

#var activeShots = []

signal s_confirmShotMarkers
signal s_resetShotMarkers

func _ready() -> void:
	%ResetShots.pressed.connect(func():s_resetShotMarkers.emit())
	%ConfirmShots.pressed.connect(func():s_confirmShotMarkers.emit())
	#Globals.s_beginBattlePhase.connect(_beginBattlePhase)
	Globals.s_placedShotMarker.connect(updateShotsLeft)
	Globals.s_resetShotMarkers.connect(resetShotsLeft)




func _beginBattlePhase():
	$'.'.visible = true
	resetShotsLeft()





func updateShotsLeft(shotsLeft:int):
	#print("battle menu - updating shots: ", Globals.friendlyGrid.calcRemainingShots())
	%ShotsLeft.text = "Shots left: " + str(shotsLeft)

func resetShotsLeft():
	%ShotsLeft.text = "Shots left: " + str(Globals.friendlyGrid.calcTotalShots())
