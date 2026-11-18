extends ColorRect

@onready var game_over_panel: Control = $"../GameOverPanel"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	game_over_panel.visibility_changed.connect(_update_visibility)

	_update_visibility()


func _update_visibility() -> void:
	visible = game_over_panel.is_visible_in_tree()
