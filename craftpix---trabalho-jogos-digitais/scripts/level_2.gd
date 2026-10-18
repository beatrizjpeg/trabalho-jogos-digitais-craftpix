extends Node2D

@export var limit_right := 2304
@export var limit_bottom := 720

func _ready():
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam.limit_right = limit_right
		cam.limit_bottom = limit_bottom

# Fase 2 introduz o pulo duplo
	var player = get_node_or_null("Player")
	if player:
		player.max_jumps = 2
