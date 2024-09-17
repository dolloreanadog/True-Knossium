extends Node
class_name TurnSystem

@export var dungeon: BaseLevel
@export var FriendlyPartyContainer: BasePartyContainer
@export var EnemyPartyContainer: BasePartyContainer

var failsafeLevel: int = 0
var playerControlActive: bool = true
var turn: int
var battle: int

signal OnNewBattle
signal OnNewTurn
signal OnPlayerControlActive
signal OnPlayerControlInactive

func _ready() -> void:
	FriendlyPartyContainer.connect("allCharactersDead", newBattle)
	EnemyPartyContainer.connect("allCharactersDead", newBattle)

func newTurn() -> void:
	turn += 1
	dungeon.warningLabel.StopDisplay()
	print(str(self) + ": turns = " + str(turn))
	emit_signal("OnNewTurn")
#	FriendlyPartyContainer.getCharactersInfo()
#	EnemyPartyContainer.getCharactersInfo()
	BattleFailsafe()
	#EnemyPartyContainer.onAllCharactersDead()
	print("---------------[ Turn Changed to " + str(turn) + " ]---------------")

func newBattle() -> void:
	battle += 1
	dungeon.difficulty.onBattleNew()
	dungeon.EndTurnButtonHighlight(true)
	print(str(self) + ": battles = " + str(battle))
	Steam.setRichPresence("gameinfotext", str("Battle: " + str(battle) + " Turn: " + str(turn)))
	Steam.setRichPresence("steam_display", "#Game")
	
	emit_signal("OnNewBattle")
	print("Battle Changed")

func removeControl() -> void:
	playerControlActive = false
	emit_signal("OnPlayerControlActive")

func returnControl() -> void:
	playerControlActive = true
	emit_signal("OnPlayerControlInactive")

## This check will make characters spawn if the signal fails

func BattleFailsafe() -> void:
	if EnemyPartyContainer.get_child_count() == 0:
		print("FailsafeLevel needed, adding: " + str(failsafeLevel))
		failsafeLevel += 1
	else:
		failsafeLevel = 0
	
	if failsafeLevel == 2:
		print("FailsafeLevel Maximum, Activating: " + str(failsafeLevel))
		EnemyPartyContainer.onAllCharactersDead()
