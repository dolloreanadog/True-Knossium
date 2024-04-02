extends Control
class_name InventoryMenu

@export var inventorySystem: InventorySystem
@export var spawnArea: BaseSpawnArea

@onready var itemList: ItemList = get_node("ColorRect/ItemList")
@onready var itemPFP: TextureRect = get_node("ColorRect/Panel/ItemPFPHolder")
@onready var itemName: Label = get_node("ColorRect/Panel/ItemName")
@onready var itemAmount: Label = get_node("ColorRect/Panel/ItemAmount")
@onready var itemValue: Label = get_node("ColorRect/Panel/ItemValue")
@onready var itemInteractable: Label = get_node("ColorRect/Panel/Panel/InteractableLabel")
@onready var itemDescription: Label = get_node("ColorRect/Panel/Panel2/ItemDescription")
@onready var spawnAOEButton: Button = get_node("ColorRect/SpawnAOEButton")

var targetItem: BaseInventoryItem

func _ready() -> void:
	spawnAOEButton.disabled = true
	itemInteractable.text = ""
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

func _on_exit_button_pressed() -> void:
	get_parent().stopControl.hide()
	self.hide()

func _on_item_list_item_selected(index: int) -> void:
	#if is_instance_valid(inventorySystem.storedItems[index]):
	targetItem = inventorySystem.storedItems[index]
	spawnAOEButton.disabled = true
	updateItemInformation()

func updateItemInformation() -> void:
	
	if targetItem.isInteractable:
		if targetItem.amount > 0:
			spawnAOEButton.disabled = false
			itemInteractable.text = "Yes"
	else:
		itemInteractable.text = "No"
		
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
	
	
	spawnArea.add_child(instance, true)
	instance.set_global_position(spawnArea.randomizeSpawn())
	
	if targetItem.amount <= 0:
		spawnAOEButton.disabled = true
