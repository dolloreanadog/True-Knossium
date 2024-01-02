extends Node
## <- Doing this can give info on it
class_name BaseFX

## Either a Sprite2D or AnimatedSprite2D
@export var sprite: Node2D
## Will contain Audio
@export var audio: AudioStream

@onready var audioStreamPlayer: AudioStreamPlayer2D = get_node("AudioStreamPlayer2D")

func _ready():
	pass

## Plays both Sound Effect & Visual Effect
func playFX():
	playSFX()
	playVFX()

func playSFX():
	if audio != null:
		audioStreamPlayer.set_stream(audio)
		print(audioStreamPlayer)
		audioStreamPlayer.play()
	else:
		push_warning("There is no AudioStream!")

func playVFX():
	if sprite != null:
		pass
	else:
		push_warning("There is no sprite!")

