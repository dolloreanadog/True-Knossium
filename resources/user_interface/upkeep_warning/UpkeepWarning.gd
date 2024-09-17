extends Control
## Box to warn player of running out of upkeep.
class_name UpkeepWarning

func _ready() -> void:
	self.hide()

func StartDisplay(text: String):
	$WarningLabel.text = text
	show()

func StopDisplay():
	hide()
