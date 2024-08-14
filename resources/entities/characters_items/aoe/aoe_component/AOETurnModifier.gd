extends Node
class_name AOETurnModifierComponent

# if negative removes cast time, if positive add cast time to actions
@onready var AOE: BaseAOE# = get_parent()
@export var castTimeModifyAmount: int = 0

func Activated(body: BaseCharacter) -> void:
		if body.stats.alreadyDied != true && body.stats.moraleAlreadyBroken != true:
			if body.action1 != null:
				body.action1.AddCastTime(castTimeModifyAmount)
				body.action1.getAttackInfo()
			if body.action2 != null:
				body.action2.AddCastTime(castTimeModifyAmount)
				body.action2.getAttackInfo()
			if body.action3 != null:
				body.action3.AddCastTime(castTimeModifyAmount)
				body.action3.getAttackInfo()
			if body.action4 != null:
				body.action4.AddCastTime(castTimeModifyAmount)
				body.action4.getAttackInfo()


func AOEHasAttack(character) -> void:
	Activated(character)
