extends Control


@export var shipType = 1
@export var shipShape:Vector2 = Vector2(1, 3)
@export var targetPoints = 11
@export var deployCost = 3
@export var shotsAvailable = 1

@onready var shipId:int = $'.'.get_instance_id()

var textures
var placedAt:Vector2 
var dragging = false
var dead = false



func simpleDict():
	return {
		"placedAt": placedAt,
		"shipId": shipId,
		"shipType": shipType,
	}



func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview($'.'.duplicate())
	dragging = true
	return $'.'



func _notification(what: int) -> void:
	#if what is Node.NOTIFICATION_DRAG_END:
	if what == NOTIFICATION_DRAG_END:
		if dragging:
			#print("ship - drag ended")
			dragging = false
			if is_drag_successful():
				#print("ship - drag was successful")
				$'.'.visible = false
				#Globals.s_removeShipFromBoard.emit(shipId)
			else:
				#print("ship - drag was NOT successful")
				Globals.s_clearBoardHighlights.emit()


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
