extends BaseLevel
class_name TutorialLevel

# Add these to the level for the tutorial
@export var debugCharacterFileName: String
@export var debugItem: BaseInventoryItem
@export var debugItem1: BaseInventoryItem

# This will decide what step we are in the tutorial process
enum tutorialSteps {NONE, INTRO, INVENTORY, PARTY, UPKEEP, ENDTURN, DRAGGING, AUTOPLACE, OFFENSIVEAOE, SUPPORTAOE, AOEINFOBOX, MELEEMECHANIC, AOEVISIBILITY, CHARACTERSTATVISIBILITY, SURRENDER, SHOP}
var tutorialStep: tutorialSteps = tutorialSteps.NONE

func _ready():
	var confirmed: bool
	print("is stopControl Visible: " + str(stopControl.visible))
	print("is stopControl2 Visible: " + str(stopControl2.visible))
	Global.StartLoadingScreen(false)
	stopControlVisible(true, 1)
	
	# Add the player character
	var loadedDebugCharacter := load(debugCharacterFileName)
	var instantiateDebugCharacter: BaseCharacter = loadedDebugCharacter.instantiate()
	friendlyPartyContainer.addCharacter(instantiateDebugCharacter, 0, false, Vector2(0, 0))
	instantiateDebugCharacter.stats.setCurrentHealth(999)
	
	inventory.addToInventory(debugItem, 9999)
	inventory.addToInventory(debugItem1, 2)
	
	system.newTurn()
	system.newBattle()
	confirmed = true
	EndTurnButtonHighlight(true)
#	await loadConfirmation()
	if confirmed:
		updateValueOfStatusBar()
		friendlyPartyContainer.onAllCharactersDead()
		SaveWarningLabel.hide()
		await get_tree().create_timer(1.5).timeout
		Global.EndLoadingScreen()
		stopControlVisible(false, 1)
		SwitchTutorialStep(tutorialSteps.INTRO)

func SwitchTutorialStep(step: tutorialSteps):

	# Have each tutorial thingy done in each node themslves?
	match step:
		tutorialSteps.NONE:
			stopControlVisible(false, 1)
			stopControlVisible(false, 2)
		tutorialSteps.INTRO: # Introduce Player to Knossium
			stopControlVisible(true, 1)
			stopControlVisible(true, 2)
			$TutorialContainer/Intro.show()
		tutorialSteps.INVENTORY: # Open Inventory & show pointers to certain parts of the inventory
			$TutorialContainer/Inventory.show()
		tutorialSteps.PARTY: # Open Party & show pointers to certain parts of the party
			$TutorialContainer/Party.show()
		tutorialSteps.UPKEEP: # Show the upkeep list in the main area & explain upkeep in dialogue
			$TutorialContainer/Upkeep.show()
		tutorialSteps.ENDTURN: # Have the player end turn, explain that every turn your AOE might spawn, if no AOE hit end turn
			$TutorialContainer/EndTurn.show()
		tutorialSteps.DRAGGING: # Ask the player to move the AOE to their spots.
			$TutorialContainer/Dragging.show()
		tutorialSteps.AOEVISIBILITY:
			# Explain how AOE Visibility work
			$TutorialContainer/AOEVisibility.show()
		tutorialSteps.CHARACTERSTATVISIBILITY:
			# Explain character Visibility work
			$TutorialContainer/CharacterStatVisibility.show()
		tutorialSteps.SURRENDER:
			# Showcase surrendering by setting all characters on the other team by -999 morale
			$TutorialContainer/Surrender.show()
		tutorialSteps.SHOP:
			# Introduce the shop on new battle guaranteed, don't go to confirmation window
			get_tree().change_scene_to_file("res://resources/levels/ingame/tutorial_levels/TutorialShopLevel.tscn")
		_:
			push_error("Not a valid step.")

func saveToSaveSystem() -> void:
	print("This is the Tutorial, We break the save system here.")
#	SaveWarningLabel.show()
#	SaveSystem.clearSaveThroughEmptying()
#	SaveSystem.clearSaveThroughDeletion()
	# Peak Total Stats have to be broken due to how we do what we're doing up top
	await get_tree().create_timer(0.05).timeout
	
#	if peakTotalStatPoints < friendlyPartyContainer.totalStatPoints: # Peak Total Stats keep resetting to 0?
#		print("------------")
#		print("New Peak Score")
#		print("Peak Total Stat Local Points: " + str(peakTotalStatPoints))
#		print("Peak Total Stat Saved Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
#		print("Total Stat Points: " + str(friendlyPartyContainer.totalStatPoints))
#		SaveSystem.GameInfoDict.PeakTotalStatPoints = friendlyPartyContainer.totalStatPoints
#		peakTotalStatPoints = SaveSystem.GameInfoDict.PeakTotalStatPoints
#		print("New Peak Total Stat Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
#	else:
#		SaveSystem.GameInfoDict.PeakTotalStatPoints = peakTotalStatPoints
#		print("------------")
#		print("Not Peak Score")
#		print("Peak Total Stat Local Points: " + str(peakTotalStatPoints))
#		print("Peak Total Stat Saved Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
#	SaveSystem.GameInfoDict.CharactersDied = totalCharactersDied
#	SaveSystem.GameInfoDict.CharactersSurrendered = totalCharactersSurrendered
#	SaveSystem.GameInfoDict.Battles = system.battle
#	SaveSystem.GameInfoDict.Turns = system.turn
#	SaveSystem.GameInfoDict.SpawnBehaviorWeights = difficulty.SpawnBehaviors
#	print("Saved Spawn Behavior Weights: " + str(SaveSystem.GameInfoDict.SpawnBehaviorWeights))
#
#	if Global.getBattlesWon() < system.battle:
#		Global.progressionDict.BattlesWon = system.battle
#
#	saveFriendlyCharacters()
#	await SavedFriendlyCharacters
#	print("Saved Friendly Characters Passed")
#	saveEnemyCharacters()
#	await SavedEnemyCharacters
#	print("Saved Enemy Characters Passed")
#	saveItems()
#	await SavedItems
#	print("Saved Items Passed")
#	saveAOE()
#	await SavedAOE
#	print("Saved AOE Passed")
#	Global.call_deferred("saveAllData")
#	await Global.Saved
#	print("Saved Global Data Passed")
#	SaveSystem.call_deferred("saveAllData")
#	await SaveSystem.Saved
#	print("Saved All Game Data Passed")
#	print("GameInfoDict PeakTotalStatPoints: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict CharactersDied: " + str(SaveSystem.GameInfoDict.CharactersDied))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict CharactersSurrendered: " + str(SaveSystem.GameInfoDict.CharactersSurrendered))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict Battles: " + str(SaveSystem.GameInfoDict.Battles))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict Turns: " + str(SaveSystem.GameInfoDict.Turns))
#	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict FriendlyCharactersList: " + str(SaveSystem.GameInfoDict.FriendlyCharactersList))
	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict EnemyCharactersList: " + str(SaveSystem.GameInfoDict.EnemyCharactersList))
	await get_tree().create_timer(0.05).timeout
#	print("GameInfoDict Inventory: " + str(SaveSystem.GameInfoDict.Inventory))
	await get_tree().create_timer(0.05).timeout
#	print("Saved GameInfoDict SupportAOEList: " + str(SaveSystem.GameInfoDict.SupportAOEList))
#	SaveWarningLabel.hide()
	emit_signal("SaveFinished")

