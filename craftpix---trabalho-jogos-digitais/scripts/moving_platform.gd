extends AnimatableBody2D

@export var travel_offset: Vector2 = Vector2(160, 0)
@export var move_speed: float = 60.0

var start_position: Vector2
var end_position: Vector2
var going_to_end: bool = true


func _ready() -> void:
	start_position = position
	end_position = start_position + travel_offset


func _physics_process(delta: float) -> void:
	var target: Vector2

	if going_to_end:
		target = end_position
	else:
		target = start_position

	position = position.move_toward(
		target,
		move_speed * delta
	)

	if position.distance_to(target) < 0.1:
		going_to_end = not going_to_end
