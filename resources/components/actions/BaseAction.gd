extends Node
class_name BaseActionComponent
# When Picked Up Show accuracy & damage
# When Finally placed no longer show aoe

## This is where we'll spawn it & make it a child of
# get_parent() chain here we go
@export var stats: StatComponent
@onready var character: BaseCharacter = get_parent()
@onready var spawnArea: BaseSpawnArea = get_parent().get_parent().get_parent().get_node("AOESpawnArea")
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
@export var amount: int
# Need to figure out how to utilize this attack stat
# Here should be 0-9
@export var health: float = 0
@export var defense: float = 0
@export var attack: float = 0
@export var morale: float = 0

func _ready():
	getAttackInfo()

func onCastTimeMinimum():
	if currentCastTime <= 0:
		spawnAOE()
		customTimeMinimumAction()
		currentCastTime = castTime
		print(str(self) + ": AOE has been Casted")

func removeCastTime():
	currentCastTime -= 1
	print(str(self) + ": Cast Time Going Down")
	onCastTimeMinimum()
	customTimeCastRemovedAction()

# Make the number negative
func turnIntoOffensiveAction(inputNumber):
	print(str(self) + ": Action is now Offensive")
	inputNumber *= -1
	return inputNumber

func spawnAOE():
	print(str(self) + ": Spawn AOE")
	# This goes from 0 -> 1, That's why it spawns two
	print(str(self) + ": Amount is: " + str(amount))
	for i in range(0, amount):
		print(str(self) + ": Spawned is "+ str(i))
		print(str(self) + ": Amount should be spawned is "+ str(amount))
		var instance: BaseAOE = AOE.instantiate()
		if isOffensive:
			instance.health = turnIntoOffensiveAction(health)
			instance.defense = turnIntoOffensiveAction(defense)
			instance.attack = turnIntoOffensiveAction(attack)
			instance.morale = turnIntoOffensiveAction(morale)
		else:
			instance.health = health
			instance.defense = defense
			instance.attack = attack
			instance.morale = morale
		if character.isFriendly:
			spawnArea.add_child(instance, true)
		elif character.isFriendly == false && isOffensive:
			EnemyAOEContainerAttack.add_child(instance, true)
		elif character.isFriendly == false && isOffensive == false:
			EnemyAOEContainerSupport.add_child(instance, true)

func getAttackInfo():
	print(str(self) + ": health attack = " + str(health))
	print(str(self) + ": defense attack = " + str(defense))
	print(str(self) + ": attack attack = " + str(attack))
	print(str(self) + ": morale attack = " + str(morale))

# This thing is scuffed Pls Fix when coming back
func updateAttackInfo():
	print(str(self) + ": Action Stats Updated")
	var Lhealth: float = health
	var Ldefense: float = defense
	var Lattack: float = attack
	var Lmorale: float = morale
	
	Lhealth *= stats.attack * 0.35
	Ldefense += stats.attack * 0.35
	Lattack *= stats.attack * 0.35
	Lmorale *= stats.attack * 0.35
	
	health = Lhealth
	defense = Ldefense
	attack = Lattack
	morale = Lmorale
	getAttackInfo()

#--[ Overridable Functions ]--
func customTimeMinimumAction():
	pass

func customTimeCastRemovedAction():
	pass
