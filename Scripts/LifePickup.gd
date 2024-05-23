extends Pickup

func onPickup(area):
	Global.player_lives += 1
	super.onPickup(area)
