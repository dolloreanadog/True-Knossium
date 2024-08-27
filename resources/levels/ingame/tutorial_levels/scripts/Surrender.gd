extends TutorialControl

var endTurnActive: bool = false

func _ready() -> void:
	pass

func TutorialIndexSwitch() -> void:
	tutorialIndex += 1
	match tutorialIndex:
		0:
			endTurnActive = true
			self.show()
			await get_tree().create_timer(0.2).timeout
			dungeon.enemyPartyContainer.getCharactersInfo()
			for i in dungeon.enemyPartyContainer.characters.size():
				var character: BaseCharacter = dungeon.enemyPartyContainer.characters[i]
				character.stats.changeCurrentMorale(-999)
			dungeon.system.newTurn()
			# Do 999 damage to all enemy characters, make sure to grab
			# End Turn
		1:
			dungeon.SwitchTutorialStep(dungeon.tutorialSteps.SHOP)
			self.queue_free()

func _on_button_pressed() -> void:
	TutorialIndexSwitch()

func _on_end_turn_pressed() -> void:
	if endTurnActive:
		TutorialIndexSwitch()
