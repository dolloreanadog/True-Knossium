extends Button

@onready var turnSystem: TurnSystem = $"../../TurnSystem"
@onready var dungeon: BaseLevel = get_tree().get_current_scene()

func _on_pressed():
	turnSystem.newTurn()
	dungeon.EndTurnButtonHighlight(false)
