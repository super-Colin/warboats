extends Control

@onready var remainingDeployPoints = Globals.roundDeployPoints

func _ready() -> void:
	%Ready.pressed.connect(func():Globals.s_deployReady.emit())
	Globals.s_beginBattlePhase.connect(_beginBattlePhase)
	Globals.s_deployBoardChanged.connect(updateTargetPoints)
	Globals.s_deployBoardChanged.connect(updateDeployPoints)

func _beginBattlePhase():
	$'.'.visible = false
	#updateTargetPoints()
	#updateDeployPoints()


func updateDeployPoints():
	%DeployPoints.text = "Deploy Points: " + str(Globals.friendlyGrid.calcSpentDeployPoints()) + "/" + str(Globals.roundDeployPoints)

func updateTargetPoints():
	%TargetPoints.text = "Target Points: " + str(Globals.friendlyGrid.calcTotalTargetPoints()) + "/" + str(Globals.roundMinTargetPoints)
