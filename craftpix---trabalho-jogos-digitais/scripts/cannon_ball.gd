extends Area2D

var direction := -1
var speed := 120.0
var life := 4.0

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	global_position.x += direction * speed * delta
	life -= delta
	if life <= 0.0:
		queue_free()

func _on_body_entered(body):
	if body.has_method("respawn"):
		body.respawn()
	queue_free()
