class_name Pickup
extends Area2D

@export var points = 100

func onPickup(_area):
	Global.score += points
	queue_free()


func _on_area_entered(area):
	onPickup(area)
