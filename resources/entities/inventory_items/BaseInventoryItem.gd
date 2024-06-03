extends Resource
class_name BaseInventoryItem

@export var globalFilePath: String 
@export var image: Texture2D = ImageTexture.new()
@export var itemName: String = "name"
@export_multiline var itemDesciption: String = "Description"
@export var amount: int = 0
@export var value: float = 0
@export var doesValueChange: bool = false
var currentValue: float
@export var isInteractable: bool = false
@export var isOffensive: bool = false
@export var AOE: PackedScene
@export var AOEHealthGain: float = 0
@export var AOEDefenseGain: float = 0
@export var AOEAttackGain: float = 0
@export var AOEMoraleGain: float = 0
@export var AOEExpGain: float = 0
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
