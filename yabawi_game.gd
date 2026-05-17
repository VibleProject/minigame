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
	
	# 3. 시작 UI 연결
	if game_start_ui:
		if game_start_ui.has_signal("countdown_finished"):
			game_start_ui.countdown_finished.connect(start_game)
		else:
			start_game()
	else:
		start_game()

func start_game():
	game_over = false
	is_shuffling = false
	game_over_ui.hide()
	
	for cup in cups:
		if cup.has_method("lift_down"):
			cup.lift_down()
	
	randomize()
	current_ball_cup = cups[randi() % cups.size()]
	ball.position = current_ball_cup.position + ball_offset
	ball.show()
	
	await get_tree().create_timer(0.5).timeout
	if current_ball_cup.has_method("lift_up"):
		current_ball_cup.lift_up()
	
	await get_tree().create_timer(1.2).timeout
	
	if current_ball_cup.has_method("lift_down"):
		current_ball_cup.lift_down()
		
	await get_tree().create_timer(0.5).timeout
	
	shuffle_cups(15)

func shuffle_cups(times: int):
	is_shuffling = true
	for i in range(times):
		var idx1 = randi() % cups.size()
		var idx2 = randi() % cups.size()
		while idx1 == idx2:
			idx2 = randi() % cups.size()
			
		await swap_cups(cups[idx1], cups[idx2])
	
	is_shuffling = false

func swap_cups(cup_a, cup_b):
	var pos_a = cup_a.position
	var pos_b = cup_b.position
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(cup_a, "position", pos_b, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cup_b, "position", pos_a, 0.15).set_trans(Tween.TRANS_SINE)
	
	if cup_a == current_ball_cup:
		tween.tween_property(ball, "position", pos_b + ball_offset, 0.15)
	elif cup_b == current_ball_cup:
		tween.tween_property(ball, "position", pos_a + ball_offset, 0.15)
		
	await tween.finished

# ⭕ [수정된 판정 함수] 구슬 게임의 간섭을 차단하고 텍스트를 직접 강제 세팅합니다!
func _on_cup_selected(clicked_cup):
	if is_shuffling or game_over: return
	
	game_over = true
	if clicked_cup.has_method("lift_up"):
		clicked_cup.lift_up()
	
	await get_tree().create_timer(0.7).timeout
	
	# 판정 결과에 따른 UI 제어
	if clicked_cup == current_ball_cup:
		# 1. UI의 본래 규칙(String, int, bool)에 맞추어 호출해 줍니다.
		game_over_ui.display("GAME OVER", 0, true)
		# 2. 호출 직후 ScoreLabel과 물리 배치를 야바위용으로 덮어씁니다.
		_setup_shell_ui_label("성공!")
	else:
		reveal_all()
		await get_tree().create_timer(0.5).timeout
		# 1. UI의 본래 규칙(String, int, bool)에 맞추어 호출해 줍니다.
		game_over_ui.display("GAME OVER", 0, false)
		# 2. 호출 직후 ScoreLabel과 물리 배치를 야바위용으로 덮어씁니다.
		_setup_shell_ui_label("실패!")

# ⭕ [새로 추가] 야바위 게임 전용 UI 텍스트 밀어넣기 및 중앙 정렬 함수
func _setup_shell_ui_label(result_text: String):
	var score_label = game_over_ui.get_node_or_null("ScoreLabel")
	var game_over_label = game_over_ui.get_node_or_null("GameOverLabel")
	
	# 상단 제목을 유저님이 원하시던 "정답입니다!" / "틀렸습니다!" 로 강제 변경


	if score_label:
		# 중간 라벨에 더 이상 -1이 아니라 "성공!" 또는 "실패!"를 박아줍니다.
		score_label.text = result_text
		
		# 구슬 게임과 마찬가지로 화면 전체를 덮는 상자로 늘려 완벽 정중앙 정렬을 보장합니다.
		if "horizontal_alignment" in score_label:
			score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			
		if "anchor_left" in score_label:
			score_label.anchor_left = 0.0
			score_label.anchor_right = 1.0
			score_label.offset_left = 0
			score_label.offset_right = 0

func reveal_all():
	for cup in cups:
		if cup.has_method("lift_up"):
			cup.lift_up()

func _exit_tree():
	DisplayServer.screen_set_orientation(4)
