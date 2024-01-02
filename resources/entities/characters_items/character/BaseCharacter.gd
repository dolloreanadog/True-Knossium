extends CharacterBody2D
class_name BaseCharacter

#--[ Some important stuff ]--
@export var id: String
@export var profilePicture: Texture2D
@onready var stats: StatComponent = get_node("StatComponent")
@onready var system: TurnSystem = get_parent().get_parent().get_node("TurnSystem")
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

func damageStats(health, defense, attack, morale):
	print("Body is getting Damaged")
	stats.isDamaged()
	stats.changeCurrentHealth(health)
	stats.changeCurrentDefense(defense)
	stats.changeCurrentAttack(attack)
	stats.changeCurrentMorale(morale)

func useActions():
	if action1 != null:
		action1.removeCastTime()
	if action2 != null:
		action2.removeCastTime()
	if action3 != null:
		action3.removeCastTime()
	if action4 != null:
		action4.removeCastTime()
	#SpawnAOE Variables
	#Amount
	#cast time


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
	print("Received Signal")
	useActions()

func characterNewBattle():
	stats.resetCurrentStats()
