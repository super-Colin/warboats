extends Control

var isHost = true
#var bothPlayersReady = false # This will be used each cycle
var playersReady = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.s_beginDeployPhase.connect(_beginDeployPhase)
	#$Grids/Friendly/Grid.s_boardChanged
	Globals.s_beginBattlePhase.connect(_beginBattlePhase)
	$Grids/Friendly/Grid.s_boardChanged.connect(_boardUpdated)
	$DeployMenu.s_deployConfirmed.connect(deployConfirmed)




@rpc("authority", "call_local", "reliable")
func updateBoardState():
	print("board - updating state... RPC??")


@rpc("any_peer", "call_local", "reliable")
func updateReadyStateLabels(pId):
	print("board - updating state... RPC??: ", pId)
	if pId == Network.id():
		$Grids/Friendly/Label.text = "Deployed"
	else:
		$Grids/Enemy/Label.text = "Deployed"
	playersReady.append(pId)
	if playersReady.size() == 2:
		print("board - both players ready")
		_beginBattlePhase()

#func getBoardState():
	#return {
		#"shipsContained":[]
	#}

func _beginBattlePhase():
	print("board - start battle")
	playersReady = []
	$DeployMenu.visible = false
	$BattleMenu.visible = true
	$Grids/Friendly/Grid.lockShipsIntoPlace()
	Globals.currentBattlePhase = Globals.BattlePhases.BATTLE

func isDeployReady():
	if Globals.roundMinTargetPoints <= $Grids/Friendly/Grid.calcTotalTargetPoints():
		print("board - deploy is ready")
		$DeployMenu.deployIsReady()
		#$Grids/Friendly.text = "Deployed"

func _boardUpdated():
	$DeployMenu.updateLabels()
	if Globals.roundMinTargetPoints <= $Grids/Friendly/Grid.calcTotalTargetPoints():
		print("board - deploy is ready")
		$DeployMenu.deployCanBeConfirmed()

func deployConfirmed():
	#$DeployMenu.visible = true
	#$Grids/Friendly/Label.text = "Deployed"
	updateReadyStateLabels.rpc(Network.id())
	


func _beginDeployPhase():
	$DeployMenu.visible = true
	$BattleMenu.visible = false
	#$Grids/Freindly.visible = true
	#$Grids/Enemy.visible = true

#func _updateDeployMenu():
	#$DeployMenu._boardUpdated()


func checkIfFriendlySideDeployReady():
	#$Grids/Enemy/Grid
	$Grids/Friendly/Grid



	#%DeployPoints.text = "Deploy Points: " + str(Globals.friendlyGrid.startingDeployPoints - Globals.friendlyGrid.calcSpentDeployPoints())
#
#func updateTargetPoints():
	#%TargetPoints.text = "Target Points: " + str(Globals.friendlyGrid.calcTotalTargetPoints()) + "/" + str(Globals.roundMinTargetPoints)
