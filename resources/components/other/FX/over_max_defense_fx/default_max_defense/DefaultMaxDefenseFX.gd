extends BaseFX

func playFX():
	if is_instance_valid(stats):
		if stats.defense * 2 < stats.currentDefense:
			stats.currentDefense = stats.defense * 2
