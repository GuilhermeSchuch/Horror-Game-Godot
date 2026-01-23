extends Node3D

@onready var camera_pivot := $CameraPivot

const RIGHT_HAND_BONE := "DEF-hand.R"

var sens := 0.002
var max_pitch := deg_to_rad(65)
var pitch := 0.0
var skeleton: Skeleton3D
var bone_index: int

func _ready() -> void:
	var skeleton_path = $"../PlayerModel/root_character_deform/Skeleton3D"
	
	# Centers the mouse cursor on the screen and make it invisible
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	skeleton = $"../PlayerModel/root_character_deform/Skeleton3D"
	bone_index = skeleton.find_bone(RIGHT_HAND_BONE)

	if bone_index == -1:
		push_error("Bone not found: " + RIGHT_HAND_BONE)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Yaw = player/body
		get_parent().rotate_y(-event.relative.x * sens)

		# Pitch = camera pivot
		pitch -= event.relative.y * sens
		pitch = clamp(pitch, -max_pitch, max_pitch)

		camera_pivot.rotation.x = pitch


func _process(delta: float) -> void:
	if bone_index == -1:
		return

	# Get pose WITHOUT overrides
	var bone_global := skeleton.get_bone_global_pose_no_override(bone_index)

	# Rotate around local X
	var rot := Basis(Vector3.RIGHT, -pitch)
	bone_global.basis = rot * bone_global.basis

	skeleton.set_bone_global_pose_override(
		bone_index,
		bone_global,
		1.0,  # weight
		true  # persistent
	)
