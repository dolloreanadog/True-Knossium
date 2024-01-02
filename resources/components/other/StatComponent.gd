extends Node
class_name StatComponent

#--[ Identification ]--
# Move to BaseCharacter the thing this is suppose to be parented to
@export var id: String
@export var idNumber: int
var isFriendly: bool

#--[ experience ]--
var level: int = 0
var experience: float = 0
var totalStatPoints: int
## When exp reaches this number, increase level
@export var maxEXP: float = 10
## when killed give the exp to other container & split it there
@export var worthEXP: float = 5

#--[ Roles ]--
enum rolesList {Healer, DPSRanged, DPSMelee, Tank}
@export var role: rolesList

#--[ Stats ]--
# These are the maximum of a stat value
@export var health: float = 10
@export var defense: float = 2
@export var attack: float = 3
@export var morale: float = 10

# When leveling how much is added to a stat
@export var potentialDefenseGain: float = 5
@export var potentialHealthGain: float = 5
@export var potentialAttackGain: float = 5
@export var potentialMoraleGain: float = 5

# The values that should be changed
var currentHealth: float
var currentDefense: float
var currentAttack: float
var currentMorale: float

# This may be deprecated
# The new plan is to spawn the AOE the BaseActionComponent provided
var canAction: bool = true

@onready var characterBody: BaseCharacter = get_owner()
#--[ Signals ]--
#-- Experience
signal levelUp
signal experienceChanged
#-- Stats Below Minimum
signal death
# When player's character morale = 0, death
# When enemy's character morale = 0, player chooses if character joins or not.
signal defenseBroken
signal attackBroken
signal moraleBroken 
#-- Stats Above Maximum
signal overHealth
signal overDefense
signal overAttack
signal overMorale
#-- Stat Gain/Loss
signal healthChanged
signal defenseChanged
signal attackChanged
signal moraleChanged
signal statReset

#--[ Basic Functions ]--
func _ready():
	resetCurrentStats()
	getTotalStatPoints()

# Idk why we have this, we'll see what this means
# ^ Determines if to spawn AOE or not
# Have the party container run a loop to use this function on all children
func changeFriendliness(boolean: bool):
	isFriendly = boolean

func resetCurrentStats():
	currentHealth = health
	currentDefense = attack
	currentAttack = defense
	currentMorale = morale
	print(currentHealth)
	emit_signal("statReset")

func getTotalStatPoints():
	totalStatPoints = health + attack + defense + morale

# -- Can override these, or add a resource to add an effect to these?

func OnReachedMaxEXP():
	if experience >= maxEXP:
		level += 1
		experience -= maxEXP
		worthEXP *= 1.5
		
		if characterBody.levelUpFX != null:
			characterBody.playLevelUpFX()
		else:
			push_warning("There's no level up effect")
		OnReachedMaxEXP()
		resetCurrentStats()
		getTotalStatPoints()
		print("Leveled Up")
		emit_signal("levelUp")

func healthDeath():
	print("Running health death method")
	var boolean: bool
	if currentHealth <= 0:
		emit_signal("death", worthEXP)
		boolean = true
		if characterBody.healthDeathFX != null:
			characterBody.playhealthDeathFX()
		else:
			push_warning("There's no health death effect")
		await get_tree().create_timer(1.0).timeout
		get_owner().queue_free()
	else:
		boolean = false
	return boolean

func defenseDeath():
	var boolean: bool
	if currentDefense <= 0:
		boolean = true
		if characterBody.defenseDeathFX != null:
			characterBody.playDefenseDeathFX()
		else:
			push_warning("There's no health death effect")
	else:
		boolean = false
	return boolean

func attackDeath():
	var boolean: bool
	if currentAttack <= 0:
		boolean = true
		if characterBody.attackDeathFX != null:
			characterBody.playAttackDeathFX()
		else:
			push_warning("There's no health death effect")
	else:
		boolean = false
	return boolean


func moraleDeath():
	var boolean: bool
	if currentMorale <= 0:
		boolean = true
		if characterBody.moraleDeathFX != null:
			characterBody.playMoraleDeathFX()
		else:
			push_warning("There's no health death effect")
	else:
		boolean = false
	return boolean

func overMaxHealth():
	var boolean: bool
	print("Function not overridem!")
	if currentHealth >= health:
		boolean = true
		if characterBody.overHealthFX != null:
			characterBody.playOverHealthFX()
		else:
			push_warning("There's no health max effect")
	else:
		boolean = false
	return boolean

func overMaxDefense():
	var boolean: bool
	if currentHealth >= health:
		boolean = true
		if characterBody.overDefenseFX != null:
			characterBody.playOverDefenseFX()
		else:
			push_warning("There's no defense max effect")
	else:
		boolean = false
	return boolean
	
func overMaxAttack():
	var boolean: bool
	if currentHealth >= health:
		boolean = true
		if characterBody.overAttackFX != null:
			characterBody.playOverAttackFX()
		else:
			push_warning("There's no attack max effect")
	else:
		boolean = false
	return boolean
	
func overMaxMorale():
	var boolean: bool
	if currentMorale >= morale:
		boolean = true
		if characterBody.overMoraleFX != null:
			characterBody.playOverMorale()
		else:
			push_warning("There's no morale max effect")
	else:
		boolean = false
	return boolean

# Don't do anything with this until needed
func isDamaged():
	var boolean: bool
	return boolean

#--[ When changing a variable above ]--

func changeEXP(amount: float):
	experience += amount
	OnReachedMaxEXP()
	emit_signal("experienceChanged")

func changeHealth(amount: float):
	health += amount
	print("health changed")
	emit_signal("healthChanged")

func changeDefense(amount: float):
	defense += amount
	emit_signal("defenseChanged")

func changeAttack(amount: float):
	attack += amount
	emit_signal("attackChanged")

func changeMorale(amount: float):
	morale += amount
	emit_signal("moraleChanged")

func changeCurrentHealth(amount: float):
	currentHealth += amount
	if characterBody.healthChangedFX != null:
		characterBody.playHealthChangedFX()
	else:
		push_warning("There's no health changed effect")
	healthDeath()
	overMaxHealth()

func changeCurrentDefense(amount: float):
	currentDefense += amount
	if characterBody.defenseChangedFX != null:
		characterBody.playDefenseChangedFX()
	else:
		push_warning("There's no defense changed effect")
	defenseDeath()
	overMaxDefense()

func changeCurrentAttack(amount: float):
	currentAttack += amount
	if characterBody.attackChangedFX != null:
		characterBody.playAttackChangedFX()
	else:
		push_warning("There's no attack changed effect")
	attackDeath()
	overMaxAttack()

func changeCurrentMorale(amount: float):
	currentMorale += amount
	if characterBody.moraleChangedFX != null:
		characterBody.playMoraleChangedFX()
	else:
		push_warning("There's no morale death effect")
	moraleDeath()
	overMaxMorale()


