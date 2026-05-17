extends Control

func _ready() -> void:
	# 메인 메뉴가 켜지자마자 세로 도화지와 세로 방향 고정
	get_viewport().content_scale_size = Vector2i(720, 1280)
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	
	get_tree().paused = false

func _on_yabawi_game_pressed():
	get_tree().change_scene_to_file("res://yabawi_game.tscn")

func _on_dino_game_pressed():
	get_tree().change_scene_to_file("res://dino_game.tscn")

func _on_ball_game_pressed():
	get_tree().change_scene_to_file("res://ball_game.tscn")
