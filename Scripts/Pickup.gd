class_name Pickup
extends Area2D

@export var points = 100

func onPickup(_area):
	Global.score += points
	$AudioStreamPlayer.pitch_scale = 1.0 + Global.rng.randf_range(-0.15,0.15)
	$AudioStreamPlayer.play()
	$PickupParticles.emitting = true
	call_deferred("disable_pickup")

func disable_pickup():
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D.visible = false
	$AmbientParticles.emitting = false

func _on_area_entered(area):
	onPickup(area)

func _on_audio_stream_player_finished():
	queue_free()
