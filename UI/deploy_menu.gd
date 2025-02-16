extends Control

@onready var remainingDeployPoints = Globals.roundDeployPoints
#var startingDeployPoints = 20

func _ready() -> void:
	%Ready.pressed.connect(func():Globals.s_deployReady.emit())
	Globals.s_beginBattlePhase.connect(_beginBattlePhase)
	Globals.s_boardChanged.connect(_boardUpdated)
	setShowReadyWuttonNotReady()

func _beginBattlePhase():
	$'.'.visible = false
	_boardUpdated()

func _boardUpdated():
	updateDeployPoints()
	updateTargetPoints()

func updateDeployPoints():
	#%DeployPoints.text = "Deploy Points: " + str(Globals.friendlyGrid.calcSpentDeployPoints()) + "/" + str(Globals.roundDeployPoints)
	%DeployPoints.text = "Deploy Points: " + str(Globals.friendlyGrid.startingDeployPoints - Globals.friendlyGrid.calcSpentDeployPoints())

func updateTargetPoints():
	%TargetPoints.text = "Target Points: " + str(Globals.friendlyGrid.calcTotalTargetPoints()) + "/" + str(Globals.roundMinTargetPoints)

func setShowReadyWuttonNotReady():
	%ReadyButton.modulate = "d82643"

func setShowReadyWuttonIsReady():
	%ReadyButton.modulate = "3dc300"
