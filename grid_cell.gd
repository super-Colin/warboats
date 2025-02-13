
extends TextureRect

@export var draggable = false
@export var droppable = true

var customSize:Vector2 = Vector2(40, 40)
var shipRef:Node
var isShip:bool = false
var coords:Vector2
var hoveredOn = false

func _ready() -> void:
	Globals.s_clearBoardHighlights.connect(disableHighlight)
	Globals.s_removeShipFromBoard.connect(removeShipSprite)
	Globals.s_deployReady.connect(func():lockIntoPlace())
	#Globals.s_confirmShotMarker.connect()
	$'.'.mouse_entered.connect(startHoverState)
	$'.'.mouse_exited.connect(endHoverState)



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("MarkShot") and hoveredOn:
		print("cell - clicked on: ", coords)
		Globals.s_placeShotMarker.emit(coords)

func lockIntoPlace():
	draggable = false

func removeShipSprite(shipId):
	if isShip and shipRef.shipId == shipId:
		print("cell - clearing out ship sprite, at coords: ", coords)
		$'.'.texture = null

#@export var textureSetup:AtlasTexture:
	#set(newVal):
		#textureSetup = newVal
		#$'.'.texture = newVal

func _get_drag_data(at_position: Vector2) -> Variant:
	if not draggable:
		print("cell - NOT draggable")
		return null
	var preview = shipRef.duplicate()
	preview.visible = true
	preview.modulate.a = 0.6
	set_drag_preview(preview)
	#$'.'.texture = null
	#Globals.s_removeShipFromBoard.emit(shipRef.shipId)
	return shipRef


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not droppable:
		return false
	#print("cell - can drop data? : ", data, ", at coords: ", coords)
	#if typeof(data) == TYPE_DICTIONARY and data.has("shipShape"):
	if data is Node and "shipShape" in data:
		#print("cell - droppable has shipShape")
		return $'.'.get_parent().hightlightShape(data.shipShape, coords)
		#return $'.'.get_parent().doesShapeFit()
		#return true
	else:
		return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("cell - setting on drop: ", data)
	$'.'.get_parent().setShipIntoGrid(data, coords)
	draggable = true


func setSize(newSize:Vector2):
	#$Box.shape.size = newSize
	customSize = newSize
	$Highlight.custom_minimum_size = newSize


#func _ready() -> void:
	#$Peg.visible = false
	#$'.'.mouse_entered.connect(enableHighlight)
	#$'.'.mouse_exited.connect(disableHighlight)


func startHoverState():
	hoveredOn = true
	if not get_parent().friendly:
		enableHighlight()
	else:
		Globals.enemyGrid.highlightSpot(coords)
func endHoverState():
	hoveredOn = false
	disableHighlight()
	Globals.enemyGrid.disableHighlightSpot(coords)

func enableHighlight():
	$Highlight.visible = true
	#print("cell - highlighting at: ", coords)

func disableHighlight():
	$Highlight.visible = false

func clearMarker():
	$Peg.visible = false

func makeUncomfirmedMarker():
	$Peg.color = Color.PURPLE
	$Peg.visible = true

func makeHitMarker():
	$Peg.color = Color.RED
	$Peg.visible = true

func makeHMissMarker():
	$Peg.color = Color.WHITE
	$Peg.visible = true
