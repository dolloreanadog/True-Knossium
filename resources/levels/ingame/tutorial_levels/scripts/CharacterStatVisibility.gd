extends TutorialControl

var amount: int = 0
func TutorialIndexSwitch() -> void:
	tutorialIndex += 1
	match tutorialIndex:
		0:
			pass
		1:
			pass

func _on_button_pressed() -> void:
	TutorialIndexSwitch()

func VisibilityStatItemSelected(_index: int) -> void:
	amount += 1
	print("amount: " + str(amount))
	if amount >= 2:
		dungeon.SwitchTutorialStep(dungeon.tutorialSteps.SURRENDER)
		self.queue_free()
