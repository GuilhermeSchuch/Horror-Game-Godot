extends AudioStreamPlayer

const FALLING_DOWN_STAIRS = preload("uid://b0757lhoxsef0")

func _play_audio(audio: AudioStream, volume = 0.0):
	if stream == audio:
		return
	
	stream = audio
	volume_db = volume
	play()

func play_stairs_jumpscare():
	_play_audio(FALLING_DOWN_STAIRS)
