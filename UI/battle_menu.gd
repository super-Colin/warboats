extends Control

signal s_confirmShotMarkers
signal s_resetShotMarkers
signal s_playAgain
signal s_toMainMenu

func _ready() -> void:
	%ResetShots.pressed.connect(func():s_resetShotMarkers.emit())
	%ConfirmShots.pressed.connect(func():s_confirmShotMarkers.emit())
	%PlayAgain.pressed.connect(func():s_playAgain.emit())
	%MainMenu.pressed.connect(func():s_toMainMenu.emit())
	Globals.s_battlePhaseChanged.connect(battleOver)

func battleOver():
	if Globals.currentBattlePhase == Globals.BattlePhases.BATTLE_OVER:
		%ResetShots.visible = false
		%ConfirmShots.visible = false
		%PlayAgain.visible = true
		%MainMenu.visible = true

func _beginBattlePhase():
	$'.'.visible = true
	resetShotsLeft()


func updateShotsLeft(shotsLeft:int):
	%ShotsLeft.text = "Shots left: " + str(shotsLeft)

func resetShotsLeft():
	%ShotsLeft.text = "Shots left: " + str(Globals.friendlyGrid.calcTotalShots())
