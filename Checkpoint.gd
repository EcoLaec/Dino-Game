extends Area2D

func _on_body_entered(body):
	body.respawn_point = global_position
