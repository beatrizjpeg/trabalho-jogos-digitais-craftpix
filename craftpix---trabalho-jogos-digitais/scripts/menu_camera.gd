
extends Camera2D

# Inicio e fim do mapa, em coordenadas do mundo
@export var map_start_x: float = 0.0
@export var map_end_x: float = 5000.0

# Velocidade do passeio automatico
@export var camera_speed: float = 60.0

var direction: float = 1.0
var min_camera_x: float
var max_camera_x: float
var fixed_y: float


func _ready() -> void:
	enabled = true
	make_current()

	position_smoothing_enabled = false

	fixed_y = global_position.y

	# Considera metade da largura da tela
	var half_width: float = (
		get_viewport_rect().size.x / (2.0 * zoom.x)
	)

	min_camera_x = map_start_x + half_width
	max_camera_x = map_end_x - half_width

	max_camera_x = maxf(max_camera_x, min_camera_x)

	global_position = Vector2(min_camera_x, fixed_y)


func _process(delta: float) -> void:
	# Percorre a fase horizontalmente
	global_position.x += direction * camera_speed * delta

	# Ao chegar no final, volta para a esquerda
	if global_position.x >= max_camera_x:
		global_position.x = max_camera_x
		direction = -1.0

	# Ao chegar no inicio, retorna para a direita
	elif global_position.x <= min_camera_x:
		global_position.x = min_camera_x
		direction = 1.0

	# Mantem sempre a mesma altura
	global_position.y = fixed_y
