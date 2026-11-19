extends Panel

# CAMINHOS DAS CENAS
@export_file("*.tscn") var menu_scene_path: String = "res://scenes/main_menu.tscn"
@export_file("*.tscn") var next_level_path: String = ""

# BOTOES
@onready var retry_button: Button = $RetryButton
@onready var menu_button: Button = $MenuButton

# O botao Continuar e opcional
@onready var continue_button: Button = get_node_or_null("ContinueButton") as Button


func _ready() -> void:
	add_to_group("finish_ui")

	# Esconde o painel ao iniciar
	hide()

	# Botao de reiniciar
	if not retry_button.pressed.is_connected(_on_retry_pressed):
		retry_button.pressed.connect(_on_retry_pressed)

	# Botao de voltar ao menu
	if not menu_button.pressed.is_connected(_on_menu_pressed):
		menu_button.pressed.connect(_on_menu_pressed)

	# Conecta o Continuar somente se existir
	if continue_button != null:
		if not continue_button.pressed.is_connected(_on_continue_pressed):
			continue_button.pressed.connect(_on_continue_pressed)

		var path: String = _get_next_level_path()
		continue_button.disabled = path.is_empty()


func _get_next_level_path() -> String:
	var current_scene: Node = get_tree().current_scene

	# Transicao especifica da Fase 4 para a Fase 5
	if current_scene != null:
		if current_scene.scene_file_path == "res://scenes/level_4.tscn":
			return "res://scenes/level_5.tscn"

	# Outras fases usam o caminho configurado
	return next_level_path.strip_edges()


func show_victory() -> void:
	if visible:
		return

	AudioManager.play_sfx("checkpoint")
	show()

	# Atualiza o botao Continuar se existir
	if continue_button != null:
		var path: String = _get_next_level_path()
		continue_button.disabled = path.is_empty()


func _on_retry_pressed() -> void:
	AudioManager.play_sfx("click")
	await get_tree().create_timer(0.1).timeout
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	AudioManager.play_sfx("click")
	await get_tree().create_timer(0.1).timeout

	if ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
	else:
		push_error("Menu nao encontrado: " + menu_scene_path)


func _on_continue_pressed() -> void:
	AudioManager.play_sfx("click")
	await get_tree().create_timer(0.1).timeout

	var path: String = _get_next_level_path()

	if path.is_empty():
		push_error("Nenhuma proxima fase configurada.")
		return

	if not ResourceLoader.exists(path):
		push_error("Cena nao encontrada: " + path)
		return

	var result: Error = get_tree().change_scene_to_file(path)

	if result != OK:
		push_error("Erro ao carregar a fase: " + str(result))
