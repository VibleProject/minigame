extends CanvasLayer

# 노드 참조 (유저님의 기존 씬 구조에 맞춤)
@onready var game_over_label = get_node_or_null("GameOverLabel") 
@onready var score_label = get_node_or_null("ScoreLabel")
@onready var retry_button = get_node_or_null("RetryButton")
@onready var menu_button = get_node_or_null("MenuButton")

func _ready():
	hide() # 시작할 때는 숨김
	process_mode = Node.PROCESS_MODE_ALWAYS # 게임이 일시정지되어도 UI는 작동하도록 설정

# ⭕ 야바위/구슬 게임 모두 호환되도록 2번째 인자를 원래대로 int로 유지합니다.
func display(title_text: String, score_val: int, is_victory: bool = false):
	# 1. 팝업 제목 설정 (GameOverLabel이 존재할 경우 문구를 변경합니다)
	if game_over_label:
		game_over_label.text = title_text
		game_over_label.show()
	
	# 2. 점수 라벨 설정
	if score_label:
		score_label.text = str(score_val)
		score_label.show()
		
	# 3. 하단 버튼들 표시
	if retry_button: retry_button.show()
	if menu_button: menu_button.show()
	
	# ⭕ [핵심 해결책] 숨겨져 있던 UI 레이어 전체를 화면에 짠! 하고 나타내줍니다.
	show() 

func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
