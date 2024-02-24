extends Control
class_name SurrenderWindow

@onready var dungeon: levelDungeon = get_parent()

@onready var characterPFPHolder: TextureRect = $characterPFPHolder
@onready var characterNameLabel: Label = $CharacterNameLabel

var character: BaseCharacter
var characterPFP: Texture2D
var characterName: String
var totalExperience: float

func setWindowInfo():
	characterPFPHolder.texture = characterPFP
	characterNameLabel.text = characterName


func _on_button_yes_pressed():
	#var newCharacter: BaseCharacter = character
	var loadedCharacter = load(character.scene_file_path)
	var instancedCharacter = loadedCharacter.instantiate()
	#newCharacter.isFriendly = true
	dungeon.friendlyPartyContainer.addCharacter(instancedCharacter, totalExperience)
	character.queue_free()
	character.stats.emit_signal("moraleBroken", 0, 0)
	self.queue_free()

func _on_button_no_pressed():
	character.queue_free()
	character.stats.emit_signal("death", character.stats.worthEXP, character.stats.characterBody)
	self.queue_free()
