extends Node2D

@onready var cup_parent = $CupParent
@onready var ball = $Ball
@onready var game_over_ui = $GameOverUI
@onready var game_start_ui = $GameStartUI

var cups = []
var is_shuffling: bool = false
var game_over: bool = false
var ball_offset: Vector2 = Vector2(-6, 10)

var current_ball_cup: Node2D = null

# 🏆 [무한 단계 시스템 추가]
var stage: int = 1

func _ready():
	# 1. 세로 모드 강제 설정
	get_viewport().content_scale_size = Vector2i(720, 1280)
	DisplayServer.screen_set_orientation(1) 
	
	cups = cup_parent.get_children()
	game_over_ui.hide()
	
	ball.z_index = -1
	
	# 2. 컵 클릭 신호 연결
	for cup in cups:
		if cup.has_signal("cup_clicked"):
			if cup.is_connected("cup_clicked", _on_cup_selected):
				cup.disconnect("cup_clicked", _on_cup_selected)
			cup.connect("cup_clicked", _on_cup_selected.bind(cup))
	
	# 3. 시작 UI 연결 (최초 시작 시 stage 1 초기화)
	if game_start_ui:
		if game_start_ui.has_signal("countdown_finished"):
			game_start_ui.countdown_finished.connect(func(): start_new_game(true))
		else:
			start_new_game(true)
	else:
		start_new_game(true)

# 🔄 게임 시작 및 단계 리셋/이어하기 통합 함수
# 🔄 게임 시작 및 단계 리셋/이어하기 통합 함수
# 🔄 게임 시작 및 단계 리셋/이어하기 통합 함수
func start_new_game(reset_stage: bool = false):
	if reset_stage:
		stage = 1 # 처음부터 시작할 때는 1단계로 리셋
		
	game_over = false
	is_shuffling = false
	game_over_ui.hide()
	
	# 🎯 [실시간 단계 표시 추가] 
	# 현재 메인 게임 화면에 있는 ScoreLabel을 찾아 "X단계"라고 실시간으로 텍스트를 갱신합니다.
	# (주의: game_over_ui 내부의 라벨이 아니라, 현재 맵 화면에 바로 나와있는 ScoreLabel 노드입니다!)
	var in_game_score_label = get_node_or_null("ScoreLabel")
	if in_game_score_label:
		in_game_score_label.text = str(stage) + "단계"
	
	# 모든 컵을 아래로 정렬
	for cup in cups:
		if cup.has_method("lift_down"):
			cup.lift_down()
	
	randomize()
	current_ball_cup = cups[randi() % cups.size()]
	ball.position = current_ball_cup.position + ball_offset
	ball.show()
	
	# 1. 구슬 위치를 먼저 슬쩍 보여주기 (컵 올리기)
	await get_tree().create_timer(0.5).timeout
	if current_ball_cup.has_method("lift_up"):
		current_ball_cup.lift_up()
	
	# 컵이 올라가 있는 시간
	await get_tree().create_timer(1.2).timeout
	
	# 2. 컵 다시 내리기
	if current_ball_cup.has_method("lift_down"):
		current_ball_cup.lift_down()
		
	# ⏳ 컵이 완전히 바닥에 내려온 뒤, 섞이기 전에 잠시 숨을 고르는 시간 (0.8초 텀)
	await get_tree().create_timer(0.8).timeout
	
	# 3. 이제 컵 섞기 시작!
	var shuffle_count = 12 + (stage * 2)
	shuffle_cups(shuffle_count)

func shuffle_cups(times: int):
	is_shuffling = true
	
	# ⚡ [속도 조절 공식] 단계가 올라갈수록 셔플 속도가 점차 빨라집니다.
	var swap_speed = 0.15 - (stage * 0.005)
	if swap_speed < 0.07: swap_speed = 0.07 # 너무 빨라져서 순간이동하는 것 방지(최소 한계값)

	for i in range(times):
		var idx1 = randi() % cups.size()
		var idx2 = randi() % cups.size()
		while idx1 == idx2:
			idx2 = randi() % cups.size()
			
		await swap_cups(cups[idx1], cups[idx2], swap_speed)
	
	is_shuffling = false

func swap_cups(cup_a, cup_b, speed: float):
	var pos_a = cup_a.position
	var pos_b = cup_b.position
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(cup_a, "position", pos_b, speed).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cup_b, "position", pos_a, speed).set_trans(Tween.TRANS_SINE)
	
	if cup_a == current_ball_cup:
		tween.tween_property(ball, "position", pos_b + ball_offset, speed)
	elif cup_b == current_ball_cup:
		tween.tween_property(ball, "position", pos_a + ball_offset, speed)
		
	await tween.finished

# 🎯 판정 함수 무한 루프 이식 완료
func _on_cup_selected(clicked_cup):
	if is_shuffling or game_over: return
	
	game_over = true
	if clicked_cup.has_method("lift_up"):
		clicked_cup.lift_up()
	
	await get_tree().create_timer(0.7).timeout
	
	# 🎉 [성공] 맞췄을 때
	if clicked_cup == current_ball_cup:
		# 다음 단계로 세팅하고 0.5초 뒤 컵 내리며 즉시 다음 판 시작!
		stage += 1
		print("정답! 다음 단계로 이동: ", stage, "단계")
		
		await get_tree().create_timer(0.5).timeout
		start_new_game(false) # false를 줘서 스테이지 숫자를 유지한 채 다음 판 진행
		
	# 💥 [실패] 틀려서 진짜 게임이 완전히 끝났을 때
	else:
		reveal_all()
		await get_tree().create_timer(0.5).timeout
		
		# 1. UI 본래 규칙에 맞추어 연동
		game_over_ui.display("GAME OVER", 0, false)
		
		# 2. ScoreLabel에 구슬 게임 스타일로 기록을 가공해 밀어넣습니다.
		var complete_stage = stage - 1
		if complete_stage < 0: complete_stage = 0
		
		var final_msg = str(complete_stage) + "단계 완료"
		if complete_stage == 0:
			final_msg = "0단계 완료"
			
		_setup_shell_ui_label(final_msg)

# 텍스트 내용만 딱 치환해 주는 안전한 정렬 제외 함수
func _setup_shell_ui_label(result_text: String):
	var score_label = game_over_ui.get_node_or_null("ScoreLabel")
	if score_label:
		score_label.text = result_text

func reveal_all():
	for cup in cups:
		if cup.has_method("lift_up"):
			cup.lift_up()

func _exit_tree():
	DisplayServer.screen_set_orientation(4)
