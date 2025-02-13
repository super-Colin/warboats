extends Control

@export var shipShape:Vector2 = Vector2(1, 3)
var textures

var dragging = false


func getDropInfo():
	return {
		"shipShape":shipShape
	}

func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview($'.'.duplicate())
	dragging = true
	return getDropInfo()


#func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	#print("cell - can drop data? : ", data)
	#if data is Texture2D:
		#return true
	#return false

#func _drop_data(at_position: Vector2, data: Variant) -> void:
	#$'.'.texture = data



func _notification(what: int) -> void:
	#if what is Node.NOTIFICATION_DRAG_END:
	if what == NOTIFICATION_DRAG_END:
		if dragging:
			#print("ship - drag ended")
			dragging = false
			if is_drag_successful():
				print("ship - drag was successful")
			#else:
				#print("ship - drag was NOT successful")


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
