extends Node
## This script will persist between scenes

var filePathForProgressionData := "user://ProgressionData.save"
var filePathForNewProgressionData := "user://NewProgressionData.save"

# Things to bring into the in game through new game start menu
var newGameCharacterInfo: Array
var newGameInventoryInfo: Array

# Progression
var newlyUnlockedCharacters: Array
var newlyUnlockedItems: Array
var BattlesWon: int

signal saved

var newProgressionDict: Dictionary = {
	"CharactersUnlocked": [],
	"ItemsUnlocked": [],
	"BattlesWon": 1, # In a single game
}

var progressionDict: Dictionary = {
	"CharactersUnlocked": ["res://resources/entities/characters_items/character/new_dev_game_characters/NewDevArcherCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevMeleeCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevSupportCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevTankCharacter.tscn"],
	"ItemsUnlocked": ["res://resources/entities/inventory_items/dev_items/DevGold.tres", "res://resources/entities/inventory_items/dev_items/ExperiencePotion.tres"],
	"BattlesWon": 0, # In a single game
}

func _ready() -> void:
	if checkGlobalDataFileExists():
		loadAllData()
	else:
		clearProgressionDict()

#--[ Unlocking ]--

func newlyUnlockedToFullyUnlocked():
	progressionDict.CharactersUnlocked += newlyUnlockedCharacters
	progressionDict.ItemsUnlocked += newlyUnlockedItems


## Check if filePath doesn't exist, if not then add
func unlockCharacter(filePath: String) -> void:
	if !(getDictCharactersUnlocked().has(filePath)):
		getDictCharactersUnlocked().push_back(filePath)
		newlyUnlockedCharacters.push_back(filePath)
		print("newly character unlock list: " + str(newlyUnlockedCharacters))
		print("new character unlock list: " + str(getDictCharactersUnlocked()))

## Check if filePath doesn't exist, if not then add
func unlockItem(filePath: String) -> void:
	if !(getDictItemsUnlocked().has(filePath)):
		getDictItemsUnlocked().push_back(filePath)
		newlyUnlockedItems.push_back(filePath)
		print("newly item unlock list: " + str(newlyUnlockedItems))
		print("new item unlock list: " + str(getDictItemsUnlocked()))

func unlockWhenMostBattles(amount: int) -> void:
	if amount > getBattlesWon():
		progressionDict.BattlesWon = amount

func clearProgressionDict() -> void:
	progressionDict = {
		"CharactersUnlocked": ["res://resources/entities/characters_items/character/new_dev_game_characters/NewDevArcherCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevMeleeCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevSupportCharacter.tscn", "res://resources/entities/characters_items/character/new_dev_game_characters/NewDevTankCharacter.tscn"],
		"ItemsUnlocked": ["res://resources/entities/inventory_items/dev_items/DevGold.tres", "res://resources/entities/inventory_items/dev_items/ExperiencePotion.tres"],
		"BattlesWon": 1, # In a single game
	}
	
	newProgressionDict = {
		"CharactersUnlocked": [],
		"ItemsUnlocked": [],
		"BattlesWon": 0, # In a single game
	}

func clearProgressThroughDeletion() -> void:
	if checkGlobalDataFileExists():
		DirAccess.remove_absolute("user://ProgressionData.save")
	if checkNewProgressionDataFileExists():
		DirAccess.remove_absolute("user://NewProgressionData.save")
		
#--[ Save & Load Dict]--

func saveAllData() -> void:
	var file := FileAccess.open_encrypted_with_pass(filePathForProgressionData, FileAccess.WRITE, "Platy1ium")
	var file1 := FileAccess.open_encrypted_with_pass(filePathForNewProgressionData, FileAccess.WRITE, "Platy1ium")
	file.store_var(progressionDict)
	file1.store_var(newProgressionDict)
	file.close()
	file1.close()
	emit_signal("saved")

# On ready like in menu or in this script, load all data
func loadAllData() -> void:
	var file := FileAccess.open_encrypted_with_pass(filePathForProgressionData, FileAccess.READ, "Platy1ium") 
	var file1 := FileAccess.open_encrypted_with_pass(filePathForNewProgressionData, FileAccess.WRITE, "Platy1ium")
	if not FileAccess.file_exists(filePathForProgressionData):
		print("No Previous Global Data")
	else:
		print("Global Data Exists!")
		progressionDict = file.get_var()
		print(progressionDict)
		
#	if not FileAccess.file_exists(filePathForNewProgressionData):
#		print("No Previous Global Data")
#	else:
#		print("Global Data Exists!")
#		newProgressionDict = file.get_var()
#		print(progressionDict)

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

