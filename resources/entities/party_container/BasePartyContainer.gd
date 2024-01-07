extends Node2D
class_name BasePartyContainer
#--[ AI Notes ]--
# To Do the AI thing we make the enemy AOE spawn in a container & then have a container function
# Which will be activated HERE, the function will do all the figuring out where to put the AOE
# It will examine the AOE Stats & if it's not offensive, use on selfPartyContainer
#


#--[ Some Important Info In Order To Run This Node ]--
@export var system: TurnSystem
#@export var director: DifficultySystem
@export var otherPartyContainer: BasePartyContainer
@export var CQCSpawnArea: BaseSpawnArea
@export var DPSRangedSpawnArea: BaseSpawnArea
@export var SupportSpawnArea: BaseSpawnArea
@export var isFriendly: bool

#--[ For Difficulty System ]--
var totalStatPoints: int = 0

#--[ EXP System ]--
# From self to other PartyContainer
var charityEXP: float = 0
# From other to self PartyContainer
var receivingEXP: float = 0
# Only used for the enemy, difficulty system will interact with the value
var difficultyEXP: float = 0
var characterThatDied

#--[ Get the Characters ]--
var characters
var charactersAmount
var characterIsHealer: Array
var characterIsTank: Array
var characterIsDPSMelee: Array
var characterIsDPSRanged: Array

signal characterChanged
signal allCharactersDead
signal totalStatPointsChanged

#--[ Basic Functions ]--
func _ready():
	getCharactersInfo()

## Grabs children, should all be on BaseCharacter
func getCharactersInfo():
	var LtotalStatPoints: int
	var LcharacterIsHealer: Array
	var LcharacterIsTank: Array
	var LcharacterIsDPSMelee: Array
	var LcharacterIsDPSRanged: Array
	
	characters = get_children()
	charactersAmount = get_child_count()
	
	# Dividing EXP here, best spot
	receivingEXP /= charactersAmount
	
	for i in charactersAmount:
		#Grabs important Nodes
		var character: BaseCharacter = get_child(i)
		var characterStats: StatComponent = get_child(i).get_node("StatComponent")
		
		if characterStats.is_connected("death", onCharacterDeath) == false:
			characterStats.connect("death", onCharacterDeath)
		else:
			print(str(self) + ": It's already connected to onCharacterDeath")
		
		if characterStats.is_connected("levelUp", onCharacterLevelUp) == false:
			characterStats.connect("levelUp", onCharacterLevelUp)
		else:
			print(str(self) + ": It's already connected to onCharacterLevelUp")
			
		match characterStats.role:
			characterStats.rolesList.Healer:
				LcharacterIsHealer.append(character)
			characterStats.rolesList.DPSRanged:
				LcharacterIsDPSRanged.append(character)
			characterStats.rolesList.DPSMelee:
				LcharacterIsDPSMelee.append(character)
			characterStats.rolesList.Tank:
				LcharacterIsTank.append(character)
			_:
				push_error("Line 58-68, Role does not apply to existing ones!")
				
		characterStats.changeEXP(receivingEXP)
		
		# Adds to the temporary totalStatPoints
		LtotalStatPoints += characterStats.totalStatPoints
	# reset receiving EXP since we're done using it, also to not use excess
	receivingEXP = 0
	print(str(self) + ": Reset receiving EXP")
	
	# Put all temporary variables into the permanent ones
	totalStatPoints = LtotalStatPoints
	
	characterIsHealer = LcharacterIsHealer
	characterIsTank = LcharacterIsTank
	characterIsDPSMelee = LcharacterIsDPSMelee
	characterIsDPSRanged = LcharacterIsDPSRanged
	print(str(self) + ": Healer Array: " + str(characterIsHealer))
	print(str(self) + ": DPSMelee Array: " + str(characterIsDPSMelee))
	print(str(self) + ": DPSRanged Array: " + str(characterIsDPSRanged))
	print(str(self) + ": Tank Array: " + str(characterIsTank))
	
	onAllCharactersDead()
	if isFriendly:
		print(str(self) + ": Friendly Total Stat Points = " + str(totalStatPoints))
		print(str(self) + ": Friendly Characters: " + str(characters))
		print(str(self) + ": Friendly Character Amount: " + str(charactersAmount))
	else:
		print(str(self) + ": Enemy Total Stat Points = " + str(totalStatPoints))
		print(str(self) + ": Enemy Characters" + str(characters))
		print(str(self) + ": Enemy Character Amount: " + str(charactersAmount))
		

func addCharacter(character: BaseCharacter):
	print(str(self) + ": Spawning: " + str(character))
	var characterStats: StatComponent = character.get_node("StatComponent")
	
	var role = characterStats.role
	
	if isFriendly:
		character.isFriendly = true
		add_child(character, true)
		
		match role:
			characterStats.rolesList.Healer:
				character.set_position(SupportSpawnArea.randomizeSpawn())
				print(character.global_position)
			characterStats.rolesList.Tank: 
				character.set_position(CQCSpawnArea.randomizeSpawn())
			characterStats.rolesList.DPSMelee: 
				character.set_position(CQCSpawnArea.randomizeSpawn())
			characterStats.rolesList.DPSRanged: 
				character.set_position(DPSRangedSpawnArea.randomizeSpawn())
	else:
		character.isFriendly = false
		add_child(character, true)
		characterStats.changeEXP(randomizeDifficultyEXP())
		match role:
			characterStats.rolesList.Healer:
				character.set_position(SupportSpawnArea.randomizeSpawn())
				print(character.global_position)
			characterStats.rolesList.Tank: 
				character.set_position(CQCSpawnArea.randomizeSpawn())
			characterStats.rolesList.DPSMelee: 
				character.set_position(CQCSpawnArea.randomizeSpawn())
			characterStats.rolesList.DPSRanged: 
				character.set_position(DPSRangedSpawnArea.randomizeSpawn())
	
	getCharactersInfo()

## using a signal, this function does stuff when a character dies
func onCharacterDeath(EXPWorth):
	print(str(self) + ": Character Died, giving EXPWorth = " + str(EXPWorth))
	addCharityEXPTotal(EXPWorth)
	getCharactersInfo()
	onAllCharactersDead()

func onCharacterLevelUp():
	print(str(self) + ": Character just Leveled Up")
	getCharactersInfo()

## Randomizes difficulty Experience
func randomizeDifficultyEXP():
	var LdifficultyEXP = difficultyEXP
	LdifficultyEXP += randf_range(5.0, 25.0)
	print(str(self) + ": DifficultyEXP Given: " + str(LdifficultyEXP))
	return LdifficultyEXP

# Use @export in difficultySystem to point to this container
# then we'll something like, EnemyPartyContainer.setDifficultyEXP, in some function
## This what the difficulty system will interact to set it
func setDifficultyEXP(EXP: float):
	difficultyEXP = EXP
	print(str(self) + ": DifficultyEXP: " + str(difficultyEXP))

## Adds to Charity EXP
func addCharityEXPTotal(EXP):
	charityEXP += EXP
	print(str(self) + ": charityEXP: " + str(charityEXP))

func giveCharityEXPTotal():
	otherPartyContainer.receivingEXP = charityEXP
	charityEXP = 0

# does something if all characters dead
func onAllCharactersDead():
	if charactersAmount <= 0:
		if isFriendly:
			pass
		else:
			print(str(self) + ": Battle should have ended")
			system.newBattle()

#--[ Custom Functions ]--

func customOnCharacterDeath():
	pass

func customOnAllCharactersDead():
	pass
