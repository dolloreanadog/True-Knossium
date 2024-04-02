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
	if SaveSystem.checkSaveFileExists():
		loadSave()
	else:
		system.newTurn()
		system.newBattle()
		
		addNewGameCharacters()
		addNewGameItems()
	
	await get_tree().create_timer(2).timeout
	$SaveWarningLabel.hide()


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
		print("Target Item (check2) " + targetItem.itemName)
		print("Target Item Amount (check2): " + str(targetItem.amount))
		inventory.addToInventory(targetItem, targetItem.amount)
		#inventory.storedItems.push_back(targetItem)

#--[ Save System ]--

#-- Load
func loadSave() -> void:
	SaveSystem.loadAllData()
	
	peakTotalStatPoints = SaveSystem.GameInfoDict.PeakTotalStatPoints
	totalCharactersDied = SaveSystem.GameInfoDict.CharactersDied
	totalCharactersSurrendered = SaveSystem.GameInfoDict.CharactersSurrendered
	
	loadCharacters()
	loadItems()
	loadAOE()
	print("(check3) GameInfoDict PeakTotalStatPoints: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
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
	print("GameInfoDict AOEList: " + str(SaveSystem.GameInfoDict.AOEList))

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

func loadItems() -> void:
	var savedInventory: Array = SaveSystem.GameInfoDict.Inventory
	
	for i in savedInventory.size():
		var targetItemInfo: Dictionary = savedInventory.pop_back()
		var loadedItem := load(targetItemInfo.ItemPathName)
		#var instanceItem: BaseInventoryItem = instance_from_id(targetItemInfo.ItemPathName.object_id)
		print(targetItemInfo)
		inventory.addToInventory(loadedItem, targetItemInfo.ItemAmount)

func loadAOE() -> void:
	var savedAOEList: Array = SaveSystem.GameInfoDict.AOEList
	
	for i in savedAOEList.size():
		var targetAOEInfo: Dictionary = savedAOEList.pop_back()
		
		var loadedAOE := load(targetAOEInfo.AOEFilePath)
		var targetAOEInstance: BaseAOE = loadedAOE.instantiate()
		friendlyAOEAttack.add_child(targetAOEInstance)
		
		targetAOEInstance.AOEName = targetAOEInfo.AOEName
		targetAOEInstance.mainColor = targetAOEInfo.AOEColor
		targetAOEInstance.get_node("MeshInstance2D").modulate = targetAOEInfo.AOEColor
		targetAOEInstance.ownerCharacterPFP = targetAOEInfo.AOEOwnerCharacterPFP
		targetAOEInstance.ownerCharacterName = targetAOEInfo.AOEOwnerName
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

#-- Save

func saveToSaveSystem() -> void: # We probably won't need this
	$SaveWarningLabel.show()
	SaveSystem.clearSaveThroughEmptying()
	SaveSystem.clearSaveThroughDeletion()
	# Peak Total Stats have to be broken due to how we do what we're doing up top
	await get_tree().create_timer(0.05).timeout
	
	if peakTotalStatPoints < friendlyPartyContainer.totalStatPoints: # Peak Total Stats keep resetting to 0?
		print("(check3) ------------")
		print("(check3) New Peak Score")
		print("(check3) Peak Total Stat Local Points: " + str(peakTotalStatPoints))
		print("(check3) Peak Total Stat Saved Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
		print("(check3) Total Stat Points: " + str(friendlyPartyContainer.totalStatPoints))
		SaveSystem.GameInfoDict.PeakTotalStatPoints = friendlyPartyContainer.totalStatPoints
		peakTotalStatPoints = SaveSystem.GameInfoDict.PeakTotalStatPoints
		print("(check3) New Peak Total Stat Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
	else:
		SaveSystem.GameInfoDict.PeakTotalStatPoints = peakTotalStatPoints
		print("(check3) ------------")
		print("(check3) Not Peak Score")
		print("(check3) Peak Total Stat Local Points: " + str(peakTotalStatPoints))
		print("(check3) Peak Total Stat Saved Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
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
	Global.saveAllData()
	SaveSystem.saveAllData()
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
	print("GameInfoDict AOEList: " + str(SaveSystem.GameInfoDict.AOEList))
	await SaveSystem.Saved
	$SaveWarningLabel.hide()
	

func saveFriendlyCharacters() -> void:
	
	# push_back to friendly characters
	for i in friendlyPartyContainer.characters.size():
		var newSavedCharacterData: Dictionary = SaveSystem.CharacterInfoDict.duplicate(true)
		newSavedCharacterData.CharacterFilePath = friendlyPartyContainer.characters[i].scene_file_path
		newSavedCharacterData.CharacterPosition = friendlyPartyContainer.characters[i].global_position
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
	
	# push_back to Enemy characters
	for i in enemyPartyContainer.characters.size():
		var newSavedCharacterData: Dictionary = SaveSystem.CharacterInfoDict.duplicate(true)
		if is_instance_valid(enemyPartyContainer.characters[i]):
			newSavedCharacterData.CharacterFilePath = enemyPartyContainer.characters[i].scene_file_path
			newSavedCharacterData.CharacterPosition = enemyPartyContainer.characters[i].global_position
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
		newSavedItemData.ItemPathName = inventory.storedItems[i].resource_path
		newSavedItemData.ItemAmount = inventory.storedItems[i].amount
		SaveSystem.GameInfoDict.Inventory.push_back(newSavedItemData)

func saveAOE() -> void:
	var allAOEList: Array = grabAllAOE()
	
	for i in allAOEList.size():
		var newSavedAOEData = SaveSystem.AOEInfoDict.duplicate(true)
		newSavedAOEData.AOEFilePath = allAOEList[i].scene_file_path
		newSavedAOEData.AOEName = allAOEList[i].AOEName
		newSavedAOEData.AOEColor = allAOEList[i].mainColor
		newSavedAOEData.AOEOwnerCharacterPFP = allAOEList[i].ownerCharacterPFP
		newSavedAOEData.AOEOwnerName = allAOEList[i].ownerCharacterName
		newSavedAOEData.AOEDescription = allAOEList[i].ownerActionDescription
		newSavedAOEData.AOEPosition = allAOEList[i].global_position
		newSavedAOEData.AOEIsDynamicColor = allAOEList[i].isDynamicColor
		print(allAOEList[i].AOEName + ": (dup) saved DyanmicColor: " + str(allAOEList[i].isDynamicColor))
		newSavedAOEData.AOEIsDraggable = allAOEList[i].draggable
		newSavedAOEData.AOEStatusActive = allAOEList[i].statusActive
		newSavedAOEData.AOEIsMelee = allAOEList[i].isMelee
		newSavedAOEData.AOEAccuracy = allAOEList[i].accuracy
		newSavedAOEData.AOEHealthDamage = allAOEList[i].health
		newSavedAOEData.AOEDefenseDamage = allAOEList[i].defense
		newSavedAOEData.AOEAttackDamage = allAOEList[i].attack
		newSavedAOEData.AOEMoraleDamage = allAOEList[i].morale
		newSavedAOEData.AOEExperienceGain = allAOEList[i].experience
		SaveSystem.GameInfoDict.AOEList.push_back(newSavedAOEData)

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
	print("AOEQueueFinished (check)")
	print("(check) --------------------------------")
	emit_signal("AOEQueueFinished")
	await get_tree().create_timer(0.25).timeout
	setIsCharactersActive(false)
	$SaveWarningLabel.show()
	stopControl.visible = true
	await get_tree().create_timer(1).timeout
	stopControl.visible = true
	saveToSaveSystem() 
	stopControl.visible = false
	await get_tree().create_timer(0.25).timeout
	stopControl.visible = false

func grabAllAOE() -> Array:
	var AOEGrabbed: Array = friendlyAOEAttack.get_children() + enemyAttackAOE.get_children() + friendlyAOESupport.get_children() + enemySupportAOE.get_children()
	return AOEGrabbed

func setIsCharactersActive(boolean: bool) -> void:
	isCharactersActive = boolean

func getTurn() -> void:
	print(str(self) + ": Turns: " + str(system.battle))
	turnsLabel.set_text("Turns: " + str(system.turn))
	print("(check)" + str(difficulty.isCharactersSpawningIn))
	goThroughQueuedAOEArray()

func getBattle() -> void:
	print(str(self) + ": Battles: " + str(system.battle))
	battlesLabel.set_text("Battles: " + str(system.battle))

func _on_turn_system_on_new_turn() -> void:
	getTurn()
	getBattle()

func spawnSurrenderWindow(Lcharacter: BaseCharacter, profilePicture: Texture2D, characterName: String, experience: float) -> void:
	print(str(self) + ": Spawning Surrender Window")
	print(str(self) + ": scene file path 2: " + str(Lcharacter))
	var instance = surrenderWindow.instantiate()
	add_child(instance)
	instance.character = Lcharacter
	instance.characterPFP = profilePicture
	instance.characterName = characterName
	instance.totalExperience = experience
	instance.setWindowInfo()
	instance.set_global_position(Vector2(0, 0))
	#print("surren$Camera2DderWindow Spawned at " + str(instance.global_position))

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
