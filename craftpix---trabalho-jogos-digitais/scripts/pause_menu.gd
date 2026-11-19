extends CanvasLayer

@export_file("*.tscn") var menu_scene_path: String = "res://scenes/main_menu.tscn"

@onready var resume_button: Button = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var options_button: Button = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OptionsButton
@onready var menu_button: Button = $ColorRect/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MenuButton

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

	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	_create_options_dialog()


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


func toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	AudioManager.play_sfx("click")


func _on_resume_pressed() -> void:
	toggle_pause()


func _on_options_pressed() -> void:
	AudioManager.play_sfx("click")
	_sync_audio_controls()
	options_dialog.popup_centered()


func _on_menu_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().paused = false
	hide()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(menu_scene_path)


func _create_options_dialog() -> void:
	options_dialog = AcceptDialog.new()
	options_dialog.title = "Opções"
	options_dialog.min_size = Vector2i(320, 220)
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
	music_slider.value_changed.connect(func(v): AudioManager.set_music_volume(v))
	vbox.add_child(music_slider)

	var sfx_label = Label.new()
	sfx_label.text = "Volume dos Efeitos"
	vbox.add_child(sfx_label)

	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value_changed.connect(func(v): AudioManager.set_sfx_volume(v))
	sfx_slider.drag_ended.connect(func(changed):
		if changed:
			AudioManager.play_sfx("click")
	)
	vbox.add_child(sfx_slider)

	pause_music_check = CheckButton.new()
	pause_music_check.text = "Pausar Música"
	pause_music_check.toggled.connect(func(t): AudioManager.set_music_paused(t))
	vbox.add_child(pause_music_check)

	mute_all_check = CheckButton.new()
	mute_all_check.text = "Mutar Tudo"
	mute_all_check.toggled.connect(func(t): AudioManager.set_muted_all(t))
	vbox.add_child(mute_all_check)


func _sync_audio_controls() -> void:
	music_slider.set_value_no_signal(AudioManager.music_volume)
	sfx_slider.set_value_no_signal(AudioManager.sfx_volume)
	pause_music_check.set_pressed_no_signal(AudioManager.is_music_paused)
	mute_all_check.set_pressed_no_signal(AudioManager.is_muted_all)
