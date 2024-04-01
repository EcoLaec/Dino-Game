class_name SoundQueue
extends Node

@export var count : int = 5
var next = 0
var audioStreamPlayers : Array[AudioStreamPlayer]

func _ready():
	var child = get_child(0)
	
	for i in count:
		var duplicate = child.duplicate()
		audioStreamPlayers.append(duplicate)
		add_child(duplicate)

func playSound(pitch : float = 1.0, volume : float = 0.0):
	if not audioStreamPlayers[next].playing:
		audioStreamPlayers[next].pitch_scale = pitch
		audioStreamPlayers[next].volume_db = volume
		audioStreamPlayers[next].play(0.0)
		next += 1
		next %= count
