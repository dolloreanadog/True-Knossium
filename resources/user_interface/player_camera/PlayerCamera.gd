extends CharacterBody2D
# Don't worry about getting out of map, we'll add a border
# Or we completely remove the moving part so ummm


var allowMovement: bool = true
@export var speed: int = 100
@export var maxSpeed: int = 200

func _ready():
	pass

func get_input():
	var input_direction = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	velocity = input_direction * speed
	
	if Input.is_action_just_pressed("RESETPOSITION"):
		self.set_position(Vector2(576, 328))

func _physics_process(delta):
	get_input()
	velocity *= delta * maxSpeed
	move_and_slide()

func switchAllowMovement():
	pass
