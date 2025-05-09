extends Control
class_name HorrorPlayerHUD

@export var player : Node
@export var prompt_component : PackedScene
@onready var prompt_area: VBoxContainer = $PromptArea

func _ready() -> void:
	connect_to_player_signals.call_deferred()

func connect_to_player_signals() -> void:
	player.player_interaction_component.interactive_object_detected.connect(set_interaction_prompts)
	player.player_interaction_component.nothing_detected.connect(delete_interaction_prompts)
	
func set_interaction_prompts(passed_interaction_nodes : Array[Node]):
	delete_interaction_prompts() # clear prompts whenever new ones are received
	for node in passed_interaction_nodes:
		if node.is_disabled:
			continue
		var instanced_prompt: UIPromptComponent = prompt_component.instantiate()
		prompt_area.add_child(instanced_prompt)
		instanced_prompt.set_prompt(node.interaction_text, node.input_map_action)
			
func delete_interaction_prompts() -> void:
	for prompt: UIPromptComponent in prompt_area.get_children():
		prompt.discard_prompt()
