extends Control




func _ready() -> void:
	updatePhaseLabel()
	Globals.s_battlePhaseChanged.connect(updatePhaseLabel)
	Globals.s_boardChanged.connect(updateFleet)
	
	Globals.s_battlePhaseChanged.connect(updateServerAuthLabel)
	Globals.s_boardChanged.connect(updateServerAuthLabel)

func updateFleet():
	%Fleet.text = str(Globals.friendlyGrid.shipsContained) 

func updatePhaseLabel():
	%GamePhase.text = "Game phase: "+str(Globals.BattlePhases.keys()[Globals.currentBattlePhase])

func updateServerAuthLabel():
	var isAuth = "Yes"
	if not Network.isAuthority():
		isAuth = "No"
	%ServerAuthority.text = "Is Server Authority: " + isAuth 
