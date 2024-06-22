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
