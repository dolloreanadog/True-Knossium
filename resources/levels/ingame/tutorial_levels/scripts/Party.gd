extends TutorialControl

@onready var partyMenu: PartyMenu = $"../../PartyMenu"

func _ready() -> void:
	var partyMenuButton: Button = partyMenu.get_node("ColorRect/ExitButton")
	partyMenuButton.connect("pressed", TutorialIndexSwitch)
	TutorialIndexSwitch()

func TutorialIndexSwitch() -> void:
	tutorialIndex += 1
	match tutorialIndex:
		0:
			$Part1.show()
		1:
			$Part1.hide()
			$Part2.show()
		2:
			dungeon.SwitchTutorialStep(dungeon.tutorialSteps.UPKEEP)
			self.queue_free()


func _on_show_party_button_pressed() -> void:
	TutorialIndexSwitch()
