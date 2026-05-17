extends Node2D

@export var brick_scene: PackedScene = preload("res://Brick.tscn")

# 노드 참조
@onready var game_over_ui = get_node_or_null("GameOverUI") 
@onready var game_start_ui = get_node_or_null("GameStartUI")
@onready var brick_parent = get_node_or_null("brickParent")
@onready var ball = get_node_or_null("Ball")

var score: int = 0
var stage: int = 1 
var is_waiting_for_paddle: bool = false # 마지막 벽돌을 깨고 패들 터치를 기다리는 스위치

func _ready():
	# 세로 모드 해상도와 세로 방향 고정
	get_viewport().content_scale_size = Vector2i(720, 1280)
	DisplayServer.screen_set_orientation(1) 
	randomize()
	
	if ball:
		ball.set_process(false)
		ball.set_physics_process(false)
		ball.velocity_dir = Vector2.ZERO 
	
	# 🎯 게임이 시작하기 전에 미리 화면의 ScoreLabel을 초기화해 둡니다.
	_update_in_game_score_label()
	
	if game_start_ui:
		if game_start_ui.has_signal("countdown_done"):
			if not game_start_ui.countdown_done.is_connected(_on_countdown_finished):
				game_start_ui.countdown_done.connect(_on_countdown_finished)
		elif game_start_ui.has_signal("countdown_finished"):
			if not game_start_ui.countdown_finished.is_connected(_on_countdown_finished):
				game_start_ui.countdown_finished.connect(_on_countdown_finished)
	else:
		_on_countdown_finished()

func _on_countdown_finished():
	stage = 1 
	score = 0
	is_waiting_for_paddle = false
	
	# 🎯 카운트다운 완료 후 진짜 게임 판이 열릴 때 1단계로 새로고침
	_update_in_game_score_label()
	
	spawn_bricks()
	start_ball()

# 🎯 [새로 추가] 현재 메인 게임 화면에 배치된 ScoreLabel을 실시간으로 변경해주는 함수
func _update_in_game_score_label():
	# game_over_ui 내부가 아니라, 평소에 화면 상단에 떠 있는 ScoreLabel을 찾아갑니다.
	var in_game_score_label = get_node_or_null("ScoreLabel")
	if in_game_score_label:
		in_game_score_label.text = str(stage) + "단계"

func start_ball():
	if ball:
		ball.set_process(true)
		ball.set_physics_process(true)
		if ball.has_method("launch"):
			ball.launch()

func spawn_bricks():
	if brick_scene == null: return
	
	var margin_x = 68.0        
	var margin_y = 68.0        
	var start_pos = Vector2(45, 70) 
	var rows = 8               
	
	var screen_width = get_viewport().content_scale_size.x
	var columns = int((screen_width - (start_pos.x * 2)) / margin_x)

	var parent_node = brick_parent if brick_parent else self

	for child in parent_node.get_children():
		if child.is_in_group("bricks"):
			child.queue_free()

	for r in range(rows):
		for c in range(columns):
			var new_brick = brick_scene.instantiate()
			new_brick.add_to_group("bricks")
			
			var pos_x = start_pos.x + (c * margin_x)
			var pos_y = start_pos.y + (r * margin_y)
			
			new_brick.position = Vector2(pos_x, pos_y)
			parent_node.add_child(new_brick)
				
func add_score():
	score += 1
	call_deferred("check_game_clear")

func check_game_clear():
	var bricks = get_tree().get_nodes_in_group("bricks")
	
	var count = 0
	for b in bricks:
		if not b.is_queued_for_deletion():
			count += 1
	
	# 마지막 벽돌이 깨졌다면 패들 대기 모드로 진입
	if count == 0 and not is_waiting_for_paddle:
		is_waiting_for_paddle = true
		print("마지막 벽돌 파괴! 패들에 튕기기를 기다립니다...")

# 공이 패들에 부딪혔을 때 호출될 함수 (Ball.gd에서 신호를 줍니다)
func on_ball_hit_paddle():
	if is_waiting_for_paddle:
		is_waiting_for_paddle = false
		next_stage()

func next_stage():
	stage += 1 
	print("현재 단계 상승: ", stage)
	
	# 🎯 다음 스테이지 벽돌이 깔리는 순간 상단 라벨도 "X단계"로 업데이트!
	_update_in_game_score_label()
	
	spawn_bricks()

func _on_death_zone_body_entered(body):
	if body.name == "Ball" or body.is_in_group("ball"):
		game_over()

# ⭕ [중앙정렬 제거 유지] 에디터에 배치한 라벨 위치를 그대로 사용하는 game_over 함수
func game_over():
	if ball:
		ball.set_process(false)
		ball.set_physics_process(false)

	if game_over_ui:
		var complete_stage = stage - 1
		if complete_stage < 0: complete_stage = 0
		
		# 1. 안전하게 기본 display 함수 호출
		var title_msg = "GAME OVER"
		game_over_ui.display(title_msg, score, false)
		
		# 2. ScoreLabel을 찾아 결과창 텍스트 내용만 업데이트합니다.
		var score_label = game_over_ui.get_node_or_null("ScoreLabel")
		
		if score_label:
			# 이 UI가 현재 '구슬 게임'에 의해 켜졌음을 증명하는 태그 지정
			game_over_ui.set_meta("game_type", "marble")
			
			# 구슬 게임 전용 문구로 텍스트 내용만 업데이트
			var final_msg = str(complete_stage) + "단계 완료"
			if complete_stage <= 0:
				final_msg = "0단계 완료"
			score_label.text = final_msg

func _exit_tree():
	DisplayServer.screen_set_orientation(4)
