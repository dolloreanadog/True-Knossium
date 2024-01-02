extends Node
class_name BaseActionComponent
# When Picked Up Show accuracy & damage
# When Finally placed no longer show aoe

## This is where we'll spawn it & make it a child of
# get_parent() chain here we go
@export var stats: StatComponent
@onready var spawnArea: BaseSpawnArea = get_parent().get_parent().get_parent().get_node("AOESpawnArea")
@onready var system: TurnSystem = get_parent().get_parent().get_parent().get_node("TurnSystem")
# This is default
## This will be in each individual class (OVERRIDE THIS)
@export var AOE = preload("res://resources/entities/characters_items/aoe/dev_aoe/DevAOE.tscn")
## How many turns it takes to spawn it
#--[ Cast Time ]--
@export var castTime: int
var currentCastTime: int

#--[ Stats ]--
@export var isOffensive: bool = true
@export var amount: int = 1
@export var accuracy: float = 10
# Need to figure out how to utilize this attack stat
@onready var health: float = stats.attack
@onready var defense: float = stats.attack
@onready var attack: float = stats.attack
@onready var morale: float = stats.attack

func _ready():
	system.connect("OnNewTurn", removeCastTime)
	if health != null:
		health = stats.attack
	else:
		push_warning("No Stats to pull damage")

func onCastTimeMinimum():
	if castTime <= 0:
		spawnAOE()
		currentCastTime = castTime
		print("AOE has been Casted")

func removeCastTime():
	castTime -= 1
	print("Cast Time Going Down")
	onCastTimeMinimum()

# Make the number negative
func turnIntoOffensiveAction(inputNumber):
	inputNumber *= -1
	return inputNumber

func spawnAOE():
	# This goes from 0 -> 1, That's why it spawns two

	for i in amount:
		var hope = i
		print("Spawned is "+ str(hope))
		var instance: BaseAOE = AOE.instantiate()
		# Change this to stats.damage
		# WE'RE DOUBLING IT WHAT?
		if isOffensive:
			instance.health = turnIntoOffensiveAction(defense)
			instance.defense = turnIntoOffensiveAction(defense)
			instance.attack = turnIntoOffensiveAction(attack)
			instance.morale = turnIntoOffensiveAction(morale)
			instance.accuracy = accuracy
		else:
			instance.health = health
			instance.defense = defense
			instance.attack = attack
			instance.morale = morale
			instance.accuracy = accuracy
		spawnArea.add_child(instance, true)
