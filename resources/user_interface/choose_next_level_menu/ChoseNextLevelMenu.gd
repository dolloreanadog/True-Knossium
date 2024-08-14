extends Control
class_name ChooseNextLevelMenu

const dungeonPaths: Array = ["res://resources/levels/ingame/dungeon/Dungeon.tscn", "res://resources/levels/ingame/forest/Forest.tscn"]
var chosenDungeonPath: String

# Need to check for available paths, do not have chosenDungeonPath be the same dungeon

# Use ShopConfirmationWindow as reference
# 2 button paths

