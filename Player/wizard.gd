extends CharacterBody2D
@onready var animations = $Animations
const GRAVITY = 980 #* 60
const FALL_LIMIT_VELOCITY = 300
const FALL_COMPENSATION = 100
const FALL_CROUCH_BOOST = 50
const base_jump_force =  -20000
var base_speed = 10000 #* 60
var facing_direction = 0
var last_facing_direction
var canDash = true
var is_dashing = false


func _ready():
	$Animations.play("walking")

func _physics_process(delta):
	_manage_movement(delta)
	_manage_animations()
	move_and_slide()

func _manage_movement(delta):
	facing_direction = Input.get_vector("move_left","move_right","face_up","face_down").normalized()
	facing_direction[0] = sign(facing_direction[0])
	facing_direction[1] = sign(facing_direction[1])
	#move left and right while not dashing
	#TODO debe mejorarse el input dash, con el fin de que al dashear y un poco despues ingresar
	#input debe seguir esa direccion
	#IDEA: Celeste al parecer conserva la direccion a la que Madeline esta observando
	#como base madeline dashea para ese lado por default (sin input), si dashea y pocos 
	#frames despues se mueve seguira esa direccion.
	
	
	if is_dashing:
		velocity = last_facing_direction * Vector2(500,350)
	else:
		velocity.x = base_speed * facing_direction[0] * delta
	#gravity
	if velocity.y < FALL_LIMIT_VELOCITY:
		velocity.y += GRAVITY * delta
	if is_on_floor():
		canDash = true
		is_dashing = false

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
		if canDash:
			last_facing_direction = facing_direction
			_dash_jump()
	#base gravity

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
	



func _on_buffer_jump_timeout():
	if is_on_floor():
		#velocity.y = base_jump_force * get_physics_process_delta_time()
		print("buffered jump")

	


func _on_dashing_time_timeout():
	is_dashing = false
