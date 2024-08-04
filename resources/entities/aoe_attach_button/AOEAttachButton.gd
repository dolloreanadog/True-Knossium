extends Button
class_name AOEAttacherButton

@export var area: Area2D

#@onready var dungeon: BaseLevel = get_tree().get_current_scene()

func _ready() -> void:
	pass

func _pressed() -> void:
	var aoeArray: Array = area.get_overlapping_areas()
	var selectedAOE: BaseAOE
	print("current AOE available:" + str(aoeArray))
	if aoeArray.size() != 0:
		selectedAOE = aoeArray[0]
		for i in aoeArray.size():
			if selectedAOE.dragging == false or selectedAOE.draggable == true:
				selectedAOE = aoeArray.pick_random()
				break
			
		print("selected AOE:" + str(selectedAOE))
		selectedAOE.lastPosition = selectedAOE.global_position 
		await get_tree().create_timer(0.01).timeout
		
		selectedAOE.dungeonAOEInfoBox.characterPFP = selectedAOE.ownerCharacterPFP
		selectedAOE.dungeonAOEInfoBox.characterName = selectedAOE.ownerCharacterName
		selectedAOE.dungeonAOEInfoBox.AOEName = selectedAOE.AOEName
		selectedAOE.dungeonAOEInfoBox.description = selectedAOE.ownerActionDescription
		selectedAOE.dungeonAOEInfoBox.accuracyValue = selectedAOE.accuracy
		selectedAOE.dungeonAOEInfoBox.healthDamageValue = selectedAOE.health
		selectedAOE.dungeonAOEInfoBox.defenseDamageValue = selectedAOE.defense
		selectedAOE.dungeonAOEInfoBox.attackDamageValue = selectedAOE.attack
		selectedAOE.dungeonAOEInfoBox.moraleDamageValue = selectedAOE.morale
		selectedAOE.dungeonAOEInfoBox.isMeleeValue = selectedAOE.isMelee
		selectedAOE.dungeonAOEInfoBox.isMovableValue = selectedAOE.draggable
		selectedAOE.dungeonAOEInfoBox.insertAOEInfo()
		
		selectedAOE.global_position = get_global_mouse_position()
		await get_tree().create_timer(0.1).timeout
		selectedAOE.areaOverlapCharacter(false)
		selectedAOE.areaOverlapIsBadArea()
	# Get Overlapping Areas as an array
	# Grab a random AOE from that array & move that aoe to your cursor (like use on of their functions), like attach or teleport
	# another alternative is to move a random aoe from that array to the cursor & check if in bad area, not using their functions

