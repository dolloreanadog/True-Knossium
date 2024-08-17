extends BaseCharacter

func _ready() -> void:
	print("(check) party container dungeon = " + str(partyContainer.dungeon))
	characterName = id
	system = dungeon.system
	inventory = dungeon.inventory
	activateLevelLabel(false)
	print("TurnSystem: " + str(system))
	dungeon.connect("AOEQueueFinished", characterNewTurn) # Instead of this use Dungeon's Queue Signal
	system.connect("OnNewBattle", characterNewBattle)
	partyContainer.connect("characterHasDied", OtherCharacterHasDied)
	runAnimation("idle1")
	if ResourceNeeded == null && ResourceNeededNumber > 0:
		push_error(str(self) + " Resource is empty")

func OtherCharacterHasDied() -> void:
	print("character has died, abomination grows in strength")
	stats.health += 2.5
	stats.attack += 1
	stats.currentHealth += 5
	stats.currentAttack += 2
