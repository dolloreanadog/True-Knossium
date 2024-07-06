extends LevelShop
class_name TutorialShop

@export var debugUpkeepItem: BaseInventoryItem
@export var debugUpkeepItemAmount: int

@export var debugInventoryItem: BaseInventoryItem
@export var debugInventoryItemAmount: int

func _ready() -> void:
	Global.StartLoadingScreen(false)
	SaveSystem.loadAllData()
	resetMaxSelectionValue()
	
	loadPartyCharacters()
	
	getShopItemFilePaths()
	shopItemFilePathsToItemInstance()
	loadPlayerItems()
	
	upkeepInventory.addToInventory(debugUpkeepItem, debugUpkeepItemAmount)
	playerInventory.addToInventory(debugInventoryItem, debugInventoryItemAmount)
	
	updateUpkeepListVisual()
	updateInventoryListVisual()
	updateShopListVisual()
	randomizeShopPersonality()
	Global.EndLoadingScreen()
	StartShopTimeLeftTimer()

func ExitShop() -> void:
	pass

func tradeItems() -> void: 
	for i in playerBarterInventory.storedItems.size():
		var Litem: BaseInventoryItem = playerBarterInventory.storedItems.pop_back()
		shopInventory.addToInventory(Litem, Litem.amount)
	
	for i in shopBarterInventory.storedItems.size():
		var Litem: BaseInventoryItem = shopBarterInventory.storedItems.pop_back()
		playerInventory.addToInventory(Litem, Litem.amount)
	
	shopBarterValue = GetTotalInventoryValue(shopBarterInventory)
	shopBarterValueLabel.text = "£" + str(snappedf(shopBarterValue, 0.01))
	
	playerBarterValue = setPlayerBarterValue(GetTotalInventoryValue(playerBarterInventory))
	playerBarterValueLabel.text = "£" + str(snappedf(playerBarterValue, 0.01))
	
	updateShopBarterListVisual()
	updatePlayerBarterListVisual()
	updateInventoryListVisual()
	updateShopListVisual()
	UpdateAcceptanceValue()
