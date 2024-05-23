extends Pickup

func _on_audio_stream_player_finished():
	Global.level_complete.emit()
	super._on_audio_stream_player_finished()
