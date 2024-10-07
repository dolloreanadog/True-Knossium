extends Control

@onready var nameLabel: Label = $Panel/Name
@onready var textLabel: Label = $Panel/Text

func Config(character: BaseCharacter) -> void:
	nameLabel.text = character.id
	textLabel.text = str(character.characterDescription) + "\n"
	if is_instance_valid(character.action1):
		textLabel.text += str(character.action1.ActionName) + ": " + str(character.action1.description) + "\n"
	if is_instance_valid(character.action2):
		textLabel.text += str(character.action2.ActionName) + ": " + str(character.action2.description) + "\n"
	if is_instance_valid(character.action3):
		textLabel.text += str(character.action3.ActionName) + ": " + str(character.action3.description) + "\n"
	if is_instance_valid(character.action4):
		textLabel.text += str(character.action4.ActionName) + ": " + str(character.action4.description) + "\n"
