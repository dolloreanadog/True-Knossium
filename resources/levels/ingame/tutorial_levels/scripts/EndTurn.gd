extends TutorialControl

func TutorialIndexSwitch() -> void:
	tutorialIndex += 1
	match tutorialIndex:
		0:
			pass
		1:
			dungeon.SwitchTutorialStep(dungeon.tutorialSteps.DRAGGING)
			self.queue_free()
		2:
			pass
		3:
			pass

func _on_end_turn_pressed() -> void:
	TutorialIndexSwitch()
