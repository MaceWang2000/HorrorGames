extends InteractionComponent

@onready var parent = get_parent()

func _ready() -> void:
	pass

func interact(_player_interact_component : PlayerInteractionComponent) -> void:
	if parent.has_method("interact"):
		parent.interact(_player_interact_component)
