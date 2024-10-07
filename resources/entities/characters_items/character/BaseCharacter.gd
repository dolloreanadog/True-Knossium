extends CharacterBody2D
class_name BaseCharacter

#--[ Some important stuff ]--
## Name of the character
@export var id: String
var characterName: String
## A PNG of what the character appear in the party of New Start Menu, not the game
@export var profilePicture: Texture2D
## Describe the character
@export_multiline var characterDescription: String
@onready var partyContainer: BasePartyContainer = get_parent()
@onready var dungeon: BaseLevel = partyContainer.dungeon
var system: TurnSystem
var inventory: InventorySystem
## Attach the StatComponent here
@export var stats: StatComponent
## Put the amount of Animations here, there needs to be at least & doesn't have multiple frames
@export var idleAnimationCount: int = 1
## This will be used so that bigger enemies will usually appear behind smaller enemies
@export var z_index_order: int = 0

var trueGlobalPosition: Vector2

@onready var levelLabel: Label = get_node("LevelLabel")
@onready var characterSprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var characterAnimation: AnimationPlayer = get_node("AnimationPlayer")
var isFriendly: bool = true
@export_category("Resource Drop")
## Every character needs an inventory item / upkeep
@export var ResourceNeeded: BaseInventoryItem # We still don't know how or what variable it's as
## How many of items it needs per
@export var ResourceNeededNumber: int
## See what it drops, if you want to have additional resources, use ExtraResourceDropComponent
@export var ResourceDrop: BaseInventoryItem
## How much it drops, if you want to have additional resources, use ExtraResourceDropComponent
@export var ResourceMaxDropAmount: int
var turns: int

@export_category("Music")
## What music will play if the character has the chance in the game's music player
@export var characterThemeMusic: AudioStream
## Higher priority music will always play before those lower
@export var characterMusicPriority: int
#--[ Effects ]--
# This video https://www.youtube.com/watch?v=vzRZjM9MTGw
# add a if null statement so we don't crash
# With this we can add more functions, SFX, VFX, & More
# Like if I were to make a shield break VFX just for that character, I just attach it to that resource
@export_category("Effects")
## See if this character can be unlocked by the player
@export var isUnlockable: bool = true
## Attach corresponding effect in here
@export var levelUpFX: BaseFX
## Attach corresponding effect in here
@export var healthDeathFX: BaseFX
## Attach corresponding effect in here
@export var defenseDeathFX: BaseFX
## Attach corresponding effect in here
@export var attackDeathFX: BaseFX
## Attach corresponding effect in here
@export var moraleDeathFX: BaseFX
## Attach corresponding effect in here
@export var overHealthFX: BaseFX
## Attach corresponding effect in here
@export var overDefenseFX: BaseFX
## Attach corresponding effect in here
@export var overAttackFX: BaseFX
## Attach corresponding effect in here
@export var overMoraleFX: BaseFX
## Attach corresponding effect in here
@export var healthChangedFX: BaseStatChangedFX
## Attach corresponding effect in here
@export var defenseChangedFX: BaseStatChangedFX
## Attach corresponding effect in here
@export var attackChangedFX: BaseStatChangedFX
## Attach corresponding effect in here
@export var moraleChangedFX: BaseStatChangedFX

#--[ Actions ]--
@export_category("Actions")
## Attach an action component here
@export var action1: BaseActionComponent
## Attach an action component here
@export var action2: BaseActionComponent
## Attach an action component here
@export var action3: BaseActionComponent
## Attach an action component here
@export var action4: BaseActionComponent

#--[ Signal ]--
#signal characterAnimationFinished
signal CharacterDied

#--[ Base Functions ]--
func _ready() -> void:
	print("(check) party container dungeon = " + str(partyContainer.dungeon))
	characterName = id
	system = dungeon.system
	inventory = dungeon.inventory
	z_index = z_index_order
	activateLevelLabel(false)
	print("TurnSystem: " + str(system))
	dungeon.connect("AOEQueueFinished", characterNewTurn) # Instead of this use Dungeon's Queue Signal
	system.connect("OnNewBattle", characterNewBattle)
	
	playAnimation("idle1")
	if ResourceNeeded == null && ResourceNeededNumber > 0:
		push_error(str(self) + " Resource is empty")

## Damage the Stats in the StatComponent
func damageStats(health, defense, attack, morale): # Print out the stats of getting damage
#	print(str(self) + ": Body is getting Damaged")
#	print(str(self) + ": Health stat being damaged for " + str(health))
#	print(str(self) + ": Defense stat being damaged for " + str(defense))
#	print(str(self) + ": Attack stat being damaged for " + str(attack))
#	print(str(self) + ": Morale stat being damaged for " + str(morale))
	#stats.isDamaged()
	stats.changeCurrentHealth(health)
	stats.changeCurrentDefense(defense)
	stats.changeCurrentAttack(attack)
	stats.changeCurrentMorale(morale)

## Remove time from all actions cast times
func useActions():
	if dungeon.difficulty.isCharactersSpawningIn != true:
		if stats.alreadyDied != true && stats.moraleAlreadyBroken != true:
			if action1 != null:
				action1.removeCastTime()
				action1.getAttackInfo()
			if action2 != null:
				action2.removeCastTime()
				action2.getAttackInfo()
			if action3 != null:
				action3.removeCastTime()
				action3.getAttackInfo()
			if action4 != null:
				action4.removeCastTime()
				action4.getAttackInfo()

#--[ Level Label ]--

## make level Label visible
func activateLevelLabel(boolean: bool):
	#print(str(self) + ": activated Level Label: " + str(boolean))
	levelLabel.set_visible(boolean)

## update level Label
func updateLevelLabel():
	levelLabel.set_text(str(stats.level))

# Make sure these are all called in the Stat Component

#--[ FX ]--

## Whenever a character levels up play an effect
func playLevelUpFX():
	levelUpFX.playFX()

## Whenever the character has no health, play an effect
func playhealthDeathFX():
	#print("Should run Health Death playFX")
	if isUnlockable:
		unlockCharacter()
		unlockItem()
	CharacterDied.emit()
	healthDeathFX.playFX()

## Whenever the character has minimum defense, play an effect
func playDefenseDeathFX():
	#print("Should run Defense Death playFX")
	defenseDeathFX.playFX()

## Whenever the character has minimum attack, play an effect
func playAttackDeathFX():
	attackDeathFX.playFX()

## Whenever the character has no morale, play an effect
func playMoraleDeathFX():
	if isUnlockable:
		unlockCharacter()
		unlockItem()
	moraleDeathFX.playFX()

## Whenever the character has over health, play an effect
func playOverHealthFX():
	overHealthFX.playFX()

## Whenever the character has over defense, play an effect
func playOverDefenseFX():
	overDefenseFX.playFX()

## Whenever the character has over attack, play an effect
func playOverAttackFX():
	overAttackFX.playFX()

## Whenever the character has over morale, play an effect
func playOverMorale():
	overMoraleFX.playFX()

## Whenever the character has health changed, play an effect
func playHealthChangedFX(amount: float):
	healthChangedFX.setAmountChanged(amount)
	healthChangedFX.playFX()

## Whenever the character has defense changed, play an effect
func playDefenseChangedFX(amount: float):
	defenseChangedFX.setAmountChanged(amount)
	defenseChangedFX.playFX()

## Whenever the character has attack changed, play an effect
func playAttackChangedFX(amount: float):
	attackChangedFX.setAmountChanged(amount)
	attackChangedFX.playFX()

## Whenever the character has morale changed, play an effect
func playMoraleChangedFX(amount: float):
	moraleChangedFX.setAmountChanged(amount)
	moraleChangedFX.playFX()

#--[ Animation ]--

## When spawning choose an idle animation or new Turn happens
func idleAnimation():
	await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
	playAnimation("idle" + str(randi_range(1, idleAnimationCount)))

## Get the animation of the character
func getAnimation():
	return characterAnimation.get_current_animation()

## Use this whenever playing animation, DO NOT USE characterAnimation.play() DIRECTLY
func playAnimation(anim_name: String) -> void:
	if characterAnimation.current_animation != "death":
		characterAnimation.play(anim_name)

## Use this whenever playing animation, DO NOT USE characterAnimation.queue() DIRECTLY
func QueueAnimation(anim_name: String) -> void:
	if characterAnimation.current_animation != "death" && !characterAnimation.get_queue().has("death"):
		characterAnimation.queue(anim_name)

## Gets the recent animation that was played
func GetAnimationPlayed(anim_name: StringName):
	AnimationIsDeath(anim_name)

## If the animation was death, free the character
func AnimationIsDeath(anim_name: StringName):
#	push_error("anim_name = " + anim_name)
	if anim_name == "death":
#		push_error("Character has died")
		queue_free()
		stats.emit_signal("death", stats.worthEXP, stats.characterBody)
		# ^ Something wrong with connection on Aqua Part

#--[ Extra ]--

## Get a Signal from the turnSystem to do this
func characterNewTurn():
	#print(str(self) + ": (L) Received Signal") # We're receiving the signal Twice?
	useActions()
	if partyContainer.isFriendly:
		if inventory.getNamedItemAmount(ResourceNeeded.itemName) > 0:
			inventory.removeFromInventory(ResourceNeeded, ResourceNeededNumber)
#			dungeon.warningLabel.text = ""
		else:
			dungeon.warningLabel.StartDisplay("We Ran out of " + str(ResourceNeeded.itemName))
			match randi_range(0, 1):
				1:
					stats.changeCurrentMorale(-999)
				2:
					stats.changeCurrentHealth(-999)
	playAnimation("idle1")

func characterNewBattle():
	pass
#	Wanted to see how the game would be if it were to transfer buffs from previous game
#	stats.resetCurrentStats()

# Idk why we have this, we'll see what this means
# ^ Determines if to spawn AOE or not
# Have the party container run a loop to use this function on all children
func changeFriendliness(boolean: bool):
	isFriendly = boolean

## Unlock the character
func unlockCharacter():
	print("Unlocked Character")
	var characterFilePath := self.scene_file_path
	Global.unlockCharacter(characterFilePath)

## Unlock the item
func unlockItem():
	print("Unlocked Item")
	var itemFilePath := ResourceNeeded.resource_path
	Global.unlockItem(itemFilePath)
	
