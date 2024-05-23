extends Pickup

@export var time_gained = 30.0

func onPickup(area):
	var t = LevelTimer.time_left
	LevelTimer.start(t + time_gained)
	super.onPickup(area)
