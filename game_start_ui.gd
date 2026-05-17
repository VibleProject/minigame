extends CanvasLayer

signal countdown_done  # 메인 게임에 보낼 신호 이름
var countdown_finished: bool = false # 상태 변수

@onready var label = $Label

func _ready() -> void:
	# ⭕ [중요] 이 UI 자체가 일시정지 상태에서도 애니메이션과 코드가 작동하도록 속성을 켭니다.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if label:
		label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		label.pivot_offset = label.size / 2
	start_countdown()

func start_countdown():
	if not label: return
	
	# 3, 2, 1 카운트다운 루프
	for i in range(3, 0, -1):
		label.text = str(i)
		play_bounce_animation()
		
		# ⭕ [오류 해결 치트키] 고도 4에서 일시정지를 무시하는 타이머를 만드는 정석 구문입니다.
		# create_timer(시간, 물리프로세스여부, 일시정지무시여부) 
		# 세 번째 칸에 true를 넣어주면 process_always 오류 없이 일시정지 중에도 타이머가 흘러갑니다.
		await get_tree().create_timer(1.0, false, true).timeout
	
	# GO! 출력
	label.text = "GO!"
	play_bounce_animation()
	
	# 여기도 똑같이 세 번째 인자에 true를 줍니다.
	await get_tree().create_timer(0.5, false, true).timeout
	
	# 드디어 메인 게임에 신호를 빵 쏩니다!
	countdown_finished = true 
	countdown_done.emit()      
	
	hide()
	
	await get_tree().create_timer(0.1, false, true).timeout
	
	queue_free()

func play_bounce_animation():
	if label:
		# ⭕ 일시정지 상태에서도 트윈 애니메이션이 멈추지 않고 튕기도록 설정합니다.
		var tween = create_tween()
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS) # 일시정지 무시 밸런스 설정
		
		label.scale = Vector2(1.5, 1.5)
		tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
