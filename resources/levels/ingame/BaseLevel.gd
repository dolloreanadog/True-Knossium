extends Node2D
class_name BaseLevel

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
