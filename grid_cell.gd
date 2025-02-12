extends TextureRect

var isShip:bool = false
var coords:Vector2
var customSize:Vector2 = Vector2(40, 40)

func _get_drag_data(at_position: Vector2) -> Variant:
	var previewTexture = TextureRect.new()
	previewTexture.texture = $'.'.texture
	previewTexture.expand_mode = 1
	previewTexture.size = customSize
	var preview = Control.new()
	preview.add_child(previewTexture)
	set_drag_preview(preview)
	$'.'.texture = null
	return previewTexture.texture


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	print("cell - can drop data? : ", data)
	if data is Texture2D:
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	$'.'.texture = data


func setSize(newSize:Vector2):
	#$Box.shape.size = newSize
	customSize = newSize
	$Highlight.custom_minimum_size = newSize

#func _ready() -> void:
	#$Peg.visible = false
	#$'.'.mouse_entered.connect(enableHighlight)
	#$'.'.mouse_exited.connect(disableHighlight)
#
#
#func enableHighlight():
	#$Highlight.visible = true
	##print("cell - highlighting at: ", coords)
#
#func disableHighlight():
	#$Highlight.visible = false
#
#func makeHitMarker():
	#$Peg.color = Color.RED
	#$Peg.visible = true
#
#func makeHMissMarker():
	#$Peg.color = Color.WHITE
	#$Peg.visible = true
#
