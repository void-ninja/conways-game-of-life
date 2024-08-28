extends Node2D

const SQUARE_SIZE_IN_PIXELS = 20
const GRID_SIDE_LENGTH_IN_SQUARES = 30

const ZOOM_SENSITIVITY = 1.1

@onready var grid_display: Node2D = $GridDisplay
@onready var camera_2d: Camera2D = $Camera2D

### Y axis is grid[], X axis is grid[][]
var grid : Array


func _ready() -> void:
	populate_grid()
	camera_2d.position = Vector2(
			(SQUARE_SIZE_IN_PIXELS * GRID_SIDE_LENGTH_IN_SQUARES) / 2, 
			(SQUARE_SIZE_IN_PIXELS * GRID_SIDE_LENGTH_IN_SQUARES) / 2
	)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			#somehow, dividing the relative by the zoom level makes the scroll look decent
			#relative to the zoom
			camera_2d.position = camera_2d.position - event.relative/camera_2d.zoom
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_2d.zoom *= Vector2(ZOOM_SENSITIVITY, ZOOM_SENSITIVITY)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_2d.zoom /= Vector2(ZOOM_SENSITIVITY, ZOOM_SENSITIVITY)


func populate_grid() -> void:
	for y in GRID_SIDE_LENGTH_IN_SQUARES:
		var array : Array
		for x in GRID_SIDE_LENGTH_IN_SQUARES: 
			var square = preload("res://square.tscn").instantiate()
			grid_display.add_child(square)
			square.position = Vector2(x * SQUARE_SIZE_IN_PIXELS,y * SQUARE_SIZE_IN_PIXELS)
		grid.append(array)
