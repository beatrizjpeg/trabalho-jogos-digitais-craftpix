
extends CharacterBody2D

# Velocidade de movimentação
const SPEED = 200.0

# Força do pulo
const JUMP_VELOCITY = -350.0

# Referência ao sprite do personagem
@onready var sprite = $AnimatedSprite2D


func _physics_process(delta):

	# Aplica gravidade quando estiver no ar
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Faz o personagem pular
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Detecta a direção do movimento
	var direction = Input.get_axis("ui_left", "ui_right")

	# Movimentação horizontal
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Inverte o sprite conforme a direção
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true

	# Controla as animações
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

	# Aplica a movimentação e colisões
	move_and_slide()
