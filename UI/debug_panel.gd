extends Control




func _ready() -> void:
	updatePhaseLabel()
	Globals.s_battlePhaseChanged.connect(updatePhaseLabel)


func updatePhaseLabel():
	%GamePhase.text = "Game phase: "+str(Globals.BattlePhases.keys()[Globals.currentBattlePhase])
