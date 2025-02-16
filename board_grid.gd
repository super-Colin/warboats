extends Node2D

@export var gridSize:Vector2 = Vector2(12, 12)
@export var cellSize:Vector2 = Vector2(40, 40)
@export var friendly:bool = true
var cellsRefs = []
var shipsContained = [] :
	set(newVal):
		shipsContained = newVal
		Globals.s_boardChanged.emit()

var cell_scene = preload("res://grid_cell.tscn")

signal s_removeShipFromBoard(shipId)
signal s_clearBoardHighlights

var currentlyHighlightedCells = []
var unconfirmedShots = 0
var startingDeployPoints = 20
var minTargetPoints = 30


func _ready() -> void:
	for c in $'.'.get_children(): # current cells are only there to be visibile in the editor
		c.queue_free()
	if friendly:
		Globals.friendlyGrid = $'.'
	else:
		Globals.s_placeShotMarker.connect(_placeShotMarker)
		Globals.enemyGrid = $'.'
	Globals.s_resetShotMarkers.connect(_resetShotMarkers)
	Globals.coordHoveredOn.connect(cellHoveredOn)
	Globals.coordHoveredOff.connect(cellHoveredOff)
	makeCells()



func setShipIntoGrid(ship:Node, startingCoord:Vector2):
	print("grid - setting ship")
	if shipsContained.has(ship):
		s_removeShipFromBoard.emit(ship.shipId)
	s_clearBoardHighlights.emit()
	for x in ship.shipShape.x:
		var xActual =  startingCoord.x + x
		for y in ship.shipShape.y:
			var yActual =  startingCoord.y + y
			var shipTextureTile = ship.get_node("x"+str(x)+"y"+str(y)).texture
			cellsRefs[xActual][yActual].setShipTexture(ship, shipTextureTile)
	if not shipsContained.has(ship):
		shipsContained.append(ship)
		#Globals.s_spentDeployPoints.emit(ship.deployCost)
		Globals.s_boardChanged.emit()
	#Globals.s_deployBoardChanged.emit()

func removeShipFromBoard(ship:Node):
	#Globals.s_refundDeployPoints.emit(ship.deployCost)
	s_removeShipFromBoard.emit(ship.shipId)
	Globals.s_boardChanged.emit()



func calcTotalTargetPoints():
	var total = 0
	for s in shipsContained:
		#total += shipsContained[s]
		total += s.targetPoints
	return total

func calcSpentDeployPoints():
	var total = 0
	for s in shipsContained:
		#total += shipsContained[s]
		total += s.deployCost
	return total



func addToUnconfirmedShots():
	unconfirmedShots += 1

func calcTotalShots():
	return 5

func calcTotalMarkers():
	return unconfirmedShots

func calcRemainingShots():
	return calcTotalShots() - unconfirmedShots




#func doesShapeFit(shape:Vector2, startingCoord:Vector2=Vector2.ZERO):
	#for x in shape.x:
		#if not cellsRefs.size() > x:
			#print("ran out of space on the x axis")
			#return false
		#for y in shape.y:
			#if not cellsRefs[x].size() > y:
				#print("ran out of space on the y axis")
				#return false


# could add red highlight for incompatible cells, but thats a lot
func hightlightShape(shape:Vector2, startingCoord:Vector2=Vector2.ZERO)->bool:
	for c in currentlyHighlightedCells:
		c.disableHighlight()
	var allGood = true
	for x in shape.x:
		var xActual =  startingCoord.x + x
		if not cellsRefs.size() > xActual:
			#print("ran out of space on the x axis")
			return false
		for y in shape.y:
			var yActual =  startingCoord.y + y
			if not cellsRefs[xActual].size() > yActual:
				#print("ran out of space on the y axis")
				return false
			if not cellsRefs[xActual][yActual].isEmpty():
				allGood = false
				#cellsRefs[xActual][yActual].enableBadHighlight()
			else:
				cellsRefs[xActual][yActual].enableHighlight()
				currentlyHighlightedCells.append(cellsRefs[xActual][yActual])
	return allGood


func makeCells():
	#var halfCellSize = cellSize / 2
	for x in gridSize.x:
		cellsRefs.append([])
		for y in gridSize.y:
			var newCell = cell_scene.instantiate()
			newCell.coords = Vector2(x, y)
			newCell.setSize(cellSize)
			newCell.position = Vector2(cellSize.x * x, cellSize.y * y)
			#newCell.position += halfCellSize # add offset since the position is based on the center of then cell
			$'.'.add_child(newCell)
			
			cellsRefs[x].append(newCell)
	#print("grid - cellRefs: ", cellsRefs)




func cellHoveredOn(coords:Vector2):
	if Globals.currentBattlePhase != Globals.BattlePhases.BATTLE:
		return
	if not friendly:
		highlightSpot(coords)
func cellHoveredOff(coords:Vector2):
	disableHighlightSpot(coords)


func highlightSpot(coords):
	cellsRefs[coords.x][coords.y].enableHighlight()
func disableHighlightSpot(coords):
	cellsRefs[coords.x][coords.y].disableHighlight()

func _resetShotMarkers():
	unconfirmedShots = 0
func _placeShotMarker(coords):
	if not Globals.currentBattlePhase == Globals.BattlePhases.BATTLE:
		return
	if calcRemainingShots() > 0 and not cellsRefs[coords.x][coords.y].isMarkedForShot:
		if cellsRefs[coords.x][coords.y].makeUncomfirmedMarker():
			unconfirmedShots += 1
			Globals.s_placedShotMarker.emit()
		#print("grid - shots left: ", calcRemainingShots(), ", unconfirmed shots: ", unconfirmedShots)
	#else:
		#print("grid - no shots left")
