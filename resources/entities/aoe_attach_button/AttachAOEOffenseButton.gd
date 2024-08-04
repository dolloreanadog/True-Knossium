extends AOEAttacherButton
class_name AOEOffensiveAttacherButton

@export var isMelee: bool

func _pressed() -> void:
	var aoeArray: Array = area.get_overlapping_areas()
	print("old current AOE available:" + str(aoeArray))
	aoeArray = aoeArray.filter(func(object): return object.isMelee == isMelee)
	aoeArray = aoeArray.filter(func(object): return object.dragging == false)
	aoeArray = aoeArray.filter(func(object): return object.draggable == true)
	print("new current AOE available:" + str(aoeArray))
	
	var selectedAOE: BaseAOE
	
	if aoeArray.size() != 0:
		selectedAOE = aoeArray[0]
#		for i in aoeArray.size():
#			selectedAOE = aoeArray.pick_random()
#			break
			
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
