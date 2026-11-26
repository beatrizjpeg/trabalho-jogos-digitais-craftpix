extends CanvasLayer

@export_file("*.tscn") var menu_scene_path: String = "res://scenes/menus/main_menu.tscn"

@onready var resume_button: Button = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var options_button: Button = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OptionsButton
@onready var menu_button: Button = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MenuButton
@onready var retry_button: Button = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RetryButton

var options_dialog: AcceptDialog
var music_slider: HSlider
var sfx_slider: HSlider
var pause_music_check: CheckButton
var mute_all_check: CheckButton


func _ready() -> void:
	# Garante que o menu de pausa e o áudio funcionem com o jogo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	AudioManager.process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	_setup_buttons_focus()

	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	retry_button.pressed.connect(_on_retry_pressed)

	_create_options_dialog()
	
	if pause_music_check != null:
		_aplicar_highlight_foco_check_buttons(pause_music_check)
	if mute_all_check != null:
		_aplicar_highlight_foco_check_buttons(mute_all_check)

func _setup_buttons_focus() -> void:
	var buttons: Array[Button] = [resume_button, options_button, menu_button, retry_button]
	for btn in buttons:
		btn.focus_mode = Control.FOCUS_ALL


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Não abre o menu de pausa se estiver no Menu Principal
		var current_scene = get_tree().current_scene
		if current_scene != null and current_scene.scene_file_path == menu_scene_path:
			return

		if options_dialog.visible:
			options_dialog.hide()
		else:
			toggle_pause()
	
	if not visible:
		return
	
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_accept"):
		var current_focus := get_viewport().gui_get_focus_owner()
		if current_focus == null or not current_focus.is_visible_in_tree():
			if options_dialog.visible and music_slider != null:
				music_slider.grab_focus()
			else:
				resume_button.grab_focus()
			get_viewport().set_input_as_handled()
	


func toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	AudioManager.play_sfx("click")
	
	if new_pause_state:
		# Aguarda um frame para garantir que o nó esteja visível e apto a receber foco
		await get_tree().process_frame
		resume_button.grab_focus()
	else:
		release_focus()

func release_focus() -> void:
	var current_focus := get_viewport().gui_get_focus_owner()
	if current_focus != null:
		current_focus.release_focus()


func _on_resume_pressed() -> void:
	toggle_pause()


func _on_options_pressed() -> void:
	AudioManager.play_sfx("click")
	_sync_audio_controls()
	options_dialog.popup_centered()
	await get_tree().process_frame
	if music_slider != null:
		music_slider.grab_focus()

func _on_options_closed() -> void:
	if visible and not get_tree().paused == false:
		await get_tree().process_frame
		if visible:
			options_button.grab_focus()


func _on_menu_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().paused = false
	hide()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(menu_scene_path)

func _on_retry_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().paused = false
	await get_tree().create_timer(0.1).timeout
	hide()
	get_tree().reload_current_scene()


func _create_options_dialog() -> void:
	options_dialog = AcceptDialog.new()
	options_dialog.title = "Opções"
	options_dialog.min_size = Vector2i(320, 220)
	options_dialog.unresizable = true
	options_dialog.theme = load("res://dialog_theme.tres")
	options_dialog.confirmed.connect(func(): AudioManager.play_sfx("click"))
	
	add_child(options_dialog)
	

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	options_dialog.add_child(vbox)

	var music_label = Label.new()
	music_label.text = "Volume da Música"
	vbox.add_child(music_label)

	music_slider = HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.focus_mode = Control.FOCUS_ALL
	music_slider.value_changed.connect(func(v): AudioManager.set_music_volume(v))
	vbox.add_child(music_slider)

	var sfx_label = Label.new()
	sfx_label.text = "Volume dos Efeitos"
	vbox.add_child(sfx_label)

	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.focus_mode = Control.FOCUS_ALL
	sfx_slider.value_changed.connect(func(v): AudioManager.set_sfx_volume(v))
	sfx_slider.drag_ended.connect(func(changed):
		if changed:
			AudioManager.play_sfx("click")
	)
	vbox.add_child(sfx_slider)

	pause_music_check = CheckButton.new()
	pause_music_check.text = "Pausar Música"
	pause_music_check.focus_mode = Control.FOCUS_ALL
	pause_music_check.toggled.connect(func(t): AudioManager.set_music_paused(t))
	vbox.add_child(pause_music_check)

	mute_all_check = CheckButton.new()
	mute_all_check.text = "Mutar Tudo"
	mute_all_check.focus_mode = Control.FOCUS_ALL
	mute_all_check.toggled.connect(func(t): AudioManager.set_muted_all(t))
	vbox.add_child(mute_all_check)
	
	
	var option_ok_btn: Button = options_dialog.get_ok_button()
	
	if option_ok_btn != null:
		_aplicar_highlight_foco_ok_button(option_ok_btn)

	
	if option_ok_btn != null and mute_all_check != null:
		mute_all_check.focus_neighbor_bottom = option_ok_btn.get_path()
		option_ok_btn.focus_neighbor_top = mute_all_check.get_path()
	


func _sync_audio_controls() -> void:
	music_slider.set_value_no_signal(AudioManager.music_volume)
	sfx_slider.set_value_no_signal(AudioManager.sfx_volume)
	pause_music_check.set_pressed_no_signal(AudioManager.is_music_paused)
	mute_all_check.set_pressed_no_signal(AudioManager.is_muted_all)

func _aplicar_highlight_foco_ok_button(btn: Control) -> void:
	var focus_box := StyleBoxFlat.new()
	focus_box.bg_color = Color(1.0, 1.0, 1.0, 0.08)
	focus_box.border_color = Color(1.0, 1.0, 1.0, 1.0)
	focus_box.set_border_width_all(2)
	focus_box.set_content_margin_all(4)
	btn.add_theme_stylebox_override("focus", focus_box)
	btn.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 1.0))

func _aplicar_highlight_foco_check_buttons(btn: Control) -> void:
	var focus_box := StyleBoxFlat.new()
	focus_box.bg_color = Color(1.0, 1.0, 1.0, 0.09)
	focus_box.set_content_margin_all(4)
	btn.add_theme_stylebox_override("focus", focus_box)
	
