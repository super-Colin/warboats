extends Control

#@onready var remainingDeployPoints = Globals.roundDeployPoints
#var startingDeployPoints = 20

signal s_deployConfirmed

func _ready() -> void:
	#%ReadyButton.pressed.connect(func():Globals.s_deployReady.emit())
	%ReadyButton.pressed.connect(func():s_deployConfirmed.emit())
	#Globals.s_beginBattlePhase.connect(_beginBattlePhase)
	#Globals.s_boardChanged.connect(_boardUpdated)
	deployCanNotBeConfirmed()

#func _beginBattlePhase():
	#$'.'.visible = false
	#updateLabels()

func updateLabels():
	updateDeployPoints()
	updateTargetPoints()

func updateDeployPoints():
	#%DeployPoints.text = "Deploy Points: " + str(Globals.friendlyGrid.calcSpentDeployPoints()) + "/" + str(Globals.roundDeployPoints)
	%DeployPoints.text = "Deploy Points: " + str(Globals.friendlyGrid.startingDeployPoints - Globals.friendlyGrid.calcSpentDeployPoints())

func updateTargetPoints():
	%TargetPoints.text = "Target Points: " + str(Globals.friendlyGrid.calcTotalTargetPoints()) + "/" + str(Globals.roundMinTargetPoints)


func deployCanNotBeConfirmed():
	%ReadyButton.modulate = "d82643"

func deployCanBeConfirmed():
	%ReadyButton.modulate = "3dc300"
