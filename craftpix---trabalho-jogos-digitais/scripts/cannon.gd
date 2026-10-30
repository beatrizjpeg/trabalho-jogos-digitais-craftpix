extends Area2D

@export var ball_scene: PackedScene
@export var shoot_interval := 2.0
@export var ball_speed := 120.0
@export var shoot_left := true
@export var start_delay := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle

func _ready():
	# o sprite do kit olha para a esquerda
	sprite.flip_h = not shoot_left
	muzzle.position.x = -abs(muzzle.position.x) if shoot_left else abs(muzzle.position.x)
	body_entered.connect(_on_body_entered)
	sprite.play("idle")
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	while true:
		await get_tree().create_timer(shoot_interval).timeout
		_shoot()

func _shoot():
	if ball_scene == null:
		return
	sprite.play("attack")
	var ball = ball_scene.instantiate()
	ball.global_position = muzzle.global_position
	ball.direction = -1 if shoot_left else 1
	ball.speed = ball_speed
	get_parent().add_child(ball)
	await get_tree().create_timer(0.5).timeout
	sprite.play("idle")

func _on_body_entered(body):
	if body.has_method("respawn"):
		body.respawn()
