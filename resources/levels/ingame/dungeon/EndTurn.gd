extends Button

@onready var turnSystem: TurnSystem = $"../../TurnSystem"
@onready var dungeon: BaseLevel = get_tree().get_current_scene()
var confirmationBox: ConfirmationBox


func _on_pressed():
	if !(dungeon.AnyAOEStillLeft()):
		newTurn()
	else:
		var instance := preload("res://resources/user_interface/confimation_box/confirmationBox.tscn").instantiate()
		confirmationBox = instance
		dungeon.add_child(confirmationBox)
		confirmationBox.set_position(Vector2(0, 0))
		confirmationBox.z_index = 2
		confirmationBox.setLabel("Still have unused AOE, they will be used. Are you sure to go to new turn?")
		confirmationBox.connect("YesPressed", newTurn)
		confirmationBox.connect("NoPressed", ContinueTurn)

func newTurn():
		turnSystem.newTurn()
		dungeon.EndTurnButtonHighlight(false)
		if is_instance_valid(confirmationBox):
			confirmationBox.queue_free()

func ContinueTurn():
	confirmationBox.queue_free()


