extends Button

@onready var turnSystem: TurnSystem = $"../../TurnSystem"

func _on_pressed():
	turnSystem.newTurn()
