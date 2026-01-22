extends RayCast3D

func _process(delta: float) -> void:
	if is_colliding():
		var object = get_collider()
		if object.has_method("interact") && Input.is_action_just_pressed("interact"):
			object.interact()
