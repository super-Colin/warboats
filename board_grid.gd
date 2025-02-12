extends Node2D

@export var gridSize = Vector2(12, 12)
@export var cellSize = Vector2(30, 30)


var cell_scene = preload("res://grid_cell.tscn")




func _ready() -> void:
	makeCells()




func makeCells():
	var halfCellSize = cellSize / 2
	for x in gridSize.x:
		for y in gridSize.y:
			var newCell = cell_scene.instantiate()
			newCell.coords = Vector2(x, y)
			newCell.setSize(cellSize)
			newCell.position = Vector2(cellSize.x * x, cellSize.y * y)
			newCell.position += halfCellSize # add offset since the position is based on the center of then cell
			$'.'.add_child(newCell)
