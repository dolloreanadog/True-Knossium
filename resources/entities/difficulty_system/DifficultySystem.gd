extends Node
class_name difficultySystem

#--[ Important Nodes ]--
# We get the total used for difficulty, deciding how to strong it should be
@export var friendlyPartyContainer: BasePartyContainer
# We use this to figure out if we should stop spawning enemies
@export var enemyPartyContainer: BasePartyContainer
# We use this for if the battle ends, it spawn them back
@export var system: TurnSystem

#--[ Variable difficulty ]--
# if over this stop spawning
var difficultyTotal: float
var friend
var enemyTotalStats: float
var charityDifficultyEXP: float = 1

var battleSignalTimes: int = 0

#--[ Variable Paths ]--
var dirDev = DirAccess.open("res://resources/entities/characters_items/character/dev_game_characters")
var dirSpecial = DirAccess.open("res://resources/entities/characters_items/character/special_game_characters")
var extension = "tscn"

#--[ character loading ]--
enum characterType {DEV, DUNGEON, GARDEN, FACTORY, LOBORATORY, BATTLEFIELD, SPECIAL}

var loadedDevCharactersArray: Array
var loadedSpecialCharactersArray: Array

func _ready():
	getCharactersFilePaths()
	system.connect("OnNewBattle", onBattleNew)

func onBattleNew():
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
	# Dp this, have like a random chance at determining your fate.
	match randi_range(1, 6):
		1:
			NormalSpawnBehavior()
		2:
			NormalSpawnBehavior()
		3:
			NormalSpawnBehavior()
		4:
			HordeSpawnBehavior()
		5: 
			HordeSpawnBehavior()
		6:
			EliteSpawnBehavior()

func NormalSpawnBehavior():
	print(str(self) + " (NormalSpawnBehavior) " + ": Normal Spawning Behavior")
	print(str(self) + " (NormalSpawnBehavior) " + "difficultyTotal: " + str(difficultyTotal))
	getEnemyStats()
	while enemyTotalStats <= difficultyTotal:
		spawnCharacter(characterType.DEV)
		getEnemyStats()
	print(str(self) + " (NormalSpawnBehavior) " + "It's over")

# Here up the difficulty by * 1.5
# But give less experience points
func HordeSpawnBehavior(): # <- For some reason this is the most reliable spawner
	print(str(self) + ": Horde Spawning Behavior")
	var total = 0
	var LdifficultyTotal = difficultyTotal * 1.25
	print(str(self) + "LdifficultyTotal: " + str(LdifficultyTotal))
	charityDifficultyEXP *= 0.05
	print("charityDifficultyEXP: " + str(charityDifficultyEXP))
	enemyPartyContainer.difficultyEXP = charityDifficultyEXP
	getEnemyStats()
	while enemyTotalStats <= LdifficultyTotal:
		total += 1
		print(str(self) + " (HordeSpawnBehavior) " + ": total total: " + str(total))
		print(str(self) + " (HordeSpawnBehavior) " + ": enemyTotalStats: " + str(enemyTotalStats))
		spawnCharacter(characterType.DEV)
		getEnemyStats()
		print(str(self) + " (HordeSpawnBehavior) " + "enemyPartyContainer totalStatPoins: " + str(enemyTotalStats))
	
	print(str(self) + " (HordeSpawnBehavior) " + ": real total total: " + str(total))
	print(str(self) + " (HordeSpawnBehavior) " + ": real enemyTotalStats: " + str(enemyTotalStats))
	print(str(self) + " (HordeSpawnBehavior) " + "It's over")
	

# Here up the difficulty by * 1.75
# But give a lot of experience points
# Don't worry about having hard limit, we already solved that
func EliteSpawnBehavior():
	print(str(self) + ": Elite Spawning Behavior")
	var total = 0
	var LdifficultyTotal = difficultyTotal * 1.5
	charityDifficultyEXP *= 1.25
	print(str(self) + " (EliteSpawnBehavior) " + "charityDifficultyEXP: " + str(charityDifficultyEXP))
	enemyPartyContainer.difficultyEXP = charityDifficultyEXP
	
	print(str(self) + " (EliteSpawnBehavior) " + "LdifficultyTotal: " + str(LdifficultyTotal))
	#print(str(self) + " (EliteSpawnBehavior) " + "LdifficultyTotal: " + str(enemyTotalStats))
	getEnemyStats()
	while enemyTotalStats <= LdifficultyTotal: # <- We're somehowskipping This?
		total += 1
		print(str(self) + " (EliteSpawnBehavior) " + ": total total: " + str(total))
		print(str(self) + " (EliteSpawnBehavior) " + "enemyPartyContainer totalStatPoins: " + str(enemyPartyContainer.totalStatPoints))
		if randi_range(1, 2) == 1:
			print(str(self) + " (EliteSpawnBehavior) " + ": Going for dev Type")
			spawnCharacter(characterType.DEV)
		else:
			print(str(self) + " (EliteSpawnBehavior) " + ": Going for special Type")
			spawnCharacter(characterType.SPECIAL)
		
		getEnemyStats()
	print(str(self) + " (EliteSpawnBehavior) " + "It's over")

func spawnCharacter(spawnCharacterArrayType: characterType):
	var loadedCharactersArray: Array
	match spawnCharacterArrayType:
		characterType.DEV:
			loadedCharactersArray = loadedDevCharactersArray.duplicate(true)
		characterType.SPECIAL:
			loadedCharactersArray = loadedDevCharactersArray.duplicate(true) #Temporary
	
	
	print(str(self) + str(loadedCharactersArray))
	var loadedCharacter
	
	print(str(self) + "old loadedCharactersArray: " + str(loadedCharactersArray))
	print(str(self) + "old loadedCharactersArray size: " + str(loadedCharactersArray.size()))
	loadedCharactersArray.shuffle()
	loadedCharacter = loadedCharactersArray.pop_back()
	
	# Have an array choose
	
	var realLoadedCharacter = load(loadedCharacter)
	var instance = realLoadedCharacter.instantiate()
	enemyPartyContainer.addCharacter(instance)
	enemyPartyContainer.getCharactersInfo()
	print(str(self) + "new loadedCharactersArray: " + str(loadedCharactersArray))
	print(str(self) + "new loadedCharactersArray size: " + str(loadedCharactersArray.size()))


func getCharactersFilePaths():
	if dirSpecial:
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
		print("An error occurred when trying to access the path.")

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
		print("An error occurred when trying to access the path.")
		
	# When adding any more game type characters, put that function here
	
	print(str(self) + ": LoadedCharactersArray = " + str(loadedDevCharactersArray))
	print(str(self) + ": LoadedCharactersArray = " + str(loadedSpecialCharactersArray))



	#"res://resources/entities/characters_items/character/game_characters/DevArcherCharacter.tscn"
	# ^ This is what it normally looks like, well should look like
	#"res://resources/entities/characters_items/character/game_characters/(x)"
	# ^ (x) <- This here what we just have to change
	# Preferably we just grab every single creature



