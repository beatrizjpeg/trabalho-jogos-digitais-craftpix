
extends HBoxContainer

# Painel e HUD
@onready var painel: Control = get_parent() as Control
@onready var hud: CanvasLayer = painel.get_parent() as CanvasLayer

# Jogador
@onready var jogador: Node = hud.get_parent().get_node_or_null("Player")

# Elementos do painel de resultados
@onready var vidas_texto: Label = $LivesBlock/LivesLabel
@onready var estrelas_texto: Label = $StarsBlock/StarsRow/StarsCount

@onready var coracoes: Array[TextureRect] = [
	$LivesBlock/HeartsRow/Heart1,
	$LivesBlock/HeartsRow/Heart2,
	$LivesBlock/HeartsRow/Heart3
]

@onready var estrela_icone: TextureRect = $StarsBlock/StarsRow/StarIcon

# Elementos originais do HUD
@onready var hud_vidas: AnimatedSprite2D = hud.get_node_or_null(
	"Hearts/Heart1"
) as AnimatedSprite2D

@onready var hud_estrela: AnimatedSprite2D = hud.get_node_or_null(
	"StarIcon"
) as AnimatedSprite2D

@onready var hud_estrelas_texto: Label = hud.get_node_or_null(
	"StarsLabel"
) as Label


func _process(_delta: float) -> void:
	# Atualiza somente enquanto a tela de vitoria estiver aberta
	if painel == null or not painel.is_visible_in_tree():
		return

	atualizar_resultados()


func atualizar_resultados() -> void:

	# VIDAS GASTAS

	var total_vidas: int = 3
	var vidas_restantes: int = total_vidas

	if jogador != null:
		var valor: Variant = jogador.get("lives")

		if valor != null:
			vidas_restantes = clampi(
				int(valor), 0, total_vidas
			)

	var vidas_gastas: int = total_vidas - vidas_restantes

	vidas_texto.text = "VIDAS GASTAS: %d/%d" % [
		vidas_gastas, total_vidas
	]


	# CORACOES

	if hud_vidas != null and hud_vidas.sprite_frames != null:
		var frames: SpriteFrames = hud_vidas.sprite_frames

		for i in range(coracoes.size()):
			var animacao: StringName = &"full"

			if i >= vidas_restantes:
				animacao = &"empty"

			if frames.has_animation(animacao):
				if frames.get_frame_count(animacao) > 0:
					coracoes[i].texture = frames.get_frame_texture(
						animacao, 0
					)


	# ESTRELAS COLETADAS

	if hud_estrelas_texto != null:
		estrelas_texto.text = hud_estrelas_texto.text
	else:
		estrelas_texto.text = "0/6"

	
	# ICONE DA ESTRELA
	
	if hud_estrela != null and hud_estrela.sprite_frames != null:
		var frames_estrela: SpriteFrames = hud_estrela.sprite_frames

		if frames_estrela.has_animation(&"spin"):
			if frames_estrela.get_frame_count(&"spin") > 0:
				estrela_icone.texture = frames_estrela.get_frame_texture(
					&"spin", 0
				)
