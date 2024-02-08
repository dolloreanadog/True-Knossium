extends BaseFX

func playFX():
	stats.currentHealth = stats.health
	playSFX()
	playVFX()
