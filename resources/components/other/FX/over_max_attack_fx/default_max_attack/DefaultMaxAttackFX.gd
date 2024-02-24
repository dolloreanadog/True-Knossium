extends BaseFX

func playFX():
	if is_instance_valid(stats):
		if stats.attack * 2 < stats.currentAttack:
			stats.currentAttack = stats.attack * 2
