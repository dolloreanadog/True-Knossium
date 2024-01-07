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


#--[ Characters that spawn ]--
@export var healer = preload("res://resources/entities/characters_items/character/support_character/dev_support_character/DevSupportCharacter.tscn")
@export var tank = preload("res://resources/entities/characters_items/character/tank_character/dev_tank_character/DevTankCharacter.tscn")
@export var DPSRanged = preload("res://resources/entities/characters_items/character/ranged_character/dev_ranged_character/DevArcherCharacter.tscn")
@export var DPSMelee = preload("res://resources/entities/characters_items/character/melee_character/dev_melee_character/DevMeleeCharacter.tscn")



func _ready():
	getTurn()
	getBattle()

func getTurn():
	turnsLabel.set_text("Turns: " + str(system.turn))

func getBattle():
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

func CQCCharactersActive():
	var boolean: bool
	# Get the container's Melee & Tank Array
	# If the array.size() is 0 then make area not visible
	
	return boolean
