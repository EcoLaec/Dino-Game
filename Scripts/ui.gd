extends CanvasLayer

@export var full_health_sprite : Texture2D
@export var empty_health_sprite : Texture2D

func _ready():
	for i in Global.player.max_health:
		var heart = TextureRect.new()
		heart.texture = full_health_sprite
		heart.custom_minimum_size = Vector2(48,48)
		%Health.add_child(heart)

func _process(_delta):
	var hearts = %Health.get_children()
	for i in hearts.size():
		if i < Global.player.current_health:
			hearts[i].texture = full_health_sprite
		else:
			hearts[i].texture = empty_health_sprite
	%LivesLabel.text = "x" + str(Global.player_lives)
	%ScoreLabel.text = "Score: " + str(Global.score).pad_zeros(6)
	%TimeLabel.text = str(int(LevelTimer.time_left) / 60).pad_zeros(2) + ":" + str(int(LevelTimer.time_left) % 60).pad_zeros(2)
