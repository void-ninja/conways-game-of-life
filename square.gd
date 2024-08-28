extends Polygon2D

enum States {DEAD,ALIVE}

@onready var line_2d: Line2D = $Line2D
@onready var area_2d: Area2D = $Area2D

var current_state

func _ready() -> void:
	set_current_state(States.DEAD)
	

func set_current_state(state:States):
	current_state = state
	if state == States.DEAD:
		change_color('white')
	elif state == States.ALIVE:
		change_color('black')


func change_color(c):
	if c == 'white':
		color = Color(1,1,1)
		line_2d.default_color = Color(0,0,0)
	elif c == 'black':
		color = Color(0,0,0)
		line_2d.default_color = Color(1,1,1)
	else:
		push_error('can\'t change_color to something other than white or black')
		
	return


func toggle_state():
	if current_state == States.DEAD:
		set_current_state(States.ALIVE)
	elif current_state == States.ALIVE:
		set_current_state(States.DEAD)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_state()
