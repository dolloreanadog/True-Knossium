extends Control
class_name SurrenderWindow

@onready var dungeon: BaseLevel = get_tree().get_current_scene()

@onready var characterPFPHolder: TextureRect = $Control/characterPFPHolder
@onready var characterNameLabel: Label = $Control/CharacterNameLabel
@onready var characterLevelLabel: Label = $Control/LevelLabel
@onready var UpkeepLabel: Label = $Control/UpkeepLabel

var character: BaseCharacter
var characterPFP: Texture2D
var characterName: String
var characterLevel: int
var totalExperience: float
var UpkeepItemName: String
var UpkeepAmount: int

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
	UpkeepLabel.text = "Upkeep: " + str(UpkeepItemName) + " x" + str(UpkeepAmount)

func _on_button_yes_pressed() -> void:
	#var newCharacter: BaseCharacter = character
	var loadedCharacter = load(character.scene_file_path)
	var instancedCharacter = loadedCharacter.instantiate()
	#newCharacter.isFriendly = true
	dungeon.friendlyPartyContainer.addCharacter(instancedCharacter, totalExperience, false, Vector2(0, 0))
	character.queue_free()
	character.stats.emit_signal("moraleBroken", 0, 0)
	if dungeon.specialWindowContainer.get_child_count() != 0:
		$Control/ButtonYes.disabled = true
		$Control/ButtonNo.disabled = true
		await get_tree().create_timer(0.01).timeout
		dungeon.stopControlVisible(false, 2)
		dungeon.enemyPartyContainer.getCharactersInfo()
		dungeon.enemyPartyContainer.onAllCharactersDead()
#	dungeon.stopControl2.hide()
#	remove_child(self)
#	dungeon.call_deferred("checkSpecialWindowContainer")
	dungeon.checkSpecialWindowContainer()
	dungeon.updateUpkeepList()
	self.queue_free()

func _on_button_no_pressed() -> void:
	character.stats.setCurrentHealth(-1)
	if dungeon.specialWindowContainer.get_child_count() != 0:
		hide()
		while dungeon.enemyPartyContainer.AnyDeadCharacter() or dungeon.friendlyPartyContainer.AnyDeadCharacter():
			print("Character Animation has no finished yet!")
			await get_tree().create_timer(0.1).timeout
		dungeon.stopControlVisible(false, 2)
		dungeon.friendlyPartyContainer.getCharactersInfo()
		dungeon.enemyPartyContainer.getCharactersInfo()
		dungeon.friendlyPartyContainer.onAllCharactersDead()
		dungeon.enemyPartyContainer.onAllCharactersDead()
#	dungeon.stopControl2.hide()
#	remove_child(self)
#	dungeon.call_deferred("checkSpecialWindowContainer")
	dungeon.checkSpecialWindowContainer()
	self.queue_free()

