extends Node2D

const SQUARE_SIZE_IN_PIXELS = 20
const GRID_SIDE_LENGTH_IN_SQUARES = 30

const ZOOM_SENSITIVITY = 1.1

@onready var grid_display: Node2D = $GridDisplay
@onready var camera_2d: Camera2D = $Camera2D
@onready var square = preload("res://square.tscn")
@onready var toggle_sim_button: Button = $GUI/Toolbar/ToggleSimButton

### Y axis is grid[], X axis is grid[][]
var grid : Array
var is_simulating : bool = false

var tick_speed :float = 1 #in seconds, roughly
var elapsed_time :float


func _ready() -> void:
	populate_grid()
	camera_2d.position = Vector2(
			(SQUARE_SIZE_IN_PIXELS * GRID_SIDE_LENGTH_IN_SQUARES) / 2, 
			(SQUARE_SIZE_IN_PIXELS * GRID_SIDE_LENGTH_IN_SQUARES) / 2
	)
	

func _process(delta: float) -> void:
	if is_simulating:
		elapsed_time += delta
		if elapsed_time >= tick_speed:
			
			#TODO Simulate here
			
			elapsed_time = 0
	

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
			var new_square = square.instantiate()
			grid_display.add_child(new_square)
			new_square.position = Vector2(x * SQUARE_SIZE_IN_PIXELS,y * SQUARE_SIZE_IN_PIXELS)
		grid.append(array)


func _on_toggle_sim_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		toggle_sim_button.text = "Stop"
		is_simulating = true
	else:
		toggle_sim_button.text = "Start"
		is_simulating = false
