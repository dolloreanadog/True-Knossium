extends Node
class_name difficultySystem

#--[ Important Nodes ]--
@onready var dungeon: BaseLevel = get_parent()
# We get the total used for difficulty, deciding how to strong it should be
@export var friendlyPartyContainer: BasePartyContainer
# We use this to figure out if we should stop spawning enemies
@export var enemyPartyContainer: BasePartyContainer
# We use this for if the battle ends, it spawn them back
@export var system: TurnSystem

#--[ Variable difficulty ]--
var difficultyTotal: float
var friend
var enemyTotalStats: float
var charityDifficultyEXP: float = 1

var battleSignalTimes: int = 0

#--[ Variable Paths ]--
# These are the paths which we use for later functions, when adding a new type, put folder path here

#Template
#var dir(name) = DirAccess.open("res://resources/entities/characters_items/character/NAME_OF_FOLDER_OF_CHARACTERS")
var dirDev := DirAccess.open("res://resources/entities/characters_items/character/new_dev_game_characters")
var dirSpecial := DirAccess.open("res://resources/entities/characters_items/character/special_game_characters")
var extension := "tscn"

#--[ character loading ]--
enum characterType {DEV, DUNGEON, GARDEN, FACTORY, LOBORATORY, BATTLEFIELD, SPECIAL}
@export var dungeonType: characterType
var isCharactersSpawningIn: bool = true


var loadedDevCharactersArray: Array
var loadedSpecialCharactersArray: Array

signal SpawningIsOver

func _ready():
	getCharactersFilePaths()
	system.connect("OnNewBattle", onBattleNew)
	#dungeon.connect("AOEQueueFinished")

func onBattleNew():
	await dungeon.AOEQueueFinished
	isCharactersSpawningIn = true
	battleSignalTimes += 1
	print(str(self) + ": Getting Battle Signal: " + str(battleSignalTimes))
	charityDifficultyEXP = 0
	randomSpawningBehavior()

# We use here to decide what kind of characterType we're getting
func getDungeonType():
	pass


func getDifficultyTotal():
	difficultyTotal = friendlyPartyContainer.getTotalStatPoints() + (system.battle * 2)
	charityDifficultyEXP = system.battle * 1.25

func getEnemyStats():
	enemyTotalStats = enemyPartyContainer.getTotalStatPoints()

func randomSpawningBehavior():
	getDifficultyTotal()
	# We Changing This
	var number: float = snappedf(randf_range(0, 90), 0.01)
	print("(Check4) number is " + str(number))
	
	if number >= 0 && number <= 60:
		print("(Check4) normal spawn behavior " + str(number))
		NormalSpawnBehavior()
	elif number >= 60.01 && number <= 80:
		print("(Check4) horde spawn behavior " + str(number))
		HordeSpawnBehavior()
	elif number >= 80.01 && number <= 90:
		print("(Check4) elite spawn behavior " + str(number))
		EliteSpawnBehavior()
#	elif range(90.01, 95).has(number):
#		LegendarySpawnBehavior()
#	elif range(95.01, 99).has(number):
#		MythicalSpawnBehavior()
#	elif range(99.01, 100).has(number):
#		GodSpawnBehavior()
	
#	match randi_range(1, 6):
#		1:
#			NormalSpawnBehavior()
#		2:
#			NormalSpawnBehavior()
#		3:
#			NormalSpawnBehavior()
#		4:
#			HordeSpawnBehavior()
#		5: 
#			HordeSpawnBehavior()
#		6:
#			EliteSpawnBehavior()

## Normal Spawning Behavior, no exp or difficulty total manipulation
func NormalSpawnBehavior():
	print(str(self) + " (NormalSpawnBehavior) (check) " + ": Normal Spawning Behavior")
	#print(str(self) + " (NormalSpawnBehavior) " + "difficultyTotal: " + str(difficultyTotal))
	getEnemyStats()
	while enemyTotalStats <= difficultyTotal:
		spawnCharacter(dungeonType)
		getEnemyStats()
		$"../StopControl".show()
		await get_tree().create_timer(0.10).timeout
	print(str(self) + " (NormalSpawnBehavior) (check) " + "It's over")
	isCharactersSpawningIn = false
	emit_signal("SpawningIsOver")
	
	$"../SaveWarningLabel".show()
	await get_tree().create_timer(1).timeout
	dungeon.saveToSaveSystem()
	$"../SaveWarningLabel".hide()
	$"../StopControl".hide()
	#print(str(self) + " (NormalSpawnBehavior) " + "It's over")

## Horde Spawning Behavior, difficulty manipulation for higher rates, also lower exp
func HordeSpawnBehavior(): # <- For some reason this is the most reliable spawner
	print(str(self) + ": Horde Spawning Behavior (check) ")
	var LdifficultyTotal = difficultyTotal * 1.25
	print(str(self) + "LdifficultyTotal: " + str(LdifficultyTotal))
	charityDifficultyEXP *= 0.05
	print("charityDifficultyEXP: " + str(charityDifficultyEXP))
	enemyPartyContainer.difficultyEXP = charityDifficultyEXP
	getEnemyStats()
	while enemyTotalStats <= LdifficultyTotal:
		#print(str(self) + " (HordeSpawnBehavior) " + ": total total: " + str(total))
		#print(str(self) + " (HordeSpawnBehavior) " + ": enemyTotalStats: " + str(enemyTotalStats))
		spawnCharacter(dungeonType)
		getEnemyStats()
		#print(str(self) + " (HordeSpawnBehavior)" + "enemyPartyContainer totalStatPoins: " + str(enemyTotalStats))
		$"../StopControl".show()
		await get_tree().create_timer(0.10).timeout
	
	print(str(self) + " (HordeSpawnBehavior) " + ": real enemyTotalStats: " + str(enemyTotalStats))
	print(str(self) + " (HordeSpawnBehavior) (check) " + "It's over")
	isCharactersSpawningIn = false
	emit_signal("SpawningIsOver")
	dungeon.saveToSaveSystem()
	
	$"../SaveWarningLabel".show()
	await get_tree().create_timer(1).timeout
	dungeon.saveToSaveSystem()
	$"../SaveWarningLabel".hide()
	$"../StopControl".hide()

## Elite Spawning Behavior, Give enemies higher initial EXP & higher difficulty total
func EliteSpawnBehavior():
	print(str(self) + ": Elite Spawning Behavior")
#	@warning_ignore("unused_variable")
	var LdifficultyTotal = difficultyTotal * 0.5
	charityDifficultyEXP *= 1.25
	print(str(self) + " (EliteSpawnBehavior) " + "charityDifficultyEXP: " + str(charityDifficultyEXP))
	enemyPartyContainer.difficultyEXP = charityDifficultyEXP
	
	print(str(self) + " (EliteSpawnBehavior) " + "LdifficultyTotal: " + str(LdifficultyTotal))
	#print(str(self) + " (EliteSpawnBehavior) " + "LdifficultyTotal: " + str(enemyTotalStats))
	getEnemyStats()
	while enemyTotalStats <= LdifficultyTotal:
		#print(str(self) + " (EliteSpawnBehavior) " + ": total total: " + str(total))
		#print(str(self) + " (EliteSpawnBehavior) " + "enemyPartyContainer totalStatPoins: " + str(enemyPartyContainer.totalStatPoints))
		if randi_range(1, 2) == 1:
			#print(str(self) + " (EliteSpawnBehavior) " + ": Going for dev Type")
			spawnCharacter(dungeonType)
		else:
			#print(str(self) + " (EliteSpawnBehavior) " + ": Going for special Type")
			spawnCharacter(characterType.SPECIAL)
		getEnemyStats()
		$"../StopControl".show()
		await get_tree().create_timer(0.10).timeout
		print(str(self) + " (EliteSpawnBehavior) (check) " + "It's over")
	isCharactersSpawningIn = false
	dungeon.saveToSaveSystem()
	$"../SaveWarningLabel".show()
	await get_tree().create_timer(1).timeout
	dungeon.saveToSaveSystem()
	$"../SaveWarningLabel".hide()
	$"../StopControl".hide()
	emit_signal("SpawningIsOver")


## Get the array which we'll be using to spawn what we want.
func spawnCharacter(spawnCharacterArrayType: characterType):
	var loadedCharactersArray: Array
	match spawnCharacterArrayType: # While adding to the enum, put the new ArrayType here
		characterType.DEV:
			loadedCharactersArray = loadedDevCharactersArray.duplicate(true)
		characterType.SPECIAL:
			loadedCharactersArray = loadedSpecialCharactersArray.duplicate(true)
	
	
	print(str(self) + str(loadedCharactersArray))
	var loadedCharacter
	
#	print(str(self) + "old loadedCharactersArray: " + str(loadedCharactersArray))
#	print(str(self) + "old loadedCharactersArray size: " + str(loadedCharactersArray.size()))
	loadedCharactersArray.shuffle()
	loadedCharacter = loadedCharactersArray.pop_back()
	
	# Have an array choose
	
	var realLoadedCharacter = load(loadedCharacter)
	var instance = realLoadedCharacter.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0, true, Vector2(0, 0))
	enemyPartyContainer.getCharactersInfo()
#	print(str(self) + "new loadedCharactersArray: " + str(loadedCharactersArray))
#	print(str(self) + "new loadedCharactersArray size: " + str(loadedCharactersArray.size()))

## We'll use this to get all the .tscn of characters to put into array that'll eventually be spawned
func getCharactersFilePaths():
#	--[ TEMPLATE ]--
#	This is what it looks like when adding a new character type's folder
#	Look at variable file paths to see what to put
#	Everything in (characterType) <- That's where to replace with type
#
#	if dir(characterType):
#		dir(characterType).list_dir_begin()
#		var file_name = dir(characterType).get_next()
#		while file_name != "":
#			if dir(characterType).current_is_dir():
#				print(dir(characterType).get_current_dir() + "/" + file_name)
#			else:
#				var characterPath = dir(characterType).get_current_dir() + "/" + file_name
#				print(str(self) + str(characterPath))
#				loaded(characterType)CharactersArray.push_back(characterPath)
#			file_name = dir(characterType).get_next()
#	else:
#		push_error("An error occurred when trying to access the path.")
	
	if dirSpecial: # The variable above
		dirSpecial.list_dir_begin()
		var file_name = dirSpecial.get_next()
		while file_name != "":
			if dirSpecial.current_is_dir():
				print(dirSpecial.get_current_dir() + "/" + file_name)
			else:
				var characterPath = dirSpecial.get_current_dir() + "/" + file_name
				print(str(self) + str(characterPath))
				loadedSpecialCharactersArray.push_back(characterPath)
			file_name = dirSpecial.get_next()
	else:
		push_error("An error occurred when trying to access the path.")

	if dirDev:
		dirDev.list_dir_begin()
		var file_name = dirDev.get_next()
		while file_name != "":
			if dirDev.current_is_dir():
				print(dirDev.get_current_dir() + "/" + file_name)
			else:
				var characterPath = dirDev.get_current_dir() + "/" + file_name
				print(str(self) + str(characterPath))
				loadedDevCharactersArray.push_back(characterPath)
			file_name = dirDev.get_next()
	else:
		push_error("An error occurred when trying to access the path.")
		
	# When adding any more game type characters, put that function here
	
	#print(str(self) + ": LoadedCharactersArray = " + str(loadedDevCharactersArray))
	#print(str(self) + ": LoadedCharactersArray = " + str(loadedSpecialCharactersArray))






