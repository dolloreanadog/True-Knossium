extends Node
class_name StatComponent

#--[ Identification ]--
# Move to BaseCharacter the thing this is suppose to be parented to

#--[ experience ]--
var level: int = 0
var experience: float = 0
var totalExperience: float = 0
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
var moraleAlreadyBroken: bool = false


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
func _ready() -> void:
	emit_signal("statChanged")
	resetCurrentStats()
	getTotalStatPoints()

func resetCurrentStats() -> void:
	currentHealth = health
	currentDefense = defense
	currentAttack = attack
	currentMorale = morale
	print(str(self) + ": Stats have been reset")
	updateActionAttackInfo()
	emit_signal("statChanged")
	emit_signal("statReset")

func getTotalStatPoints() -> void:
	@warning_ignore("narrowing_conversion")
	totalStatPoints = health + attack + defense + morale

func getCurrentTotalStatPoints() -> float:
	return (currentHealth + currentDefense + currentAttack + currentMorale)

func updateActionAttackInfo() -> void:
	if characterBody.action1 != null:
		characterBody.action1.updateAttackInfo()
	if characterBody.action2 != null:
		characterBody.action2.updateAttackInfo()
	if characterBody.action3 != null:
		characterBody.action3.updateAttackInfo()
	if characterBody.action4 != null:
		characterBody.action4.updateAttackInfo()

# -- Can override these, or add a resource to add an effect to these?

func changeEXP(amount: float) -> void:
	experience += amount
	totalExperience += amount
	while experience >= maxEXP:
		experience -= maxEXP
		level += 1
		maxEXP *= 1.05
		worthEXP *= 1.025
		characterBody.ResourceMaxDropAmount += 2
		
		changeHealth(potentialHealthGain)
		changeDefense(potentialDefenseGain)
		changeAttack(potentialAttackGain)
		changeMorale(potentialMoraleGain)
		
		currentHealth = clampf(currentHealth * 1.10, 0, health)
		currentDefense = clampf(currentDefense * 1.15, 0, defense)
		currentAttack = clampf(currentAttack * 1.15, 0, attack)
		currentMorale = clampf(currentMorale * 1.10, 0, morale)
		getTotalStatPoints()
		characterBody.updateLevelLabel()
		
		if characterBody.levelUpFX != null:
			characterBody.playLevelUpFX()
		else:
			push_warning("There's no level up effect")
		
	emit_signal("statChanged")
	emit_signal("experienceChanged")


func healthDeath() -> void:
	print(str(self) + ": Running health death method")
	if alreadyDied != true:
		if currentHealth <= 0:
			print(str(self) + ": Health is Below Zero")
			if characterBody.healthDeathFX != null:
				characterBody.playhealthDeathFX()
			else:
				push_warning("There's no health death effect")
			alreadyDied = true
			characterBody.dungeon.totalCharactersDied += 1
			characterBody.inventory.addToInventory(characterBody.ResourceDrop, randi_range(0, characterBody.ResourceMaxDropAmount))
			#emit_signal("death", worthEXP, characterBody) # Moving this FX, some issues having it not there
	else:
		print(str(self) + ": It already died")

func defenseDeath() -> void:
	if currentDefense < 1:
		print(str(self) + ": current Defense reached 0: " + str(currentDefense))
		if characterBody.defenseDeathFX != null:
			characterBody.playDefenseDeathFX()
		else:
			push_warning("There's no defense death effect")

func attackDeath() -> void:
	if currentAttack < 0:
		if characterBody.attackDeathFX != null:
			print("Attack Died")
			characterBody.playAttackDeathFX()
		else:
			push_warning("There's no attack death effect")

func moraleDeath() -> void:
	if currentMorale <= 0:
		if moraleAlreadyBroken != true:
			if characterBody.moraleDeathFX != null:
				characterBody.playMoraleDeathFX()
			else:
				push_warning("There's no morale death effect")
			moraleAlreadyBroken = true
			characterBody.dungeon.totalCharactersSurrendered += 1

func overMaxHealth() -> void:
	print(str(self) + ": Function not overridem!")
	if currentHealth > health:
		if characterBody.overHealthFX != null:
			characterBody.playOverHealthFX()
		else:
			push_warning("There's no over health max effect")

func overMaxDefense() -> void:
	if currentDefense > defense:
		if characterBody.overDefenseFX != null:
			characterBody.playOverDefenseFX()
		else:
			push_warning("There's no over defense max effect")
	
func overMaxAttack() -> void:
	if currentAttack > attack:
		if characterBody.overAttackFX != null:
			characterBody.playOverAttackFX()
		else:
			push_warning("There's no over attack max effect")
	
func overMaxMorale() -> void:
	if currentMorale > morale:
		if characterBody.overMoraleFX != null:
			characterBody.playOverMorale()
		else:
			push_warning("There's no over morale max effect")


#--[ When changing a variable above ]--

func changeHealth(amount: float) -> void:
	health += amount
#	print(str(self) + ": health changed = " + str(amount))
	emit_signal("statChanged")
	emit_signal("healthChanged")

func changeDefense(amount: float) -> void:
	defense += amount
#	print(str(self) + ": defense changed = " + str(amount))
	emit_signal("statChanged")
	emit_signal("defenseChanged")

func changeAttack(amount: float) -> void:
	attack += amount
#	print(str(self) + ": attack changed = " + str(amount))
	emit_signal("statChanged")
	emit_signal("attackChanged")

func changeMorale(amount: float) -> void:
	morale += amount
#	print(str(self) + ": morale changed = " + str(amount))
	emit_signal("statChanged")
	emit_signal("moraleChanged")

func SetHealth(amount: float) -> void:
	health = amount
#	print(str(self) + ": health Setd = " + str(amount))
	healthDeath()
	overMaxHealth()
	emit_signal("statChanged")
	emit_signal("healthChanged")

func SetDefense(amount: float) -> void:
	if amount < 1:
		amount = 1
	defense = amount
#	print(str(self) + ": defense Setd = " + str(amount))
	defenseDeath()
	overMaxDefense()
	emit_signal("statChanged")
	emit_signal("defenseChanged")

func SetAttack(amount: float) -> void:
	attack = amount
#	print(str(self) + ": attack Setd = " + str(amount))
	attackDeath()
	overMaxAttack()
	emit_signal("statChanged")
	emit_signal("attackChanged")

func SetMorale(amount: float) -> void:
	morale = amount
#	print(str(self) + ": morale changed = " + str(amount))
	moraleDeath()
	overMaxMorale()
	emit_signal("statChanged")
	emit_signal("moraleChanged")

## update the save with these amounts
func UpdateSave(amount: float) -> void:
	if characterBody.isFriendly:
		if amount < 0:
			SaveSystem.GameInfoDict.EnemyTotalDamage += absf(amount)
		elif amount > 0:
			SaveSystem.GameInfoDict.PlayerTotalSupport += absf(amount)
	elif !characterBody.isFriendly:
		if amount < 0:
			SaveSystem.GameInfoDict.PlayerTotalDamage += absf(amount)
		elif amount > 0:
			SaveSystem.GameInfoDict.EnemyTotalSupport += absf(amount)
			

func changeCurrentHealth(amount: float) -> void:
	UpdateSave(amount)
	if amount < 0:
		amount /= currentDefense
	currentHealth += amount
	if characterBody.healthChangedFX != null:
		characterBody.playHealthChangedFX(amount)
#	else:
#		push_warning("There's no health changed effect")
	emit_signal("statChanged")
	healthDeath()
	overMaxHealth()

func changeCurrentDefense(amount: float) -> void:
	UpdateSave(amount)
	if amount < 0:
		amount /= currentDefense / 2
	currentDefense += amount
	if characterBody.defenseChangedFX != null:
		characterBody.playDefenseChangedFX(amount)
#	else:
#		push_warning("There's no defense changed effect")
	emit_signal("statChanged")
	defenseDeath()
	overMaxDefense()

func changeCurrentAttack(amount: float) -> void:
	UpdateSave(amount)
	if amount < 0:
		amount /= currentDefense
	currentAttack += amount
	if characterBody.attackChangedFX != null:
		characterBody.playAttackChangedFX(amount)
#	else:
#		push_warning("There's no attack changed effect")
	emit_signal("statChanged")
	updateActionAttackInfo()
	attackDeath()
	overMaxAttack()

func changeCurrentMorale(amount: float) -> void:
	UpdateSave(amount)
	if amount < 0:
		amount /= currentDefense
	currentMorale += amount
	if characterBody.moraleChangedFX != null:
		characterBody.playMoraleChangedFX(amount)
#	else:
#		push_warning("There's no morale changed effect")
	emit_signal("statChanged")
	moraleDeath()
	overMaxMorale()

#--[ For Save/Load System or something else ]--

func setCurrentHealth(amount: float) -> void:
	currentHealth = amount
	healthDeath()
	overMaxHealth()

func setCurrentDefense(amount: float) -> void:
	currentDefense = amount
	defenseDeath()
	overMaxDefense()
	
func setCurrentAttack(amount: float) -> void:
	currentAttack = amount
	updateActionAttackInfo()
	attackDeath()
	overMaxAttack()
	
func setCurrentMorale(amount: float) -> void:
	currentMorale = amount
	moraleDeath()
	overMaxMorale()

func setCurrentExperience(amount: float) -> void: 
	experience = amount
	totalExperience = amount
	while experience >= maxEXP:
		experience -= maxEXP
		level += 1
		maxEXP *= 1.02
		worthEXP *= 1.02
		
		changeHealth(potentialHealthGain)
		changeDefense(potentialDefenseGain)
		changeAttack(potentialAttackGain)
		changeMorale(potentialMoraleGain)
		
		currentHealth += clampf(currentHealth * 1.10, 0, health)
		currentDefense += clampf(currentDefense * 1.50, 0, defense)
		currentAttack += clampf(currentAttack * 1.50, 0, attack)
		currentMorale += clampf(currentMorale * 1.10, 0, morale)
		getTotalStatPoints()
		characterBody.updateLevelLabel()
		
	
	emit_signal("statChanged")
	emit_signal("experienceChanged")
