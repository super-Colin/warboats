extends Control

var delpoyConfirmable = false

signal s_deployConfirmed

func _ready() -> void:
	%ReadyButton.pressed.connect(tryDeploy)
	deployCanNotBeConfirmed()


func tryDeploy():
	if delpoyConfirmable:
		s_deployConfirmed.emit()

func updateDeployPoints(pts):
	%DeployPoints.text = "Deploy Points: " + str(pts)

func updateTargetPoints(current, target):
	%TargetPoints.text = "Target Points: " + str(current) + "/" + str(target)

func deployCanNotBeConfirmed():
	delpoyConfirmable = false
	%ReadyButton.modulate = "d82643"

func deployCanBeConfirmed():
	delpoyConfirmable = true
	%ReadyButton.modulate = "3dc300"
