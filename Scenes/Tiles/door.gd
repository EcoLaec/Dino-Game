extends StaticBody2D

@onready var sprite = $AnimatedSprite2D
@onready var shape = $CollisionShape2D

func _ready():
	Global.picked_up_pearl.connect(update)

func update():
	if sprite.frame < 2:
		sprite.frame += 1
	else:
		sprite.frame = 3
		call_deferred("disable_collision")

func disable_collision():
	shape.disabled = true
