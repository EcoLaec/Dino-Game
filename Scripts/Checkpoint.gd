extends Area2D

var active = false

func _on_area_entered(area):
	area.get_parent().respawn_point = global_position
	if not active: 
		$AnimatedSprite2D.play("activate")
		Global.score += 1500
		$ActivateSound.play()
	active = true
