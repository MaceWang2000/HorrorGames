extends Node3D
class_name PlayerInteractionComponent

@export var interaction_raycast: InteractionRayCast

var player : HorrorPlayer
var player_rid
var interactable: 
	set = _set_interactable
var is_carrying: bool:
	get: return carried_object != null
var carried_object = null:  # Used for carryable handling.
	set = _set_carried_object

signal interactive_object_detected(interaction_nodes: Array[Node])
signal nothing_detected()
signal started_carrying(interaction_node: Node)

func _ready() -> void:
	player = get_parent() as HorrorPlayer
	
func exclude_player(rid: RID):
	player_rid = rid
	interaction_raycast.add_exception_rid(rid)

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var action: String = "interact" if event.is_action_pressed("interact") else "interact2"
		
		_handle_interaction(action)

func _handle_interaction(action : String) -> void:
	if interactable != null and not is_carrying:
		for node: InteractionComponent in interactable.interaction_nodes:
			if node.input_map_action == action and not node.is_disabled:
				#if !node.ignore_open_gui and get_parent().is_showing_ui:
					#return
				node.interact(self)
				
func _set_interactable(new_interactable) -> void:
	interactable = new_interactable
	
	if is_carrying:
		return
	if interactable == null:
		nothing_detected.emit()
	else:
		interactive_object_detected.emit(interactable.interaction_nodes)

func start_carrying(_carried_object):
	carried_object = _carried_object


func stop_carrying():
	carried_object = null

func _set_carried_object(new_carried_object) -> void:
	carried_object = new_carried_object
	if carried_object != null:
		started_carrying.emit(carried_object)


func _on_interaction_ray_cast_interactable_seen(new_interactable: Variant) -> void:
	interactable = new_interactable
	print(interactable)


func _on_interaction_ray_cast_interactable_unseen() -> void:
	interactable = null
