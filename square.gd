extends Sprite2D

const ALIVE = preload("res://alive.png")
const DEAD = preload("res://dead.png")

var is_alive : bool :
	set(value):
		is_alive = value
		if is_alive:
			texture = ALIVE
		else:
			texture = DEAD


func _ready() -> void:
	is_alive = false


func toggle_state():
	if is_alive:
		is_alive = false
	else:
		is_alive = true
