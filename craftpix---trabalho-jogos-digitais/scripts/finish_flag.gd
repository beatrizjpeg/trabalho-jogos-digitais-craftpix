extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Impede que a fase seja concluída duas vezes
var completed: bool = false


func _ready() -> void:
	# Começa com a bandeira escondida
	sprite.play("inactive")

	# Detecta quando Luma chega
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:

	# Verifica se é a raposa e se a fase já terminou
	if completed:
		return

	if not body is CharacterBody2D:
		return

	if not body.has_method("respawn"):
		return

	# Marca a fase como concluída
	completed = true
	set_deferred("monitoring", false)

	# Para a movimentação da raposa
	var player: CharacterBody2D = body as CharacterBody2D
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)

	# Anima a bandeira aparecendo
	sprite.play("activate")

	# Espera a animação terminar
	await sprite.animation_finished

	if not is_inside_tree():
		return

	# Mantém a bandeira balançando
	sprite.play("active")

	# Mostra a tela de vitória
	get_tree().call_group("finish_ui", "show_victory")
