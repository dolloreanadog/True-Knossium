extends Node
class_name TurnSystem

@export var FriendlyPartyContainer: BasePartyContainer
@export var EnemyPartyContainer: BasePartyContainer

var playerControlActive: bool = true
var turn: int
var battle: int

signal OnNewBattle
signal OnNewTurn
signal OnPlayerControlActive
signal OnPlayerControlInactive

func _ready():
	pass

func newTurn():
	turn += 1
	FriendlyPartyContainer.getCharactersInfo()
	EnemyPartyContainer.getCharactersInfo()
	emit_signal("OnNewTurn")
	
	print("---------------[ Turn Changed to " + str(turn) + " ]---------------")

func newBattle():
	battle += 1
	print(str(self) + ": battles = " + str(battle))
	emit_signal("OnNewBattle")
	
	print("Battle Changed")

func removeControl():
	playerControlActive = false
	emit_signal("OnPlayerControlActive")

func returnControl():
	playerControlActive = true
	emit_signal("OnPlayerControlInactive")
