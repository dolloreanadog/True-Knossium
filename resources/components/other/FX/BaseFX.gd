extends Node
## <- Doing this can give info on it
class_name BaseFX

#--[ Need info from these ]--
@export var stats: StatComponent


## Either a Sprite2D or AnimatedSprite2D
@export var sprite: Node2D
## Will contain Audio
@export var audio: AudioStream

@export var audioStreamPlayer: AudioStreamPlayer2D
@onready var character: BaseCharacter = get_parent()

# These are not final, should be changed for each character
# An outline, for the final FX

func _ready():
	character.connect("characterAnimationFinished", animationFinished)

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
	pass
	#if sprite != null:
	#	pass
	#else:
	#	push_warning("There is no sprite!")

func animationFinished():
	pass
