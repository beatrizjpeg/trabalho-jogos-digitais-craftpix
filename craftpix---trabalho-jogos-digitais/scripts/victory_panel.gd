
extends Panel

# Caminhos das cenas
@export_file("*.tscn") var menu_scene_path: String
@export_file("*.tscn") var next_level_path: String

# Referências aos botões
@onready var retry_button: Button = $RetryButton
@onready var menu_button: Button = $MenuButton
@onready var continue_button: Button = $ContinueButton


func _ready() -> void:

	process_mode = PROCESS_MODE_ALWAYS

	# Permite que a bandeira encontre o painel
	add_to_group("finish_ui")

	# Esconde a tela de vitória no início
	hide()

	# Conecta os três botões
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	continue_button.pressed.connect(_on_continue_pressed)

	# Desativa Continuar enquanto a próxima fase não existir
	continue_button.disabled = (
		next_level_path.is_empty()
		or not ResourceLoader.exists(next_level_path)
	)


# Mostrar tela de vitória
func show_victory() -> void:
	show()
	get_tree().paused = true

	if continue_button.disabled:
		retry_button.grab_focus()
	else:
		continue_button.grab_focus()


# JOGAR NOVAMENTE
func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


# MENU PRINCIPAL
func _on_menu_pressed() -> void:
	if menu_scene_path.is_empty():
		push_warning("Configure a cena do menu principal.")
		return
	get_tree().paused = false
	get_tree().change_scene_to_file(menu_scene_path)


# CONTINUAR - PRÓXIMA FASE
func _on_continue_pressed() -> void:
	if next_level_path.is_empty():
		push_warning("Configure o caminho da próxima fase.")
		return

	if not ResourceLoader.exists(next_level_path):
		push_warning("A próxima fase ainda não existe.")
		return
	
	get_tree().paused = false
	get_tree().change_scene_to_file(next_level_path)
