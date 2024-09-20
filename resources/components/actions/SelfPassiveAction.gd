extends BaseActionComponent
## This is a passive action that effects character itself
class_name SelfPassiveActionComponent

func onCastTimeMinimum() -> void:
	if currentCastTime <= 0:
		ActivatePassive()
		currentCastTime = castTime
		if character.isFriendly:
			SaveSystem.GameInfoDict.PlayerTotalAOEUsed += 1
		else:
			SaveSystem.GameInfoDict.EnemyTotalAOEUsed += 1
		print(str(self) + ": AOE has been Casted")

func ActivatePassive() -> void:
	if !is_instance_valid(character):
		printerr("Character is not valid")
		return
	
	character.damageStats(currentHealth, CurrentDefense, CurrentAttack, CurrentMorale)
