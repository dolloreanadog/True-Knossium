extends BaseFX

func playFX():
	playSFX()
	playVFX()
	

func playVFX():
	if character.getAnimation() != "active":
		character.runAnimation("active")
