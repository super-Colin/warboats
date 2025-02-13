extends Node


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




#func _ready() -> void:
	#s_friendlySideReady.connect(func(): friendlySideReady = true)
	#s_enemySideReady.connect(func(): enemySideReady = true)
	#sideReady.connect(proceedTurn)
