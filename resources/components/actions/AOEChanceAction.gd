extends BaseActionComponent
class_name AOEChanceActionComponent

@export_range(0, 1, 0.01) var chance: float = 1

func removeCastTime() -> void:
	if randf_range(0, 1) >= chance:
		currentCastTime -= 1
		print(str(self) + ": Cast Time Going Down")
		onCastTimeMinimum()

