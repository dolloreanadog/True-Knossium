extends Control

var onIndex: int = 0

@onready var gameStartMenu: PartyStartMenu = get_tree().get_current_scene()
@onready var setupOptionButton: OptionButton = $SetupOptionButton
@onready var newSetupButton: Button = $HBoxContainer/NewSetupButton
@onready var saveSetupButton: Button = $HBoxContainer/SaveSetupButton
@onready var deleteSetupButton: Button = $HBoxContainer/DeleteSetupButton

func _ready() -> void:
	await Global.LoadLoadoutData()
#	deleteSetupButton.disabled = true
#	saveSetupButton.disabled = true
	LoadAllLoudouts()
	if setupOptionButton.item_count > 0:
		setupOptionButton.select(0)
		setupOptionButton.item_selected.emit(0)
	else:
		setupOptionButton.select(-1)
		setupOptionButton.item_selected.emit(-1)

func LoadAllLoudouts() -> void:
	var loadoutsArray: Array = Global.loadoutsListDict.Loudouts
	setupOptionButton.clear()
	print("All Loudouts: " + str(loadoutsArray))
	print("All Loudouts Amount: " + str(loadoutsArray.size()))
	for i in loadoutsArray.size():
		setupOptionButton.add_item(str(i))

func loadSetup() -> void:
	var loadoutCharacters: Array = Global.loadoutsListDict.Loudouts[setupOptionButton.selected].Characters
	var loadoutItems: Array = Global.loadoutsListDict.Loudouts[setupOptionButton.selected].Items
	print("Loading Loadout Characters: " + str(loadoutCharacters))
	print("Loading Loadout Characters Size: " + str(loadoutCharacters.size()))
	print("Loading Loadout Items: " + str(loadoutItems))
	print("Loading Loadout Items Size: " + str(loadoutItems.size()))
	
	# Load Characters
	for i in loadoutCharacters.size():
		print("Character: " + str(loadoutCharacters[i]))
		var realLoadedCharacter := load(loadoutCharacters[i])
		var instance: BaseCharacter = realLoadedCharacter.instantiate()
		gameStartMenu.finalCharacterListArray.push_back(instance)
	
	# Load Items
	for i in loadoutItems.size():
		print("Item: " + str(loadoutItems[i]))
		var itemDict: Dictionary = loadoutItems[i]
		var loadedItem := load(itemDict.ItemFilePath).duplicate()
		gameStartMenu.finalInventorySystem.SetAmountInventory(loadedItem, itemDict.ItemAmount, false)
	
	# Finalize
	gameStartMenu.UpdateCharacterFinalListVisual()
	gameStartMenu.UpdateItemFinalListVisual()
	gameStartMenu.UpdateUpkeepListArray()
	gameStartMenu.CheckIfForCharacters()
	gameStartMenu.UpdateCurrentValue()

# -- Button Pressed 

func SetupOptionItemSelected(index: int) -> void:
	gameStartMenu.clear()
	onIndex = index
	CheckSetupItem(index)


func CheckSetupItem(value: int) -> void:
	if setupOptionButton.item_count <= 0:
		print("-1 selected, disable delete button")
		deleteSetupButton.disabled = true
		saveSetupButton.disabled = true
	else:
		print("Setup is " + str(value))
		deleteSetupButton.disabled = false
		saveSetupButton.disabled = false
		loadSetup()

func NewSetupButtonPressed() -> void:
	var newSavedLoadoutData: Dictionary = Global.loadoutDict.duplicate(true)
	print("new newSavedLoadoutData: " + str(newSavedLoadoutData))
	
	# Save Items
	for i in gameStartMenu.finalInventorySystem.storedItems.size():
		var newSavedItemData: Dictionary = Global.loadoutItemDict.duplicate(true)
		newSavedItemData.ItemFilePath = gameStartMenu.finalInventorySystem.storedItems[i].globalFilePath
		newSavedItemData.ItemAmount = gameStartMenu.finalInventorySystem.storedItems[i].amount
		print("New Item File Path: " + str(newSavedItemData.ItemFilePath))
		print("New Item Amount: " + str(newSavedItemData.ItemAmount))
		newSavedLoadoutData.Items.push_back(newSavedItemData)
	
	
	# Save Characters
	for i in gameStartMenu.finalCharacterListArray.size():
		newSavedLoadoutData.Characters.push_back(gameStartMenu.finalCharacterListArray[i].scene_file_path)
		print("New Characters: " + str(newSavedLoadoutData.Characters))
	
	print("New Loadout: " + str(Global.loadoutsListDict.Loudouts))
	Global.loadoutsListDict.Loudouts.push_back(newSavedLoadoutData)
	LoadAllLoudouts()
	await Global.SaveLoadoutData()
	setupOptionButton.select(setupOptionButton.item_count - 1)
	setupOptionButton.item_selected.emit(setupOptionButton.item_count - 1)

func SaveSetupButtonPressed() -> void:
	var newSavedLoadoutData: Dictionary = Global.loadoutDict.duplicate(true)
	print("Old Loadout: " + str(Global.loadoutsListDict.Loudouts[setupOptionButton.selected]))
	
	# Save Items
	for i in gameStartMenu.finalInventorySystem.storedItems.size():
		var newSavedItemData: Dictionary = Global.loadoutItemDict.duplicate(true)
		newSavedItemData.ItemFilePath = gameStartMenu.finalInventorySystem.storedItems[i].globalFilePath
		newSavedItemData.ItemAmount = gameStartMenu.finalInventorySystem.storedItems[i].amount
		print("Save Item File Path: " + str(newSavedItemData.ItemFilePath))
		print("Save Item Amount: " + str(newSavedItemData.ItemAmount))
		newSavedLoadoutData.Items.push_back(newSavedItemData)
	
	# Save Characters
	for i in gameStartMenu.finalCharacterListArray.size():
		newSavedLoadoutData.Characters.push_back(gameStartMenu.finalCharacterListArray[i].scene_file_path)
		print("Save Characters: " + str(newSavedLoadoutData.Characters))
	
	print("Save Loadout: " + str(Global.loadoutsListDict.Loudouts))
	Global.loadoutsListDict.Loudouts[setupOptionButton.selected] = newSavedLoadoutData
	print("New Loadout: " + str(Global.loadoutsListDict.Loudouts[setupOptionButton.selected]))
	LoadAllLoudouts()
	setupOptionButton.select(onIndex)
	await Global.SaveLoadoutData()


func DeleteSetupButtonPressed() -> void:
	gameStartMenu.clear()
	print("Deletion Old Size: " + str(Global.loadoutsListDict.Loudouts.size()))
	Global.loadoutsListDict.Loudouts.remove_at(setupOptionButton.selected)
	print("Deletion New Size: " + str(Global.loadoutsListDict.Loudouts.size()))
#	setupOptionButton.item_selected.emit(-1)
	LoadAllLoudouts()
	await Global.SaveLoadoutData()
	if setupOptionButton.item_count > 0:
		setupOptionButton.select(0)
		setupOptionButton.item_selected.emit(0)
	else:
		setupOptionButton.select(-1)
		deleteSetupButton.disabled = true
		saveSetupButton.disabled = true
