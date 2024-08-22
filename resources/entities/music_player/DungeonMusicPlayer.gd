extends AudioStreamPlayer
class_name DungeonMusicPlayer

@export var dungeon: BaseLevel

@export var DefaultMusic: AudioStream
var isPlayingDefaultMusic: bool = true

@export var characterMusic: AudioStream
var currentCharacterMusicPriority: int

@export var winningMusic: AudioStream
@export var losingMusic: AudioStream
@export var canPlayLosingMusic: bool = true

@export var dangerLevel: float
@export var dangerLevelQuartile: int

#--[ Base Functions ]--
func _ready() -> void:
	connect("finished", musicFinished)
	playDefaultMusic()

func musicFinished() -> void:
	updateDangerLevel()

# Initiate a check
func playDefaultMusic() -> void:
	print(str(self) + ": Playing Level Music")
	isPlayingDefaultMusic = true
	currentCharacterMusicPriority = 0
	PlayMusic(DefaultMusic)

# change this to set character music & create a new playCharacterMusic
func playCharacterMusic() -> void:
	print(str(self) + ": Playing Character Music")
	PlayMusic(characterMusic)


func playWinningMusic() -> void:
	print(str(self) + ": Playing Winning Music")
	isPlayingDefaultMusic = true
	currentCharacterMusicPriority = 0
	PlayMusic(winningMusic)


func playLosingMusic() -> void:
	print(str(self) + ": Playing Losing Music")
	if canPlayLosingMusic:
		isPlayingDefaultMusic = false
		currentCharacterMusicPriority = 0
		PlayMusic(losingMusic)
	else:
		push_warning("Cannot Play Danger Music as it is disabled!")

func setCanPlayDangerMusic(boolean: bool) -> void:
	canPlayLosingMusic = boolean

#--[ Danger Music Functions ]--
# In this part if enemy is 100% higher than player current stats

# if dangerLevel stays the same area, don't restart the music.
func updateDangerLevel() -> void:
	dangerLevel = clampf(dungeon.enemyPartyContainer.currentTotalStatPoints / dungeon.friendlyPartyContainer.currentTotalStatPoints, 0, 4)
	print(str(self) + ": danger level is at " + str(dangerLevel * 100) + "%")
	# print(str(self) + ": ")
	if dangerLevel > 3:
		print(str(self) + ": danger level quartile is " + str(dangerLevelQuartile))
		if dangerLevelQuartile != 1:
			playLosingMusic()
		dangerLevelQuartile = 1
	elif dangerLevel <= 3 && dangerLevel > 1.15:
		print(str(self) + ": danger level quartile is " + str(dangerLevelQuartile))
		if dangerLevelQuartile != 2:
			playCharacterMusic()
		dangerLevelQuartile = 2
	elif dangerLevel <= 1.15 && dangerLevel > 0.25:
		print(str(self) + ": danger level quartile is " + str(dangerLevelQuartile))
		if dangerLevelQuartile != 3:
			playDefaultMusic()
		dangerLevelQuartile = 3
	elif  dangerLevel <= 0.25 && dangerLevel >= 0:
		print(str(self) + ": danger level quartile is " + str(dangerLevelQuartile))
		if dangerLevelQuartile != 4:
			playWinningMusic()
		dangerLevelQuartile = 4
	else:
		push_error("Danger Level out of scope, danger level is " + str(dangerLevel))

#--[ Set Music Functions ]--

# This Function will be used in the basePartyContainer
func setCharacterMusic(music: AudioStream, priority: int) -> void:
	# Priority will be helpful, when we want to have the more scarier monsters to have priority
	# We can also have it so add up all music priority of each duplicate characters to match the song
	# if there are 5 slimes -> 1 + 1 + 1 + 1 + 1
	# 1 skeleton -> 3
	# 5 > 3
	
	if is_instance_valid(music):
		if priority > currentCharacterMusicPriority:
			isPlayingDefaultMusic = false
			currentCharacterMusicPriority = priority
			characterMusic = music
	else:
		playDefaultMusic() 

func PlayMusic(music: AudioStream) -> void:
	if is_instance_valid(stream) && is_instance_valid(music):
#		print("old music: " + str(stream.resource_path))
#		print("new music: " + str(music.resource_path))
#		print("music playing")
		if music.resource_path != stream.resource_path or !is_playing():
			await create_tween().tween_property(self, "volume_db", -80, 1).finished
			stop()
			set_stream(music)
			play()
			create_tween().tween_property(self, "volume_db", 0, 1)
	elif !is_playing():
		print(str(self) + ": No valid character music, playing default.")
		await create_tween().tween_property(self, "volume_db", -80, 1).finished
		stop()
		set_stream(DefaultMusic)
		play()
		create_tween().tween_property(self, "volume_db", 0, 1)
