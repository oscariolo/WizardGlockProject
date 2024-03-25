extends CharacterBody2D
@onready var animations = $Animations
const GRAVITY = 980 #* 60
const FALL_LIMIT_VELOCITY = 300
const FALL_COMPENSATION = 100
const FALL_CROUCH_BOOST = 50
const BASE_JUMP_FORCE =  -20000
const DASHING_VELOCITY = Vector2(500,350)
var base_speed = 10000 #* 60
var facing_direction = Vector2(0,0)
var last_facing_direction
var canDash = true
var is_dashing = false
var has_compensated = false


func _ready():
	$Animations.play("idle")

func _physics_process(delta):
	_manage_movement(delta)
	_manage_animations()
	move_and_slide()

func _manage_movement(delta):
	facing_direction = Input.get_vector("move_left","move_right","face_up","face_down").normalized()
	facing_direction[0] = sign(facing_direction[0])
	facing_direction[1] = sign(facing_direction[1])
	
	if is_on_floor():
		has_compensated = false
	#gravity
	if velocity.y < FALL_LIMIT_VELOCITY:
		velocity.y += GRAVITY * delta
	
	#move left and right while not dashing
	
	if is_dashing:
		velocity = last_facing_direction * DASHING_VELOCITY
	else:
		velocity.x = base_speed * facing_direction[0] * delta
	
	if is_on_floor() and not is_dashing:
		canDash = true
		is_dashing = false

	#jump mechanic
	#base jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = BASE_JUMP_FORCE * delta
		else:
			_buffer_jump()

	#crouch fall
	const speed_threshold = -200
	if Input.is_action_pressed("crouch") and velocity.y > speed_threshold: #falling state, fall is faster than jump if it crouches
		velocity.y = FALL_CROUCH_BOOST + FALL_LIMIT_VELOCITY
	
	#fall compensation
	if velocity.y <= 0 and Input.is_action_just_released("jump") and not has_compensated: #jumping state and release jump
		velocity.y += 120
		has_compensated = true
	
		
	
	#dash jump
	if Input.is_action_just_pressed("dash"):
		if canDash:
			if facing_direction[0] == 0 and facing_direction[1] != 1 and facing_direction[1] != -1:
				if animations.flip_h == false:
					facing_direction[0] = 1
				else:
					facing_direction[0] = -1
			last_facing_direction = facing_direction
			_dash_jump()

func _dash_jump():
	$dashing_time.start()
	canDash = false
	is_dashing = true
	
func _buffer_jump():
	$buffer_jump.start()


func _manage_animations():
	if facing_direction[0] == -1:
		animations.flip_h = true
	if facing_direction[0] == 1:
		animations.flip_h = false
	if velocity.x != 0:
		$Animations.play("walking")
	else:
		$Animations.play("idle")
	

func _on_buffer_jump_timeout():
	if is_on_floor():
		velocity.y = BASE_JUMP_FORCE * get_physics_process_delta_time()

func _on_dashing_time_timeout():
	is_dashing = false
