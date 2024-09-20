extends SelfPassiveActionComponent
## This is a passive action that effects the other party
class_name OtherPartyPassiveActionComponent

func ActivatePassive() -> void:
	if !is_instance_valid(character):
		printerr("Character is not valid")
		return
	
	if character.isFriendly:
		for c in character.dungeon.enemyPartyContainer.get_children():
			c.damageStats(currentHealth, CurrentDefense, CurrentAttack, CurrentMorale)
	else:
		for c in character.dungeon.friendlyPartyContainer.get_children():
			c.damageStats(currentHealth, CurrentDefense, CurrentAttack, CurrentMorale)
