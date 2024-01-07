extends Node2D
class_name EnemyAOEContainer

#--[ Important Nodes ]--

@export var isAOESupportContainer: bool

#--[ Behavior ]--

enum behaviorPlans {targetLowHealth, targetHighHealth, targetLowDefense, targetHighDefense, targetLowAttack}# Haven't finished this
var preferredPlan: behaviorPlans

#--[ Holding ]--
var AOEList: Array
var AOEListCount: int
# Sort them into these for AI to make effective use of knowing hot use it
# Take into account if it's support or not
# if support & is positive, that's high attack
# if offensive & is negative, that's high attack
var AOEListHighHealthAttack: Array
var AOEListHighDefenseAttack: Array
var AOEListHighAttackAttack: Array
var AOEListHighMoraleAttack: Array

# When placing AOE make to take into account the attacks stats
# Have the AI prioritize attacks that would be most effective
# example: if the AOE has a high attack, target characters with low or high attack

# CHECK IF AREA ISMELEE
# We need someway of dealing with AOE that are melee, like not place it into the AOEDenial area if still Active
# We could do a check if the AOE is still draggable, it could signify that 
# AOEList pop_front()
# AOE.set_position(Vector2)
# if AOE.draggable != true:
#	Either 1: Go through loop again
#	Either 2: 
