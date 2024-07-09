class_name Player
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
@export var max_health = 4

# Reference Variables
@export var jump_particle : PackedScene
@export var land_particle : PackedScene
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D
@onready var coyote_time = $CoyoteTime
@onready var wall_time = $WallTime
@onready var jump_sound = $JumpSound
@onready var land_sound = $LandSound
@onready var hurt_sound = $HurtSound
@onready var invincibility_timer = $InvincibilityTimer
@onready var hit_stop_timer = $HitStopTimer
@onready var hurt_animation = $HurtAnimation
var air_jumps_made = 0
var just_wall_jumped = false
var stored_wall_normal = Vector2.ZERO
var clinging = false
var sprinting = false
var respawn_point = Vector2.ZERO
var current_health = max_health
var feet_offset = Vector2(0,8)
var stored_velocity = Vector2.ZERO

func _ready():
	Global.player = self
	respawn_point = position
	LevelTimer.timeout.connect(die,true)

func _physics_process(delta):
	var input_axis = Input.get_axis("Left","Right")
	clinging = is_on_wall_only() and input_axis and velocity.y >= 0.0
	if Input.is_action_just_pressed("Reset"): damage(true)
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	apply_acceleration(input_axis,delta)
	apply_friction(input_axis,delta)
	update_animations(input_axis)
	# Before Moving
	var was_on_floor = is_on_floor()
	if not was_on_floor: stored_velocity = velocity
	var was_on_wall = is_on_wall_only()
	if was_on_wall: stored_wall_normal = get_wall_normal()
	if is_on_floor() and Input.is_action_just_pressed("Down"): position.y += 1
	move_and_slide()
	# After Moving
	if not was_on_floor and is_on_floor(): on_landing()
	just_wall_jumped = false
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge: coyote_time.start()
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall: wall_time.start()

func create_particle(particle : PackedScene, offset : Vector2, life : float = -1.0):
	var p = particle.instantiate()
	p.emitting = true
	p.global_position = global_position + offset
	if life > 0.0: p.lifetime = life
	get_parent().add_child(p)

func play_sound(sound : AudioStreamPlayer, pitch : float = 1.0, volume : float = -10.0):
	sound.pitch_scale = pitch
	sound.volume_db = volume
	sound.play()

func squish(squish_scale : Vector2, time : float):
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	sprite.scale = squish_scale
	tween.tween_property(sprite, "scale", Vector2(1,1), time)

func on_landing():
	play_sound(land_sound, 1.0, (stored_velocity.y * 0.1) - 60.0)
	create_particle(land_particle, feet_offset, stored_velocity.y * 0.0015)
	squish(Vector2(1.0 + stored_velocity.y * 0.0003,1.0 - stored_velocity.y * 0.0003), 0.25)

func jump_effects(pitch : float = 1.0, volume : float = -10.0):
	play_sound(jump_sound, pitch, volume)
	create_particle(jump_particle, feet_offset)
	squish(Vector2(0.9,1.1),0.25)

func apply_gravity(delta):
	var current_terminal_velocity = cling_speed if clinging else terminal_velocity
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta
		velocity.y = min(velocity.y,current_terminal_velocity)

func handle_wall_jump():
	# Skip if not on Wall
	if not is_on_wall_only() and wall_time.time_left <= 0.0: return
	var wall_normal = stored_wall_normal if wall_time.time_left > 0.0 else get_wall_normal()
	if Input.is_action_just_pressed("Jump"):
		velocity.x = wall_normal.x * speed * wall_jump_horizontal_scale
		velocity.y = jump_velocity * wall_jump_vertical_scale
		just_wall_jumped = true
		jump_effects(1.3,-15.0)
		air_jumps_made = 0

func handle_jump():
	# Resetting Air Jumps
	if is_on_floor(): air_jumps_made = 0
	# Jumping
	if (is_on_floor() or coyote_time.time_left > 0.0) and Input.is_action_just_pressed("Jump"):
		velocity.y = jump_velocity
		jump_effects()
	# Off of Floor
	if not is_on_floor():
		# Short Hops
		if Input.is_action_just_released("Jump") and velocity.y < jump_velocity / 2:
			velocity.y = jump_velocity / 2
		
		# Air Jumps
		if Input.is_action_just_pressed("Jump") and air_jumps_made < air_jumps and coyote_time.time_left == 0.0 and not just_wall_jumped:
			velocity.y = jump_velocity * air_jump_scale
			air_jumps_made += 1
			jump_effects(1.0 + 0.2 * air_jumps_made, -15.0)

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

func damage(hardDamage : bool):
	if invincibility_timer.time_left == 0.0 or hardDamage:
		current_health -= 1
		hurt_sound.play()
		invincibility_timer.start()
		hurt_animation.play("blink")
		hurt_effects()
		if current_health <= 0:
			die()
		if hardDamage: global_position = respawn_point

func hurt_effects():
	hit_stop_timer.start()
	sprite.play("hurt")
	get_tree().paused = true
	await hit_stop_timer.timeout
	if not current_health <= 0: get_tree().paused = false

func die():
	Global.player_died.emit(self)

func _on_hazard_collider_body_entered(_body):
	call_deferred("damage",_body.is_in_group("HardDamage"))

func _on_hazard_collider_area_entered(_area):
	call_deferred("damage",_area.is_in_group("HardDamage"))

func _on_trigger_collider_area_entered(area):
	area.onCollide()

func _on_enemy_collider_body_entered(body):
	if body.is_in_group("Enemy") and velocity.y > 0.0:
		velocity.y = jump_velocity
		air_jumps_made = 0
		body.die()
		squish(Vector2(0.9,1.1),0.25)

func _on_invincibilty_timer_timeout():
	hurt_animation.play("RESET")
	$HazardCollider/CollisionShape2D.disabled = true
	$HazardCollider/CollisionShape2D.disabled = false

func _on_enemy_collider_area_entered(area):
	if area.is_in_group("Enemy") and velocity.y > 0.0:
		velocity.y = jump_velocity
		air_jumps_made = 0
		area.die()
		squish(Vector2(0.9,1.1),0.25)
