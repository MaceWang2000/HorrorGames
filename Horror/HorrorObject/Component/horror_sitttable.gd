extends Node3D
class_name HorrorSittable

@export var physics_sittable: bool =  false
@export_category("Sittable Behaviour")
@export var placement_on_leave : PlacementOnLeave = PlacementOnLeave.ORIGINAL
@export_group("Animation")
@export var tween_to_location : bool = true
@export var tween_to_look_marker : bool = true
@export var tween_duration: float = 0.8
@export var rotation_tween_duration: float = 0.4
@export var animation_on_enter: String 
@export var animation_on_leave: String
@export_group("Nodes")
## 定义玩家坐下的位置
@export var sit_position_node_path: NodePath
## 定义玩家看向哪个位置
@export var look_marker_node_path : NodePath
@export var sit_area_node_path: NodePath
@export var leave_node_path: NodePath 
@export_group("Vision")
## 玩家坐下时，任意方向的水平视角
@export var horizontal_look_angle : float = 120
## 玩家坐下时，任意方向的垂直视角
@export var vertical_look_angle: float = 90
## 当玩家坐下时，摄像机下降的速度（头部与脚部之间的高度差异）
@export var sit_marker_displacement: float = 0.7

enum PlacementOnLeave{
	ORIGINAL, # Player 返回原来的位置
	AUTO, # 尝试使用NavMesh，为Player找到可用位置
	TRANSFORM, # 
	DISPLACEMENT
}

var interaction_nodes : Array[Node]
var player_node : Node3D
var sit_position_node: Node3D = null
var look_marker_node: Node3D = null

func _ready() -> void:
	player_node = HorrorSceneManager._current_player_node
	self.add_to_group("interactable")
	interaction_nodes = find_children("", "InteractionComponent", true)
	HorrorSceneManager._current_sittable_node = self
	# 找到look_marker_node
	look_marker_node = get_node_or_null(look_marker_node_path)
	# find sit position node
	sit_position_node = get_node_or_null(sit_position_node_path)
	if not sit_position_node:
		print_debug("未找到sit position node节点")
	else:
		displace_sit_marker()

func interact(player_interaction_component : PlayerInteractionComponent) -> void:
	if player_node.is_sitting and HorrorSceneManager._current_sittable_node == self:
		HorrorSceneManager.emit_signal("stand_requested")
	
	elif !player_node.is_sitting:
		HorrorSceneManager._current_sittable_node = self
		HorrorSceneManager.emit_signal("sit_requested", self)
		
func _sit_down() -> void:
	pass

func _stand_up() -> void:
	pass

func displace_sit_marker():
	if sit_position_node:
		# 根据sit_marker_displacement向下调整sit marker节点
		var adjusted_transform = sit_position_node.transform
		adjusted_transform.origin.y -= sit_marker_displacement
		sit_position_node.transform = adjusted_transform
