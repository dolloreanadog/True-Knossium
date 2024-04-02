extends Node2D

@onready var inventory: InventorySystem = get_node("InventorySystem")
@onready var inventoryUI: InventoryMenu = get_node("InventoryMenu")

@export var startingItem: BaseInventoryItem
@export var otherStartingItem: BaseInventoryItem

func _ready() -> void:
	inventory.addToInventory(startingItem, 5)
	

func _on_get_inventory_array_pressed() -> void:
	print("Inventory Array: " + str(inventory.storedItems))
	for i in inventory.storedItems.size():
		print("item number: " + str(i) + " --------")
		print("item name: " + str(inventory.storedItems[i].itemName))
		print("item amount: " + str(inventory.storedItems[i].amount))
		


func _on_add_existing_item_to_array_pressed() -> void:
	inventory.addToInventory(startingItem, 5)


func _on_add_new_item_to_array_pressed() -> void:
	inventory.addToInventory(otherStartingItem, 1)


func _on_remove_existing_item_to_array_pressed() -> void:
	inventory.removeFromInventory(startingItem, 2)


func _on_remove_new_item_to_array_pressed() -> void:
	inventory.removeFromInventory(otherStartingItem, 3)


func _on_show_inventory_menu_pressed() -> void:
	inventoryUI.updateInventoryItemList()
	inventoryUI.show()
