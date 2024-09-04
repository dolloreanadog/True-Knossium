extends BaseActionComponent
## Action that spawns character instead of AOE
class_name CharacterSpawnerActionComponent

@export var spawningCharacter: PackedScene
@export var characterExperience: float

func onCastTimeMinimum() -> void:
	if currentCastTime <= 0:
		SpawnCharacter()
		currentCastTime = castTime
		if character.isFriendly:
			SaveSystem.GameInfoDict.PlayerTotalAOEUsed += 1
		else:
			SaveSystem.GameInfoDict.EnemyTotalAOEUsed += 1
		print(str(self) + ": AOE has been Casted")

func SpawnCharacter() -> void:
	if !is_instance_valid(character):
		printerr("Character is not valid")
	
	characterExperience *= stats.currentAttack
	
	for i in amount:
		var instance: BaseCharacter = spawningCharacter.instantiate()
		character.partyContainer.addCharacter(instance, characterExperience, true, Vector2(0, 0))
		await get_tree().create_timer(0.005).timeout
