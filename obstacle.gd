extends Area2D

@export var speed = 500.0 
var score_added = false # ⭕ 점수가 중복으로 들어가는 것을 막는 안전장치

func _ready() -> void:
	# 게임이 일시정지(paused)되어도 이 장애물은 끝까지 걸어가도록 설정
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	position.x -= speed * delta
	
	# ⭕ [핵심 로직] 장애물이 공룡을 지나쳐서 왼쪽으로 넘어갔을 때 직접 점수를 올립니다.
	# (보통 공룡의 x 위치가 100~200 사이일 테니, 0보다 작아지면 확실히 지나친 것입니다)
	if position.x < 0 and not score_added:
		score_added = true # 점수를 한 번만 올리도록 잠금
		
		# 현재 최상위 메인 게임 씬을 직접 찾아서 score 변수를 올립니다.
		var main_node = get_tree().current_scene
		if main_node and "score" in main_node:
			if main_node.is_game_started: # 게임이 진행 중일 때만
				main_node.score += 1
				print("장애물 통과! 점수 상승: ", main_node.score) # 출력창 확인용
	
	# 화면 밖으로 완전히 나가면 메모리 삭제
	if position.x < -500:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# 공룡과 부딪히면 메인의 game_over() 호출
	if body.name == "Player" or body.is_in_group("player"):
		var main_node = get_tree().current_scene
		if main_node and main_node.has_method("game_over"):
			main_node.game_over()
