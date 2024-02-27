extends CharacterBody2D
class_name BaseCharacter

#--[ Some important stuff ]--
@export var id: String
@export var profilePicture: Texture2D
@onready var dungeon: BaseLevel = get_parent().get_parent()
@onready var stats: StatComponent = get_node("StatComponent")
@onready var system: TurnSystem = get_parent().get_parent().get_node("TurnSystem")
@onready var levelLabel: Label = get_node("LevelLabel")
@onready var characterSprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
var isFriendly: bool = true
@export var ResourceNeeded: String # We still don't know how or what variable it's as
@export var ResourceNeededNumber: int
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
@export var healthChangedFX: BaseStatChangedFX
@export var defenseChangedFX: BaseStatChangedFX
@export var attackChangedFX: BaseStatChangedFX
@export var moraleChangedFX: BaseStatChangedFX

#--[ Actions ]--
@export var action1: BaseActionComponent
@export var action2: BaseActionComponent
@export var action3: BaseActionComponent
@export var action4: BaseActionComponent

#--[ Signal ]--
signal characterAnimationFinished


#--[ Base Functions ]--
func _ready():
	activateLevelLabel(false)
	print("TurnSystem: " + str(system))
	dungeon.connect("AOEQueueFinished", characterNewTurn) # Instead of this use Dungeon's Queue Signal
	system.connect("OnNewBattle", characterNewBattle)
	runAnimation("idle1")

func damageStats(health, defense, attack, morale): # Print out the stats of getting damage
	print(str(self) + ": Body is getting Damaged")
	print(str(self) + ": Health stat being damaged for " + str(health))
	print(str(self) + ": Defense stat being damaged for " + str(defense))
	print(str(self) + ": Attack stat being damaged for " + str(attack))
	print(str(self) + ": Morale stat being damaged for " + str(morale))
	#stats.isDamaged()
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
		action2.getAttackInfo()
	if action3 != null:
		action3.removeCastTime()
		action3.getAttackInfo()
	if action4 != null:
		action4.removeCastTime()
		action4.getAttackInfo()

#--[ Level Label ]--

func activateLevelLabel(boolean: bool):
	#print(str(self) + ": activated Level Label: " + str(boolean))
	levelLabel.set_visible(boolean)

func updateLevelLabel():
	levelLabel.set_text(str(stats.level))

# Make sure these are all called in the Stat Component

#--[ FX ]--

func playLevelUpFX():
	levelUpFX.playFX()

func playhealthDeathFX():
	#print("Should run Health Death playFX")
	healthDeathFX.playFX()

func playDefenseDeathFX():
	#print("Should run Defense Death playFX")
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

func playHealthChangedFX(amount: float):
	healthChangedFX.setAmountChanged(amount)
	healthChangedFX.playFX()

func playDefenseChangedFX(amount: float):
	defenseChangedFX.setAmountChanged(amount)
	defenseChangedFX.playFX()

func playAttackChangedFX(amount: float):
	attackChangedFX.setAmountChanged(amount)
	attackChangedFX.playFX()

func playMoraleChangedFX(amount: float):
	moraleChangedFX.setAmountChanged(amount)
	moraleChangedFX.playFX()

#--[ Animation ]--

## When spawning choose an idle animation or new Turn happens
func idleAnimation():
	await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
	match randi_range(1, 4):
		1:
			runAnimation("idle1")
		2:
			runAnimation("idle2")
		3:
			runAnimation("idle3")

# The new way to do attack animation
# When AOE is used it either choose attack animation, special attack animation, buff animation, defense animation
func runAnimation(animationName: String):
	print(str(self) + ": (runAnimation) " + getAnimation() + " - " + animationName)
	match animationName:
		"idle1":
			characterSprite.play("idle1")
		"idle2":
			characterSprite.play("idle2")
		"idle3":
			characterSprite.play("idle3")
		"offensive1":
			characterSprite.play("offensive1")
		"offensive2":
			characterSprite.play("offensive2")
		"offensive3":
			characterSprite.play("offensive3")
		"offensive4":
			characterSprite.play("offensive4")
		"inoffensive1":
			characterSprite.play("inoffensive1")
		"inoffensive2":
			characterSprite.play("inoffensive1")
		"inoffensive3":
			characterSprite.play("inoffensive1")
		"inoffensive4":
			characterSprite.play("inoffensive1")
		"death":
			characterSprite.play("death")
		"surrender":
			characterSprite.play("surrender")
		_:
			push_warning(animationName + ": There is no sprite animation by that name!")
	emit_signal("characterAnimationFinished")

func getAnimation():
	return characterSprite.get_animation()

#--[ Extra ]--

## Get a Signal from the turnSystem to do this
func characterNewTurn():
	#print(str(self) + ": (L) Received Signal") # We're receiving the signal Twice?
	useActions()
	runAnimation("idle1")

func characterNewBattle():
	stats.resetCurrentStats()

# Idk why we have this, we'll see what this means
# ^ Determines if to spawn AOE or not
# Have the party container run a loop to use this function on all children
func changeFriendliness(boolean: bool):
	isFriendly = boolean
