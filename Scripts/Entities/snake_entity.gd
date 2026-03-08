extends Node2D

signal change_snake_size
signal change_move_mode
signal change_dir

#enums
enum Direction {UP, DOWN, LEFT, RIGHT}
enum MovementMode {AUTO, MANUAL, INVERTED} # move to global script

# export variables
@export var direction: Direction

@export var movement_mode: MovementMode:
	set (e): movement_mode = e; change_move_mode.emit()

# snake variables
var new_cell: SnakeBody
var last_cell: SnakeBody
var head: SnakeBody
var snake: SnakeBody
var removed_cells: Array

var snake_cells: = [] as Array[SnakeBody]

var input_vector: Vector2
var current_dir: = Vector2.RIGHT
var next_dir: = Vector2.RIGHT
var opp_dir: = Vector2.LEFT
var next_cell: Vector2
var current_cell: Vector2
var cell_size: = Vector2(32, 32)

var grow: int
var shrink: int

var can_move: = true

var tween: Tween

func _ready() -> void:
	current_cell = global_position / cell_size
	tween = create_tween().set_loops()
	tween.tween_callback(move_player).set_delay(1)
	initialise_snake(3, direction)


func _input(event: InputEvent) -> void:
	# movement inputs
	if event.is_action_pressed("Up") && head.current_dir != head.Direction.DOWN:
		snake.next_dir = snake.Direction.UP
	if event.is_action_pressed("Down") && head.current_dir != head.Direction.UP:
		snake.next_dir = snake.Direction.DOWN
	if event.is_action_pressed("Left") && head.current_dir != head.Direction.RIGHT:
		snake.next_dir = snake.Direction.LEFT
	if event.is_action_pressed("Right") && head.current_dir != head.Direction.LEFT:
		snake.next_dir = snake.Direction.RIGHT
	# booster/powerup inputs
	
	# testing inputs
	if event.is_action_pressed("Space"):
		grow = 1
		change_snake_size.emit(grow, shrink)
	if event.is_action_pressed("Dash"):
		shrink = 1
		change_snake_size.emit(grow, shrink)


func initialise_snake(cells: int, dir: Direction):
	# create the head of the snake
	snake = SnakeBody.new()
	head = SnakeBody.new()
	add_child(head)
	head._on_load()
	head.head = true
	snake_cells.push_front(head)
	# create the rest of the snake body
	for cell in cells:
		new_cell = SnakeBody.new()
		add_child(new_cell)
		new_cell._on_load()
		snake_cells.append(new_cell)
	# load snake sprites
	for i in range(1, snake_cells.size()):
		snake_cells[i].body = true
	snake_cells[-1].tail = true
	
	# set initial direction
	match dir:
		Direction.UP:
			snake.next_dir = snake.Direction.UP
			snake.current_dir = snake.Direction.UP
			current_dir = Vector2.UP
		Direction.DOWN:
			snake.next_dir = snake.Direction.DOWN
			snake.current_dir = snake.Direction.DOWN
			current_dir = Vector2.DOWN
		Direction.LEFT:
			snake.next_dir = snake.Direction.LEFT
			snake.current_dir = snake.Direction.LEFT
			current_dir = Vector2.LEFT
		Direction.RIGHT:
			snake.next_dir = snake.Direction.RIGHT
			snake.current_dir = snake.Direction.RIGHT
			current_dir = Vector2.RIGHT
	
	# set positions and rotation
	snake_cells[0].current_pos = global_position
	snake_cells[0].next_pos = global_position
	snake_cells[0].last_pos = global_position
	snake_cells[0].current_dir = snake.current_dir
	for i in range(1, snake_cells.size()):
		# set sprite roation
		snake_cells[i].current_dir = snake.current_dir
		# offsets the position by the opposite direction
		snake_cells[i].position = -current_dir * i * cell_size
		# initialises the global position for movement chaining
		snake_cells[i].current_pos = snake_cells[i].global_position
		snake_cells[i].last_pos = snake_cells[i].global_position



func growth_loop(_grow: int, _shrink: int):
	var child_cells: Array = get_children()
	for i in _grow:
		if removed_cells.size() >= 1: # check if nodes already exists
			add_child(removed_cells[-1])
			snake_cells.append(removed_cells.pop_at(-1)) # transfer node from rem
		else: # create new nodes and add them as children
			new_cell = SnakeBody.new()
			last_cell = snake_cells.back() as SnakeBody
			add_child(new_cell)
			new_cell._on_load()
			snake_cells.push_back(new_cell)
	
	# initialise sprite for cells
	for cells in range(1, snake_cells.size()-1):
		snake_cells[cells].body = true
	snake_cells[-1].tail = true
	new_cell.current_pos = last_cell.current_pos
	new_cell.next_pos = last_cell.current_pos
	new_cell.last_pos = last_cell.current_pos
	new_cell.current_dir = last_cell.current_dir

		
	# loop through the array to remove the child nodes
	for i in _shrink:
		removed_cells.append(child_cells[-1]) # get the child nodes to be removed
		snake_cells.remove_at(-1)
		remove_child(removed_cells[-1])
	snake_cells[-1].tail = true
	grow = 0
	shrink = 0


func move_player():
	# convert direction to vector movement
	match snake.next_dir:
		snake.Direction.UP:
			next_cell = current_cell + Vector2.UP
		snake.Direction.DOWN:
			next_cell = current_cell + Vector2.DOWN
		snake.Direction.LEFT:
			next_cell = current_cell + Vector2.LEFT
		snake.Direction.RIGHT:
			next_cell = current_cell + Vector2.RIGHT
	# transfer movement vector to global position
	snake.current_dir = snake.next_dir
	global_position = next_cell * cell_size
	current_cell = next_cell
	snake_cells[0].next_pos = global_position
	snake_cells[0].current_dir = snake.current_dir
	for i in range(1, snake_cells.size()-1):
		snake_cells[i].next_pos = snake_cells[i-1].last_pos
		snake_cells[i].current_dir = snake_cells[i-1].last_dir
	snake_cells[-1].next_pos = snake_cells[-2].last_pos
	snake_cells[-1].current_dir = snake_cells[-2].current_dir



func _on_tree_entered() -> void:
	change_snake_size.connect(growth_loop)


func _on_tree_exited() -> void:
	change_snake_size.disconnect(growth_loop)
