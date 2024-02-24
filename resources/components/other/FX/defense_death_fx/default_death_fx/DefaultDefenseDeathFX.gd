extends BaseFX

func playFX():
	if is_instance_valid(stats):
		stats.currentDefense = 1
	#playSFX()
	playVFX()
	

func playVFX():
	sprite.global_position = character.global_position
	if sprite.get_animation() != "active":
		print("Running Defense Death animation")
		sprite.play("active")
		while sprite.frame != 4:
			await get_tree().create_timer(0.1).timeout
			print("Defense Death Animation still running at frame " + str(sprite.frame))
		if is_instance_valid(sprite):
			sprite.play("inactive")
