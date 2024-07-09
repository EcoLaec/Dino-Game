extends Pickup

func _on_pickup_sound_finished():
	Global.level_complete.emit()
	super._on_pickup_sound_finished()
