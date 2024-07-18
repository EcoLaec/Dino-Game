extends Node

var player : Player
var player_lives = 3
var score = 0
var rng = RandomNumberGenerator.new()

signal level_complete
signal player_died(player : Player)
signal picked_up_pearl

func _ready():
	rng.randomize()
