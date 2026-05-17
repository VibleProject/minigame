extends CharacterBody2D

@export var speed: float = 700.0
var velocity_dir: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("ball")
	collision_layer = 1
	collision_mask = 1
	global_position = Vector2(570, 600) 
	launch()

func launch():
	velocity_dir = Vector2(randf_range(-0.5, 0.5), 1.0).normalized()

func _physics_process(delta):
	# 이동 및 충돌 예측
	var collision = move_and_collide(velocity_dir * speed * delta, false, 0.15)
	
	if collision:
		var collider = collision.get_collider()
		if not collider: return

		# 1. 패들 처리 (이름이나 그룹이 패들일 때)
		if collider.is_in_group("paddle") or "Paddle" in collider.name:
			# ⭕ [새로 추가] 패들에 충돌하는 순간, 메인 스크립트에 "패들 부딪힘!" 신호를 보냅니다.
			# 마지막 벽돌이 깨진 상태라면 이 타이밍에 다음 단계로 자연스럽게 넘어갑니다.
			var main_scene = get_tree().current_scene
			if main_scene and main_scene.has_method("on_ball_hit_paddle"):
				main_scene.on_ball_hit_paddle()
			
			# 들어온 각도 그대로 자연스럽게 정반사(bounce) 시킵니다.
			velocity_dir = velocity_dir.bounce(collision.get_normal()).normalized()
			
			# 물리 엔진 한계로 Y축이 아래로 향하는 예외가 생기면 위(-Y)로 강제 반전
			if velocity_dir.y > 0:
				velocity_dir.y = -velocity_dir.y
				velocity_dir = velocity_dir.normalized()
			return # 패들 처리가 끝났으므로 즉시 함수 종료

		# 2. 벽돌 처리
		elif collider.is_in_group("bricks"):
			collider.queue_free()
			if get_parent().has_method("add_score"):
				get_parent().add_score()
			velocity_dir = velocity_dir.bounce(collision.get_normal())
			return # 벽돌 처리 끝났으므로 즉시 함수 종료
		
		# 3. 일반 벽/천장 처리 (좌우 벽, 천장에 부딪혔을 때)
		else:
			velocity_dir = velocity_dir.bounce(collision.get_normal())
			
		# 4. 각도 보정 (무한 수평 왕복 방지)
		if abs(velocity_dir.y) < 0.25:
			velocity_dir.y = -0.3 if velocity_dir.y < 0 else 0.3
			velocity_dir = velocity_dir.normalized()
