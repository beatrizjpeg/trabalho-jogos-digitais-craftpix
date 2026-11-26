extends Panel

@onready var retry_button: Button = $RetryButton
@onready var menu_button: Button = $MenuButton


func _ready() -> void:
	
	_setup_buttons_focus()
	
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)
	
	# Conecta o botao TENTAR NOVAMENTE
	if not retry_button.pressed.is_connected(_on_retry_pressed):
		retry_button.pressed.connect(_on_retry_pressed)

	# Conecta o botao MENU PRINCIPAL
	if not menu_button.pressed.is_connected(_on_menu_pressed):
		menu_button.pressed.connect(_on_menu_pressed)
	
	

func _setup_buttons_focus() -> void:
	var buttons: Array[Button] = [retry_button, menu_button]
	for btn in buttons:
		btn.focus_mode = Control.FOCUS_ALL

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		retry_button.grab_focus.call_deferred()


func _on_retry_pressed() -> void:
	print("Reiniciando fase...")
	AudioManager.play_sfx("click")
	await get_tree().create_timer(0.1).timeout
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	print("Voltando ao menu principal...")

	var menu_path: String = "res://scenes/menus/main_menu.tscn"
	AudioManager.play_sfx("click")
	await get_tree().create_timer(0.1).timeout
	if ResourceLoader.exists(menu_path):
		get_tree().change_scene_to_file(menu_path)
	else:
		push_error("Menu nao encontrado: " + menu_path)
