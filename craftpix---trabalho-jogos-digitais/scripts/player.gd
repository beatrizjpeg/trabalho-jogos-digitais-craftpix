extends CharacterBody2D

# Janela de tempo onde o Player ainda consegue pular
@export var coyote_time_window: = 0.1
@onready var time_in_air: float = 0.0

@export var jump_buffer_window: = 0.1
@onready var jump_buffer_time: float = 0.0

# Configurações de movimento
@export var speed: float = 160.0
@export var jump_force: float = -320.0
@export var gravity: float = 900.0


# 1 = só pulo normal, 2 = pulo duplo
@export var max_jumps: int = 1
var jumps_done: int = 0

# Animações da raposa
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Sistema de vidas
var lives: int = 3
var initial_position: Vector2
var respawn_locked: bool = false

# Sinais para atualizar a interface
signal lives_changed(remaining: int)
signal game_over


func _ready() -> void:
	initial_position = global_position
	sprite.play("idle")


func _physics_process(delta: float) -> void:

	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
		time_in_air += delta
		if jumps_done == 0 and time_in_air > coyote_time_window:
			jumps_done = 1
	
	# Ao tocar no chão, recupera os pulos
	if is_on_floor():
		jumps_done = 0
		time_in_air = 0.0
		# Verifica se o buffer do pulo está ativo
		if jump_buffer_time > 0.0:
			velocity.y = jump_force
			jumps_done = 1
			jump_buffer_time = 0.0 # Zera para não repetir
	
	
	# Pulo e pulo duplo
	if Input.is_action_just_pressed("ui_accept"):
		# Pula se estiver no chão ou no Coyote Time e não tiver feito nenhum pulo
		if (is_on_floor() or time_in_air < coyote_time_window) and jumps_done == 0:
			velocity.y = jump_force
			jumps_done = 1
			jump_buffer_time = 0.0
		# Verifica se pode dar pulo duplo
		elif jumps_done < max_jumps:
			velocity.y = jump_force
			jumps_done += 1
			jump_buffer_time = 0.0
		else:
			jump_buffer_time = jump_buffer_window
	else:
		jump_buffer_time = max(jump_buffer_time - delta, 0.0)
	
	
	
	# Movimento horizontal
	var direction: float = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	
	# Virar a raposa
	if direction != 0:
		sprite.flip_h = direction < 0
	
	# Aplicar movimento e colisões
	move_and_slide()
	
	# Animações
	var next_animation: String = "idle"
	
	if not is_on_floor():
		if velocity.y < 0:
			next_animation = "jump"
		else:
			next_animation = "fall"
	elif direction != 0:
		next_animation = "run"
	
	if sprite.animation != next_animation:
		sprite.play(next_animation)


# Perder uma vida e retornar ao início
func respawn() -> void:

	if respawn_locked or lives <= 0:
		return

	respawn_locked = true
	lives -= 1

	lives_changed.emit(lives)

	if lives <= 0:
		velocity = Vector2.ZERO
		set_physics_process(false)
		sprite.play("idle")
		game_over.emit()
		return

	global_position = initial_position
	velocity = Vector2.ZERO
	sprite.play("idle")

	# Evita perder várias vidas ao mesmo tempo
	await get_tree().create_timer(0.5).timeout

	if is_inside_tree():
		respawn_locked = false


# Define um novo ponto de retorno
func set_checkpoint(new_position: Vector2) -> void:
	initial_position = new_position


# Impulso causado pela mola
func launch_up(force: float) -> void:
	velocity.y = force
