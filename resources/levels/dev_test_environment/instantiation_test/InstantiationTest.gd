extends Node2D

var box = load("res://resources/levels/dev_test_environment/instantiation_test/instantiationTestBox.tscn")

func _ready():
	var instance = box.instantiate()
	add_child(instance)
