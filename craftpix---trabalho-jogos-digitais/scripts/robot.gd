extends Area2D

@export var speed := 70.0
@export var dash_speed := 120.0     # velocidade na arrancada
@export var patrol_range := 80.0
@export var pause_time := 0.8       # tempo parado nas pontas

var dir := 1
var left_limit := 0.0
var right_limit := 0.0
var paused := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	left_limit = global_position.x - patrol_range
	right_limit = global_position.x + patrol_range
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if paused:
		return

	# Acelera no meio do trecho e fica mais lento perto das pontas
	var dist_to_edge = min(global_position.x - left_limit, right_limit - global_position.x)
	var current_speed = dash_speed if dist_to_edge > patrol_range * 0.5 else speed

	global_position.x += dir * current_speed * delta

	if global_position.x >= right_limit:
		global_position.x = right_limit
		_turn(-1)
	elif global_position.x <= left_limit:
		global_position.x = left_limit
		_turn(1)

	sprite.flip_h = dir > 0

func _turn(new_dir: int) -> void:
	paused = true
	await get_tree().create_timer(pause_time).timeout
	dir = new_dir
	paused = false

func _on_body_entered(body):
	if body.has_method("respawn"):
		body.respawn()
