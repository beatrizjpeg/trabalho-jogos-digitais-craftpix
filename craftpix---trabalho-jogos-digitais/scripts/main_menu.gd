
extends Control

# Primeira fase que abre ao clicar em Jogar
@export_file("*.tscn") var first_level_path: String = "res://scenes/level_1.tscn"

# Cenario de fundo do menu
@onready var preview_viewport: SubViewport = $BackgroundViewport/SubViewport
@onready var background_level: Node2D = $BackgroundViewport/SubViewport/Level05
@onready var menu_camera: Camera2D = $BackgroundViewport/SubViewport/MenuCamera

# Botoes do menu
@onready var jogar_button: Button = $UILayer/MenuUI/CenterContainer/MenuColumn/JogarButton
@onready var opcoes_button: Button = $UILayer/MenuUI/CenterContainer/MenuColumn/OpcoesButton
@onready var creditos_button: Button = $UILayer/MenuUI/CenterContainer/MenuColumn/CreditosButton
@onready var sair_button: Button = $UILayer/MenuUI/CenterContainer/MenuColumn/SairButton

# Janelas
@onready var opcoes_dialog: AcceptDialog = $UILayer/MenuUI/OpcoesDialog
@onready var creditos_dialog: AcceptDialog = $UILayer/MenuUI/CreditosDialog


func _ready() -> void:

	# Impede comandos de interface no SubViewport
	preview_viewport.gui_disable_input = true

	# Esconde o HUD da Fase 5
	var hud: Node = background_level.get_node_or_null("CanvasLayer")

	if hud != null:
		if hud is CanvasItem:
			hud.hide()

	# Esconde e desativa a Luma no menu
	var player: Node = background_level.get_node_or_null("Player")

	if player != null:

		if player is CanvasItem:
			player.hide()

		# Impede que a personagem se movimente
		player.process_mode = Node.PROCESS_MODE_DISABLED

		# Desativa as colisoes da personagem
		if player is CollisionObject2D:
			player.set_deferred("collision_layer", 0)
			player.set_deferred("collision_mask", 0)

	# Desativa a camera original da Fase 5
	var level_camera: Camera2D = background_level.get_node_or_null("Camera2D") as Camera2D

	if level_camera != null:
		level_camera.set_process(false)
		level_camera.set_physics_process(false)
		level_camera.enabled = false

	# Ativa a camera exclusiva do menu
	menu_camera.enabled = true
	menu_camera.make_current()

	# Conecta os botoes
	jogar_button.pressed.connect(_on_jogar_pressed)
	opcoes_button.pressed.connect(_on_opcoes_pressed)
	creditos_button.pressed.connect(_on_creditos_pressed)
	sair_button.pressed.connect(_on_sair_pressed)


func _on_jogar_pressed() -> void:

	if ResourceLoader.exists(first_level_path):
		get_tree().change_scene_to_file(first_level_path)
	else:
		push_error("Cena nao encontrada: " + first_level_path)


func _on_opcoes_pressed() -> void:
	opcoes_dialog.popup_centered()


func _on_creditos_pressed() -> void:
	creditos_dialog.popup_centered()


func _on_sair_pressed() -> void:
	get_tree().quit()
