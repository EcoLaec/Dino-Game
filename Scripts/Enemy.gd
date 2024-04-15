class_name Enemy
extends CharacterBody2D

@export var speed = 25.0
@export var flying = false
@export var invincible = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D
@onready var shape = $CollisionShape2D
@onready var edge_shape = $EdgeDetector/CollisionShape2D
var direction = Vector2.RIGHT
var is_moving = true

func _physics_process(delta):
	if not is_on_floor() and not flying: velocity.y += gravity * delta
	velocity.x = direction.x * speed
	if not is_moving: velocity = Vector2.ZERO
	move_and_slide()
	if is_on_wall(): change_direction()

func change_direction():
	direction = -direction
	sprite.flip_h = not sprite.flip_h
	edge_shape.position.x = -edge_shape.position.x

func die():
	is_moving = false
	if not invincible: call_deferred("disable_collision")
	sprite.stop()
	sprite.play("death")
	await sprite.animation_finished
	if invincible:
		is_moving = true
		sprite.play("move")
	else:
		queue_free()

func disable_collision():
	shape.disabled = true

func _on_edge_detector_body_exited(_body):
	change_direction()
