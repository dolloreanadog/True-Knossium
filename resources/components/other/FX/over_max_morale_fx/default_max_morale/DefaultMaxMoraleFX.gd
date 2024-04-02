extends BaseFX

func playFX():
	if character.stats.morale * 2 < character.stats.currentMorale:
		character.stats.currentMorale = character.stats.morale * 2
