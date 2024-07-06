extends Node2D


@export var warningLabel: Label
#---[ Amount Selectors ]---
# Character Amount Selector
@export var characterAmountSelector: ColorRect
@export var characterAmountSelectorLabel: Label
@export var characterAmountSlider: HSlider
@export var characterAmountSpinbox: SpinBox
# It should work where it moves to the final
# Final will have the old system of moving character to the other side

# Item Amount Selector
@export var itemAmountSelector: ColorRect
@export var itemAmountSelectorLabel: Label
@export var itemAmountSlider: HSlider
@export var itemAmountSpinbox: SpinBox
# It works for both sides
# Need Inventory System

# Amount Selector Variables
# Have these 2 depending on what kind of selector
var selectorCharacter: BaseCharacter
var selectorItem: BaseInventoryItem

var selectorRemover: bool
var selectorInitialItemAmount: int
var selectorTargetInitialItemAmount: int
var selectorCurrentValue: float
# This all will be used for items not for character
var selectorIsFinal: bool 
var selectorInitialInventory: InventorySystem
var selectorInventory: InventorySystem

#---[ Item Containers ]---
@onready var chooseCharacterList: ItemList = get_node("Lists/ChooseCharacterList")
@onready var chooseInventoryList: ItemList = get_node("Lists/ChooseInventoryList")
@onready var finalCharacterList: ItemList = get_node("Lists/FinalCharacterList")
@onready var finalInventoryList: ItemList = get_node("Lists/FinalInventoryList")
@onready var finalUpkeepList: ItemList = get_node("Lists/UpkeepList")

@export var choosingInventorySystem: InventorySystem
@export var finalInventorySystem: InventorySystem
@export var upkeepInventorySystem: InventorySystem
var chooseCharacterListArray: Array
var finalCharacterListArray: Array

#---[ Character Info Container ]---
@onready var characterNameLabel: Label = get_node("Panel/CharacterNameLabel")
@onready var upkeepLabel: Label = get_node("Panel/UpkeepLabel")


#---[ File Loading ]---
var filedCharactersArray: Array
var loadedCharactersArray: Array

var filedItemsArray: Array
var loadedItemsArray: Array

#---[ Value ]---
# Visual
@onready var maxValueLabel: Label = get_node("MiddleInfo/MaxValueLabel")
@onready var currentValueLabel: Label = get_node("MiddleInfo/CurrentValueLabel")

# System
@export var maxValue: float = 0
@export var currentValue: float = 0

#---[ Misc. ]---

func _ready() -> void:
	Global.StartLoadingScreen(false)
	GetCharactersFilePaths()
	print(filedCharactersArray)
	CharacterFilePathsToCharacterInstances()
	ItemFilePathsToItemInstance()
	
	UpdateCharacterChooseListArray()
	UpdateItemChooseListArray()
	
	UpdateCharacterChooseListVisual()
	UpdateInventoryChooseListVisual()
	
	CheckIfForCharacters()
	characterNameLabel.text = "nobody"
	upkeepLabel.text = "Upkeep: " + "0" + " x" + "0"
	maxValue = (Global.getBattlesWon() * 25) + 150
	maxValueLabel.text = str(maxValue)
	currentValueLabel.text = str(currentValue)
	
	await get_tree().create_timer(0.5).timeout
	Global.EndLoadingScreen()

func UpdateCurrentValue() -> void:
	
	# Get total stat points in final
	# Get total value in inventory
	# Get total value in the amount selector
	
	currentValue = selectorCurrentValue + GetFinalCharacterListArrayValue() + GetFinalInventoryValue()
	currentValueLabel.text = str(currentValue)

func GetFinalCharacterListArrayValue() -> float:
	var total: float = 0
	
	for i in finalCharacterListArray.size():
		var character: BaseCharacter = finalCharacterListArray[i]
		character.stats.getTotalStatPoints()
		total += character.stats.totalStatPoints
	
	return total

func GetFinalInventoryValue() -> float:
	var total: float = 0
	
	for i in finalInventorySystem.storedItems.size():
		total += finalInventorySystem.storedItems[i].amount * finalInventorySystem.storedItems[i].value
	
	return total


func StartGameButtonPressed() -> void:
	Global.StartLoadingScreen(true)
	var dungeon: PackedScene = load("res://resources/levels/ingame/dungeon/Dungeon.tscn")

	for i in finalCharacterListArray.size():
		Global.newGameCharacterInfo.push_back(finalCharacterListArray[i].scene_file_path)
	
	Global.newGameInventoryInfo = finalInventorySystem.storedItems
	
	print("Global Game Items (check2): " + str(Global.newGameInventoryInfo))
	print("Global Game Characters: " + str(Global.newGameCharacterInfo))
	
	for i in finalInventorySystem.storedItems.size():
		print("Item Info name NewInventory (check2): " + str(finalInventorySystem.storedItems[i].itemName))
		print("Item Info amount NewInventory (check2): " + str(finalInventorySystem.storedItems[i].amount))
	
	
	for i in Global.newGameInventoryInfo.size():
		print("Item Info name NewGameStart (check2): " + str(Global.newGameInventoryInfo[i].itemName))
		print("Item Info amount NewGameStart (check2): " + str(Global.newGameInventoryInfo[i].amount))
	
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_packed(dungeon)
	# Add the characters & Items
	
	self.queue_free()


func ResetListsButtonPressed() -> void:
	finalInventorySystem.storedItems.clear()
	finalCharacterListArray.clear()
	
	UpdateCharacterFinalListVisual()
	UpdateItemFinalListVisual()
	UpdateCurrentValue()


func BackToMenuButtonPressed() -> void:
	Global.StartLoadingScreen(true)
	Global.newGameCharacterInfo.clear()
	Global.newGameInventoryInfo.clear()
	get_tree().change_scene_to_file("res://resources/levels/MainMenu.tscn")

func UpdateCharacterUpkeepLabels(character: BaseCharacter) -> void:
	characterNameLabel.text = character.id
	upkeepLabel.text = "Upkeep: " + str(character.ResourceNeeded.itemName) + " x" + str(character.ResourceNeededNumber)

#--[ Finalize Information For Dungeon ]--


#---[ Load Important Information ]---
#-- Item Loading

func CharacterFilePathsToCharacterInstances() -> void:
	for i in filedCharactersArray.size():
		var realLoadedCharacter := load(filedCharactersArray[i])
		var instance: BaseCharacter = realLoadedCharacter.instantiate()
		loadedCharactersArray.push_back(instance)

func ItemFilePathsToItemInstance() -> void:
	for i in filedItemsArray.size():
		var realLoadedItem = load(filedItemsArray[i])
		loadedItemsArray.push_back(realLoadedItem)

#-- Character Loading
func GetCharactersFilePaths() -> void:
	print("getDictItemsUnlocked: " + str(Global.getDictItemsUnlocked()))
	filedItemsArray = Global.getDictItemsUnlocked()
	filedCharactersArray = Global.getDictCharactersUnlocked()

#---[ Update List Visuals ]---
func UpdateCharacterChooseListVisual() -> void:
	chooseCharacterList.clear()
	for i in chooseCharacterListArray.size():
		var Lcharacter: BaseCharacter = chooseCharacterListArray[i]
		chooseCharacterList.add_item(Lcharacter.id, Lcharacter.profilePicture)
		chooseCharacterList.set_item_tooltip(i, Lcharacter.characterDescription)
		await get_tree().create_timer(0.01).timeout

func UpdateInventoryChooseListVisual() -> void:
	chooseInventoryList.clear()
	for i in choosingInventorySystem.storedItems.size():
		var Litem: BaseInventoryItem = choosingInventorySystem.storedItems[i]
		chooseInventoryList.add_item(Litem.itemName, Litem.image)
		chooseInventoryList.set_item_tooltip(i, Litem.itemDesciption)

func UpdateCharacterFinalListVisual() -> void:
	finalCharacterList.clear()
	for i in finalCharacterListArray.size():
		var Lcharacter: BaseCharacter = finalCharacterListArray[i]
		finalCharacterList.add_item(Lcharacter.id, Lcharacter.profilePicture)
		finalCharacterList.set_item_tooltip(i, Lcharacter.characterDescription)
	print(finalCharacterListArray)

func UpdateItemFinalListVisual() -> void:
	finalInventoryList.clear()
	for i in finalInventorySystem.storedItems.size():
		var Litem: BaseInventoryItem = finalInventorySystem.storedItems[i]
		finalInventoryList.add_item(Litem.itemName + "  x" + str(Litem.amount), Litem.image)
		finalInventoryList.set_item_tooltip(i, Litem.itemDesciption)

func UpdateUpkeepList() -> void:
	finalUpkeepList.clear()
	for i in upkeepInventorySystem.storedItems.size():
		var Litem: BaseInventoryItem = upkeepInventorySystem.storedItems[i]
		finalUpkeepList.add_item(Litem.itemName + "  x" + str(Litem.amount) + " £" + str(snappedf(Litem.value, 0.01)), Litem.image)
		finalUpkeepList.set_item_tooltip(i, Litem.itemDesciption)

#---[ Updated System Info ]---
func UpdateCharacterChooseListArray() -> void:
	for i in loadedCharactersArray.size():
		chooseCharacterListArray.push_back(loadedCharactersArray[i])

func UpdateItemChooseListArray() -> void:
	for i in loadedItemsArray.size():
		choosingInventorySystem.addToInventory(loadedItemsArray[i].duplicate(), 999999)

func CheckIfForCharacters() -> void:
	if finalCharacterListArray.size() == 0:
		warningLabel.text = "There's No Characters!"
		$MiddleInfo/StartGameButton.set_disabled(true)
	else:
		warningLabel.text = ""
		$MiddleInfo/StartGameButton.set_disabled(false)


func UpdateUpkeepListArray() -> void:
	upkeepInventorySystem.storedItems.clear()
	for i in finalCharacterListArray.size():
		var character: BaseCharacter = finalCharacterListArray[i]
		
		upkeepInventorySystem.addToInventory(character.ResourceNeeded, character.ResourceNeededNumber)
	
	UpdateUpkeepList()

#---[ Update Value Labels ]---



#---[ Selecting Item on List ]---
func OnChooseCharacterListItemSelected(index: int) -> void:
	UpdateCharacterUpkeepLabels(chooseCharacterListArray[index])
	OpenCharacterAmountSelector(chooseCharacterListArray[index])


func OnChooseInventoryListItemSelected(index: int) -> void:
	OpenItemAmountSelector(choosingInventorySystem.storedItems[index], finalInventorySystem, false)


func OnFinalCharacterListItemSelected(index: int) -> void:
	UpdateCharacterUpkeepLabels(finalCharacterListArray[index])
	finalCharacterListArray.remove_at(index)
	UpdateUpkeepListArray()
	UpdateCharacterFinalListVisual()
	UpdateCurrentValue()
	CheckIfForCharacters()


func OnFinalInventoryListItemSelected(index: int) -> void:
	OpenItemAmountSelector(finalInventorySystem.storedItems[index], finalInventorySystem, true)

#---[ Amount Selectors ]---
#-- Important Functions
func setMaxSelectorAmountOnMaxValue(isCharacter: bool, character: BaseCharacter = null, item: BaseInventoryItem = null) -> void:
	var value: float = 0
	var amount: int = 0
	
	value = GetFinalCharacterListArrayValue() + GetFinalInventoryValue()
	
	if isCharacter:
		character.stats.getTotalStatPoints()
		while value <= maxValue:
			value += character.stats.totalStatPoints
			amount += 1
		amount -= 1
		characterAmountSlider.max_value = amount
		characterAmountSpinbox.max_value = amount
	else:
		while value <= maxValue:
			value += item.value
			amount += 1
		amount -= 1
		itemAmountSlider.max_value = amount
		itemAmountSpinbox.max_value = amount
	


func setMaxSelectorAmountOnAmount(amount: int) -> void:
	itemAmountSlider.max_value = amount
	itemAmountSpinbox.max_value = amount
	print("Max Value is " + str(amount))

#-- Character Amount Selector
func OpenCharacterAmountSelector(selectedCharacter: BaseCharacter) -> void:
	$StopControl.show()
	characterAmountSelector.show()
	
	selectorCharacter = selectedCharacter
	setMaxSelectorAmountOnMaxValue(true, selectorCharacter)
	


func CharacterAmountSliderValueChanged(value: float) -> void:
	characterAmountSpinbox.value = value
	selectorCurrentValue = 0
	
	for i in value:
		print("Value Changed")
		selectorCharacter.stats.getTotalStatPoints()
		selectorCurrentValue += selectorCharacter.stats.totalStatPoints
	
	UpdateCurrentValue()


func CharacterAmountSpinBoxValueChanged(value: float) -> void:
	characterAmountSlider.value = value


func CharacterAmountSelectorConfirmButtonPressed() -> void:
	$StopControl.hide()
	characterAmountSelector.hide()
	for i in characterAmountSlider.value:
		finalCharacterListArray.push_back(selectorCharacter)
		UpdateCharacterFinalListVisual()
	
	characterAmountSlider.value = 0
	selectorCurrentValue = 0
	UpdateCurrentValue()
	UpdateUpkeepListArray()
	CheckIfForCharacters()

func CharacterAmountSelectorCancelButtonPressed() -> void:
	$StopControl.hide()
	characterAmountSelector.hide()
	
	characterAmountSlider.value = 0
	selectorCurrentValue = 0
	UpdateCurrentValue()
	UpdateUpkeepListArray()
	CheckIfForCharacters()


#-- Item Amount Selector
func OpenItemAmountSelector(selectedItem: BaseInventoryItem, selectedInventory: InventorySystem, isFinal: bool) -> void:
	$StopControl.show()
	itemAmountSelector.show()
	
	selectorItem = selectedItem.duplicate(true)
	print("selector Item: " + str(selectedItem.itemName))
	selectorInventory = selectedInventory
	selectorIsFinal = isFinal
	selectorInitialItemAmount = selectedInventory.getNamedItemAmount(selectorItem.itemName)
	print("selector Initial Item Amount: " + str(selectorInitialItemAmount))
	
	if selectorIsFinal:
		setMaxSelectorAmountOnAmount(selectorInitialItemAmount)
		itemAmountSlider.set_value_no_signal(selectorInitialItemAmount)
		itemAmountSpinbox.set_value_no_signal(selectorInitialItemAmount)
	else:
		setMaxSelectorAmountOnMaxValue(false, null, selectorItem)


func ItemAmountSliderValueChanged(value: float) -> void:
	itemAmountSpinbox.value = value
#	selectorCurrentValue = value
	
	if selectorIsFinal:
		@warning_ignore("narrowing_conversion")
		finalInventorySystem.SetAmountInventory(selectorItem, value, false)
	else:
		@warning_ignore("narrowing_conversion")
		finalInventorySystem.SetAmountInventory(selectorItem, selectorInitialItemAmount + value, false)
	
	
	UpdateItemFinalListVisual()
	UpdateCurrentValue()


func ItemAmountSpinBoxValueChanged(value: float) -> void:
	itemAmountSlider.value = value


func ItemAmountSelectorConfirmButtonPressed() -> void:
	$StopControl.hide()
	itemAmountSelector.hide()
	
	UpdateCharacterFinalListVisual()
	finalInventorySystem.removeAllItemsAtZero()
	itemAmountSlider.set_value_no_signal(0)
	itemAmountSpinbox.set_value_no_signal(0)
	UpdateItemFinalListVisual()
	selectorCurrentValue = 0

func ItemAmountSelectorCancelButtonPressed() -> void:
	$StopControl.hide()
	itemAmountSelector.hide()
	
	if selectorIsFinal:
		itemAmountSlider.value = selectorInitialItemAmount
	
	UpdateCharacterFinalListVisual()
	itemAmountSlider.set_value_no_signal(0)
	itemAmountSpinbox.set_value_no_signal(0)
	finalInventorySystem.removeAllItemsAtZero()
	UpdateItemFinalListVisual()
	selectorCurrentValue = 0
