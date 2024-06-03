extends Node
class_name InventorySystem

## Should only contain BaseInventoryItem
var storedItems: Array

## Returns what items there are in the inventory
func getStoredItems() -> Array:
	return storedItems

## Returns how the amount of the item named
func getNamedItemAmount(itemName: String) -> int:
	for i in storedItems.size():
		if storedItems[i].itemName == itemName:
			return storedItems[i].amount
	return 0

func getIndexedItemAmount(index: int) -> int:
	return storedItems[index].amount

## Adds an amount of item into the player's inventory
func addToInventory(item: BaseInventoryItem, amount: int) -> void:
	# Replicate this entire thing in other functions
	var Litem: BaseInventoryItem
	
	for i in storedItems.size():
		print("item name: " + str(item.itemName))
		print("Stored item name: " + str(storedItems[i].itemName))
		if storedItems[i].itemName == item.itemName:
			Litem = storedItems[i]
	
	print("LitemIndex = " + str(Litem))
	if is_instance_valid(Litem):
		print("It does exist")
		print("Old Amount: " + str(Litem.amount))
		Litem.amount += amount
		print("New Amount: " + str(Litem.amount))
	else:
		print("doesn't exist yet")
		item.amount = amount
		storedItems.push_back(item)

## Removes an amount of items from the player's inventory
func removeFromInventory(item: BaseInventoryItem, amount: int) -> void:
#	var storedItemsAmount: int = storedItems.size()
	var Litem: BaseInventoryItem
	var LitemIndex: int
	
	for i in storedItems.size(): # Will be tested later.
		print("item name: " + str(item.itemName))
		print("Stored item name: " + str(storedItems[i].itemName))
		if storedItems[i].itemName == item.itemName:
			Litem = storedItems[i]
			LitemIndex = i
	
	if is_instance_valid(Litem):
		print("Old Amount: " + str(Litem.amount))
		Litem.amount -= amount
		print("New Amount: " + str(Litem.amount))
		if Litem.amount <= 0:
			print("Item amount is >= 0, Removing")
			storedItems.remove_at(LitemIndex)
	else:
		print("Item already doesn't exist!")

func SetAmountInventory(item: BaseInventoryItem, amount: int, isRemoveAtZero: bool) -> void:
	var Litem: BaseInventoryItem
	var LitemIndex: int
	
	for i in storedItems.size(): # Will be tested later.
		print("item name: " + str(item.itemName))
		print("Stored item name: " + str(storedItems[i].itemName))
		if storedItems[i].itemName == item.itemName:
			Litem = storedItems[i]
			LitemIndex = i
	
	if is_instance_valid(Litem):
		print("item being set: " + str(Litem.itemName))
		print("Old Amount: " + str(Litem.amount))
		Litem.amount = amount
		print("New Amount: " + str(Litem.amount))
		if isRemoveAtZero:
			if Litem.amount <= 0:
				print("Item amount is >= 0, Removing")
				storedItems.remove_at(LitemIndex)
	else:
		print("Item doesn't exist!")
		item.amount = amount
		storedItems.push_back(item)
	print("-------")
	
func removeAllItemsAtZero() -> void:
	var removedItemsTotal: int = 0
	var itemsToBeRemoved: Array = []
	
	for i in storedItems.size():
		if storedItems[i].amount == 0:
			removedItemsTotal += 1
			itemsToBeRemoved.push_back(storedItems[i])
	
	for i in itemsToBeRemoved.size():
		storedItems.erase(itemsToBeRemoved[i])
		print("storedItems: " + str(storedItems))
		
	print("removed item total: " + str(removedItemsTotal))
