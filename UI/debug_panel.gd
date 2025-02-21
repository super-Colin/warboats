extends Control




func _ready() -> void:
	updatePhaseLabel()
	Globals.s_battlePhaseChanged.connect(updatePhaseLabel)
	Globals.s_boardChanged.connect(updateFleet)
	Network.s_networkStatusChanged.connect(updateServerAuthLabel)
	Network.s_networkStatusChanged.connect(updateServerIdLabel)

func updateFleet():
	%Fleet.text = str(Globals.friendlyGrid.shipsContained) 

func updatePhaseLabel():
	%GamePhase.text = "Game phase: "+str(Globals.BattlePhases.keys()[Globals.currentBattlePhase])

func updateServerAuthLabel():
	%ServerAuthority.text = "Server Role: " + Network.role 
func updateServerIdLabel():
	%ServerId.text = "Server Id: " + str(Network.id())
