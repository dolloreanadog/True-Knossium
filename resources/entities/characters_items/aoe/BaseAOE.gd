extends Area2D
class_name BaseAOE
# Notes
# We need to figure out how to activate the turns thing.
# This should always be the child
#

#--[ Turn System ]--
@onready var system: TurnSystem

#--[ Stats ]--
# Need Action to set these AOE
# The Four variable it should be targetting
#health, defense, attack, morale
@export var health: float
@export var defense: float
@export var attack: float
@export var morale: float
# Determine if attack lands or not
@export var accuracy: float

#--[ Status ]--
## How long an AOE Lingers
@export var TurnsLeft: float
@export var activateEveryTurn: bool = true
@export var activateLastTurn: bool
@export var isMelee: bool
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
	system.connect("OnNewTurn", InTurn)
	print("health attack for area is " + str(health))
	print("TurnSystem for Area is: " + str(system))
	print("Spawned")
	self.z_index = 1

func _process(delta):
	if draggable:
		if dragging:
			self.global_position = get_global_mouse_position() - currentPosition

#--[ Dragging Functions ]--
# Make sure to connect these functions to the button
func _on_button_pressed():
	print("Pressed")


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
	print("Global Position:" + str(lastPosition))

# When you place it in an area you're not suppose to
func returnToLastPosition():
	self.set_global_position(lastPosition)

#Check if overlaps an Area it's not suppose to
#Example: if it isn't melee, it should not be in anti-melee area
func areaOverlapIsBadArea():
	# The plan to remove the area is to set the position somewhere else
	print("Start Overlap Area Check")
	var overlappingAreaArrayCount = overlappingAreaArray.size()
	if isMelee:
		for i in overlappingAreaArrayCount:
			var target = overlappingAreaArray.pop_front()
			if target is BaseAReaAOEDenial:
				print("Returning")
				returnToLastPosition()
				draggable = true

#When it overlaps character should put into an array
func areaOverlapCharacter(ActiveAttack: bool):
	print("Start Overlap Character Check")
	var overlappingBodiesArrayCount = overlappingBodiesArray.size()
	for i in overlappingBodiesArrayCount:
		var target = overlappingBodiesArray.pop_front()
		if target is BaseCharacter && overlappingAreaArray.size() == 0:
			if ActiveAttack:
				attackStats(target)
			draggable = false

func getItemsInside():
	# We Should make a Temporary Array in here, if we're going to use every turn
	# If not temporary array, it will run out
	overlappingAreaArray = get_overlapping_areas()
	overlappingBodiesArray = get_overlapping_bodies()
	print(overlappingBodiesArray)
	print(overlappingAreaArray)
	

#--[ Overridable Functions ]--
# When there are no more turns activate
func lastTurn():
	print("Activate last turn")
	if activateLastTurn:
		getItemsInside()
		areaOverlapCharacter(true)
	self.queue_free()

# Every time a turn is done something happens
func InTurn():
	print("AOE Turn")
	TurnsLeft -= 1
	if activateEveryTurn:
		getItemsInside()
		areaOverlapCharacter(true)
	if TurnsLeft <= 0:
		lastTurn()

func attackStats(body: BaseCharacter):
	# Do the accuracy check
	print("Attacking " + str(body))
	body.damageStats(health, defense, attack, morale)
