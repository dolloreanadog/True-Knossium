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
@export var AOEDenialRanged: BaseAreaAOEDenial
@export var AOEDenialSupport: BaseAreaAOEDenial
@export var isFriendly: bool
var stopPreEmptiveBattleEnd: bool = true


#--[ For Difficulty System ]--
var totalStatPoints: float = 0

#--[ EXP System ]--
# From self to other PartyContainer
var charityEXP: float = 0
# From other to self PartyContainer
var receivingEXP: float = 0
# Only used for the enemy, difficulty system will interact with the value
var difficultyEXP: float = 0
var characterThatDied

#--[ Get the Characters ]--
var characters: Array
var charactersAmount: int = 0
var characterIsActive: Array
var characterIsHealer: Array
var characterIsTank: Array
var characterIsDPSMelee: Array
var characterIsDPSRanged: Array

var characterDied: bool = false

signal characterChanged
signal charactersUpdated
signal allCharactersDead
signal totalStatPointsChanged

#--[ Basic Functions ]--
func _ready():
	getCharactersInfo()
	system.connect("OnNewTurn", newTurn)

func newTurn():
	getCharactersInfo()


## Grabs children, should all be on BaseCharacter
func getCharactersInfo():
	if characterDied:
		print(str(self) + ": Getting Character Info, because character Died")
		characterDied = false
	else:
		print(str(self) + ": Getting Character Info")
	var LtotalStatPoints: int = 0
	var LcharacterIsHealer: Array = []
	var LcharacterIsTank: Array = []
	var LcharacterIsDPSMelee: Array = []
	var LcharacterIsDPSRanged: Array = []
	
	characters = get_children()
	charactersAmount = get_child_count()
	
	print(str(self) + ": (getCharactersInfo) characters: " + str(characters))
	print(str(self) + ": (getCharactersInfo) charactersAmount: " + str(charactersAmount))
	# Dividing EXP here, best spot
	receivingEXP /= charactersAmount
	
	for i in charactersAmount:
		#Grabs important Nodes
		var character: BaseCharacter = get_child(i)
		var characterStats: StatComponent = get_child(i).get_node("StatComponent")
		
		if characterStats.is_connected("death", onCharacterDeath) == false:
			characterStats.connect("death", onCharacterDeath)
		else:
			pass
			#print(str(self) + ": It's already connected to onCharacterDeath")
			
		if characterStats.currentHealth <= 0:
			push_warning("Trying to push a character that's Dead")
		else:
			#characters.append(character)
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
					
			print(str(self) + ": Receiving EXP: " + str(receivingEXP))
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
	characterIsActive = characterIsHealer + characterIsTank + characterIsDPSMelee + characterIsDPSRanged
	
	
	# Set the AreaAOEDenial to active or not
	# An Idea to fix this is to move it to the BaseAOEAreaDenial
	if characterIsTank.size() == 0 && characterIsDPSMelee.size() == 0:
		AOEDenialRanged.setActive(false)
	else:
		AOEDenialRanged.setActive(true)
	if characterIsDPSRanged.size() == 0 && characterIsTank.size() == 0 && characterIsDPSMelee.size() == 0:
		AOEDenialSupport.setActive(false)
	else: 
		AOEDenialSupport.setActive(true)
	
	if isFriendly:
		print(str(self) + ": Friendly Total Stat Points = " + str(totalStatPoints))
#		print(str(self) + ": Turn: " + str(system.turn) + ": Friendly Characters: " + str(characters))
#		print(str(self) + ": Turn: " + str(system.turn) + ": Friendly Character Amount: " + str(charactersAmount))
	else:
		print(str(self) + ": Enemy Total Stat Points = " + str(totalStatPoints))
#		print(str(self) + ": Turn: " + str(system.turn) + ": Enemy Characters" + str(characters))
#		print(str(self) + ": Turn: " + str(system.turn) + ": Enemy Character Amount: " + str(charactersAmount))
	emit_signal("charactersUpdated")

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
		if character.characterSprite != null:
			character.characterSprite.flip_h = true
		match role:
			characterStats.rolesList.Healer:
				character.set_position(SupportSpawnArea.randomizeSpawn())
			characterStats.rolesList.Tank: 
				character.set_position(CQCSpawnArea.randomizeSpawn())
			characterStats.rolesList.DPSMelee: 
				character.set_position(CQCSpawnArea.randomizeSpawn())
			characterStats.rolesList.DPSRanged: 
				character.set_position(DPSRangedSpawnArea.randomizeSpawn())
	
	getCharactersInfo()

## using a signal, this function does stuff when a character dies
func onCharacterDeath(EXPWorth, characterBody):
	print(str(self) + ": (onCharacterDeath) Character Died, giving EXPWorth = " + str(EXPWorth))
	characterDied = true
	addCharityEXPTotal(EXPWorth)
	await get_tree().create_timer(randf_range(0.01, 0.1)).timeout
	print(str(self) + ": (onCharacterDeath) old Character Died " + str(characterBody))
	#print(str(self) + ": (onCharacterDeath) isInstanceValid: " + str(is_instance_valid(characterBody)))
	if is_instance_valid(characterBody):
		remove_child(characterBody)
		characterBody.queue_free()
		print(str(self) + ": (onCharacterDeath) new Character Died" + str(characterBody))
		getCharactersInfo()
		onAllCharactersDead()
	else:
		characters.filter(func(object): return object != characterBody)

## Randomizes difficulty Experience
func randomizeDifficultyEXP():
	var LdifficultyEXP = randf_range(5.0, 25.0)
	LdifficultyEXP *= difficultyEXP
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
	print(str(self) + ": new charityEXP: " + str(charityEXP))
	giveCharityEXPTotal()

func giveCharityEXPTotal():
	otherPartyContainer.receivingEXP = charityEXP
	charityEXP = 0
	print(str(self) + ": old charityEXP: " + str(charityEXP))

# does something if all characters dead
func onAllCharactersDead(): # When more than 1 character dies, it just breaks <- I don't this is the reason
	print(str(self) + ": Checking if characters are dead")
	if charactersAmount <= 0:
		print(str(self) + ": All Characters Died")
		if isFriendly:
			pass
		else:
			print(str(self) + ": Battle should have ended")
			system.newBattle()

#--[ Info Get ]--
func getCharactersArray():
	var exportedCharactersArray = characterIsActive
	return exportedCharactersArray

func getTankArray():
	var exportedTankArray = characterIsTank
	return exportedTankArray

func getMeleeArray():
	var exportedMeleeArray = characterIsDPSMelee
	return exportedMeleeArray

func getRangedArray():
	var exportedRangedArray = characterIsDPSRanged
	return exportedRangedArray

func getSupportArray():
	var exportedSupportArray = characterIsHealer
	return exportedSupportArray

func getTotalStatPoints():
	var exportedTotalStatPoints = totalStatPoints
	return exportedTotalStatPoints

#--[ Custom Functions ]--

func customOnCharacterDeath():
	pass

func customOnAllCharactersDead():
	pass
