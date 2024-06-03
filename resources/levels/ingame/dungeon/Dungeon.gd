extends BaseLevel
class_name levelDungeon
# Notes
# Once done, with real development, change this to work with next

#--[ Characters that spawn ]--
@export var healer = preload("res://resources/entities/characters_items/character/new_dev_game_characters/NewDevArcherCharacter.tscn")
@export var tank = preload("res://resources/entities/characters_items/character/new_dev_game_characters/NewDevMeleeCharacter.tscn")
@export var DPSRanged = preload("res://resources/entities/characters_items/character/new_dev_game_characters/NewDevSupportCharacter.tscn")
@export var DPSMelee = preload("res://resources/entities/characters_items/character/new_dev_game_characters/NewDevTankCharacter.tscn")

#--[ Item Test]--
@export var startingItem: BaseInventoryItem
@export var GoldItem: BaseInventoryItem

#--[ Functions ]--
func _ready():
	print("is stopControl Visible: " + str(stopControl.visible))
	print("is stopControl2 Visible: " + str(stopControl2.visible))
	Global.StartLoadingScreen(false)
	if SaveSystem.checkSaveFileExists():
		@warning_ignore("redundant_await")
		await loadSave()
	else:
		system.newTurn()
		system.newBattle()
		
		addNewGameCharacters()
		addNewGameItems()
	
	
	await get_tree().create_timer(1.5).timeout
	updateValueOfStatusBar()
	Global.EndLoadingScreen()
	SaveWarningLabel.hide()


#--[ New Game System ]--

func addNewGameCharacters() -> void:
	for i in Global.newGameCharacterInfo.size():
		var targetCharacter := load(Global.newGameCharacterInfo.pop_back())
		var loadedCharacter: BaseCharacter = targetCharacter.instantiate()
		friendlyPartyContainer.addCharacter(loadedCharacter, 0, false, Vector2(0, 0))
		await get_tree().create_timer(0.01).timeout

func addNewGameItems() -> void:
	for i in Global.newGameInventoryInfo.size():
		var targetItem = Global.newGameInventoryInfo.pop_back()
		print("Target Item " + targetItem.itemName)
		print("Target Item Amount: " + str(targetItem.amount))
		inventory.addToInventory(targetItem, targetItem.amount)
		#inventory.storedItems.push_back(targetItem)

#--[ Save System ]--

#-- Load
func loadSave() -> bool:
	SaveSystem.loadAllData()
	
	peakTotalStatPoints = SaveSystem.GameInfoDict.PeakTotalStatPoints
	totalCharactersDied = SaveSystem.GameInfoDict.CharactersDied
	totalCharactersSurrendered = SaveSystem.GameInfoDict.CharactersSurrendered
	system.battle = SaveSystem.GameInfoDict.Battles
	system.turn = SaveSystem.GameInfoDict.Turns
	
	call_deferred("loadCharacters")
	if Global.newGameInventoryInfo.is_empty():
		call_deferred("loadItems")
	else:
		addNewGameItems()
	call_deferred("loadAOE")
#	print("GameInfoDict PeakTotalStatPoints: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict CharactersDied: " + str(SaveSystem.GameInfoDict.CharactersDied))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict CharactersSurrendered: " + str(SaveSystem.GameInfoDict.CharactersSurrendered))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict Battles: " + str(SaveSystem.GameInfoDict.Battles))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict Turns: " + str(SaveSystem.GameInfoDict.Turns))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict FriendlyCharactersList: " + str(SaveSystem.GameInfoDict.FriendlyCharactersList))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict EnemyCharactersList: " + str(SaveSystem.GameInfoDict.EnemyCharactersList))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict Inventory: " + str(SaveSystem.GameInfoDict.Inventory))
#	await get_tree().create_timer(0.05).timeout
	print("Loaded GameInfoDict SupportAOEList: " + str(SaveSystem.GameInfoDict.SupportAOEList))
	friendlyPartyContainer.getCharactersInfo()
	turnsLabel.set_text("Turns: " + str(system.turn))
	getBattle()
	return true

func loadCharacters() -> void:
	var savedFriendlyCharactersList: Array = SaveSystem.GameInfoDict.FriendlyCharactersList
	var savedEnemyCharactersList: Array = SaveSystem.GameInfoDict.EnemyCharactersList
	var targetCharacterInstance: BaseCharacter
	
	for i in savedFriendlyCharactersList.size():
		var targetCharacterInfo: Dictionary = savedFriendlyCharactersList.pop_back()
		
		var loadCharacter := load(targetCharacterInfo.CharacterFilePath)
		targetCharacterInstance = loadCharacter.instantiate()
		
		friendlyPartyContainer.addCharacter(targetCharacterInstance, targetCharacterInfo.CharacterExperience, false, targetCharacterInfo.CharacterPosition)
		
		if is_instance_valid(targetCharacterInstance.action1):
			targetCharacterInstance.action1.currentCastTime = targetCharacterInfo.CharacterAction1CurrentCastTime
		if is_instance_valid(targetCharacterInstance.action2):
			targetCharacterInstance.action2.currentCastTime = targetCharacterInfo.CharacterAction2CurrentCastTime
		if is_instance_valid(targetCharacterInstance.action3):
			targetCharacterInstance.action3.currentCastTime = targetCharacterInfo.CharacterAction3CurrentCastTime
		if is_instance_valid(targetCharacterInstance.action4):
			targetCharacterInstance.action4.currentCastTime = targetCharacterInfo.CharacterAction4CurrentCastTime
		
		targetCharacterInstance.stats.setCurrentHealth(targetCharacterInfo.CharacterCurrentHealth)
		targetCharacterInstance.stats.setCurrentDefense(targetCharacterInfo.CharacterCurrentDefense)
		targetCharacterInstance.stats.setCurrentAttack(targetCharacterInfo.CharacterCurrentAttack)
		targetCharacterInstance.stats.setCurrentMorale(targetCharacterInfo.CharacterCurrentMorale)
		
		# Make sure to do make true -> character.isFriendly
		
	for i in savedEnemyCharactersList.size():
		var targetCharacterInfo: Dictionary = savedEnemyCharactersList.pop_back()
		
		var loadCharacter := load(targetCharacterInfo.CharacterFilePath)
		targetCharacterInstance = loadCharacter.instantiate()
		
		enemyPartyContainer.addCharacter(targetCharacterInstance, targetCharacterInfo.CharacterExperience, false, targetCharacterInfo.CharacterPosition)
		
		if is_instance_valid(targetCharacterInstance.action1):
			targetCharacterInstance.action1.currentCastTime = targetCharacterInfo.CharacterAction1CurrentCastTime
		if is_instance_valid(targetCharacterInstance.action2):
			targetCharacterInstance.action2.currentCastTime = targetCharacterInfo.CharacterAction2CurrentCastTime
		if is_instance_valid(targetCharacterInstance.action3):
			targetCharacterInstance.action3.currentCastTime = targetCharacterInfo.CharacterAction3CurrentCastTime
		if is_instance_valid(targetCharacterInstance.action4):
			targetCharacterInstance.action4.currentCastTime = targetCharacterInfo.CharacterAction4CurrentCastTime
		
		targetCharacterInstance.stats.setCurrentHealth(targetCharacterInfo.CharacterCurrentHealth)
		targetCharacterInstance.stats.setCurrentDefense(targetCharacterInfo.CharacterCurrentDefense)
		targetCharacterInstance.stats.setCurrentAttack(targetCharacterInfo.CharacterCurrentAttack)
		targetCharacterInstance.stats.setCurrentMorale(targetCharacterInfo.CharacterCurrentMorale)
	setIsCharactersActive(false)
	friendlyPartyContainer.getCharactersInfo()
	enemyPartyContainer.getCharactersInfo()
	updateUpkeepList()

func loadItems() -> void:
	var savedInventory: Array = SaveSystem.GameInfoDict.Inventory
	
	for i in savedInventory.size():
		var targetItemInfo: Dictionary = savedInventory.pop_back()
		var loadedItem := load(targetItemInfo.ItemPathName)
		#var instanceItem: BaseInventoryItem = instance_from_id(targetItemInfo.ItemPathName.object_id)
		print(targetItemInfo)
		inventory.addToInventory(loadedItem, targetItemInfo.ItemAmount)

func loadAOE() -> void:
	#var savedAOEList: Array = SaveSystem.GameInfoDict.AOEList
	var savedSupportAOEList: Array = SaveSystem.GameInfoDict.SupportAOEList
	var savedOffensiveAOEList: Array = SaveSystem.GameInfoDict.OffensiveAOEList
	
	print("support aoe list size " + str(savedSupportAOEList.size()))
	for i in savedSupportAOEList.size():
		var targetAOEInfo: Dictionary = savedSupportAOEList.pop_back()
		
		var loadedAOE := load(targetAOEInfo.AOEFilePath)
		var targetAOEInstance: BaseAOE = loadedAOE.instantiate()
		friendlyAOESupport.add_child(targetAOEInstance)
		
		targetAOEInstance.AOEName = targetAOEInfo.AOEName
		targetAOEInstance.mainColor = targetAOEInfo.AOEColor
		targetAOEInstance.get_node("MeshInstance2D").modulate = targetAOEInfo.AOEColor
		print("loaded color: " + str(targetAOEInstance.get_node("MeshInstance2D").modulate))
		print("(check) loaded owner character pfp: " + str(targetAOEInfo.AOEOwnerCharacterPFP))
		targetAOEInstance.ownerCharacterPFP = load(targetAOEInfo.AOEOwnerCharacterPFP)
		print("(check) owner character pfp: " + str(targetAOEInstance.ownerCharacterPFP))
		targetAOEInstance.ownerCharacterName = targetAOEInfo.AOEOwnerName
		targetAOEInstance.spriteAnimations.flip_h = targetAOEInfo.AOEIsSpriteFlipped
		targetAOEInstance.ownerActionDescription = targetAOEInfo.AOEDescription
		targetAOEInstance.global_position = targetAOEInfo.AOEPosition
		targetAOEInstance.isDynamicColor = targetAOEInfo.AOEIsDynamicColor
		print(targetAOEInstance.AOEName + ": (dup) loaded DyanmicColor: " + str(targetAOEInstance.isDynamicColor))
		targetAOEInstance.draggable = targetAOEInfo.AOEIsDraggable
		targetAOEInstance.statusActive = targetAOEInfo.AOEStatusActive
		targetAOEInstance.isMelee = targetAOEInfo.AOEIsMelee
		targetAOEInstance.accuracy = targetAOEInfo.AOEAccuracy
		targetAOEInstance.health = targetAOEInfo.AOEHealthDamage
		targetAOEInstance.defense = targetAOEInfo.AOEDefenseDamage
		targetAOEInstance.attack = targetAOEInfo.AOEAttackDamage
		targetAOEInstance.morale = targetAOEInfo.AOEMoraleDamage
		targetAOEInstance.experience = targetAOEInfo.AOEExperienceGain
		
	for i in savedOffensiveAOEList.size():
		var targetAOEInfo: Dictionary = savedOffensiveAOEList.pop_back()
		
		var loadedAOE := load(targetAOEInfo.AOEFilePath)
		var targetAOEInstance: BaseAOE = loadedAOE.instantiate()
		friendlyAOEAttack.add_child(targetAOEInstance)
		
		targetAOEInstance.AOEName = targetAOEInfo.AOEName
		targetAOEInstance.mainColor = targetAOEInfo.AOEColor
		targetAOEInstance.get_node("MeshInstance2D").modulate = targetAOEInfo.AOEColor
		targetAOEInstance.ownerCharacterPFP = load(targetAOEInfo.AOEOwnerCharacterPFP)
		targetAOEInstance.ownerCharacterName = targetAOEInfo.AOEOwnerName
		targetAOEInstance.spriteAnimations.flip_h = targetAOEInfo.AOEIsSpriteFlipped
		targetAOEInstance.ownerActionDescription = targetAOEInfo.AOEDescription
		targetAOEInstance.global_position = targetAOEInfo.AOEPosition
		targetAOEInstance.isDynamicColor = targetAOEInfo.AOEIsDynamicColor
		print(targetAOEInstance.AOEName + ": (dup) loaded DyanmicColor: " + str(targetAOEInstance.isDynamicColor))
		targetAOEInstance.draggable = targetAOEInfo.AOEIsDraggable
		targetAOEInstance.statusActive = targetAOEInfo.AOEStatusActive
		targetAOEInstance.isMelee = targetAOEInfo.AOEIsMelee
		targetAOEInstance.accuracy = targetAOEInfo.AOEAccuracy
		targetAOEInstance.health = targetAOEInfo.AOEHealthDamage
		targetAOEInstance.defense = targetAOEInfo.AOEDefenseDamage
		targetAOEInstance.attack = targetAOEInfo.AOEAttackDamage
		targetAOEInstance.morale = targetAOEInfo.AOEMoraleDamage
		targetAOEInstance.experience = targetAOEInfo.AOEExperienceGain
		await get_tree().create_timer(0.05).timeout
		targetAOEInstance.call_deferred("getItemsInside")
		await targetAOEInstance.gotItems
		targetAOEInstance.areaOverlapCharacter(false)

#-- Save

func saveToSaveSystem() -> bool: # We probably won't need this
	SaveWarningLabel.show()
	SaveSystem.clearSaveThroughEmptying()
	SaveSystem.clearSaveThroughDeletion()
	# Peak Total Stats have to be broken due to how we do what we're doing up top
	await get_tree().create_timer(0.05).timeout
	
	if peakTotalStatPoints < friendlyPartyContainer.totalStatPoints: # Peak Total Stats keep resetting to 0?
		print("------------")
		print("New Peak Score")
		print("Peak Total Stat Local Points: " + str(peakTotalStatPoints))
		print("Peak Total Stat Saved Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
		print("Total Stat Points: " + str(friendlyPartyContainer.totalStatPoints))
		SaveSystem.GameInfoDict.PeakTotalStatPoints = friendlyPartyContainer.totalStatPoints
		peakTotalStatPoints = SaveSystem.GameInfoDict.PeakTotalStatPoints
		print("New Peak Total Stat Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
	else:
		SaveSystem.GameInfoDict.PeakTotalStatPoints = peakTotalStatPoints
		print("------------")
		print("Not Peak Score")
		print("Peak Total Stat Local Points: " + str(peakTotalStatPoints))
		print("Peak Total Stat Saved Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
	SaveSystem.GameInfoDict.CharactersDied = totalCharactersDied
	SaveSystem.GameInfoDict.CharactersSurrendered = totalCharactersSurrendered
	SaveSystem.GameInfoDict.Battles = system.battle
	SaveSystem.GameInfoDict.Turns = system.turn
	
	if Global.getBattlesWon() < system.battle:
		Global.progressionDict.BattlesWon = system.battle
	
	saveFriendlyCharacters()
	saveEnemyCharacters()
	saveItems()
	saveAOE()
	Global.call_deferred("saveAllData")
	SaveSystem.call_deferred("saveAllData")
	@warning_ignore("redundant_await")
	var gameSaveConfirmed = await SaveSystem.saveAllData()
	print("GameInfoDict PeakTotalStatPoints: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
	await get_tree().create_timer(0.05).timeout
	print("GameInfoDict CharactersDied: " + str(SaveSystem.GameInfoDict.CharactersDied))
	await get_tree().create_timer(0.05).timeout
	print("GameInfoDict CharactersSurrendered: " + str(SaveSystem.GameInfoDict.CharactersSurrendered))
	await get_tree().create_timer(0.05).timeout
	print("GameInfoDict Battles: " + str(SaveSystem.GameInfoDict.Battles))
	await get_tree().create_timer(0.05).timeout
	print("GameInfoDict Turns: " + str(SaveSystem.GameInfoDict.Turns))
	await get_tree().create_timer(0.05).timeout
	print("GameInfoDict FriendlyCharactersList: " + str(SaveSystem.GameInfoDict.FriendlyCharactersList))
	await get_tree().create_timer(0.05).timeout
	print("GameInfoDict EnemyCharactersList: " + str(SaveSystem.GameInfoDict.EnemyCharactersList))
	await get_tree().create_timer(0.05).timeout
	print("GameInfoDict Inventory: " + str(SaveSystem.GameInfoDict.Inventory))
	await get_tree().create_timer(0.05).timeout
	print("Saved GameInfoDict SupportAOEList: " + str(SaveSystem.GameInfoDict.SupportAOEList))
	if gameSaveConfirmed:
		SaveWarningLabel.hide()
	return true
	

func saveFriendlyCharacters() -> void:
	friendlyPartyContainer.getCharactersInfo()
	
	# push_back to friendly characters
	for i in friendlyPartyContainer.characters.size():
		var newSavedCharacterData: Dictionary = SaveSystem.CharacterInfoDict.duplicate(true)
		if is_instance_valid(friendlyPartyContainer.characters[i]):
			newSavedCharacterData.CharacterFilePath = friendlyPartyContainer.characters[i].scene_file_path
			newSavedCharacterData.CharacterPosition = friendlyPartyContainer.characters[i].trueGlobalPosition
			newSavedCharacterData.CharacterExperience = friendlyPartyContainer.characters[i].stats.totalExperience
			if is_instance_valid(friendlyPartyContainer.characters[i].action1):
				newSavedCharacterData.CharacterAction1CurrentCastTime = friendlyPartyContainer.characters[i].action1.currentCastTime
			if is_instance_valid(friendlyPartyContainer.characters[i].action2):
				newSavedCharacterData.CharacterAction2CurrentCastTime = friendlyPartyContainer.characters[i].action2.currentCastTime
			if is_instance_valid(friendlyPartyContainer.characters[i].action3):
				newSavedCharacterData.CharacterAction3CurrentCastTime = friendlyPartyContainer.characters[i].action3.currentCastTime
			if is_instance_valid(friendlyPartyContainer.characters[i].action4):
				newSavedCharacterData.CharacterAction4CurrentCastTime = friendlyPartyContainer.characters[i].action4.currentCastTime
			newSavedCharacterData.CharacterCurrentHealth = friendlyPartyContainer.characters[i].stats.currentHealth
			newSavedCharacterData.CharacterCurrentDefense = friendlyPartyContainer.characters[i].stats.currentDefense
			newSavedCharacterData.CharacterCurrentAttack = friendlyPartyContainer.characters[i].stats.currentAttack
			newSavedCharacterData.CharacterCurrentMorale = friendlyPartyContainer.characters[i].stats.currentMorale
			SaveSystem.GameInfoDict.FriendlyCharactersList.push_back(newSavedCharacterData)

func saveEnemyCharacters() -> void:
	enemyPartyContainer.getCharactersInfo()
	
	# push_back to Enemy characters
	for i in enemyPartyContainer.characters.size():
		var newSavedCharacterData: Dictionary = SaveSystem.CharacterInfoDict.duplicate(true)
		if is_instance_valid(enemyPartyContainer.characters[i]):
			newSavedCharacterData.CharacterFilePath = enemyPartyContainer.characters[i].scene_file_path
			newSavedCharacterData.CharacterPosition = enemyPartyContainer.characters[i].trueGlobalPosition
			newSavedCharacterData.CharacterExperience = enemyPartyContainer.characters[i].stats.totalExperience
			if is_instance_valid(enemyPartyContainer.characters[i].action1):
				newSavedCharacterData.CharacterAction1CurrentCastTime = enemyPartyContainer.characters[i].action1.currentCastTime
			if is_instance_valid(enemyPartyContainer.characters[i].action2):
				newSavedCharacterData.CharacterAction2CurrentCastTime = enemyPartyContainer.characters[i].action2.currentCastTime
			if is_instance_valid(enemyPartyContainer.characters[i].action3):
				newSavedCharacterData.CharacterAction3CurrentCastTime = enemyPartyContainer.characters[i].action3.currentCastTime
			if is_instance_valid(enemyPartyContainer.characters[i].action4):
				newSavedCharacterData.CharacterAction4CurrentCastTime = enemyPartyContainer.characters[i].action4.currentCastTime
			newSavedCharacterData.CharacterCurrentHealth = enemyPartyContainer.characters[i].stats.currentHealth
			newSavedCharacterData.CharacterCurrentDefense = enemyPartyContainer.characters[i].stats.currentDefense
			newSavedCharacterData.CharacterCurrentAttack = enemyPartyContainer.characters[i].stats.currentAttack
			newSavedCharacterData.CharacterCurrentMorale = enemyPartyContainer.characters[i].stats.currentMorale
			SaveSystem.GameInfoDict.EnemyCharactersList.push_back(newSavedCharacterData)

func saveItems() -> void:
	for i in inventory.storedItems.size():
		var newSavedItemData: Dictionary = SaveSystem.ItemInfoDict.duplicate(true)
		newSavedItemData.ItemPathName = inventory.storedItems[i].globalFilePath
		newSavedItemData.ItemAmount = inventory.storedItems[i].amount
		SaveSystem.GameInfoDict.Inventory.push_back(newSavedItemData)

func saveAOE() -> void:
	var allSupportAOEList: Array = friendlyAOESupport.get_children() + enemySupportAOE.get_children()
	var allOffensiveAOEList: Array = friendlyAOEAttack.get_children() + enemyAttackAOE.get_children()
	
	for i in allSupportAOEList.size():
		var newSavedAOEData = SaveSystem.AOEInfoDict.duplicate(true)
		newSavedAOEData.AOEFilePath = allSupportAOEList[i].scene_file_path
		newSavedAOEData.AOEName = allSupportAOEList[i].AOEName
		newSavedAOEData.AOEColor = allSupportAOEList[i].mainColor
		print("saved color: " + str(allSupportAOEList[i].get_node("MeshInstance2D").modulate))
		print("(check) current owner character pfp: " + str(allSupportAOEList[i].ownerCharacterPFP.resource_path))
		newSavedAOEData.AOEOwnerCharacterPFP = allSupportAOEList[i].ownerCharacterPFP.resource_path
		print("(check) saved owner character pfp: " + str(newSavedAOEData.AOEOwnerCharacterPFP))
		newSavedAOEData.AOEOwnerName = allSupportAOEList[i].ownerCharacterName
		newSavedAOEData.AOEIsSpriteFlipped = allSupportAOEList[i].spriteAnimations.flip_h
		newSavedAOEData.AOEDescription = allSupportAOEList[i].ownerActionDescription
		newSavedAOEData.AOEPosition = allSupportAOEList[i].global_position
		newSavedAOEData.AOEIsDynamicColor = allSupportAOEList[i].isDynamicColor
		print(allSupportAOEList[i].AOEName + ": (dup) saved DyanmicColor: " + str(allSupportAOEList[i].isDynamicColor))
		newSavedAOEData.AOEIsDraggable = allSupportAOEList[i].draggable
		newSavedAOEData.AOEStatusActive = allSupportAOEList[i].statusActive
		newSavedAOEData.AOEIsMelee = allSupportAOEList[i].isMelee
		newSavedAOEData.AOEAccuracy = allSupportAOEList[i].accuracy
		newSavedAOEData.AOEHealthDamage = allSupportAOEList[i].health
		newSavedAOEData.AOEDefenseDamage = allSupportAOEList[i].defense
		newSavedAOEData.AOEAttackDamage = allSupportAOEList[i].attack
		newSavedAOEData.AOEMoraleDamage = allSupportAOEList[i].morale
		newSavedAOEData.AOEExperienceGain = allSupportAOEList[i].experience
		SaveSystem.GameInfoDict.SupportAOEList.push_back(newSavedAOEData)
	
	
	for i in allOffensiveAOEList.size():
		var newSavedAOEData = SaveSystem.AOEInfoDict.duplicate(true)
		newSavedAOEData.AOEFilePath = allOffensiveAOEList[i].scene_file_path
		newSavedAOEData.AOEName = allOffensiveAOEList[i].AOEName
		newSavedAOEData.AOEColor = allOffensiveAOEList[i].mainColor
		newSavedAOEData.AOEOwnerCharacterPFP = allOffensiveAOEList[i].ownerCharacterPFP.resource_path
		newSavedAOEData.AOEOwnerName = allOffensiveAOEList[i].ownerCharacterName
		newSavedAOEData.AOEIsSpriteFlipped = allOffensiveAOEList[i].spriteAnimations.flip_h
		newSavedAOEData.AOEDescription = allOffensiveAOEList[i].ownerActionDescription
		newSavedAOEData.AOEPosition = allOffensiveAOEList[i].global_position
		newSavedAOEData.AOEIsDynamicColor = allOffensiveAOEList[i].isDynamicColor
		print(allOffensiveAOEList[i].AOEName + ": (dup) saved DyanmicColor: " + str(allOffensiveAOEList[i].isDynamicColor))
		newSavedAOEData.AOEIsDraggable = allOffensiveAOEList[i].draggable
		newSavedAOEData.AOEStatusActive = allOffensiveAOEList[i].statusActive
		newSavedAOEData.AOEIsMelee = allOffensiveAOEList[i].isMelee
		newSavedAOEData.AOEAccuracy = allOffensiveAOEList[i].accuracy
		newSavedAOEData.AOEHealthDamage = allOffensiveAOEList[i].health
		newSavedAOEData.AOEDefenseDamage = allOffensiveAOEList[i].defense
		newSavedAOEData.AOEAttackDamage = allOffensiveAOEList[i].attack
		newSavedAOEData.AOEMoraleDamage = allOffensiveAOEList[i].morale
		newSavedAOEData.AOEExperienceGain = allOffensiveAOEList[i].experience
		SaveSystem.GameInfoDict.OffensiveAOEList.push_back(newSavedAOEData)

func setDisabledAllAOE(boolean: bool) -> void:
	for i in grabAllAOE().size():
		print("Button is " + str(grabAllAOE()[i].button))
		grabAllAOE()[i].button.visible = boolean

func goThroughQueuedAOEArray() -> void:
	var currentBattle: int = system.battle
	
	queuedAOE = grabAllAOE()
	print(str(self) + ": allAOE: " + str(queuedAOE))
	stopControl.visible = true
	setIsCharactersActive(true)
	
	while queuedAOE.size() != 0:
			await get_tree().create_timer(0.25).timeout
			var Ltarget = queuedAOE.pop_back()
			var targetAOE: BaseAOE
			
			if currentBattle != system.battle:
				queuedAOE.clear()
				break
			
			if is_instance_valid(Ltarget):
				targetAOE = Ltarget
				print(str(self) + ": targetAOE: " + str(targetAOE))
				targetAOE.InTurn()
				
	# Spawn Our Friendly AOE Here
	print("AOEQueueFinished")
	print("--------------------------------")
	emit_signal("AOEQueueFinished")
	updateValueOfStatusBar()
	await get_tree().create_timer(1).timeout
	setIsCharactersActive(false)
	stopControl.visible = true
	var isSavingDone: bool = await saveToSaveSystem()
	if isSavingDone:
		stopControl.visible = false
		musicPlayer.updateDangerLevel()
		if system.battle >= 2:
			if randi_range(0, 8) == 0:
				stopControl.visible = true
				await get_tree().create_timer(1.5).timeout
				GotoShop()
	
	updateUpkeepList()

func grabAllAOE() -> Array:
	var AOEGrabbed: Array = friendlyAOEAttack.get_children() + enemyAttackAOE.get_children() + friendlyAOESupport.get_children() + enemySupportAOE.get_children()
	return AOEGrabbed

func setIsCharactersActive(boolean: bool) -> void:
	isCharactersActive = boolean

func getTurn() -> void:
	print(str(self) + ": Turns: " + str(system.battle))
	turnsLabel.set_text("Turns: " + str(system.turn))
	print(str(difficulty.isCharactersSpawningIn))
	goThroughQueuedAOEArray()

func getBattle() -> void:
	print(str(self) + ": Battles: " + str(system.battle))
	battlesLabel.set_text("Battles: " + str(system.battle))

func _on_turn_system_on_new_turn() -> void:
	getTurn()
	getBattle()

func GotoShop() -> void:
	print("Go to shop!")
	stopControl2.show()
	var instance := shopWindow.instantiate()
	add_child(instance)
	instance.dungeon = self
	instance.z_index = 2
	
	@warning_ignore("integer_division")
	instance.set_global_position(Vector2(DisplayServer.screen_get_size().x / 2, DisplayServer.screen_get_size().y / 2))


func spawnSurrenderWindow(Lcharacter: BaseCharacter, profilePicture: Texture2D, characterName: String, experience: float) -> void:
	print(str(self) + ": Spawning Surrender Window")
	print(str(self) + ": scene file path 2: " + str(Lcharacter))
	stopControl2.show()
	var instance := surrenderWindow.instantiate()
	add_child(instance)
	instance.character = Lcharacter
	instance.characterPFP = profilePicture
	instance.characterName = characterName
	instance.totalExperience = experience
	instance.setWindowInfo()
	instance.set_global_position(Vector2(0, 0))

func _on_spawn_friendly_healer_pressed() -> void:
	var instance = healer.instantiate()
	friendlyPartyContainer.addCharacter(instance, 0.0, false, Vector2(0, 0))

func _on_spawn_friendly_tank_pressed() -> void:
	var instance = tank.instantiate()
	friendlyPartyContainer.addCharacter(instance, 0.0, false, Vector2(0, 0))

func _on_spawn_friend_ranged_pressed() -> void:
	var instance = DPSRanged.instantiate()
	friendlyPartyContainer.addCharacter(instance, 0.0, false, Vector2(0, 0))

func _on_spawn_friend_melee_pressed() -> void:
	var instance = DPSMelee.instantiate()
	friendlyPartyContainer.addCharacter(instance, 0.0, false, Vector2(0, 0))

func _on_spawn_enemy_healer_pressed() -> void:
	var instance = healer.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0, false, Vector2(0, 0))

func _on_spawn_enemy_tank_pressed() -> void:
	var instance = tank.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0, false, Vector2(0, 0))

func _on_spawn_enemy_ranged_pressed() -> void:
	var instance = DPSRanged.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0, false, Vector2(0, 0))

func _on_spawn_enemy_melee_pressed() -> void:
	var instance = DPSMelee.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0, false, Vector2(0, 0))


func _on_get_attack_aoe_container_nodes_pressed() -> void:
	print("All Attack AOE: " + str($EnemyAOEContainerAttack.get_children() + $AOESpawnAreaAttack.get_children()))


func _on_get_support_aoe_container_nodes_pressed() -> void:
	print("All Support AOE: " + str($EnemyAOEContainerSupport.get_children() + $AOESpawnAreaSupport.get_children()))


func _on_get_enemy_container_nodes_pressed() -> void:
	print("All Enemies: " + str($EnemyPartyContainer.get_children()))


func _on_get_friendly_container_nodes_pressed() -> void:
	print("All Friendly: " + str($FriendlyPartyContainer.get_children()))

func _on_show_inventory_button_pressed() -> void:
	stopControl.show()
	inventoryUI.updateInventoryItemList()
	inventoryUI.show()

func _on_show_party_button_pressed() -> void:
	stopControl.show()
	partyUI.updateCharacterList()
	partyUI.show()


func _on_show_menu_button_pressed() -> void:
	stopControl.show()
	ingameUI.show()
