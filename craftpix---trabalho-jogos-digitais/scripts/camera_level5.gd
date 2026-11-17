
extends Camera2D

# REFERENCIAS
@onready var player: CharacterBody2D = $"../Player"
@onready var high_zone: Area2D = $"../CameraHighZone"

# MOVIMENTO VERTICAL
@export var rise_amount: float = 120.0
@export var vertical_speed: float = 180.0

# LIMITES HORIZONTAIS
@export var use_horizontal_limits: bool = false
@export var left_edge_x: float = 0.0
@export var right_edge_x: float = 0.0

# ALTURA ORIGINAL
var normal_y: float


func _ready() -> void:
	normal_y = global_position.y

	# A camera desta fase sera a principal
	enabled = true
	make_current()

	# Desativa os limites internos da Godot.
	# Vamos controlar os horizontais pelo script.
	limit_enabled = false

	# Evita deslocamentos e atrasos indesejados
	drag_horizontal_enabled = false
	drag_vertical_enabled = false
	position_smoothing_enabled = false
	offset = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	# Garante que esta camera esteja ativa
	if not is_current():
		make_current()

	# ACOMPANHA A LUMA HORIZONTALMENTE
	var target_x: float = player.global_position.x

	# LIMITA APENAS O MOVIMENTO HORIZONTAL
	if use_horizontal_limits:
		var half_width: float = (
			get_viewport_rect().size.x / (2.0 * zoom.x)
		)

		var min_x: float = left_edge_x + half_width
		var max_x: float = right_edge_x - half_width

		if max_x >= min_x:
			target_x = clampf(target_x, min_x, max_x)

	global_position.x = target_x

	# ALTURA NORMAL DA CAMERA
	var target_y: float = normal_y

	# SOBE SOMENTE DENTRO DA CAMERAHIGHZONE
	if high_zone.overlaps_body(player):
		target_y = normal_y - rise_amount

	# SUBIDA E DESCIDA SUAVES
	global_position.y = move_toward(
		global_position.y,
		target_y,
		vertical_speed * delta
	)
