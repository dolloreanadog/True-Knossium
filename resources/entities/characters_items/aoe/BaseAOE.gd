extends Area2D
class_name BaseAOE
# Notes
# This should always be the child

@export var AOEName: String

#--[ Owner ]--
var ownerCharacter: BaseCharacter
var ownerCharacterName: String # We going to need to print the id of character
var ownerActionDescription: String
var ownerCharacterPFP: Texture2D
var ownerCharacterAnimation: String

#--[ Turn System ]--
@onready var system: TurnSystem

#--[ Child Nodes ]--
@export var spriteAnimations: AnimatedSprite2D
@onready var collisionVisualizer: MeshInstance2D = get_node("MeshInstance2D")
@onready var button: Button = get_node("Button")

#--[ Other Nodes]--
@onready var dungeonAOEInfoBox: AOEInfoBox = get_parent().get_parent().get_node("AOEInfoBox")


#--[ Stats ]--

var health: float
var defense: float
var attack: float
var morale: float
# Determine if attack lands or not
## The lower the number, the more accurate it is
var accuracy: int


#--[ Status ]--
## How long an AOE Lingers
enum animationActivation {EVERYTURN, FIRSTTURN, LASTTURN}
@export var animationActivateOn: animationActivation

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
	#system.connect("OnNewTurn", NewTurnSignaled)
	system.connect("OnNewBattle", inBattle)
	self.z_index = 1

func _process(_delta):
	if draggable:
		if dragging:
			self.global_position = get_global_mouse_position() - currentPosition

#--[ Dragging Functions ]--
# Make sure to connect these functions to the button
func _on_button_pressed():
	print(str(self) + ": Pressed")
	
	dungeonAOEInfoBox.characterPFP = ownerCharacterPFP
	dungeonAOEInfoBox.characterName = ownerCharacterName
	dungeonAOEInfoBox.AOEName = AOEName
	dungeonAOEInfoBox.description = ownerActionDescription
	dungeonAOEInfoBox.accuracyValue = accuracy
	dungeonAOEInfoBox.healthDamageValue = health
	dungeonAOEInfoBox.defenseDamageValue = defense
	dungeonAOEInfoBox.attackDamageValue = attack
	dungeonAOEInfoBox.moraleDamageValue = morale
	dungeonAOEInfoBox.isMeleeValue = isMelee
	dungeonAOEInfoBox.isMovableValue = draggable
	dungeonAOEInfoBox.insertAOEInfo()


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
		if animationActivateOn == animationActivation.EVERYTURN:
			animationActivate()
	if activateFirstTurn:
		firstTurn()
		activateFirstTurn = false
		if animationActivateOn == animationActivation.FIRSTTURN:
			animationActivate()
	if isCharacterAnimationDone:
		if is_instance_valid(ownerCharacter):
			ownerCharacter.runAnimation(ownerCharacterAnimation)
		isCharacterAnimationDone = false
	if TurnsLeft <= 0:
		lastTurn()
		if animationActivateOn == animationActivation.LASTTURN:
			animationActivate()
		while spriteAnimations.is_playing():
			await get_tree().create_timer(0.01).timeout
		self.queue_free()
		


func inBattle():
	self.queue_free()

# In Case we want something where  it gives a temporary buff, but not add onto it every turn
# Example: First Turn, give 5 health. Last Turn, remove 5 health
# Example: First Turn, give 10 morale. Every Turn, remove 2 morale
func firstTurn():
	print(str(self) + ": Activate first turn")

func attackStats(body: BaseCharacter):
	var checkArray: Array = [true, true, true]
	print(str(self) + ": Attacking " + str(body))
	
	# Adds as many false into the array
	for i in accuracy:
		checkArray.append(false)
		checkArray.shuffle()
	
	print(str(self) + ": Shuffle is " + str(checkArray))
	var target = checkArray.pop_front()
	
	if target:
		print(str(self) + ": Target Has Been hit ")
		body.damageStats(health, defense, attack, morale)
	else:
		print(str(self) + ": Target Has Been missed ")

func animationActivate():
	if is_instance_valid(spriteAnimations):
		spriteAnimations.play("active")

func setVisbility(visibility: bool):
	collisionVisualizer.set_visible(visibility)
	button.set_visible(visibility)

func getVisibility():
	print("getting visiblity")
	return collisionVisualizer.is_visible()
