extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $"../Marker2D"
@onready var transition_screen: CanvasLayer = $"../../transition-screen"
@onready var camera_2d: Camera2D = $'../Camera2D'
@onready var hitbox: Area2D = $hitbox

const SPEED = 1200.0
const JUMP_VELOCITY = -1200.0
const FALL_LIMIT = 4500.0

func onready() -> void:
	animated_sprite_2d.flip_h = true

func check_dash_hit() -> void:
	for area in hitbox.get_overlapping_areas():
		print(area)
		if area.is_in_group("enemy_hurtbox"):
			var enemy = area.get_parent()

			# must be above enemy
			if global_position.y < enemy.global_position.y:
				if enemy.has_method("take_damage"):
					enemy.take_damage(1)

func check_fall() -> void:
	if global_position.y >= FALL_LIMIT:
		# print("oh no death by falling!")
		camera_2d.enabled = false
		await play_respawn_transition()

func play_respawn_transition() -> void:
	transition_screen.visible = true
	var fade_rect = transition_screen.get_node("ColorRect")
	fade_rect.color = Color(0,0,0,0)
	fade_rect.z_index = 100
	transition_screen.layer = 1

	# fade in
	var tween_in = get_tree().create_tween()
	tween_in.tween_property(fade_rect, "color", Color(0,0,0,1), 0.5)
	await tween_in.finished

	# teleport player
	camera_2d.enabled = true
	global_position = marker_2d.global_position
	
	# fade out
	var tween_out = get_tree().create_tween()
	tween_out.tween_property(fade_rect, "color", Color(0,0,0,0), 0.5)
	await tween_out.finished

	# hide
	transition_screen.visible = false
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("dash"):
		velocity.y = SPEED * 2
		check_dash_hit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# animation for left/right
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true
		
	# die & respawn if falling too far
	check_fall()
