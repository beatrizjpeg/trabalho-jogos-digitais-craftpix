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

# Controles de Audio nas Opcoes
@onready var music_slider: HSlider = $UILayer/MenuUI/OpcoesDialog/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $UILayer/MenuUI/OpcoesDialog/VBoxContainer/SfxSlider
@onready var pause_music_check: CheckButton = $UILayer/MenuUI/OpcoesDialog/VBoxContainer/PauseMusicCheck
@onready var mute_all_check: CheckButton = $UILayer/MenuUI/OpcoesDialog/VBoxContainer/MuteAllCheck


func _ready() -> void:
	AudioManager.play_music("menu")
	creditos_dialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	opcoes_dialog.confirmed.connect(func(): AudioManager.play_sfx("click"))
	creditos_dialog.confirmed.connect(func(): AudioManager.play_sfx("click"))
	# Impede comandos de interface no SubViewport
	preview_viewport.gui_disable_input = true

	# Esconde o HUD da Fase 5
	var hud: Node = background_level.get_node_or_null("CanvasLayer")
	if hud != null and hud is CanvasItem:
		hud.hide()

	# Esconde e desativa a Luma no menu
	var player: Node = background_level.get_node_or_null("Player")
	if player != null:
		if player is CanvasItem:
			player.hide()
		player.process_mode = Node.PROCESS_MODE_DISABLED
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

	# Conecta os botoes do menu
	jogar_button.pressed.connect(_on_jogar_pressed)
	opcoes_button.pressed.connect(_on_opcoes_pressed)
	creditos_button.pressed.connect(_on_creditos_pressed)
	sair_button.pressed.connect(_on_sair_pressed)

	# Sincroniza e conecta os controles de audio
	music_slider.value = AudioManager.music_volume
	sfx_slider.value = AudioManager.sfx_volume
	pause_music_check.button_pressed = AudioManager.is_music_paused
	mute_all_check.button_pressed = AudioManager.is_muted_all

	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_slider.drag_ended.connect(_on_sfx_drag_ended)
	pause_music_check.toggled.connect(_on_pause_music_toggled)
	mute_all_check.toggled.connect(_on_mute_all_toggled)


func _on_jogar_pressed() -> void:
	AudioManager.play_sfx("click")
	await get_tree().create_timer(0.1).timeout

	if ResourceLoader.exists(first_level_path):
		get_tree().change_scene_to_file(first_level_path)
	else:
		push_error("Cena nao encontrada: " + first_level_path)


func _on_opcoes_pressed() -> void:
	AudioManager.play_sfx("click")
	opcoes_dialog.popup_centered()


func _on_creditos_pressed() -> void:
	AudioManager.play_sfx("click")
	creditos_dialog.popup_centered()


func _on_sair_pressed() -> void:
	AudioManager.play_sfx("click")
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()


func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value)


func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)


func _on_sfx_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioManager.play_sfx("click")


func _on_pause_music_toggled(toggled_on: bool) -> void:
	AudioManager.set_music_paused(toggled_on)


func _on_mute_all_toggled(toggled_on: bool) -> void:
	AudioManager.set_muted_all(toggled_on)
