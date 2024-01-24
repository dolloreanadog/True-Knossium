extends Control
# No Worried for modulate, tint will work simply fine if we use it on the CharacterBody2D

var FriendlyPartyContainer: BasePartyContainer
var EnemyPartyContainer: BasePartyContainer

var allCharacters: Array
var allTanks: Array
var allMelee: Array
var allRanged: Array
var allSupport: Array

@onready var main = get_parent()
@onready var system: TurnSystem = main.get_node("TurnSystem")

enum activeList {NORMAL, HEALTH, DEFENSE, ATTACK, MORALE, LEVEL}
var visibleActive: activeList
# Make use of modulate to tint the sprites
# We need sprites

var activeVisibleLevel: bool

#--[ Basic ]--

func _ready():
	FriendlyPartyContainer = main.get_node("FriendlyPartyContainer")
	EnemyPartyContainer = main.get_node("EnemyPartyContainer")
	FriendlyPartyContainer.connect("charactersUpdated", updateModulation)
	EnemyPartyContainer.connect("charactersUpdated", updateModulation)
	system.connect("OnNewTurn", updateModulation)
	

#--[ Buttons ]--

func _on_view_normal_pressed():
	visibleActive = activeList.NORMAL
	activeVisibleLevel = false
	updateModulation()


func _on_view_health_pressed():
	visibleActive = activeList.HEALTH
	activeVisibleLevel = false
	updateModulation()

func _on_view_defense_pressed():
	visibleActive = activeList.DEFENSE
	activeVisibleLevel = false
	updateModulation()

func _on_view_attack_pressed():
	visibleActive = activeList.ATTACK
	activeVisibleLevel = false
	updateModulation()

func _on_view_morale_pressed():
	visibleActive = activeList.MORALE
	activeVisibleLevel = false
	updateModulation()

func _on_view_level_pressed():
	visibleActive = activeList.LEVEL
	if activeVisibleLevel:
		activeVisibleLevel = false
	else:
		activeVisibleLevel = true
	updateModulation()

func updateModulation():
	getPartyContainersInfo()
	match visibleActive:
		activeList.NORMAL:
			modulateNormalView()
		activeList.HEALTH:
			modulateHealthView()
		activeList.DEFENSE:
			modulateDefenseView()
		activeList.ATTACK:
			modulateAttackView()
		activeList.MORALE:
			modulateMoraleView()
		activeList.LEVEL:
			modulateLevelView()

#--[ Getting Character ]--

func getPartyContainersInfo():
	print(str(self) + ": got Party Container Info")
	allCharacters = FriendlyPartyContainer.characters + EnemyPartyContainer.characters
	allTanks = FriendlyPartyContainer.characterIsTank + EnemyPartyContainer.characterIsTank
	allMelee = FriendlyPartyContainer.characterIsDPSMelee + EnemyPartyContainer.characterIsDPSMelee
	allRanged = FriendlyPartyContainer.characterIsDPSRanged + EnemyPartyContainer.characterIsDPSRanged
	allSupport = FriendlyPartyContainer.characterIsHealer + EnemyPartyContainer.characterIsHealer
	#print(str(self) + ": AllCharactersInfo: " + str(allCharacters))
	#print(str(self) + ": AllTanksInfo: " + str(allTanks))
	#print(str(self) + ": AllMeleeInfo: " + str(allMelee))
	#print(str(self) + ": AllRangedInfo: " + str(allRanged))
	#print(str(self) + ": AllSupportInfo: " + str(allSupport))

#--[ Modulation ]--

func modulateNormalView():
	#print(str(self) + ": Turning total into Normal:" + str(allCharacters.size()))
	#print(str(self) + ": Turning total into Normal:" + str(allCharacters))
	var LallCharacters = allCharacters
	for i in LallCharacters.size():
		#var character: BaseCharacter
		#var characterStats: StatComponent
		var Lcharacter = LallCharacters.pop_back()
		if Lcharacter != null:
			Lcharacter.set_modulate(Color(1, 1, 1))
			Lcharacter.activateLevelLabel(false)
		else:
			print("what?")
		
	getPartyContainersInfo()

func modulateHealthView():
	
	#print(str(self) + ": Turning total into Health View:" + str(allCharacters.size()))
	#print(str(self) + ": Turning total Health View:" + str(allCharacters))
	
	var LallCharacters: Array = allCharacters
	# Go through all
	for i in LallCharacters.size():
		var character: BaseCharacter
		var characterStats: StatComponent
		var Lcharacter = LallCharacters.pop_back()
		#print(str(self) + ": Looped Character:" + str(Lcharacter))
		# There's a Freed object in the character list, This will become an issue. If they Pile up
		if Lcharacter != null:
			character = Lcharacter
			characterStats = character.get_node("StatComponent")
			
			var Rcoloration = absf((characterStats.currentHealth / characterStats.health) - 1)
			var Gcoloration = characterStats.currentHealth / characterStats.health
			
			character.activateLevelLabel(false)
			character.modulate = Color(Rcoloration, Gcoloration, 0)
		
	print(str(self) + ": LallCharacters = " + str(LallCharacters))
	getPartyContainersInfo()

func modulateDefenseView():
	
	#print(str(self) + ": Turning total into Defense View:" + str(allCharacters.size()))
	#print(str(self) + ": Turning total Defense View:" + str(allCharacters))
	
	var LallCharacters: Array = allCharacters
	# Go through all
	for i in LallCharacters.size():
		var character: BaseCharacter
		var characterStats: StatComponent
		var Lcharacter = LallCharacters.pop_back()
		#print(str(self) + ": Looped Character:" + str(Lcharacter))
		# There's a Freed object in the character list, This will become an issue. If they Pile up
		if Lcharacter != null:
			character = Lcharacter
			characterStats = character.get_node("StatComponent")
			
			var Rcoloration = absf((characterStats.currentDefense / characterStats.defense) - 1)
			var Bcoloration = characterStats.currentDefense / characterStats.defense
			
			character.activateLevelLabel(false)
			character.modulate = Color(Rcoloration, 0, Bcoloration)
		
	print(str(self) + ": LallCharacters = " + str(LallCharacters))
	getPartyContainersInfo()

func modulateAttackView():
	
	#print(str(self) + ": Turning total into Attack View:" + str(allCharacters.size()))
	#print(str(self) + ": Turning total Attack View:" + str(allCharacters))
	
	var LallCharacters: Array = allCharacters
	# Go through all
	for i in LallCharacters.size():
		var character: BaseCharacter
		var characterStats: StatComponent
		var Lcharacter = LallCharacters.pop_back()
		#print(str(self) + ": Looped Character:" + str(Lcharacter))
		# There's a Freed object in the character list, This will become an issue. If they Pile up
		if Lcharacter != null:
			character = Lcharacter
			characterStats = character.get_node("StatComponent")
			
			var Rcoloration = absf((characterStats.currentAttack / characterStats.attack) - 1)
			var Gcoloration = characterStats.currentAttack / characterStats.attack
			
			character.activateLevelLabel(false)
			character.modulate = Color(Rcoloration, Gcoloration, 0)
		
	
	print(str(self) + ": LallCharacters = " + str(LallCharacters))
	getPartyContainersInfo()

func modulateMoraleView():
	
	#print(str(self) + ": Turning total into Morale View:" + str(allCharacters.size()))
	#print(str(self) + ": Turning total Morale View:" + str(allCharacters))
	
	var LallCharacters: Array = allCharacters
	# Go through all
	for i in LallCharacters.size():
		var character: BaseCharacter
		var characterStats: StatComponent
		var Lcharacter = LallCharacters.pop_back()
		#print(str(self) + ": Looped Character:" + str(Lcharacter))
		# There's a Freed object in the character list, This will become an issue. If they Pile up
		if Lcharacter != null:
			character = Lcharacter
			characterStats = character.get_node("StatComponent")
			
			var Rcoloration = absf((characterStats.currentDefense / characterStats.defense) - 1)
			var Gcoloration = characterStats.currentDefense / characterStats.defense
			
			character.activateLevelLabel(false)
			character.modulate = Color(Rcoloration, Gcoloration, 0)
		
	print(str(self) + ": LallCharacters = " + str(LallCharacters))
	getPartyContainersInfo()

# How are we going to show level?
# Plan 1: Have text appear displaying level
func modulateLevelView():
	#print(str(self) + ": Turning total into Level:" + str(allCharacters.size()))
	#print(str(self) + ": Turning total into Level:" + str(allCharacters))
	var LallCharacters = allCharacters
	for i in LallCharacters.size():
		#var character: BaseCharacter
		#var characterStats: StatComponent
		var Lcharacter = LallCharacters.pop_back()
		if Lcharacter != null:
			Lcharacter.set_modulate(Color(1, 1, 1))
			Lcharacter.updateLevelLabel()
			Lcharacter.activateLevelLabel(activeVisibleLevel)
		else:
			print("what?")
	getPartyContainersInfo()
