extends SelfPassiveActionComponent
## This is a passive action that all character in own party
class_name SelfPartyPassiveActionComponent

func ActivatePassive() -> void:
	if !is_instance_valid(character):
		printerr("Character is not valid")
		return
	
	for c in character.partyContainer.get_children():
		c.damageStats(currentHealth, CurrentDefense, CurrentAttack, CurrentMorale)
