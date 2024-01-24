extends Button

@onready var turnSystem: TurnSystem = $"../../TurnSystem"

func _on_pressed():
	turnSystem.newTurn()
	$"../../StopControl".visible = true
	await get_tree().create_timer(2.5).timeout
	$"../../StopControl".visible = false
