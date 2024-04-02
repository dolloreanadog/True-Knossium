extends Node

var filePathForSaveData := "user://SaveData.save"

signal Saved
signal Loaded

#--[ Save Information]--

@export var GameInfoDict: Dictionary = {
	"PeakTotalStatPoints": 0,
	"CharactersDied": 0,
	"CharactersSurrendered": 0,
	"Battles": 0,
	"Turns": 0,
	
	"Inventory": [], # Store all itemInfoDicts Here
	"FriendlyCharactersList": [], # Store all CharacterInfoDicts Here
	"EnemyCharactersList": [], # Store all CharacterInfoDicts Here
	"AOEList": [], # Store all AOEInfoDicts Here
	# ^ Going to replace this with more specific to prevent save errors
}

@export var ItemInfoDict: Dictionary = {
	"ItemPathName": "PathName",
	"ItemAmount": 0
}

@export var CharacterInfoDict: Dictionary = {
	"CharacterFilePath": "CharacterFilePath",
	"CharacterPosition": Vector2(0, 0),
#	"CharacterIsDynamicColor": false, 
	"CharacterExperience": 0.0,
	"CharacterAction1CurrentCastTime": 0,
	"CharacterAction2CurrentCastTime": 0,
	"CharacterAction3CurrentCastTime": 0,
	"CharacterAction4CurrentCastTime": 0,
	"CharacterCurrentHealth": 0.0,
	"CharacterCurrentDefense": 0.0,
	"CharacterCurrentAttack": 0.0,
	"CharacterCurrentMorale": 0.0,
}

@export var AOEInfoDict: Dictionary = {
	"AOEFilePath": "Resource.new()",
	"AOEName": "name",
	"AOEColor": Color(1, 1, 1, 1),
	"AOEOwnerCharacterPFP": ImageTexture.new(),
	"AOEOwnerName": "OwnerName",
	"AOEDescription": "description",
	"AOEPosition": Vector2(0, 0),
	"AOEIsDynamicColor": false, 
	"AOEIsDraggable": false,
	"AOEStatusActive": false,
	"AOEIsMelee": false,
	"AOEAccuracy": 0,
	"AOEHealthDamage": 0.0,
	"AOEDefenseDamage": 0.0,
	"AOEAttackDamage": 0.0,
	"AOEMoraleDamage": 0.0,
	"AOEExperienceGain": 0.0,
}



#--[ Functions ]--

#----[ Saving ]----

func saveAllData() -> void:
	var file := FileAccess.open_encrypted_with_pass(filePathForSaveData, FileAccess.WRITE, "Platy1ium")
	file.store_var(GameInfoDict)
	file.close()
	emit_signal("Saved")

#----[ Loading ]----
# Loading may be done by BaseLevel, idk

func loadAllData() -> void:
	var file := FileAccess.open_encrypted_with_pass(filePathForSaveData, FileAccess.READ, "Platy1ium") 
	if not FileAccess.file_exists(filePathForSaveData):
		print("No Previous Save Data")
	else:
		print("Save Data Exists!")
		GameInfoDict = file.get_var()
		print(GameInfoDict)
		emit_signal("Loaded")

func loadGeneralInformation() -> void:
	pass

#--[ Load Individual Items ]--

func loadItem() -> void:
	pass
	# pop_back item from inventory
	# Turn it into an instance 
	# addToInventory()

func loadCharacter() -> void:
	pass
	# pop_back character from Friendly Character List
	# if no more in Friendly Character List pop_back from Enemy Character List
	# Turn it into an instance
	# addCharacter() in either friendly or enemy
	# grab that instance variable & edit from there

func loadAOE() -> void:
	pass
	# pop_back AOE from AOEList
	# Turn it into an instance
	# Set Position
	# Set Draggable
	# Set Active
	# Set all its other data
	
#----[ Other ]----

func checkSaveFileExists() -> bool:
	if FileAccess.file_exists(filePathForSaveData):
		return true
	else:
		return false

func clearSaveThroughDeletion() -> void:
	if checkSaveFileExists():
		DirAccess.remove_absolute("user://SaveData.save")
	# Delete the save file if it exists

## Do Not Use This!
func clearSaveThroughEmptying() -> void:
	GameInfoDict = {
	"PeakTotalStatPoints": 0,
	"CharactersDied": 0,
	"CharactersSurrendered": 0,
	"Battles": 0,
	"Turns": 0,
	
	"Inventory": [], # Store all itemInfoDicts Here
	"FriendlyCharactersList": [], # Store all CharacterInfoDicts Here
	"EnemyCharactersList": [], # Store all CharacterInfoDicts Here
	"AOEList": [], # Store all AOEInfoDicts Here
	}
	# clears all contents in GameInfoDict, really intended for ingame saving
