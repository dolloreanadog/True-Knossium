extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	print("Hello?")
	animation_player.play("default")

func Ended() -> void:
	print("ending")
	queue_free()
