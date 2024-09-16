extends BaseFX

func playFX():
	if character.stats.defense * 1.25 < character.stats.currentDefense:
		character.stats.currentDefense = character.stats.defense * 1.25
