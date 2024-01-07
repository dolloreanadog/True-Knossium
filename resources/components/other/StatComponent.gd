extends Node
class_name StatComponent

#--[ Identification ]--
# Move to BaseCharacter the thing this is suppose to be parented to
@export var id: String
@export var idNumber: int

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
@export var potentialHealthGain: float = 5
@export var potentialDefenseGain: float = 5
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

#--[ Important Nodes ]--
@onready var characterBody: BaseCharacter = get_owner()
var Info: Label


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

## Only using for deving, delete later
func updateInfoLabel():
	Info = characterBody.get_node("InfoLabel")
	var Lhealth = "%.2f" % currentHealth
	var Ldefense = "%.2f" % currentDefense
	var Lattack = "%.2f" % currentAttack
	var Lmorale = "%.2f" % currentMorale
	if Info != null:
		Info.set_text(str(Lhealth) + "/" + str(health) + " " + str(Ldefense) + "/" + str(defense) + " " + str(Lattack) + "/" + str(attack) + " " + str(Lmorale) + "/" + str(morale))

func resetCurrentStats():
	currentHealth = health
	currentDefense = defense
	currentAttack = attack
	currentMorale = morale
	print(str(self) + ": current health = " + str(currentHealth))
	print(str(self) + ": current defense = " + str(currentDefense))
	print(str(self) + ": current attack = " + str(currentAttack))
	print(str(self) + ": current morale = " + str(currentMorale))
	print(str(self) + ": Stats have been reset")
	updateActionAttackInfo()
	updateInfoLabel()
	emit_signal("statReset")

func getTotalStatPoints():
	totalStatPoints = health + attack + defense + morale

func updateActionAttackInfo():
	if characterBody.action1 != null:
		characterBody.action1.updateAttackInfo()
	if characterBody.action2 != null:
		characterBody.action2.updateAttackInfo()
	if characterBody.action3 != null:
		characterBody.action3.updateAttackInfo()
	if characterBody.action4 != null:
		characterBody.action4.updateAttackInfo()

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
		# Change the perma stats values
		changeHealth(potentialHealthGain)
		changeDefense(potentialDefenseGain)
		changeAttack(potentialAttackGain)
		changeMorale(potentialMoraleGain)
		
		OnReachedMaxEXP()
		resetCurrentStats()
		getTotalStatPoints()
		print(str(self) + ": Leveled Up")
		emit_signal("levelUp")

func healthDeath():
	print(str(self) + ": Running health death method")
	var boolean: bool
	if currentHealth <= 0:
		print(str(self) + ": Health is Below Zero")
		emit_signal("death", worthEXP)
		boolean = true
		if characterBody.healthDeathFX != null:
			characterBody.playhealthDeathFX()
		else:
			push_warning("There's no health death effect")
		#await get_tree().create_timer(1.0).timeout
		get_owner().queue_free() # Temporary measure until FX get Working
	else:
		boolean = false
	return boolean

func defenseDeath():
	var boolean: bool
	if currentDefense < 1:
		currentDefense = 1 # Temporary Measure until we get FX to do it
		print(str(self) + ": current Defense reached 0: " + str(currentDefense))
		boolean = true
		if characterBody.defenseDeathFX != null:
			characterBody.playDefenseDeathFX()
		else:
			push_warning("There's no defense death effect")
	else:
		boolean = false
	return boolean

func attackDeath():
	var boolean: bool
	if currentAttack < 0:
		currentAttack = 0 # Temporary measure until FX get Working
		boolean = true
		if characterBody.attackDeathFX != null:
			characterBody.playAttackDeathFX()
		else:
			push_warning("There's no attack death effect")
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
			push_warning("There's no morale death effect")
	else:
		boolean = false
	return boolean

func overMaxHealth():
	var boolean: bool
	print(str(self) + ": Function not overridem!")
	if currentHealth > health:
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
	if currentDefense > defense:
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
	if currentAttack > attack:
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
	if currentMorale > morale:
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
	print(str(self) + ": experience changed = " + str(amount))
	emit_signal("experienceChanged")

func changeHealth(amount: float):
	health += amount
	print(str(self) + ": health changed = " + str(amount))
	emit_signal("healthChanged")

func changeDefense(amount: float):
	defense += amount
	print(str(self) + ": defense changed = " + str(amount))
	emit_signal("defenseChanged")

func changeAttack(amount: float):
	attack += amount
	print(str(self) + ": attack changed = " + str(amount))
	emit_signal("attackChanged")

func changeMorale(amount: float):
	morale += amount
	print(str(self) + ": morale changed = " + str(amount))
	emit_signal("moraleChanged")

# There's an in lore reason why defense affects buffs
func changeCurrentHealth(amount: float):
	amount /= currentDefense
	currentHealth += amount
	if characterBody.healthChangedFX != null:
		characterBody.playHealthChangedFX()
	else:
		push_warning("There's no health changed effect")
	print(str(self) + ": current health changed = " + str(amount))
	print(str(self) + ": current health = " + str(currentHealth))
	updateInfoLabel()
	healthDeath()
	overMaxHealth()

func changeCurrentDefense(amount: float):
	amount /= currentDefense
	currentDefense += amount
	print(str(self) + ": current defense changed = " + str(amount))
	print(str(self) + ": current defense = " + str(currentDefense))
	if characterBody.defenseChangedFX != null:
		characterBody.playDefenseChangedFX()
	else:
		push_warning("There's no defense changed effect")
	updateInfoLabel()
	defenseDeath()
	overMaxDefense()

func changeCurrentAttack(amount: float):
	amount /= currentDefense
	currentAttack += amount
	print(str(self) + ": current attack changed = " + str(amount))
	print(str(self) + ": current attack = " + str(currentAttack))
	if characterBody.attackChangedFX != null:
		characterBody.playAttackChangedFX()
	else:
		push_warning("There's no attack changed effect")
	updateInfoLabel()
	updateActionAttackInfo()
	attackDeath()
	overMaxAttack()

func changeCurrentMorale(amount: float):
	amount /= currentDefense
	currentMorale += amount
	print(str(self) + ": current morale changed = " + str(amount))
	print(str(self) + ": current moral = " + str(currentMorale))
	if characterBody.moraleChangedFX != null:
		characterBody.playMoraleChangedFX()
	else:
		push_warning("There's no morale changed effect")
	updateInfoLabel()
	moraleDeath()
	overMaxMorale()

#--[ Overridable ]--
func customReady():
	pass
