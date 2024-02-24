extends Node
class_name BaseActionComponent


## This is where we'll spawn it & make it a child of
@export var stats: StatComponent
@onready var character: BaseCharacter = get_parent()

## What animation to use when casted, Check Animation Naming Convention in Discord.
@export var animationUsed: String
@onready var spawnAreaAttack: BaseSpawnArea = get_parent().get_parent().get_parent().get_node("AOESpawnAreaAttack")
@onready var spawnAreaSupport: BaseSpawnArea = get_parent().get_parent().get_parent().get_node("AOESpawnAreaSupport")
## For the AI use
# This is used to store the attack, the AOEs here should be sent to other Party Container
@onready var EnemyAOEContainerAttack: EnemyAOEContainer = get_parent().get_parent().get_parent().get_node("EnemyAOEContainerAttack")
#This is used to store the attack (support), the AOEs here should be sent to self Party Container
@onready var EnemyAOEContainerSupport: EnemyAOEContainer = get_parent().get_parent().get_parent().get_node("EnemyAOEContainerSupport")
@onready var system: TurnSystem = get_parent().get_parent().get_parent().get_node("TurnSystem")
# This is default
## This will be in each individual class (OVERRIDE THIS)
@export var AOE = preload("res://resources/entities/characters_items/aoe/dev_aoe/DevAOE.tscn")
#--[ Cast Time ]--
## How many turns it takes to spawn it
@export var castTime: int
var currentCastTime: int

#--[ Stats ]--
@export var isOffensive: bool = true
@export var amount: int = 1
# Need to figure out how to utilize this attack stat
# Here should be 0-9
@export var health: float = 0
@export var defense: float = 0
@export var attack: float = 0
@export var morale: float = 0
## The higher the accuracy, the more it misses
@export_range(0, 20, 1) var accuracy: int
var currentHealth: float
var CurrentDefense: float
var CurrentAttack: float
var CurrentMorale: float

#--[ Other important variables ]-- 
@export var description: String



func _ready():
	pass
	#getAttackInfo()

func onCastTimeMinimum():
	if currentCastTime <= 0:
		spawnAOE()
		currentCastTime = castTime
		print(str(self) + ": AOE has been Casted")

func removeCastTime():
	currentCastTime -= 1
	print(str(self) + ": Cast Time Going Down")
	onCastTimeMinimum()

## Make the number negative
func turnIntoOffensiveAction(inputNumber):
	inputNumber *= -1
	return inputNumber

func spawnAOE():
#	print(str(self) + ": Spawn AOE")
#	print(str(self) + ": Amount is: " + str(amount))
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
		elif character.isFriendly && isOffensive == false:
			print(str(character) + " " + str(self) + ": (Surrender) 2")
			spawnAreaSupport.add_child(instance, true)
			instance.set_global_position(spawnAreaSupport.randomizeSpawn())
		elif character.isFriendly == false && isOffensive:
			print(str(character) + " " + str(self) + ": (Surrender) 3")
			EnemyAOEContainerAttack.add_child(instance, true)
		elif character.isFriendly == false && isOffensive == false:
			print(str(character) + " " + str(self) + ": (Surrender) 4")
			EnemyAOEContainerSupport.add_child(instance, true)
		else:
			push_error("Action Broke!")

func getAttackInfo():
	print(str(self) + ": health attack = " + str(currentHealth))
	print(str(self) + ": defense attack = " + str(CurrentDefense))
	print(str(self) + ": attack attack = " + str(CurrentAttack))
	print(str(self) + ": morale attack = " + str(CurrentMorale))

# This thing is scuffed Pls Fix when coming back
func updateAttackInfo():
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
