extends Control
class_name SurrenderWindow

@onready var dungeon: BaseLevel = get_tree().get_current_scene()

@onready var characterPFPHolder: TextureRect = $characterPFPHolder
@onready var characterNameLabel: Label = $CharacterNameLabel
@onready var characterLevelLabel: Label = $LevelLabel

var character: BaseCharacter
var characterPFP: Texture2D
var characterName: String
var characterLevel: int
var totalExperience: float

func _ready() -> void:
	dungeon.stopControlVisible(true, 1)
	dungeon.stopControlVisible(true, 2)
	dungeon.checkSpecialWindowContainer()

func setWindowInfo() -> void:
	self.z_index = 1
	characterLevel = character.stats.level
	characterPFPHolder.texture = characterPFP
	characterNameLabel.text = characterName 
	characterLevelLabel.text = "Level: " + str(characterLevel)

func _on_button_yes_pressed() -> void:
	#var newCharacter: BaseCharacter = character
	var loadedCharacter = load(character.scene_file_path)
	var instancedCharacter = loadedCharacter.instantiate()
	#newCharacter.isFriendly = true
	dungeon.friendlyPartyContainer.addCharacter(instancedCharacter, totalExperience, false, Vector2(0, 0))
	character.queue_free()
	character.stats.emit_signal("moraleBroken", 0, 0)
	if dungeon.specialWindowContainer.get_child_count() != 0:
		dungeon.stopControlVisible(false, 2)
#	dungeon.stopControl2.hide()
#	remove_child(self)
#	dungeon.call_deferred("checkSpecialWindowContainer")
	dungeon.checkSpecialWindowContainer()
	self.queue_free()

func _on_button_no_pressed() -> void:
	character.stats.setCurrentHealth(-1)
	if dungeon.specialWindowContainer.get_child_count() != 0:
		dungeon.stopControlVisible(false, 2)
#	dungeon.stopControl2.hide()
#	remove_child(self)
#	dungeon.call_deferred("checkSpecialWindowContainer")
	dungeon.checkSpecialWindowContainer()
	self.queue_free()

