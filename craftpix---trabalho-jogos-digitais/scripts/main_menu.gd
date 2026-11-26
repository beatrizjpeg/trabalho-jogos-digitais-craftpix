extends Control

# Primeira fase que abre ao clicar em Jogar
@export_file("*.tscn") var first_level_path: String = "res://scenes/level_1.tscn"

@export var creditos_scroll_speed: float = 300.0

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
@onready var creditos_scroll: ScrollContainer = $UILayer/MenuUI/CreditosDialog/ScrollContainer

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
	
	# Devolve o foco para o menu principal ao fechar os popups
	opcoes_dialog.close_requested.connect(func():
		opcoes_dialog.hide()
		opcoes_button.grab_focus()
	)
	opcoes_dialog.canceled.connect(func(): opcoes_button.grab_focus())
	opcoes_dialog.confirmed.connect(func(): opcoes_button.grab_focus())
	
	var option_ok_btn: Button = opcoes_dialog.get_ok_button()
	
	if option_ok_btn != null:
		_aplicar_highlight_foco(option_ok_btn)

	
	if option_ok_btn != null and mute_all_check != null:
		mute_all_check.focus_neighbor_bottom = option_ok_btn.get_path()
		option_ok_btn.focus_neighbor_top = mute_all_check.get_path()

	creditos_dialog.close_requested.connect(func():
		creditos_dialog.hide()
		creditos_button.grab_focus()
	)
	creditos_dialog.canceled.connect(func(): creditos_button.grab_focus())
	creditos_dialog.confirmed.connect(func(): creditos_button.grab_focus())
	
	var creditos_ok_btn: Button = creditos_dialog.get_ok_button()
	
	if creditos_ok_btn != null:
		_aplicar_highlight_foco(creditos_ok_btn)

	# Garante que os botoes aceitem foco por teclado/controle
	for btn: Button in [jogar_button, opcoes_button, creditos_button, sair_button]:
		btn.focus_mode = Control.FOCUS_ALL

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
	
	# Define o foco inicial no primeiro botao do menu
	jogar_button.grab_focus.call_deferred()

func _process(delta: float) -> void:
	if creditos_dialog.visible and creditos_scroll != null:
		var axis: float = Input.get_axis("ui_up", "ui_down")
		if axis != 0.0:
			creditos_scroll.scroll_vertical += int(axis * creditos_scroll_speed * delta)
		
		_checar_fim_rolagem_scroll()

func _checar_fim_rolagem_scroll() -> void:
	if _creditos_focou_ok or creditos_scroll == null:
		return

	var v_bar: VScrollBar = creditos_scroll.get_v_scroll_bar()
	var max_scroll: float = maxf(0.0, v_bar.max_value - v_bar.page)
	if v_bar.max_value > v_bar.page and creditos_scroll.scroll_vertical >= int(max_scroll) - 2:
		_creditos_focou_ok = true
		var ok_btn: Button = creditos_dialog.get_ok_button()
		if ok_btn != null:
			ok_btn.grab_focus()

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
	music_slider.grab_focus.call_deferred()

var _creditos_focou_ok: bool = false

func _on_creditos_pressed() -> void:
	_creditos_focou_ok = false
	AudioManager.play_sfx("click")
	creditos_dialog.popup_centered()
	await get_tree().process_frame
	if creditos_scroll != null:
		creditos_scroll.grab_focus()


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

func _aplicar_highlight_foco(btn: Control) -> void:
	var focus_box := StyleBoxFlat.new()
	focus_box.bg_color = Color(1.0, 1.0, 1.0, 0.08)
	focus_box.border_color = Color(1.0, 1.0, 1.0, 1.0)
	focus_box.set_border_width_all(2)
	focus_box.set_content_margin_all(4)
	btn.add_theme_stylebox_override("focus", focus_box)
	btn.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 1.0))
