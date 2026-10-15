
extends Node2D

var gems_collected = 0
var total_gems = 0

@onready var gem_counter = $HUD/GemCounter


func _ready():
	var gems = get_tree().get_nodes_in_group("gems")
	total_gems = gems.size()

	for gem in gems:
		gem.collected.connect(_on_gem_collected)

	update_counter()


func _on_gem_collected():
	gems_collected += 1
	update_counter()


func update_counter():
	gem_counter.text = "Gemas: %d/%d" % [gems_collected, total_gems]
