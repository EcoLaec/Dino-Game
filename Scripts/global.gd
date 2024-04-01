extends Node

var player_lives = 5
var score = 0
var rng = RandomNumberGenerator.new()

signal level_complete

func _ready():
	rng.randomize()
