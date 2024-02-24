extends Button

@onready var dungeon = get_parent().get_parent()
@onready var AutoPlaceSupportAOE: AutoPlacementAOEComponent = get_node("AutoPlaceSupportAOE")
@onready var AutoPlaceOffensiveAOE: AutoPlacementAOEComponent = get_node("AutoPlaceOffensiveAOE")

#--[ Functions ]--

func ready():
	pass

func onPressed():
	AutoPlaceOffensiveAOE.activateAOEPlacement()
	AutoPlaceSupportAOE.activateAOEPlacement()
