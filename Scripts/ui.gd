extends CanvasLayer

func _process(delta):
	%LivesLabel.text = "x" + str(Global.player_lives)
	%ScoreLabel.text = "Score: " + str(Global.score)
	%TimeLabel.text = str(int(LevelTimer.time_left) / 60) + ":" + str(int(LevelTimer.time_left) % 60)
