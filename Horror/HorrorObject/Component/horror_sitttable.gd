extends Node3D
class_name HorrorSittable

var interaction_nodes : Array[Node]

func _ready() -> void:
	self.add_to_group("interactable")
	interaction_nodes = find_children("", "InteractionComponent", true)

func interact() -> void:
	pass
