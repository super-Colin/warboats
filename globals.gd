extends Node

signal s_placeShotMarker(coords:Vector2)
signal s_confirmShotMarker

signal s_deployReady

signal s_resetShots

signal s_clearBoardHighlights

signal s_removeShipFromBoard(shipId)

signal s_sideReady(isFriendly:bool) # friendly side or enemy side
var friendlySideReady= false
var enemySideReady= false

var friendlyGrid:Node
var enemyGrid:Node
var hitMarkerGrid:Node

enum BattlePhases {SETUP=0,}
var currentBattlePhase:BattlePhases = BattlePhases.SETUP

#var friendlyGridRef:Node



#func _ready() -> void:
	#s_friendlySideReady.connect(func(): friendlySideReady = true)
	#s_enemySideReady.connect(func(): enemySideReady = true)
	#sideReady.connect(proceedTurn)
