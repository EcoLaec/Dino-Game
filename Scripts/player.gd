extends CharacterBody2D

@export var speed = 100.0
@export var acceleration = 800.0
@export var friction = 1200.0
@export var jump_velocity = -300.0
@export var gravity_scale = 1.0
@export var terminal_velocity = 500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	var input_axis = Input.get_axis("Left","Right")
	apply_gravity(delta)
	handle_jump()
	apply_acceleration(input_axis,delta)
	apply_friction(input_axis,delta)
	update_animations(input_axis)
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
		velocity.y = min(velocity.y,terminal_velocity)

func handle_jump():
	if is_on_floor() and Input.is_action_just_pressed("Jump"):
		velocity.y = jump_velocity
	
	if not is_on_floor():
		if Input.is_action_just_released("Jump") && velocity.y < jump_velocity / 2:
			velocity.y = jump_velocity / 2

func apply_acceleration(input_axis,delta):
	if input_axis:
		velocity.x = move_toward(velocity.x, speed * input_axis, acceleration * delta)

func apply_friction(input_axis,delta):
	if not input_axis:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func update_animations(input_axis):
	if input_axis:
		sprite.flip_h = input_axis < 0
		sprite.play("walk")
	else:
		sprite.play("idle")
	
	if not is_on_floor():
		if velocity.y <= 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
