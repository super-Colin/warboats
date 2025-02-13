#@tool
extends TextureRect

@export var droppable = true

var isShip:bool = false
var coords:Vector2
var customSize:Vector2 = Vector2(40, 40)

#@export var textureSetup:AtlasTexture:
	#set(newVal):
		#textureSetup = newVal
		#$'.'.texture = newVal

#func _get_drag_data(at_position: Vector2) -> Variant:
	#var previewTexture = TextureRect.new()
	#previewTexture.texture = $'.'.texture
	#previewTexture.expand_mode = 1
	#previewTexture.size = customSize
	#var preview = Control.new()
	#preview.add_child(previewTexture)
	#set_drag_preview(preview)
	#$'.'.texture = null
	#return previewTexture.texture


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not droppable:
		return false
	#print("cell - can drop data? : ", data, ", at coords: ", coords)
	if typeof(data) == TYPE_DICTIONARY and data.has("shipShape"):
		print("cell - droppable has shipShape")
		$'.'.get_parent().hightlightShape(data.shipShape)
		return true
	else:
		return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("cell - setting on drop: ", data)
	#$'.'.texture = data


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
func enableHighlight():
	$Highlight.visible = true
	#print("cell - highlighting at: ", coords)

func disableHighlight():
	$Highlight.visible = false
#
#func makeHitMarker():
	#$Peg.color = Color.RED
	#$Peg.visible = true
#
#func makeHMissMarker():
	#$Peg.color = Color.WHITE
	#$Peg.visible = true
#
