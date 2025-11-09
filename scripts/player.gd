extends CharacterBody2D

# Movement constants
@export var max_speed: float = 250.0
@export var acceleration: float = 475.0
@export var deceleration: float = 650.0
@export var dash_speed: float = 500.0 # Increased for a more noticeable dash

# Jump constants
@export var jump_velocity: float = -320.0
@export var walljump_force: float = 250.0
@export var wall_slide_gravity: float = 50.0
var just_wall_jumped = false
var can_dash = true
var can_coyote_jump = false


# Timers for mechanics
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var walljump_timer = $WallJumpTimer
@onready var coyote_timer = $CoyoteTimer

# Get gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_on_floor = false

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Update floor status for coyote time
	if is_on_floor():
		was_on_floor = true
		coyote_timer.stop()
		can_dash = true
		can_coyote_jump = true
	elif was_on_floor:
		was_on_floor = false
		coyote_timer.start()

	_handle_movement(delta)
	_handle_jump()
	_handle_dashing()
	_handle_animations()
	
	move_and_slide()

# This function handles horizontal movement.
func _handle_movement(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		
	# Flip the sprite to match the movement direction
	if direction > 0:
		animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false

# This function handles all jump mechanics, including wall jumps.
func _handle_jump():
	var direction = Input.get_axis("move_left", "move_right")
	
	# Wall slide
	if is_on_wall() and not is_on_floor() and direction != 0:
		velocity.y = min(velocity.y, wall_slide_gravity)
	
	# Regular jump and Coyote time jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
			can_coyote_jump = false # Disable coyote jump for the current air time
			coyote_timer.stop()
		elif can_coyote_jump and not coyote_timer.is_stopped():
			velocity.y = jump_velocity
			can_coyote_jump = false # Consume the coyote jump
			coyote_timer.stop()
	# Wall jump
	if Input.is_action_just_pressed("jump") and is_on_wall() and not is_on_floor() and not just_wall_jumped:
		
		if ray_cast_left.is_colliding():
			velocity.y = jump_velocity
			velocity.x = -walljump_force
			just_wall_jumped = true
			walljump_timer.start()
			coyote_timer.stop()
			
		elif ray_cast_right.is_colliding():
			velocity.y = jump_velocity
			velocity.x = walljump_force
			just_wall_jumped = true
			walljump_timer.start()
			coyote_timer.stop()

func _handle_dashing():
		if Input.is_action_just_pressed("dash") and can_dash == true and not is_on_floor():

			
			#cardinal directions
			#dash up
			if Input.is_action_pressed("jump"):
				velocity.y = -dash_speed

			#dash left
			elif Input.is_action_pressed("move_left"):
				velocity.x = -dash_speed
				
			#dash down
			elif Input.is_action_pressed("anti_jump"):
				velocity.y = dash_speed

			#dash right
			elif Input.is_action_pressed("move_right"):
				velocity.x = dash_speed
				
				
			#diagonals
			#dash up-left
			if Input.is_action_pressed("jump") and Input.is_action_pressed("move_left"):
				velocity.y = -dash_speed/1.4
				velocity.x = -dash_speed/1.4
				
			#dash up-right
			elif Input.is_action_pressed("jump") and Input.is_action_pressed("move_right"):
				velocity.y = -dash_speed/1.4
				velocity.x = dash_speed/1.4
				
			#dash down-left
			elif Input.is_action_pressed("anti_jump") and Input.is_action_pressed("move_left"):
				velocity.y = dash_speed/1.4
				velocity.x = -dash_speed/1.4
				
			#dash down-right
			elif Input.is_action_pressed("anti_jump") and Input.is_action_pressed("move_right"):
				velocity.y = dash_speed/1.4
				velocity.x = dash_speed/1.4
				
			can_dash = false
				
# This function handles animations based on the player's state.
func _handle_animations():
	if is_on_floor():
		if abs(velocity.x) > 10:
			animated_sprite.play("Run")
		else:
			animated_sprite.play("Idle")
	else:
		animated_sprite.play("Jump")

# Reset wall jump state after a brief timer
func _on_walljump_timer_timeout():
	just_wall_jumped = false
	print("timer ended")

# Reset coyote time after falling off a platform
func _on_coyote_timer_timeout():
	can_coyote_jump = false


func _on_area_2d_body_entered(_body: Node2D) -> void:
	pass
	
