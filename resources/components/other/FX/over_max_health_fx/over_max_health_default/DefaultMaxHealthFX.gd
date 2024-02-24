extends BaseFX

func playFX():
	if is_instance_valid(stats):
		stats.currentHealth = stats.health
	playSFX()
	playVFX()
