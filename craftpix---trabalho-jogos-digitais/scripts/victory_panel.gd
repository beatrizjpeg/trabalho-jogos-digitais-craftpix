
extends Panel

# CAMINHOS DAS CENAS
@export_file("*.tscn") var menu_scene_path: String = "res://scenes/main_menu.tscn"
@export_file("*.tscn") var next_level_path: String = ""

# BOTOES
@onready var retry_button: Button = $RetryButton
@onready var menu_button: Button = $MenuButton
@onready var continue_button: Button = $ContinueButton


func _ready() -> void:
	# Adiciona o painel ao grupo de vitoria
	add_to_group("finish_ui")

	# Esconde o painel no inicio da fase
	hide()

	# Conecta os botoes
	if not retry_button.pressed.is_connected(_on_retry_pressed):
		retry_button.pressed.connect(_on_retry_pressed)

	if not menu_button.pressed.is_connected(_on_menu_pressed):
		menu_button.pressed.connect(_on_menu_pressed)

	if not continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.connect(_on_continue_pressed)

	# Verifica a proxima fase
	var path: String = _get_next_level_path()

	continue_button.disabled = path.is_empty()

	print("Proxima fase configurada: ", path)


# IDENTIFICA A PROXIMA FASE
func _get_next_level_path() -> String:

	var current_scene: Node = get_tree().current_scene

	# Correcao especifica da Fase 4
	if current_scene != null:
		if current_scene.scene_file_path == "res://scenes/level_4.tscn":
			return "res://scenes/level_5.tscn"

	# Nas outras fases, usa o caminho do Inspector
	return next_level_path.strip_edges()


# MOSTRA A VITORIA
func show_victory() -> void:
	show()

	var path: String = _get_next_level_path()

	continue_button.disabled = path.is_empty()

	print("Tela de vitoria aberta.")
	print("Proxima fase: ", path)


# REINICIAR FASE
func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()


# VOLTAR AO MENU
func _on_menu_pressed() -> void:

	if ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
	else:
		push_error("Menu nao encontrado: " + menu_scene_path)


# CONTINUAR PARA A PROXIMA FASE
func _on_continue_pressed() -> void:

	print("Botao CONTINUAR pressionado!")

	var path: String = _get_next_level_path()

	if path.is_empty():
		push_error("O caminho da proxima fase esta vazio.")
		return

	if not ResourceLoader.exists(path):
		push_error("A proxima fase nao foi encontrada: " + path)
		return

	print("Carregando proxima fase: ", path)

	var result: Error = get_tree().change_scene_to_file(path)

	if result != OK:
		push_error("Erro ao trocar de fase. Codigo: " + str(result))
