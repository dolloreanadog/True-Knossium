extends BaseFX

func playFX():
	if character.stats.defense * 2 < character.stats.currentDefense:
		character.stats.currentDefense = character.stats.defense * 2
