extends Node3D

@export var carriage_node : Node3D
@export var carriage_animation_player : AnimationPlayer
@export var carriage_destination : Marker3D

var carriage_sound = preload("res://Audio/马车.wav")
var tween :Tween

func _ready() -> void:
	SoundManager.play_sound(carriage_sound, "SFX")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # 隐藏鼠
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
func _process(delta: float) -> void:
	pass
	
