extends BaseStatChangedFX

func playFX():
	playVFX()

func playVFX():
	var tween: Tween = create_tween()
	var instancedLabel: Label = Label.new()
	add_child(instancedLabel)
	instancedLabel.global_position = character.global_position + Vector2(10, 0)
	instancedLabel.text = str(snapped(amount, 0.01))
	
	# Might use later if changing label color depending on
	#if isAmountOffensive():
	#	instancedLabel.modulate = Color(1, 0, 0)
	#else:
	#	instancedLabel.modulate = Color(0, 1, 0)
	
	tween.set_parallel(true)
	tween.tween_property(instancedLabel, "position", instancedLabel.global_position - Vector2(-150, -150), 3)
	await tween.tween_property(instancedLabel, "modulate", Color(1, 1, 1, 0), 2).finished
	instancedLabel.queue_free()
	
