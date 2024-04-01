extends Pickup

func onCollide():
	Global.level_complete.emit()
	super.onCollide()
