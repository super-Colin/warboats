extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.popUpMessage = $'.'
	%ConfirmButton.pressed.connect(closePopUp)
	Network.s_popupWorthyMessage.connect(newMessage)

func newMessage(newMessage:String):
	%Message.text = newMessage
	$'.'.visible = true

func closePopUp():
	$'.'.visible = false
	Globals.s_toMainMenu.emit()
