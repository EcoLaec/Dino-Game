extends Node2D

@export var next_level : PackedScene
@export var level_time = 180

@onready var level_transition = $LevelTransition

func _ready():
	Global.level_complete.connect(complete_level)
	Global.player_died.connect(player_death)
	LevelTimer.start(level_time)
	level_transition.fade_from_black()

func complete_level():
	Global.score += int(LevelTimer.time_left) * 25
	Global.score += Global.player_lives * 1000
	print(Global.score)
	get_tree().paused = true
	if not next_level is PackedScene: return
	await level_transition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)

func player_death(player : Player):
	get_tree().paused = true
	await level_transition.fade_to_black()
	Global.player_lives -= 1
	player.current_health = player.max_health
	if Global.player_lives <= 0:
		print(Global.score)
		get_tree().quit()
	else:
		player.global_position = player.respawn_point
		player.velocity = Vector2.ZERO
	get_tree().paused = false
	level_transition.fade_from_black()
