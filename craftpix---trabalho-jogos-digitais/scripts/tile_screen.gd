
extends Control

func _ready() -> void:
	$character_animated.play("idle")

func _on_start_button_pressed() -> void:
	pass

func _on_options_button_pressed() -> void:
	pass

func _on_exit_button_pressed() -> void:
	get_tree().quit()
