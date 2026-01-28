extends Control

@onready var battery_rect_container: Control = %BatteryRectContainer
@onready var top_battery: ColorRect = $ProgressBar/TopBattery
@onready var progress_bar: ProgressBar = $ProgressBar

func _on_flashlight_being_used(battery: float) -> void:
	#print(battery)
	
	if battery <= 89 and battery >= 78:
		deplete_battery(0) # Green
	elif battery <= 78 and battery >= 67:
		deplete_battery(1) # Green
	elif battery <= 67 and battery >= 56:
		deplete_battery(2, "#f9b604") # Yellow
	elif battery <= 56 and battery >= 45:
		deplete_battery(3, "#f9b604") # Yellow
	elif battery <= 45 and battery >= 34:
		deplete_battery(4, "#fc5a03") # Orange
	elif battery <= 34 and battery >= 23:
		deplete_battery(5, "#fc5a03") # Orange
	elif battery <= 23 and battery >= 12:
		deplete_battery(6, "#eb0110") # Red
	elif battery <= 12 and battery >= 1:
		deplete_battery(7, "#eb0110") # Red
	elif battery <= 1 and battery >= 0:
		deplete_battery(8, "#eb0110") # Red


func deplete_battery(index: int, battery_color: String = "#58c357") -> void:
	# Hide battery rects
	var parent_battery := battery_rect_container.get_children()
	parent_battery[index].visible = false
	
	# Change battery color
	top_battery.self_modulate = battery_color
	
	var count := index + 1
	
	while count < parent_battery.size():
		parent_battery[count].self_modulate = battery_color
		count += 1
	
	var background_stylebox := progress_bar.get_theme_stylebox("background") as StyleBoxFlat
	background_stylebox.border_color = battery_color
	
	
