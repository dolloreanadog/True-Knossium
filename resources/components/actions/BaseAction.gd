extends Node
class_name BaseActionComponent


## Attach StatComponent of character here
@export var stats: StatComponent
@onready var character: BaseCharacter = get_parent()
@onready var dungeon: BaseLevel
## What the action will be named
@export var ActionName: String
## What animation to use when casted, Check Animation Naming Convention in Discord.
@export var animationUsed: String
var spawnAreaAttack: BaseSpawnArea
var spawnAreaSupport: BaseSpawnArea
## For the AI use
# This is used to store the attack, the AOEs here should be sent to other Party Container
var EnemyAOEContainerAttack: EnemyAOEContainer
#This is used to store the attack (support), the AOEs here should be sent to self Party Container
var EnemyAOEContainerSupport: EnemyAOEContainer
var system: TurnSystem
# This is default
## This will be in each individual class (OVERRIDE THIS)
@export var AOE := preload("res://resources/entities/characters_items/aoe/dev_aoe/DevAOE.tscn")
#--[ Cast Time ]--
## How many turns it takes to spawn it
@export_category("Action Casts")
## How long it takes for character to cast this action
@export var castTime: int
var currentCastTime: int

#--[ Stats ]--
@export_category("AOE Information")
## If true, it does damage, If false, it does suport
@export var isOffensive: bool = true
## How many AOE it spawns
@export var amount: int = 1
# Need to figure out how to utilize this attack stat
# Here should be 0-9
## Multiplies current attack stat of character, Determines how much AOE attacks this stat
@export var health: float = 0
## Multiplies current attack stat of character, Determines how much AOE attacks this stat
@export var defense: float = 0
## Multiplies current attack stat of character, Determines how much AOE attacks this stat
@export var attack: float = 0
## Multiplies current attack stat of character, Determines how much AOE attacks this stat
@export var morale: float = 0
## The higher the accuracy, the higher the maximum damage is up to x2
@export_range(0, 1, 0.01) var accuracy: float
var currentHealth: float
var CurrentDefense: float
var CurrentAttack: float
var CurrentMorale: float

#--[ Other important variables ]-- 
## Describe it
@export_multiline var description: String

func _ready() -> void:
	# All things we'll automatically get
	if get_tree().get_current_scene() is BaseLevel:
		dungeon = get_tree().get_current_scene()
		
		if dungeon.friendlyAOEAttack != null:
			spawnAreaAttack = dungeon.friendlyAOEAttack
		
		if dungeon.friendlyAOESupport != null:
			spawnAreaSupport = dungeon.friendlyAOESupport
		
		if dungeon.enemyAttackAOE != null:
			EnemyAOEContainerAttack = dungeon.enemyAttackAOE
		
		if dungeon.enemySupportAOE != null:
			EnemyAOEContainerSupport = dungeon.enemySupportAOE
		
		if dungeon.system != null:
			system = dungeon.system
	else:
		push_error("Dungeon does not exist for action")
	
	
	if !(character is BaseCharacter):
		assert(false, str(character) + " is not BaseCharacter")
	else:
		print(str(character) + " is BaseCharacter")
	if !is_instance_valid(character):
		assert(false, "Character is not valid")

## If cast time for action is 0, place aoe
func onCastTimeMinimum() -> void:
	if currentCastTime <= 0:
		spawnAOE()
		currentCastTime = castTime
		if character.isFriendly:
			SaveSystem.GameInfoDict.PlayerTotalAOEUsed += 1
		else:
			SaveSystem.GameInfoDict.EnemyTotalAOEUsed += 1
		print(str(self) + ": AOE has been Casted")

## Adds Cast Time to this action
func AddCastTime(castAmount: int) -> void:
	currentCastTime += castAmount
	print(str(self) + ": Added: " + str(castAmount))
	onCastTimeMinimum()

## Removes Cast time to this action
func removeCastTime() -> void:
	currentCastTime -= 1
	print(str(self) + ": Cast Time Going Down")
	onCastTimeMinimum()

## Make the number negative
func turnIntoOffensiveAction(inputNumber: float) -> float:
	inputNumber *= -1
	return inputNumber

## Spawns the AOE
func spawnAOE() -> void:
	if !is_instance_valid(character):
		assert(false, "Character is not valid")
	
	updateAttackInfo()
	for i in range(0, amount):
#		print(str(self) + ": Spawned is "+ str(i))
#		print(str(self) + ": Amount should be spawned is "+ str(amount))
		
		var instance: BaseAOE = AOE.instantiate()
		
		if isOffensive:
			instance.health = turnIntoOffensiveAction(currentHealth)
			instance.defense = turnIntoOffensiveAction(CurrentDefense)
			instance.attack = turnIntoOffensiveAction(CurrentAttack)
			instance.morale = turnIntoOffensiveAction(CurrentMorale)
		else:
			instance.health = currentHealth
			instance.defense = CurrentDefense
			instance.attack = CurrentAttack
			instance.morale = CurrentMorale
		
		# some essential stuff the AOE needs

			#character = get_parent()
		instance.dungeon = dungeon
		instance.AOEName = ActionName
		instance.accuracy = accuracy
		instance.ownerCharacter = self.get_owner()
		instance.ownerCharacterAnimation = animationUsed
		instance.ownerCharacterName = character.id
		instance.ownerCharacterPFP = character.profilePicture
		instance.ownerActionDescription = description
		
		
		if character.isFriendly && isOffensive:
			print(str(character) + " " + str(self) + ": (Surrender) 1")
			spawnAreaAttack.add_child(instance, true)
			instance.set_global_position(spawnAreaAttack.randomizeSpawn())
			instance.get_node("MeshInstance2D").modulate = Color(1, 1, 1, 0.05)
		elif character.isFriendly && isOffensive == false:
			print(str(character) + " " + str(self) + ": (Surrender) 2")
			spawnAreaSupport.add_child(instance, true)
			instance.mainColor = Color(0, 1, 0, 0.1)
			instance.set_global_position(spawnAreaSupport.randomizeSpawn())
			instance.get_node("MeshInstance2D").modulate = instance.mainColor
		elif character.isFriendly == false && isOffensive:
			print(str(character) + " " + str(self) + ": (Surrender) 3")
			EnemyAOEContainerAttack.add_child(instance, true)
			instance.draggable = false
			instance.mainColor = Color(0.5, 0, 0.5, 0.1)
			instance.isDynamicColor = false
			instance.get_node("MeshInstance2D").modulate = instance.mainColor
		elif character.isFriendly == false && isOffensive == false:
			print(str(character) + " " + str(self) + ": (Surrender) 4")
			EnemyAOEContainerSupport.add_child(instance, true)
			instance.draggable = false
			instance.mainColor = Color(1, 0.5, 0.5, 0.1)
			instance.isDynamicColor = false
			instance.get_node("MeshInstance2D").modulate = instance.mainColor
		else:
			push_error("Action Broke!")

## Get the information of the attack & print to console
func getAttackInfo() -> void:
	print(str(self) + ": health attack = " + str(currentHealth))
	print(str(self) + ": defense attack = " + str(CurrentDefense))
	print(str(self) + ": attack attack = " + str(CurrentAttack))
	print(str(self) + ": morale attack = " + str(CurrentMorale))

## Update the attack info of the action
func updateAttackInfo() -> void:
#	getAttackInfo()
	var Lhealth: float = health
	var Ldefense: float = defense
	var Lattack: float = attack
	var Lmorale: float = morale
	
	# *= because when 0, it stays 0
	Lhealth *= stats.currentAttack * 0.35
	Ldefense *= stats.currentAttack * 0.35
	Lattack *= stats.currentAttack * 0.35
	Lmorale *= stats.currentAttack * 0.35
	
	currentHealth = Lhealth
	CurrentDefense = Ldefense
	CurrentAttack = Lattack
	CurrentMorale = Lmorale
#	getAttackInfo()
