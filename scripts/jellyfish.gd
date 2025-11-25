extends CharacterBody2D
@onready var player: CharacterBody2D = $"../../player"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 250.0
var health = 1

func take_damage(amount: int) -> void:
	health -= amount
	print("enemy damanged by ", amount, "-> health = ", health)

	if health <= 0:
		var deathloops = 5
		var i = 0
		while i < deathloops:
			animated_sprite.play("death")
			i += 1
	
		queue_free()

func _physics_process(delta: float) -> void:
	# follows player around
	var direction = player.global_position - global_position
	var distance = direction.length()
	var max_step = SPEED * delta
	var move_vector = direction.normalized() * min(distance, max_step)
	velocity = move_vector / delta
	move_and_slide()
	
	# flips to "face" player
	if global_position.x > player.global_position.x:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

	if global_position.y > player.global_position.x + 150:
		animated_sprite.flip_v = false
	else:
		animated_sprite.flip_v = true
