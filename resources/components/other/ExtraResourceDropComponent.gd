extends Node
class_name ExtraResourceDropComponent

var character: BaseCharacter

## Example: "res://resources/entities/inventory_items/dev_items/HealthPotion.tres": 0
@export var itemsDict: Dictionary

func _ready() -> void:
	character = get_parent()

func AddItems() -> void:
	for item in itemsDict:
		if randi_range(0, 2) == 0:
			if FileAccess.file_exists(item):
				var loadedItem = load(item)
				character.inventory.addToInventory(loadedItem.duplicate(true), itemsDict[item])
			else:
				push_error("That item does not exist or it's the wrong file path: ")

func Activated() -> void:
	AddItems()
