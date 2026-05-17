extends CanvasLayer

@onready var start_button = get_node_or_null("StartButton") # 에디터의 시작 버튼 이름과 맞추세요
@onready var back_to_menu_button = get_node_or_null("BackButton") # 에디터의 뒤로가기 버튼 이름과 맞추세요

func _ready() -> void:
	# 1. 일시정지나 씬 로드 상태와 상관없이 UI가 상시 반응하도록 설정
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	
	# 2. UI가 화면에 안착하면 즉시 공룡 게임용 '가로 모드(0)'로 화면을 돌립니다.
	await get_tree().process_frame
	DisplayServer.screen_set_orientation(0) # 0: 가로 모드 (Landscape)

	# 3. 버튼들의 클릭 이벤트를 안전하게 연결합니다.
	if start_button and not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)
		
	if back_to_menu_button and not back_to_menu_button.pressed.is_connected(_on_back_to_menu_pressed):
		back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)

# 🏁 게임 시작 버튼 클릭 시
func _on_start_button_pressed() -> void:
	print("공룡 게임 플레이 시작!")
	var gameplay_scene_path = "res://dino_game.tscn" 
	if ResourceLoader.exists(gameplay_scene_path):
		get_tree().change_scene_to_file(gameplay_scene_path)

# 🏠 뒤로가기 (메인 메뉴로 복귀) 버튼 클릭 시
func _on_back_to_menu_pressed() -> void:
	print("메인 메뉴로 복귀")
	# 메뉴 화면으로 빠져나갈 때는 다시 깔끔하게 '세로 모드(1)'로 돌려놓습니다.
	DisplayServer.screen_set_orientation(1) # 1: 세로 모드 (Portrait)
	
	await get_tree().create_timer(0.05).timeout # 화면 회전 안정화 시간
	
	var menu_scene_path = "res://main_menu.tscn"
	if ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
