extends Control
class_name KnossiumConsole

var dungeon: BaseLevel
var unlocked: bool = false
@export var consoleInputLine: LineEdit
@export var consoleTextLabel: RichTextLabel

@export_category("Debug Menus")
@export var spawnBehaviorDebugMenu: ColorRect
@export var spawnCharacterDebugMenu: ColorRect
@export var spawnItemDebugMenu: ColorRect

@export_category("Spawn Character Variables")
@export var spawnCharacterInputFileNameLine: LineEdit
@export var spawnCharacterPartyOption: OptionButton
@export var spawnCharacterInputExperienceLine: SpinBox
#Confirm Button

@export_category("Spawn Behavior Variables")
@export var spawnBehaviorChooser: OptionButton
@export var normalSpawnBehaviorWeightSpinBox: SpinBox
@export var hordeSpawnBehaviorWeightSpinBox: SpinBox
@export var eliteSpawnBehaviorWeightSpinBox: SpinBox
@export var legendarySpawnBehaviorWeightSpinBox: SpinBox
@export var mythicalSpawnBehaviorWeightSpinBox: SpinBox
@export var godSpawnBehaviorWeightSpinBox: SpinBox
# Confirm Button

@export_category("Spawn Item Variables")
@export var spawnItemInputFileNameLine: LineEdit
@export var spawnItemAmountSpinbox: SpinBox

#--[ Misc. Functions ]--
func _ready() -> void:
	dungeon = get_tree().get_current_scene()
	unlocked = SaveSystem.GameInfoDict.ConsoleUnlocked
	self.z_index = 11
	spawnBehaviorDebugMenu.z_index = 11
	spawnCharacterDebugMenu.z_index = 11
	

func ConsoleInputLineSubmitted(new_text: String) -> void:
	printConsoleText(new_text)
	
	if unlocked == true:
		new_text = new_text.to_lower()
		if new_text.begins_with("spawnbehavior"):
			spawnBehaviorDebugMenu.show()
			# Set the editable spinbox weights
			normalSpawnBehaviorWeightSpinBox.value = dungeon.difficulty.SpawnBehaviors["Normal Spawn Behavior"]
			hordeSpawnBehaviorWeightSpinBox.value = dungeon.difficulty.SpawnBehaviors["Horde Spawn Behavior"]
			eliteSpawnBehaviorWeightSpinBox.value = dungeon.difficulty.SpawnBehaviors["Elite Spawn Behavior"]
			legendarySpawnBehaviorWeightSpinBox.value = dungeon.difficulty.SpawnBehaviors["Legendary Spawn Behavior"]
			mythicalSpawnBehaviorWeightSpinBox.value = dungeon.difficulty.SpawnBehaviors["Mythical Spawn Behavior"]
			godSpawnBehaviorWeightSpinBox.value = dungeon.difficulty.SpawnBehaviors["God Spawn Behavior"]
		if new_text.begins_with("spawncharacter"):
			spawnCharacterDebugMenu.show()
		if new_text.begins_with("spawnitem"):
			spawnItemDebugMenu.show()
		if new_text.begins_with("shop"):
			dungeon.GotoShop()
		if new_text.begins_with("nextarea"):
			dungeon.GoToNextArea()
	else:
		if new_text.contains("IOKNOWSKNOSSIUM"):
			printConsoleText("Console is now unlocked!")
			unlocked = true
		else:
			printConsoleText("Console is locked!")
	
	if new_text.contains("clear"):
		consoleTextLabel.clear()

func printConsoleText(text: String) -> void:
	consoleTextLabel.text += "\n " + text
	consoleInputLine.text = ""

#--[ Spawn Behavior Functions ]--

# Spinbox probability weights

func NormalSpawnBehaviorWeightSpinboxChanged(value: float) -> void:
	dungeon.difficulty.SpawnBehaviors["Normal Spawn Behavior"] = value


func HordeSpawnBehaviorWeightSpinboxChanged(value: float) -> void:
	dungeon.difficulty.SpawnBehaviors["Horde Spawn Behavior"] = value


func EliteSpawnBehaviorWeightSpinboxChanged(value: float) -> void:
	dungeon.difficulty.SpawnBehaviors["Elite Spawn Behavior"] = value


func LegendarySpawnBehaviorWeightSpinboxChanged(value: float) -> void:
	dungeon.difficulty.SpawnBehaviors["Legendary Spawn Behavior"] = value


func MythicalSpawnBehaviorWeightSpinboxChanged(value: float) -> void:
	dungeon.difficulty.SpawnBehaviors["Mythical Spawn Behavior"] = value


func GodSpawnBehaviorWeightSpinboxChanged(value: float) -> void:
	dungeon.difficulty.SpawnBehaviors["God Spawn Behavior"] = value

# Guarantee Spawn Behavior next battle

# This button only be used for the guarantee spawn behavior
func SpawnBehaviorConfirmButton() -> void:
	if spawnBehaviorChooser.selected == 0:
		dungeon.difficulty.debugGuaranteeSpawning = false
	else:
		dungeon.difficulty.debugGuaranteeSpawning = true
		dungeon.difficulty.debugChosenSpawnBehavior = spawnBehaviorChooser.selected

#--[ Spawn Character Functions]--

# When pressed get all information from Path, Experience, & Party
func SpawnCharacterConfirmButtonPressed() -> void:
	if FileAccess.file_exists(spawnCharacterInputFileNameLine.text):
		var loadCharacter := load(spawnCharacterInputFileNameLine.text)
		var targetCharacterInstance = loadCharacter.instantiate()
		if spawnCharacterPartyOption.selected == 0:
			dungeon.friendlyPartyContainer.addCharacter(targetCharacterInstance, spawnCharacterInputExperienceLine.value, false, Vector2(0, 0))
		elif spawnCharacterPartyOption.selected == 1:
			dungeon.enemyPartyContainer.addCharacter(targetCharacterInstance, spawnCharacterInputExperienceLine.value, false, Vector2(0, 0))
		else:
			printConsoleText("Did Not Select a Party!")
	else:
		printConsoleText("That Character does not exist!")

#--[ Spawn Items ]--
func SpawnItemConfirmButton() -> void:
	if FileAccess.file_exists(spawnItemInputFileNameLine.text):
		var loadedItem := load(spawnItemInputFileNameLine.text)
		@warning_ignore("narrowing_conversion")
		dungeon.inventory.addToInventory(loadedItem.duplicate(true), spawnItemAmountSpinbox.value)
	else:
		printConsoleText("That Item does not exist!")

#--[ Exit Buttons ]--
func ConsoleExitButtonPressed() -> void:
	if !(dungeon.isCharactersActive) && dungeon.specialWindowContainer.get_child_count() == 0 && dungeon.difficulty.isCharactersSpawningIn != true:
		dungeon.stopControlVisible(false, 1)
		dungeon.stopControlVisible(false, 2)
	spawnCharacterDebugMenu.hide()
	spawnBehaviorDebugMenu.hide()
	spawnItemDebugMenu.hide()
	self.hide()

func SpawnCharacterMenuExitButtonPressed() -> void:
	spawnCharacterDebugMenu.hide()

func SpawnBehaviorExitButtonPressed() -> void:
	spawnBehaviorDebugMenu.hide()

func SpawnItemMenuExitButtonPressed() -> void:
	spawnItemDebugMenu.hide()
