extends Node3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var cam_shake_node: Node3D = $CameraPivot/ShakeOffset
@onready var player: CharacterBody3D = $".."

# CAMERA SHAKE SETTINGS
var shake_strength := 0.0
var shake_decay := 5.0
var shake_speed := 8.0

var noise := FastNoiseLite.new()
var noise_time := 0.0

# MOUSE LOOK
var sens := 0.002
var max_pitch := deg_to_rad(65)
var pitch := 0.0

# HAND / BONE
const RIGHT_HAND_BONE := "DEF-hand.R"
var skeleton: Skeleton3D
var bone_index: int = -1


func _ready() -> void:
	# ---- Noise setup ----
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 1.5

	# ---- Mouse ----
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# ---- Skeleton ----
	skeleton = $"../PlayerModel/root_character_deform/Skeleton3D"
	bone_index = skeleton.find_bone(RIGHT_HAND_BONE)

	if bone_index == -1:
		push_error("Bone not found: " + RIGHT_HAND_BONE)


# MOUSE LOOK INPUT
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var can_camera_move: bool = player.get_meta("can_camera_move")
		
		if can_camera_move:
			# Yaw = player body
			get_parent().rotate_y(-event.relative.x * sens)

			# Pitch = camera pivot
			pitch -= event.relative.y * sens
			pitch = clamp(pitch, -max_pitch, max_pitch)
			camera_pivot.rotation.x = pitch


# SHAKE CONTROL
func add_camera_shake(amount: float) -> void:
	shake_strength = clamp(shake_strength + amount, 0.0, 1.0)


func apply_camera_shake(delta: float) -> void:
	noise_time += delta * shake_speed

	var target_rot := Vector3.ZERO
	var target_pos := Vector3.ZERO

	if shake_strength > 0.001:
		target_rot.x = noise.get_noise_2d(noise_time, 0.0) * shake_strength * 0.035
		target_rot.y = noise.get_noise_2d(0.0, noise_time) * shake_strength * 0.02
		target_rot.z = noise.get_noise_2d(noise_time, noise_time) * shake_strength * 0.05

		target_pos.x = noise.get_noise_2d(noise_time + 10.0, 0.0) * shake_strength * 0.02
		target_pos.y = noise.get_noise_2d(0.0, noise_time + 10.0) * shake_strength * 0.02

		shake_strength = lerp(shake_strength, 0.0, delta * shake_decay)

	# Smooth interpolation (prevents jitter)
	cam_shake_node.rotation = cam_shake_node.rotation.lerp(target_rot, delta * 10.0)
	cam_shake_node.position = cam_shake_node.position.lerp(target_pos, delta * 10.0)


func _process(delta: float) -> void:
	if bone_index != -1:
		var bone_global := skeleton.get_bone_global_pose_no_override(bone_index)
		var rot := Basis(Vector3.RIGHT, -pitch)
		bone_global.basis = rot * bone_global.basis

		skeleton.set_bone_global_pose_override(
			bone_index,
			bone_global,
			1.0,
			true
		)

	apply_camera_shake(delta)


# RUNNING SIGNAL
func _on_player_running(stamina: float) -> void:
	shake_strength = 2


func _on_player_walking(stamina: float) -> void:
	shake_strength = .5
