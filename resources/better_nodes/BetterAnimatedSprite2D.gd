extends AnimatedSprite2D
class_name BetterAnimatedSprite2D

var animation_queue: Array

signal current_animation_finished(anim_name)

func _ready() -> void:
	connect("animation_finished", _on_animation_finished)
	connect("current_animation_finished", _on_current_animation_finished)

# animation finish signal
func _on_animation_finished() -> void:
	emit_signal("current_animation_finished", animation)
	play_queue()

func _on_current_animation_finished(anim_name: String) -> void:
	print("Finished animation: ", anim_name)

# animation queue
func queue(anim_name: String) -> void:
	animation_queue.push_back(anim_name)

func play_queue() -> void:
	if !animation_queue.is_empty():
		var anim: String = animation_queue.pop_front()
		play(anim)
	else:
		print("No animations in queue.")

func clear_queue() -> void:
	animation_queue.clear()
	print("Animation queue cleared.")
