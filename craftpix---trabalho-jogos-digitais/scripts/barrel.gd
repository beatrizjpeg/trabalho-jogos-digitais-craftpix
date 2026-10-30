extends Area2D

@export var walk_speed := 30.0
@export var charge_speed := 110.0
@export var patrol_range := 48.0
@export var stun_time := 1.2

var dir := 1
var left_limit := 0.0
var right_limit := 0.0
var state := "walk"   # walk, charge, stun
var target: Node2D = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect: Area2D = $DetectArea

func _ready():
	left_limit = global_position.x - patrol_range
	right_limit = global_position.x + patrol_range
	body_entered.connect(_on_body_entered)
	detect.body_entered.connect(_on_detect_entered)
	detect.body_exited.connect(_on_detect_exited)
	sprite.play("walk")

func _physics_process(delta):
	match state:
		"walk":
			_move(walk_speed, delta)
			if target:
				var side = sign(target.global_position.x - global_position.x)
				if side != 0:
					dir = int(side)
					state = "charge"
					sprite.play("charge")
		"charge":
			_move(charge_speed, delta)
	sprite.flip_h = dir > 0

func _move(speed: float, delta: float):
	global_position.x += dir * speed * delta
	if global_position.x >= right_limit:
		global_position.x = right_limit
		_hit_limit(-1)
	elif global_position.x <= left_limit:
		global_position.x = left_limit
		_hit_limit(1)

func _hit_limit(new_dir: int):
	if state == "charge":
		_stun(new_dir)
	else:
		dir = new_dir

func _stun(new_dir: int):
	state = "stun"
	sprite.play("stun")
	await get_tree().create_timer(stun_time).timeout
	dir = new_dir
	state = "walk"
	sprite.play("walk")

func _on_detect_entered(body):
	if body.has_method("respawn"):
		target = body

func _on_detect_exited(body):
	if body == target:
		target = null

func _on_body_entered(body):
	if body.has_method("respawn"):
		body.respawn()
