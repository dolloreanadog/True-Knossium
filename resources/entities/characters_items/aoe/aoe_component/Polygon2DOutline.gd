extends Node2D
class_name polygon2DOutline

@onready var polygon2D: Polygon2D = get_parent()
@export_range(0, 10, 0.01) var lineWidth: float = 1
@export_color_no_alpha var lineColor: Color = Color(Color.BLACK)

func _draw() -> void:
	var array: Array = polygon2D.polygon
	array.append(polygon2D.polygon[0])
	draw_polyline(array, lineColor, lineWidth, false)
