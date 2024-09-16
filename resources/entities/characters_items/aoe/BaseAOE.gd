extends Area2D
class_name BaseAOE
# Notes
# This should always be the child
# https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html
# ^ Make sure to set bus to SFX

@export var AOEName: String

#--[ Owner ]--
var ownerCharacter: BaseCharacter
var ownerCharacterName: String # We going to need to print the id of character
var ownerActionDescription: String
var ownerCharacterPFP: Texture2D
var ownerCharacterAnimation: String

# Move those @onready to the ready()

#--[ dungeon ]--
var dungeon: BaseLevel

#--[ Turn System ]--
var system: TurnSystem

#--[ Child Nodes ]--
## AOE sprite, not owner sprite animation
@export var spriteAnimations: AnimatedSprite2D
@export var audioPlayer: AudioStreamPlayer2D
@onready var collisionVisualizer: MeshInstance2D = get_node("MeshInstance2D")
@onready var button: Button = get_node("Button")

@export var isDynamicColor: bool = true
var mainColor: Color
#--[ Other Nodes]--
var dungeonAOEInfoBox

#--[ Stats ]--

var health: float
var defense: float
var attack: float
var morale: float
# Determine if attack lands or not
## The lower the number, the more accurate it is
var experience: float
var accuracy: float = 1


#--[ Status ]--
## How long an AOE Lingers
@export var isAnimationEveryTurn: bool = true

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

signal gotItems
signal aoeHasAttack(character: BaseCharacter)

#--[ Base Functions ]--
func _ready() -> void:
#	if get_parent().get_parent().get_node("TurnSystem") is TurnSystem:
#		system = get_parent().get_parent().get_node("TurnSystem")
#		system.connect("OnNewBattle", inBattle)
	
	if get_parent().get_parent().get_parent() is BaseLevel:
		dungeon = get_parent().get_parent().get_parent()
	
	if get_parent().get_parent().get_parent().get_node("AOEInfoBox") is AOEInfoBox:
		dungeonAOEInfoBox = get_parent().get_parent().get_parent().get_node("AOEInfoBox")
	
	if dungeon is BaseLevel:
		system = dungeon.system
	
	if !is_instance_valid(spriteAnimations):
		push_warning("There is no sprite animation node, might result in save error!")
	
	mainColor = collisionVisualizer.modulate
	#system.connect("OnNewTurn", NewTurnSignaled)
	
	if is_instance_valid(audioPlayer):
		audioPlayer.set_bus("SFX")
	
	self.z_index = 100


func _process(_delta) -> void:
	if draggable:
		if dragging:
			global_position = get_global_mouse_position()
		
	

#--[ Dragging Functions ]--
# Make sure to connect these functions to the button
func _on_button_pressed() -> void:
	print(str(self) + ": Pressed")
	if draggable:
		if SettingsSystem.getAOEMovement():
			if dragging:
				dungeon.setDisabledAllAOE(true)
				dragging = false
				collisionVisualizer.modulate = mainColor
				await get_tree().create_timer(0.1).timeout
				await getItemsInside()
#				call_deferred("getItemsInside")
#				await gotItems
				areaOverlapCharacter(false)
				areaOverlapIsBadArea()
			else:
				button.mouse_filter = Control.MOUSE_FILTER_STOP
				dragging = true
				collisionVisualizer.modulate = Color(1, 1, 1, 0.2)
				lastPosition = self.global_position 
				dungeon.setDisabledAllAOE(false)
				button.visible = true
	
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
	dungeonAOEInfoBox.turnsLeftValue = TurnsLeft
	dungeonAOEInfoBox.insertAOEInfo()


func _on_button_button_up() -> void:
	# When Up should whether its in an area it's not suppose to be in
	if draggable:
		if !SettingsSystem.getAOEMovement():
			dragging = false
			collisionVisualizer.modulate = mainColor
			await get_tree().create_timer(0.1).timeout
#			call_deferred("getItemsInside")
#			await gotItems
			await getItemsInside()
			areaOverlapCharacter(false)
			areaOverlapIsBadArea()
	

func _on_button_button_down() -> void:
	if draggable:
		if !SettingsSystem.getAOEMovement():
			dragging = true
			#if isDynamicColor:
			collisionVisualizer.modulate = Color(1, 1, 1, 0.2)
			lastPosition = self.global_position 
			print(str(self) + ": Global Position:" + str(lastPosition))

# When you place it in an area you're not suppose to
func returnToLastPosition() -> void:
	var warningLabel: Label = Label.new()
	
	draggable = false
	button.disabled = true
	
	warningLabel.modulate = Color(1, 0, 0, 1)
	warningLabel.text = "Can't Place Here!"
	collisionVisualizer.modulate = Color(1, 0, 0, 0.11)
	
	# This is here so that it doesn't become a child of AOE Containers
	dungeon.add_child(warningLabel)
	warningLabel.global_position = collisionVisualizer.global_position - Vector2(60, 0)
	
	
	await get_tree().create_timer(0.2).timeout
	collisionVisualizer.modulate = mainColor
	
	self.set_global_position(lastPosition)
	draggable = true
	button.disabled = false
	
	await get_tree().create_timer(0.05).timeout
	await getItemsInside()
	areaOverlapCharacter(false)
	
	await get_tree().create_timer(1).timeout
	
	warningLabel.queue_free()

#Check if overlaps an Area it's not suppose to
#Example: if it isn't melee, it should not be in anti-melee area
func areaOverlapIsBadArea() -> void:
	# The plan to remove the area is to set the position somewhere else
	print(str(self) + ": Start Overlap Area Check")
	overlappingAreaArray = get_overlapping_areas()
#	await get_tree().create_timer(0.01).timeout
	var overlappingAreaArrayCount = overlappingAreaArray.size()
	print("overlapping Areas: " + str(overlappingAreaArray))
	for i in overlappingAreaArrayCount:
		var target = overlappingAreaArray.pop_front()
		if target is BaseAreaAOEDenial && target.active == true:
			if target.blocker == target.blockType.ALL:
				print("Returning")
				returnToLastPosition()
				break
			if target.blocker == target.blockType.MELEE && isMelee:
				print("Returning")
				returnToLastPosition()
				break
			if target.blocker == target.blockType.RANGED && !(isMelee):
				print("Returning")
				returnToLastPosition()
				break

#When it overlaps character should put into an array
func areaOverlapCharacter(ActiveAttack: bool) -> void:
#	print(str(self) + ": Start Overlap Character Check (overlap)")
#	print(str(self) + ": (overlap) Start Overlap Character Check " + str(overlappingBodiesArray.size()))
	await get_tree().create_timer(0.01).timeout
	overlappingBodiesArray = get_overlapping_bodies()
#	await get_tree().create_timer(0.01).timeout
	if overlappingBodiesArray.size() != 0:
		for i in overlappingBodiesArray.size():
			var target = overlappingBodiesArray.pop_front()
			if target is BaseCharacter:
				if isDynamicColor:
					collisionVisualizer.modulate = Color(0, 0, 1, 0.05)
				if ActiveAttack:
					attackStats(target)
				#draggable = false
	else:
		collisionVisualizer.modulate = mainColor

func getItemsInside() -> bool:
	# We Should make a Temporary Array in here, if we're going to use every turn
	# If not temporary array, it will run out
#	overlappingAreaArray = get_overlapping_areas()
#	overlappingBodiesArray = get_overlapping_bodies()
	await get_tree().create_timer(0.001).timeout
#	print(str(self) + ": Overlapping Bodies Array: " + str(overlappingBodiesArray))
#	print(str(self) + ": Overlapping Areas Array:" + str(overlappingAreaArray))
	emit_signal("gotItems") # connect both areaOverlapCharacter & areaOverlapIsBadArea, or put them in their own functions
	return true

#--[ Action Functions ]--
# When there are no more turns activate
func lastTurn() -> void:
#	print(str(self) + ": Activate last turn")
	if activateLastTurn:
		animationActivate()
		await getItemsInside()
		areaOverlapCharacter(true)

# Every time a turn is done something happens
func InTurn() -> void:
#	print(str(self) + ": AOE Turn")
	TurnsLeft -= 1
	draggable = false
	statusActive = true
	if activateEveryTurn:
		await getItemsInside()
		areaOverlapCharacter(true)
		if isAnimationEveryTurn:
			animationActivate()
	if activateFirstTurn:
		firstTurn()
		activateFirstTurn = false
#		if animationActivateOn == animationActivation.FIRSTTURN:
#			animationActivate()
	if isCharacterAnimationDone:
		if is_instance_valid(ownerCharacter):
			ownerCharacter.playAnimation(ownerCharacterAnimation)
			ownerCharacter.QueueAnimation("idle1")
#			ownerCharacter.characterAnimation.queue("idle1")
		isCharacterAnimationDone = false
	if TurnsLeft <= 0:
		lastTurn()
#		if animationActivateOn == animationActivation.LASTTURN:
#			animationActivate()
		if is_instance_valid(spriteAnimations):
			while spriteAnimations.is_playing():
				await get_tree().create_timer(0.01).timeout
		self.queue_free()
		


func inBattle() -> void:
	self.queue_free()

# In Case we want something where  it gives a temporary buff, but not add onto it every turn
# Example: First Turn, give 5 health. Last Turn, remove 5 health
# Example: First Turn, give 10 morale. Every Turn, remove 2 morale
func firstTurn() -> void:
	await getItemsInside()
	areaOverlapCharacter(true)
	animationActivate()
	print(str(self) + ": Activate first turn")

func attackStats(body: BaseCharacter) -> void:
#	if randf_range(0, 1) <= accuracy:
#	print(str(self) + ": Target Has Been hit ")
	body.damageStats(randf_range(0, health * (1 + accuracy)), randf_range(0, defense * (1 + accuracy)), randf_range(0, attack * (1 + accuracy)), randf_range(0, morale * (1 + accuracy)))
	body.stats.changeEXP(experience)
	aoeHasAttack.emit(body)
#	else:
#		print(str(self) + ": Target Has Been missed ")
#		body.damageStats(0, 0, 0, 0)

func animationActivate() -> void:
	if is_instance_valid(spriteAnimations):
		spriteAnimations.play("active")
	if is_instance_valid(audioPlayer):
		audioPlayer.play()

func setVisbility(visibility: bool) -> void:
	collisionVisualizer.set_visible(visibility)
	button.set_visible(visibility)

func getVisibility() -> bool:
	print("getting visiblity")
	return collisionVisualizer.is_visible()
