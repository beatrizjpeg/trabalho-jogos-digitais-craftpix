
extends Area2D

# CONFIGURACOES DO INIMIGO
@export var patrol_radius: float = 55.0
@export var patrol_speed: float = 35.0
@export var start_left: bool = true

# FORCA DO PULO DEPOIS DE ACERTAR O INIMIGO
@export var bounce_force: float = -250.0

# NOS DA CENA
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stomp_area: Area2D = $StompArea

# CONTROLE DA PATRULHA
var initial_x: float
var moving_right: bool = false

# CONTROLE DA DERROTA
var defeated: bool = false


func _ready() -> void:
	initial_x = global_position.x

	moving_right = not start_left

	# Conecta as colisões automaticamente
	body_entered.connect(_on_body_entered)
	stomp_area.body_entered.connect(_on_stomp_body_entered)

	# Comeca andando
	sprite.flip_h = moving_right
	sprite.play("run")


func _physics_process(delta: float) -> void:
	if defeated:
		return

	# Define para qual lado o inimigo deve andar
	var target_x: float

	if moving_right:
		target_x = initial_x + patrol_radius
	else:
		target_x = initial_x - patrol_radius

	# Movimenta horizontalmente
	global_position.x = move_toward(
		global_position.x,
		target_x,
		patrol_speed * delta
	)

	# Inverte a direcao ao chegar no limite
	if abs(global_position.x - target_x) < 0.5:
		moving_right = not moving_right
		sprite.flip_h = moving_right


# VERIFICA SE LUMA ESTA PULANDO SOBRE O INIMIGO
func _can_stomp(hero: CharacterBody2D) -> bool:
	if hero.velocity.y <= 30.0:
		return false

	# O centro da Luma precisa estar acima do cacto
	if hero.global_position.y >= global_position.y - 8.0:
		return false

	return true


# COLISAO COM O CORPO
func _on_body_entered(body: Node2D) -> void:
	if defeated:
		return

	var hero: CharacterBody2D = body as CharacterBody2D

	if hero == null:
		return

	if not hero.has_method("respawn"):
		return

	# Pulo sobre o inimigo causa dano nele
	if _can_stomp(hero):
		_defeat(hero)
	else:
		# Contato lateral causa dano na Luma
		hero.call_deferred("respawn")


# COLISAO COM A CABECA
func _on_stomp_body_entered(body: Node2D) -> void:
	if defeated:
		return

	var hero: CharacterBody2D = body as CharacterBody2D

	if hero == null:
		return

	if not hero.has_method("respawn"):
		return

	if _can_stomp(hero):
		_defeat(hero)


# DERROTA DO INIMIGO
func _defeat(hero: CharacterBody2D) -> void:
	if defeated:
		return

	defeated = true

	# Faz a Luma quicar para cima
	hero.velocity.y = bounce_force

	# Impede novas colisoes
	set_deferred("monitoring", false)
	stomp_area.set_deferred("monitoring", false)

	# Reproduz a animacao de dano
	sprite.play("hit")

	# Aguarda a animacao terminar
	await sprite.animation_finished

	if is_inside_tree():
		queue_free()
