extends Node2D

var is_game_started: bool = true
var score = 0
var current_speed = 500.0   
var speed_increment = 20.0  

# 장애물 씬 로드
var obstacle_scene = preload("res://obstacle.tscn")
var obstacle_up_scene = preload("res://obstacle_up.tscn")

@onready var ui = get_node_or_null("DinoGameOverUI") 

# 메인 스크립트 (예: DinoMain.gd 등)

func _ready() -> void:
	# 🚨 [재시작 버그 해결 핵심] 얼어붙었던 전 세계의 시간을 원래대로(1.0) 녹입니다!
	Engine.time_scale = 1.0 
	
	# 기존에 있던 유저님의 ready 코드들...
	get_viewport().content_scale_size = Vector2i(1280, 720) 
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	
	await get_tree().process_frame
	
	randomize()
	get_tree().paused = false # 일시정지도 함께 해제
	is_game_started = true
	score = 0
	current_speed = 500.0 
	
	if ui: ui.hide() 
	if has_node("ObstacleTimer"): $ObstacleTimer.start()

func _on_obstacle_timer_timeout() -> void:
	if not is_game_started: return
	
	var obs = null
	
	# 🎯 [8 : 2 확률 조정치] 
	# randf()는 0.0부터 1.0 사이의 소수를 뽑습니다.
	# 0.2 미만(20% 확률)이면 하늘 장애물, 그 외(80% 확률)에는 바닥 장애물을 만듭니다.
	var random_value = randf()
	
	if random_value < 0.2 and obstacle_up_scene != null:
		# ☁️ 하늘 장애물 생성 (20%)
		obs = obstacle_up_scene.instantiate()
		obs.position = Vector2(1400, 380) 
	elif obstacle_scene != null:
		# 🍾 바닥 병뚜껑 장애물 생성 (80%)
		obs = obstacle_scene.instantiate()
		obs.position = Vector2(1400, 550) 

	if obs != null:
		if "speed" in obs: 
			obs.speed = current_speed
		add_child(obs)
		
		current_speed = min(current_speed + speed_increment, 1200)

	if has_node("ObstacleTimer") and is_game_started:
		$ObstacleTimer.wait_time = randf_range(1.2, 2.8)
		$ObstacleTimer.start()

# 🚨 메인 게임오버 함수 (실행 시 즉시 모든 연산 정지)
func game_over():
	if not is_game_started: return
	is_game_started = false
	
	if has_node("ObstacleTimer"): 
		$ObstacleTimer.stop()
		
	get_tree().paused = true # 👈 이 코드가 실행되는 순간 고도의 물리 엔진과 타이머가 즉시 멈춥니다!
	
	if ui:
		ui.show()
		if ui.has_method("display"):
			ui.display("GAME OVER", score, false)
