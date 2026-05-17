extends CanvasLayer

@onready var label = get_node_or_null("ScoreLabel") 
@onready var retry_button = get_node_or_null("Button") 
@onready var menu_button = get_node_or_null("MenuButton") 

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if label: label.hide()
	if retry_button:
		retry_button.hide()
		if not retry_button.pressed.is_connected(_on_retry_button_pressed):
			retry_button.pressed.connect(_on_retry_button_pressed)
			
	if menu_button:
		menu_button.hide()
		if not menu_button.pressed.is_connected(_on_menu_button_pressed):
			menu_button.pressed.connect(_on_menu_button_pressed)

func display(title_text: String, score_val: int, is_victory: bool = false):
	if label:
		label.text = "Score: " + str(score_val)
		label.show()
	if retry_button: retry_button.show()
	if menu_button: menu_button.show()

# 🔄 다시하기 버튼 (수정 완료)
func _on_retry_button_pressed():
	# 🚨 [중요] 하늘 장애물이 얼려버린 엔진 시간을 다시 원래대로(1.0) 녹여줍니다!
	Engine.time_scale = 1.0
	get_tree().paused = false 
	get_tree().reload_current_scene() 

# 🏠 메뉴화면 버튼 (수정 완료)
func _on_menu_button_pressed() -> void:
	# 1. 얼어붙었던 엔진 시간과 일시정지를 완전히 풀어줍니다.
	Engine.time_scale = 1.0
	get_tree().paused = false
	
	# 2. [화면 가로 버그 해결] 메뉴 화면이 세로 모드 기반이라면 세로로 원상복구!
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	
	# 3. 🎯 원래 사용하시는 실제 메뉴 씬 파일 경로를 입력해 주세요!
	# (예: res://menu.tscn 또는 res://main_menu.tscn 등 유저님의 파일명으로 교체)
	get_tree().change_scene_to_file("res://main_menu.tscn")
