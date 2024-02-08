extends Node2D
class_name levelDungeon
# Notes
# Have a check here that does a for loop on each of the party container
# If that party container has no tanks or melee the AOE Area denial will dissapear

#--[ These are reference, will not be used ]--
var stats: StatComponent

#--[ Get Important Nodes ]--
@onready var system: TurnSystem = get_node("TurnSystem")
@onready var turnsLabel = $Notes/Label5
@onready var battlesLabel = $Notes/Label6
@onready var friendlyPartyContainer = $FriendlyPartyContainer
@onready var enemyPartyContainer = $EnemyPartyContainer

#--[ Get all the AOEs]--
@onready var friendlyAOE = $AOESpawnArea
@onready var enemyAttackAOE = $EnemyAOEContainerAttack
@onready var enemySupportAOE = $EnemyAOEContainerSupport

#--[ Characters that spawn ]--
@export var healer = preload("res://resources/entities/characters_items/character/dev_game_characters/DevSupportCharacter.tscn")
@export var tank = preload("res://resources/entities/characters_items/character/dev_game_characters/DevTankCharacter.tscn")
@export var DPSRanged = preload("res://resources/entities/characters_items/character/dev_game_characters/DevArcherCharacter.tscn")
@export var DPSMelee = preload("res://resources/entities/characters_items/character/dev_game_characters/DevMeleeCharacter.tscn")

var queuedAOE: Array

signal AOEQueueFinished



func _ready():
	system.newTurn()
	system.newBattle()
#	system.connect("OnNewTurn", getTurn)
#	system.connect("OnNewBattle", getBattle)


## THIS IS VITAL, WE'RE REVIVING THIS FUNCTION
func goThroughQueuedAOEArray():
	#await get_tree().create_timer(0.75).timeout
	queuedAOE = friendlyAOE.get_children() + enemyAttackAOE.get_children() + enemySupportAOE.get_children()
	print(str(self) + ": allAOE: " + str(queuedAOE))
	$StopControl.visible = true
	# How this works
	# every .25 seconds (or animation ends) we get a targetAOE from queued AOE
	# We then use the InTurn Function for the targetAOE
	
	while queuedAOE.size() != 0:
		await get_tree().create_timer(0.25).timeout # or when animation ends
		var Ltarget = queuedAOE.pop_back()
		var targetAOE: BaseAOE
		if is_instance_valid(Ltarget):
			targetAOE = Ltarget
			print(str(self) + ": targetAOE: " + str(targetAOE))
			targetAOE.InTurn()
			
	# Spawn Our Friendly AOE Here
	print(str(self) + ": (L) Emitting Signal")
	emit_signal("AOEQueueFinished")
	await get_tree().create_timer(0.25).timeout
	$StopControl.visible = false


func getTurn():
	print(str(self) + ": Turns: " + str(system.battle))
	turnsLabel.set_text("Turns: " + str(system.turn))
	goThroughQueuedAOEArray()

func getBattle():
	print(str(self) + ": Battles: " + str(system.battle))
	battlesLabel.set_text("Battles: " + str(system.battle))

func _on_turn_system_on_new_turn():
	getTurn()
	getBattle()

func _on_spawn_friendly_healer_pressed():
	var instance = healer.instantiate()
	friendlyPartyContainer.addCharacter(instance)

func _on_spawn_friendly_tank_pressed():
	var instance = tank.instantiate()
	friendlyPartyContainer.addCharacter(instance)

func _on_spawn_friend_ranged_pressed():
	var instance = DPSRanged.instantiate()
	friendlyPartyContainer.addCharacter(instance)

func _on_spawn_friend_melee_pressed():
	var instance = DPSMelee.instantiate()
	friendlyPartyContainer.addCharacter(instance)

func _on_spawn_enemy_healer_pressed():
	var instance = healer.instantiate()
	enemyPartyContainer.addCharacter(instance)

func _on_spawn_enemy_tank_pressed():
	var instance = tank.instantiate()
	enemyPartyContainer.addCharacter(instance)

func _on_spawn_enemy_ranged_pressed():
	var instance = DPSRanged.instantiate()
	enemyPartyContainer.addCharacter(instance)

func _on_spawn_enemy_melee_pressed():
	var instance = DPSMelee.instantiate()
	enemyPartyContainer.addCharacter(instance)
