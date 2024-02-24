extends BaseFX

func playFX():
	playVFX()

func playVFX():
	if character.getAnimation() != "death":
		print("Running death animation")
		character.runAnimation("death")
		#await get_tree().create_timer(0.85).timeout
		while sprite.is_playing():
			await get_tree().create_timer(0.02).timeout
			print("Death Animation still running at frame " + str(sprite.frame))
			if character.getAnimation() != "death":
				break
		await get_tree().create_timer(0.04).timeout
		sprite.pause()
		sprite.stop()
		character.queue_free()
		stats.emit_signal("death", stats.worthEXP, stats.characterBody)
			

