extends Node2D

@export var gridSize:Vector2 = Vector2(12, 12)
@export var cellSize:Vector2 = Vector2(30, 30)
@export var friendly:bool = true
var cellsRefs = []
var currentlyHighlightedCells = []

var cell_scene = preload("res://grid_cell.tscn")

func calcTotalShots():
	return 5

func _ready() -> void:
	for c in $'.'.get_children(): # current cells are only there to be visibile in the editor
		c.queue_free()
	if friendly:
		Globals.friendlyGrid = $'.'
	else:
		Globals.s_placeShotMarker.connect(_placeShotMarker)
		Globals.enemyGrid = $'.'
	makeCells()
func highlightSpot(coords):
	cellsRefs[coords.x][coords.y].enableHighlight()
func disableHighlightSpot(coords):
	cellsRefs[coords.x][coords.y].disableHighlight()
func _placeShotMarker(coords):
	cellsRefs[coords.x][coords.y].makeUncomfirmedMarker()

func setShipIntoGrid(ship:Node, startingCoord:Vector2):
	print("grid - setting ship")
	Globals.s_removeShipFromBoard.emit(ship.shipId)
	Globals.s_clearBoardHighlights.emit()
	for x in ship.shipShape.x:
		var xActual =  startingCoord.x + x
		for y in ship.shipShape.y:
			var yActual =  startingCoord.y + y
			cellsRefs[xActual][yActual].isShip = true
			cellsRefs[xActual][yActual].shipRef = ship # while placing ships, ship is still invisible on the side invisible
			var shipTextureTile = ship.get_node("x"+str(x)+"y"+str(y)).texture
			cellsRefs[xActual][yActual].texture = shipTextureTile

func doesShapeFit(shape:Vector2, startingCoord:Vector2=Vector2.ZERO):
	for x in shape.x:
		if not cellsRefs.size() > x:
			print("ran out of space on the x axis")
			return false
		for y in shape.y:
			if not cellsRefs[x].size() > y:
				print("ran out of space on the y axis")
				return false

func hightlightShape(shape:Vector2, startingCoord:Vector2=Vector2.ZERO):
	for c in currentlyHighlightedCells:
		c.disableHighlight()
	for x in shape.x:
		var xActual =  startingCoord.x + x
		if not cellsRefs.size() > xActual:
			print("ran out of space on the x axis")
			return false
		for y in shape.y:
			var yActual =  startingCoord.y + y
			if not cellsRefs[xActual].size() > yActual:
				print("ran out of space on the y axis")
				return false
			cellsRefs[xActual][yActual].enableHighlight()
			currentlyHighlightedCells.append(cellsRefs[xActual][yActual])
	return true


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
