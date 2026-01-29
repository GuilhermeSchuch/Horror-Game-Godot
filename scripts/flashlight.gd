extends Node3D

@export var max_distance := 12.0

signal being_used(battery: float)

const MAX_BATTERY := 100.0
const MIN_BATTERY := 0.0
const DRAIN_PER_SECOND := 0.1

var battery := MAX_BATTERY
var flashlight_on := false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("flashlight"):
		toggle_flashlight()

	if flashlight_on:
		drain_battery(delta)
		
		%FlashLightRayCast.target_position = Vector3.FORWARD * max_distance
		%FlashLightRayCast.force_raycast_update()

		if %FlashLightRayCast.is_colliding():
			var obj_colliding = %FlashLightRayCast.get_collider().has_meta("DisableShadow")
			print(%FlashLightRayCast.get_collider())
			#print(obj_colliding)
			
			if obj_colliding:
				print("COLLIDING: ", obj_colliding)
				var hit_dist = %FlashLightRayCast.global_position.distance_to(%FlashLightRayCast.get_collision_point())
				%FlashLightBeam.spot_range = hit_dist
		else:
			%FlashLightBeam.spot_range = max_distance


func toggle_flashlight() -> void:
	if battery <= MIN_BATTERY:
		return

	%ToggleFlashlightFX.play()

	flashlight_on = !flashlight_on
	%FlashLightBeam.visible = flashlight_on
	%FlashlightLens.visible = flashlight_on
	%FlashlightBattery.visible = flashlight_on

func drain_battery(delta: float) -> void:
	battery -= DRAIN_PER_SECOND * delta
	battery = max(battery, MIN_BATTERY)

	emit_signal("being_used", battery)

	if battery <= MIN_BATTERY:
		flashlight_on = false
		%FlashLightBeam.visible = false
		%FlashlightLens.visible = false
		# %FlashlightBattery.visible = false
