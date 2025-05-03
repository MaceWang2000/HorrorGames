extends Sprite2D

@export var keyboard_icon : Texture2D
@export var action_name : String
@export var input_icon_type: InputIconType

@export var interact1_icon : Texture2D
@export var interact2_icon : Texture2D

enum InputIconType{
	DYNAMIC,
	DYNAMIC_GAMEPAD,
	KBM,
	XBOX,
	PS5,
	SWITCH,
}

var device
var device_index
var key_int : int

func _ready() -> void:
	InputHelper.device_changed.connect(update_device)
	update_device(InputHelper.device,InputHelper.device_index)
	InputHelper.keyboard_input_changed.connect(check_for_input_change)

func update_device(_device, _device_index) -> void:
	device = _device
	device_index = _device_index
	
	update_input_icon()

func check_for_input_change(_action, _input):
	if _action == action_name:
		update_input_icon()

func update_input_icon() -> void:
	match input_icon_type:
		InputIconType.DYNAMIC:
			update_input_icon_dynamic()
		InputIconType.KBM:
			update_icon_kbm()

func update_input_icon_dynamic() -> void:
	match device:
		InputHelper.DEVICE_KEYBOARD:
			update_icon_kbm()

func update_icon_kbm() -> void:
	if action_name == "interact":
		set_texture(interact1_icon)
	elif action_name == "interact2":
		set_texture(interact2_icon)

func keycode_to_frame_index(key_code_string: String) -> int:
	match key_code_string:
		null:
			return 0
		"Mouse Left":
			return 108
		"Mouse Right":
			return 109
		"Mouse Middle":
			return 110
		"0":
			return 1
		"1":
			return 2
		"2":
			return 3
		"3":
			return 4
		"4":
			return 5
		"5":
			return 6
		"6":
			return 7
		"7":
			return 8
		"8":
			return 9
		"9":
			return 10
		"A":
			return 12
		"B":
			return 13
		"C":
			return 14
		"D":
			return 15
		"E":
			return 16
		"F":
			return 17
		"G":
			return 18
		"H":
			return 19
		"I":
			return 20
		"J":
			return 21
		"K":
			return 22
		"L":
			return 23
		"M":
			return 24
		"N":
			return 25
		"O":
			return 26
		"P":
			return 27
		"Q":
			return 28
		"R":
			return 29
		"S":
			return 30
		"T":
			return 31
		"U":
			return 32
		"V":
			return 33
		"W":
			return 34
		"X":
			return 35
		"Y":
			return 36
		"Z":
			return 37
		"~":
			return 38
		"'":
			return 39
		"<":
			return 40
		">":
			return 41
		"[":
			return 42
		"]":
			return 43
		".":
			return 44
		":":
			return 45
		",":
			return 46
		";":
			return 47
		"=":
			return 48
		"+":
			return 49
		"-":
			return 50
		"^":
			return 51
		"\"":
			return 52
		"?":
			return 53
		"!":
			return 54
		"*":
			return 55
		"/":
			return 56
		"\\":
			return 57
		"Escape":
			return 60
		"Ctrl":
			return 61
		"Alt":
			return 62
		"Space":
			return 63
		"Tab":
			return 64
		"Enter":
			return 65
		"Shift":
			return 66
		
		_:
			return -1
