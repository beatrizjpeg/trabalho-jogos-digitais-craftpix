extends Area2D

var collected: bool = false


func _on_body_entered(body: Node2D) -> void:

	# Verifica se quem encostou foi a raposa
	if body.name != "Player" or collected:
		return

	# Impede que a mesma estrela seja coletada duas vezes
	collected = true

	# Avisa o HUD que uma estrela foi coletada
	get_tree().call_group("level_hud", "add_star")

	# Remove a estrela do cenário
	queue_free()
