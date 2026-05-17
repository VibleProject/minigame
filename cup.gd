extends Area2D

# 메인 스크립트로 보낼 신호
signal cup_clicked

var origin_y: float
var is_up: bool = false

func _ready():
	# 게임 시작 시 컵의 처음 높이를 기억해둡니다.
	origin_y = position.y
	input_pickable = true

# 컵을 들어 올리는 함수
func lift_up():
	if is_up: return
	is_up = true
	var tween = create_tween()
	# 현재 위치에서 위로 200픽셀만큼 이동
	tween.tween_property(self, "position:y", origin_y - 200, 0.4).set_trans(Tween.TRANS_QUAD)

# 컵을 아래로 내리는 함수 (이게 없어서 에러가 났던 거예요!)
func lift_down():
	if not is_up: return
	is_up = false
	var tween = create_tween()
	# 원래 기억해둔 높이(origin_y)로 복귀
	tween.tween_property(self, "position:y", origin_y, 0.4).set_trans(Tween.TRANS_QUAD)

# 마우스 클릭 감지
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			cup_clicked.emit()
