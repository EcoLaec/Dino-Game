class_name Pickup
extends Area2D

@export var points = 100

func onCollide():
	Global.score += points
	queue_free()
