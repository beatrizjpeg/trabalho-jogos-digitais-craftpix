extends Area2D

# Configuracoes da patrulha
@export var patrol_distance: float = 120.0
@export var patrol_speed: float = 45.0

# Configuracoes do ataque
@export var attack_distance: float = 110.0
@export var attack_speed: float = 160.0
@export var return_speed: float = 80.0

# Tempos de espera
@export var warning_time: float = 0.5
@export var cooldown_time: float = 2.0

# Nos da cena
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

# Estados do inimigo
enum State {
	PATROL,
	PREPARE,
	ATTACK,
	RETURN,
	COOLDOWN
}

var state: State = State.PATROL

# Posicoes da patrulha
var patrol_start: Vector2
var patrol_end: Vector2
var going_to_end: bool = true

# Posicoes do ataque
var attack_start: Vector2
var attack_end: Vector2

# Jogador detectado
var player: Node2D

# Contador de espera
var wait_time: float = 0.0


func _ready() -> void:
	# Define os limites da patrulha
	patrol_start = global_position
	patrol_end = patrol_start + Vector2(patrol_distance, 0)

	# Conecta os sinais automaticamente
	body_entered.connect(_on_body_entered)
	detection_area.body_entered.connect(_on_detection_body_entered)

	# Inicia voando
	sprite.play("fly")


func _physics_process(delta: float) -> void:

	match state:

		State.PATROL:
			move_patrol(delta)

		State.PREPARE:
			wait_time -= delta

			if wait_time <= 0.0:
				start_attack()

		State.ATTACK:
			global_position = global_position.move_toward(
				attack_end,
				attack_speed * delta
			)

			if global_position.distance_to(attack_end) < 0.5:
				state = State.RETURN
				sprite.play("fly")

		State.RETURN:
			global_position = global_position.move_toward(
				attack_start,
				return_speed * delta
			)

			if global_position.distance_to(attack_start) < 0.5:
				state = State.COOLDOWN
				wait_time = cooldown_time
				sprite.play("idle")

		State.COOLDOWN:
			wait_time -= delta

			if wait_time <= 0.0:
				state = State.PATROL
				sprite.play("fly")

				# Detecta novamente se a Luma ainda estiver perto
				for body in detection_area.get_overlapping_bodies():
					if body.has_method("respawn"):
						prepare_attack(body)
						break


func move_patrol(delta: float) -> void:
	var target: Vector2

	if going_to_end:
		target = patrol_end
	else:
		target = patrol_start

	global_position = global_position.move_toward(
		target,
		patrol_speed * delta
	)

	if global_position.distance_to(target) < 0.5:
		going_to_end = not going_to_end


func prepare_attack(body: Node2D) -> void:
	player = body
	state = State.PREPARE
	wait_time = warning_time

	# Para antes de atacar
	sprite.play("idle")


func start_attack() -> void:

	# Cancela o ataque se o jogador saiu da area
	if not is_instance_valid(player):
		state = State.PATROL
		sprite.play("fly")
		return

	if not detection_area.overlaps_body(player):
		state = State.PATROL
		sprite.play("fly")
		return

	# Guarda a posicao onde o ataque comeca
	attack_start = global_position

	# Calcula a direcao da Luma
	var direction: Vector2 = (
		player.global_position - global_position
	).normalized()

	if direction == Vector2.ZERO:
		direction = Vector2.DOWN

	# Define ate onde o inimigo avanca
	attack_end = attack_start + direction * attack_distance

	state = State.ATTACK
	sprite.play("attack")


func _on_detection_body_entered(body: Node2D) -> void:

	# Detecta somente o personagem
	if not body.has_method("respawn"):
		return

	if state == State.PATROL:
		prepare_attack(body)


func _on_body_entered(body: Node2D) -> void:

	# Causa dano ao encostar na Luma
	if body.has_method("respawn"):
		body.call_deferred("respawn")
