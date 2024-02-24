extends BaseFX

func playFX():
	if is_instance_valid(stats):
		stats.currentAttack = 0
	playVFX()

func playVFX():
	sprite.global_position = character.global_position
	if sprite.get_animation() != "active":
		print("Running Attack Death animation")
		sprite.play("active")
		while sprite.is_playing():
			await get_tree().create_timer(0.1).timeout
			print("Attack Death Animation still running at frame " + str(sprite.frame))
		if is_instance_valid(sprite):
			sprite.play("inactive")
