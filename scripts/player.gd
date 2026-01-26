extends CharacterBody3D

@onready var footstep_ray_cast: RayCast3D = %FootstepRayCast
@onready var footstep_player: AudioStreamPlayer3D = %FootstepPlayer

@export var pitch_min := 0.95
@export var pitch_max := 1.05

# Movement
const WALK_SPEED := 1
const SPRINT_SPEED := 2.5
const JUMP_VELOCITY := 3.0
const AIR_CONTROL := 0.3

# Stamina
const MAX_STAMINA := 3.0
const STAMINA_REGEN_IDLE := 1.5
const STAMINA_REGEN_WALK := 0.6
const STAMINA_COOLDOWN := 2.5

# Steps
const FOOTSTEP_WOOD = preload("uid://bvd1qphf1j4n6")
const FOOTSTEPS_CONCRETE = preload("uid://bqlgtpukdbndc")
const FOOTSTEPS_RUG = preload("uid://bry4o0sbgdfg5")
const FOOTSTEPS_STONE = preload("uid://bphq53h1munqe")
const FOOTSTEPS_TRASH = preload("uid://p8wplstpdre5")

const WALK_STEP_INTERVAL := 0.65
const RUN_STEP_INTERVAL := 0.3

var step_timer := 0.0
var current_surface := ""

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
	#if Input.is_action_just_pressed("jump") and is_on_floor() and stamina > 0:
		#velocity.y = JUMP_VELOCITY

	var surface := ""

	if footstep_ray_cast.is_colliding():
		var collider = footstep_ray_cast.get_collider()
		print("collider", collider)
		
		if collider:
			if collider.is_in_group("Wood"):
				surface = "Wood"
			elif collider.is_in_group("Concrete"):
				surface = "Concrete"
			elif collider.is_in_group("Rug"):
				surface = "Rug"
			elif collider.is_in_group("Stone"):
				surface = "Stone"
			elif collider.is_in_group("Trash"):
				surface = "Trash"
	
	if surface != "" and surface != current_surface:
		current_surface = surface
		step_timer = 0.0  # force immediate new step
		if footstep_player.playing:
			footstep_player.stop()
	
	if Input.is_action_just_pressed("teste"):
		%Shader.visible = !%Shader.visible

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
			emit_signal("stop_running", stamina)

	# Movement
	if direction:
		velocity.x = direction.x * player_speed * control
		velocity.z = direction.z * player_speed * control
	else:
		emit_signal("idle", stamina)
		velocity.x = move_toward(velocity.x, 0, player_speed * control)
		velocity.z = move_toward(velocity.z, 0, player_speed * control)
	
	# Footsteps logic
	var is_moving := direction != Vector3.ZERO and is_on_floor()

	if is_moving:
		step_timer -= delta
		
		var interval := RUN_STEP_INTERVAL if is_running else WALK_STEP_INTERVAL
		
		if step_timer <= 0.0:
			play_footsteps()
			step_timer = interval
	else:
		step_timer = 0.0

	move_and_slide()

func play_footsteps() -> void:
	if current_surface == "":
		return
	
	print("current_surface", current_surface)

	match current_surface:
		"Wood":
			footstep_player.stream = FOOTSTEP_WOOD
		"Concrete":
			footstep_player.stream = FOOTSTEPS_CONCRETE
		"Rug":
			footstep_player.stream = FOOTSTEPS_RUG
		"Stone":
			footstep_player.stream = FOOTSTEPS_STONE
		"Trash":
			footstep_player.stream = FOOTSTEPS_TRASH

	footstep_player.pitch_scale = randf_range(pitch_min, pitch_max)
	footstep_player.play()
