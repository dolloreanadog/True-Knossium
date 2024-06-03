extends Label

@export var partyContainer: BasePartyContainer


func _ready():
	partyContainer.connect("charactersUpdated", updateLabel)
	
func updateLabel():
	self.set_text("Total Stat Points are " + str(snappedf(partyContainer.currentTotalStatPoints, 0.01)))
