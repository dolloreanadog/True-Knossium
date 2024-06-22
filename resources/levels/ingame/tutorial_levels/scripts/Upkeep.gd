extends TutorialControl

func TutorialIndexSwitch() -> void:
	tutorialIndex += 1
	match tutorialIndex:
		0:
			pass
		1:
			dungeon.SwitchTutorialStep(dungeon.tutorialSteps.ENDTURN)
			self.queue_free()

func _on_button_pressed() -> void:
	TutorialIndexSwitch()
