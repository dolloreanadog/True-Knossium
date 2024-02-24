extends Control
# Have this all account in when we click turn end we cannot see AOE

@onready var dungeon = get_parent()

@export var EnemyAOEContainerOffensive: EnemyAOEContainer
@export var EnemyAOEContainerSupport: EnemyAOEContainer
@export var FriendlyAOEContainerOffensive: BaseSpawnArea
@export var FriendlyAOEContainerSupport: BaseSpawnArea

var EnemyAOEContainerOffensiveChildren: Array
var EnemyAOEContainerSupportChildren: Array
var FriendlyAOEContainerOffensiveChildren: Array
var FriendlyAOEContainerSupportChildren: Array

var isAllEnemyAOEVisible: bool = true
var isAllFriendlyAOEVisible: bool = true
var isAllSupportAOEVisible: bool = true
var isAllOffensiveAOEVisible: bool = true
var isAllDraggableAOEVisible: bool = true

func _ready():
	$EnemyAOEInvisible.button_pressed = isAllEnemyAOEVisible
	$FriendlyAOEInvisible.button_pressed = isAllFriendlyAOEVisible
	$SupportAOEInvisible.button_pressed = isAllSupportAOEVisible
	$OffensiveAOEInvisible.button_pressed = isAllOffensiveAOEVisible
	$DraggableAOEInvisible.button_pressed = isAllDraggableAOEVisible
	

func _on_dungeon_aoe_queue_finished():
	await get_tree().create_timer(0.4).timeout
	setAllAOEVisibility()

func _on_enemy_aoe_invisible_toggled(button_pressed):
	isAllEnemyAOEVisible = button_pressed
	setAllAOEVisibility()

func _on_friendly_aoe_invisible_toggled(button_pressed):
	isAllFriendlyAOEVisible = button_pressed
	setAllAOEVisibility()

func _on_support_aoe_invisible_toggled(button_pressed):
	isAllSupportAOEVisible = button_pressed
	setAllAOEVisibility()

func _on_offensive_aoe_invisible_toggled(button_pressed):
	isAllOffensiveAOEVisible = button_pressed
	setAllAOEVisibility()

func _on_draggable_aoe_invisible_toggled(button_pressed):
	isAllDraggableAOEVisible = button_pressed
	setAllAOEVisibility()

func getAllAOE():
	EnemyAOEContainerOffensiveChildren = EnemyAOEContainerOffensive.get_children()
	EnemyAOEContainerSupportChildren = EnemyAOEContainerSupport.get_children()
	FriendlyAOEContainerOffensiveChildren = FriendlyAOEContainerOffensive.get_children()
	FriendlyAOEContainerSupportChildren = FriendlyAOEContainerSupport.get_children()
	
	#print(str(self) + ": (getAllAOE) EnemyAOEContainerOffensiveChildren: " + str(EnemyAOEContainerOffensiveChildren))
	#print(str(self) + ": (getAllAOE) EnemyAOEContainerSupportChildren: " + str(EnemyAOEContainerSupportChildren))
	#print(str(self) + ": (getAllAOE) FriendlyAOEContainerOffensiveChildren: " + str(FriendlyAOEContainerOffensiveChildren))
	#print(str(self) + ": (getAllAOE) FriendlyAOEContainerSupportChildren: " + str(FriendlyAOEContainerSupportChildren))

func setAllAOEVisibility():
	getAllAOE()
	var targetAOEArray: Array
	
	if isAllEnemyAOEVisible:
		print(str(self) + ": (setAllAOEVisibility) Setting Enemy Array")
		targetAOEArray = EnemyAOEContainerOffensiveChildren + EnemyAOEContainerSupportChildren
		setTargetAOEVisiblity(targetAOEArray, isAllEnemyAOEVisible)
	elif isAllEnemyAOEVisible != true:
		targetAOEArray = EnemyAOEContainerOffensiveChildren + EnemyAOEContainerSupportChildren
		setTargetAOEVisiblity(targetAOEArray, isAllEnemyAOEVisible)
	
	if isAllFriendlyAOEVisible:
		print(str(self) + ": (setAllAOEVisibility) Setting Friendly Array")
		targetAOEArray = FriendlyAOEContainerOffensiveChildren + FriendlyAOEContainerSupportChildren
		setTargetAOEVisiblity(targetAOEArray, isAllFriendlyAOEVisible)
	elif isAllFriendlyAOEVisible != true:
		targetAOEArray = FriendlyAOEContainerOffensiveChildren + FriendlyAOEContainerSupportChildren
		setTargetAOEVisiblity(targetAOEArray, isAllFriendlyAOEVisible)
	
	if isAllSupportAOEVisible != true:
		var finalTargetAOEArray: Array = []

		if isAllEnemyAOEVisible:
			finalTargetAOEArray += EnemyAOEContainerSupportChildren
		if isAllFriendlyAOEVisible:
			finalTargetAOEArray += FriendlyAOEContainerSupportChildren

		setTargetAOEVisiblity(finalTargetAOEArray, isAllSupportAOEVisible)
	
	if isAllOffensiveAOEVisible != true:
		var finalTargetAOEArray: Array = []

		if isAllEnemyAOEVisible:
			finalTargetAOEArray += EnemyAOEContainerOffensiveChildren
		if isAllFriendlyAOEVisible:
			finalTargetAOEArray += FriendlyAOEContainerOffensiveChildren

		setTargetAOEVisiblity(finalTargetAOEArray, isAllOffensiveAOEVisible)
		
	
	if isAllDraggableAOEVisible != true:
		var finalTargetAOEArray: Array = []
		print(str(self) + ": Draggable AOE should be invisible")
		
		if isAllSupportAOEVisible:
			print(str(self) + ": Support AOE should be visible")
			if isAllEnemyAOEVisible:
				finalTargetAOEArray += EnemyAOEContainerSupportChildren
			if isAllFriendlyAOEVisible:
				finalTargetAOEArray += FriendlyAOEContainerSupportChildren
		
		if isAllOffensiveAOEVisible:
			print(str(self) + ": Offensive AOE should be visible")
			if isAllEnemyAOEVisible:
				finalTargetAOEArray += EnemyAOEContainerOffensiveChildren
			if isAllFriendlyAOEVisible:
				finalTargetAOEArray += FriendlyAOEContainerOffensiveChildren
		
		print("finalTargetAOEArray: " + str(finalTargetAOEArray))
		print("finalTargetAOEArrayFiltered: " + str(finalTargetAOEArray.filter(filterDraggable)))
		
		setTargetAOEVisiblity(finalTargetAOEArray.filter(filterDraggable), isAllDraggableAOEVisible)
	
	# 
	
#	if isAllDraggableAOEVisible:
#		var finalTargetAOEArray = EnemyAOEContainerOffensiveChildren + EnemyAOEContainerSupportChildren + FriendlyAOEContainerOffensiveChildren + FriendlyAOEContainerSupportChildren
#		finalTargetAOEArray.filter(filterDraggable)
#		print("finalTargetAOEArray: " + str(targetAOEArray))
#		setTargetAOEVisiblity(finalTargetAOEArray, isAllDraggableAOEVisible)
#	elif isAllDraggableAOEVisible != true:
#		var finalTargetAOEArray = EnemyAOEContainerOffensiveChildren + EnemyAOEContainerSupportChildren + FriendlyAOEContainerOffensiveChildren + FriendlyAOEContainerSupportChildren
#		finalTargetAOEArray.filter(filterDraggable)
#		print("finalTargetAOEArray: " + str(targetAOEArray))
#		setTargetAOEVisiblity(finalTargetAOEArray, isAllDraggableAOEVisible)

func filterVisible(object: BaseAOE):
	return object.getVisibility() != true

func filterDraggable(object: BaseAOE):
	return object.draggable != true

func inTurn():
	getAllAOE()
	var targetAOEArray: Array
	
	#if isAOEInvisibleWhenInTurn: # This is for in settings to disable or enable this
	targetAOEArray = EnemyAOEContainerOffensiveChildren + EnemyAOEContainerSupportChildren + FriendlyAOEContainerOffensiveChildren + FriendlyAOEContainerSupportChildren
	setTargetAOEVisiblity(targetAOEArray, false)

func setTargetAOEVisiblity(targetAOEArray: Array, boolean: bool):
	print(str(self) + ": We keep doing it?")
	print(str(self) + ": (setTargetAOEVisiblity) targetAOEArray: " + str(targetAOEArray))
	while targetAOEArray.size() != 0:
		var targetAOE = targetAOEArray.pop_back()
		targetAOE.setVisbility(boolean)









