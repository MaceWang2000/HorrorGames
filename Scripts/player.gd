extends CharacterBody3D
class_name HorrorPlayer

@onready var head: Node3D = $Nek/Head
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var nek: Node3D = $Nek
@onready var eyes: Node3D = $Nek/Head/Eyes
@onready var camera_3d: Camera3D = %Camera3D
@onready var player_interaction_component: PlayerInteractionComponent = $PlayerInteractionComponent

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
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	Establish_Speed()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
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
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_speed)
	else:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
