extends CanvasLayer

func _process(_delta):
	%LivesLabel.text = "x" + str(Global.player_lives)
	%ScoreLabel.text = "Score: " + str(Global.score)
	%TimeLabel.text = str(int(LevelTimer.time_left) / 60).pad_zeros(2) + ":" + str(int(LevelTimer.time_left) % 60).pad_zeros(2)
