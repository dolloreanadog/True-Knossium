extends Polygon2D

@export_color_no_alpha var lineColor

func _ready() -> void:
	pass

func _draw() -> void:
	var array: Array = polygon
	array.append(polygon[0])
	draw_polyline(array, lineColor, 10, false)
