extends Camera2D

# Referência à raposa
@onready var player: CharacterBody2D = $"../Player"


func _ready() -> void:
	make_current()


func _process(_delta: float) -> void:
	# Acompanha Luma somente na horizontal
	global_position.x = player.global_position.x

	# Não altera o eixo Y
