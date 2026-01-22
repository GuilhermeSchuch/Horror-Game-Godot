extends Node3D

func _process(delta: float) -> void:
	var player := get_node(%PlayerModel.get_parent().get_path())
	var is_holding_flashlight = player.get_meta("is_holding_flashlight")
	
	var flashlight = get_node("root_character_deform/Skeleton3D/PlayerHandAttachment")
	flashlight.visible = is_holding_flashlight	
