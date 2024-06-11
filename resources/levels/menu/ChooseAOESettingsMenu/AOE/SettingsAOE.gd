extends BaseAOE
class_name SettingsAOE
#SettingsAOEMovement
# False = Click & Click
# True = Click & Drag
@export var AOEMovement: bool = false

signal placed

func _process(_delta):
	if draggable:
		if dragging:
			self.global_position = get_global_mouse_position()
		
	

func _on_button_pressed():
	print(str(self) + ": Pressed")
	
	if AOEMovement:
		if dragging:
			dragging = false
			collisionVisualizer.modulate = mainColor
			await get_tree().create_timer(0.1).timeout
			call_deferred("getItemsInside")
			await gotItems
			areaOverlapCharacter(false)
			areaOverlapIsBadArea()
		else:
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			dragging = true
			collisionVisualizer.modulate = Color(1, 1, 1, 0.2)
			lastPosition = self.global_position 
			button.visible = true


func _on_button_button_up():
	# When Up should whether its in an area it's not suppose to be in
	if AOEMovement:
		pass
	else:
		dragging = false
		collisionVisualizer.modulate = mainColor
		await get_tree().create_timer(0.01).timeout
		call_deferred("getItemsInside")
		await gotItems
		areaOverlapCharacter(false)
		areaOverlapIsBadArea()
	

func _on_button_button_down():
	if AOEMovement:
		pass
	else:
		dragging = true
		#if isDynamicColor:
		collisionVisualizer.modulate = Color(1, 1, 1, 0.2)
		lastPosition = self.global_position 
		print(str(self) + ": Global Position:" + str(lastPosition))

