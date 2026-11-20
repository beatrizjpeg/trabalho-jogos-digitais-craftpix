extends Area2D

var _ja_ativou: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("Entrou na area: ", body.name)
	if _ja_ativou:
		return
	if body is CharacterBody2D:
		_ja_ativou = true
		AudioManager.play_music("boss")
