extends BasePartyContainer

func getCharactersInfo():
	if characterDied:
#		print(str(self) + ": Getting Character Info, because character Died")
		characterDied = false
	else:
		pass
#		print(str(self) + ": Getting Character Info")
	var LtotalStatPoints: int = 0
	var LtotalCurrentStatPoints: float =0
	var LcharacterIsHealer: Array = []
	var LcharacterIsTank: Array = []
	var LcharacterIsDPSMelee: Array = []
	var LcharacterIsDPSRanged: Array = []
	
	characters = get_children()
	charactersAmount = get_child_count()
	
#	print(str(self) + ": (check) characters: " + str(characters))
#	print(str(self) + ": (check) charactersAmount: " + str(charactersAmount))
	
	# Dividing EXP here to split between characters
	receivingEXP /= charactersAmount * 1.5
	
	for i in charactersAmount:
		#Grabs important Nodes
		var character: BaseCharacter = get_child(i)
		var characterStats: StatComponent = get_child(i).get_node("StatComponent")
		
		if characterStats.is_connected("death", onCharacterDeath) == false:
			characterStats.connect("death", onCharacterDeath)
			
		if characterStats.is_connected("moraleBroken", onCharacterDeath) == false:
			characterStats.connect("moraleBroken", onCharacterDeath)
		
		if characterStats.currentHealth <= 0:
			pass
			push_warning("Trying to push a character that's Dead")
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
			
			# Adds to the temporary totalStatPoints
			LtotalStatPoints += characterStats.totalStatPoints
			LtotalCurrentStatPoints += characterStats.getCurrentTotalStatPoints()
			
			
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
	
	emit_signal("charactersUpdated")

@warning_ignore("unused_parameter")
func addCharacter(character: BaseCharacter, startingExperience: float, giveDifficultyEXP: bool, characterPosition: Vector2):
	print(str(self) + ": Spawning: " + str(character))
	var tween: Tween = get_tree().create_tween().bind_node(character)
	print("Tween: " + str(tween))
	var characterStats: StatComponent = character.get_node("StatComponent")
	
	var role := characterStats.role
	var spot: Vector2
	
	character.isFriendly = true
	add_child(character, true)
	character.stats.changeEXP(startingExperience)
	if character.characterSprite != null:
		character.characterSprite.flip_h = false
	match role:
		characterStats.rolesList.Healer:
			if Vector2(0, 0) == characterPosition:
				spot = SupportSpawnArea.randomizeSpawn()
				character.trueGlobalPosition = spot
				character.set_position(spot - Vector2(150, 0))
				tween.tween_property(character, "global_position", spot, 1)
			else:
				character.set_position(characterPosition)
				character.trueGlobalPosition = characterPosition
				tween.tween_property(character, "global_position", characterPosition, 1)
		characterStats.rolesList.Tank: 
			if Vector2(0, 0) == characterPosition:
				spot = CQCSpawnArea.randomizeSpawn()
				character.trueGlobalPosition = spot
				character.set_position(spot - Vector2(550, 0))
				tween.tween_property(character, "global_position", spot, 1)
			else:
				character.set_position(characterPosition)
				character.trueGlobalPosition = characterPosition
				tween.tween_property(character, "global_position", characterPosition, 1)
		characterStats.rolesList.DPSMelee: 
			if Vector2(0, 0) == characterPosition:
				spot = CQCSpawnArea.randomizeSpawn()
				character.trueGlobalPosition = spot
				character.set_position(spot - Vector2(550, 0))
				tween.tween_property(character, "global_position", spot, 1)
			else:
				character.set_position(characterPosition)
				character.trueGlobalPosition = characterPosition
				tween.tween_property(character, "global_position", characterPosition, 1)
		characterStats.rolesList.DPSRanged: 
			if Vector2(0, 0) == characterPosition:
				spot = DPSRangedSpawnArea.randomizeSpawn()
				character.trueGlobalPosition = spot
				character.set_position(spot - Vector2(300, 0))
				tween.tween_property(character, "global_position", spot, 1)
			else:
				character.set_position(characterPosition)
				character.trueGlobalPosition = characterPosition
				tween.tween_property(character, "global_position", characterPosition, 1)
	
	getCharactersInfo()
	dungeon.statButtonGroup.updateModulation()

func onAllCharactersDead():
#	print(str(self) + ": Checking if characters are dead")
#	print(str(self) + ": Checking if characters are dead List: " + str(characters))
	if charactersAmount <= 0 && dungeon.specialWindowContainer.get_child_count() == 0:
		print(str(self) + ": All Characters Died")
		if isFriendly:
			dungeon.stopControlVisible(true, 1)
			dungeon.saveToSaveSystem()
			await dungeon.SaveFinished
			await get_tree().create_timer(2).timeout
			Global.StartLoadingScreen(false)
			dungeon.queue_free()
			get_tree().change_scene_to_file("res://resources/levels/menu/GameOverMenu/GameOverMenu.tscn")
