class_name Pickup
extends Area2D

@export var points = 100
@export var key : bool = false

func onPickup(_area):
	Global.score += points
	if key: Global.picked_up_pearl.emit()
	$PickupSound.pitch_scale = 1.0 + Global.rng.randf_range(-0.15,0.15)
	$PickupSound.play()
	$PickupParticles.emitting = true
	call_deferred("disable_pickup")

func disable_pickup():
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D.visible = false
	$AmbientParticles.emitting = false

func _on_area_entered(area):
	onPickup(area)

func _on_pickup_sound_finished():
	queue_free()
