extends BaseFX

func playFX():
	if is_instance_valid(stats):
		if stats.morale * 2 < stats.currentMorale:
			stats.currentMorale = stats.morale * 2
