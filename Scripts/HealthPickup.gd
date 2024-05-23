extends Pickup

func onPickup(area):
	if Global.player.current_health < Global.player.max_health:
		Global.player.current_health += 1
		super.onPickup(area)
