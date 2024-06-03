extends BaseFX

func _ready():
	sprite.play("inactive")

func playFX():
	#playSFX()
	playVFX()

func playVFX():
	print(" Playing Surrender FX")
	sprite.global_position = character.global_position
	if sprite.get_animation() != "active":
		print(" sprite is not active")
		sprite.play("active")
		while sprite.is_playing():
			await get_tree().create_timer(0.02).timeout
		print(str(self) + ": (surrender) Morale Death Animation Done")
		print(str(self) + ": scene file path: " + str(character.scene_file_path))
		# --- Error starts here
		while character.dungeon.isCharactersActive:
			await get_tree().create_timer(0.02).timeout
		print(" Character is no longer Active")
		# --- Error ends here
		# Need to make sure isCharacterActive is false
		if is_instance_valid(character):
			print(" character is valid")
			if !character.stats.alreadyDied:
				print(" character isn't dead")
				if character.isFriendly:
					var loadedCharacter = load(character.scene_file_path)
					var instance = loadedCharacter.instantiate()
					print("instance: " + str(instance))
					character.dungeon.enemyPartyContainer.addCharacter(instance, character.stats.totalExperience, false, Vector2(0, 0))
					character.queue_free()
					character.stats.emit_signal("moraleBroken", 0, character.stats.characterBody)
				else:
					print(" Opening Surrender Window")
					character.dungeon.spawnSurrenderWindow(character, character.profilePicture, character.id, character.stats.totalExperience)
			else:
				print(" character already dead")
		else:
			push_warning("Not A Valid Character")
	else:
		print(" Surrender Sprite is already active")
