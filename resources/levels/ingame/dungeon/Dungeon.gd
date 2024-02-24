extends Node2D
class_name levelDungeon
# Notes
# Once done, with real development, change this to work with next

#--[ These are reference, will not be used ]--
var stats: StatComponent

#--[ Get Important Nodes ]--
@onready var system: TurnSystem = get_node("TurnSystem")
@onready var turnsLabel = $Notes/Label5
@onready var battlesLabel = $Notes/Label6
@onready var friendlyPartyContainer: BasePartyContainer = $FriendlyPartyContainer
@onready var enemyPartyContainer: BasePartyContainer = $EnemyPartyContainer

#--[ Get all the AOEs]--
@onready var friendlyAOEAttack = $AOESpawnAreaAttack
@onready var friendlyAOESupport = $AOESpawnAreaSupport
@onready var enemyAttackAOE = $EnemyAOEContainerAttack
@onready var enemySupportAOE = $EnemyAOEContainerSupport

#--[ Characters that spawn ]--
@export var healer = preload("res://resources/entities/characters_items/character/dev_game_characters/DevSupportCharacter.tscn")
@export var tank = preload("res://resources/entities/characters_items/character/dev_game_characters/DevTankCharacter.tscn")
@export var DPSRanged = preload("res://resources/entities/characters_items/character/dev_game_characters/DevArcherCharacter.tscn")
@export var DPSMelee = preload("res://resources/entities/characters_items/character/dev_game_characters/DevMeleeCharacter.tscn")

#--[ For queue ]--
var queuedAOE: Array
var isCharactersActive: bool = true

#--[ Surrender Window ]--
var surrenderWindow = preload("res://resources/entities/surrender_window/surrender_window.tscn")

#--[ Signal ]--
signal AOEQueueFinished

#--[ Functions ]--
func _ready():
	system.newTurn()
	system.newBattle()

func goThroughQueuedAOEArray() -> void:
	var currentBattle: int = system.battle
	
	queuedAOE = grabAllAOE()
	print(str(self) + ": allAOE: " + str(queuedAOE))
	$StopControl.visible = true
	setIsCharactersActive(true)
	
	while queuedAOE.size() != 0:
			await get_tree().create_timer(0.25).timeout
			var Ltarget = queuedAOE.pop_back()
			var targetAOE: BaseAOE
			
			if currentBattle != system.battle:
				queuedAOE.clear()
				break
			
			if is_instance_valid(Ltarget):
				targetAOE = Ltarget
				print(str(self) + ": targetAOE: " + str(targetAOE))
				targetAOE.InTurn()
			

			
			
	# Spawn Our Friendly AOE Here
	emit_signal("AOEQueueFinished")
	await get_tree().create_timer(0.25).timeout
	setIsCharactersActive(false)
	$StopControl.visible = false

func grabAllAOE() -> Array:
	var AOEGrabbed: Array = friendlyAOEAttack.get_children() + enemyAttackAOE.get_children() + friendlyAOESupport.get_children() + enemySupportAOE.get_children()
	return AOEGrabbed

func setIsCharactersActive(boolean: bool) -> void:
	isCharactersActive = boolean

func getTurn() -> void:
	print(str(self) + ": Turns: " + str(system.battle))
	turnsLabel.set_text("Turns: " + str(system.turn))
	goThroughQueuedAOEArray()

func getBattle() -> void:
	print(str(self) + ": Battles: " + str(system.battle))
	battlesLabel.set_text("Battles: " + str(system.battle))

func _on_turn_system_on_new_turn() -> void:
	getTurn()
	getBattle()

func spawnSurrenderWindow(Lcharacter: BaseCharacter, profilePicture: Texture2D, characterName: String, experience: float) -> void:
	print(str(self) + ": Spawning Surrender Window")
	print(str(self) + ": scene file path 2: " + str(Lcharacter))
	var instance = surrenderWindow.instantiate()
	add_child(instance)
	instance.character = Lcharacter
	instance.characterPFP = profilePicture
	instance.characterName = characterName
	instance.totalExperience = experience
	instance.setWindowInfo()
	instance.set_global_position(Vector2(0, 0))
	#print("surren$Camera2DderWindow Spawned at " + str(instance.global_position))

func _on_spawn_friendly_healer_pressed() -> void:
	var instance = healer.instantiate()
	friendlyPartyContainer.addCharacter(instance, 0.0)

func _on_spawn_friendly_tank_pressed() -> void:
	var instance = tank.instantiate()
	friendlyPartyContainer.addCharacter(instance, 0.0)

func _on_spawn_friend_ranged_pressed() -> void:
	var instance = DPSRanged.instantiate()
	friendlyPartyContainer.addCharacter(instance, 0.0)

func _on_spawn_friend_melee_pressed() -> void:
	var instance = DPSMelee.instantiate()
	friendlyPartyContainer.addCharacter(instance, 0.0)

func _on_spawn_enemy_healer_pressed() -> void:
	var instance = healer.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0)

func _on_spawn_enemy_tank_pressed() -> void:
	var instance = tank.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0)

func _on_spawn_enemy_ranged_pressed() -> void:
	var instance = DPSRanged.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0)

func _on_spawn_enemy_melee_pressed() -> void:
	var instance = DPSMelee.instantiate()
	enemyPartyContainer.addCharacter(instance, 0.0)


func _on_get_attack_aoe_container_nodes_pressed() -> void:
	print("All Attack AOE: " + str($EnemyAOEContainerAttack.get_children() + $AOESpawnAreaAttack.get_children()))


func _on_get_support_aoe_container_nodes_pressed() -> void:
	print("All Support AOE: " + str($EnemyAOEContainerSupport.get_children() + $AOESpawnAreaSupport.get_children()))


func _on_get_enemy_container_nodes_pressed() -> void:
	print("All Enemies: " + str($EnemyPartyContainer.get_children()))


func _on_get_friendly_container_nodes_pressed() -> void:
	print("All Friendly: " + str($FriendlyPartyContainer.get_children()))
