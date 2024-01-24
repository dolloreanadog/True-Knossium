extends Label
class_name CharacterInfoLabel

@onready var stats: StatComponent = get_parent().get_node("StatComponent")

func _ready():
	print(str(self) + " print " + str(stats))
	stats.connect("statChanged", updateInfoLabel)

func updateInfoLabel():
	print(str(self) + ": Updated Info Label")
	var Lhealth = "%.2f" % stats.currentHealth
	var Ldefense = "%.2f" % stats.currentDefense
	var Lattack = "%.2f" % stats.currentAttack
	var Lmorale = "%.2f" % stats.currentMorale
	self.set_text(str(Lhealth) + "/" + str(stats.health) + " " + str(Ldefense) + "/" + str(stats.defense) + " " + str(Lattack) + "/" + str(stats.attack) + " " + str(Lmorale) + "/" + str(stats.morale))
