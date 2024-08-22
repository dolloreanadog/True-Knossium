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
var enemyTotalStats: float
var charityDifficultyEXP: float = 1

#--[ Variable Paths ]--


#--[ character loading ]--
var isCharactersSpawningIn: bool = false
# This has to with console, make this true if guaranteed
var debugGuaranteeSpawning: bool = false
var debugChosenSpawnBehavior: int

@export var SpawnBehaviors: Dictionary = {
	"Normal Spawn Behavior": 750,
	"Horde Spawn Behavior": 50,
	"Elite Spawn Behavior": 25,
	"Legendary Spawn Behavior": 15,
	"Mythical Spawn Behavior": 5,
	"God Spawn Behavior": 0,
}

var loadedDevCharactersArray: Array
var loadedSpecialCharactersArray: Array

signal SpawningIsOver
signal SpawnNormals
signal SpawnHorde
signal SpawnSpecials
signal SpawnLegendary
signal SpawnMythical
signal SpawnGod

func _ready() -> void:
	pass
#	getCharactersFilePaths()
#	system.connect("OnNewBattle", onBattleNew)
	#dungeon.connect("AOEQueueFinished")

func onBattleNew() -> void:
	isCharactersSpawningIn = true
	if debugGuaranteeSpawning != true:
		randomSpawningBehavior()
	else:
		print("Guaranteed Debug Spawning of behavior")
		match debugChosenSpawnBehavior:
			1:
				chooseSpawnBehavior("Normal Spawn Behavior")
			2:
				chooseSpawnBehavior("Horde Spawn Behavior")
			3:
				chooseSpawnBehavior("Elite Spawn Behavior")
			4:
				chooseSpawnBehavior("Legendary Spawn Behavior")
			5:
				chooseSpawnBehavior("Mythical Spawn Behavior")
			6: 
				chooseSpawnBehavior("God Spawn Behavior")
	
	print("(check) new battle in difficulty")
	for i in dungeon.grabAllAOE().size():
		var aoe: BaseAOE = dungeon.grabAllAOE()[i]
		aoe.queue_free()

# We use here to decide what kind of characterType we're getting
func getDungeonType():
	pass

func updateDifficultyTotal() -> void:
	difficultyTotal = (friendlyPartyContainer.getTotalStatPoints() + (system.battle * 5) + (float(system.turn) / 2)) * 0.90
	charityDifficultyEXP = difficultyTotal * 0.1

func getEnemyStats() -> void:
	enemyTotalStats = enemyPartyContainer.getTotalStatPoints()

func chooseSpawnBehavior(spawnBehavior: String):
	match spawnBehavior:
		"Normal Spawn Behavior":
			NormalSpawnBehavior()
			
			# Change Weight as it was chosen so others get a chance
			SpawnBehaviors["Normal Spawn Behavior"] -= 50
			SpawnBehaviors["Horde Spawn Behavior"] += 7.5
			SpawnBehaviors["Elite Spawn Behavior"] += 7.5
			SpawnBehaviors["Legendary Spawn Behavior"] += 2.5
			SpawnBehaviors["Mythical Spawn Behavior"] += 1
			SpawnBehaviors["God Spawn Behavior"] += 0.05
		"Horde Spawn Behavior":
			HordeSpawnBehavior()
			
			# Change Weight as it was chosen so others get a chance
			SpawnBehaviors["Normal Spawn Behavior"] += 25
			SpawnBehaviors["Horde Spawn Behavior"] -= 15
			SpawnBehaviors["Elite Spawn Behavior"] += 7.5
			SpawnBehaviors["Legendary Spawn Behavior"] += 2.5
			SpawnBehaviors["Mythical Spawn Behavior"] += 1
			SpawnBehaviors["God Spawn Behavior"] += 0.05
		"Elite Spawn Behavior":
			EliteSpawnBehavior()
			
			# Change Weight as it was chosen so others get a chance
			SpawnBehaviors["Normal Spawn Behavior"] += 25
			SpawnBehaviors["Horde Spawn Behavior"] += 7.5
			SpawnBehaviors["Elite Spawn Behavior"] -= 15
			SpawnBehaviors["Legendary Spawn Behavior"] += 2.5
			SpawnBehaviors["Mythical Spawn Behavior"] += 1
			SpawnBehaviors["God Spawn Behavior"] += 0.05
		"Legendary Spawn Behavior":
			LegendarySpawnBehavior()

			# Change Weight as it was chosen so others get a chance
			SpawnBehaviors["Normal Spawn Behavior"] += 15
			SpawnBehaviors["Horde Spawn Behavior"] += 7.5
			SpawnBehaviors["Elite Spawn Behavior"] += 7.5
			SpawnBehaviors["Legendary Spawn Behavior"] -= 10
			SpawnBehaviors["Mythical Spawn Behavior"] += 1
			SpawnBehaviors["God Spawn Behavior"] += 0.05
		"Mythical Spawn Behavior":
			MythicalSpawnBehavior()

			# Change Weight as it was chosen so others get a chance
			SpawnBehaviors["Normal Spawn Behavior"] += 15
			SpawnBehaviors["Horde Spawn Behavior"] += 7.5
			SpawnBehaviors["Elite Spawn Behavior"] += 7.5
			SpawnBehaviors["Legendary Spawn Behavior"] += 2.5
			SpawnBehaviors["Mythical Spawn Behavior"] -= 10
			SpawnBehaviors["God Spawn Behavior"] += 0.05
#		"God Spawn Behavior":
#			GodSpawnBehavior()
#
#			# Change Weight as it was chosen so others get a chance
#			SpawnBehaviors["Normal Spawn Behavior"] += 15
#			SpawnBehaviors["Horde Spawn Behavior"] += 10
#			SpawnBehaviors["Elite Spawn Behavior"] += 10
#			SpawnBehaviors["Legendary Spawn Behavior"] += 2.5
#			SpawnBehaviors["Mythical Spawn Behavior"] += 1
#			SpawnBehaviors["God Spawn Behavior"] -= 20
		_:
			push_warning("That Spawn Behavior was not added defaulting to Elite Spawn Behavior")
			EliteSpawnBehavior()
			
			# Change Weight as it was chosen so others get a chance
			SpawnBehaviors["Normal Spawn Behavior"] += 15
			SpawnBehaviors["Horde Spawn Behavior"] += 7.5
			SpawnBehaviors["Elite Spawn Behavior"] -= 15
			SpawnBehaviors["Legendary Spawn Behavior"] += 2.5
			SpawnBehaviors["Mythical Spawn Behavior"] += 1
			SpawnBehaviors["God Spawn Behavior"] += 0.05

func GetWhichSpawnBehavior() -> String:
#	rng.randomize()
	
	var weightedSum: float = 0
	
	# Get Our weightedSum here
	for n in SpawnBehaviors:
		weightedSum += SpawnBehaviors[n]
	
	# We see what number we got
	var item: float = randf_range(0, weightedSum)
#	print("Our item range " + str(item))
	
	# Choose which item we get
	for n in SpawnBehaviors:
		if item <= SpawnBehaviors[n]:
			return n
		else:
			item -= SpawnBehaviors[n]
	return SpawnBehaviors[0]

func randomSpawningBehavior() -> void:
	updateDifficultyTotal()
	print("Charity difficulty EXP Start: " + str(charityDifficultyEXP))
	# We Changing This
	var number: float = snappedf(randf_range(0, 90), 0.01)
	print("number is " + str(number))
	
	var spawnBehavior = GetWhichSpawnBehavior()
	chooseSpawnBehavior(spawnBehavior)

## Normal Spawning Behavior, no exp or difficulty total manipulation
func NormalSpawnBehavior() -> void:
	difficultyTotal /= get_signal_connection_list("SpawnNormals").size()
	SpawnNormals.emit()
#	print(str(self) + " (NormalSpawnBehavior)" + ": Normal Spawning Behavior")
#	print(str(self) + "LdifficultyTotal: " + str(difficultyTotal))
#	print(str(self) + " (NormalSpawnBehavior) " + " charityDifficultyEXP: " + str(charityDifficultyEXP))
#	enemyPartyContainer.difficultyEXP = charityDifficultyEXP
#	getEnemyStats()
#	dungeon.stopControlVisible(true, 1)
#	while enemyTotalStats <= difficultyTotal:
#		dungeon.stopControlVisible(true, 1)
#		spawnCharacter(dungeonType)
#		getEnemyStats()
##		dungeon.stopControl.show()
#		await get_tree().create_timer(0.10).timeout
#	print(str(self) + " (NormalSpawnBehavior) " + "It's over")
#	isCharactersSpawningIn = false
#	emit_signal("SpawningIsOver")
#
#	dungeon.SaveWarningLabel.show()
#	await get_tree().create_timer(1).timeout
#	dungeon.saveToSaveSystem()
#	dungeon.SaveWarningLabel.hide()
#	dungeon.stopControlVisible(false, 1)
#	dungeon.stopControl.hide()
	#print(str(self) + " (NormalSpawnBehavior) " + "It's over")

## Horde Spawning Behavior, difficulty manipulation for higher rates, also lower exp
func HordeSpawnBehavior() -> void: # <- For some reason this is the most reliable spawner
	difficultyTotal /= get_signal_connection_list("SpawnHorde").size()
	SpawnHorde.emit()

## Elite Spawning Behavior, Give enemies higher initial EXP & higher difficulty total
func EliteSpawnBehavior() -> void:
	difficultyTotal /= get_signal_connection_list("SpawnSpecials").size()
	SpawnSpecials.emit()

func LegendarySpawnBehavior() -> void:
	difficultyTotal /= get_signal_connection_list("SpawnLegendary").size()
	SpawnLegendary.emit()

func MythicalSpawnBehavior() -> void:
	difficultyTotal /= get_signal_connection_list("SpawnMythical").size()
	SpawnMythical.emit()


## Get the array which we'll be using to spawn what we want.
func SpawnCharacterFromArray(loadedCharactersArray: Array) -> void:
	print(str(self) + str(loadedCharactersArray))
	var loadedCharacter = loadedCharactersArray.pick_random()
	
#	print(str(self) + "old loadedCharactersArray: " + str(loadedCharactersArray))
#	print(str(self) + "old loadedCharactersArray size: " + str(loadedCharactersArray.size()))
	
	# Have an array choose
	
	var realLoadedCharacter = load(loadedCharacter)
	var instance = realLoadedCharacter.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0, true, Vector2(0, 0))
	enemyPartyContainer.getCharactersInfo()
#	print(str(self) + "new loadedCharactersArray: " + str(loadedCharactersArray))
#	print(str(self) + "new loadedCharactersArray size: " + str(loadedCharactersArray.size()))


## Get the array which we'll be using to spawn what we want.
#func spawnCharacter(spawnCharacterArrayType: characterType) -> void:
#	var loadedCharactersArray: Array
#	match spawnCharacterArrayType: # While adding to the enum, put the new ArrayType here
#		characterType.DEV:
#			loadedCharactersArray = loadedDevCharactersArray
#		characterType.SPECIAL:
#			loadedCharactersArray = loadedSpecialCharactersArray
#
#
#	print(str(self) + str(loadedCharactersArray))
#	var loadedCharacter = loadedCharactersArray.pick_random()
	
#	print(str(self) + "old loadedCharactersArray: " + str(loadedCharactersArray))
#	print(str(self) + "old loadedCharactersArray size: " + str(loadedCharactersArray.size()))
	
	# Have an array choose
	
#	var realLoadedCharacter = load(loadedCharacter)
#	var instance = realLoadedCharacter.instantiate()
#	enemyPartyContainer.addCharacter(instance, 0.0, true, Vector2(0, 0))
#	enemyPartyContainer.getCharactersInfo()
#	print(str(self) + "new loadedCharactersArray: " + str(loadedCharactersArray))
#	print(str(self) + "new loadedCharactersArray size: " + str(loadedCharactersArray.size()))

## We'll use this to get all the .tscn of characters to put into array that'll eventually be spawned
#func getCharactersFilePaths() -> void: # WHATEVER YOU DO NOT DELETE THIS TEMPLATE
#	--[ TEMPLATE ]-- 
#	This is what it looks like when adding a new character type's folder
#	Look at variable file paths to see what to put
#	Everything in (characterType) <- That's where to replace with type
#
#	if dir*(characterType):
#		dir*(characterType).list_dir_begin()
#		var file_name = dir*(characterType).get_next()
#		while file_name != "":
#			if dir*(characterType).current_is_dir():
#				print(dir*(characterType).get_current_dir() + "/" + file_name)
#			else:
#				var characterPath = dir*(characterType).get_current_dir() + "/" + file_name
#				print(str(self) + str(characterPath))
#				loaded(characterType)CharactersArray.push_back(characterPath)
#			file_name = dir*(characterType).get_next()
#	else:
#		push_error("An error occurred when trying to access the path.")
	
#	if dirSpecial: # The variable above
#		dirSpecial.list_dir_begin()
#		var file_name = dirSpecial.get_next()
#		while file_name != "":
#			if dirSpecial.current_is_dir():
#				print(dirSpecial.get_current_dir() + "/" + file_name)
#			else:
#				var characterPath = dirSpecial.get_current_dir() + "/" + file_name
#				print(str(self) + str(characterPath))
#				loadedSpecialCharactersArray.push_back(characterPath)
#			file_name = dirSpecial.get_next()
#	else:
#		push_error("An error occurred when trying to access the path.")
#
#	if dirDev:
#		dirDev.list_dir_begin()
#		var file_name = dirDev.get_next()
#		while file_name != "":
#			if dirDev.current_is_dir():
#				print(dirDev.get_current_dir() + "/" + file_name)
#			else:
#				var characterPath = dirDev.get_current_dir() + "/" + file_name
#				print(str(self) + str(characterPath))
#				loadedDevCharactersArray.push_back(characterPath)
#			file_name = dirDev.get_next()
#	else:
#		push_error("An error occurred when trying to access the path.")
	# When adding any more game type characters, put that function here
	
	#print(str(self) + ": LoadedCharactersArray = " + str(loadedDevCharactersArray))
	#print(str(self) + ": LoadedCharactersArray = " + str(loadedSpecialCharactersArray))
