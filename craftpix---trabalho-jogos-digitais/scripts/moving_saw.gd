extends Node2D

# Distância que a serra vai percorrer
@export var travel_offset: Vector2 = Vector2(160, 0)

# Velocidade da serra
@export var move_speed: float = 60.0

# Começar no destino em vez do ponto inicial
@export var start_at_end: bool = false

# Referência à serra original
@onready var saw: Area2D = $Saw

var start_position: Vector2
var end_position: Vector2
var going_to_end: bool = true


func _ready() -> void:
	# Guarda a posição inicial
	start_position = saw.position

	# Calcula o destino
	end_position = start_position + travel_offset

	# Permite começar no outro extremo
	if start_at_end:
		saw.position = end_position
		going_to_end = false


func _physics_process(delta: float) -> void:
	var target: Vector2

	# Escolhe o destino atual
	if going_to_end:
		target = end_position
	else:
		target = start_position

	# Movimenta a serra
	saw.position = saw.position.move_toward(
		target,
		move_speed * delta
	)

	# Inverte a direção quando chega ao destino
	if saw.position.is_equal_approx(target):
		going_to_end = not going_to_end
