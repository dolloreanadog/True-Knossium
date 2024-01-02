extends Area2D
# Notes: CharacterBody2D is the better solution due to us having to move the character in an animation
# Detect Character Collider for AOE & applying damage
# Detect Area for setting position back to where it was
# We probably when moving AOE get it's original location so we can teleport it back there

# Collision for Static & Character Body will get their parent
# Collision for area will obviously get the area


func _ready():
	pass

func _process(delta):
	var overlappingAreaArray: Array
	var overlappingBodiesArray: Array
	overlappingAreaArray = get_overlapping_areas()
	overlappingBodiesArray = get_overlapping_bodies()
	print(overlappingBodiesArray)
	print(overlappingAreaArray)
