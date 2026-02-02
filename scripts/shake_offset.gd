extends Node3D

@export var shake_duration := 1.3
@export var shake_strength := 10
@export var return_speed := .2

var shaking := false
var shake_timer := 0.0

func _process(delta):
	if shaking:
		shake_timer -= delta

		# Violent shake (local to this node)
		rotation = Vector3(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		position = Vector3(
			randf_range(-shake_strength * 0.2, shake_strength * 0.2),
			randf_range(-shake_strength * 0.2, shake_strength * 0.2),
			randf_range(-shake_strength * 0.2, shake_strength * 0.2)
		)

		if shake_timer <= 0:
			shaking = false

	else:
		# Smoothly return to ZERO (guaranteed normal)
		position = position.lerp(Vector3.ZERO, return_speed * delta)
		rotation = rotation.lerp(Vector3.ZERO, return_speed * delta)

func start_jumpscare_shake():
	shaking = true
	shake_timer = shake_duration
