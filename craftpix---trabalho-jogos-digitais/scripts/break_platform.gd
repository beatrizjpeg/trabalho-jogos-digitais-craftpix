extends StaticBody2D

# Referências aos nós da plataforma
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var solid_collision: CollisionShape2D = $CollisionShape2D
@onready var detector: Area2D = $Detector
@onready var break_timer: Timer = $BreakTimer
@onready var respawn_timer: Timer = $RespawnTimer

# Controla o estado da plataforma
var player_on_platform: bool = false
var breaking: bool = false
var broken: bool = false


func _ready() -> void:
	# Começa com a plataforma inteira
	sprite.play("idle")

	# Conecta os sinais automaticamente
	detector.body_entered.connect(_on_detector_body_entered)
	detector.body_exited.connect(_on_detector_body_exited)

	break_timer.timeout.connect(_on_break_timer_timeout)
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)

	sprite.animation_finished.connect(_on_animation_finished)


# Quando a raposa pisa na plataforma
func _on_detector_body_entered(body: Node2D) -> void:
	if breaking or broken:
		return

	if body is CharacterBody2D and body.has_method("respawn"):
		player_on_platform = true
		break_timer.start()


# Quando a raposa sai da plataforma
func _on_detector_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("respawn"):
		player_on_platform = false

		if not breaking and not broken:
			break_timer.stop()


# Quando termina o tempo sobre a plataforma
func _on_break_timer_timeout() -> void:
	if not player_on_platform or breaking or broken:
		return

	breaking = true

	# Executa a animação de quebra
	sprite.play("break")


# Quando a animação de quebra termina
func _on_animation_finished() -> void:
	if sprite.animation != "break":
		return

	breaking = false
	broken = true
	player_on_platform = false

	# Esconde a plataforma
	sprite.hide()

	# Desliga a colisão e o detector
	solid_collision.set_deferred("disabled", true)
	detector.set_deferred("monitoring", false)

	# Inicia contagem para reaparecer
	respawn_timer.start()


# Quando chega a hora de reaparecer
func _on_respawn_timer_timeout() -> void:
	broken = false
	player_on_platform = false

	# Mostra a plataforma inteira
	sprite.show()
	sprite.play("idle")

	# Restaura a colisão e o detector
	solid_collision.set_deferred("disabled", false)
	detector.set_deferred("monitoring", true)
