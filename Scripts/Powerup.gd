extends Pickup

@export var powerup_time : float = 30.0
@export var powerup : Global.PowerUps

func onPickup(area):
	var p = area.get_parent()
	p.activate_powerup(powerup,powerup_time)
	super.onPickup(area)
