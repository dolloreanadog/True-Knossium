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
	FriendlyPartyContainer.connect("allCharactersDead", newBattle)
	EnemyPartyContainer.connect("allCharactersDead", newBattle)

func newTurn():
	turn += 1
	print(str(self) + ": turns = " + str(turn))
	emit_signal("OnNewTurn")
	FriendlyPartyContainer.getCharactersInfo()
	EnemyPartyContainer.getCharactersInfo()
	#EnemyPartyContainer.onAllCharactersDead()
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
