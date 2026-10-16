extends Area2D

# Força do impulso vertical
@export var launch_force: float = -500.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	sprite.play("idle")
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animation_finished)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("launch_up"):

		# Ativa ao tocar a mola caindo ou parado
		if body.velocity.y >= 0:
			body.launch_up(launch_force)
			sprite.play("bounce")


func _on_animation_finished() -> void:
	if sprite.animation == "bounce":
		sprite.play("idle")
