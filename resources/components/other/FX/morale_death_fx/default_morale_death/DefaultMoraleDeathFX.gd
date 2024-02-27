extends BaseFX

func _ready():
	sprite.play("inactive")

func playFX():
	#playSFX()
	playVFX()

func playVFX():
	sprite.global_position = character.global_position
	if sprite.get_animation() != "active":
		sprite.play("active")
		while sprite.is_playing():
			await get_tree().create_timer(0.02).timeout
		print(str(self) + ": (surrender) Morale Death Animation Done")
		print(str(self) + ": scene file path: " + str(character.scene_file_path))
		while character.dungeon.isCharactersActive:
			await get_tree().create_timer(0.02).timeout
		if is_instance_valid(character):
			if !character.stats.alreadyDied:
				if character.isFriendly:
					var loadedCharacter = load(character.scene_file_path)
					var instance = loadedCharacter.instantiate()
					print("instance: " + str(instance))
					character.queue_free()
					character.dungeon.enemyPartyContainer.addCharacter(instance, character.stats.totalExperience, false, Vector2(0, 0))
					character.stats.emit_signal("moraleBroken", 0, character.stats.characterBody)
				else:
					character.dungeon.spawnSurrenderWindow(character, character.profilePicture, character.id, character.stats.totalExperience)

