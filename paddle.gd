extends AnimatableBody2D

func _ready():
	add_to_group("paddle")
	collision_layer = 1
	collision_mask = 1

func _physics_process(_delta):
	var mouse_x = get_global_mouse_position().x
	# X는 마우스, Y는 1000 고정 (이 한 줄로 물리 충돌까지 자동 처리됩니다)
	global_position = Vector2(mouse_x, 1000)
