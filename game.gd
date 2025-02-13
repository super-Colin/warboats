extends Node2D


func _ready() -> void:
	Globals.s_sideReady.connect(sideReadied)

func sideReadied(isFriendly=true):
	if isFriendly:
		Globals.friendlySideReady = true
	else:
		Globals.enemySideReady = true

func proceedTurn(sideThatJust):
	if Globals.friendlySideReady and Globals.enemySideReady:
		print("globals - proceeding turn")
		Globals.enemySideReady= false
		Globals.friendlySideReady= false
