extends Node2D
class_name SnakeBody

signal set_sprite


enum Direction {NONE, UP, DOWN, LEFT, RIGHT}

@export var head: bool: 
	set(v): 
		head = v; set_sprite.emit(head)
		if head: tail = false; body = false

var body: bool:
	set(v): 
		body = v; set_sprite.emit(body)
		if body: head = false; tail = false

var tail: bool: 
	set(v): 
		tail = v; set_sprite.emit(tail)
		if tail: head = false; body = false

var exists: bool: 
	set (v): exists = v; _on_load()

var next_dir: Direction
var current_dir: Direction: set = set_movement
var last_dir: Direction

var current_pos: Vector2
var next_pos: Vector2
var last_pos: Vector2

var head_sprite: Texture2D
var body_sprite: Texture2D
var tail_sprite: Texture2D

var snake_sprite: = Sprite2D.new()




func _ready() -> void:
	set_sprite.connect(_set_sprite)


func _on_load() -> void:
	head_sprite = load("res://Sprites/Snake/snake_head.png")
	body_sprite = load("res://Sprites/Snake/snake_body.png")
	tail_sprite = load("res://Sprites/Snake/snake_tail.png")


func set_movement(new_dir: Direction) -> void:
	# update node position
	last_pos = current_pos
	current_pos = next_pos
	global_position = current_pos
	
	# update sprite rotation
	last_dir = current_dir
	current_dir = new_dir
	
	#update sprite rotation
	match current_dir:
		Direction.UP:
			snake_sprite.rotation_degrees = 0
		Direction.DOWN:
			snake_sprite.rotation_degrees = 180
		Direction.LEFT:
			snake_sprite.rotation_degrees = -90
		Direction.RIGHT:
			snake_sprite.rotation_degrees = 90




func _set_sprite(on: bool) -> void:
	if !exists: add_child(snake_sprite); exists = true
	if !on: snake_sprite.texture = null
	if head: snake_sprite.texture = head_sprite
	if body: snake_sprite.texture = body_sprite
	if tail: snake_sprite.texture = tail_sprite
