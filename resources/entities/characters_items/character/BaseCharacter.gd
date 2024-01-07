extends CharacterBody2D
class_name BaseCharacter

#--[ Some important stuff ]--
@export var id: String
@export var profilePicture: Texture2D
@onready var stats: StatComponent = get_node("StatComponent")
@onready var system: TurnSystem = get_parent().get_parent().get_node("TurnSystem")
@export var isFriendly: bool = true
var turns: int


#--[ Effects ]--
# This video https://www.youtube.com/watch?v=vzRZjM9MTGw
# add a if null statement so we don't crash
# With this we can add more functions, SFX, VFX, & More
# Like if I were to make a shield break VFX just for that character, I just attach it to that resource
@export var levelUpFX: BaseFX
@export var healthDeathFX: BaseFX
@export var defenseDeathFX: BaseFX
@export var attackDeathFX: BaseFX
@export var moraleDeathFX: BaseFX
@export var overHealthFX: BaseFX
@export var overDefenseFX: BaseFX
@export var overAttackFX: BaseFX
@export var overMoraleFX: BaseFX
@export var healthChangedFX: BaseFX
@export var defenseChangedFX: BaseFX
@export var attackChangedFX: BaseFX
@export var moraleChangedFX: BaseFX

#--[ Actions ]--
@export var action1: BaseActionComponent
@export var action2: BaseActionComponent
@export var action3: BaseActionComponent
@export var action4: BaseActionComponent

#--[ Base Functions ]--
func _ready():
	print("TurnSystem: " + str(system))
	system.connect("OnNewTurn", characterNewTurn)
	system.connect("OnNewBattle", characterNewBattle)

func damageStats(health, defense, attack, morale): # Print out the stats of getting damage
	print(str(self) + ": Body is getting Damaged")
	print(str(self) + ": Health stat being damaged for " + str(health))
	print(str(self) + ": Defense stat being damaged for " + str(defense))
	print(str(self) + ": Attack stat being damaged for " + str(attack))
	print(str(self) + ": Morale stat being damaged for " + str(morale))
	stats.isDamaged()
	stats.changeCurrentHealth(health)
	stats.changeCurrentDefense(defense)
	stats.changeCurrentAttack(attack)
	stats.changeCurrentMorale(morale)

func useActions():
	if action1 != null:
		action1.removeCastTime()
		action1.getAttackInfo()
	if action2 != null:
		action2.removeCastTime()
		action1.getAttackInfo()
	if action3 != null:
		action3.removeCastTime()
		action1.getAttackInfo()
	if action4 != null:
		action4.removeCastTime()
		action1.getAttackInfo()


# Make sure these are all called in the Stat Component
func playLevelUpFX():
	levelUpFX.playFX()

func playhealthDeathFX():
	healthDeathFX.playFX()

func playDefenseDeathFX():
	defenseDeathFX.playFX()

func playAttackDeathFX():
	attackDeathFX.playFX()

func playMoraleDeathFX():
	moraleDeathFX.playFX()

func playOverHealthFX():
	overHealthFX.playFX()

func playOverDefenseFX():
	overDefenseFX.playFX()

func playOverAttackFX():
	overAttackFX.playFX()

func playOverMorale():
	overMoraleFX.playFX()

func playHealthChangedFX():
	healthChangedFX.playFX()

func playDefenseChangedFX():
	defenseChangedFX.playFX()

func playAttackChangedFX():
	attackChangedFX.playFX()

func playMoraleChangedFX():
	moraleChangedFX.playFX()

## Get a Signal from the turnSystem to do this
func characterNewTurn():
	print(str(self) + ": Received Signal") # We're receiving the signal Twice?
	useActions()

func characterNewBattle():
	stats.resetCurrentStats()

# Idk why we have this, we'll see what this means
# ^ Determines if to spawn AOE or not
# Have the party container run a loop to use this function on all children
func changeFriendliness(boolean: bool):
	isFriendly = boolean
