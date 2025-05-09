extends CharacterBody3D
class_name HorrorPlayer

@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var player_interaction_component: PlayerInteractionComponent = $PlayerInteractionComponent
@onready var nek: Node3D = %Nek
@onready var head: Node3D = %Head
@onready var eyes: Node3D = %Eyes
@onready var body: Node3D = %Body
@onready var camera_3d: Camera3D = %Camera3D

@export_group("Control Settings")
@export var TOGGLE_CROUCH : bool = false
var try_crouch : bool = false
@export var air_speed : float = 3.0 
@export var WALKING_SPEED = 5.0
@export var SRINTING_SPEED = 8.0
@export var CROUCHING_SPEED = 3.0
@export_subgroup("Jump Settings")
@export var jump_peak_time: float = 0
@export var jump_fall_time: float = 0
@export var jump_height: float = 0
var jump_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall_gravity : float = -5.0
var jump_velocity : float
@export_group("Interaction Settings")
@export var secondary_left : Node3D

var current_speed : float = 0.0
var lerp_speed : float = 10.0
var direction : Vector3
var input_dir : Vector2
var crouching_depth = -0.8 #下蹲的深度

#State
var walking = false
var sprinting = false
var crouching = false

const MOUSE_SENS = 0.1
#Bobbing
const HEAD_BOBBING_SPRINTING_SPEED : float = 16.0
const HEAD_BOBBING_WALKING_SPEED : float = 12.0
const HEAD_BOBBING_CROUCHING_SPEED : float = 8.0
const HEAD_BOBBING_SPRINTING_INTENSITY : float = 0.05
const HEAD_BOBBING_WALKING_INTENSITY : float = 0.03
const HEAD_BOBBING_CROHCHING_INTENSITY : float = 0.08
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0


func _ready() -> void:
	HorrorSceneManager._current_player_node = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	Establish_Speed()
	
	HorrorSceneManager.connect("sit_requested", Callable(self, "_on_sit_requested"))
	HorrorSceneManager.connect("stand_requested", Callable(self, "_on_stand_requested"))
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		if is_sitting and HorrorSceneManager._current_sittable_node.look_marker_node:
			handle_sitting_look(event)
		else:
			body.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
			head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
func Establish_Speed()->void:
	jump_gravity = (2*jump_height)/ pow(jump_peak_time,2)
	fall_gravity = (2*jump_height)/ pow(jump_fall_time,2)
	jump_velocity = ((jump_gravity)*(jump_peak_time))

func _physics_process(delta: float) -> void:
	if TOGGLE_CROUCH and Input.is_action_just_pressed("crouch"):
		try_crouch = !try_crouch
	elif !TOGGLE_CROUCH:
		try_crouch = Input.is_action_pressed("crouch")
	
	if try_crouch:
		current_speed = lerp(current_speed, CROUCHING_SPEED, delta * lerp_speed)
		head.position.y = lerp(head.position.y, crouching_depth, delta * lerp_speed)
		
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		walking = false
		crouching = true
		sprinting = false
		
	elif not ray_cast_3d.is_colliding():
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		if Input.is_action_pressed("sprint"):
			current_speed = lerp(current_speed, SRINTING_SPEED, delta * lerp_speed)
			
			walking = false
			crouching = false
			sprinting = true
		else:
			current_speed = lerp(current_speed, WALKING_SPEED, delta * lerp_speed)
			
			walking = true
			sprinting = false
			crouching = false
	
	handle_headbob(delta)
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if not is_on_floor():
		# 添加重力
		velocity.y -= fall_gravity * delta
		# 空中控制
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (body.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_speed)
	else:
		direction = (body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, lerp_speed * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, lerp_speed * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, lerp_speed * delta)
		velocity.z = lerp(velocity.z, 0.0, lerp_speed * delta)

	move_and_slide()

func handle_headbob(delta : float) -> void:
	if sprinting:
		head_bobbing_current_intensity = HEAD_BOBBING_SPRINTING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_SPRINTING_SPEED * delta
	elif walking:
		head_bobbing_current_intensity = HEAD_BOBBING_WALKING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_WALKING_SPEED * delta
	elif crouching:
		head_bobbing_current_intensity = HEAD_BOBBING_CROHCHING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_CROUCHING_SPEED  * delta
		
	if is_on_floor() and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity / 2), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)

#region Sittable Interaction Handing
var original_position: Transform3D
var displacement_position: Vector3
var is_sitting : bool
var sittable_look_marker: Vector3
var sittable_look_angle: float
var moving_seat: bool = false
var original_neck_basis: Basis = Basis()
var currently_tweening: bool = false

func handle_sitting_look(event):
	#TODO - Fix for vehicles by handling dynamic look marker, Fix for controller support
	var neck_position = nek.global_transform.origin
	var look_marker_position = sittable_look_marker
	var target_direction = Vector2(look_marker_position.x - neck_position.x, look_marker_position.z - neck_position.z).normalized()

	# Get the current neck forward direction
	var neck_forward = nek.global_transform.basis.z
	var neck_direction = Vector2(neck_forward.x, neck_forward.z).normalized()

	# Angle between neck direction and look marker direction
	var angle_to_marker = rad_to_deg(neck_direction.angle_to(target_direction))

	# Apply mouse input to rotate neck
	nek.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))

	# Updated neck direction after rotation
	neck_forward = nek.global_transform.basis.z
	neck_direction = Vector2(neck_forward.x, neck_forward.z).normalized()

	# New angle after rotation
	var new_angle_to_marker = rad_to_deg(neck_direction.angle_to(target_direction))
	new_angle_to_marker = wrapf(new_angle_to_marker, 0, 360)
	
	# Check if the new angle is within the limits
	if not (new_angle_to_marker > 180-sittable_look_angle and new_angle_to_marker < (180 + sittable_look_angle)):
		nek.rotation.y -= deg_to_rad(-event.relative.x * MOUSE_SENS)

	head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
	
	var sittable = HorrorSceneManager._current_sittable_node
	
	if sittable.physics_sittable == false:
		#static sittables are fine to be clamped this way
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-sittable.vertical_look_angle), deg_to_rad(sittable.vertical_look_angle))
	else:
		# TODO replace with dynamic vertical look range based on look marker
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-sittable.vertical_look_angle), deg_to_rad(sittable.vertical_look_angle))

func _on_sit_requested(sittable : Node) -> void:
	if not is_sitting:
		_sit_down()

func _on_stand_requested():
	if is_sitting:
		_stand_up()	

func _sit_down() -> void:
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = true
	var sittable = HorrorSceneManager._current_sittable_node
	
	if sittable:
		is_sitting = true
		set_physics_process(true) # 固定帧率
		if sittable.look_marker_node:
			sittable_look_marker = sittable.look_marker_node.global_transform.origin
		sittable_look_angle = sittable.horizontal_look_angle
		if !moving_seat:
			original_position = self.global_transform
			original_neck_basis = nek.global_transform.basis
			displacement_position = sittable.global_transform.origin - self.global_transform.origin
			
		if sittable.physics_sittable:
			currently_tweening = true
			set_physics_process(true)
			
			var tween = create_tween()
			tween.tween_property(self, "global_transform", sittable.sit_position_node.global_transform, sittable.tween_duration)
			tween.tween_callback(Callable(self, "_sit_down_finished"))
		
		else:
			currently_tweening = true
			var tween = create_tween()
			tween.tween_property(self, "global_transform", sittable.sit_position_node.global_transform, sittable.tween_duration)
			tween.tween_callback(Callable(self, "_sit_down_finished"))

func _sit_down_finished() -> void:
	is_sitting = true
	set_physics_process(true)
	var sittable = HorrorSceneManager._current_sittable_node
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = true
	currently_tweening = false
	if sittable_look_marker:
		var tween = create_tween()
		var target_transform = nek.global_transform.looking_at(sittable_look_marker, Vector3.UP)
		tween.tween_property(nek, "global_transform:basis", target_transform.basis, sittable.rotation_tween_duration)

func _stand_up() -> void:
	var sittable = HorrorSceneManager._current_sittable_node
	if sittable:
		is_sitting = false
		set_physics_process(false)
		
		match sittable.placement_on_leave:
			sittable.PlacementOnLeave.ORIGINAL:
				pass
				
func _move_to_original_position(sittable) -> void:
	currently_tweening = true
	var tween = create_tween()
	tween.tween_property(self, "global_transform", original_position, sittable.tween_duration)
	tween.tween_property(nek, "global_transform:basis", original_neck_basis, sittable.rotation_tween_duration)
	tween.tween_callback(Callable(self, "_stand_up_finished"))

func _stand_up_finished() -> void:
	is_sitting = false
	set_physics_process(true)
	standing_collision_shape.disabled = false
	#crouching_collision_shape.disabled = false
	self.global_transform.basis = Basis()
	nek.global_transform.basis = original_neck_basis  
	currently_tweening = false
#endregion
			
		
