extends Area2D
class_name BaseAOE
# Notes
# We need to figure out how to activate the turns thing.
# This should always be the child
#

#--[ Owner ]--
var ownerCharacter: BaseCharacter
var ownerCharacterAnimation: String

#--[ Turn System ]--
@onready var system: TurnSystem

#--[ Stats ]--
# Need Action to set these AOE
# The Four variable it should be targetting
#health, defense, attack, morale
var health: float
var defense: float
var attack: float
var morale: float
# Determine if attack lands or not
## The lower the number, the more accurate it is
var accuracy: int

#--[ Status ]--
## How long an AOE Lingers
@export var TurnsLeft: int
@export var activateFirstTurn: bool = false
@export var activateEveryTurn: bool = true
@export var activateLastTurn: bool = false
@export var isMelee: bool
var isCharacterAnimationDone: bool = true
var statusActive: bool

#--[ Overlapping ]--
var overlappingAreaArray: Array
var overlappingBodiesArray: Array

#--[ Dragging ]--
var draggable = true
var dragging = false
var currentPosition = Vector2(0, 0)
var lastPosition: Vector2

#--[ Base Functions ]--
func _ready():
	system = get_parent().get_parent().get_node("TurnSystem")
	#system.connect("OnNewTurn", InTurn)
	system.connect("OnNewBattle", inBattle)
	#print(str(self) + ": health attack for area is " + str(health))
	#print(str(self) + ": defense attack for area is " + str(defense))
	#print(str(self) + ": attack attack for area is " + str(attack))
	#print(str(self) + ": morale attack for area is " + str(morale))
	#print(str(self) + ": accuracy for area is = " + str(accuracy))
	#print(str(self) + ": TurnSystem for Area is: " + str(system))
	#print(str(self) + ": Spawned")
	self.z_index = 1

func _process(_delta):
	if draggable:
		if dragging:
			self.global_position = get_global_mouse_position() - currentPosition

#--[ Dragging Functions ]--
# Make sure to connect these functions to the button
func _on_button_pressed():
	print(str(self) + ": Pressed")


func _on_button_button_up():
	# When Up should whether its in an area it's not suppose to be in
	dragging = false
	getItemsInside()
	areaOverlapCharacter(false)
	areaOverlapIsBadArea()

func _on_button_button_down():
	dragging = true
	currentPosition = get_global_mouse_position() - self.global_position
	lastPosition = self.global_position 
	print(str(self) + ": Global Position:" + str(lastPosition))

# When you place it in an area you're not suppose to
func returnToLastPosition():
	self.set_global_position(lastPosition)

#Check if overlaps an Area it's not suppose to
#Example: if it isn't melee, it should not be in anti-melee area
func areaOverlapIsBadArea():
	# The plan to remove the area is to set the position somewhere else
	print(str(self) + ": Start Overlap Area Check")
	var overlappingAreaArrayCount = overlappingAreaArray.size()
	if isMelee:
		for i in overlappingAreaArrayCount:
			var target = overlappingAreaArray.pop_front()
			if target is BaseAreaAOEDenial && target.active == true:
				print("Returning")
				returnToLastPosition()
				draggable = true

#When it overlaps character should put into an array
func areaOverlapCharacter(ActiveAttack: bool):
	print(str(self) + ": Start Overlap Character Check")
	var overlappingBodiesArrayCount = overlappingBodiesArray.size()
	for i in overlappingBodiesArrayCount:
		var target = overlappingBodiesArray.pop_front()
		if target is BaseCharacter:
			if ActiveAttack:
				attackStats(target)
			#draggable = false

func getItemsInside():
	# We Should make a Temporary Array in here, if we're going to use every turn
	# If not temporary array, it will run out
	overlappingAreaArray = get_overlapping_areas()
	overlappingBodiesArray = get_overlapping_bodies()
	print(str(self) + ": Overlapping Bodies Array: " + str(overlappingBodiesArray))
	print(str(self) + ": Overlapping Areas Array:" + str(overlappingAreaArray))
	

#--[ Action Functions ]--
# When there are no more turns activate
func lastTurn():
	print(str(self) + ": Activate last turn")
	customLastTurnAction()
	if activateLastTurn:
		getItemsInside()
		areaOverlapCharacter(true)

# Every time a turn is done something happens
func InTurn():
	print(str(self) + ": AOE Turn")
	TurnsLeft -= 1
	draggable = false
	statusActive = true
	if activateEveryTurn:
		getItemsInside()
		areaOverlapCharacter(true)
		customInTurn()
	if activateFirstTurn:
		firstTurn()
		activateFirstTurn = false
	if isCharacterAnimationDone:
		if is_instance_valid(ownerCharacter):
			ownerCharacter.runAnimation(ownerCharacterAnimation)
		isCharacterAnimationDone = false
	if TurnsLeft <= 0:
		lastTurn()
		self.queue_free()
		

func inBattle():
	self.queue_free()

# In Case we want something where  it gives a temporary buff, but not add onto it every turn
# Example: First Turn, give 5 health. Last Turn, remove 5 health
# Example: First Turn, give 10 morale. Every Turn, remove 2 morale
func firstTurn():
	print(str(self) + ": Activate first turn")
	customFirstTurn()

func attackStats(body: BaseCharacter):
	var checkArray: Array = [true]
	print(str(self) + ": Attacking " + str(body))
	
	# Adds as many false into the array
	for i in accuracy:
		checkArray.append(false)
		checkArray.shuffle()
	
	print(str(self) + ": Shuffle is " + str(checkArray))
	var target = checkArray.pop_front()
	
	if target:
		print(str(self) + ": Target Has Been hit ")
		customAttackStats()
		body.damageStats(health, defense, attack, morale)
	else:
		print(str(self) + ": Target Has Been missed ")

#--[ Overridable Functions ]--
#
func customLastTurnAction():
	pass

func customInTurn():
	pass

func customAttackStats():
	pass

func customFirstTurn():
	pass
