extends CharacterBody2D
@onready var animations = $Animations
const GRAVITY = 800 #* 60
const FALL_LIMIT_VELOCITY = 300
const FALL_COMPENSATION = 100
const FALL_CROUCH_BOOST = 50
const base_jump_force =  -20000
var base_speed = 10000 #* 60
var facing_direction = 0
var canDash = true
var is_dashing = false


func _ready():
	$Animations.play("walking")

func _physics_process(delta):
	_manage_movement(delta)
	_manage_animations()
	move_and_slide()
	

func _manage_movement(delta):
	facing_direction = Input.get_axis("move_left","move_right")
	#move left and right
	velocity.x = base_speed * facing_direction * delta
	#gravity
	if velocity.y < FALL_LIMIT_VELOCITY:
		velocity.y += GRAVITY * delta

	#jump mechanic
	#base jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = base_jump_force * delta
		else:
			_buffer_jump()

	#crouch fall
	const speed_threshold = -200
	if Input.is_action_pressed("crouch") and velocity.y > speed_threshold: #falling state, fall is faster than jump if it crouches
		velocity.y = FALL_CROUCH_BOOST + FALL_LIMIT_VELOCITY
	
	#fall compensation
	if velocity.y <= 0 and Input.is_action_just_released("jump"): #jumping state and release jump
		velocity.y += FALL_COMPENSATION
	
	#dash jump
	if Input.is_action_just_pressed("dash"):
		_dash_jump(delta)
	
	velocity.x = lerp(velocity.x,0.0,0.1)
	
	#base gravity


func _dash_jump(delta):
	if canDash:
		var dash_direction = Input.get_vector("move_left","move_right","face_up","face_down")
		#velocity = velocity + dash_direction.normalized() * Vector2(1000,1000)
		#print(velocity)
		dash_direction = dash_direction.normalized()
		if abs(dash_direction.x) > 0.5:
			dash_direction.x = sign(dash_direction.x)
		elif abs(dash_direction.x) < 0.5:
			dash_direction.x = sign(dash_direction.x)
		
		if abs(dash_direction.y) > 0.5:
			dash_direction.y = sign(dash_direction.y)
		elif abs(dash_direction.y) < 0.5:
			dash_direction.y = sign(dash_direction.y)
			
		velocity = dash_direction * Vector2(2000*60,400*60) * delta
		
	
	
func _buffer_jump():
	$buffer_jump.start()


func _manage_animations():
	if facing_direction == -1:
		animations.flip_h = true
	if facing_direction == 1:
		animations.flip_h = false
	



func _on_buffer_jump_timeout():
	if is_on_floor():
		#velocity.y = base_jump_force * get_physics_process_delta_time()
		print("buffered jump")
	


