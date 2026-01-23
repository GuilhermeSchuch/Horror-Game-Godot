extends Node3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("flashlight"):
		%FlashLightBeam.visible = !%FlashLightBeam.visible
		%FlashlightLens.visible = !%FlashlightLens.visible
