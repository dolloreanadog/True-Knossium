extends Node
## Attached to a DifficultySystem for spawn characters.
class_name SpawnCharacterComponent
# Eventaully make a base class for this called SpawnCharacterComponent

@export var spawner: difficultySystem
# Opens folder containing all characters in the folder here
@export var dirPaths: Array = ["res://resources/entities/characters_items/character/new_dev_game_characters"]
var loadedCharactersArray: Array
@export_category("Experience Modifier")
## Multiplier, will decide the cap for characters. Keep to 1 for no change.
@export var difficultyTotalModifier: float = 1
## Multiplier, will decide how much more experience for characters. Keep to 1 for no change.
@export var charityDifficultyEXPModifier: float = 1

func _ready() -> void:
	GetCharactersFilePaths(dirPaths)

# Connect the signal to here
func Activate() -> void:
	SpawnCharacters()

func SpawnCharacters() -> void:
	print(str(self) + " (NormalSpawnBehavior)" + ": Normal Spawning Behavior")
	print(str(self) + "LdifficultyTotal: " + str(spawner.difficultyTotal))
	print(str(self) + " (NormalSpawnBehavior) " + " charityDifficultyEXP: " + str(spawner.charityDifficultyEXP))
	var LdifficultyTotal = spawner.difficultyTotal * difficultyTotalModifier
	spawner.charityDifficultyEXP *= charityDifficultyEXPModifier
	spawner.enemyPartyContainer.difficultyEXP = spawner.charityDifficultyEXP
	
	spawner.getEnemyStats()
	spawner.dungeon.stopControlVisible(true, 1)
	while spawner.enemyTotalStats <= LdifficultyTotal:
		spawner.dungeon.stopControlVisible(true, 1)
		spawner.SpawnCharacterFromArray(loadedCharactersArray)
		spawner.getEnemyStats()
		while spawner.dungeon.enemyPartyContainer.isSpawningCharacter:
			print("Wait for character Spawning in")
			await get_tree().create_timer(0.1).timeout
	print(str(self) + " (NormalSpawnBehavior) " + "It's over")
	spawner.dungeon.enemyPartyContainer.MoveAllCharactersToTruePosition()
	spawner.isCharactersSpawningIn = false
	spawner.emit_signal("SpawningIsOver")
	
	spawner.dungeon.SaveWarningLabel.show()
	await get_tree().create_timer(1).timeout
	spawner.dungeon.saveToSaveSystem()
	spawner.dungeon.SaveWarningLabel.hide()
	spawner.dungeon.stopControlVisible(false, 1)



func GetCharactersFilePaths(filePath: Array) -> void: # WHATEVER YOU DO NOT DELETE THIS TEMPLATE
	
	for i in filePath.size():
		var dir := DirAccess.open(filePath[i])
		
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					print(dir.get_current_dir() + "/" + file_name)
				else:
					var characterPath = dir.get_current_dir() + "/" + file_name
					print(str(self) + str(characterPath))
					loadedCharactersArray.push_back(characterPath)
				file_name = dir.get_next()
		else:
			push_error("An error occurred when trying to access the path.")
