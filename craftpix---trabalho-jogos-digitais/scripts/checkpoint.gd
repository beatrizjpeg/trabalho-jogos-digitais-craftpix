
extends Area2D

var activated: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_point: Marker2D = $SpawnPoint


func _ready() -> void:
	sprite.play("inactive")
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animation_finished)


func _on_body_entered(body: Node2D) -> void:
	if activated:
		return

	if not body.has_method("set_checkpoint"):
		return

	activated = true

	# Salva a posicao segura para a raposa reaparecer
	body.set_checkpoint(spawn_point.global_position)

	# Mostra a bandeira sendo ativada
	sprite.play("activate")


func _on_animation_finished() -> void:
	if sprite.animation == "activate":
		sprite.play("active")
