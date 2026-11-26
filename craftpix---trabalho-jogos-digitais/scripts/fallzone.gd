extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.call_deferred("respawn")


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.call_deferred("respawn")
