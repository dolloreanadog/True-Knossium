extends Node2D
class_name NewGameStartMenu

# Item Selection Amount
@onready var characterAmountSelectedSpinBox: SpinBox = get_node("CharacterSelection/CharacterAmountWanted")
@onready var itemAmountSelectedSpinBox: SpinBox = get_node("ItemSelection/ItemAmountWanted")

@onready var selectedCharacterNameLabel: Label = get_node("CharacterSelection/SelectedCharacterName")
@onready var selectedItemNameLabel: Label = get_node("ItemSelection/SelectedItemName")

# Character Info Container
@onready var characterNameLabel: Label = get_node("Panel/CharacterNameLabel")
@onready var upkeepLabel: Label = get_node("Panel/UpkeepLabel")


# Lists
@onready var ChooseCharacterList: ItemList = get_node("Lists/ChooseCharacterList")
@onready var ChooseInventoryList: ItemList = get_node("Lists/ChooseInventoryrList")
@onready var FinalCharacterList: ItemList = get_node("Lists/FinalCharacterList")
@onready var FinalInventoryList: ItemList = get_node("Lists/FinalInventoryList")
@onready var FinalUpkeepList: ItemList = get_node("Lists/UpkeepList")

# List containers

var chooseCharacterListArray: Array
var chooseItemListArray: Array
var finalCharacterListArray: Array
var finalItemListArray: Array
var upkeepListArray: Array

# Selection
var targetChooseCharacterSelected: BaseCharacter
var targetChooseItemSelected: BaseInventoryItem
var targetFinalCharacterSelected: BaseCharacter
var targetFinalItemSelected: BaseInventoryItem

# Loading
var dirItem := DirAccess.open("res://resources/entities/inventory_items/dev_items")
var dirDev := DirAccess.open("res://resources/entities/characters_items/character/new_dev_game_characters")
var dirSpecial := DirAccess.open("res://resources/entities/characters_items/character/special_game_characters")
var extension := "tscn"

var filedCharactersArray: Array
var loadedCharactersArray: Array

var filedItemsArray: Array
var loadedItemsArray: Array

# Point Value
@onready var maxValueLabel: Label = get_node("MiddleInfo/MaxValueLabel")
@onready var currentValueLabel: Label = get_node("MiddleInfo/CurrentValueLabel")

## Export for now, but eventually be tuned by Global's player progression
@export var maxValue: float

@export var currentValue: float

#--[ Functions ]--

func _ready() -> void:
	$CharacterSelection/ConfirmCharacterSelectedAmount.disabled = true
	$ItemSelection/ConfirmItemSelectedAmount.disabled = true
	getCharactersFilePaths()
	print(filedCharactersArray)
	characterFilePathsToCharacterInstances()
	itemFilePathsToItemInstance()
	
	maxValue = Global.getBattlesWon() * 100
	
	updateCharacterChooseListArray()
	updateItemChooseListArray()
	
	updateCharacterChooseListVisual()
	updateInventoryChooseListVisual()
	
	targetChooseItemSelected = chooseItemListArray[0]
	targetChooseCharacterSelected = chooseCharacterListArray[0]
	
	ChooseInventoryList.select(0)
	ChooseCharacterList.select(0)
	
	setMaxValueForCharacterSpinbox()
	setMaxValueForItemSpinbox()
	
	updateCurrentValue()
	isOverMaxValue()

#--[ Selected on List ]--

func _on_choose_character_list_item_selected(index: int) -> void:
	if !(ChooseCharacterList.is_item_disabled(index)):
		targetChooseCharacterSelected = chooseCharacterListArray[index]
		
		selectedCharacterNameLabel.text = targetChooseCharacterSelected.id
		
		characterNameLabel.text = targetChooseCharacterSelected.id
		upkeepLabel.text = "Upkeep: " + str(targetChooseCharacterSelected.ResourceNeeded.itemName) + " x" + str(targetChooseCharacterSelected.ResourceNeededNumber)
		
		characterAmountSelectedSpinBox.value = 0
		itemAmountSelectedSpinBox.value = 0
		
		updateCurrentValue()
		setMaxValueForItemSpinbox()
		setMaxValueForCharacterSpinbox()


func _on_choose_inventoryr_list_item_selected(index: int) -> void:
	if !(ChooseInventoryList.is_item_disabled(index)):
		
		targetChooseItemSelected = chooseItemListArray[index]
		
		selectedItemNameLabel.text = targetChooseItemSelected.itemName
		
		characterAmountSelectedSpinBox.value = 0
		itemAmountSelectedSpinBox.value = 0
		
		updateCurrentValue()
		setMaxValueForItemSpinbox()
		setMaxValueForCharacterSpinbox()


func _on_final_character_list_item_selected(index: int) -> void:
	targetFinalCharacterSelected = finalCharacterListArray[index]
	targetFinalCharacterSelected.stats.getTotalStatPoints()
	finalCharacterListArray.remove_at(index)
	updateCharacterFinalListVisual()
	updateUpkeepList()
	
	characterAmountSelectedSpinBox.value = 0
	itemAmountSelectedSpinBox.value = 0
	
	updateCurrentValue()
	setMaxValueForCharacterSpinbox()
	setMaxValueForItemSpinbox()
	isOverMaxValue()


func _on_final_inventory_list_item_selected(index: int) -> void:
	targetFinalItemSelected = finalItemListArray[index]
	
	finalItemListArray.remove_at(index)
	
	updateItemFinalListVisual()
	
	characterAmountSelectedSpinBox.value = 0
	itemAmountSelectedSpinBox.value = 0
	
	updateCurrentValue()
	setMaxValueForItemSpinbox()
	setMaxValueForCharacterSpinbox()
	isOverMaxValue()

#--[ Middle Item Selection ]--

func _on_character_amount_wanted_value_changed(value: float) -> void:
	if is_instance_valid(targetChooseCharacterSelected) && (value != 0):
		$CharacterSelection/ConfirmCharacterSelectedAmount.disabled = false
	else:
		$CharacterSelection/ConfirmCharacterSelectedAmount.disabled = true
		
	updateCurrentValue()

func _on_item_amount_wanted_value_changed(value: float) -> void:
	if is_instance_valid(targetChooseItemSelected) && (value != 0):
		$ItemSelection/ConfirmItemSelectedAmount.disabled = false
	else:
		$ItemSelection/ConfirmItemSelectedAmount.disabled = true
	
	updateCurrentValue()

func _on_confirm_item_selected_amount_pressed() -> void:
	if finalItemListArray.has(targetChooseItemSelected):
		print("does exist")
		for i in finalItemListArray.size():
			if finalItemListArray[i] == targetChooseItemSelected:
				print("Old Amount: " + str(finalItemListArray[i].amount))
				finalItemListArray[i].amount += itemAmountSelectedSpinBox.value
				print("New Amount: " + str(finalItemListArray[i].amount))
				break
	else:
		print("doesn't exist yet")
		@warning_ignore("narrowing_conversion")
		targetChooseItemSelected.amount = itemAmountSelectedSpinBox.value
		finalItemListArray.push_back(targetChooseItemSelected)
	
	characterAmountSelectedSpinBox.value = 0
	itemAmountSelectedSpinBox.value = 0
	currentValue = 0
	
	updateCurrentValue()
	updateItemFinalListVisual()
	setMaxValueForCharacterSpinbox()
	setMaxValueForItemSpinbox()


func _on_confirm_character_selected_amount_pressed() -> void:
	for i in characterAmountSelectedSpinBox.value:
		finalCharacterListArray.push_back(targetChooseCharacterSelected)
		updateCharacterFinalListVisual()
	
	characterAmountSelectedSpinBox.value = 0
	itemAmountSelectedSpinBox.value = 0
	currentValue = 0
	
	updateUpkeepList()
	updateCurrentValue()
	updateCharacterChooseListVisual()
	setMaxValueForCharacterSpinbox()
	setMaxValueForItemSpinbox()

func setMaxValueForCharacterSpinbox() -> void:
	targetChooseCharacterSelected.stats.getTotalStatPoints()
	var LtemporaryValue: float
	characterAmountSelectedSpinBox.max_value = 0
	while (LtemporaryValue + currentValue) <= maxValue:
		characterAmountSelectedSpinBox.max_value += 1
		LtemporaryValue = characterAmountSelectedSpinBox.max_value * targetChooseCharacterSelected.stats.totalStatPoints

func setMaxValueForItemSpinbox() -> void:
	var LtemporaryValue: float
	itemAmountSelectedSpinBox.max_value = 0
	while (LtemporaryValue + currentValue) <= maxValue:
		itemAmountSelectedSpinBox.max_value += 1
		LtemporaryValue = itemAmountSelectedSpinBox.max_value * targetChooseItemSelected.value
		#await get_tree().create_timer(0.001).timeout
		print("spinbox max value: " + str(itemAmountSelectedSpinBox.max_value))
		print(LtemporaryValue)
	print("item max value: " + str(itemAmountSelectedSpinBox.max_value))

# Need Some way to validate


#--[ Middle Stuff ]--

func _on_start_game_button_pressed() -> void:
	var dungeon: PackedScene = load("res://resources/levels/ingame/dungeon/Dungeon.tscn")
	
	for i in finalCharacterListArray.size():
		Global.newGameCharacterInfo.push_back(finalCharacterListArray[i].scene_file_path)
	
	Global.newGameInventoryInfo = finalItemListArray
	
	print("Global Game Items (check2): " + str(Global.newGameInventoryInfo))
	print("Global Game Characters: " + str(Global.newGameCharacterInfo))
	
	for i in finalItemListArray.size():
		print("Item Info name NewInventory (check2): " + str(finalItemListArray[i].itemName))
		print("Item Info amount NewInventory (check2): " + str(finalItemListArray[i].amount))
	
	
	for i in Global.newGameInventoryInfo.size():
		print("Item Info name NewGameStart (check2): " + str(Global.newGameInventoryInfo[i].itemName))
		print("Item Info amount NewGameStart (check2): " + str(Global.newGameInventoryInfo[i].amount))
	
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_packed(dungeon)
	# Add the characters & Items
	
	self.queue_free()


func _on_reset_lists_button_pressed() -> void:
	finalCharacterListArray.clear()
	finalItemListArray.clear()
	
	updateCharacterFinalListVisual()
	updateItemFinalListVisual()
	updateUpkeepList()
	itemAmountSelectedSpinBox.value = 0
	characterAmountSelectedSpinBox.value = 0
	currentValue = 0
	
	
	updateCurrentValue()
	isOverMaxValue()
	print("current Value: " + str(currentValue))


func _on_back_to_menu_button_pressed() -> void:
	Global.newGameCharacterInfo.clear()
	Global.newGameInventoryInfo.clear()
	get_tree().change_scene_to_file("res://resources/levels/MainMenu.tscn")

func updateValueLabels() -> void:
	maxValueLabel.text = str(clampf(snappedf(maxValue, 0.01), 0, 99999))
	currentValueLabel.text = str(clampf(snappedf(currentValue, 0.01), 0, 99999))

func isOverMaxValue() -> void:
	if currentValue >= maxValue:
		for i in chooseCharacterListArray.size():
			ChooseCharacterList.set_item_disabled(i, true)
		for i in chooseItemListArray.size():
			ChooseInventoryList.set_item_disabled(i, true)
	else:
		for i in chooseCharacterListArray.size():
			print("check Character Array" + str(chooseCharacterListArray))
			#ChooseCharacterList.set_item_disabled(i, false)
		for i in chooseItemListArray.size():
			print("check Item Array" + str(chooseItemListArray))
			#ChooseInventoryList.set_item_disabled(i, false)

func checkOverMaxValue() -> bool:
	if currentValue >= maxValue:
		return true
	else: 
		return false
	
#--[ Extra Functions]--

func updateCurrentValue() -> void:
	var finalCharacterListValue: float = 0
	var finalItemListValue: float = 0
	var selectedItemValue: float = 0
	var selectedCharacterValue: float = 0
	
	# final Value
	for i in finalItemListArray.size():
		finalItemListValue += finalItemListArray[i].value * finalItemListArray[i].amount
	
	for i in finalCharacterListArray.size():
		finalCharacterListArray[i].stats.getTotalStatPoints()
		finalCharacterListValue += finalCharacterListArray[i].stats.totalStatPoints
	
	# Selected Value
	selectedItemValue = targetChooseItemSelected.value * itemAmountSelectedSpinBox.value
	
	targetChooseCharacterSelected.stats.getTotalStatPoints()
	selectedCharacterValue = targetChooseCharacterSelected.stats.totalStatPoints * characterAmountSelectedSpinBox.value
	
	# Final
	currentValue = finalCharacterListValue + finalItemListValue + selectedItemValue + selectedCharacterValue
	updateValueLabels()


#-- Update Choose Lists (Visual)

# Update Character Choose List Visual
func updateCharacterChooseListVisual() -> void:
	print("Updating Character Choose List Visual")
	ChooseCharacterList.clear()
	for i in chooseCharacterListArray.size():
		var Lcharacter: BaseCharacter = chooseCharacterListArray[i]
		ChooseCharacterList.add_item(Lcharacter.id, Lcharacter.profilePicture)
		ChooseCharacterList.set_item_tooltip(i, Lcharacter.characterDescription)
		await get_tree().create_timer(0.01).timeout

# Update Item Choose List
func updateInventoryChooseListVisual() -> void:
	ChooseInventoryList.clear()
	for i in chooseItemListArray.size():
		var Litem: BaseInventoryItem = chooseItemListArray[i]
		ChooseInventoryList.add_item(Litem.itemName, Litem.image)
		ChooseInventoryList.set_item_tooltip(i, Litem.itemDesciption)
		
#-- Update Final Lists

# Update Character Final List
func updateCharacterFinalListVisual() -> void:
	FinalCharacterList.clear()
	for i in finalCharacterListArray.size():
		var Lcharacter: BaseCharacter = finalCharacterListArray[i]
		FinalCharacterList.add_item(Lcharacter.id, Lcharacter.profilePicture)
	print(finalCharacterListArray)

# Update Inventory Final List
func updateItemFinalListVisual() -> void:
	FinalInventoryList.clear()
	for i in finalItemListArray.size():
		var Litem: BaseInventoryItem = finalItemListArray[i]
		FinalInventoryList.add_item(Litem.itemName + "  x" + str(Litem.amount), Litem.image)

func updateUpkeepList() -> void:
	print("Updating Upkeep List")
	upkeepListArray.clear()
	FinalUpkeepList.clear()
	
	for i in finalCharacterListArray.size():
		var Litem: BaseInventoryItem = finalCharacterListArray[i].ResourceNeeded.duplicate(true)
		Litem.amount = finalCharacterListArray[i].ResourceNeededNumber
		
		if upkeepListArray.size() != 0:
			for index in upkeepListArray.size():
				print("does exist (check2)")
				if upkeepListArray[index].itemName == Litem.itemName:
					print("Old Amount: " + str(upkeepListArray[index].amount))
					upkeepListArray[index].amount += Litem.amount
					print("New Amount: " + str(upkeepListArray[index].amount))
					break
				else:
					print("doesn't exist yet (check2)")
					Litem.amount = Litem.amount
					upkeepListArray.push_back(Litem)
		else:
			print("count is 0 (check2)")
			Litem.amount = Litem.amount
			upkeepListArray.push_back(Litem)
	
	print("Upkeep List (check2) " + str(upkeepListArray))
	
	for i in upkeepListArray.size():
		var Litem: BaseInventoryItem = upkeepListArray[i]
		FinalUpkeepList.add_item(Litem.itemName + "  x" + str(Litem.amount), Litem.image)
		
#-- Update Choose Lists (System)

# Update Character Choose List
func updateCharacterChooseListArray() -> void:
	for i in loadedCharactersArray.size():
		chooseCharacterListArray.push_back(loadedCharactersArray[i])

func updateItemChooseListArray() -> void:
	for i in loadedItemsArray.size():
		chooseItemListArray.push_back(loadedItemsArray[i])

# Turn all Scene Paths into actual object to get info
func characterFilePathsToCharacterInstances() -> void:
	for i in filedCharactersArray.size():
		var realLoadedCharacter := load(filedCharactersArray[i])
		var instance: BaseCharacter = realLoadedCharacter.instantiate()
		loadedCharactersArray.push_back(instance)

func itemFilePathsToItemInstance() -> void:
	for i in filedItemsArray.size():
		var realLoadedItem = load(filedItemsArray[i])
		loadedItemsArray.push_back(realLoadedItem)

#-- Character Loading

# Eventually We want this to load only unlocked Characters & items, from global
func getCharactersFilePaths() -> void:
#	--[ TEMPLATE ]--
#	This is what it looks like when adding a new character type's folder
#	Look at variable file paths to see what to put
#	Everything in (characterType) <- That's where to replace with type
#
#	if dir(characterType):
#		dir(characterType).list_dir_begin()
#		var file_name = dir(characterType).get_next()
#		while file_name != "":
#			if dir(characterType).current_is_dir():
#				print(dir(characterType).get_current_dir() + "/" + file_name)
#			else:
#				var characterPath = dir(characterType).get_current_dir() + "/" + file_name
#				print(str(self) + str(characterPath))
#				loaded(characterType)CharactersArray.push_back(characterPath)
#			file_name = dir(characterType).get_next()
#	else:
#		push_error("An error occurred when trying to access the path.")
	print("getDictItemsUnlocked: " + str(Global.getDictItemsUnlocked()))
	filedItemsArray = Global.getDictItemsUnlocked()
	filedCharactersArray = Global.getDictCharactersUnlocked()
	
#	if dirItem:
#		dirItem.list_dir_begin()
#		var file_name = dirItem.get_next()
#		while file_name != "":
#			if dirItem.current_is_dir():
#				print(dirItem.get_current_dir() + "/" + file_name)
#			else:
#				var characterPath = dirItem.get_current_dir() + "/" + file_name
#				print(str(self) + str(characterPath))
#				filedItemsArray.push_back(characterPath)
#			file_name = dirItem.get_next()
#	else:
#		push_error("An error occurred when trying to access the path.")
#
#	if dirSpecial: # The variable above
#		dirSpecial.list_dir_begin()
#		var file_name = dirSpecial.get_next()
#		while file_name != "":
#			if dirSpecial.current_is_dir():
#				print(dirSpecial.get_current_dir() + "/" + file_name)
#			else:
#				var characterPath = dirSpecial.get_current_dir() + "/" + file_name
#				print(str(self) + str(characterPath))
#				filedCharactersArray.push_back(characterPath)
#			file_name = dirSpecial.get_next()
#	else:
#		push_error("An error occurred when trying to access the path.")
#
#	if dirDev:
#		dirDev.list_dir_begin()
#		var file_name = dirDev.get_next()
#		while file_name != "":
#			if dirDev.current_is_dir():
#				print(dirDev.get_current_dir() + "/" + file_name)
#			else:
#				var characterPath = dirDev.get_current_dir() + "/" + file_name
#				print(str(self) + str(characterPath))
#				filedCharactersArray.push_back(characterPath)
#			file_name = dirDev.get_next()
#	else:
#		push_error("An error occurred when trying to access the path.")
		
	# When adding any more game type characters, put that function here
