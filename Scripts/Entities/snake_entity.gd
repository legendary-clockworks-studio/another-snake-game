extends Node2D


var input_vector: Vector2
var current_dir: = Vector2.RIGHT
var next_dir: = Vector2.RIGHT
var opp_dir: = Vector2.LEFT
var next_cell: Vector2
var current_cell: Vector2
var cell_size: = Vector2(32, 32)

var can_move: = true

var tween: Tween

func _ready() -> void:
	current_cell = global_position / cell_size
	tween = create_tween().set_loops()
	tween.tween_callback(move_player).set_delay(1)
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Up") && current_dir != Vector2.DOWN:
		next_dir = Vector2.UP
	if event.is_action_pressed("Down") && current_dir != Vector2.UP:
		next_dir = Vector2.DOWN
	if event.is_action_pressed("Left") && current_dir != Vector2.RIGHT:
		next_dir = Vector2.RIGHT
	if event.is_action_pressed("Right") && current_dir != Vector2.LEFT:
		next_dir = Vector2.RIGHT


func move_player():
	current_dir = next_dir
	next_cell = current_cell + current_dir
	global_position = next_cell * cell_size
	current_cell = next_cell
