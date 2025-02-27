extends Node

signal s_toMainMenu

signal s_beginDeployPhase
signal s_beginBattlePhase
signal s_boardChanged


signal coordHoveredOn(coord:Vector2)
signal coordHoveredOff(coord:Vector2)

signal s_clearBoardHighlights # ships use this when a drag fails

var boardRef:Node
var friendlyGrid:Node
var enemyGrid:Node
var popUpMessage:Node
#var boardRef:Node

enum BattlePhases {MENU=0, DEPLOY=1, BATTLE=2, BATTLE_OVER=3}
signal s_battlePhaseChanged
var currentBattlePhase:BattlePhases = BattlePhases.MENU:
	set(newVal):
		currentBattlePhase = newVal
		s_battlePhaseChanged.emit()
