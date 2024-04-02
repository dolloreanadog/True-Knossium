extends BaseFX

func playFX():
	character.stats.currentHealth = character.stats.health
	playSFX()
	playVFX()
