extends RichTextLabel

@export var PartyContainer: BasePartyContainer
@onready var system: TurnSystem = get_parent().get_parent().get_node("TurnSystem")

enum getInfoOn {ALL, TANK, MELEE, RANGED, SUPPORT}
@export var wantedInfo: getInfoOn

func _ready():
	#system.connect("OnNewTurn", newTurn)
	PartyContainer.connect("charactersUpdated", updateInfo)
	updateInfo()

#func newTurn():
#	updateInfo()

func updateInfo():
	match wantedInfo:
		getInfoOn.ALL:
			if PartyContainer.getCharactersArray() != null:
				self.set_text(str(PartyContainer.getCharactersArray()))
		getInfoOn.TANK:
			if PartyContainer.getTankArray() != null:
				self.set_text(str(PartyContainer.getTankArray()))
		getInfoOn.MELEE:
			if PartyContainer.getMeleeArray() != null:
				self.set_text(str(PartyContainer.getMeleeArray()))
		getInfoOn.RANGED:
			if PartyContainer.getRangedArray() != null:
				self.set_text(str(PartyContainer.getRangedArray()))
		getInfoOn.SUPPORT:
			if PartyContainer.getSupportArray() != null:
				self.set_text(str(PartyContainer.getSupportArray()))
