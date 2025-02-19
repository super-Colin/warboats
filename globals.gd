extends Node


signal s_beginDeployPhase
signal s_beginBattlePhase
signal s_boardChanged


signal coordHoveredOn(coord:Vector2)
signal coordHoveredOff(coord:Vector2)


var friendlyGrid:Node
var enemyGrid:Node
#var boardRef:Node

enum BattlePhases {MENU=0, DEPLOY=1, BATTLE=2, BATTLE_OVER=3}
signal s_battlePhaseChanged
var currentBattlePhase:BattlePhases = BattlePhases.MENU:
	set(newVal):
		currentBattlePhase = newVal
		s_battlePhaseChanged.emit()
