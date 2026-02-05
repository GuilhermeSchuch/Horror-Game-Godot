extends MeshInstance3D

@onready var starter_couch_collision: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var getting_up_fx: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _on_timer_timeout() -> void:
	starter_couch_collision.disabled = false
	getting_up_fx.play()
