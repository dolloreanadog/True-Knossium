extends CharacterBody2D
class_name BaseCharacter

#--[ Some important stuff ]--
@export var id: String
var characterName: String
@export var profilePicture: Texture2D
@export_multiline var characterDescription: String
@onready var partyContainer: BasePartyContainer = get_parent()
@onready var dungeon: BaseLevel = partyContainer.dungeon
var system: TurnSystem
var inventory: InventorySystem
@export var stats: StatComponent
@export var idleAnimationCount: int = 1
## This will be used so that bigger enemies will usually appear behind smaller enemies
@export var z_index_order: int = 0

var trueGlobalPosition: Vector2

@onready var levelLabel: Label = get_node("LevelLabel")
@onready var characterSprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var characterAnimation: AnimationPlayer = get_node("AnimationPlayer")
var isFriendly: bool = true
@export_category("Resource Drop")
@export var ResourceNeeded: BaseInventoryItem # We still don't know how or what variable it's as
@export var ResourceNeededNumber: int
@export var ResourceDrop: BaseInventoryItem
@export var ResourceMaxDropAmount: int
var turns: int

@export_category("Music")
@export var characterThemeMusic: AudioStream
@export var characterMusicPriority: int
#--[ Effects ]--
# This video https://www.youtube.com/watch?v=vzRZjM9MTGw
# add a if null statement so we don't crash
# With this we can add more functions, SFX, VFX, & More
# Like if I were to make a shield break VFX just for that character, I just attach it to that resource
@export_category("Effects")
@export var isUnlockable: bool = true
@export var levelUpFX: BaseFX
@export var healthDeathFX: BaseFX
@export var defenseDeathFX: BaseFX
@export var attackDeathFX: BaseFX
@export var moraleDeathFX: BaseFX
@export var overHealthFX: BaseFX
@export var overDefenseFX: BaseFX
@export var overAttackFX: BaseFX
@export var overMoraleFX: BaseFX
@export var healthChangedFX: BaseStatChangedFX
@export var defenseChangedFX: BaseStatChangedFX
@export var attackChangedFX: BaseStatChangedFX
@export var moraleChangedFX: BaseStatChangedFX

#--[ Actions ]--
@export_category("Actions")
@export var action1: BaseActionComponent
@export var action2: BaseActionComponent
@export var action3: BaseActionComponent
@export var action4: BaseActionComponent

#--[ Signal ]--
signal characterAnimationFinished

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

func damageStats(health, defense, attack, morale): # Print out the stats of getting damage
	print(str(self) + ": Body is getting Damaged")
	print(str(self) + ": Health stat being damaged for " + str(health))
	print(str(self) + ": Defense stat being damaged for " + str(defense))
	print(str(self) + ": Attack stat being damaged for " + str(attack))
	print(str(self) + ": Morale stat being damaged for " + str(morale))
	#stats.isDamaged()
	stats.changeCurrentHealth(health)
	stats.changeCurrentDefense(defense)
	stats.changeCurrentAttack(attack)
	stats.changeCurrentMorale(morale)

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

func activateLevelLabel(boolean: bool):
	#print(str(self) + ": activated Level Label: " + str(boolean))
	levelLabel.set_visible(boolean)

func updateLevelLabel():
	levelLabel.set_text(str(stats.level))

# Make sure these are all called in the Stat Component

#--[ FX ]--

func playLevelUpFX():
	levelUpFX.playFX()

func playhealthDeathFX():
	#print("Should run Health Death playFX")
	if isUnlockable:
		unlockCharacter()
		unlockItem()
	healthDeathFX.playFX()

func playDefenseDeathFX():
	#print("Should run Defense Death playFX")
	defenseDeathFX.playFX()

func playAttackDeathFX():
	attackDeathFX.playFX()

func playMoraleDeathFX():
	if isUnlockable:
		unlockCharacter()
		unlockItem()
	moraleDeathFX.playFX()

func playOverHealthFX():
	overHealthFX.playFX()

func playOverDefenseFX():
	overDefenseFX.playFX()

func playOverAttackFX():
	overAttackFX.playFX()

func playOverMorale():
	overMoraleFX.playFX()

func playHealthChangedFX(amount: float):
	healthChangedFX.setAmountChanged(amount)
	healthChangedFX.playFX()

func playDefenseChangedFX(amount: float):
	defenseChangedFX.setAmountChanged(amount)
	defenseChangedFX.playFX()

func playAttackChangedFX(amount: float):
	attackChangedFX.setAmountChanged(amount)
	attackChangedFX.playFX()

func playMoraleChangedFX(amount: float):
	moraleChangedFX.setAmountChanged(amount)
	moraleChangedFX.playFX()

#--[ Animation ]--

## When spawning choose an idle animation or new Turn happens
func idleAnimation():
	await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
	playAnimation("idle" + str(randi_range(1, idleAnimationCount)))

# The new way to do attack animation
# When AOE is used it either choose attack animation, special attack animation, buff animation, defense animation

func getAnimation():
	return characterAnimation.get_current_animation()

func playAnimation(anim_name: String) -> void:
	if characterAnimation.current_animation != "death":
		characterAnimation.play(anim_name)

func QueueAnimation(anim_name: String) -> void:
	if characterAnimation.current_animation != "death" && !characterAnimation.get_queue().has("death"):
		characterAnimation.queue(anim_name)

func GetAnimationPlayed(anim_name: StringName):
	AnimationIsDeath(anim_name)

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
			dungeon.warningLabel.text = ""
		else:
			dungeon.warningLabel.text = "We Ran out of " + str(ResourceNeeded.itemName)
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

func unlockCharacter():
	print("Unlocked Character")
	var characterFilePath := self.scene_file_path
	Global.unlockCharacter(characterFilePath)

func unlockItem():
	print("Unlocked Item")
	var itemFilePath := ResourceNeeded.resource_path
	Global.unlockItem(itemFilePath)
