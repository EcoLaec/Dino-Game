extends Pickup

func onPickup(_body):
	Global.level_complete.emit()
	super.onPickup(_body)
