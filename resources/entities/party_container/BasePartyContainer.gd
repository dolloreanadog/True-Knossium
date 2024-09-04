extends Node2D
class_name BasePartyContainer
#--[ AI Notes ]--
# To Do the AI thing we make the enemy AOE spawn in a container & then have a container function
# Which will be activated HERE, the function will do all the figuring out where to put the AOE
# It will examine the AOE Stats & if it's not offensive, use on selfPartyContainer
#


#--[ Some Important Info In Order To Run This Node ]--
@export_category("Important Nodes")
@onready var dungeon: BaseLevel = get_parent().get_parent()
@export var system: TurnSystem
#@export var director: DifficultySystem
@export var otherPartyContainer: BasePartyContainer
@export_category("AOE Containers")
@export var CQCSpawnArea: BaseSpawnArea
@export var DPSRangedSpawnArea: BaseSpawnArea
@export var SupportSpawnArea: BaseSpawnArea
@export_category("Denial Areas")
@export var AOEDenialRanged: BaseAreaAOEDenial
@export var AOEDenialSupport: BaseAreaAOEDenial
@export var isFriendly: bool
var stopPreEmptiveBattleEnd: bool = true


#--[ For Difficulty System ]--
var totalStatPoints: float = 0

# Not for Difficulty System
var currentTotalStatPoints: float = 0

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

var isSpawningCharacter: bool = false
var characterDied: bool = false

signal characterChanged
signal charactersUpdated
signal characterHasDied
signal allCharactersDead
signal totalStatPointsChanged

#--[ Basic Functions ]--
func _ready():
	getCharactersInfo()
	system.connect("OnNewTurn", newTurn)

func newTurn():
	getCharactersInfo()

func AnyAOEAnimationPlaying() -> bool:
	var playing: bool = false
	if get_child_count() != 0:
		playing = get_children().any(func(object: BaseCharacter): return object.characterAnimation.is_playing())
	print("(check5) is playing character? " + str(playing))
	return playing


func AnyCharacterSurrendered() -> bool:
	var isAnySurrendered: bool = false
	if get_child_count() != 0:
		isAnySurrendered = dungeon.enemyPartyContainer.get_children().any(func(object: BaseCharacter): return object.stats.moraleAlreadyBroken)
	return isAnySurrendered

## Grabs children, should all be on BaseCharacter
func getCharactersInfo() -> void:
	if characterDied:
#		print(str(self) + ": Getting Character Info, because character Died")
		characterDied = false
	else:
		pass
#		print(str(self) + ": Getting Character Info")
	var LtotalStatPoints: int = 0
	var LtotalCurrentStatPoints: float =0
	var LcharacterIsHealer: Array = []
	var LcharacterIsTank: Array = []
	var LcharacterIsDPSMelee: Array = []
	var LcharacterIsDPSRanged: Array = []
	
	characters = get_children()
	charactersAmount = get_child_count()
#	print(str(self) + ": (check) characters: " + str(characters))
#	print(str(self) + ": (check) charactersAmount: " + str(charactersAmount))
	
	# Dividing EXP here to split between characters
	if isFriendly:
		receivingEXP /= charactersAmount * 2.5
	else:
		receivingEXP /= charactersAmount * 2
	
	for i in charactersAmount:
		#Grabs important Nodes
		var character: BaseCharacter = get_child(i)
		var characterStats: StatComponent = get_child(i).get_node("StatComponent")
		
		if characterStats.currentHealth <= 0:
			pass
			push_warning("Trying to push a character that's Dead")
		else:
			
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
					
#			print(str(self) + ": Receiving EXP: " + str(receivingEXP))
			characterStats.changeEXP(receivingEXP)
			
			# Adds to the temporary totalStatPoints
			LtotalStatPoints += characterStats.totalStatPoints
			LtotalCurrentStatPoints += characterStats.getCurrentTotalStatPoints()
		await get_tree().create_timer(0.001).timeout
#		await get_tree().create_timer(0.01).timeout
	# reset receiving EXP since we're done using it, also to not use excess
	receivingEXP = 0
	print(str(self) + ": Reset receiving EXP")
	
	# Put all temporary variables into the permanent ones
	currentTotalStatPoints = LtotalCurrentStatPoints
	totalStatPoints = LtotalStatPoints
	
	characterIsHealer = LcharacterIsHealer
	characterIsTank = LcharacterIsTank
	characterIsDPSMelee = LcharacterIsDPSMelee
	characterIsDPSRanged = LcharacterIsDPSRanged
	characterIsActive = characterIsHealer + characterIsTank + characterIsDPSMelee + characterIsDPSRanged
	
	# Set the AreaAOEDenial to active or not
	if characterIsTank.size() == 0 && characterIsDPSMelee.size() == 0:
		AOEDenialRanged.setActive(false)
	else:
		AOEDenialRanged.setActive(true)
	if characterIsDPSRanged.size() == 0 && characterIsTank.size() == 0 && characterIsDPSMelee.size() == 0:
		AOEDenialSupport.setActive(false)
	else: 
		AOEDenialSupport.setActive(true)
	await get_tree().create_timer(0.001).timeout
	emit_signal("charactersUpdated")

func MoveAllCharactersToTruePosition() -> void:
	getCharactersInfo()
	isSpawningCharacter = true
	for i in charactersAmount:
		var character: BaseCharacter = characters[i]
		var tween: Tween = get_tree().create_tween().bind_node(character)
		tween.tween_property(character, "global_position", character.trueGlobalPosition, 1)
		await get_tree().create_timer(randf_range(0, 0.15)).timeout
	isSpawningCharacter = false
	CharacterInCorrectPosition()
	dungeon.stopControlVisible(false, 1)

func CharacterInCorrectPosition() -> void:
	for i in charactersAmount:
		var character: BaseCharacter = characters[i]
		if character.global_position != character.trueGlobalPosition:
			character.set_global_position(character.trueGlobalPosition)

func addCharacter(character: BaseCharacter, startingExperience: float, spawnedFromDifficulty: bool, characterPosition: Vector2):
	print(str(self) + ": Spawning: " + str(character))
	print(str(self) + ": spawnedFromDifficulty: " + str(spawnedFromDifficulty))
	var tween: Tween = get_tree().create_tween().bind_node(character)
	print("Tween: " + str(tween))
	var characterStats: StatComponent = character.get_node("StatComponent")
	
	var role := characterStats.role
	var spot: Vector2
	
	if characterStats.is_connected("death", onCharacterDeath) == false:
		characterStats.connect("death", onCharacterDeath)
	if characterStats.is_connected("moraleBroken", onCharacterDeath) == false:
		characterStats.connect("moraleBroken", onCharacterDeath)
	
	if isFriendly:
		character.isFriendly = true
		add_child(character, true)
		character.stats.changeEXP(startingExperience)
		if character.characterSprite != null:
			character.characterSprite.flip_h = false
		match role:
			characterStats.rolesList.Healer:
				if Vector2(0, 0) == characterPosition:
					spot = SupportSpawnArea.randomizeSpawn()
					character.trueGlobalPosition = spot
					character.set_position(spot - Vector2(150, 0))
					tween.tween_property(character, "global_position", spot, 1)
				else:
					character.set_position(characterPosition)
					tween.tween_property(character, "global_position", characterPosition, 1)
			characterStats.rolesList.Tank: 
				if Vector2(0, 0) == characterPosition:
					spot = CQCSpawnArea.randomizeSpawn()
					character.trueGlobalPosition = spot
					character.set_position(spot - Vector2(550, 0))
					tween.tween_property(character, "global_position", spot, 1)
				else:
					character.set_position(characterPosition)
					tween.tween_property(character, "global_position", characterPosition, 1)
			characterStats.rolesList.DPSMelee: 
				if Vector2(0, 0) == characterPosition:
					spot = CQCSpawnArea.randomizeSpawn()
					character.trueGlobalPosition = spot
					character.set_position(spot - Vector2(550, 0))
					tween.tween_property(character, "global_position", spot, 1)
				else:
					character.set_position(characterPosition)
					tween.tween_property(character, "global_position", characterPosition, 1)
			characterStats.rolesList.DPSRanged: 
				if Vector2(0, 0) == characterPosition:
					spot = DPSRangedSpawnArea.randomizeSpawn()
					character.trueGlobalPosition = spot
					character.set_position(spot - Vector2(300, 0))
					tween.tween_property(character, "global_position", spot, 1)
				else:
					character.set_position(characterPosition)
					tween.tween_property(character, "global_position", characterPosition, 1)
	else:
		character.isFriendly = false
		add_child(character, true)
		character.stats.changeEXP(startingExperience)
		if spawnedFromDifficulty:
			characterStats.changeEXP(randomizeDifficultyEXP())
		if character.characterSprite != null:
			character.characterSprite.flip_h = true
		match role:
			characterStats.rolesList.Healer:
				if Vector2(0, 0) == characterPosition:
					spot = SupportSpawnArea.randomizeSpawn()
					character.trueGlobalPosition = spot
					character.set_position(spot + Vector2(150, 0))
					await tween.tween_property(character, "global_position", spot, 1).finished
				else:
					character.set_position(characterPosition)
					await tween.tween_property(character, "global_position", characterPosition, 1).finished
			characterStats.rolesList.Tank: 
				if Vector2(0, 0) == characterPosition:
					spot = CQCSpawnArea.randomizeSpawn()
					character.trueGlobalPosition = spot
					character.set_position(spot + Vector2(550, 0))
					await tween.tween_property(character, "global_position", spot, 1).finished
				else:
					character.set_position(characterPosition)
					await tween.tween_property(character, "global_position", characterPosition, 1).finished
			characterStats.rolesList.DPSMelee: 
				if Vector2(0, 0) == characterPosition:
					spot = CQCSpawnArea.randomizeSpawn()
					character.trueGlobalPosition = spot
					character.set_position(spot + Vector2(550, 0))
					await tween.tween_property(character, "global_position", spot, 1).finished
				else:
					character.set_position(characterPosition)
					await tween.tween_property(character, "global_position", characterPosition, 1).finished
			characterStats.rolesList.DPSRanged: 
				if Vector2(0, 0) == characterPosition:
					spot = DPSRangedSpawnArea.randomizeSpawn()
					character.trueGlobalPosition = spot
					character.set_position(spot + Vector2(300, 0))
					await tween.tween_property(character, "global_position", spot, 1).finished
				else:
					character.set_position(characterPosition)
					await tween.tween_property(character, "global_position", characterPosition, 1).finished
	
	dungeon.statButtonGroup.updateModulation()
	tween.kill()

## using a signal, this function does stuff when a character dies
func onCharacterDeath(EXPWorth, characterBody):
	print(str(self) + ": (onCharacterDeath) Character Died, giving EXPWorth = " + str(EXPWorth))
	characterDied = true
	addCharityEXPTotal(EXPWorth)
	# if container is enemy, give the character drop to the inventorySystem
	await get_tree().create_timer(0.04).timeout
	print(str(self) + ": (onCharacterDeath) old Character Died " + str(characterBody))
	characters = characters.filter(func(object): return is_instance_valid(object))
	print(str(self) + ": (onCharacterDeath) new Character Died" + str(characterBody))
	characterHasDied.emit()
	
	
	call_deferred("onAllCharactersDead")

## Randomizes difficulty Experience
func randomizeDifficultyEXP():
	var LdifficultyEXP = randf_range(1.0, 2.0)
	LdifficultyEXP *= difficultyEXP
	print(str(self) + ": Old DifficultyEXP Given: " + str(difficultyEXP))
	print(str(self) + ": New DifficultyEXP Given: " + str(LdifficultyEXP))
	return LdifficultyEXP


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

## does something if all characters dead
func onAllCharactersDead():
#	print(str(self) + ": Checking if characters are dead")
#	print(str(self) + ": Checking if characters are dead List: " + str(characters))
	getCharactersInfo()
	if charactersAmount <= 0:
		print(str(self) + ": All Characters Died")
		if isFriendly:
			dungeon.get_node("StopControl").show()
			dungeon.saveToSaveSystem()
			await SaveSystem.Saved
			dungeon.queue_free()
			get_tree().change_scene_to_file("res://resources/levels/menu/GameOverMenu/GameOverMenu.tscn")
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
