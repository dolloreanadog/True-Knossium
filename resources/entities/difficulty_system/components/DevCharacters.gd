extends Node
## Attached to a DifficultySystem for spawn characters.
class_name SpawnCharacterComponent
# Eventaully make a base class for this called SpawnCharacterComponent

@export var spawner: difficultySystem
# Opens folder containing all characters in the folder here
@export var dirPath: String = "res://resources/entities/characters_items/character/new_dev_game_characters"
var loadedCharactersArray: Array

func _ready() -> void:
	GetCharactersFilePaths(dirPath)

# Connect the signal to here
func Activate() -> void:
	SpawnCharacters()

func SpawnCharacters() -> void:
	print(str(self) + " (NormalSpawnBehavior)" + ": Normal Spawning Behavior")
	print(str(self) + "LdifficultyTotal: " + str(spawner.difficultyTotal))
	print(str(self) + " (NormalSpawnBehavior) " + " charityDifficultyEXP: " + str(spawner.charityDifficultyEXP))
	spawner.enemyPartyContainer.difficultyEXP = spawner.charityDifficultyEXP
	spawner.getEnemyStats()
	spawner.dungeon.stopControlVisible(true, 1)
	while spawner.enemyTotalStats <= spawner.difficultyTotal:
		spawner.dungeon.stopControlVisible(true, 1)
		spawner.SpawnCharacterFromArray(loadedCharactersArray)
		spawner.getEnemyStats()
#		dungeon.stopControl.show()
		await get_tree().create_timer(0.10).timeout
	print(str(self) + " (NormalSpawnBehavior) " + "It's over")
	spawner.isCharactersSpawningIn = false
	emit_signal("SpawningIsOver")
	
	spawner.dungeon.SaveWarningLabel.show()
	await get_tree().create_timer(1).timeout
	spawner.dungeon.saveToSaveSystem()
	spawner.dungeon.SaveWarningLabel.hide()
	spawner.dungeon.stopControlVisible(false, 1)

func GetCharactersFilePaths(filePath: String) -> void: # WHATEVER YOU DO NOT DELETE THIS TEMPLATE
	var dir := DirAccess.open(filePath)
	
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
