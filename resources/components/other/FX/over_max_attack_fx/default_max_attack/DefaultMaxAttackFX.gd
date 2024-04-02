extends BaseFX

func playFX():
	if character.stats.attack * 2 < character.stats.currentAttack:
		character.stats.currentAttack = character.stats.attack * 2
