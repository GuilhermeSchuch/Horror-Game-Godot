extends AnimationPlayer

func _on_player_running(stamina: float) -> void:
	if current_animation != "runHD_001":
		play("runHD_001")


func _on_player_walking(stamina: float) -> void:
	if current_animation != "anim_walkwHD":
		play("anim_walkwHD")


func _on_player_idle(stamina: float) -> void:
	if current_animation != "iddle_001":
		play("iddle_001", -1, 0.2)
