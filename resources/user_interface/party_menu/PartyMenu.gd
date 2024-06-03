extends Control
class_name PartyMenu

#--[ Some other important nodes ]--
@export var partyContainer: BasePartyContainer
@onready var dungeon: BaseLevel = get_parent()

#--[ ItemList ]--
@onready var characterList: ItemList = get_node("ColorRect/CharacterList")
@onready var upkeepList: ItemList = get_node("ColorRect/UpkeepList")
var upkeepListArray: Array


#--[ Important Character Info ]--
@onready var characterPFPHolder: TextureRect = get_node("ColorRect/Panel/CharacterPFPHolder")
@onready var characterNameLabel: Label = get_node("ColorRect/Panel/CharacterNameLabel")
@onready var characterLevelLabel: Label = get_node("ColorRect/Panel/LevelLabel")
@onready var characterExperienceLabel: Label = get_node("ColorRect/Panel/ExperienceLabel")
@onready var characterClassLabel: Label = get_node("ColorRect/Panel/ClassLabel")

#--[ StatComponent Stats ]--
@onready var HealthStatLabel: Label = get_node("ColorRect/Panel/StatPanel/HBoxContainer/HealthStatContainer/HealthStatLabel")
@onready var DefenseStatLabel: Label = get_node("ColorRect/Panel/StatPanel/HBoxContainer/DefenseStatContainer/DefenseStatLabel")
@onready var AttackStatLabel: Label = get_node("ColorRect/Panel/StatPanel/HBoxContainer/AttackStatContainer/AttackStatLabel")
@onready var MoraleStatLabel: Label = get_node("ColorRect/Panel/StatPanel/HBoxContainer/MoraleStatContainer/MoraleStatLabel")

#--[ Action ]--
@onready var Action1NameLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer/Action1Label")
@onready var Action1HealthLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer/ActionHealthLabel")
@onready var Action1DefenseLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer/ActionDefenseLabel")
@onready var Action1AttackLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer/ActionAttackLabel")
@onready var Action1MoraleLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer/ActionMoraleLabel")

@onready var Action2NameLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer2/Action2Label")
@onready var Action2HealthLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer2/ActionHealthLabel")
@onready var Action2DefenseLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer2/ActionDefenseLabel")
@onready var Action2AttackLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer2/ActionAttackLabel")
@onready var Action2MoraleLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer2/ActionMoraleLabel")

@onready var Action3NameLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer3/Action3Label")
@onready var Action3HealthLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer3/ActionHealthLabel")
@onready var Action3DefenseLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer3/ActionDefenseLabel")
@onready var Action3AttackLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer3/ActionAttackLabel")
@onready var Action3MoraleLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer3/ActionMoraleLabel")

@onready var Action4NameLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer4/Action4Label")
@onready var Action4HealthLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer4/ActionHealthLabel")
@onready var Action4DefenseLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer4/ActionDefenseLabel")
@onready var Action4AttackLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer4/ActionAttackLabel")
@onready var Action4MoraleLabel: Label = get_node("ColorRect/Panel/ActionPanel/HBoxContainer/VboxContainer4/ActionMoraleLabel")

#--[ Item Stuff ]--
@onready var UpkeepNameLabel: Label = get_node("ColorRect/Panel/UpkeepPanel/UpkeepLabel")
@onready var UpkeepAmountLabel: Label = get_node("ColorRect/Panel/UpkeepPanel/UpkeepAmount")

@onready var DropNameLabel: Label = get_node("ColorRect/Panel/DropPanel/DropsLabel")
@onready var DropAmount: Label = get_node("ColorRect/Panel/DropPanel/DropsAmount")

#--[ Description ]--
@onready var characterDescription: Label = get_node("ColorRect/Panel/DescriptionPanel/DescriptionLabel")

#--[ Cool Stuff ]--
var targetCharacter: BaseCharacter

#--[ Functions ]--

#--[ UI Functions ]--
func _ready() -> void:
	characterPFPHolder.texture = ImageTexture.new()
	characterNameLabel.text = ""
	characterLevelLabel.text = "Level: "
	characterExperienceLabel.text = "Experience: "
	characterClassLabel.text = "Role: "
	HealthStatLabel.text = ""
	DefenseStatLabel.text = ""
	AttackStatLabel.text = ""
	MoraleStatLabel.text = ""
	
	Action1NameLabel.text = ""
	Action1HealthLabel.text = ""
	Action1DefenseLabel.text = ""
	Action1AttackLabel.text = ""
	Action1MoraleLabel.text = ""
	
	Action2NameLabel.text = ""
	Action2HealthLabel.text = ""
	Action2DefenseLabel.text = ""
	Action2AttackLabel.text = ""
	Action2MoraleLabel.text = ""
	
	Action3NameLabel.text = ""
	Action3HealthLabel.text = ""
	Action3DefenseLabel.text = ""
	Action3AttackLabel.text = ""
	Action3MoraleLabel.text = ""
	
	Action4NameLabel.text = ""
	Action4HealthLabel.text = ""
	Action4DefenseLabel.text = ""
	Action4AttackLabel.text = ""
	Action4MoraleLabel.text = ""
	
	UpkeepNameLabel.text = "Upkeep: "
	UpkeepAmountLabel.text = ""
	
	DropNameLabel.text = "Drops: "
	DropAmount.text = ""
	
	characterDescription.text = ""
	

func _on_exit_button_pressed() -> void:
	if dungeon.isCharactersActive != true && dungeon.specialWindowContainer.get_child_count() == 0 && dungeon.difficulty.isCharactersSpawningIn != true && dungeon.knossiumConsole.visible == false:
		print("(check3) isCharactersActive " + str(dungeon.isCharactersActive))
		print("(check3) get_child_count " + str(dungeon.specialWindowContainer.get_child_count()))
		print("(check3) isCharactersSpawningIn " + str(dungeon.difficulty.isCharactersSpawningIn))
		dungeon.stopControlVisible(false, 1)
		dungeon.stopControlVisible(false, 2)
	dungeon.partyButton.disabled = false
#	dungeon.checkSpecialWindowContainer()
#	get_parent().stopControl.hide()
	self.hide()


func _on_character_list_item_selected(index: int) -> void:
	targetCharacter = partyContainer.characters[index]
	updateCharacterInfo()

#--[ Handler Walter ]--

## Updates the ItemList (CharacterList) to current
func updateCharacterList() -> void:
	characterList.clear()
	for i in partyContainer.characters.size():
		var Lcharacter: BaseCharacter = partyContainer.characters[i]
		characterList.add_item(Lcharacter.id, Lcharacter.profilePicture)
		await get_tree().create_timer(0.01).timeout
	updateUpkeepList()

func updateUpkeepList() -> void:
	print("Updating Upkeep List")
	upkeepListArray.clear()
	upkeepList.clear()
		
	for i in partyContainer.characters.size():
		var Litem: BaseInventoryItem = partyContainer.characters[i].ResourceNeeded.duplicate(true)
		Litem.amount = partyContainer.characters[i].ResourceNeededNumber
		
		if upkeepListArray.size() != 0:
			for index in upkeepListArray.size():
				print("does exist")
				if upkeepListArray[index].itemName == Litem.itemName:
					print("Old Amount: " + str(upkeepListArray[index].amount))
					upkeepListArray[index].amount += Litem.amount
					print("New Amount: " + str(upkeepListArray[index].amount))
					break
				else:
					print("doesn't exist yet")
					Litem.amount = Litem.amount
					upkeepListArray.push_back(Litem)
		else:
			print("count is 0")
			Litem.amount = Litem.amount
			upkeepListArray.push_back(Litem)

#	print("Upkeep List " + str(upkeepListArray))

	for i in upkeepListArray.size():
		var Litem: BaseInventoryItem = upkeepListArray[i]
		upkeepList.add_item(Litem.itemName + "  x" + str(Litem.amount), Litem.image)



## When clicking on item in itemlist show info here
func updateCharacterInfo() -> void:
	characterPFPHolder.texture = targetCharacter.profilePicture
	characterNameLabel.text = targetCharacter.id
	characterLevelLabel.text = "Level: " + str(targetCharacter.stats.level)
	characterExperienceLabel.text = "Experience: " + str(snapped(targetCharacter.stats.experience, 0.01)) + "/" + str(snapped(targetCharacter.stats.maxEXP, 0.01))
	match targetCharacter.stats.role:
		0:
			characterClassLabel.text = "Role: Support"
		1:
			characterClassLabel.text = "Role: Ranged"
		2:
			characterClassLabel.text = "Role: Melee"
		3:
			characterClassLabel.text = "Role: Tank"
		_:
			characterClassLabel.text = "Role: Error"
			push_error('Unable to find target Character Role ')
	
	
	HealthStatLabel.text = str(snapped(targetCharacter.stats.currentHealth, 0.01)) + "/" + str(snapped(targetCharacter.stats.health, 0.01))
	DefenseStatLabel.text = str(snapped(targetCharacter.stats.currentDefense, 0.01)) + "/" + str(snapped(targetCharacter.stats.defense, 0.01))
	AttackStatLabel.text = str(snapped(targetCharacter.stats.currentAttack, 0.01)) + "/" + str(snapped(targetCharacter.stats.attack, 0.01))
	MoraleStatLabel.text = str(snapped(targetCharacter.stats.currentMorale, 0.01)) + "/" + str(snapped(targetCharacter.stats.morale, 0.01))
	
	if is_instance_valid(targetCharacter.action1):
		Action1NameLabel.text = targetCharacter.action1.ActionName
		Action1HealthLabel.text = str(snapped(targetCharacter.action1.health, 0.01))
		Action1DefenseLabel.text = str(snapped(targetCharacter.action1.defense, 0.01))
		Action1AttackLabel.text = str(snapped(targetCharacter.action1.attack, 0.01))
		Action1MoraleLabel.text = str(snapped(targetCharacter.action1.morale, 0.01))
	else:
		Action1NameLabel.text = ""
		Action1HealthLabel.text = ""
		Action1DefenseLabel.text = ""
		Action1AttackLabel.text = ""
		Action1MoraleLabel.text = ""
	
	if is_instance_valid(targetCharacter.action2):
		Action2NameLabel.text = targetCharacter.action2.ActionName
		Action2HealthLabel.text = str(snapped(targetCharacter.action2.health, 0.01))
		Action2DefenseLabel.text = str(snapped(targetCharacter.action2.defense, 0.01))
		Action2AttackLabel.text = str(snapped(targetCharacter.action2.attack, 0.01))
		Action2MoraleLabel.text = str(snapped(targetCharacter.action2.morale, 0.01))
	else:
		Action2NameLabel.text = ""
		Action2HealthLabel.text = ""
		Action2DefenseLabel.text = ""
		Action2AttackLabel.text = ""
		Action2MoraleLabel.text = ""
	
	if is_instance_valid(targetCharacter.action3):
		Action3NameLabel.text = targetCharacter.action3.ActionName
		Action3HealthLabel.text = str(snapped(targetCharacter.action3.health, 0.01))
		Action3DefenseLabel.text = str(snapped(targetCharacter.action3.defense, 0.01))
		Action3AttackLabel.text = str(snapped(targetCharacter.action3.attack, 0.01))
		Action3MoraleLabel.text = str(snapped(targetCharacter.action3.morale, 0.01))
	else:
		Action3NameLabel.text = ""
		Action3HealthLabel.text = ""
		Action3DefenseLabel.text = ""
		Action3AttackLabel.text = ""
		Action3MoraleLabel.text = ""
	
	if is_instance_valid(targetCharacter.action4):
		Action4NameLabel.text = targetCharacter.action4.ActionName
		Action4HealthLabel.text = str(snapped(targetCharacter.action4.health, 0.01))
		Action4DefenseLabel.text = str(snapped(targetCharacter.action4.defense, 0.01))
		Action4AttackLabel.text = str(snapped(targetCharacter.action4.attack, 0.01))
		Action4MoraleLabel.text = str(snapped(targetCharacter.action4.morale, 0.01))
	else:
		Action4NameLabel.text = ""
		Action4HealthLabel.text = ""
		Action4DefenseLabel.text = ""
		Action4AttackLabel.text = ""
		Action4MoraleLabel.text = ""
	
	UpkeepNameLabel.text = "Upkeep: " + targetCharacter.ResourceNeeded.itemName
	UpkeepAmountLabel.text = "x" + str(targetCharacter.ResourceNeededNumber)
	DropNameLabel.text = "Drop: " + str(targetCharacter.ResourceDrop.itemName)
	DropAmount.text = "x" + str(targetCharacter.ResourceMaxDropAmount)
	
	characterDescription.text = targetCharacter.characterDescription
