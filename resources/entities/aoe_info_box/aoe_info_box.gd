extends Control
class_name AOEInfoBox

@onready var dungeon = get_parent()

@onready var characterPFPHolder: TextureRect = $characterPFPTexture
@onready var characterNameLabel: Label = $CharacterNameLabel
@onready var AOENameLabel: Label = $AOENameLabel
@onready var descriptionLabel: Label = $Description
@onready var AOEHealthDamageLabel: Label = $AOEHealthDamageLabel
@onready var AOEDefenseDamageLabel: Label = $AOEDefenseDamageLabel
@onready var AOEAttackDamageLabel: Label = $AOEAttackDamageLabel
@onready var AOEMoraleDamageLabel: Label = $AOEMoraleDamageLabel
@onready var AOEAccuracyLabel: Label = $AOEAccuracyLabel
@onready var AOEIsMeleeLabel: Label = $AOEIsMeleeLabel
@onready var AOEIsMovableLabel: Label = $IsMovableLabel

var characterPFP: Texture2D
var characterName: String
var AOEName: String
var description: String
var accuracyValue: float
var healthDamageValue: float
var defenseDamageValue: float
var attackDamageValue: float
var moraleDamageValue: float
var isMeleeValue: bool
var isMovableValue: bool

func _ready():
	placeholderAOEInfo()
	

func placeholderAOEInfo():
	characterPFPHolder.texture = ImageTexture.new()
	characterNameLabel.text = ""
	AOENameLabel.text = ""
	descriptionLabel.text = ""
	AOEHealthDamageLabel.text = ""
	AOEDefenseDamageLabel.text = ""
	AOEAttackDamageLabel.text = ""
	AOEMoraleDamageLabel.text = ""
	AOEAccuracyLabel.text = ""
	AOEIsMeleeLabel.text = ""
	AOEIsMovableLabel.text = ""

func insertAOEInfo():
	characterPFPHolder.texture = characterPFP
	characterNameLabel.text = "Owner: " + str(characterName)
	AOENameLabel.text = AOEName
	descriptionLabel.text = description
	if descriptionLabel.get_total_character_count() > 250:
		push_warning("AOE description exceeds 250 characters")

	if healthDamageValue == 0:
		AOEHealthDamageLabel.text = "Nothing to Health!" # Maybe to avoid wrong coloration, move this above
		AOEHealthDamageLabel.set_modulate(Color(1, 1, 1))
	elif healthDamageValue < 0:
		AOEHealthDamageLabel.text = "Health Damage: " + str(snapped(healthDamageValue, 0.01))
		AOEHealthDamageLabel.set_modulate(Color(1, 0, 0))
	else:
		AOEHealthDamageLabel.text = "Health Heal: " + str(snapped(healthDamageValue, 0.01))
		AOEHealthDamageLabel.set_modulate(Color(0, 1, 0))
	
	if defenseDamageValue == 0:
		AOEDefenseDamageLabel.text = "Nothing to Defense!"
		AOEDefenseDamageLabel.set_modulate(Color(1, 1, 1))
	elif defenseDamageValue < 0:
		AOEDefenseDamageLabel.text = "Defense Debuff: " + str(snapped(defenseDamageValue, 0.01))
		AOEDefenseDamageLabel.set_modulate(Color(1, 0, 0))
	else:
		AOEDefenseDamageLabel.text = "Defense Buff: " + str(snapped(defenseDamageValue, 0.01))
		AOEDefenseDamageLabel.set_modulate(Color(0, 1, 0))
	
	
	if attackDamageValue == 0:
		AOEAttackDamageLabel.text = "Nothing to Attack!"
		AOEAttackDamageLabel.set_modulate(Color(1, 1, 1))
	elif attackDamageValue < 0:
		AOEAttackDamageLabel.text = "Attack Debuff: " + str(snapped(attackDamageValue, 0.01))
		AOEAttackDamageLabel.set_modulate(Color(1, 0, 0))
	else:
		AOEAttackDamageLabel.text = "Attack Buff: " + str(snapped(attackDamageValue, 0.01))
		AOEAttackDamageLabel.set_modulate(Color(0, 1, 0))
	
	if moraleDamageValue == 0:
		AOEMoraleDamageLabel.text = "Nothing to Morale!"
		AOEMoraleDamageLabel.set_modulate(Color(1, 1, 1))
	elif moraleDamageValue < 0:
		AOEMoraleDamageLabel.text = "Morale Debuff: " + str(snapped(moraleDamageValue, 0.01))
		AOEMoraleDamageLabel.set_modulate(Color(1, 0, 0))
	else:
		AOEMoraleDamageLabel.text = "Morale Buff: " + str(snapped(moraleDamageValue, 0.01))
		AOEMoraleDamageLabel.set_modulate(Color(0, 1, 0))
	
	
	AOEAccuracyLabel.text = "Accuracy: " + str(snapped(abs(100 * (1 - (accuracyValue/(3 + accuracyValue)))), 0.01)) + "%"
	
	if isMeleeValue:
		AOEIsMeleeLabel.text = "It's a melee attack"
	else:
		AOEIsMeleeLabel.text = "It's not a melee attack"
		
	if isMovableValue:
		AOEIsMovableLabel.text = "It's movable"
		AOEIsMovableLabel.set_modulate(Color(0, 1, 0))
	else:
		AOEIsMovableLabel.text = "It's not movable"
		AOEIsMovableLabel.set_modulate(Color(1, 0, 0))
