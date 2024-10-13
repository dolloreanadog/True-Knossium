extends Resource
class_name BaseInventoryItem

## Insert File Path of the item
@export var globalFilePath: String 
## Put the image of the icon
@export var image: Texture2D = ImageTexture.new()
## Name of the item
@export var itemName: String = "name"
## Describe the item, what it does then add flavour text
@export_multiline var itemDesciption: String = "Description"
var amount: int = 0
## How much it cost in shop
@export var value: float = 0
## Is currently not used, but possibly changed in the future.
@export var doesValueChange: bool = false
var currentValue: float
## Can it become an AOE, if true make sure to put an AOE
@export var isInteractable: bool = false
## Will it spawn looking like an offensive AOE & multiply values by -1
@export var isOffensive: bool = false
## Needs isInteractable to be true, if so then put an AOE
@export var AOE: PackedScene
## How much health it changes
@export var AOEHealthGain: float = 0
## How much defense it changes
@export var AOEDefenseGain: float = 0
## How much attack it changes
@export var AOEAttackGain: float = 0
## How much morale it changes
@export var AOEMoraleGain: float = 0
## How much exp it changes
@export var AOEExpGain: float = 0
## How accurate is the AOE
@export_range(0, 1, 0.01) var AOEAccuracy: float = 1

func resetValue() -> void:
	currentValue = value

func adjustCurrentValueRandomly() -> void:
	if doesValueChange:
		currentValue -= randf_range(currentValue * -0.5, currentValue * 1.5)
		snapped(clampf(currentValue, value * 0.1, value * 2), 0.01)

func setCurrentValue(setAmount: float) -> void:
	currentValue = setAmount
	snapped(clampf(currentValue, value * 0.1, value * 2), 0.01)
