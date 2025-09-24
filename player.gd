extends CharacterBody2D

# --- Movement settings ---
const SPEED = 200
const JUMP_FORCE = -300
const GRAVITY = 900
const DASH_SPEED = 300
const DASH_TIME = 0.15

# --- Timers ---
const COYOTE_TIME = 0.15   # seconds after leaving ground to still allow jump
const JUMP_BUFFER = 0.15   # seconds jump input is stored

# --- State variables ---
var jumps_left = 1
var is_dashing = false
var can_dash = true  # <--- new flag
var dash_timer = 0.0
var coyote_timer = 0.0
var jump_buffer_timer = 0.0

func _physics_process(delta: float) -> void:
	# --- Input ---
	var input_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Track coyote time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		jumps_left = 1
		can_dash = true   # reset dash when grounded
	else:
		coyote_timer -= delta

	# Track jump buffer
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer -= delta

	# --- Horizontal movement ---
	if not is_dashing:
		velocity.x = input_dir * SPEED

	# --- Gravity ---
	if not is_on_floor() and not is_dashing:
		velocity.y += GRAVITY * delta

	# --- Jump logic (coyote + buffer + double jump) ---
	if jump_buffer_timer > 0 and (coyote_timer > 0 or jumps_left > 0):
		velocity.y = JUMP_FORCE
		jump_buffer_timer = 0
		if coyote_timer <= 0:
			jumps_left -= 1

	# --- Dash logic ---
	if Input.is_action_just_pressed("shift") and not is_dashing and can_dash:
		if input_dir != 0:
			is_dashing = true
			dash_timer = DASH_TIME
			velocity.x = input_dir * DASH_SPEED
			velocity.y = 0
			can_dash = false  # consume dash

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	# --- Move character ---
	move_and_slide()
