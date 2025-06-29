extends Node

func play(res_url: String):
	var sound = load(res_url)
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sound
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)