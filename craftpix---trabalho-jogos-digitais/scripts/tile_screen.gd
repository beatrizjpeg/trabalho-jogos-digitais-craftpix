extends Control

func _ready() -> void:
	$character_animated.play("idle")

func _on_start_button_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_options_button_pressed() -> void:
	AudioManager.play_sfx("click")

func _on_exit_button_pressed() -> void:
	AudioManager.play_sfx("click")
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
