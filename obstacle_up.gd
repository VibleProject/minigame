extends Area2D # 🎯 에러 해결 핵심: 노드 타입에 맞춰 Area2D로 정확히 선언합니다!

@export var speed = 500.0 
var score_added = false 
var is_dead = false     

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if is_dead or Engine.time_scale == 0.0: return
	position.x -= speed * delta
	
	var main_node = get_tree().current_scene
	
	# ⭕ 병뚜껑의 완벽한 점수 획득 로직 100% 재현
	if position.x < 0 and not score_added and not is_dead:
		score_added = true 
		if main_node and "score" in main_node:
			if main_node.is_game_started: 
				main_node.score += 1
				print("하늘 장애물 통과! 점수 상승: ", main_node.score)
	
	if position.x < -500:
		queue_free()

# 🚨 [Area2D 전용 충돌 감지] 부딪히는 순간 0초 컷 즉시 정지
func _on_body_entered(body: Node2D) -> void:
	if is_dead: return 
	
	# 플레이어 노드 이름인 "Player"와 정확히 매칭합니다.
	if body.name == "Player" or body.is_in_group("player"):
		is_dead = true
		score_added = true # 죽는 순간 점수판 잠금 (1점 버그 방지)
		
		# ⏱️ 닿는 즉시 시간을 분자 단위로 얼려버립니다.
		Engine.time_scale = 0.0
		
		# 감지 시스템 오프 및 연산 셧다운
		monitoring = false
		monitorable = false
		set_process(false)
		set_physics_process(false)
		
		# 메인 게임오버 호출
		var main_node = get_tree().current_scene
		if main_node and main_node.has_method("game_over"):
			main_node.game_over()
