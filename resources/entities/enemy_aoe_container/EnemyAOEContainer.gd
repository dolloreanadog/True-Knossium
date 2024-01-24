extends Node2D
class_name EnemyAOEContainer

#--[ Important Nodes ]--
@export var system: TurnSystem
@export var targetPartyContainer: BasePartyContainer
@export var isAOESupportContainer: bool

#--[ Behavior ]--

enum behaviorPlans {TARGETSINGLE, TARGETLIMITED, TARGETMULTIPLE}
enum highAttackIn {HEALTH, DEFENSE, ATTACK, MORALE}
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

#--[ targets ]--
var targetedCharacters: Array
var targetedTanks: Array
var targetedMelee: Array
var targetedRanged: Array
var targetedSupport: Array


func _ready():
	system.connect("OnNewTurn", newTurn)

func newTurn():
	await get_tree().create_timer(0.5).timeout # Have this here so we get everything else loaded
	getCharacters()
	getAOEInfo()
	randomChoosePreferredPlan()
	call_deferred("useAllAOE")

# Get all AOE Info
func getAOEInfo():
	#await get_tree().create_timer(0.25).timeout
	AOEListHighHealthAttack.clear()
	AOEListHighDefenseAttack.clear()
	AOEListHighAttackAttack.clear()
	AOEListHighMoraleAttack.clear()
	
	AOEList = get_children()
	AOEList.filter(func(object): return is_instance_valid(object)) # Remove AOE that is null or freed
	print(str(self) + ": (getAOEInfo) old AOEList: " + str(AOEList))
	AOEListCount = get_child_count()
	var targetAOE: BaseAOE
	
	# Make sure AOE Array are clear, make sure to do the rest
	
	
	
	for i in AOEListCount:
		targetAOE = get_child(i)
		# Fix <Freed Object> issue
		# Fix do a check if AOE is active
		
		if targetAOE.statusActive != true:
			if isAOESupportContainer:
				if targetAOE.health >= targetAOE.defense:
					AOEListHighHealthAttack.push_back(targetAOE)
					print(str(self) + ": (getAOEInfo) Has high health attack ")
				elif targetAOE.defense >= targetAOE.attack:
					AOEListHighDefenseAttack.push_back(targetAOE)
					print(str(self) + ": (getAOEInfo) Has high defemse attack ")
				elif targetAOE.attack >= targetAOE.morale:
					AOEListHighAttackAttack.push_back(targetAOE)
					print(str(self) + ": (getAOEInfo) Has high attack attack ")
				else:
					AOEListHighMoraleAttack.push_back(targetAOE)
					print(str(self) + ": (getAOEInfo) Has high morale attack ")
			else:
				if targetAOE.health <= targetAOE.defense:
					AOEListHighHealthAttack.push_back(targetAOE)
					print(str(self) + ": (getAOEInfo) Has high health attack ")
				elif targetAOE.defense <= targetAOE.attack:
					AOEListHighDefenseAttack.push_back(targetAOE)
					print(str(self) + ": (getAOEInfo) Has high defemse attack ")
				elif targetAOE.attack <= targetAOE.morale:
					AOEListHighAttackAttack.push_back(targetAOE)
					print(str(self) + ": (getAOEInfo) Has high attack attack ")
				else:
					AOEListHighMoraleAttack.push_back(targetAOE)
					print(str(self) + ": (getAOEInfo) Has high morale attack ")
	
	print(str(self) + ": (getAOEInfo) new AOEList: " + str(AOEList))
	print(str(self) + ": (getAOEInfo) HighHealthAttackArray: " + str(AOEListHighHealthAttack))
	print(str(self) + ": (getAOEInfo) HighDefenseAttackArray: " + str(AOEListHighDefenseAttack))
	print(str(self) + ": (getAOEInfo) HighAttackAttackArray: " + str(AOEListHighAttackAttack))
	print(str(self) + ": (getAOEInfo) HighMoraleAttackArray: " + str(AOEListHighMoraleAttack))

#--[ Placing AOE ]--

## We choose the random plan
func randomChoosePreferredPlan():
	match randi_range(1, 3):
		1:
			preferredPlan = behaviorPlans.TARGETSINGLE
		2:
			preferredPlan = behaviorPlans.TARGETLIMITED
		3:
			preferredPlan = behaviorPlans.TARGETMULTIPLE

## We get the characters & seperate them into roles
func getCharacters():
	targetPartyContainer.getCharactersInfo()
	targetedCharacters = targetPartyContainer.getCharactersArray()
	targetedTanks = targetPartyContainer.getTankArray()
	targetedMelee = targetPartyContainer.getMeleeArray()
	targetedRanged = targetPartyContainer.getRangedArray()
	targetedSupport = targetPartyContainer.getSupportArray()
	print(str(self) + ": (getCharacters) health unsorted: " + str(targetedCharacters))

#--[ AI usage of AOE Version 1]--

## this function does use all the AOE
#func useAllAOE():
#	await get_tree().create_timer(0.25).timeout
#	print(str(self) + ": (useAllAOE) Using all AOE!")
#	#var targetCharacterArray: Array
#	var targetAOE: BaseAOE
#	var priorityAttack: highAttackIn
#	#var targetCharacter: BaseCharacter
#
#	# Make good comments btw
#	# How do we get target AOE? Solution is down below
#	print(str(self) + ": (useAllAOE) AOEListHighHealthAttack!: " + str(AOEListHighHealthAttack.size()))
#	print(str(self) + ": (useAllAOE) AOEListHighDefenseAttack!: " + str(AOEListHighDefenseAttack.size()))
#	print(str(self) + ": (useAllAOE) AOEListHighAttackAttack!: " + str(AOEListHighAttackAttack.size()))
#	print(str(self) + ": (useAllAOE) AOEListHighMoraleAttack!: " + str(AOEListHighMoraleAttack.size()))
#	# Something wrong here, while statement not activating.
#	while AOEListHighHealthAttack.size() + AOEListHighDefenseAttack.size() + AOEListHighAttackAttack.size() + AOEListHighMoraleAttack.size() > 0:
#		print(str(self) + ": (useAllAOE) going through AOE List")
#
#		if AOEListHighHealthAttack.size() != 0:
#			targetAOE = AOEListHighHealthAttack.pop_back()
#			print(str(self) + ": (useAllAOE) AOE is high health!: " + str(targetAOE))
#			priorityAttack = highAttackIn.HEALTH
#			print(str(self) + ": (useAllAOE) priorityAttack!: " + str(priorityAttack))
#		elif AOEListHighDefenseAttack.size() != 0:
#			targetAOE = AOEListHighDefenseAttack.pop_back()
#			print(str(self) + ": (useAllAOE) AOE is high defense!: " + str(targetAOE))
#			priorityAttack = highAttackIn.DEFENSE
#			print(str(self) + ": (useAllAOE) priorityAttack!: " + str(priorityAttack))
#		elif AOEListHighAttackAttack.size() != 0:
#			targetAOE = AOEListHighAttackAttack.pop_back()
#			print(str(self) + ": (useAllAOE) AOE is high attack!: " + str(targetAOE))
#			priorityAttack = highAttackIn.ATTACK
#			print(str(self) + ": (useAllAOE) priorityAttack!: " + str(priorityAttack))
#		elif AOEListHighMoraleAttack.size() != 0:
#			targetAOE = AOEListHighMoraleAttack.pop_back()
#			print(str(self) + ": (useAllAOE) AOE is high morale!: " + str(targetAOE))
#			priorityAttack = highAttackIn.MORALE
#			print(str(self) + ": (useAllAOE) priorityAttack!: " + str(priorityAttack))
#		else:
#			push_warning(str(self) + ": (useAllAOE) AOE IS NULL!: ")
#			continue
#
#		if targetAOE != null:
#			print(str(self) + ": (useAllAOE) AOE is not null!: " + str(targetAOE))
#			if isAOESupportContainer != true:
#				print(str(self) + ": (useAllAOE) AOE is in AOE Support Container: " + str(targetAOE))
#				if targetAOE.isMelee:
#					print(str(self) + ": (useAllAOE) targetAOE is Melee!")
#					# This if statement, as because it's melee, should target Front, Middle, then Back
#					if targetedTanks.size() != 0 or targetedMelee.size() != 0:
#						var targetCharacterArray: Array = targetedTanks + targetedMelee
#						print(str(self) + ": (useAllAOE) targetting CQC characters: " + str(targetCharacterArray))
#						chosenPreferredPlan(priorityAttack, targetCharacterArray, targetAOE)
#					elif targetedRanged.size() != 0:
#						var targetCharacterArray: Array = targetedRanged
#						print(str(self) + ": (useAllAOE) targetting Ranged characters: " + str(targetCharacterArray))
#						chosenPreferredPlan(priorityAttack, targetCharacterArray, targetAOE)
#					else:
#						var targetCharacterArray: Array = targetedSupport
#						print(str(self) + ": (useAllAOE) targetting Support characters: " + str(targetCharacterArray))
#						chosenPreferredPlan(priorityAttack, targetCharacterArray, targetAOE)
#				else: #targetAOE.isMelee == false
#					var targetCharacterArray: Array = targetedTanks + targetedMelee + targetedRanged + targetedSupport
#					print(str(self) + ": (useAllAOE) target every character: " + str(targetCharacterArray))
#					chosenPreferredPlan(priorityAttack, targetCharacterArray, targetAOE)
#			else: #isAOESupportContainer == true
#				# Target all Characters
#				var targetCharacterArray: Array = targetedTanks + targetedMelee + targetedRanged + targetedSupport
#				print(str(self) + ": (useAllAOE) target AOE is not Melee: " + str(targetCharacterArray))
#				chosenPreferredPlan(priorityAttack, targetCharacterArray, targetAOE)
#
#		else:
#			push_warning(str(self) + ": (useAllAOE) targetAOE was null ")
#	print(str(self) + ": (useAllAOE) finished while statement")
#
### once we get the preferred plan, put it here. Need to fill out the rest of the prerequisites as well.
#func chosenPreferredPlan(priorityAttack, targetCharacterArray, targetAOE):
#	print(str(self) + ": (useAllAOE) (ChosenPreferredPlan)")
#	print(str(self) + ": (useAllAOE) (ChosenPreferredPlan) priorityAttack: " + str(priorityAttack))
#	print(str(self) + ": (useAllAOE) (ChosenPreferredPlan) targetCharacterArray: " + str(targetCharacterArray))
#	print(str(self) + ": (useAllAOE) (ChosenPreferredPlan) targetAOE: " + str(targetAOE))
#	match preferredPlan:
#		behaviorPlans.TARGETSINGLE:
#			print(str(self) + ": (useAllAOE) (ChosenPreferredPlan) targetting single character")
#			useAOE(priorityAttack, targetCharacterArray, targetAOE, 1)
#		behaviorPlans.TARGETLIMITED:
#			# 50% of targetCharacterArray should be targettable
#			print(str(self) + ": (useAllAOE) (ChosenPreferredPlan) targetting limited characters")
#			var uses = targetCharacterArray.size() / 2
#			useAOE(priorityAttack, targetCharacterArray, targetAOE, uses)
#		behaviorPlans.TARGETMULTIPLE:
#			# 100% of targetCharacterArray should be targettable
#			print(str(self) + ": (useAllAOE) (ChosenPreferredPlan) targetting all")
#			var uses = targetCharacterArray.size()
#			useAOE(priorityAttack, targetCharacterArray, targetAOE, uses)
#
### Finally get to use the AOE
#func useAOE(priorityAttack: highAttackIn, targetCharacterArray: Array, targetAOE: BaseAOE, timesOfUse: int):
#	print(str(self) + ": (useAllAOE) (useAOE)")
#	match priorityAttack:
#		highAttackIn.HEALTH:
#			# This does damage, Lowest Health is at the back
#			targetedCharacters.sort_custom(sortHealth)
#		highAttackIn.DEFENSE:
#			targetedCharacters.sort_custom(sortDefense)
#		highAttackIn.ATTACK:
#			targetedCharacters.sort_custom(sortAttack)
#		highAttackIn.MORALE:
#			targetedCharacters.sort_custom(sortMorale)
#
#	targetCharacterArray.reverse()
#	targetCharacterArray.resize(timesOfUse)
#	targetedCharacters.shuffle()
#	var targetCharacter: BaseCharacter = targetCharacterArray.pop_back()
#	positionAOE(targetAOE, targetCharacter)

#--[ AI usage of AOE Version 2]--




func positionAOE(targetAOE: BaseAOE, targetCharacter: BaseCharacter):
	if targetCharacter != null:
		targetAOE.set_global_position(targetCharacter.global_position)
		print(str(self) + ": (positionAOE) targetAOE position: " + str(targetAOE.global_position))
		print(str(self) + ": (positionAOE) targetCharacter position: " + str(targetCharacter.global_position))
		targetAOE.draggable = false
		print("Placed")


#--[ Sorting ]--
func sortHealth(a: BaseCharacter, b: BaseCharacter):
	print("sorting health")
	if a.stats.currentHealth > b.stats.currentHealth:
		#print(str(self) + ": (getCharacters) true")
		return true
	#print(str(self) + ": (getCharacters) false")
	return false

func sortDefense(a, b):
	print("sorting defense")
	if a.stats.currentDefense > b.stats.currentDefense:
		#print(str(self) + ": (getCharacters) true")
		return true
	#print(str(self) + ": (getCharacters) false")
	return false

func sortAttack(a, b):
	print("sorting attack")
	if a.stats.currentAttack > b.stats.currentAttack:
		print(str(self) + ": (getCharacters) true")
		return true
	print(str(self) + ": (getCharacters) false")
	return false

func sortMorale(a, b):
	print("sorting morale")
	if a.stats.currentMorale > b.stats.currentMorale:
		print(str(self) + ": (getCharacters) true")
		return true
	print(str(self) + ": (getCharacters) false")
	return false


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
