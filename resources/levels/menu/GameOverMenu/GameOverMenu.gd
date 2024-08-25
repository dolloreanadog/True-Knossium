extends Node2D

# Load Files
@onready var filedCharacterUnlocked: Array
@onready var filedItemUnlocked: Array


@onready var loadedCharacterUnlocked: Array
@onready var loadedItemUnlocked: Array

# Important Stuff
@onready var CharacterDiedLabel: Label = get_node("StatsPanel/CharactersDiedLabel")
@onready var CharactersSurrenderedLabel: Label = get_node("StatsPanel/CharactersSurrenderedLabel")
@onready var TotalBattlesLabel: Label = get_node("StatsPanel/TotalBattlesLabel")
@onready var TotalTurnsLabel: Label = get_node("StatsPanel/TotalTurnsLabel")
@onready var PeakTotalStatPointsLabel: Label = get_node("StatsPanel/PeakTotalStatPointsLabel")

@onready var UnlockedList: ItemList = get_node("UnlockedPanel/UnlockedList")
var unlockedListArray: Array

func _ready() -> void:
	Global.StartLoadingScreen(false)
	UnlockedList.clear()
	unlockedListArray.clear()
	loadSaveData()
	
	loadFiledCharacters()
	loadFiledItems()
	visualizeUnlockedList()
	
	SaveSystem.clearSaveThroughEmptying()
	SaveSystem.clearSaveThroughDeletion()
	Global.EndLoadingScreen()

func _on_go_to_menu_pressed() -> void:
	Global.StartLoadingScreen(true)
	Global.clearNewProgressThroughDeletion()
	Global.clearNewProgressionDict()
	SaveSystem.clearSaveThroughEmptying()
	SaveSystem.clearSaveThroughDeletion()
	
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://resources/levels/MainMenu.tscn")

# Load Save
func loadSaveData() -> void:
	CharacterDiedLabel.text = "Total Characters Died: " + str(SaveSystem.GameInfoDict.CharactersDied)
	CharactersSurrenderedLabel.text = "Total Characters Surrendered: " + str(SaveSystem.GameInfoDict.CharactersSurrendered)
	TotalBattlesLabel.text = "Total Battles: " + str(SaveSystem.GameInfoDict.Battles)
	TotalTurnsLabel.text = "Total Turns: " + str(SaveSystem.GameInfoDict.Turns)
	PeakTotalStatPointsLabel.text = "Peak Total Stat Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints)

func visualizeUnlockedList() -> void:
	UnlockedList.clear()
	for i in loadedCharacterUnlocked.size():
		var Lcharacter: BaseCharacter = loadedCharacterUnlocked[i]
		UnlockedList.add_item(Lcharacter.id, Lcharacter.profilePicture)
		UnlockedList.set_item_tooltip(i, Lcharacter.characterDescription)
		await get_tree().create_timer(0.01).timeout
	
	for i in loadedItemUnlocked.size():
		var Litem: BaseInventoryItem = loadedItemUnlocked[i]
		UnlockedList.add_item(Litem.itemName, Litem.image)
		UnlockedList.set_item_tooltip(i, Litem.itemDesciption)

func loadFiledCharacters() -> void:
	var LCharacterUnlocked: Array = Global.newProgressionDict.CharactersUnlocked
	for i in LCharacterUnlocked.size():
		var loadedCharacter := load(LCharacterUnlocked[i])
		var instance: BaseCharacter = loadedCharacter.instantiate()
		loadedCharacterUnlocked.push_back(instance)

func loadFiledItems() -> void:
	var LItemUnlocked: Array = Global.newProgressionDict.ItemsUnlocked
	for i in LItemUnlocked.size():
		var loadedItem: BaseInventoryItem = load(LItemUnlocked[i])
		loadedItemUnlocked.push_back(loadedItem)

func compareBattleCount() -> void:
	Global.unlockWhenMostBattles(SaveSystem.GameInfoDict.Battles)
	

# Get filePaths in global newly(variable) & load them
# Display Newly Unlocked Stuff on itemlist
