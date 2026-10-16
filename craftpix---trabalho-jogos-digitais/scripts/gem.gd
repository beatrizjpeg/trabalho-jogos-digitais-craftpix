
extends Area2D

signal collected

#encontra o nó da animação
@onready var sprite = $AnimatedSprite2D


func _ready():
	# inicia a animação automaticamente quando a gema aparece no jogo.
	sprite.play("idle")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is CharacterBody2D:
		collected.emit()
		queue_free()
