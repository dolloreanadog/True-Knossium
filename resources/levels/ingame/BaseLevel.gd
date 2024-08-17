extends Node2D
class_name BaseLevel

#--[ These are reference, will not be used ]--
var stats: StatComponent

#--[ Get Important Nodes ]--
@export_category("Important Nodes")
@onready var system: TurnSystem = get_node("TurnSystem")
@onready var difficulty: difficultySystem = get_node("difficultySystem")
@export var turnsLabel: Label
@export var battlesLabel: Label
@export var friendlyPartyContainer: BasePartyContainer
@export var enemyPartyContainer: BasePartyContainer
@export var battleStatusBar: BattleStatusBar
@export var stopControl: Control
@export var stopControl2: Control
@export var musicPlayer: DungeonMusicPlayer
@export var statButtonGroup: StatViewButtonGroup
@export var specialWindowContainer: Control
@export var knossiumConsole: KnossiumConsole
@export var AOECheckSupport: Area2D
@export var AOECheckOffense: Area2D

#---[ Some Important buttons ]---
@export_category("Important Buttons")
@export var endTurnButton: Button
@export var showMenuButton: Button
@export var autoPlaceButton: Button

@export var inventoryButton: Button
@export var partyButton: Button

#--[ Get all the AOEs]--
@export_category("AOE Containers")
@export var friendlyAOEAttack: BaseSpawnArea
@export var friendlyAOESupport: BaseSpawnArea
@export var enemyAttackAOE: EnemyAOEContainer
@export var enemySupportAOE: EnemyAOEContainer

#--[ For queue ]--
var queuedAOE: Array
var isCharactersActive: bool = true

#--[ Inventory ]--
@export_category("Inventory")
@onready var inventory: InventorySystem = get_node("InventorySystem")
@onready var upkeepInventory: InventorySystem = get_node("UpkeepInventorySystem")
@onready var inventoryUI: InventoryMenu = get_node("InventoryMenu")

#--[ Party Menu ]--
@export_category("User Interfaces")
@onready var partyUI: PartyMenu = get_node("PartyMenu")

@onready var ingameUI: IngameMenu = get_node("InGameMenu")

@onready var upkeepList: ItemList = get_node("UpkeepList")

var peakTotalStatPoints: int
var totalCharactersDied: int
var totalCharactersSurrendered: int

@export_category("Warning Labels")
@export var warningLabel: Label
@export var SaveWarningLabel: Label

#--[ Other ]--
var highlightEndTurn: bool
var shopWeight: float = 0.0

#--[ Surrender Window ]--
var surrenderWindow = preload("res://resources/entities/surrender_window/surrender_window.tscn")
var shopWindow = preload("res://resources/entities/shop_confirmation_window/ShopConfirmationWindow.tscn")
var nextAreaWindow = preload("res://resources/user_interface/choose_next_level_menu/ChoseNextLevelMenu.tscn")

#--[ Save/Load ]-- 
var saveCheck: int
var loadCheck: int

#--[ Signal ]--
signal AOEQueueFinished

# Save Signals
signal SaveFinished
signal SavedFriendlyCharacters
signal SavedEnemyCharacters
signal SavedItems
signal SavedAOE


# Load Signals
signal LoadFinished
signal LoadCharacters
signal LoadItems
signal LoadAOE


#--[ Functions ]--
func _ready():
	var confirmed: bool
	print("is stopControl Visible: " + str(stopControl.visible))
	print("is stopControl2 Visible: " + str(stopControl2.visible))
	Global.StartLoadingScreen(false)
	stopControlVisible(true, 1)
	if SaveSystem.checkSaveFileExists():
		loadSave()
		confirmed = await loadConfirmation()
	else:
		system.newTurn()
		system.newBattle()
		
		addNewGameCharacters()
		addNewGameItems()
		confirmed = true
		EndTurnButtonHighlight(true)
	
#	await loadConfirmation()
	if confirmed:
		updateValueOfStatusBar()
		Global.EndLoadingScreen()
		stopControlVisible(false, 1)
		checkSpecialWindowContainer()
		friendlyPartyContainer.onAllCharactersDead()
		SaveWarningLabel.hide()

func saveConfirmation() -> bool:
	await SaveFinished
	return true

func loadConfirmation() -> bool:
	await LoadFinished
	return true

func EndTurnButtonHighlight(boolean: bool) -> void:
	highlightEndTurn = boolean
	while highlightEndTurn:
		await create_tween().tween_property(endTurnButton, "modulate", Color(1, 0, 0), 1).finished
		await create_tween().tween_property(endTurnButton, "modulate", Color(1, 1, 1), 1).finished
		await get_tree().create_timer(2).timeout
	await create_tween().tween_property(endTurnButton, "modulate", Color(1, 1, 1), 1).finished

func AnyAOEStillLeft() -> bool:
	if AOECheckSupport.has_overlapping_areas() or AOECheckOffense.has_overlapping_areas():
		return true
	else:
		return false

# When user exits unintentionally
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
	elif what == NOTIFICATION_CRASH:
		assert(false, "About to Crash")
		get_tree().quit()

func updateValueOfStatusBar() -> void:
	friendlyPartyContainer.getCharactersInfo()
	enemyPartyContainer.getCharactersInfo()
	battleStatusBar.updateStatusBar(friendlyPartyContainer.currentTotalStatPoints, enemyPartyContainer.currentTotalStatPoints)
	

func stopControlVisible(visibility: bool, stopControlNumber: int):
	if stopControlNumber == 1:
		if visibility == true:
			stopControl.visible = true
			endTurnButton.disabled = true
			showMenuButton.disabled = true
			autoPlaceButton.disabled = true
		else:
			stopControl.visible = false
			endTurnButton.disabled = false
			showMenuButton.disabled = false
			autoPlaceButton.disabled = false
	elif stopControlNumber == 2:
		if visibility == true:
			stopControl2.visible = true
			endTurnButton.disabled = true
			showMenuButton.disabled = true
			autoPlaceButton.disabled = true
		else:
			stopControl2.visible = false
			endTurnButton.disabled = false
			showMenuButton.disabled = false
			autoPlaceButton.disabled = false

#--[ Upkeep List ]--
func updateUpkeepList() -> void:
	print("update upkeep list")
	friendlyPartyContainer.getCharactersInfo()
	
#	print("characters: " + str(friendlyPartyContainer.characters))
	upkeepInventory.storedItems.clear()
	for i in friendlyPartyContainer.characters.size():
		var character: BaseCharacter = friendlyPartyContainer.characters[i]
		
		upkeepInventory.addToInventory(character.ResourceNeeded.duplicate(true), character.ResourceNeededNumber)
	
	
	upkeepList.clear()
	for i in upkeepInventory.storedItems.size():
		var Litem: BaseInventoryItem = upkeepInventory.storedItems[i]
		upkeepList.add_item(Litem.itemName + "  x" + str(Litem.amount), Litem.image)
		upkeepList.set_item_tooltip(i, Litem.itemDesciption)



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
		await get_tree().create_timer(0.01).timeout
	
	await get_tree().create_timer(0.01).timeout
	LoadItems.emit()

#--[ Save System ]--

#-- Load
func loadSave() -> void:
	SaveSystem.loadAllData()
	
	peakTotalStatPoints = SaveSystem.GameInfoDict.PeakTotalStatPoints
	totalCharactersDied = SaveSystem.GameInfoDict.CharactersDied
	totalCharactersSurrendered = SaveSystem.GameInfoDict.CharactersSurrendered
	system.battle = SaveSystem.GameInfoDict.Battles
	system.turn = SaveSystem.GameInfoDict.Turns
	difficulty.SpawnBehaviors = SaveSystem.GameInfoDict.SpawnBehaviorWeights
	knossiumConsole.unlocked = SaveSystem.GameInfoDict.ConsoleUnlocked
	print("Loaded Spawn Behavior Weights: " + str(difficulty.SpawnBehaviors))
	
	loadCharacters()
	await LoadCharacters
	loadAOE()
	await LoadAOE
#	call_deferred("loadCharacters")
	if Global.newGameInventoryInfo.is_empty():
		call_deferred("loadItems")
	else:
		addNewGameItems()
	await LoadItems
#	call_deferred("loadAOE")
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
	print("Loaded GameInfoDict OffensiveAOEList: " + str(SaveSystem.GameInfoDict.EnemyOffensiveAOEList))
	print("Loaded GameInfoDict SupportAOEList: " + str(SaveSystem.GameInfoDict.FriendlyOffensiveAOEList))
	friendlyPartyContainer.getCharactersInfo()
	turnsLabel.set_text("Turns: " + str(system.turn))
	getBattle()
	emit_signal("LoadFinished")

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
		
		targetCharacterInstance.characterName = targetCharacterInfo.CharacterName
		targetCharacterInstance.stats.setCurrentHealth(targetCharacterInfo.CharacterCurrentHealth)
		targetCharacterInstance.stats.setCurrentDefense(targetCharacterInfo.CharacterCurrentDefense)
		targetCharacterInstance.stats.setCurrentAttack(targetCharacterInfo.CharacterCurrentAttack)
		targetCharacterInstance.stats.setCurrentMorale(targetCharacterInfo.CharacterCurrentMorale)
		
		await get_tree().create_timer(0.01).timeout
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
		
		targetCharacterInstance.characterName = targetCharacterInfo.CharacterName
		targetCharacterInstance.stats.setCurrentHealth(targetCharacterInfo.CharacterCurrentHealth)
		targetCharacterInstance.stats.setCurrentDefense(targetCharacterInfo.CharacterCurrentDefense)
		targetCharacterInstance.stats.setCurrentAttack(targetCharacterInfo.CharacterCurrentAttack)
		targetCharacterInstance.stats.setCurrentMorale(targetCharacterInfo.CharacterCurrentMorale)
		
		await get_tree().create_timer(0.01).timeout
	
	setIsCharactersActive(false)
	friendlyPartyContainer.getCharactersInfo()
	enemyPartyContainer.getCharactersInfo()
	partyUI.updateUpkeepList()
	await get_tree().create_timer(0.01).timeout
	LoadCharacters.emit()

func loadItems() -> void:
	var savedInventory: Array = SaveSystem.GameInfoDict.Inventory
	
	for i in savedInventory.size():
		var targetItemInfo: Dictionary = savedInventory.pop_back()
		var loadedItem := load(targetItemInfo.ItemPathName)
		#var instanceItem: BaseInventoryItem = instance_from_id(targetItemInfo.ItemPathName.object_id)
		print(targetItemInfo)
		inventory.addToInventory(loadedItem, targetItemInfo.ItemAmount)
		await get_tree().create_timer(0.01).timeout
	
	await get_tree().create_timer(0.01).timeout
	LoadItems.emit()

func loadAOE() -> void:
	#var savedAOEList: Array = SaveSystem.GameInfoDict.AOEList
#	var savedSupportAOEList: Array = SaveSystem.GameInfoDict.SupportAOEList
#	var savedOffensiveAOEList: Array = SaveSystem.GameInfoDict.OffensiveAOEList
	
	var savedFriendlySupportAOEList: Array = SaveSystem.GameInfoDict.FriendlySupportAOEList
	var savedEnemySupportAOEList: Array = SaveSystem.GameInfoDict.EnemySupportAOEList
	var savedFriendlyOffensiveAOEList: Array = SaveSystem.GameInfoDict.FriendlyOffensiveAOEList
	var savedEnemyOffensiveAOEList: Array = SaveSystem.GameInfoDict.EnemyOffensiveAOEList
	
#	print("support aoe list size " + str(savedSupportAOEList.size()))
	for i in savedFriendlySupportAOEList.size():
		var targetAOEInfo: Dictionary = savedFriendlySupportAOEList.pop_back()
		
		var loadedAOE := load(targetAOEInfo.AOEFilePath)
		var targetAOEInstance: BaseAOE = loadedAOE.instantiate()
		friendlyAOESupport.add_child(targetAOEInstance)
		
		targetAOEInstance.AOEName = targetAOEInfo.AOEName
		targetAOEInstance.mainColor = targetAOEInfo.AOEColor
		targetAOEInstance.get_node("MeshInstance2D").modulate = targetAOEInfo.AOEColor
#		print("loaded color: " + str(targetAOEInstance.get_node("MeshInstance2D").modulate))
#		print("(check) loaded owner character pfp: " + str(targetAOEInfo.AOEOwnerCharacterPFP))
		targetAOEInstance.ownerCharacterPFP = load(targetAOEInfo.AOEOwnerCharacterPFP)
#		print("(check) owner character pfp: " + str(targetAOEInstance.ownerCharacterPFP))
		targetAOEInstance.ownerCharacterName = targetAOEInfo.AOEOwnerName
		targetAOEInstance.spriteAnimations.flip_h = targetAOEInfo.AOEIsSpriteFlipped
		targetAOEInstance.ownerActionDescription = targetAOEInfo.AOEDescription
		targetAOEInstance.global_position = targetAOEInfo.AOEPosition
		targetAOEInstance.isDynamicColor = targetAOEInfo.AOEIsDynamicColor
#		print(targetAOEInstance.AOEName + ": (dup) loaded DyanmicColor: " + str(targetAOEInstance.isDynamicColor))
		targetAOEInstance.draggable = targetAOEInfo.AOEIsDraggable
		targetAOEInstance.statusActive = targetAOEInfo.AOEStatusActive
		targetAOEInstance.isMelee = targetAOEInfo.AOEIsMelee
		targetAOEInstance.accuracy = targetAOEInfo.AOEAccuracy
		targetAOEInstance.health = targetAOEInfo.AOEHealthDamage
		targetAOEInstance.defense = targetAOEInfo.AOEDefenseDamage
		targetAOEInstance.attack = targetAOEInfo.AOEAttackDamage
		targetAOEInstance.morale = targetAOEInfo.AOEMoraleDamage
		targetAOEInstance.experience = targetAOEInfo.AOEExperienceGain
		await get_tree().create_timer(0.01).timeout
	
	for i in savedEnemySupportAOEList.size():
		var targetAOEInfo: Dictionary = savedEnemySupportAOEList.pop_back()
		
		var loadedAOE := load(targetAOEInfo.AOEFilePath)
		var targetAOEInstance: BaseAOE = loadedAOE.instantiate()
		enemySupportAOE.add_child(targetAOEInstance)
		
		targetAOEInstance.AOEName = targetAOEInfo.AOEName
		targetAOEInstance.mainColor = targetAOEInfo.AOEColor
		targetAOEInstance.get_node("MeshInstance2D").modulate = targetAOEInfo.AOEColor
#		print("loaded color: " + str(targetAOEInstance.get_node("MeshInstance2D").modulate))
#		print("(check) loaded owner character pfp: " + str(targetAOEInfo.AOEOwnerCharacterPFP))
		targetAOEInstance.ownerCharacterPFP = load(targetAOEInfo.AOEOwnerCharacterPFP)
#		print("(check) owner character pfp: " + str(targetAOEInstance.ownerCharacterPFP))
		targetAOEInstance.ownerCharacterName = targetAOEInfo.AOEOwnerName
		targetAOEInstance.spriteAnimations.flip_h = targetAOEInfo.AOEIsSpriteFlipped
		targetAOEInstance.ownerActionDescription = targetAOEInfo.AOEDescription
		targetAOEInstance.global_position = targetAOEInfo.AOEPosition
		targetAOEInstance.isDynamicColor = targetAOEInfo.AOEIsDynamicColor
#		print(targetAOEInstance.AOEName + ": (dup) loaded DyanmicColor: " + str(targetAOEInstance.isDynamicColor))
		targetAOEInstance.draggable = targetAOEInfo.AOEIsDraggable
		targetAOEInstance.statusActive = targetAOEInfo.AOEStatusActive
		targetAOEInstance.isMelee = targetAOEInfo.AOEIsMelee
		targetAOEInstance.accuracy = targetAOEInfo.AOEAccuracy
		targetAOEInstance.health = targetAOEInfo.AOEHealthDamage
		targetAOEInstance.defense = targetAOEInfo.AOEDefenseDamage
		targetAOEInstance.attack = targetAOEInfo.AOEAttackDamage
		targetAOEInstance.morale = targetAOEInfo.AOEMoraleDamage
		targetAOEInstance.experience = targetAOEInfo.AOEExperienceGain
		await get_tree().create_timer(0.01).timeout
	
	for i in savedFriendlyOffensiveAOEList.size():
		var targetAOEInfo: Dictionary = savedFriendlyOffensiveAOEList.pop_back()
		
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
#		print(targetAOEInstance.AOEName + ": (dup) loaded DyanmicColor: " + str(targetAOEInstance.isDynamicColor))
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
#		targetAOEInstance.call_deferred("getItemsInside")
		await targetAOEInstance.getItemsInside()
#		await targetAOEInstance.gotItems
		targetAOEInstance.areaOverlapCharacter(false)
		await get_tree().create_timer(0.01).timeout
	
	for i in savedEnemyOffensiveAOEList.size():
		var targetAOEInfo: Dictionary = savedEnemyOffensiveAOEList.pop_back()
		
		var loadedAOE := load(targetAOEInfo.AOEFilePath)
		var targetAOEInstance: BaseAOE = loadedAOE.instantiate()
		enemyAttackAOE.add_child(targetAOEInstance)
		
		targetAOEInstance.AOEName = targetAOEInfo.AOEName
		targetAOEInstance.mainColor = targetAOEInfo.AOEColor
		targetAOEInstance.get_node("MeshInstance2D").modulate = targetAOEInfo.AOEColor
		targetAOEInstance.ownerCharacterPFP = load(targetAOEInfo.AOEOwnerCharacterPFP)
		targetAOEInstance.ownerCharacterName = targetAOEInfo.AOEOwnerName
		targetAOEInstance.spriteAnimations.flip_h = targetAOEInfo.AOEIsSpriteFlipped
		targetAOEInstance.ownerActionDescription = targetAOEInfo.AOEDescription
		targetAOEInstance.global_position = targetAOEInfo.AOEPosition
		targetAOEInstance.isDynamicColor = targetAOEInfo.AOEIsDynamicColor
#		print(targetAOEInstance.AOEName + ": (dup) loaded DyanmicColor: " + str(targetAOEInstance.isDynamicColor))
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
#		targetAOEInstance.call_deferred("getItemsInside")
		await targetAOEInstance.getItemsInside()
#		await targetAOEInstance.gotItems
		targetAOEInstance.areaOverlapCharacter(false)
		await get_tree().create_timer(0.01).timeout
	
	await get_tree().create_timer(0.01).timeout
	LoadAOE.emit()

#-- Save

func saveToSaveSystem() -> void:
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
	SaveSystem.GameInfoDict.SpawnBehaviorWeights = difficulty.SpawnBehaviors
	SaveSystem.GameInfoDict.ConsoleUnlocked = knossiumConsole.unlocked
	SaveSystem.GameInfoDict.DungeonLevel = get_tree().get_current_scene().get_scene_file_path()
	print("Saved Spawn Behavior Weights: " + str(SaveSystem.GameInfoDict.SpawnBehaviorWeights))
	
	if Global.getBattlesWon() < system.battle:
		Global.progressionDict.BattlesWon = system.battle
	
	saveFriendlyCharacters()

	await SavedFriendlyCharacters
	print("Saved Friendly Characters Passed")
	saveEnemyCharacters()
	await SavedEnemyCharacters
	print("Saved Enemy Characters Passed")
	saveItems()
	await SavedItems
	print("Saved Items Passed")
	saveAOE()
	await SavedAOE
	print("Saved AOE Passed")
	Global.call_deferred("saveAllData")
	await Global.Saved
	print("Saved Global Data Passed")
	SaveSystem.call_deferred("saveAllData")
	await SaveSystem.Saved
	print("Saved All Game Data Passed")
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
	print("GameInfoDict FriendlyCharactersList: " + str(SaveSystem.GameInfoDict.FriendlyCharactersList))
	print("GameInfoDict EnemyCharactersList: " + str(SaveSystem.GameInfoDict.EnemyCharactersList))
	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict EnemyCharactersList: " + str(SaveSystem.GameInfoDict.EnemyCharactersList))
	await get_tree().create_timer(0.05).timeout
	print("GameInfoDict Inventory: " + str(SaveSystem.GameInfoDict.Inventory))
	await get_tree().create_timer(0.05).timeout
	print("Saved GameInfoDict SupportAOEList: " + str(SaveSystem.GameInfoDict.FriendlySupportAOEList))
	print("Saved GameInfoDict SupportAOEList: " + str(SaveSystem.GameInfoDict.EnemySupportAOEList))
	SaveWarningLabel.hide()
	emit_signal("SaveFinished")

func saveFriendlyCharacters() -> void:
	friendlyPartyContainer.getCharactersInfo()
	
	# push_back to friendly characters
	friendlyPartyContainer.characters = friendlyPartyContainer.characters.filter(func(object): return is_instance_valid(object))
	for i in friendlyPartyContainer.characters.size():
		var newSavedCharacterData: Dictionary = SaveSystem.CharacterInfoDict.duplicate(true)
		if is_instance_valid(friendlyPartyContainer.characters[i]):
			newSavedCharacterData.CharacterFilePath = friendlyPartyContainer.characters[i].scene_file_path
			newSavedCharacterData.CharacterPosition = friendlyPartyContainer.characters[i].trueGlobalPosition
			newSavedCharacterData.CharacterName = friendlyPartyContainer.characters[i].characterName
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
			await get_tree().create_timer(0.001).timeout
	
	await get_tree().create_timer(0.05).timeout
	SavedFriendlyCharacters.emit()

func saveEnemyCharacters() -> void:
	enemyPartyContainer.getCharactersInfo()
	
	# push_back to Enemy characters
	enemyPartyContainer.characters = enemyPartyContainer.characters.filter(func(object): return is_instance_valid(object))
	for i in enemyPartyContainer.characters.size():
		var newSavedCharacterData: Dictionary = SaveSystem.CharacterInfoDict.duplicate(true)
		if is_instance_valid(enemyPartyContainer.characters[i]):
			newSavedCharacterData.CharacterFilePath = enemyPartyContainer.characters[i].scene_file_path
			newSavedCharacterData.CharacterPosition = enemyPartyContainer.characters[i].trueGlobalPosition
			newSavedCharacterData.CharacterName = enemyPartyContainer.characters[i].characterName
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
			await get_tree().create_timer(0.001).timeout
	
	await get_tree().create_timer(0.05).timeout
	SavedEnemyCharacters.emit()

func saveItems() -> void:
	for i in inventory.storedItems.size():
		var newSavedItemData: Dictionary = SaveSystem.ItemInfoDict.duplicate(true)
		newSavedItemData.ItemPathName = inventory.storedItems[i].globalFilePath
		newSavedItemData.ItemAmount = inventory.storedItems[i].amount
		SaveSystem.GameInfoDict.Inventory.push_back(newSavedItemData)
		await get_tree().create_timer(0.001).timeout
	
	await get_tree().create_timer(0.05).timeout
	SavedItems.emit()

func saveAOE() -> void:
#	var allSupportAOEList: Array = friendlyAOESupport.get_children() + enemySupportAOE.get_children()
#	var allOffensiveAOEList: Array = friendlyAOEAttack.get_children() + enemyAttackAOE.get_children()
	
	var friendlySupportAOEList: Array = friendlyAOESupport.get_children()
	var enemySupportAOEList: Array = enemySupportAOE.get_children()
	var friendlyOffensiveAOEList: Array = friendlyAOEAttack.get_children()
	var enemyOffensiveAOEList: Array = enemyAttackAOE.get_children()
	
	
	for i in friendlySupportAOEList.size():
		if is_instance_valid(friendlySupportAOEList[i]):
			var newSavedAOEData = SaveSystem.AOEInfoDict.duplicate(true)
			newSavedAOEData.AOEFilePath = friendlySupportAOEList[i].scene_file_path
			newSavedAOEData.AOEName = friendlySupportAOEList[i].AOEName
			newSavedAOEData.AOEColor = friendlySupportAOEList[i].mainColor
	#		print("saved color: " + str(friendlySupportAOEList[i].get_node("MeshInstance2D").modulate))
	#		print("(check) current owner character pfp: " + str(friendlySupportAOEList[i].ownerCharacterPFP.resource_path))
			newSavedAOEData.AOEOwnerCharacterPFP = friendlySupportAOEList[i].ownerCharacterPFP.resource_path
	#		print("(check) saved owner character pfp: " + str(newSavedAOEData.AOEOwnerCharacterPFP))
			newSavedAOEData.AOEOwnerName = friendlySupportAOEList[i].ownerCharacterName
			newSavedAOEData.AOEIsSpriteFlipped = friendlySupportAOEList[i].spriteAnimations.flip_h
			newSavedAOEData.AOEDescription = friendlySupportAOEList[i].ownerActionDescription
			newSavedAOEData.AOEPosition = friendlySupportAOEList[i].global_position
			newSavedAOEData.AOEIsDynamicColor = friendlySupportAOEList[i].isDynamicColor
	#		print(friendlySupportAOEList[i].AOEName + ": (dup) saved DyanmicColor: " + str(friendlySupportAOEList[i].isDynamicColor))
			newSavedAOEData.AOEIsDraggable = friendlySupportAOEList[i].draggable
			newSavedAOEData.AOEStatusActive = friendlySupportAOEList[i].statusActive
			newSavedAOEData.AOEIsMelee = friendlySupportAOEList[i].isMelee
			newSavedAOEData.AOEAccuracy = friendlySupportAOEList[i].accuracy
			newSavedAOEData.AOEHealthDamage = friendlySupportAOEList[i].health
			newSavedAOEData.AOEDefenseDamage = friendlySupportAOEList[i].defense
			newSavedAOEData.AOEAttackDamage = friendlySupportAOEList[i].attack
			newSavedAOEData.AOEMoraleDamage = friendlySupportAOEList[i].morale
			newSavedAOEData.AOEExperienceGain = friendlySupportAOEList[i].experience
			SaveSystem.GameInfoDict.FriendlySupportAOEList.push_back(newSavedAOEData)
			await get_tree().create_timer(0.001).timeout
	
	for i in enemySupportAOEList.size():
		if is_instance_valid(enemySupportAOEList[i]):
			var newSavedAOEData = SaveSystem.AOEInfoDict.duplicate(true)
			newSavedAOEData.AOEFilePath = enemySupportAOEList[i].scene_file_path
			newSavedAOEData.AOEName = enemySupportAOEList[i].AOEName
			newSavedAOEData.AOEColor = enemySupportAOEList[i].mainColor
	#		print("saved color: " + str(enemySupportAOEList[i].get_node("MeshInstance2D").modulate))
	#		print("(check) current owner character pfp: " + str(enemySupportAOEList[i].ownerCharacterPFP.resource_path))
			newSavedAOEData.AOEOwnerCharacterPFP = enemySupportAOEList[i].ownerCharacterPFP.resource_path
	#		print("(check) saved owner character pfp: " + str(newSavedAOEData.AOEOwnerCharacterPFP))
			newSavedAOEData.AOEOwnerName = enemySupportAOEList[i].ownerCharacterName
			newSavedAOEData.AOEIsSpriteFlipped = enemySupportAOEList[i].spriteAnimations.flip_h
			newSavedAOEData.AOEDescription = enemySupportAOEList[i].ownerActionDescription
			newSavedAOEData.AOEPosition = enemySupportAOEList[i].global_position
			newSavedAOEData.AOEIsDynamicColor = enemySupportAOEList[i].isDynamicColor
	#		print(enemySupportAOEList[i].AOEName + ": (dup) saved DyanmicColor: " + str(enemySupportAOEList[i].isDynamicColor))
			newSavedAOEData.AOEIsDraggable = enemySupportAOEList[i].draggable
			newSavedAOEData.AOEStatusActive = enemySupportAOEList[i].statusActive
			newSavedAOEData.AOEIsMelee = enemySupportAOEList[i].isMelee
			newSavedAOEData.AOEAccuracy = enemySupportAOEList[i].accuracy
			newSavedAOEData.AOEHealthDamage = enemySupportAOEList[i].health
			newSavedAOEData.AOEDefenseDamage = enemySupportAOEList[i].defense
			newSavedAOEData.AOEAttackDamage = enemySupportAOEList[i].attack
			newSavedAOEData.AOEMoraleDamage = enemySupportAOEList[i].morale
			newSavedAOEData.AOEExperienceGain = enemySupportAOEList[i].experience
			SaveSystem.GameInfoDict.EnemySupportAOEList.push_back(newSavedAOEData)
			await get_tree().create_timer(0.001).timeout
	
	for i in friendlyOffensiveAOEList.size():
		if is_instance_valid(friendlyOffensiveAOEList[i]):
			var newSavedAOEData = SaveSystem.AOEInfoDict.duplicate(true)
			newSavedAOEData.AOEFilePath = friendlyOffensiveAOEList[i].scene_file_path
			newSavedAOEData.AOEName = friendlyOffensiveAOEList[i].AOEName
			newSavedAOEData.AOEColor = friendlyOffensiveAOEList[i].mainColor
			newSavedAOEData.AOEOwnerCharacterPFP = friendlyOffensiveAOEList[i].ownerCharacterPFP.resource_path
			newSavedAOEData.AOEOwnerName = friendlyOffensiveAOEList[i].ownerCharacterName
			newSavedAOEData.AOEIsSpriteFlipped = friendlyOffensiveAOEList[i].spriteAnimations.flip_h
			newSavedAOEData.AOEDescription = friendlyOffensiveAOEList[i].ownerActionDescription
			newSavedAOEData.AOEPosition = friendlyOffensiveAOEList[i].global_position
			newSavedAOEData.AOEIsDynamicColor = friendlyOffensiveAOEList[i].isDynamicColor
	#		print(friendlyOffensiveAOEList[i].AOEName + ": (dup) saved DyanmicColor: " + str(friendlyOffensiveAOEList[i].isDynamicColor))
			newSavedAOEData.AOEIsDraggable = friendlyOffensiveAOEList[i].draggable
			newSavedAOEData.AOEStatusActive = friendlyOffensiveAOEList[i].statusActive
			newSavedAOEData.AOEIsMelee = friendlyOffensiveAOEList[i].isMelee
			newSavedAOEData.AOEAccuracy = friendlyOffensiveAOEList[i].accuracy
			newSavedAOEData.AOEHealthDamage = friendlyOffensiveAOEList[i].health
			newSavedAOEData.AOEDefenseDamage = friendlyOffensiveAOEList[i].defense
			newSavedAOEData.AOEAttackDamage = friendlyOffensiveAOEList[i].attack
			newSavedAOEData.AOEMoraleDamage = friendlyOffensiveAOEList[i].morale
			newSavedAOEData.AOEExperienceGain = friendlyOffensiveAOEList[i].experience
			SaveSystem.GameInfoDict.FriendlyOffensiveAOEList.push_back(newSavedAOEData)
			await get_tree().create_timer(0.001).timeout
	
	for i in enemyOffensiveAOEList.size():
		if is_instance_valid(enemyOffensiveAOEList[i]):
			var newSavedAOEData = SaveSystem.AOEInfoDict.duplicate(true)
			newSavedAOEData.AOEFilePath = enemyOffensiveAOEList[i].scene_file_path
			newSavedAOEData.AOEName = enemyOffensiveAOEList[i].AOEName
			newSavedAOEData.AOEColor = enemyOffensiveAOEList[i].mainColor
			newSavedAOEData.AOEOwnerCharacterPFP = enemyOffensiveAOEList[i].ownerCharacterPFP.resource_path
			newSavedAOEData.AOEOwnerName = enemyOffensiveAOEList[i].ownerCharacterName
			newSavedAOEData.AOEIsSpriteFlipped = enemyOffensiveAOEList[i].spriteAnimations.flip_h
			newSavedAOEData.AOEDescription = enemyOffensiveAOEList[i].ownerActionDescription
			newSavedAOEData.AOEPosition = enemyOffensiveAOEList[i].global_position
			newSavedAOEData.AOEIsDynamicColor = enemyOffensiveAOEList[i].isDynamicColor
	#		print(enemyOffensiveAOEList[i].AOEName + ": (dup) saved DyanmicColor: " + str(enemyOffensiveAOEList[i].isDynamicColor))
			newSavedAOEData.AOEIsDraggable = enemyOffensiveAOEList[i].draggable
			newSavedAOEData.AOEStatusActive = enemyOffensiveAOEList[i].statusActive
			newSavedAOEData.AOEIsMelee = enemyOffensiveAOEList[i].isMelee
			newSavedAOEData.AOEAccuracy = enemyOffensiveAOEList[i].accuracy
			newSavedAOEData.AOEHealthDamage = enemyOffensiveAOEList[i].health
			newSavedAOEData.AOEDefenseDamage = enemyOffensiveAOEList[i].defense
			newSavedAOEData.AOEAttackDamage = enemyOffensiveAOEList[i].attack
			newSavedAOEData.AOEMoraleDamage = enemyOffensiveAOEList[i].morale
			newSavedAOEData.AOEExperienceGain = enemyOffensiveAOEList[i].experience
			SaveSystem.GameInfoDict.EnemyOffensiveAOEList.push_back(newSavedAOEData)
			await get_tree().create_timer(0.001).timeout
	
	await get_tree().create_timer(0.05).timeout
	SavedAOE.emit()

func setDisabledAllAOE(boolean: bool) -> void:
	for i in grabAllAOE().size():
		print("Button is " + str(grabAllAOE()[i].button))
		grabAllAOE()[i].button.visible = boolean

func goThroughQueuedAOEArray() -> void:
	var currentBattle: int = system.battle
	
	queuedAOE = grabAllAOE()
#	print(str(self) + ": allAOE: " + str(queuedAOE))
	stopControlVisible(true, 1)
#	stopControl.visible = true
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
			
	# This is still in testing, this might cause crash or infinite loop
	while friendlyAOEAttack.AnyAOEAnimationPlaying() && enemyAttackAOE.AnyAOEAnimationPlaying() && friendlyAOESupport.AnyAOEAnimationPlaying() && enemySupportAOE.AnyAOEAnimationPlaying():
		print("AOE has no finished yet!")
		await get_tree().create_timer(0.1).timeout
#	while friendlyAOEAttack.get_child_count() != 0 && enemyAttackAOE.get_child_count() != 0 && friendlyAOESupport.get_child_count() != 0 && enemySupportAOE.get_child_count() != 0:
#		print("AOE has no finished yet!")
#		await get_tree().create_timer(0.1).timeout
	# Spawn Our Friendly AOE Here
	print("AOEQueueFinished")
	print("--------------------------------")
	emit_signal("AOEQueueFinished")
	updateValueOfStatusBar()
	await get_tree().create_timer(1).timeout
	setIsCharactersActive(false)
	
	saveToSaveSystem()
	updateUpkeepList()
	stopControlVisible(true, 1)
	var confirm: bool = await saveConfirmation()
	
	musicPlayer.updateDangerLevel()
	
	if confirm:
		if system.battle >= 2:
			shopWeight += 0.25
			if randi_range(0, 25) - shopWeight <= 0:
				shopWeight = 0.0
				stopControlVisible(true, 1)
				await get_tree().create_timer(0.5).timeout
				while difficulty.isCharactersSpawningIn == true:
					await get_tree().create_timer(0.1).timeout
				if randi_range(0, 1) == 0:
					GotoShop()
				else:
					GoToNextArea()
			else:
				checkSpecialWindowContainer()
		else:
			checkSpecialWindowContainer()
		stopControlVisible(false, 1)

func grabAllAOE() -> Array:
	var AOEGrabbed: Array = friendlyAOEAttack.get_children() + enemyAttackAOE.get_children() + friendlyAOESupport.get_children() + enemySupportAOE.get_children()
	return AOEGrabbed

func setIsCharactersActive(boolean: bool) -> void:
	isCharactersActive = boolean

func getTurn() -> void:
	print(str(self) + ": Turns: " + str(system.battle))
	turnsLabel.set_text("Turns: " + str(system.turn))
	print("Is characters Spawning in? " + str(difficulty.isCharactersSpawningIn))
	goThroughQueuedAOEArray()

func getBattle() -> void:
	print(str(self) + ": Battles: " + str(system.battle))
	battlesLabel.set_text("Battles: " + str(system.battle))

func _on_turn_system_on_new_turn() -> void:
	getTurn()
	getBattle()

func GotoShop() -> void:
	print("Go to shop!")
	stopControlVisible(true, 2)
#	stopControl2.show()
	var instance := shopWindow.instantiate()
	specialWindowContainer.add_child(instance)
	instance.dungeon = self
	instance.z_index = 2
	
	@warning_ignore("integer_division")
	instance.set_global_position(Vector2(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen(0)).x / 2, DisplayServer.screen_get_size(DisplayServer.window_get_current_screen(0)).y / 2))
	checkSpecialWindowContainer()

func GoToNextArea() -> void:
	print("Go to Next Area!")
	stopControlVisible(true, 2)
	var instance := nextAreaWindow.instantiate()
	specialWindowContainer.add_child(instance)
	instance.dungeon = self
	instance.z_index = 2
	
	@warning_ignore("integer_division")
	instance.set_global_position(Vector2(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen(0)).x / 2, DisplayServer.screen_get_size(DisplayServer.window_get_current_screen(0)).y / 2))
	checkSpecialWindowContainer()

func spawnSurrenderWindow(Lcharacter: BaseCharacter, profilePicture: Texture2D, characterName: String, experience: float) -> void:
	print(str(self) + ": Spawning Surrender Window")
	print(str(self) + ": scene file path 2: " + str(Lcharacter))
	stopControlVisible(true, 2)
#	stopControl2.show()
	var instance := surrenderWindow.instantiate()
	specialWindowContainer.add_child(instance)
	instance.character = Lcharacter
	instance.characterPFP = profilePicture
	instance.characterName = characterName
	instance.totalExperience = experience
	instance.setWindowInfo()
	instance.set_global_position(Vector2(0, 0))
	stopControlVisible(true, 1)
	stopControlVisible(true, 2)

func checkSpecialWindowContainer() -> void:
	await get_tree().create_timer(0.005).timeout
#	^ This is the last thing to do if call_deffered doesn't like being reliable
	print("(check) child count: " + str(specialWindowContainer.get_child_count()))
	if specialWindowContainer.get_child_count() != 0:
		stopControlVisible(true, 1)
		stopControlVisible(true, 2)
	else:
		stopControlVisible(false, 1)
		stopControlVisible(false, 2)

func _on_show_inventory_button_pressed() -> void:
	stopControlVisible(true, 1)
#	stopControl.show()
	inventoryButton.disabled = true
	inventoryUI.updateInventoryItemList()
	inventoryUI.show()

func _on_show_party_button_pressed() -> void:
	stopControlVisible(true, 1)
#	stopControl.show()
	partyButton.disabled = true
	partyUI.updateCharacterList()
	partyUI.show()

func _on_show_menu_button_pressed() -> void:
	stopControlVisible(true, 1)
#	stopControl.show()
	ingameUI.show()

func OpenConsoleButtonPressed() -> void:
	stopControlVisible(true, 1)
	knossiumConsole.show()
