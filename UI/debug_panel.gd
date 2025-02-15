extends Control




func _ready() -> void:
	updatePhaseLabel()
	Globals.s_battlePhaseChanged.connect(updatePhaseLabel)
	Globals.s_deployBoardChanged.connect(updateFleet)

func updateFleet():
	%Fleet.text = str(Globals.friendlyGrid.shipsContained) 

func updatePhaseLabel():
	%GamePhase.text = "Game phase: "+str(Globals.BattlePhases.keys()[Globals.currentBattlePhase])
