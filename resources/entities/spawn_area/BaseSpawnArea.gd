extends ReferenceRect
class_name BaseSpawnArea

func _ready():
	pass

func randomizeSpawn() -> Vector2:
	var area = self
	var Lposition = area.global_position + Vector2(randf() * area.size.x, randf() * area.size.y)
	
	return Lposition

func AnyAOEAnimationPlaying() -> bool:
	var playing: bool
	if get_child_count() == 0:
		playing = get_children().any(func(object: BaseAOE): return object.spriteAnimations.is_playing())
	return playing
