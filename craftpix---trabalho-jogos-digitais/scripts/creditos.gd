extends Control

@onready var voltar_button: Button = $CenterContainer/VBoxContainer/VoltarButton

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://scenes/tile_screen.tscn")

func _ready():
	voltar_button.pressed.connect(_on_voltar_pressed)
