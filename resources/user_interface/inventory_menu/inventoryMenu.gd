extends Control
class_name InventoryMenu


@export var inventorySystem: InventorySystem
@export var spawnAreaSupport: BaseSpawnArea
@export var spawnAreaOffensive: BaseSpawnArea

@onready var dungeon: BaseLevel = get_parent()
@onready var itemList: ItemList = $ColorRect/ItemList
@onready var itemPFP: TextureRect = $ColorRect/Panel/ItemPFPHolder
@onready var itemName: Label = $ColorRect/Panel/ItemName
@onready var itemAmount: Label = $ColorRect/Panel/ItemAmount
@onready var itemValue: Label = $ColorRect/Panel/ItemValue
@onready var itemDescription: Label = $ColorRect/Panel/Panel2/ItemDescription
@onready var spawnAOEButton: Button = $ColorRect/SpawnAOEButton
@onready var spawnAllAOEButton: Button = $ColorRect/SpawnAllAOEButton

var targetItem: BaseInventoryItem

func _ready() -> void:
	spawnAOEButton.disabled = true
	spawnAllAOEButton.disabled = true
	itemPFP.texture = ImageTexture.new()
	itemName.text = ""
	itemAmount.text = ""
	itemValue.text = ""
	itemDescription.text = ""


func updateInventoryItemList() -> void:
	itemList.clear()
	for i in inventorySystem.storedItems.size():
		print(inventorySystem.storedItems[i].itemName)
		var LitemName = inventorySystem.storedItems[i].itemName + " x" + str(inventorySystem.storedItems[i].amount) + " £" + str("%.2f" % inventorySystem.storedItems[i].value)
		itemList.add_item(LitemName, inventorySystem.storedItems[i].image)

func Exit() -> void:
	if !(dungeon.isCharactersActive) && (dungeon.specialWindowContainer.get_child_count() == 0) && (dungeon.difficulty.isCharactersSpawningIn != true) && dungeon.knossiumConsole.visible == false:
		dungeon.stopControlVisible(false, 1)
		dungeon.stopControlVisible(false, 2)
	dungeon.inventoryButton.disabled = false
#	dungeon.checkSpecialWindowContainer()
#	get_parent().stopControl.hide()
	self.hide()

func _on_exit_button_pressed() -> void:
	Exit()

func _on_item_list_item_selected(index: int) -> void:
	#if is_instance_valid(inventorySystem.storedItems[index]):
	targetItem = inventorySystem.storedItems[index]
	spawnAOEButton.disabled = true
	spawnAllAOEButton.disabled = true
	updateItemInformation()

func updateItemInformation() -> void:
	if targetItem.isInteractable:
		if targetItem.amount > 0:
			spawnAOEButton.disabled = false
			spawnAllAOEButton.disabled = false
		
	if is_instance_valid(targetItem.image):
		itemPFP.texture = targetItem.image
	
	itemName.text = targetItem.itemName
	itemAmount.text = "x" + str(targetItem.amount)
	itemValue.text = "£" + str("%.2f" % targetItem.value)
	itemDescription.text = targetItem.itemDesciption


func _on_spawn_aoe_button_pressed() -> void:
	var instance: BaseAOE = targetItem.AOE.instantiate()
	
	instance.health = targetItem.AOEHealthGain
	instance.defense = targetItem.AOEDefenseGain
	instance.attack = targetItem.AOEAttackGain
	instance.morale = targetItem.AOEMoraleGain
	instance.experience = targetItem.AOEExpGain
	
	instance.ownerCharacterName = targetItem.itemName
	instance.ownerCharacterPFP = targetItem.image
	instance.ownerActionDescription = targetItem.itemDesciption
	
	inventorySystem.removeFromInventory(targetItem, 1)
	updateInventoryItemList()
	updateItemInformation()
	
	if targetItem.isOffensive:
		spawnAreaOffensive.add_child(instance, true)
		instance.set_global_position(spawnAreaOffensive.randomizeSpawn())
	else:
		spawnAreaSupport.add_child(instance, true)
		instance.set_global_position(spawnAreaSupport.randomizeSpawn())
	
	if targetItem.amount <= 0:
		spawnAOEButton.disabled = true
		spawnAllAOEButton.disabled = true


func SpawnAllAOEButtonPressed() -> void:
	while inventorySystem.getNamedItemAmount(targetItem.itemName) != 0:
		var instance: BaseAOE = targetItem.AOE.instantiate()
		
		instance.health = targetItem.AOEHealthGain
		instance.defense = targetItem.AOEDefenseGain
		instance.attack = targetItem.AOEAttackGain
		instance.morale = targetItem.AOEMoraleGain
		instance.experience = targetItem.AOEExpGain
		
		instance.ownerCharacterName = targetItem.itemName
		instance.ownerCharacterPFP = targetItem.image
		instance.ownerActionDescription = targetItem.itemDesciption
		
		inventorySystem.removeFromInventory(targetItem, 1)
		updateInventoryItemList()
		updateItemInformation()
		
		if targetItem.isOffensive:
			spawnAreaOffensive.add_child(instance, true)
			instance.set_global_position(spawnAreaOffensive.randomizeSpawn())
		else:
			spawnAreaSupport.add_child(instance, true)
			instance.set_global_position(spawnAreaSupport.randomizeSpawn())
		await get_tree().create_timer(0.01).timeout
	
	if targetItem.amount <= 0:
		spawnAOEButton.disabled = true
		spawnAllAOEButton.disabled = true
