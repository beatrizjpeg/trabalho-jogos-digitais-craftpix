extends ColorRect

@onready var victory_panel: Control = $"../VictoryPanel"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	victory_panel.visibility_changed.connect(_atualizar_visibilidade)

	_atualizar_visibilidade()


func _atualizar_visibilidade() -> void:
	visible = victory_panel.is_visible_in_tree()
