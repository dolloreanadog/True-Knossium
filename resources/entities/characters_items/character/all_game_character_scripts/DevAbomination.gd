extends BaseCharacter

func _ready() -> void:
	print("(check) party container dungeon = " + str(partyContainer.dungeon))
	characterName = id
	system = dungeon.system
	inventory = dungeon.inventory
	z_index = z_index_order
	activateLevelLabel(false)
	print("TurnSystem: " + str(system))
	dungeon.connect("AOEQueueFinished", characterNewTurn) # Instead of this use Dungeon's Queue Signal
	system.connect("OnNewBattle", characterNewBattle)
	
	# If character dies call functions related to characters' death
	partyContainer.connect("characterHasDied", FriendlyCharacterHasDied)
	if isFriendly:
		dungeon.enemyPartyContainer.connect("characterHasDied", EnemyCharacterHasDied)
	else:
		dungeon.friendlyPartyContainer.connect("characterHasDied", EnemyCharacterHasDied)
	
	characterAnimation.play("idle1")
	if ResourceNeeded == null && ResourceNeededNumber > 0:
		push_error(str(self) + " Resource is empty")

func FriendlyCharacterHasDied() -> void:
	print("character has died, abomination grows in strength")
	stats.health += 2.5
	stats.attack += 1
	stats.currentHealth += 10
	stats.currentDefense += 0.25
	stats.currentAttack += 2
	stats.currentMorale += 10

func EnemyCharacterHasDied() -> void:
	print("character has died, abomination grows in strength")
	stats.health += 1
	stats.attack += 0.5
	stats.currentHealth += 5
	stats.currentDefense += 0.125
	stats.currentAttack += 1
	stats.currentMorale += 5
