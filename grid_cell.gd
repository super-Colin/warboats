
extends TextureRect

@export var draggable = false
@export var droppable = true

var customSize:Vector2 = Vector2(40, 40)
var shipRef:Node
var isShip:bool = false
var coords:Vector2
var hoveredOn = false
var isMarkedForShot = false
var confirmed = false

func _ready() -> void:
	Globals.s_clearBoardHighlights.connect(disableHighlight)
	Globals.s_removeShipFromBoard.connect(removeShipSprite)
	Globals.s_deployReady.connect(lockIntoPlace)
	Globals.s_confirmShotMarkers.connect(_confirmShotMarker)
	Globals.s_resetShotMarkers.connect(_resetShotMarkers)
	$'.'.mouse_entered.connect(startHoverState)
	$'.'.mouse_exited.connect(endHoverState)

# Set size, called by parent grid
func setSize(newSize:Vector2):
	customSize = newSize
	$'.'.custom_minimum_size = newSize
	$Highlight.custom_minimum_size = newSize




func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("MarkShot") and hoveredOn:
		#print("cell - clicked on: ", coords)
		Globals.s_placeShotMarker.emit(coords)

func lockIntoPlace():
	draggable = false

func isEmpty():
	if not confirmed and not isShip:
		return true

func removeShipSprite(shipId):
	if isShip and shipRef.shipId == shipId:
		#print("cell - clearing out ship sprite, at coords: ", coords)
		$'.'.texture = null

# Drag and Drop
func _get_drag_data(at_position: Vector2) -> Variant:
	if not draggable:
		#print("cell - NOT draggable")
		return null
	var preview = shipRef.duplicate()
	preview.visible = true
	preview.modulate.a = 0.6
	set_drag_preview(preview)
	return shipRef

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not droppable or not $'.'.get_parent().friendly:
		return false
	if data is Node and "shipShape" in data:
		return $'.'.get_parent().hightlightShape(data.shipShape, coords)
	else:
		return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	#print("cell - setting on drop: ", data)
	$'.'.get_parent().setShipIntoGrid(data, coords)


# Decide what type of marker should be used
func _resetShotMarkers():
	if isMarkedForShot:
		hidePeg()
		isMarkedForShot = false

func _confirmShotMarker():
	if isMarkedForShot:
		if isShip:
			makeHitMarker()
		else:
			makeHMissMarker()
		isMarkedForShot = false
		confirmed = true









# Hover state
func startHoverState():
	hoveredOn = true
	Globals.coordHoveredOn.emit(coords)
func endHoverState():
	hoveredOn = false
	Globals.coordHoveredOff.emit(coords)

# Highlight visibility
func enableHighlight():
	$Highlight.visible = true
func disableHighlight():
	$Highlight.visible = false
func clearMarker():
	$Peg.visible = false

# Peg color / visibility
func hidePeg():
	$Peg.visible = false
func makeUncomfirmedMarker():
	if not isMarkedForShot and not confirmed:
		$Peg.color = Color.PURPLE
		$Peg.visible = true
		isMarkedForShot = true
		return true
func makeHitMarker():
	$Peg.color = Color.RED
	$Peg.visible = true
func makeHMissMarker():
	$Peg.color = Color.WHITE
	$Peg.visible = true
