extends CharacterBody2D

# Player Stats
@export var speed = 100.0
@export var acceleration = 800.0
@export var friction = 1200.0
@export var jump_velocity = -300.0
@export var gravity_scale = 1.0
@export var terminal_velocity = 500.0
@export var air_jumps = 1
@export var air_jump_scale = 0.8
@export var wall_jump_horizontal_scale = 1.0
@export var wall_jump_vertical_scale = 1.0
@export var air_acceleration = 600.0
@export var air_friction = 200.0
@export var cling_speed = 75.0
@export var sprint_speed = 130.0

# Reference Variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D
@onready var coyote_time = $CoyoteTime
var air_jumps_made = 0
var just_wall_jumped = false
var clinging = false
var sprinting = false

func _physics_process(delta):
	var input_axis = Input.get_axis("Left","Right")
	clinging = is_on_wall_only() and input_axis and velocity.y >= 0.0
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	apply_acceleration(input_axis,delta)
	apply_friction(input_axis,delta)
	update_animations(input_axis)
	# Before Moving
	var was_on_floor = is_on_floor()
	move_and_slide()
	# After Moving
	just_wall_jumped = false
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge: coyote_time.start()

func apply_gravity(delta):
	var current_terminal_velocity = cling_speed if clinging else terminal_velocity
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
		velocity.y = min(velocity.y,current_terminal_velocity)

func handle_wall_jump():
	# Skip if not on Wall
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("Jump"):
		velocity.x = wall_normal.x * speed * wall_jump_horizontal_scale
		velocity.y = jump_velocity * wall_jump_vertical_scale
		just_wall_jumped = true

func handle_jump():
	# Resetting Air Jumps
	if is_on_floor(): air_jumps_made = 0
	# Jumping
	if (is_on_floor() or coyote_time.time_left > 0.0) and Input.is_action_just_pressed("Jump"):
		velocity.y = jump_velocity
	
	# Off of Floor
	if not is_on_floor():
		# Short Hops
		if Input.is_action_just_released("Jump") and velocity.y < jump_velocity / 2:
			velocity.y = jump_velocity / 2
		
		# Air Jumps
		if Input.is_action_just_pressed("Jump") and air_jumps_made < air_jumps and coyote_time.time_left == 0.0 and not just_wall_jumped:
			velocity.y = jump_velocity * air_jump_scale
			air_jumps_made += 1

func apply_acceleration(input_axis,delta):
	sprinting = Input.is_action_pressed("Sprint")
	var current_speed = sprint_speed if sprinting else speed
	if input_axis:
		if is_on_floor():
			# Grounded Acceleration
			velocity.x = move_toward(velocity.x, current_speed * input_axis, acceleration * delta)
		else:
			# Aerial Acceleration
			velocity.x = move_toward(velocity.x, current_speed * input_axis, air_acceleration * delta)

func apply_friction(input_axis,delta):
	if not input_axis:
		if is_on_floor():
			# Grounded Friction
			velocity.x = move_toward(velocity.x, 0, friction * delta)
		else:
			# Aerial Friction
			velocity.x = move_toward(velocity.x, 0, air_friction * delta)

func update_animations(input_axis):
	# Grounded Animations
	if input_axis:
		sprite.flip_h = input_axis < 0
		if sprinting: 
			sprite.play("sprint")
		else:
			sprite.play("walk")
	else:
		sprite.play("idle")
	
	# Aerial Animations
	if not is_on_floor():
		if velocity.y <= 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
		if clinging: sprite.play("cling")
