extends Node

@onready var players := get_children()

func play(sound: AudioStream, volume_db := 0.0):
	if sound == null:
		return

	for p: AudioStreamPlayer in players:
		if !p.playing:
			p.stream = sound
			p.volume_db = volume_db
			p.play()
			return
	
func stop(sound: AudioStream):
	for p: AudioStreamPlayer in players:
		if p.playing and p.stream == sound:
			p.stop()
			
func stop_all_sfx(sound: AudioStream):
	for p: AudioStreamPlayer in players:
		if p.playing and p.stream == sound:
			p.stop()
