extends Node3D
class_name HorrorObject

var interaction_nodes : Array[Node]

@export var horror_name : String = self.name
@export var display_name : String

func _ready() -> void:
	self.add_to_group("interactable")
	find_interaction_nodes()

func find_interaction_nodes():
	interaction_nodes = find_children("","InteractionComponent",true)
