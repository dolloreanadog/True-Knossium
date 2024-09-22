extends TutorialControl

func TutorialIndexSwitch() -> void:
	tutorialIndex += 1
	match tutorialIndex:
		0:
			$"../../ButtonsContainer/EndTurn".disabled = true
			$"../../ButtonsContainer/ShowMenuButton".disabled = true
		1:
			$Part1.hide()
			$Part2.show()
		2:
			dungeon.SwitchTutorialStep(dungeon.tutorialSteps.AOEVISIBILITY)
			self.queue_free()

func _on_button_pressed() -> void:
	TutorialIndexSwitch()
