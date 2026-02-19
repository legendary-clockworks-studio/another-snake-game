extends Node2D

signal _add_cell

var snake_cells: = [] as Array[SnakeBody]

var input_vector: Vector2
var current_dir: = Vector2.RIGHT
var next_dir: = Vector2.RIGHT
var opp_dir: = Vector2.LEFT
var next_cell: Vector2
var current_cell: Vector2
var cell_size: = Vector2(32, 32)

var add_cell: int

var can_move: = true

var tween: Tween

func _ready() -> void:
	
	current_cell = global_position / cell_size
	tween = create_tween().set_loops()
	tween.tween_callback(move_player).set_delay(1)
	initialise_snake(3)
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Up") && current_dir != Vector2.DOWN:
		next_dir = Vector2.UP
	if event.is_action_pressed("Down") && current_dir != Vector2.UP:
		next_dir = Vector2.DOWN
	if event.is_action_pressed("Left") && current_dir != Vector2.RIGHT:
		next_dir = Vector2.LEFT
	if event.is_action_pressed("Right") && current_dir != Vector2.LEFT:
		next_dir = Vector2.RIGHT
	if event.is_action_pressed("Space"):
		add_cell = 1
		_add_cell.emit(add_cell)


func initialise_snake(cells: int):
	# create the head of the snake
	var head = SnakeBody.new()
	add_child(head)
	head._on_load()
	head.head = true
	snake_cells.push_front(head)
	# create the rest of the snake body
	for cell in cells:
		var new_cell = SnakeBody.new()
		add_child(new_cell)
		new_cell._on_load()
		snake_cells.append(new_cell)
	# load snake sprites
	for i in range(1, snake_cells.size()):
		snake_cells[i].body = true
	snake_cells[-1].tail = true
	
	# set positions
	snake_cells[0].current_pos = global_position
	snake_cells[0].last_pos = global_position
	
	for i in range(1, snake_cells.size()):
		# offsets the position by the opposite direction
		snake_cells[i].position = -current_dir * i * cell_size
		# initialises the global position for movement chaining
		snake_cells[i].current_pos = snake_cells[i].global_position
		snake_cells[i].last_pos = snake_cells[i].global_position


func growth_loop(grow: int):
	var new_cell = SnakeBody.new()
	var last_cell = snake_cells.back() as SnakeBody
	add_child(new_cell)
	new_cell._on_load()
	snake_cells.push_back(new_cell)
	for i in range(1, snake_cells.size()-1):
		snake_cells[i].body = true
	snake_cells[-1].tail = true
	new_cell.current_pos = last_cell.current_pos


func move_player():
	current_dir = next_dir
	next_cell = current_cell + current_dir
	global_position = next_cell * cell_size
	current_cell = next_cell
	snake_cells[0].current_pos = global_position
	for i in range(1, snake_cells.size()):
		snake_cells[i].current_pos = snake_cells[i-1].last_pos


func _on_tree_entered() -> void:
	_add_cell.connect(growth_loop)


func _on_tree_exited() -> void:
	_add_cell.disconnect(growth_loop)
