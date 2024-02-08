extends BaseFX

func playVFX():
	if character.getAnimation() != "death":
		character.runAnimation("death")

func animationFinished():
	if character.getAnimation() == "death":
		character.queue_free()
