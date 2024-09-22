extends Node2D

# Load Files
@onready var filedCharacterUnlocked: Array
@onready var filedItemUnlocked: Array


@onready var loadedCharacterUnlocked: Array
@onready var loadedItemUnlocked: Array

# Important Stuff
@onready var CharacterDiedLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer/CharactersDiedLabel
@onready var CharactersSurrenderedLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer/CharactersSurrenderedLabel
@onready var TotalBattlesLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer/TotalBattlesLabel
@onready var TotalTurnsLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer/TotalTurnsLabel
@onready var PeakTotalStatPointsLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer/PeakTotalStatPointsLabel
@onready var PlayerTotalDamageLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer3/PlayerTotalDamageLabel
@onready var PlayerTotalSupportLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer3/PlayerTotalSupportLabel
@onready var EnemyTotalDamageLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer3/EnemyTotalDamageLabel
@onready var EnemyTotalSupportLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer3/EnemyTotalSupportLabel
@onready var TotalPlayerAOEUsed: Label = $StatsPanel/HBoxContainer/VBoxContainer2/TotalPlayerAOEUsedLabel
@onready var TotalEnemyAOEUsed: Label = $StatsPanel/HBoxContainer/VBoxContainer2/TotalEnemyAOEUsedLabel
@onready var TotalExperienceGained: Label = $StatsPanel/HBoxContainer/VBoxContainer2/TotalExperienceGainedLabel
@onready var TotalLevelsGained: Label = $StatsPanel/HBoxContainer/VBoxContainer2/TotalLevelsGainedLabel

@onready var ShopAppearedLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer2/ShopAppearedLabel
@onready var AreasAppearedLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer3/AreasAppearedLabel
@onready var TradesFailedLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer4/TradesFailedLabel
@onready var TradesCompletedLabel: Label = $StatsPanel/HBoxContainer/VBoxContainer4/TradesCompletedLabel

@onready var CharactersFieldedGraph: Graph2D = $"Panel/TabContainer/Characters Fielded/Graph2D"
@onready var TotalStatPointsGraph: Graph2D = $"Panel/TabContainer/Total Stat Points/Graph2D"
@onready var AOEFieldedGraph: Graph2D = $"Panel/TabContainer/AOE Fielded/Graph2D"

@onready var UnlockedList: ItemList = $UnlockedPanel/UnlockedList
var unlockedListArray: Array

func _ready() -> void:
	Global.StartLoadingScreen(false)
	UnlockedList.clear()
	unlockedListArray.clear()
	loadSaveData()
	
	loadFiledCharacters()
	loadFiledItems()
	visualizeUnlockedList()
	
	Global.EndLoadingScreen()
	Steam.setRichPresence("steam_display", "#Over")

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
#	print("Loaded: " + str(SaveSystem.GameInfoDict))
	CharacterDiedLabel.text = "Total Characters Died: " + str(SaveSystem.GameInfoDict.CharactersDied)
	CharactersSurrenderedLabel.text = "Total Characters Surrendered: " + str(SaveSystem.GameInfoDict.CharactersSurrendered)
	TotalBattlesLabel.text = "Total Battles: " + str(SaveSystem.GameInfoDict.Battles)
	TotalTurnsLabel.text = "Total Turns: " + str(SaveSystem.GameInfoDict.Turns)
	PeakTotalStatPointsLabel.text = "Peak Total Stat Points: " + str(SaveSystem.GameInfoDict.PeakTotalStatPoints)
	PlayerTotalDamageLabel.text = "You Did " + str(snappedf(SaveSystem.GameInfoDict.PlayerTotalDamage, 0.01)) + " Total Damage"
	PlayerTotalSupportLabel.text = "You Did " + str(snappedf(SaveSystem.GameInfoDict.PlayerTotalSupport, 0.01)) + " Total Support"
	EnemyTotalDamageLabel.text = "Enemy Did " + str(snappedf(SaveSystem.GameInfoDict.EnemyTotalDamage, 0.01)) + " Total Damage"
	EnemyTotalSupportLabel.text = "Enemy Did " + str(snappedf(SaveSystem.GameInfoDict.EnemyTotalSupport, 0.01)) + " Total Support"
	TotalPlayerAOEUsed.text = "You Placed " + str(SaveSystem.GameInfoDict.PlayerTotalAOEUsed) + " AOE"
	TotalEnemyAOEUsed.text = "Enemy Placed " + str(SaveSystem.GameInfoDict.EnemyTotalAOEUsed) + " AOE"
	TotalExperienceGained.text = "Total Experience: " + str(snappedf(SaveSystem.GameInfoDict.ExperienceGained, 0.01))
	TotalLevelsGained.text = "Total Levels: " + str(SaveSystem.GameInfoDict.LevelsGained)
	ShopAppearedLabel.text = "Shop appeared " + str(SaveSystem.GameInfoDict.ShopAppeared)
	AreasAppearedLabel.text = "Area appeared " + str(SaveSystem.GameInfoDict.AreaAppeared)
	TradesFailedLabel.text = "Trade failed " + str(SaveSystem.GameInfoDict.TradeCompleted) + " times"
	TradesCompletedLabel.text = "Trade completed " + str(SaveSystem.GameInfoDict.TradeFailed) + " times"
	var confirm: bool = await UpdateCharts()
	if confirm:
		await get_tree().create_timer(0.5).timeout
		SaveSystem.clearSaveThroughEmptying()
		SaveSystem.clearSaveThroughDeletion()
	else:
		assert(false, "failed to update chart")

func UpdateCharts() -> bool:
	var charactersFieldedPlot: PlotItem = CharactersFieldedGraph.add_plot_item(" ", Color.WHITE, 2)
	var totalStatPointsPlot: PlotItem = TotalStatPointsGraph.add_plot_item(" ", Color.WHITE, 2)
	var AOEFieldedPlot: PlotItem = AOEFieldedGraph.add_plot_item(" ", Color.WHITE, 2.5)
	
	for vector in SaveSystem.GameInfoDict.TotalStatPoints:
		totalStatPointsPlot.add_point(vector)
		if TotalStatPointsGraph.x_max < vector.x:
			TotalStatPointsGraph.x_max = vector.x
		if TotalStatPointsGraph.y_max < vector.y:
			TotalStatPointsGraph.y_max = vector.y
		await get_tree().create_timer(0.001).timeout
	for vector in SaveSystem.GameInfoDict.CharactersFielded:
		charactersFieldedPlot.add_point(vector)
		if CharactersFieldedGraph.x_max < vector.x:
			CharactersFieldedGraph.x_max = vector.x
		if CharactersFieldedGraph.y_max < vector.y:
			CharactersFieldedGraph.y_max = vector.y
		await get_tree().create_timer(0.001).timeout
	for vector in SaveSystem.GameInfoDict.AOEFielded:
		AOEFieldedPlot.add_point(vector)
		if AOEFieldedGraph.x_max < vector.x:
			AOEFieldedGraph.x_max = vector.x
		if AOEFieldedGraph.y_max < vector.y:
			AOEFieldedGraph.y_max = vector.y
		await get_tree().create_timer(0.001).timeout
	return true


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
