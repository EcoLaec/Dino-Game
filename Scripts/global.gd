extends Node

var player : Player
var player_lives = 3
var score = 0
var rng = RandomNumberGenerator.new()

signal level_complete

func _ready():
	rng.randomize()
