extends InteractionComponent
class_name CarryableComponent

var parent_object
var player_interaction_component : PlayerInteractionComponent

func _ready() -> void:
	parent_object = get_parent()
	
func interact(_player_interaction : PlayerInteractionComponent) -> void:
	if !is_disabled:
		carry(_player_interaction)

func carry(_player_interaction_component : PlayerInteractionComponent) -> void:
	player_interaction_component = _player_interaction_component
	
	parent_object.global_transform = player_interaction_component.player.secondary_left.global_transform
	parent_object.reparent(player_interaction_component.player.secondary_left)
