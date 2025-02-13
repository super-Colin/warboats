extends Node2D

@export var gridSize = Vector2(12, 12)
@export var cellSize = Vector2(30, 30)
var cellsRefs = []

var cell_scene = preload("res://grid_cell.tscn")




func _ready() -> void:
	for c in $'.'.get_children():
		c.queue_free()
	makeCells()

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
	for x in shape.x:
		if not cellsRefs.size() > x:
			print("ran out of space on the x axis")
			return false
		for y in shape.y:
			if not cellsRefs[x].size() > y:
				print("ran out of space on the y axis")
				return false
			cellsRefs[x][y].enableHighlight()


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
