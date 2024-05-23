extends Node2D

@export var next_level : PackedScene
@export var level_time = 180

@onready var level_transition = $LevelTransition

func _ready():
	Global.level_complete.connect(complete_level)
	LevelTimer.start(level_time)
	level_transition.fade_from_black()

func complete_level():
	Global.score += int(LevelTimer.time_left) * 5
	get_tree().paused = true
	if not next_level is PackedScene: return
	await level_transition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
