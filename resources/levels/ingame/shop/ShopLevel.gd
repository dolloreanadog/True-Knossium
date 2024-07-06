extends Node2D
class_name LevelShop
# Notes:
# For Upkeep List Look at PartyMenu.gd
# For the rest either look in InventoryMenu.gd or NewGameStartMenu.gd

# 1 TODO : Shop List
# 2 TODO : Shop Barter List
# 3 TODO : Player Inventory List
# 4 TODO : Player Barter List
# 5 TODO : upkeep

# Important nodes
@export var stopControl: Control
@export var playerInventory: InventorySystem
@export var playerBarterInventory: InventorySystem
@export var upkeepInventory: InventorySystem
@export var shopInventory: InventorySystem
@export var shopBarterInventory: InventorySystem
@export var confirmButton: Button

# Directories
var dirItems := DirAccess.open("res://resources/entities/inventory_items/dev_items")
var extension := "tscn"

# List Arrays
var shopItemFilePaths: Array

# List Objects
@export var upkeepList: ItemList
@export var inventoryList: ItemList
@export var shopList: ItemList
@export var playerBarterList: ItemList
@export var shopBarterList: ItemList

# Label Objects
@export var playerBarterValueLabel: Label
@export var shopBarterValueLabel: Label
@export var acceptanceValueLabel: Label

@export var itemDescriptionLabel: Label
@export var shopPersonalityLabel: Label
@export var strikesLabel: Label
@export var buttonCooldownTime: float
@export var buttonCooldownLabel: Label
@export var shopLeftTime: float = 60
@export var isTimeLocked: bool = false
@export var shopTimeLeftLabel: Label
# Amount Selector
@export var amountSelectorLabel: Label
@export var amountSelector: ColorRect
@export var amountSlider: HSlider
@export var amountSpinbox: SpinBox

# Amount Selector Variables
var selectorBarterChangerTo: bool # false = playerBarterValue : true = shopBarterValue
var selectorRemover: bool
var selectorItem: BaseInventoryItem
var selectorInitialItemAmount: int
var selectorTargetInitialItemAmount: int
var selectorInitialInventory: InventorySystem
var selectorTotalAmount: int

var selectorInventory: InventorySystem

# Shop Personality
enum shopPersonality {NAIVE, INEXPERIENCED, NEUTRAL, SMART, GREEDY}
var personality: shopPersonality
## 0 - 36, check randomizePersonality to see what value activate what
@export_range(0, 36) var personalityValue: int
@export var isDebugPersonality: bool
var merchantPFP: TextureRect

# When failing a trade raise a strike, if it's max, boot off shop
var strikes: int
var maxStrikes: int = 10

# Bartering Values
var barterActionAvailable: bool = true
var initialValue: float

var playerTotalValue: float
var playerBarterValue: float
var shopBarterValue: float
var acceptanceValue: float
var minimumAcceptanceValue: float
var guaranteedAcceptanceValue: float


# Choose a personality on a chance system similar to DifficultySystem
func _ready() -> void:
	Global.StartLoadingScreen(false)
	SaveSystem.loadAllData()
	resetMaxSelectionValue()
	
	loadPartyCharacters()
	
	getShopItemFilePaths()
	shopItemFilePathsToItemInstance()
	loadPlayerItems()
	
	updateUpkeepListVisual()
	updateInventoryListVisual()
	updateShopListVisual()
	randomizeShopPersonality()
	Global.EndLoadingScreen()
	StartShopTimeLeftTimer()

func EndShoppingPressed() -> void:
	ExitShop()

func ExitShop() -> void:
	Global.StartLoadingScreen(true)
	var dungeon: PackedScene = load("res://resources/levels/ingame/dungeon/Dungeon.tscn")
	stopControl.show()
	print("(check) exiting shop")
	# If in amount selector confirm & exit
	if amountSelector.visible == true:
		amountSelector.hide()
		
		# Place This Accordingly
		var Litem: BaseInventoryItem = selectorItem.duplicate(true)
		@warning_ignore("narrowing_conversion")
		Litem.amount = amountSlider.value
		
		print("-------")
		
		print(str(selectorInventory.storedItems))
		selectorInitialInventory.removeAllItemsAtZero()
		selectorInventory.removeAllItemsAtZero()

	
	# Move everything from barter to
	for i in playerBarterInventory.storedItems.size():
		var Litem: BaseInventoryItem = playerBarterInventory.storedItems.pop_back()
		
		playerInventory.addToInventory(Litem, Litem.amount)
		playerBarterInventory.removeFromInventory(Litem, Litem.amount)
	
	Global.newGameInventoryInfo = playerInventory.storedItems
	
#	for i in playerInventory.storedItems.size():
#		var newSavedItemData: Dictionary = SaveSystem.ItemInfoDict.duplicate(true)
#		newSavedItemData.ItemPathName = playerInventory.storedItems[i].get_path()
#		newSavedItemData.ItemAmount = playerInventory.storedItems[i].amount
#		SaveSystem.GameInfoDict.Inventory.push_back(newSavedItemData)
	
	updateInventoryListVisual()
	updatePlayerBarterListVisual()
	updateShopBarterListVisual()
	resetMaxSelectionValue()
	
	get_tree().change_scene_to_packed(dungeon)



#--[ Shopkeeper AI]--
func setPlayerBarterValue(amount: float) -> float:
	var playerCurrentBarterValue: float = 0
	match personality:
		shopPersonality.NAIVE:
			playerCurrentBarterValue = amount * 2
		shopPersonality.INEXPERIENCED:
			playerCurrentBarterValue = amount * 1.5
		shopPersonality.NEUTRAL:
			playerCurrentBarterValue = amount
		shopPersonality.SMART:
			playerCurrentBarterValue = amount * 0.75
		shopPersonality.GREEDY:
			playerCurrentBarterValue = amount * 0.5
			
	return playerCurrentBarterValue

func randomizeShopPersonality() -> void:
	var value: int = randi_range(0, 36)
	
	if isDebugPersonality:
		value = personalityValue
	
	if value <= 1: # 2
		personality = shopPersonality.NAIVE
		minimumAcceptanceValue = randf_range(-10, -20)
		if !isTimeLocked:
			shopLeftTime = 25
#		guaranteedAcceptanceValue = 0
		shopPersonalityLabel.text = "Personality: Naive"
		maxStrikes = 10
		strikesLabel.text = "Strikes: " + str(strikes) + "/" + str(maxStrikes)
	elif value >= 2 && value <= 4: # 3
		personality = shopPersonality.INEXPERIENCED
		minimumAcceptanceValue = randf_range(0, -10)
		if !isTimeLocked:
			shopLeftTime = 45
#		guaranteedAcceptanceValue = 100
		shopPersonalityLabel.text = "Personality: Inexperienced"
		maxStrikes = 8
		strikesLabel.text = "Strikes: " + str(strikes) + "/" + str(maxStrikes)
	elif value >= 5 && value <= 26: # 22
		personality = shopPersonality.NEUTRAL
		minimumAcceptanceValue = randf_range(5, -5)
		if !isTimeLocked:
			shopLeftTime = 120
#		guaranteedAcceptanceValue = 175
		shopPersonalityLabel.text = "Personality: Neutral"
		maxStrikes = 6
		strikesLabel.text = "Strikes: " + str(strikes) + "/" + str(maxStrikes)
	elif value >= 27 && value <= 32: # 6
		personality = shopPersonality.SMART
		minimumAcceptanceValue = randf_range(10, 0)
		if !isTimeLocked:
			shopLeftTime = 180
#		guaranteedAcceptanceValue = 185
		shopPersonalityLabel.text = "Personality: Smart"
		maxStrikes = 4
		strikesLabel.text = "Strikes: " + str(strikes) + "/" + str(maxStrikes)
	elif value >= 33 && value <= 36: # 4
		personality = shopPersonality.GREEDY
		minimumAcceptanceValue = randf_range(20, 0)
		if !isTimeLocked:
			shopLeftTime = 180
#		guaranteedAcceptanceValue = 95
		shopPersonalityLabel.text = "Personality: Greedy"
		maxStrikes = 3
		strikesLabel.text = "Strikes: " + str(strikes) + "/" + str(maxStrikes)
	print("minimum acceptance value " + str(minimumAcceptanceValue))
	print("guaranteed acceptance value " + str(guaranteedAcceptanceValue))

func setShopBarterValue(amount: float) -> void:
	shopBarterValue = amount
	

func StartShopTimeLeftTimer() -> void:
	var time: float = shopLeftTime
	
	while time > 0:
		await get_tree().create_timer(1).timeout
		time -= 1
		shopTimeLeftLabel.text = str(snappedf(time, 1)) + " seconds left"
	shopTimeLeftLabel.text = ""
	barterActionAvailable = false
#	ExitShop()

# Updates the label visually
func UpdateAcceptanceValue() -> void:
	print("playerBarterValue = " + str(playerBarterValue))
	acceptanceValue = playerBarterValue - shopBarterValue
	match personality:
		shopPersonality.NAIVE:
			guaranteedAcceptanceValue = shopBarterValue * 0.45
		shopPersonality.INEXPERIENCED:
			guaranteedAcceptanceValue = shopBarterValue * 0.7
		shopPersonality.NEUTRAL:
			guaranteedAcceptanceValue = shopBarterValue * 1
		shopPersonality.SMART:
			guaranteedAcceptanceValue = shopBarterValue * 1.05
		shopPersonality.GREEDY:
			guaranteedAcceptanceValue = shopBarterValue * 1.15
		_:
			push_error("Not a valid shop personality.")
	
#	var value: float = snappedf(((acceptanceValue / (100 + absf(minimumAcceptanceValue)))) * 100, 0.01)
	var value: float
	var Rcoloration
	var Gcoloration
	if guaranteedAcceptanceValue > minimumAcceptanceValue:
		value = remap(acceptanceValue, minimumAcceptanceValue, guaranteedAcceptanceValue, 0, 1)
		Rcoloration = remap(acceptanceValue, minimumAcceptanceValue, guaranteedAcceptanceValue, 1, 0)
		Gcoloration = remap(acceptanceValue, minimumAcceptanceValue, guaranteedAcceptanceValue, 0, 1)
	else:
		value = remap(acceptanceValue, guaranteedAcceptanceValue, minimumAcceptanceValue, 0, 1)
		Rcoloration = remap(acceptanceValue, guaranteedAcceptanceValue, minimumAcceptanceValue, 1, 0)
		Gcoloration = remap(acceptanceValue, guaranteedAcceptanceValue, minimumAcceptanceValue, 0, 1)
	acceptanceValueLabel.text = str(snappedf(value * 100, 0.01)) + "%"
	
	
#	var OGcoloration = 1
#	var Rcoloration = OGcoloration - value
#	var Gcoloration = value
	

#	var Rcoloration = remap(value, minimumAcceptanceValue, guaranteedAcceptanceValue, 1, 0)
#	var Gcoloration = remap(value, minimumAcceptanceValue, guaranteedAcceptanceValue, 0, 1)
	
	print("acceptanceValue = " + str(acceptanceValue))
	print("(check) value " + str(value))
	print("(check) GColoration " + str(Gcoloration))
	print("(check) Rcoloration " + str(Rcoloration))
	print("(check) Total " + str(Rcoloration + Gcoloration))
	acceptanceValueLabel.modulate = Color(clampf(Rcoloration, 0, 1), clampf(Gcoloration, 0, 1), 0)
#	acceptanceValueLabel.modulate = Color(clampf(Rcoloration * 0.01, 0, 1), clampf(Gcoloration * 0.01, 0, 1), 0)
#	acceptanceValueLabel.modulate = Color(clampf(Rcoloration * 2.55, 0, 255), clampf(Gcoloration * 2.55, 0, 255), 0)
	
#	if acceptanceValue > 0:
#		acceptanceValueLabel.set_modulate(Color(0, 1, 0))
#	elif acceptanceValue == 0:
#		acceptanceValueLabel.set_modulate(Color(1, 1, 1))
#	elif acceptanceValue < 0:
#		acceptanceValueLabel.set_modulate(Color(1, 0, 0))

func ConfirmTradeButton() -> void:
	if !(barterActionAvailable):
		confirmButton.disabled = true
		await get_tree().create_timer(1).timeout
		ExitShop()
	checkForAcceptance()

func tradeItems() -> void: 
#	for i in playerBarterInventory.storedItems.size():
#		playerBarterInventory.storedItems.pop_back()
	
	for i in shopBarterInventory.storedItems.size():
		var Litem: BaseInventoryItem = shopBarterInventory.storedItems.pop_back()
		Global.unlockItem(Litem.globalFilePath)
		playerInventory.addToInventory(Litem, Litem.amount)
	
	for i in playerBarterInventory.storedItems.size():
		var Litem: BaseInventoryItem = playerBarterInventory.storedItems.pop_back()
		shopInventory.addToInventory(Litem, Litem.amount)
	
	shopBarterValue = GetTotalInventoryValue(shopBarterInventory)
	shopBarterValueLabel.text = "£" + str(snappedf(shopBarterValue, 0.01))
	
	playerBarterValue = setPlayerBarterValue(GetTotalInventoryValue(playerBarterInventory))
	playerBarterValueLabel.text = "£" + str(snappedf(playerBarterValue, 0.01))
	
	updateShopBarterListVisual()
	updatePlayerBarterListVisual()
	updateInventoryListVisual()
	updateShopListVisual()
	UpdateAcceptanceValue()

func checkForAcceptance() -> void:
	var value: float = randf_range(acceptanceValue, playerBarterValue)
	
	match personality:
		shopPersonality.NAIVE:
			if value >= guaranteedAcceptanceValue && acceptanceValue >= minimumAcceptanceValue:
				print("Merchant liked that deal! " + str(value))
				tradeItems()
			else:
				print("Merchant didn't like that deal! " + str(value))
				raiseStrike()
		shopPersonality.INEXPERIENCED:
			if value >= guaranteedAcceptanceValue && acceptanceValue >= minimumAcceptanceValue:
				print("Merchant liked that deal! " + str(value))
				tradeItems()
			else:
				print("Merchant didn't like that deal! " + str(value))
				raiseStrike()
		shopPersonality.NEUTRAL:
			if value >= guaranteedAcceptanceValue && acceptanceValue >= minimumAcceptanceValue:
				print("(check1) Merchant liked that deal! " + str(value))
				print("(check1) Needs to pass: " + str(guaranteedAcceptanceValue))
				print("(check1) Current Acceptance Value: " + str(acceptanceValue))
				print("(check1) Current Max Rand (playerBarterValue) Value: " + str(acceptanceValue))
				tradeItems()
			else:
				print("(check1) Merchant didn't like that deal! " + str(value))
				print("(check1) Needs to pass: " + str(guaranteedAcceptanceValue))
				print("(check1) Current Acceptance Value: " + str(acceptanceValue))
				print("(check1) Current Max Rand (playerBarterValue) Value: " + str(acceptanceValue))
				raiseStrike()
		shopPersonality.SMART:
			if value >= guaranteedAcceptanceValue && acceptanceValue >= minimumAcceptanceValue:
				print("Merchant liked that deal! " + str(value))
				tradeItems()
			else:
				print("Merchant didn't like that deal! " + str(value))
				raiseStrike()
		shopPersonality.GREEDY:
			if value >= guaranteedAcceptanceValue && acceptanceValue >= minimumAcceptanceValue:
				print("Merchant liked that deal! " + str(value))
				tradeItems()
			else:
				print("Merchant didn't like that deal! " + str(value))
				raiseStrike()

func raiseStrike() -> void:
	strikes += 1
	strikesLabel.text = "Strikes: " + str(strikes) + "/" + str(maxStrikes)
	buttonCooldown()
	if strikes >= maxStrikes:
		ExitShop()

func buttonCooldown() -> void:
	# How much time cooldown is.
	var time: float = buttonCooldownTime
	
	confirmButton.disabled = true
	while time > 0:
		await get_tree().create_timer(0.01).timeout
		time -= 0.01
		buttonCooldownLabel.text = str(snappedf(time, 0.01)) + " seconds left"
	buttonCooldownLabel.text = ""
	if barterActionAvailable:
		confirmButton.disabled = false
	else:
		ExitShop()


#-- [ Lists ] --

#--- Inventory
# visualize player inventory into list
#	Make sure to display current value
#
#
# load player inventory
#	It's in the Dungeon.gd
func loadPlayerItems() -> void:
	var savedInventory: Array = SaveSystem.GameInfoDict.Inventory
	
	for i in savedInventory.size():
		var targetItemInfo: Dictionary = savedInventory.pop_back()
		var loadedItem := load(targetItemInfo.ItemPathName)
		#var instanceItem: BaseInventoryItem = instance_from_id(targetItemInfo.ItemPathName.object_id)
		print(targetItemInfo)
		if loadedItem != null:
			playerInventory.addToInventory(loadedItem.duplicate(true), targetItemInfo.ItemAmount)
		else:
			print("Loaded Item is null")

func updateInventoryListVisual() -> void:
	inventoryList.clear()
	for i in playerInventory.storedItems.size():
		var Litem: BaseInventoryItem = playerInventory.storedItems[i]
		inventoryList.add_item(Litem.itemName + "  x" + str(Litem.amount) + " £" + str(snappedf(Litem.value, 0.01)), Litem.image)
		inventoryList.set_item_tooltip(i, Litem.itemDesciption)
#---

#--- Upkeep
# visualize upkeep into list
#
# load player party from save script
#	Look into Party Menu or NewGameStart (<-- Might Go for this) to do most of the work
# Do we have to load all characters?
func loadPartyCharacters() -> void:
	var savedCharacters: Array = SaveSystem.GameInfoDict.FriendlyCharactersList
	var targetCharacterInstance: BaseCharacter
	
	
	for i in savedCharacters.size():
		var targetCharacterInfo: Dictionary = savedCharacters.pop_back()
		var loadedCharacter := load(targetCharacterInfo.CharacterFilePath)
		
		targetCharacterInstance = loadedCharacter.instantiate()
		
		upkeepInventory.addToInventory(targetCharacterInstance.ResourceNeeded, targetCharacterInstance.ResourceNeededNumber)
	
func updateUpkeepListVisual() -> void:
	upkeepList.clear()
	for i in upkeepInventory.storedItems.size():
		var Litem: BaseInventoryItem = upkeepInventory.storedItems[i]
		upkeepList.add_item(Litem.itemName + "  x" + str(Litem.amount) + " £" + str(snappedf(Litem.value, 0.01)), Litem.image)
		upkeepList.set_item_tooltip(i, Litem.itemDesciption)
#---

#--- Shop List
# Visualize shop list
#
# Select some random items, but guarantee items in upkeep list
func shopItemFilePathsToItemInstance() -> void:
	var temporaryShopArray: Array = []
	
	# Load all items here
	for i in shopItemFilePaths.size():
		var realLoadedItem = load(shopItemFilePaths[i])
		temporaryShopArray.push_back(realLoadedItem)
	
	# Decide whether to add it to the actual shop list here
	# Make it look at the upkeep. (Currently it doesn't)
	for i in temporaryShopArray.size():
		var shopItem: BaseInventoryItem = temporaryShopArray[i].duplicate(true)
		shopItem.amount = randi_range(10, 5000)
		
		for index in upkeepInventory.storedItems.size():
			if shopItem.itemName == upkeepInventory.storedItems[index].itemName:
				shopInventory.storedItems.push_back(shopItem)
			break
		if randi_range(0, 1) == 0 && !(shopInventory.storedItems.has(shopItem)):
			shopInventory.storedItems.push_back(shopItem)
		else:
			print(str(shopItem.itemName) + " was not added!")

# load all items
#	Use getCharacterFilePaths() as reference in DifficultySystem
func updateShopListVisual() -> void:
	shopList.clear()
	for i in shopInventory.storedItems.size():
		var Litem: BaseInventoryItem = shopInventory.storedItems[i]
		shopList.add_item(Litem.itemName + "  x" + str(Litem.amount) + " £" + str(snappedf(Litem.value, 0.01)), Litem.image)
		shopList.set_item_tooltip(i, Litem.itemDesciption)
#
#---

#--- Player Barter List
#
# visualize Array into List
#	Also total all the value of the items when going through the Array
func updatePlayerBarterListVisual() -> void:
	print("Updating Player Barter List Visual")
	playerBarterList.clear()
	for i in playerBarterInventory.storedItems.size():
		var Litem: BaseInventoryItem = playerBarterInventory.storedItems[i]
		playerBarterList.add_item(Litem.itemName + "  x" + str(Litem.amount) + " £" + str(snappedf(Litem.value, 0.01)), Litem.image)
		playerBarterList.set_item_tooltip(i, Litem.itemDesciption)
#
#---

#--- Shop Barter List
#
# visualize Array into List
#	Also total all the value of the items when going through the Array
func updateShopBarterListVisual() -> void:
	shopBarterList.clear()
	for i in shopBarterInventory.storedItems.size():
		var Litem: BaseInventoryItem = shopBarterInventory.storedItems[i]
		print(str(Litem.itemName) + str(Litem.amount))
		shopBarterList.add_item(Litem.itemName + "  x" + str(Litem.amount) + " £" + str(snappedf(Litem.value, 0.01)), Litem.image)
		shopBarterList.set_item_tooltip(i, Litem.itemDesciption)

#
#---

#--- Item Select

# This will just show a description
func UpkeepListItemSelected(index: int) -> void:
	itemDescriptionLabel.text = upkeepInventory.storedItems[index].itemDesciption

func InventoryListItemSelected(index: int) -> void:
	OpenAmountSelector(playerInventory.storedItems[index], playerInventory, playerBarterInventory, true)

# Should we go for more of a bartering, where player pick & choose what they want (stellaris trade agreement or civ thing)

func ShopListItemSelected(index: int) -> void:
	OpenAmountSelector(shopInventory.storedItems[index], shopInventory, shopBarterInventory, true)

# pop open amount selector
func PlayerBarterListItemSelected(index: int) -> void:
	OpenAmountSelector(playerBarterInventory.storedItems[index], playerBarterInventory, playerInventory, false)

# pop open amount selector
func ShopBarterListItemSelected(index: int) -> void:
	OpenAmountSelector(shopBarterInventory.storedItems[index], shopBarterInventory, shopInventory, false)

#---

# --[ Amount Selection ]--

func OpenAmountSelector(selectedItem: BaseInventoryItem, initialInventory: InventorySystem, selectedInventoryDestination: InventorySystem, isChangingValue: bool):
	amountSelector.show()
	stopControl.show()
	selectorItem = selectedItem.duplicate(true)
	selectorInitialInventory = initialInventory
	selectorInventory = selectedInventoryDestination
	selectorInitialItemAmount = initialInventory.getNamedItemAmount(selectorItem.itemName)
	selectorTargetInitialItemAmount = selectedInventoryDestination.getNamedItemAmount(selectorItem.itemName)
	selectorBarterChangerTo = isChangingValue
	amountSelectorLabel.text = selectorItem.itemName
	itemDescriptionLabel.text = selectorItem.itemDesciption
	# Make sure value is updated
	
	setMaxSelectionValueOnItemAmount(selectorItem)
	#amountSlider.max_value

	
	if selectorBarterChangerTo:
		amountSlider.set_value_no_signal(0)
		amountSpinbox.set_value_no_signal(0)
		print("(check) selectorItem: " + str(selectorItem.itemName))
		@warning_ignore("narrowing_conversion")
		selectorInitialInventory.SetAmountInventory(selectorItem, selectorInitialItemAmount - amountSlider.value, false)
		@warning_ignore("narrowing_conversion")
		selectorInventory.SetAmountInventory(selectorItem, selectorTargetInitialItemAmount + amountSlider.value, false)
	else:
		amountSlider.set_value_no_signal(amountSlider.max_value)
		amountSpinbox.set_value_no_signal(amountSlider.max_value)
		print("(check) selectorItem: " + str(selectorItem.itemName))
		@warning_ignore("narrowing_conversion")
		selectorInitialInventory.SetAmountInventory(selectorItem, selectorInitialItemAmount - (selectorInitialItemAmount - amountSlider.value), false)
		@warning_ignore("narrowing_conversion")
		selectorInventory.SetAmountInventory(selectorItem, selectorTargetInitialItemAmount + (selectorInitialItemAmount - amountSlider.value), false)
	
	
	# Display Information
	shopBarterValue = GetTotalInventoryValue(shopBarterInventory)
	shopBarterValueLabel.text = "£" + str(snappedf(shopBarterValue, 0.01))
	playerBarterValue = setPlayerBarterValue(GetTotalInventoryValue(playerBarterInventory))
	playerBarterValueLabel.text = "£" + str(snappedf(playerBarterValue, 0.01))
	
	updateInventoryListVisual()
	updatePlayerBarterListVisual()
	updateShopListVisual()
	updateShopBarterListVisual()
	UpdateAcceptanceValue()

func OnAmountSliderValueChanged(value: float) -> void:
	amountSpinbox.value = value
	
	if selectorBarterChangerTo:
		@warning_ignore("narrowing_conversion")
		selectorInitialInventory.SetAmountInventory(selectorItem, selectorInitialItemAmount - amountSlider.value, false)
		@warning_ignore("narrowing_conversion")
		selectorInventory.SetAmountInventory(selectorItem, selectorTargetInitialItemAmount + amountSlider.value, false)
	else:
		print("(check) selectorItem: " + str(selectorItem.itemName))
		@warning_ignore("narrowing_conversion")
		selectorInitialInventory.SetAmountInventory(selectorItem, selectorInitialItemAmount - (selectorInitialItemAmount - amountSlider.value), false)
		@warning_ignore("narrowing_conversion")
		selectorInventory.SetAmountInventory(selectorItem, selectorTargetInitialItemAmount + (selectorInitialItemAmount - amountSlider.value), false)
	
	# Display Information
	playerBarterValue = setPlayerBarterValue(GetTotalInventoryValue(playerBarterInventory))
	playerBarterValueLabel.text = "£" + str(snappedf(playerBarterValue, 0.01))
	shopBarterValue = GetTotalInventoryValue(shopBarterInventory)
	shopBarterValueLabel.text = "£" + str(snappedf(shopBarterValue, 0.01))
	
	updateInventoryListVisual()
	updatePlayerBarterListVisual()
	updateShopListVisual()
	updateShopBarterListVisual()
	UpdateAcceptanceValue()

func OnAmountSpinboxValueChanged(value: float) -> void:
	amountSlider.value = value

func OnAmountConfirmedButtonPressed() -> void:
	amountSelector.hide()
	stopControl.hide()
	
	# Place This Accordingly
	var Litem: BaseInventoryItem = selectorItem.duplicate(true)
	@warning_ignore("narrowing_conversion")
	Litem.amount = amountSlider.value
	
	print("-------")
	
	print(str(selectorInventory.storedItems))
	selectorInitialInventory.removeAllItemsAtZero()
	selectorInventory.removeAllItemsAtZero()
	updateInventoryListVisual()
	updateShopListVisual()
	updatePlayerBarterListVisual()
	updateShopBarterListVisual()
#	resetMaxSelectionValue()

func OnAmountCancelButtonPressed() -> void:
	amountSelector.hide()
	stopControl.hide()
	
#	var Litem: BaseInventoryItem = selectorItem.duplicate(true)
	selectorInitialInventory.SetAmountInventory(selectorItem, selectorInitialItemAmount, true)
	selectorInventory.SetAmountInventory(selectorItem, selectorTargetInitialItemAmount, true)
	
	updateInventoryListVisual()
	updateShopListVisual()
	updatePlayerBarterListVisual()
	updateShopBarterListVisual()

func setMaxSelectionValueOnItemAmount(item: BaseInventoryItem) -> void:
	var amount: int = item.amount
	print("amount is " + str(amount))
	amountSlider.max_value = amount
	amountSpinbox.max_value = amount

func resetMaxSelectionValue() -> void:
	print("Max Selection Value Previous " + str(playerBarterValue)) # Yes it is
	amountSlider.max_value = 999
	amountSpinbox.max_value = 999
	print("Max Selection Value After " + str(playerBarterValue)) # Yes it is

# --[ Extra ]--

## Grabs the total value of a specified inventory
func GetTotalInventoryValue(inventory: InventorySystem) -> float:
	print("Getting Total Inventory Value")
	var value: float = 0
	print("storedItem size: " + str(inventory.storedItems.size()))
	for i in inventory.storedItems.size():
		value += inventory.storedItems[i].amount * inventory.storedItems[i].value 
	print("Total Inventory Value = " + str(value))
	return value

func UpdatePlayerTotalValue() -> void:
	pass

## Gets all related files
func getShopItemFilePaths() -> void:
	if dirItems: # The variable above
		dirItems.list_dir_begin()
		var file_name = dirItems.get_next()
		while file_name != "":
			if dirItems.current_is_dir():
				print(dirItems.get_current_dir() + "/" + file_name)
			else:
				var itemPath = dirItems.get_current_dir() + "/" + file_name
				print(str(self) + str(itemPath))
				shopItemFilePaths.push_back(itemPath)
			file_name = dirItems.get_next()
	else:
		push_error("An error occurred when trying to access the path.")
	
