
extends Panel

@onready var retry_button: Button = $RetryButton
@onready var menu_button: Button = $MenuButton


func _ready() -> void:
	# Conecta o botao TENTAR NOVAMENTE
	if not retry_button.pressed.is_connected(_on_retry_pressed):
		retry_button.pressed.connect(_on_retry_pressed)

	# Conecta o botao MENU PRINCIPAL
	if not menu_button.pressed.is_connected(_on_menu_pressed):
		menu_button.pressed.connect(_on_menu_pressed)


func _on_retry_pressed() -> void:
	print("Reiniciando fase...")
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	print("Voltando ao menu principal...")

	var menu_path: String = "res://scenes/main_menu.tscn"

	if ResourceLoader.exists(menu_path):
		get_tree().change_scene_to_file(menu_path)
	else:
		push_error("Menu nao encontrado: " + menu_path)
