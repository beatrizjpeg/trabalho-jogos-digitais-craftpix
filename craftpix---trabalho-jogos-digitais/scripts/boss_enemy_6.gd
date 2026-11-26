
extends Area2D

@export var bandeira_final: Area2D

# CONFIGURACOES DO BOSS
@export var max_health: int = 3
@export var move_speed: float = 45.0
@export var move_range: float = 140.0
@export var attack_range: float = 75.0

# TEMPOS
@export var preparation_time: float = 0.6
@export var attack_duration: float = 0.65
@export var recovery_time: float = 1.2
@export var hurt_time: float = 0.7

# PULO NA CABECA
@export var bounce_force: float = -260.0
@export var stomp_width: float = 28.0
@export var stomp_height: float = 12.0

# VITORIA
@export var finish_level_on_defeat: bool = false

# ALINHAMENTO DO SPRITE
@export var sprite_offset_x: float = 26.0
@export var sprite_offset_y: float = -28.0
@export var tongue_offset_x: float = 48.0

# NOS
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: ProgressBar = $HealthBar

enum State {
	IDLE,
	CHASE,
	PREPARE,
	ATTACK,
	RECOVER,
	HURT,
	DEAD
}

var state: State = State.IDLE
var health: int
var initial_x: float
var player: CharacterBody2D = null
var timer: float = 0.0
var attack_hit: bool = false


func _ready() -> void:
	if bandeira_final:
		bandeira_final.visible = false
		bandeira_final.monitoring = false

	health = max_health
	initial_x = global_position.x

	health_bar.min_value = 0
	health_bar.max_value = max_health
	health_bar.value = health

	detection_area.monitoring = true

	_set_facing_right(false)
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	# Procura a Luma dentro do circulo continuamente
	_update_player_detection()

	# Permite acertar o boss mesmo durante o ataque
	if state != State.HURT:
		if _check_stomp():
			return
	
	

	match state:

		State.IDLE:
			if player != null:
				state = State.CHASE

		State.CHASE:
			_chase_player(delta)

		State.PREPARE:
			timer -= delta

			if player != null:
				_face_player()

			if timer <= 0.0:
				state = State.ATTACK
				timer = attack_duration
				attack_hit = false
				sprite.play("attack")

		State.ATTACK:
			_check_attack()

			timer -= delta

			if timer <= 0.0:
				_start_recovery()

		State.RECOVER:
			timer -= delta

			if timer <= 0.0:
				if player != null:
					state = State.CHASE
				else:
					state = State.IDLE
					# Se o player ja estiver encostando ao fim da recuperacao, aplica dano
					_check_contact_damage()

		State.HURT:
			timer -= delta

			if timer <= 0.0:
				_start_recovery()
	_check_contact_damage()


# NOVA DETECCAO CONTINUA
func _update_player_detection() -> void:
	var detected_player: CharacterBody2D = null

	for body in detection_area.get_overlapping_bodies():
		if body is CharacterBody2D:
			if body.has_method("respawn"):
				detected_player = body as CharacterBody2D
				break

	player = detected_player


# PERSEGUICAO
func _chase_player(delta: float) -> void:
	if player == null:
		state = State.IDLE
		_play_animation("idle")
		return

	_face_player()

	var distance_x: float = abs(
		player.global_position.x - global_position.x
	)

	var distance_y: float = abs(
		player.global_position.y - global_position.y
	)

	# Ataca quando esta perto da Luma
	if distance_x <= attack_range and distance_y <= 55.0:
		state = State.PREPARE
		timer = preparation_time
		_play_animation("idle")
		return

	# Calcula o destino dentro dos limites da arena
	var target_x: float = clampf(
		player.global_position.x,
		initial_x - move_range,
		initial_x + move_range
	)

	var old_x: float = global_position.x

	global_position.x = move_toward(
		global_position.x,
		target_x,
		move_speed * delta
	)

	if abs(global_position.x - old_x) > 0.05:
		_play_animation("run")
	else:
		_play_animation("idle")


# DIRECAO E ALINHAMENTO
func _face_player() -> void:
	if player == null:
		return

	var facing_right: bool = (
		player.global_position.x > global_position.x
	)

	_set_facing_right(facing_right)


func _set_facing_right(facing_right: bool) -> void:
	sprite.flip_h = facing_right

	if facing_right:
		sprite.position.x = sprite_offset_x
		attack_area.position.x = tongue_offset_x
	else:
		sprite.position.x = -sprite_offset_x
		attack_area.position.x = -tongue_offset_x

	sprite.position.y = sprite_offset_y


# DANO AO BOSS
func _check_stomp() -> bool:
	for body in get_overlapping_bodies():
		var hero: CharacterBody2D = body as CharacterBody2D

		if hero == null:
			continue

		if not hero.has_method("respawn"):
			continue

		var falling: bool = hero.velocity.y > 30.0

		var above: bool = (
			hero.global_position.y <
			global_position.y - stomp_height
		)

		var centered: bool = (
			abs(hero.global_position.x - global_position.x)
			<= stomp_width
		)

		if falling and above and centered:
			_receive_damage(hero)
			return true

	return false

func _check_contact_damage() -> bool:
	if state == State.HURT or state == State.RECOVER or state == State.DEAD:
		return false

	for body in get_overlapping_bodies():
		var hero: CharacterBody2D = body as CharacterBody2D

		if hero == null or not is_instance_valid(hero):
			continue

		if not hero.has_method("respawn"):
			continue

		# Ignora se o player estiver por cima para nao atropelar o stomp
		var above: bool = (
			hero.global_position.y <
			global_position.y - stomp_height
		)
		if above:
			continue

		hero.call_deferred("respawn")
		return true

	return false


# ATAQUE DA LINGUA
func _check_attack() -> void:
	if attack_hit:
		return

	if sprite.animation != "attack":
		return

	# A lingua atinge somente nos frames 4, 5 e 6
	if sprite.frame < 4 or sprite.frame > 6:
		return

	for body in attack_area.get_overlapping_bodies():
		var hero: CharacterBody2D = body as CharacterBody2D

		if hero == null:
			continue

		if not hero.has_method("respawn"):
			continue

		var above: bool = (
			hero.global_position.y <
			global_position.y - stomp_height
		)

		if above:
			continue

		attack_hit = true
		hero.call_deferred("respawn")
		break


func _receive_damage(hero: CharacterBody2D) -> void:
	if state == State.HURT or state == State.DEAD:
		return

	health -= 1
	health_bar.value = health

	hero.velocity.y = bounce_force

	state = State.HURT
	timer = hurt_time

	sprite.play("hit")

	if health <= 0:
		_defeat_boss(hero)


func _start_recovery() -> void:
	state = State.RECOVER
	timer = recovery_time
	_play_animation("idle")


func _play_animation(animation_name: String) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)


func _defeat_boss(hero: CharacterBody2D) -> void:
	state = State.DEAD

	set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)
	detection_area.set_deferred("monitoring", false)

	await get_tree().create_timer(0.7).timeout

	if not is_inside_tree():
		return

	sprite.hide()
	health_bar.hide()

	if finish_level_on_defeat:
		if is_instance_valid(hero):
			hero.velocity = Vector2.ZERO
			hero.set_physics_process(false)

		get_tree().call_group(
			"finish_ui",
			"show_victory"
		)
	else:
		if bandeira_final:
			bandeira_final.visible = true
			bandeira_final.set_deferred("monitoring", true)
		queue_free()
