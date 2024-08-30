extends BaseFX

func playFX():
	playVFX()
	playSFX()

func playVFX():
	if character.getAnimation() != "death":
		print("Running death animation")
		character.characterAnimation.play("death")
		

