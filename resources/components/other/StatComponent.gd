extends Node
class_name StatComponent

#--[ Identification ]--
# Move to BaseCharacter the thing this is suppose to be parented to

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

## Sometimes it dies more than once
var alreadyDied: bool = false

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
signal statChanged
signal statReset

#--[ Basic Functions ]--
func _ready():
	emit_signal("statChanged")
	resetCurrentStats()
	getTotalStatPoints()

## Only using for deving, delete later

func resetCurrentStats():
	currentHealth = health
#	characterBody.bodyCurrentHealth = currentHealth
	currentDefense = defense
#	characterBody.bodyCurrentDefense = currentDefense
	currentAttack = attack
#	characterBody.bodyCurrentAttack = currentAttack
	currentMorale = morale
#	characterBody.bodyCurrentMorale = currentMorale
	#print(str(self) + ": current health = " + str(currentHealth))
	#print(str(self) + ": current defense = " + str(currentDefense))
	#print(str(self) + ": current attack = " + str(currentAttack))
	#print(str(self) + ": current morale = " + str(currentMorale))
	print(str(self) + ": Stats have been reset")
	updateActionAttackInfo()
	emit_signal("statChanged")
	emit_signal("statReset")

func getTotalStatPoints():
	@warning_ignore("narrowing_conversion")
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

func changeEXP(amount: float):
	experience += amount
	#print(str(self) + " " + str(characterBody.isFriendly) + ": EXP to Level Up = " + str(experience) + "/" + str(maxEXP))
	while experience >= maxEXP:
		experience -= maxEXP
		level += 1
		maxEXP *= 1.02
		worthEXP *= 1.25
		
		changeHealth(potentialHealthGain)
		changeDefense(potentialDefenseGain)
		changeAttack(potentialAttackGain)
		changeMorale(potentialMoraleGain)
		
		resetCurrentStats()
		getTotalStatPoints()
		characterBody.updateLevelLabel()
		
		if characterBody.levelUpFX != null:
			characterBody.playLevelUpFX()
		else:
			push_warning("There's no level up effect")
		
		#print(str(self) + " " + str(characterBody.isFriendly) + ": Leveled Up")
		#emit_signal("levelUp") # <- This causes a crash?
	#print(str(self) + ": experience changed = " + str(amount))
	emit_signal("statChanged")
	emit_signal("experienceChanged")


func healthDeath():
	print(str(self) + ": Running health death method")
	if alreadyDied != true:
		if currentHealth <= 0:
			print(str(self) + ": Health is Below Zero")
			
			if characterBody.healthDeathFX != null:
				characterBody.playhealthDeathFX()
			else:
				push_warning("There's no health death effect")
			alreadyDied = false
			
			# Hopefully we'll do something in the health Death FX
			# Like a timer or after finishing animation, so we don't instantly destroy it.
			emit_signal("death", worthEXP, characterBody)
	else:
		print(str(self) + ": It already died")

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
			push_warning("There's no over health max effect")
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
			push_warning("There's no over defense max effect")
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
			push_warning("There's no over attack max effect")
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
			push_warning("There's no over morale max effect")
	else:
		boolean = false
	return boolean

# Don't do anything with this until needed
#func isDamaged():
#	var boolean: bool
#	return boolean

#--[ When changing a variable above ]--



func changeHealth(amount: float):
	health += amount
	print(str(self) + ": health changed = " + str(amount))
	emit_signal("statChanged")
	emit_signal("healthChanged")

func changeDefense(amount: float):
	defense += amount
	print(str(self) + ": defense changed = " + str(amount))
	emit_signal("statChanged")
	emit_signal("defenseChanged")

func changeAttack(amount: float):
	attack += amount
	print(str(self) + ": attack changed = " + str(amount))
	emit_signal("statChanged")
	emit_signal("attackChanged")

func changeMorale(amount: float):
	morale += amount
	print(str(self) + ": morale changed = " + str(amount))
	emit_signal("statChanged")
	emit_signal("moraleChanged")

# There's an in lore reason why defense affects buffs
func changeCurrentHealth(amount: float):
	amount /= currentDefense
	currentHealth += amount
	if characterBody.healthChangedFX != null:
		characterBody.playHealthChangedFX()
#	else:
#		push_warning("There's no health changed effect")
	emit_signal("statChanged")
	healthDeath()
	overMaxHealth()

func changeCurrentDefense(amount: float):
	amount /= currentDefense
	currentDefense += amount
#	characterBody.bodyCurrentDefense = currentDefense
	#print(str(self) + ": current defense changed = " + str(amount))
	#print(str(self) + ": current defense = " + str(currentDefense))
	if characterBody.defenseChangedFX != null:
		characterBody.playDefenseChangedFX()
#	else:
#		push_warning("There's no defense changed effect")
	emit_signal("statChanged")
	defenseDeath()
	overMaxDefense()

func changeCurrentAttack(amount: float):
	amount /= currentDefense
	currentAttack += amount
#	characterBody.bodyCurrentAttack = currentAttack
	#print(str(self) + ": current attack changed = " + str(amount))
	#print(str(self) + ": current attack = " + str(currentAttack))
	if characterBody.attackChangedFX != null:
		characterBody.playAttackChangedFX()
#	else:
#		push_warning("There's no attack changed effect")
	emit_signal("statChanged")
	updateActionAttackInfo()
	attackDeath()
	overMaxAttack()

func changeCurrentMorale(amount: float):
	amount /= currentDefense
	currentMorale += amount
#	characterBody.bodyCurrentMorale = currentMorale
	#print(str(self) + ": current morale changed = " + str(amount))
	#print(str(self) + ": current moral = " + str(currentMorale))
	if characterBody.moraleChangedFX != null:
		characterBody.playMoraleChangedFX()
#	else:
#		push_warning("There's no morale changed effect")
	emit_signal("statChanged")
	moraleDeath()
	overMaxMorale()

#--[ Overridable ]--
func customReady():
	pass
