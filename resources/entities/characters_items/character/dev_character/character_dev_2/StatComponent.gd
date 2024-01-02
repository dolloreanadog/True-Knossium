extends StatComponent
# Notes
# In this character we test overriding functions
# Function Overrides everything

func _ready():
	overMaxHealth()
	if overMaxHealth() == true:
		print("uh oh")
	else:
		print("yippee")
	print(characterBody) # Testing if it sees the characterBody2D
	
func overMaxHealth():
	print("Overridden previous function")
