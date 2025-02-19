extends Control


signal s_deployConfirmed

func _ready() -> void:
	%ReadyButton.pressed.connect(func():s_deployConfirmed.emit())
	deployCanNotBeConfirmed()

func updateDeployPoints(pts):
	%DeployPoints.text = "Deploy Points: " + str(pts)

func updateTargetPoints(current, target):
	%TargetPoints.text = "Target Points: " + str(current) + "/" + str(target)

func deployCanNotBeConfirmed():
	%ReadyButton.modulate = "d82643"

func deployCanBeConfirmed():
	%ReadyButton.modulate = "3dc300"
