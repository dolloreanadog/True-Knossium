extends BasePartyContainer

func getCharactersInfo():
	if characterDied:
#		print(str(self) + ": Getting Character Info, because character Died")
		characterDied = false
	else:
		pass
#		print(str(self) + ": Getting Character Info")
	var LtotalStatPoints: int = 0
	var LtotalCurrentStatPoints: float = 0
	var LcharacterIsHealer: Array = []
	var LcharacterIsTank: Array = []
	var LcharacterIsDPSMelee: Array = []
	var LcharacterIsDPSRanged: Array = []
	
	characters = get_children()
	charactersAmount = get_child_count()
	
#	print(str(self) + ": (getCharactersInfo) characters: " + str(characters))
#	print(str(self) + ": (getCharactersInfo) charactersAmount: " + str(charactersAmount))
	
	# Dividing EXP here to split between characters
	receivingEXP /= charactersAmount * 1.25
	
	for i in charactersAmount:
		#Grabs important Nodes
		var character: BaseCharacter = get_child(i)
		var characterStats: StatComponent = get_child(i).get_node("StatComponent")
		
#		if characterStats.is_connected("death", onCharacterDeath) == false:
#			characterStats.connect("death", onCharacterDeath)
#
#		if characterStats.is_connected("moraleBroken", onCharacterDeath) == false:
#			characterStats.connect("moraleBroken", onCharacterDeath)
		
		if characterStats.currentHealth <= 0:
			pass
#			push_warning("Trying to push a character that's Dead")
		else:
			match characterStats.role:
				characterStats.rolesList.Healer:
					LcharacterIsHealer.append(character)
				characterStats.rolesList.DPSRanged:
					LcharacterIsDPSRanged.append(character)
				characterStats.rolesList.DPSMelee:
					LcharacterIsDPSMelee.append(character)
				characterStats.rolesList.Tank:
					LcharacterIsTank.append(character)
				_:
					push_error("Line 58-68, Role does not apply to existing ones!")
					
#			print(str(self) + ": Receiving EXP: " + str(receivingEXP))
			characterStats.changeEXP(receivingEXP)
			dungeon.musicPlayer.setCharacterMusic(character.characterThemeMusic, character.characterMusicPriority)
			# Adds to the temporary totalStatPoints
			LtotalStatPoints += characterStats.totalStatPoints
			LtotalCurrentStatPoints += characterStats.getCurrentTotalStatPoints()
			
#		await get_tree().create_timer(0.05).timeout
	# reset receiving EXP since we're done using it, also to not use excess
	receivingEXP = 0
	print(str(self) + ": Reset receiving EXP")
	
	# Put all temporary variables into the permanent ones
	currentTotalStatPoints = LtotalCurrentStatPoints
	totalStatPoints = LtotalStatPoints
	
	characterIsHealer = LcharacterIsHealer
	characterIsTank = LcharacterIsTank
	characterIsDPSMelee = LcharacterIsDPSMelee
	characterIsDPSRanged = LcharacterIsDPSRanged
	characterIsActive = characterIsHealer + characterIsTank + characterIsDPSMelee + characterIsDPSRanged
	
	# Set the AreaAOEDenial to active or not
	if characterIsTank.size() == 0 && characterIsDPSMelee.size() == 0:
		AOEDenialRanged.setActive(false)
	else:
		AOEDenialRanged.setActive(true)
	if characterIsDPSRanged.size() == 0 && characterIsTank.size() == 0 && characterIsDPSMelee.size() == 0:
		AOEDenialSupport.setActive(false)
	else: 
		AOEDenialSupport.setActive(true)
	
#	if isFriendly:
#		print(str(self) + ": Friendly Total Stat Points = " + str(totalStatPoints))
#		print(str(self) + ": Turn: " + str(system.turn) + ": Friendly Characters: " + str(characters))
#		print(str(self) + ": Turn: " + str(system.turn) + ": Friendly Character Amount: " + str(charactersAmount))
#	else:
#		print(str(self) + ": Enemy Total Stat Points = " + str(totalStatPoints))
#		print(str(self) + ": Turn: " + str(system.turn) + ": Enemy Characters" + str(characters))
#		print(str(self) + ": Turn: " + str(system.turn) + ": Enemy Character Amount: " + str(charactersAmount))
	emit_signal("charactersUpdated")

@warning_ignore("unused_parameter")
func addCharacter(character: BaseCharacter, startingExperience: float, spawnedFromDifficulty: bool, characterPosition: Vector2):
	isSpawningCharacter = true
	print(str(self) + ": Spawning: " + str(character))
	var tween: Tween = get_tree().create_tween().bind_node(character)
	print("Tween: " + str(tween))
	var characterStats: StatComponent = character.get_node("StatComponent")
	
	var role := characterStats.role
	var spot: Vector2
	
	if characterStats.is_connected("death", onCharacterDeath) == false:
		characterStats.connect("death", onCharacterDeath)
	if characterStats.is_connected("moraleBroken", onCharacterDeath) == false:
		characterStats.connect("moraleBroken", onCharacterDeath)
	
	character.isFriendly = false
	add_child(character, true)
	character.stats.changeEXP(startingExperience)
	if spawnedFromDifficulty:
		characterStats.changeEXP(randomizeDifficultyEXP())
#		print(str(self) + ": charityDifficultyEXP: " + str(spawnedFromDifficulty))
	if character.characterSprite != null:
		character.characterSprite.flip_h = true
	match role:
		characterStats.rolesList.Healer:
			if Vector2(0, 0) == characterPosition:
				spot = SupportSpawnArea.randomizeSpawn()
				character.trueGlobalPosition = spot
				character.set_position(spot + Vector2(250, 0))
				if !spawnedFromDifficulty:
					await tween.tween_property(character, "global_position", spot, 1).finished
			else:
				character.set_position(characterPosition)
				character.trueGlobalPosition = characterPosition
				await tween.tween_property(character, "global_position", characterPosition, 1).finished
		characterStats.rolesList.Tank: 
			if Vector2(0, 0) == characterPosition:
				spot = CQCSpawnArea.randomizeSpawn()
				character.trueGlobalPosition = spot
				character.set_position(spot + Vector2(950, 0))
				if !spawnedFromDifficulty:
					await tween.tween_property(character, "global_position", spot, 1).finished
			else:
				character.set_position(characterPosition)
				character.trueGlobalPosition = characterPosition
				await tween.tween_property(character, "global_position", characterPosition, 1).finished
		characterStats.rolesList.DPSMelee: 
			if Vector2(0, 0) == characterPosition:
				spot = CQCSpawnArea.randomizeSpawn()
				character.trueGlobalPosition = spot
				character.set_position(spot + Vector2(950, 0))
				if !spawnedFromDifficulty:
					await tween.tween_property(character, "global_position", spot, 1).finished
			else:
				character.set_position(characterPosition)
				character.trueGlobalPosition = characterPosition
				await tween.tween_property(character, "global_position", characterPosition, 1).finished
		characterStats.rolesList.DPSRanged: 
			if Vector2(0, 0) == characterPosition:
				spot = DPSRangedSpawnArea.randomizeSpawn()
				character.trueGlobalPosition = spot
				character.set_position(spot + Vector2(950, 0))
				if !spawnedFromDifficulty:
					await tween.tween_property(character, "global_position", spot, 1).finished
			else:
				character.set_position(characterPosition)
				character.trueGlobalPosition = characterPosition
				await tween.tween_property(character, "global_position", characterPosition, 1).finished
	
	isSpawningCharacter = false
#	getCharactersInfo()
	dungeon.statButtonGroup.updateModulation()
	tween.kill()

func onAllCharactersDead():
	print(str(self) + ": Checking if characters are dead")
#	print(str(self) + ": Checking if characters are dead List: " + str(characters))
	# replaced characterAmount with get_child_count()
	await get_tree().create_timer(0.05).timeout
	if totalStatPoints <= 0:
		print(str(self) + ": All Characters Died")
		print(str(self) + ": Battle should have ended")
		system.newBattle()
