extends ProgressBar

func _ready():
	max_value = 4.0
	value = 4.0
	visible = false


func _on_player_running(stamina: float) -> void:
	visible = true
	value = stamina


func _on_player_stop_running(stamina: float) -> void:
	value = stamina
	if stamina >= max_value:
		visible = false
