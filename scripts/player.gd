extends CharacterBody3D

# Movement
const WALK_SPEED := 3.0
const SPRINT_SPEED := 4.5
const JUMP_VELOCITY := 3.0
const AIR_CONTROL := 0.3

# Stamina
const MAX_STAMINA := 3.0
const STAMINA_REGEN_IDLE := 1.5
const STAMINA_REGEN_WALK := 0.6
const STAMINA_COOLDOWN := 2.5

signal running(stamina: float)
signal walking(stamina: float)
signal idle(stamina: float)
signal stop_running(stamina: float)

var player_speed := WALK_SPEED
var stamina := MAX_STAMINA
var regen_timer := 0.0
var is_running := false

func _physics_process(delta: float) -> void:	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump (disabled if exhausted)
	if Input.is_action_just_pressed("jump") and is_on_floor() and stamina > 0:
		velocity.y = JUMP_VELOCITY

	# Input
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var control := 1.0 if is_on_floor() else AIR_CONTROL
	var wants_to_sprint := Input.is_action_pressed("sprint")

	# Sprint logic
	is_running = wants_to_sprint and stamina > 0 and direction != Vector3.ZERO

	if is_running:
		player_speed = SPRINT_SPEED
		stamina -= delta
		stamina = max(stamina, 0)
		regen_timer = STAMINA_COOLDOWN
		emit_signal("running", stamina)
		
	else:
		player_speed = WALK_SPEED
		
		# Cheks if player is idle or walking
		if direction != Vector3.ZERO:
			emit_signal("walking", stamina)
		else:
			emit_signal("stop_running", stamina)

		# Cooldown before regen
		if regen_timer > 0:
			regen_timer -= delta
		else:
			# Regen rate depends on movement
			var regen_rate := STAMINA_REGEN_IDLE if direction == Vector3.ZERO else STAMINA_REGEN_WALK
			stamina += regen_rate * delta
			stamina = min(stamina, MAX_STAMINA)

	# Movement
	if direction:
		velocity.x = direction.x * player_speed * control
		velocity.z = direction.z * player_speed * control
	else:
		emit_signal("idle", stamina)
		velocity.x = move_toward(velocity.x, 0, player_speed * control)
		velocity.z = move_toward(velocity.z, 0, player_speed * control)

	move_and_slide()
