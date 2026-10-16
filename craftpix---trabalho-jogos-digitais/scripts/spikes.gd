extends Area2D

# Se esconstar no espinho respawna
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.call_deferred("respawn")
