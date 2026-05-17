extends CharacterBody2D

const JUMP_VELOCITY = -550.0 # 점프 힘 (숫자가 클수록 높이 점프)
var gravity = 1000 # 중력 값

func _physics_process(delta):
	# 1. 중력 적용 (공중에 있다면 아래로 떨어짐)
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. 점프 입력 처리 (스페이스바 또는 마우스 클릭)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. 실제 이동 적용
	move_and_slide()
