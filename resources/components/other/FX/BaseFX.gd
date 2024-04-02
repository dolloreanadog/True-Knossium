extends Node
## <- Doing this can give info on it
class_name BaseFX

# Note: Make sure to set VFX to inactive


#--[ Need info from these ]--
## Try not to use this use (character.stats) instead
#@export var stats: StatComponent


## Either a Sprite2D or AnimatedSprite2D
@export var sprite: AnimatedSprite2D
## Will contain Audio
@export var audio: AudioStream

@export var audioStreamPlayer: AudioStreamPlayer2D
@onready var character: BaseCharacter = get_parent()

# These are not final, should be changed for each character
# An outline, for the final FX

func _ready():
	pass

## Plays both Sound Effect & Visual Effect & Handles Stat Calculation
func playFX():
	playSFX()
	playVFX()

## Handles Sound Effects
func playSFX():
	if audio != null:
		audioStreamPlayer.set_stream(audio)
		print(audioStreamPlayer)
		audioStreamPlayer.play()
#	else:
#		push_warning("There is no AudioStream!")

## Handles Visual Effects
func playVFX():
	pass
	#if sprite != null:
	#	pass
	#else:
	#	push_warning("There is no sprite!")

