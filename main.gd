extends Node2D

const SQUARE_SIZE_IN_PIXELS = 20
const GRID_SIDE_LENGTH_IN_SQUARES = 120

const ZOOM_SENSITIVITY = 1.1

#the coordinates of a given square's neighbors relative to the square itself
const RELATIVE_NEIGHBOR_COORDS :Array = [Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1),
										 Vector2(-1,0),               Vector2(1,0),
										 Vector2(-1,1), Vector2(0,1), Vector2(1,1)]

@onready var grid_display: Node2D = $GridDisplay
@onready var camera_2d: Camera2D = $Camera2D
@onready var square = preload("res://square.tscn")
@onready var toggle_sim_button: Button = $GUI/Toolbar/ToggleSimButton
@onready var speed_slider: HSlider = $GUI/Toolbar/SpeedSlider
@onready var generation_label: Label = $GUI/Toolbar/Generations

### Y axis is grid[], X axis is grid[][]
var grid : Array
var is_simulating : bool = false
var next_gen_array : Array

var tick_speed :float #in seconds, roughly
var elapsed_time :float

var gens_passed = 0 : 
	set(value):
		gens_passed = value
		generation_label.text = "Gen: " + str(value)



func _ready() -> void:
	tick_speed = speed_slider.value
	populate_grid()
	next_gen_array = create_next_gen_array() #an attempt at optimization
	camera_2d.position = Vector2(
			(SQUARE_SIZE_IN_PIXELS * GRID_SIDE_LENGTH_IN_SQUARES) / 2.0, 
			(SQUARE_SIZE_IN_PIXELS * GRID_SIDE_LENGTH_IN_SQUARES) / 2.0
	)


func _process(delta: float) -> void:
	if is_simulating:
		elapsed_time += delta
		if elapsed_time >= tick_speed:
			var next_generation :Array = next_gen_array.duplicate(true)
			
			for y in GRID_SIDE_LENGTH_IN_SQUARES:
				for x in GRID_SIDE_LENGTH_IN_SQUARES:
					var current_square = grid[y][x]
					var is_square_alive = current_square.is_alive
					var alive_neighbors = get_num_alive_neighbors(x,y)
					
					if not is_square_alive:
						if alive_neighbors == 3:
							next_generation[y][x] = true
							continue
					else:
						if alive_neighbors == 2 or alive_neighbors == 3:
							next_generation[y][x] = true
						else:
							next_generation[y][x] = false
							
			
			for y in GRID_SIDE_LENGTH_IN_SQUARES:
				for x in GRID_SIDE_LENGTH_IN_SQUARES:
					grid[y][x].is_alive = next_generation[y][x]
			
			gens_passed += 1
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
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_mouse_clicked()


func populate_grid() -> void:
	for y in GRID_SIDE_LENGTH_IN_SQUARES:
		var array : Array
		for x in GRID_SIDE_LENGTH_IN_SQUARES: 
			var new_square = square.instantiate()
			grid_display.add_child(new_square)
			new_square.position = Vector2(x * SQUARE_SIZE_IN_PIXELS,y * SQUARE_SIZE_IN_PIXELS)
			array.append(new_square)
		grid.append(array)
		

func create_next_gen_array():
	var array : Array
	for y in GRID_SIDE_LENGTH_IN_SQUARES:
		var array_row : Array
		for x in GRID_SIDE_LENGTH_IN_SQUARES: 
			array_row.append(false)
		array.append(array_row)
	
	return array


func _on_toggle_sim_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		toggle_sim_button.text = "Stop"
		is_simulating = true
	else:
		toggle_sim_button.text = "Start"
		is_simulating = false


func get_num_alive_neighbors(x, y):
	var coords = Vector2(x,y)
	var living_neighbors = 0
	
	for i in RELATIVE_NEIGHBOR_COORDS:
		var new_coords = coords + i
		if new_coords.x > (GRID_SIDE_LENGTH_IN_SQUARES - 1) or \
				new_coords.y > (GRID_SIDE_LENGTH_IN_SQUARES - 1) or \
				new_coords.x < 0 or new_coords.y < 0:
			continue
			
		if grid[new_coords.y][new_coords.x].is_alive:
			living_neighbors += 1
		
	return living_neighbors


func _on_speed_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		tick_speed = speed_slider.value


func _on_reset_pressed() -> void:
	toggle_sim_button.text = "Start"
	gens_passed = 0
	is_simulating = false
	for child in grid_display.get_children():
		child.queue_free()
	grid.clear()
	populate_grid()


func on_mouse_clicked() -> void:
	if is_simulating:
		return
	var pos = get_global_mouse_position()
	pos.x = floori(pos.x / SQUARE_SIZE_IN_PIXELS)
	pos.y = floori(pos.y / SQUARE_SIZE_IN_PIXELS)
	grid[pos.y][pos.x].toggle_state()


func _on_randomize_pressed() -> void:
	if is_simulating:
		return
	for y in GRID_SIDE_LENGTH_IN_SQUARES:
		for x in GRID_SIDE_LENGTH_IN_SQUARES:
			grid[y][x].is_alive = randi_range(0,1)
