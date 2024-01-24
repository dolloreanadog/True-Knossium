extends ReferenceRect
class_name BaseSpawnArea

func _ready():
	pass

func randomizeSpawn():
	var area = self
	var Lposition = area.position + Vector2(randf() * area.size.x, randf() * area.size.y)
	
	return Lposition
