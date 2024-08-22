extends Node
## This script will persist between scenes

@onready var loadedLoadingScreen := preload("res://resources/levels/menu/LoadingMenu/LoadingMenu.tscn")
var loadingScreen: LoadingScreen
var previousScene: String

var filePathForProgressionData := "user://ProgressionData.save"
var filePathForNewProgressionData := "user://NewProgressionData.save"
var gameProgressionVersion: String = "0.82"

# Things to bring into the in game through new game start menu
var newGameCharacterInfo: Array
var newGameInventoryInfo: Array

# Progression
var newlyUnlockedCharacters: Array
var newlyUnlockedItems: Array
var BattlesWon: int

signal loaded
signal Saved

var newProgressionDict: Dictionary = {
	"CharactersUnlocked": [],
	"ItemsUnlocked": [],
	"BattlesWon": 0, # In a single game
}

var progressionDict: Dictionary = {
	"ProgressionGameVersion": gameProgressionVersion,
	"CharactersUnlocked": ["res://resources/entities/characters_items/character/new_dev_game_characters/NewDevArcherCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevMeleeCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevSupportCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevTankCharacter.tscn"],
	"ItemsUnlocked": ["res://resources/entities/inventory_items/dev_items/DevGold.tres", "res://resources/entities/inventory_items/dev_items/ExperiencePotion.tres"],
	"BattlesWon": 0, # In a single game
}

var loadoutsListDict: Dictionary = {
	"Loudouts": []
}

var loadoutDict: Dictionary = {
	"Characters": [],
	"Items": []
}

func _ready() -> void:
	if checkGlobalDataFileExists():
		loadAllData()
		checkProgressionVersion()
	else:
		clearProgressionDict()
		clearNewProgressionDict()

func StartLoadingScreen(smoothStart: bool) -> void:
	print("Loading")
	if !(smoothStart):
		loadingScreen = loadedLoadingScreen.instantiate()
		loadingScreen.z_index = 10
		get_tree().get_current_scene().add_child(loadingScreen)
		loadingScreen.set_position(Vector2(0, 0))
		print("Loading Works: SmoothStart false")
	else:
		loadingScreen = loadedLoadingScreen.instantiate()
		loadingScreen.z_index = 10
		get_tree().get_current_scene().add_child(loadingScreen)
		loadingScreen.set_position(Vector2(0, 0))
		loadingScreen.smoothStartLoadingMenu()
		print("Loading Works: SmoothStart true")
	

func EndLoadingScreen() -> void:
	loadingScreen.RemoveLoadingMenu()


#--[ Unlocking ]--

func newlyUnlockedToFullyUnlocked():
	progressionDict.CharactersUnlocked += newProgressionDict.CharactersUnlocked
	progressionDict.ItemsUnlocked += newProgressionDict.ItemsUnlocked


## Check if filePath doesn't exist, if not then add
func unlockCharacter(filePath: String) -> void:
	if !(getDictCharactersUnlocked().has(filePath)):
		getDictCharactersUnlocked().push_back(filePath)
#		newlyUnlockedCharacters.push_back(filePath)
		newProgressionDict.CharactersUnlocked.push_back(filePath)
		print("newly character unlock list: " + str(newProgressionDict.CharactersUnlocked))
		print("new character unlock list: " + str(getDictCharactersUnlocked()))

## Check if filePath doesn't exist, if not then add
func unlockItem(filePath: String) -> void:
	if !(getDictItemsUnlocked().has(filePath)):
		getDictItemsUnlocked().push_back(filePath)
#		newlyUnlockedItems.push_back(filePath)
		newProgressionDict.ItemsUnlocked.push_back(filePath)
		print("newly item unlock list: " + str(newProgressionDict.ItemsUnlocked))
		print("new item unlock list: " + str(getDictItemsUnlocked()))

func unlockWhenMostBattles(amount: int) -> void:
	if amount > getBattlesWon():
		progressionDict.BattlesWon = amount

func clearProgressionDict() -> void:
	progressionDict = {
		"ProgressionGameVersion": gameProgressionVersion,
		"CharactersUnlocked": ["res://resources/entities/characters_items/character/new_dev_game_characters/NewDevArcherCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevMeleeCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevSupportCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevTankCharacter.tscn"],
		"ItemsUnlocked": ["res://resources/entities/inventory_items/dev_items/DevGold.tres", "res://resources/entities/inventory_items/dev_items/ExperiencePotion.tres"],
		"BattlesWon": 0, # In a single game
	}

func clearNewProgressionDict() -> void:
	newlyUnlockedCharacters.clear()
	newlyUnlockedItems.clear()
	newProgressionDict = {
		"CharactersUnlocked": [],
		"ItemsUnlocked": [],
		"BattlesWon": 0, # In a single game
	}

func clearProgressThroughDeletion() -> void:
	if checkGlobalDataFileExists():
		DirAccess.remove_absolute("user://ProgressionData.save")

func clearNewProgressThroughDeletion() -> void:
	if checkNewProgressionDataFileExists():
		DirAccess.remove_absolute("user://NewProgressionData.save")
		


#--[ Save & Load Dict]--

func saveAllData() -> bool:
	print("Progression Data Saved")
	progressionDict.CharactersUnlocked = progressionDict.CharactersUnlocked.filter(func(object): return FileAccess.file_exists(object))
	newProgressionDict.CharactersUnlocked = newProgressionDict.CharactersUnlocked.filter(func(object): return FileAccess.file_exists(object))
	var file := FileAccess.open_encrypted_with_pass(filePathForProgressionData, FileAccess.WRITE, "Platy1ium")
	var file1 := FileAccess.open_encrypted_with_pass(filePathForNewProgressionData, FileAccess.WRITE, "Platy1ium")
	file.store_var(progressionDict)
	file1.store_var(newProgressionDict)
	file.close()
	file1.close()
	await get_tree().create_timer(0.01).timeout
	emit_signal("Saved")
	return true

# On ready like in menu or in this script, load all data
func loadAllData() -> void:
	var file := FileAccess.open_encrypted_with_pass(filePathForProgressionData, FileAccess.READ, "Platy1ium") 
	var file1 := FileAccess.open_encrypted_with_pass(filePathForNewProgressionData, FileAccess.READ, "Platy1ium")
	if not FileAccess.file_exists(filePathForProgressionData):
		print("No Previous Global Progression Data")
	else:
		print("Global Data Exists!")
		progressionDict = file.get_var()
		progressionDict.CharactersUnlocked = progressionDict.CharactersUnlocked.filter(func(object): return FileAccess.file_exists(object))
		print(progressionDict)
		
	if not FileAccess.file_exists(filePathForNewProgressionData):
		print("No Previous Global New Progression Data")
	else:
		print("Global Data Exists!")
		newProgressionDict = file1.get_var()
		newProgressionDict.CharactersUnlocked = newProgressionDict.CharactersUnlocked.filter(func(object): return FileAccess.file_exists(object))
		print(progressionDict)
	emit_signal("loaded")

func checkGlobalDataFileExists() -> bool:
	if FileAccess.file_exists(filePathForProgressionData):
		return true
	else:
		return false

func checkNewProgressionDataFileExists() -> bool:
	if FileAccess.file_exists(filePathForNewProgressionData):
		return true
	else:
		return false

func checkProgressionVersion() -> bool:
	print("checking the save version")
#	print("current Dict: " + str(GameInfoDict))
	if progressionDict.find_key("gameProgressionVersion") != "":
		if progressionDict.ProgressionGameVersion != gameProgressionVersion:
			push_error("Incompatible Progression Version, Current is " + str(gameProgressionVersion) + ", Your Version is " + str(progressionDict.ProgressionGameVersion))
			SaveSystem.clearSaveThroughDeletion()
			SaveSystem.clearSaveThroughEmptying()
			clearProgressThroughDeletion()
			clearNewProgressThroughDeletion()
			clearNewProgressionDict()
			clearProgressionDict()
			saveAllData()
			return false
		else:
			print("Compatible Progression Version, Current is " + str(gameProgressionVersion) + ", Your Version is " + str(progressionDict.ProgressionGameVersion))
			return true
	else:
		push_error("The Key ProgressionVersion doesn't exist")
		SaveSystem.clearSaveThroughDeletion()
		SaveSystem.clearSaveThroughEmptying()
		clearProgressThroughDeletion()
		clearNewProgressThroughDeletion()
		clearNewProgressionDict()
		clearProgressionDict()
		saveAllData()
		progressionDict.ProgressionGameVersion = gameProgressionVersion
		print("Progression " + str(progressionDict))
		return false
#--[ Get Info from Dict ]--

func checkMaxValue() -> float:
	var count: int = 0
	var newGameMenuMaxValue: float = 0
	
	for i in BattlesWon:
		count += 1
		if count == 5:
			count = 0
			newGameMenuMaxValue += 100
	
	return newGameMenuMaxValue

func getDictCharactersUnlocked() -> Array:
	return progressionDict.CharactersUnlocked

func getDictItemsUnlocked() -> Array:
	return progressionDict.ItemsUnlocked

func getBattlesWon() -> int:
	return progressionDict.BattlesWon

#--[ Other Functions ]--

