extends CharacterBody2D
@onready var animations = $Animations
const GRAVITY = 20
const FALL_LIMIT_VELOCITY = 350
const FALL_CROUCH_BOOST = 65
const base_jump_force =  -330
var base_speed = 200
var facing_direction = 0

func _ready():
	$Animations.play("walking")

func _physics_process(delta):
	_manage_movement(delta)
	_manage_animations()
	move_and_slide()
	
	if velocity.y != 0:
		if velocity.y <0:
			print("jumping: ")
		else:
			print("falling")
		print(velocity.y)

func _manage_movement(delta):
	facing_direction = Input.get_axis("move_left","move_right")
	#base gravity
	if velocity.y <= FALL_LIMIT_VELOCITY:
		velocity.y += GRAVITY
	else:
		velocity.y = FALL_LIMIT_VELOCITY
	#move left and right
	velocity.x = base_speed * facing_direction
	#jump mechanic
	#like mario holding longer makes it jump higher
	
	#the longer the input the higher the jump, velocity defined
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = base_jump_force
	if Input.is_action_pressed("crouch"): #falling state, fall is faster than jump if it crouches
		velocity.y = FALL_CROUCH_BOOST + FALL_LIMIT_VELOCITY
	if velocity.y < 0 and Input.is_action_just_released("jump"): #jumping state
		velocity.y += GRAVITY * 10
		#maybe an input buffer for jumping right at the moment it touches floor
		
		
	
	
	#if input was jump then velocity y is decreased
	
	
	
	

func _manage_animations():
	if facing_direction == -1:
		animations.flip_h = true
	if facing_direction == 1:
		animations.flip_h = false
	

