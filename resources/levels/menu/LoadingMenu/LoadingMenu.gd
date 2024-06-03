extends Control
class_name LoadingScreen

var keepLoading: bool = false
var nextScene: String

func smoothStartLoadingMenu() -> void:
	self.modulate = Color(1, 1, 1, 0)
	var tween: Tween = create_tween()
	await tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25).finished

func RemoveLoadingMenu() -> void:
	print("Removing Loading Menu")
	var tween: Tween = create_tween()
	await tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.25).finished
	self.queue_free()
