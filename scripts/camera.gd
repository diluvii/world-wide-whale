extends Camera2D

@export var target: CharacterBody2D
@export var smoothing := 8.0

func _process(delta):
	if target:
		global_position = lerp(global_position, target.global_position, smoothing * delta)
