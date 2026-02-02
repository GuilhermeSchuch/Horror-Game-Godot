extends Node3D

@onready var player_flashlight: SpotLight3D = $"../../../../../PlayerHead/CameraPivot/ShakeOffset/SpringArm3D/MainCamera/PlayerFlashlight"

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


func toggle_flashlight() -> void:
	if battery <= MIN_BATTERY:
		return

	%ToggleFlashlightFX.play()

	flashlight_on = !flashlight_on
	player_flashlight.visible = flashlight_on
	%FlashlightLens.visible = flashlight_on
	%FlashlightBattery.visible = flashlight_on


func drain_battery(delta: float) -> void:
	battery -= DRAIN_PER_SECOND * delta
	battery = max(battery, MIN_BATTERY)

	emit_signal("being_used", battery)

	if battery <= MIN_BATTERY:
		flashlight_on = false
		player_flashlight.visible = false
		%FlashlightLens.visible = false
		# %FlashlightBattery.visible = false


func _on_player_falling_down_stairs() -> void:
	await get_tree().create_timer(3).timeout
	%FlickerFX.play()
