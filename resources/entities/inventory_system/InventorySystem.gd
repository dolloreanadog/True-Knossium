extends Node
class_name InventorySystem

## Should only contain BaseInventoryItem
var storedItems: Array

## Returns what items there are in the inventory
func getStoredItems() -> Array:
	return storedItems

## Adds an amount of item into the player's inventory
func addToInventory(item: BaseInventoryItem, amount: int) -> void:
	
	var storedItemsAmount: int = storedItems.size()
	
	# If we get an error here, that means Resource Needed is empty
	if storedItems.has(item):
		print("It does exist")
		for i in storedItemsAmount:
			if storedItems[i] == item:
				print("Old Amount: " + str(storedItems[i].amount))
				storedItems[i].amount += amount
				print("New Amount: " + str(storedItems[i].amount))
				break
	else:
		print("doesn't exist yet")
		item.amount = amount
		storedItems.push_back(item)
		

## Removes an amount of items from the player's inventory
func removeFromInventory(item: BaseInventoryItem, amount: int) -> void:
	var storedItemsAmount: int = storedItems.size()
	
	if amount > 0 && is_instance_valid(item):
		if storedItems.has(item):
			print("It does exist")
			for i in storedItemsAmount:
				if storedItems[i] == item: # I could potentially use it in difficultySystem or AI
					print("Old Amount: " + str(storedItems[i].amount))
					storedItems[i].amount -= amount
					print("New Amount: " + str(storedItems[i].amount))
					if storedItems[i].amount <= 0:
						print("Removed: " + str(storedItems[i]))
						storedItems.remove_at(i)
					break
		else:
			print("doesn't exist")
	else:
		print("Amount is less than 0,")
