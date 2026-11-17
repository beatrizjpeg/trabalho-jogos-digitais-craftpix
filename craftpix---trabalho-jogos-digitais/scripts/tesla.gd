extends Area2D

@export var off_time := 1.5
@export var on_time := 1.2
@export var start_delay := 0.0   # use valores diferentes em T1, T2 e T3

var active := false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready():
	_set_active(false)
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	while true:
		_set_active(false)
		await get_tree().create_timer(off_time).timeout
		_set_active(true)
		await get_tree().create_timer(on_time).timeout

func _set_active(value: bool):
	active = value
	shape.set_deferred("disabled", not value)
	sprite.play("on" if value else "off")

func _physics_process(_delta):
	if not active:
		return
	for body in get_overlapping_bodies():
		if body.has_method("respawn"):
			body.respawn()
