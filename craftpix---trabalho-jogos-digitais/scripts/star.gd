
extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var collected: bool = false


func _ready() -> void:
	sprite.play("spin")


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player" or collected:
		return

	collected = true

	get_tree().call_group("level_hud", "add_star")

	queue_free()
