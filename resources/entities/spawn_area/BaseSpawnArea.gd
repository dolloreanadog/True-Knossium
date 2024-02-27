extends ReferenceRect
class_name BaseSpawnArea

func _ready():
	pass

func randomizeSpawn() -> Vector2:
	var area = self
	var Lposition = area.global_position + Vector2(randf() * area.size.x, randf() * area.size.y)
	
	return Lposition
