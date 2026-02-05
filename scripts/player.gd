extends CharacterBody3D

@onready var footstep_ray_cast: RayCast3D = %FootstepRayCast
@onready var footstep_player: AudioStreamPlayer3D = %FootstepPlayer

@export var pitch_min := 0.95
@export var pitch_max := 1.05

var stairs_code_instance = preload("uid://bddm53mesxp1b").new()
@onready var camera_shake = %ShakeOffset

@onready var anim_player: AnimationPlayer = %CutsceneManager

# Movement
const WALK_SPEED := 1
const SPRINT_SPEED := 2.5
const JUMP_VELOCITY := 3.0
const AIR_CONTROL := 0.3

var last_y_position: float

# Stamina
const MAX_STAMINA := 5.0
const STAMINA_REGEN_IDLE := 1.5
const STAMINA_REGEN_WALK := 0.6
const STAMINA_COOLDOWN := 2.5

# Steps
const FOOTSTEPS_CONCRETE = preload("uid://d4efgdhjjadpg")
const FOOTSTEPS_RUG = preload("uid://kyowah0jukth")
const FOOTSTEPS_STONE = preload("uid://bsners5y5yrqn")
const FOOTSTEPS_WOOD = preload("uid://de8tc16huok00")
const FOOTSTEPS_TRASH = preload("uid://wv5bj8ylx0hr")

const WALK_STEP_INTERVAL := 0.65
const RUN_STEP_INTERVAL := 0.3

var step_timer := 0.0
var current_surface := ""

signal running(stamina: float)
signal running_on_stairs
signal walking(stamina: float)
signal idle(stamina: float)
signal stop_running(stamina: float)
signal falling_down_stairs

var player_speed := WALK_SPEED
var stamina := MAX_STAMINA
var regen_timer := 0.0
var is_running := false
var is_jumscare_played := false
var camera_default_transform: Transform3D

func _ready():
	var camera_default_transform = %MainCamera.transform
	last_y_position = global_position.y
	CutsceneManager.play_cutscene(anim_player)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if get_meta("is_player_in_cutscene"):
		set_meta("can_camera_move", false)
		set_meta("can_player_move", false)
	
	var going_down = global_position.y < last_y_position
	last_y_position = global_position.y

	var surface := ""

	if footstep_ray_cast.is_colliding():
		var collider = footstep_ray_cast.get_collider()
		#print("collider", collider)
		
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
			
			if collider.is_in_group("Stairs") and is_running and going_down:
				var stairs = collider.name

				if stairs == "FirstFloorStairs":
					var should_play_jumpscare: bool = stairs_code_instance.play_jumpscare()

					if should_play_jumpscare and !is_jumscare_played:
						is_jumscare_played = true
						emit_signal("falling_down_stairs")

						%PlayerModel.visible = false

						self.set_meta("can_player_move", false)
						self.set_meta("can_camera_move", false)

						camera_shake.start_jumpscare_shake()

						var target_pos = Vector3(-28.92732, -0.17765, -126.6113)
						var tween = create_tween()
						tween.tween_property(self, "position", target_pos, 1.3)
						tween.set_trans(Tween.TRANS_SINE)
						tween.set_ease(Tween.EASE_OUT)

						await get_tree().create_timer(1.5).timeout

						self.set_meta("can_player_move", true)
						self.set_meta("can_camera_move", true)
						%PlayerFlashlight.visible = false
						%PlayerModel.visible = true
						
						await get_tree().create_timer(5).timeout
						%PlayerFlashlight.visible = true

	
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
	
	if self.get_meta("can_player_move"):
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
	if direction and self.get_meta("can_player_move"):
		velocity.x = direction.x * player_speed * control
		velocity.z = direction.z * player_speed * control
	else:
		emit_signal("idle", stamina)
		velocity.x = move_toward(velocity.x, 0, player_speed * control)
		velocity.z = move_toward(velocity.z, 0, player_speed * control)
	
	# Footsteps logic
	var is_moving :bool = direction != Vector3.ZERO and is_on_floor() and self.get_meta("can_player_move")

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
			footstep_player.stream = FOOTSTEPS_WOOD
		"Concrete":
			footstep_player.stream = FOOTSTEPS_CONCRETE
		"Rug":
			footstep_player.stream = FOOTSTEPS_RUG
		"Stone":
			footstep_player.stream = FOOTSTEPS_STONE
			footstep_player.volume_db = 80.0
		"Trash":
			footstep_player.stream = FOOTSTEPS_TRASH

	footstep_player.pitch_scale = randf_range(pitch_min, pitch_max)
	footstep_player.play()


func move_player(target_pos: Vector3, duration: float) -> void:
	var tween = create_tween()
	
	tween.tween_property(self, "position", target_pos, duration)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)


func _on_cutscene_manager_animation_finished(anim_name: StringName) -> void:
	set_meta("can_camera_move", true)
	set_meta("can_player_move", true)
	set_meta("is_player_in_cutscene", false)
	
	move_player(Vector3(-33.534, 3.48, -131.844), 1.3)
