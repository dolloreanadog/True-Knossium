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

var queuedAOE

func _ready():
	system.newTurn()
	system.newBattle()
	system.connect("OnNewTurn", getTurn)
	system.connect("OnNewBattle", getBattle)

#func goThroughQueuedAOEArray():
#	var queuedAOE: Array = friendlyAOE.get_children() + enemyAttackAOE.get_children() + enemySupportAOE.get_children()
#	print(str(self) + ": allAOE: " + str(queuedAOE))
#	
#	while queuedAOE.size() != 0:
#		var targetAOE: BaseAOE = queuedAOE.pop_back()
#		print(str(self) + ": targetAOE: " + str(targetAOE))
#		targetAOE.InTurn()


func getTurn():
	print(str(self) + ": Turns: " + str(system.battle))
	turnsLabel.set_text("Turns: " + str(system.turn))
#	goThroughQueuedAOEArray()

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
