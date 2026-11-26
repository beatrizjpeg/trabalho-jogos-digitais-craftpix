extends Node2D

@onready var double_jump_area: Area2D = $DoubleJumpArea
@onready var double_jump_text: Panel = $DoubleJumpText




var double_jump_active: bool = false

func _ready() -> void:
	AudioManager.play_music("level1")
	
	double_jump_text.hide()
	
	if double_jump_area != null:
		if not double_jump_area.body_entered.is_connected(_on_double_jump_area_body_entered):
			double_jump_area.body_entered.connect(_on_double_jump_area_body_entered)
		if not double_jump_area.body_exited.is_connected(_on_double_jump_area_body_exited):
			double_jump_area.body_exited.connect(_on_double_jump_area_body_exited)

	var player: Node = get_node_or_null("Player")
	if player != null:
		_set_player_max_jumps(player, 1)
	
	


func _on_double_jump_area_body_entered(body: Node2D) -> void:
	if _is_player(body):
		double_jump_active = true
		_set_player_max_jumps(body, 2)
		if double_jump_text != null:
			double_jump_text.show()
	


func _on_double_jump_area_body_exited(body: Node2D) -> void:
	if _is_player(body):
		double_jump_active = false
		_set_player_max_jumps(body, 1)
		if double_jump_text != null:
			double_jump_text.hide()
	
	


func _is_player(body: Node2D) -> bool:
	return body.name == "Player" or body.is_in_group("player")


func _set_player_max_jumps(player: Node2D, jumps: int) -> void:
	if "max_jumps" in player:
		player.max_jumps = jumps
