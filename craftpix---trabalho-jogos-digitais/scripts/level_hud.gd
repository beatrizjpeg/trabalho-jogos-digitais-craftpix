
extends CanvasLayer

# CORAÇÕES ANIMADOS
@onready var heart1: AnimatedSprite2D = $Hearts/Heart1
@onready var heart2: AnimatedSprite2D = $Hearts/Heart2
@onready var heart3: AnimatedSprite2D = $Hearts/Heart3

# GAME OVER
@onready var game_over_panel: Control = $GameOverPanel

# CONTADOR DE ESTRELAS
@onready var stars_label: Label = $StarsLabel
@onready var star_icon: AnimatedSprite2D = $StarIcon

const TOTAL_STARS: int = 6

var stars_collected: int = 0
var previous_lives: int = 3


func _ready() -> void:
	# Permite que as estrelas encontrem o HUD
	add_to_group("level_hud")

	# Configurar os corações
	var hearts: Array[AnimatedSprite2D] = [
		heart1, heart2, heart3
	]

	for heart in hearts:
		heart.animation_finished.connect(
			_on_heart_animation_finished.bind(heart)
		)
		heart.play("full")

	# Esconder Game Over no início
	game_over_panel.hide()

	# Iniciar animação da estrela do HUD
	star_icon.play("spin")

	# Encontrar o Player
	var player: Node = get_parent().get_node("Player")

	# Conectar os sinais do Player
	player.lives_changed.connect(_on_lives_changed)
	player.game_over.connect(_on_game_over)

	# Iniciar com zero estrelas
	stars_label.text = "0/6"


# SISTEMA DE VIDAS
func _on_lives_changed(remaining: int) -> void:
	var hearts: Array[AnimatedSprite2D] = [
		heart1, heart2, heart3
	]

	for i in range(hearts.size()):
		var was_full: bool = i < previous_lives
		var is_full: bool = i < remaining

		# Perder vida
		if was_full and not is_full:
			hearts[i].play("lose")

		# Recuperar vida
		elif not was_full and is_full:
			hearts[i].play("gain")

	previous_lives = remaining


# ANIMAÇÕES DOS CORAÇÕES
func _on_heart_animation_finished(heart: AnimatedSprite2D) -> void:
	if heart.animation == "lose":
		heart.play("empty")

	elif heart.animation == "gain":
		heart.play("full")


# SISTEMA DE ESTRELAS
func add_star() -> void:
	if stars_collected >= TOTAL_STARS:
		return

	stars_collected += 1

	# Atualizar somente os números
	stars_label.text = "%d/%d" % [
		stars_collected,
		TOTAL_STARS
	]


# GAME OVER
func _on_game_over() -> void:
	game_over_panel.show()


# BOTÃO TENTAR NOVAMENTE
func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
