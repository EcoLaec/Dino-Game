extends Enemy

@export var health : int = 3
@onready var neck_attach = $NeckAttach
@onready var head = $NeckAttach/Head
@onready var neck = $NeckAttach/Neck

func _ready():
	update_neck()

func die():
	health -= 1
	if health > 0:
		hurt_sound.pitch_scale = 1 + Global.rng.randf_range(-0.2,0.2)
		hurt_sound.play()
		update_neck()
	else:
		neck_attach.visible = false
		super.die()

func disable_collision():
	$NeckAttach/Head/HeadCollider/CollisionShape2D.disabled = true
	super.disable_collision()

func change_direction():
	neck_attach.position.x = -neck_attach.position.x
	head.flip_h = not head.flip_h
	head.offset.x = -head.offset.x
	super.change_direction()

func update_neck():
	var neck_length = max(0,(health - 1) * 5)
	neck.region_rect = Rect2(0, 0, 5, neck_length)
	neck.position.y = -neck_length / 2.0
	head.position.y = -neck_length - 4.0
