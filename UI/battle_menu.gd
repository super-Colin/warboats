extends Control

var activeShots = []

func _ready() -> void:
	%ResetShots.pressed.connect(func():Globals.s_resetShots.emit())
	%ConfirmShots.pressed.connect(func():Globals.s_confirmShotMarkers.emit())
	#Globals.s_deployReady.connect(updateShotsLeft)
	Globals.s_beginBattlePhase.connect(_beginBattlePhase)

func _beginBattlePhase():
	$'.'.visible = true
	updateShotsLeft()


func updateShotsLeft():
	var shotsLeft = Globals.friendlyGrid.calcTotalShots() - activeShots.size()
	%ShotsLeft.text = "Shots left: " + str(shotsLeft)
