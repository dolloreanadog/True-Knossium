extends Node
class_name AutoPlacementAOEComponent
# What has to be changed
# Get_child() functions need to be updated

@export var AOEContainer: BaseSpawnArea
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

#--[ Functions ]--

func activateAOEPlacement():
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
	
	AOEList = AOEContainer.get_children()
	AOEList = AOEList.filter(func(object): return is_instance_valid(object)) # Remove AOE that is null or freed
	print(str(self) + ": (getAOEInfo) old AOEList: " + str(AOEList))
	AOEListCount = AOEContainer.get_child_count()
	var targetAOE: BaseAOE
	
	# Make sure AOE Array are clear, make sure to do the rest
	
	for i in AOEListCount:
		targetAOE = AOEContainer.get_child(i)
		
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

#--[ AI usage of AOE Version 2]--

## gets all AOE & uses them
func useAllAOE():
#	await get_tree().create_timer(0.5).timeout
	var targetAOE: BaseAOE
	var attackPriority: highAttackIn
	
	print(str(self) + ": (getAOEInfo) HighHealthAttackArray: " + str(AOEListHighHealthAttack))
	print(str(self) + ": (getAOEInfo) HighDefenseAttackArray: " + str(AOEListHighDefenseAttack))
	print(str(self) + ": (getAOEInfo) HighAttackAttackArray: " + str(AOEListHighAttackAttack))
	print(str(self) + ": (getAOEInfo) HighMoraleAttackArray: " + str(AOEListHighMoraleAttack))
	
	while AOEListHighAttackAttack.size() + AOEListHighDefenseAttack.size() + AOEListHighHealthAttack.size() + AOEListHighMoraleAttack.size() != 0:
		var targettedCharactersHealth: Array = []
		var targettedCharactersDefense: Array = []
		var targettedCharactersAttack: Array = []
		var targettedCharactersMorale: Array = []
		var targetCharacter: BaseCharacter
		
		if AOEListHighHealthAttack.size() != 0:
			print(str(self) + ": (useAllAOE) targetAOE: " + str(targetAOE))
			print(str(self) + ": (useAllAOE) (List) AOEHealthTargets: " + str(AOEListHighHealthAttack))
			targetAOE = AOEListHighHealthAttack.pop_back()
			attackPriority = highAttackIn.HEALTH
			if is_instance_valid(targetAOE):
				targettedCharactersHealth += findTarget(attackPriority, targetAOE)
				targettedCharactersHealth.shuffle()
				print(str(self) + ": (useAllAOE) (PreferredPlan) CharacterTargetList: " + str(targettedCharactersHealth))
				targetCharacter = targettedCharactersHealth.pop_back()
				print(str(self) + ": (useAllAOE) (PreferredPlan) AOEListHighHealthAttack: " + str(targetAOE))
				positionAOE(targetAOE, targetCharacter)
			
		elif AOEListHighDefenseAttack.size() != 0:
			print(str(self) + ": (useAllAOE) targetAOE: " + str(targetAOE))
			targetAOE = AOEListHighDefenseAttack.pop_back()
			attackPriority = highAttackIn.DEFENSE
			if is_instance_valid(targetAOE):
				targettedCharactersDefense += findTarget(attackPriority, targetAOE)
				targettedCharactersDefense.shuffle()
				print(str(self) + ": (useAllAOE) (PreferredPlan) CharacterTargetList: " + str(targettedCharactersDefense))
				targetCharacter = targettedCharactersDefense.pop_back()
				print(str(self) + ": (useAllAOE) (PreferredPlan) AOEListHighDefenseAttack: " + str(targetAOE))
				positionAOE(targetAOE, targetCharacter)
			
		elif AOEListHighAttackAttack.size() != 0:
			print(str(self) + ": (useAllAOE) targetAOE: " + str(targetAOE))
			targetAOE = AOEListHighAttackAttack.pop_back()
			attackPriority = highAttackIn.ATTACK
			if is_instance_valid(targetAOE):
				targettedCharactersAttack += findTarget(attackPriority, targetAOE)
				targettedCharactersAttack.shuffle()
				print(str(self) + ": (useAllAOE) (PreferredPlan) CharacterTargetList: " + str(targettedCharactersAttack))
				targetCharacter = targettedCharactersAttack.pop_back()
				print(str(self) + ": (useAllAOE) (PreferredPlan) AOEListHighAttackAttack: " + str(targetAOE))
				positionAOE(targetAOE, targetCharacter)
			
		elif AOEListHighMoraleAttack.size() != 0:
			print(str(self) + ": (useAllAOE) targetAOE: " + str(targetAOE))
			targetAOE = AOEListHighMoraleAttack.pop_back()
			attackPriority = highAttackIn.MORALE
			if is_instance_valid(targetAOE):
				targettedCharactersMorale += findTarget(attackPriority, targetAOE)
				targettedCharactersMorale.shuffle()
				print(str(self) + ": (useAllAOE) (PreferredPlan) CharacterTargetList: " + str(targettedCharactersMorale))
				targetCharacter = targettedCharactersMorale.pop_back()
				print(str(self) + ": (useAllAOE) (PreferredPlan) AOEListHighMoraleAttack: " + str(targetAOE))
				positionAOE(targetAOE, targetCharacter)
	print(str(self) + ": (useAllAOE) (PreferredPlan) Ending Using AOE For Statement")
	

func findTarget(priority: highAttackIn, targetAOE: BaseAOE):
	
	var target: Array
	var targetArray: Array
	
	targetArray.clear()
	
	if targetAOE.isMelee:
#		print(str(targetAOE) + "targetAOE isMelee 1 = " + str(targetAOE.isMelee))
		match checkCurrentSectionAlive():
			0:
#				print("how are these frontline troops alive? 1")
				targetArray = targetedMelee + targetedTanks
			1:
#				print("CQC Section has been eliminated! 1")
				targetArray = targetedMelee + targetedTanks + targetedRanged
			2:
#				print("All that's left is supports! 3")
				targetArray = targetedMelee + targetedTanks + targetedRanged + targetedSupport
	else:
		targetArray = targetedMelee + targetedTanks + targetedRanged + targetedSupport
#		print(str(targetAOE) + "targetAOE isMelee 1 = " + str(targetAOE.isMelee))
	
	match priority:
		highAttackIn.HEALTH:
			print("sorting health")
			targetArray.sort_custom(sortHealth)
		highAttackIn.DEFENSE:
			print("sorting defense")
			targetArray.sort_custom(sortDefense)
		highAttackIn.ATTACK:
			print("sorting attack")
			targetArray.sort_custom(sortAttack)
		highAttackIn.MORALE:
			print("sorting morale")
			targetArray.sort_custom(sortMorale)
	targetArray.reverse()
	match preferredPlan: # WE EITHER PUT checkCurrentSectionAlive somewhere here!!!
		behaviorPlans.TARGETSINGLE:
			print("Targetted Single")
			targetArray.resize(1)
		behaviorPlans.TARGETLIMITED:
			print("Targetted Limited")
			@warning_ignore("integer_division")
			targetArray.resize(clampi(targetArray.size() / 2, 1, 999))
		behaviorPlans.TARGETMULTIPLE:
			print("Targetted Multiple")
	if targetAOE.isMelee:
		print(str(targetAOE) + "targetAOE isMelee 2 = " + str(targetAOE.isMelee))
		match checkCurrentSectionAlive():
			0:
				pass
#				print("how are these frontline troops alive? 2")
				# Effectively Useless
#				targetArray.filter(func(object): return object.get_node("StatComponent").role == 0 or object.get_node("StatComponent").role == 1 )
			1:
				pass
#				print("CQC Section has been eliminated! 2")
				# Effectively Useless
#				targetArray.filter(func(object): return object.get_node("StatComponent").role == 2)
			2:
				pass
#				print("All that's left is supports! 2")
			_:
				pass
#				print(str(targetAOE) + "targetAOE isMelee 2 = " + str(targetAOE.isMelee))
	
	target = targetArray
	print(str(targetAOE) + ": targetedArray = " + str(target))
	return target

func positionAOE(targetAOE: BaseAOE, targetCharacter: BaseCharacter):
	if targetCharacter != null:
		if targetAOE.draggable:
			targetAOE.set_global_position(targetCharacter.global_position)
			print(str(self) + ": (positionAOE) targetAOE: " + str(targetAOE))
			print(str(self) + ": (positionAOE) targetAOE position: " + str(targetAOE.global_position))
			print(str(self) + ": (positionAOE) targetCharacter: " + str(targetCharacter))
			print(str(self) + ": (positionAOE) targetCharacter position: " + str(targetCharacter.global_position))
			print("Placed")
			await get_tree().create_timer(0.03).timeout
			if !(isAOESupportContainer):
#				var itemGot: bool = await targetAOE.getItemsInside()
#				if itemGot:
				targetAOE.areaOverlapCharacter(false)


#--[ Sorting ]--
func sortHealth(a: BaseCharacter, b: BaseCharacter):
	if a.stats.currentHealth > b.stats.currentHealth:
		#print(str(self) + ": (getCharacters) true")
		return true
	#print(str(self) + ": (getCharacters) false")
	return false

func sortDefense(a, b):
	if a.stats.currentDefense > b.stats.currentDefense:
		#print(str(self) + ": (getCharacters) true")
		return true
	#print(str(self) + ": (getCharacters) false")
	return false

func sortAttack(a, b):
	if a.stats.currentAttack > b.stats.currentAttack:
		print(str(self) + ": (getCharacters) true")
		return true
	print(str(self) + ": (getCharacters) false")
	return false

func sortMorale(a, b):
	if a.stats.currentMorale > b.stats.currentMorale:
		print(str(self) + ": (getCharacters) true")
		return true
	print(str(self) + ": (getCharacters) false")
	return false

## Returns an integer depending on whether what sections are dead, 0 if CQC is alive, 1 if CQC is dead & Ranged Alive, 2 if both CQC & Ranged Dead
func checkCurrentSectionAlive(): # We can do -> int, but we'll do that version 2
	if targetPartyContainer.characterIsTank.size() != 0 or targetPartyContainer.characterIsDPSMelee.size() != 0:
		print(str(self) + ": (checkCurrentSectionAlive) All CQC characters alive!")
		return 0
	elif targetPartyContainer.characterIsDPSRanged.size() != 0:
		print(str(self) + ": (checkCurrentSectionAlive) All CQC characters dead!")
		return 1
	else:
		print(str(self) + ": (checkCurrentSectionAlive) Supports only left alive!")
		return 2
	
