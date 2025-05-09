extends Node

@export var _current_player_node : Node
@export var _current_sittable_node : Node

# Sit or Stand Variables
signal sit_requested(Node)
signal stand_requested()
