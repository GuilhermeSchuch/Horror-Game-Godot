extends StaticBody3D


func play_jumpscare():
	if chance(3):
		AudioManager.play_stairs_jumpscare()
		return true
	else:
		return false


func chance(percent: float) -> bool:
	return randf() <= percent / 100.0
