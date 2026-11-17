
extends Area2D

@export var ball_scene: PackedScene
@export var shoot_interval := 2.0
@export var ball_speed := 120.0
@export var shoot_left := true
@export var start_delay := 0.0

# Alcance configuravel de cada canhao
@export var bullet_range: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle


func _ready() -> void:
	# O sprite original olha para a esquerda
	sprite.flip_h = not shoot_left

	muzzle.position.x = -abs(muzzle.position.x) if shoot_left else abs(muzzle.position.x)

	body_entered.connect(_on_body_entered)
	sprite.play("idle")

	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout

	while is_inside_tree():
		await get_tree().create_timer(shoot_interval).timeout

		if not is_inside_tree():
			return

		_shoot()


func _shoot() -> void:
	if ball_scene == null:
		return

	sprite.play("attack")

	var ball = ball_scene.instantiate()

	ball.direction = -1 if shoot_left else 1
	ball.speed = ball_speed

	# Envia o alcance escolhido no Inspector
	ball.max_distance = bullet_range

	# Adiciona a bala e posiciona na saida do canhao
	get_parent().add_child(ball)
	ball.global_position = muzzle.global_position

	await get_tree().create_timer(0.5).timeout

	if is_inside_tree():
		sprite.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.call_deferred("respawn")
