extends Control
class_name ConfirmationBox

@onready var confirmationLabel: Label = $ConfirmationWindow/Label
@onready var confirmationYesButton: Button = $ConfirmationWindow/ConfirmYes
@onready var confirmationNoButton: Button = $ConfirmationWindow/ConfirmNo

signal YesPressed
signal NoPressed

func setLabel(text: String):
	confirmationLabel.text = text

func ConfirmYesPressed() -> void:
	YesPressed.emit()

func ConfirmNoPressed() -> void:
	NoPressed.emit()
