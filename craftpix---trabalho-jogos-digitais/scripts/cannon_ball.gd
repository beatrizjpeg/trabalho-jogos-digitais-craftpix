
extends Area2D

var direction := -1
var speed := 120.0
var life := 4.0

# Distancia maxima do tiro
# 0 = usa somente o tempo de vida original
var max_distance: float = 0.0

var start_position: Vector2
var position_initialized: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:

	# Registra a posicao real de onde a bala saiu
	if not position_initialized:
		start_position = global_position
		position_initialized = true

	# Movimenta a bala
	global_position.x += direction * speed * delta

	# Verifica se atingiu o alcance configurado
	if max_distance > 0.0:
		if global_position.distance_to(start_position) >= max_distance:
			queue_free()
			return

	# Mantem o tempo de vida original da bala
	life -= delta

	if life <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.respawn()

	queue_free()
