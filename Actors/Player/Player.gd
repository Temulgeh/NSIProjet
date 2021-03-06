extends KinematicBody2D


# all of these states.... all of these conditions.... this could have been done
# more easily by storing the constants into variables and then modifying said
# variables


# TO DO:

# Coyote time for bouncing / not for the wall but for the input
# also the delay before bouncing is now a feature (combined with dash cancelling
# so that it's consistent)

# for the two things above: MOMENTUM CONSERVATION JUST LIKE IN C******

# Bring back dash cancelling + see point above (when dashing change the momentum
# memory by something less than the actual velocity)

# maybe fix down diagonal dashes

# Missing animations: wallslide, landing, changing directions, ledge balancing
# rolling

# more particles!!!!

# More squash and stretch in general


export var facing_left: bool


# Physics constants

const RUN_SPEED_MAX = 90.0
const RUN_ACC = 380.0
const RUN_AIR_ACC = RUN_ACC * .75
const GRAVITY = 650.0
const JUMP_FORCE = -230.0
const JUMP_TIME = .1
const COYOTE_TIME = .1
const COYOTE_TIME_WHEN_DASHING = .07
const JUMP_SPBOOST_MULTIPLIER = 1.38
const JUMP_SPBOOST_MAX = RUN_SPEED_MAX * JUMP_SPBOOST_MULTIPLIER * JUMP_SPBOOST_MULTIPLIER
const STICKY_LANDING_MIN = 20.0
const STICKY_LANDING_FORCE = 70.0
const GRAVMOD_SHORTHOP_MULTIPLIER = 4.9
const GRAVMOD_SHORTHOP_BEGIN = JUMP_FORCE
const GRAVMOD_SHORTHOP_END = JUMP_FORCE * .275
const GRAVMOD_BIGLEAP_MULTIPLIER = .7
const GRAVMOD_BIGLEAP_BEGIN = JUMP_FORCE * .2
const GRAVMOD_BIGLEAP_END = -GRAVMOD_BIGLEAP_BEGIN
const WALLJUMP_FORCE = JUMP_FORCE * .8
const WALLJUMP_PUSH = RUN_SPEED_MAX * 1.3
const WALLJUMP_PUSH_NEUTRAL = RUN_SPEED_MAX * 1.3
const WALLJUMP_MARGIN = 1.5
const WALLJUMP_CONTROL_REMOVED_TIME = .15
const WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL = 0.0
const VELOCITY_CONSERVATION_TIME = .065
const FALL_SPEED = -JUMP_FORCE * 1.15
const FASTFALL_SPEED = -JUMP_FORCE * 1.5
const FASTFALL_MULTIPLIER = 1.2
const FASTFALL_BEGIN = 0
const JUMP_SPEED_MAX = FASTFALL_SPEED
const WALLSLIDE_MIN_SPEED = 30.0
const WALLSLIDE_GRAVITY = 350.0
const WALLSLIDE_MAX_SPEED = 80.0
const WALLSLIDE_FCOUNT = 2

# actually not temporary lmao
const RUN_FRIC_TEMP = .72
const AIR_FRIC_TEMP = .85
const CORRECTION_FRIC_TEMP = .95
const CORRECTION_FRIC_ATTENUATED_TEMP = .97
const CORRECTION_FRIC_ATTENUATED_AIR_TEMP = .985
const AIR_Y_FRICTION_TEMP = CORRECTION_FRIC_TEMP
const CORRECTION_EVEN_MORE_FOR_JUMP_SPBOOSTS_TEMP = .97
const ROLLING_FRIC_ON_GROUND = .985
const ROLLING_FRIC_IN_AIR = 1.0
const ROLLING_FRIC_HOLDING = .997

# Dangerous constants

const EXTENTS_DEFAULT = Vector2(3.9, 7.9)
const HITBOX_OFFSET_DEFAULT = Vector2(0.0, 0.0)

const EXTENTS_ROLLING = Vector2(3.9, 3.9)
const HITBOX_OFFSET_ROLLING = Vector2(0.0, 4.0)

# Rolling constants

const ROLLING_MIN_DURATION = .1

const ROLLING_ROTATION_ON_GROUND = .8
const ROLLING_ROTATION_IN_AIR = .2

const ROLL_MAX_SPEED = 50.0
const ROLL_ACCEL = 50.0

const ROLL_JUMP_FORCE = -170.0
const ROLL_JUMP_SPBOOST = 1.0

const ROLL_WALLJUMP_FORCE = -150.0
const ROLL_WALLJUMP_PUSH = ROLL_MAX_SPEED

const ROLL_DASH_EXIT_VEL_RATIO = .85

const ROLL_BOUNCINESS_X = .7
const ROLL_BOUNCINESS_Y = .55
const ROLL_BOUNCE_MIN_X = 45.0
const ROLL_BOUNCE_MIN_Y = 100.0

const BOUNCE_CEILING = 200.0
const BOUNCE_FLOOR = -320.0
const BOUNCE_WALL = -265.0

# Animation constants

const RUNNING_THRESHOLD = 10.0
const FALLING_THRESHOLD = 0.0

const CUTSCENE_WALKING_SPEED = 65.0

const DASH_REFILL_ANIM_DURATION = .1

const DASH_POSITION_OFFSET = 1

const ROLL_FACING_LEFT_ROTATION_OFFSET = .8

const ROLL_NB_OF_ANGLES = 12

# Dash constants

const DASH_DELAY = .1
const DASH_PRE_VEL_MULTIPLIER = 0
const DASH_SPEED = 350.0
const DASH_DURATION = .12
const DASH_REGAIN_AFTER_RATIO = .7
const DASH_EXIT_SPEED = 130.0
const DASH_DIAG_X_EXIT_SPEED = 200.0
const DASH_DIAG_Y_EXIT_SPEED = 250.0
const DASH_UP_EXIT_SPEED = 110.0
const DASH_SQUEEZE_AROUND_MAX = 3
const DASH_SQUEEZE_AROUND_CHECK_DISTANCE_MAX = 4

const DASH_EXIT_TIME = 0.0

# Bounce constants

#const BOUNCE_TIME = .1
#const BOUNCE_CHECK_DISTANCE = 2 * WALLJUMP_MARGIN
#const BOUNCE_DASH_HOLD_TIME = .06
#
#const BOUNCE_FROM_FLOOR = Vector2(0, -290)
#const BOUNCE_FROM_SIDE = Vector2(-280, -80)
#const BOUNCE_FROM_CEILING = Vector2(0, 400)
#
#const BOUNCE_REMOVE_CONTROL_TIME = .2
#
#const BOUNCE_DURATION = .2

# Camera constants

const DASH_SHAKE_DURATION = .2


var in_control_x: bool = true
var in_control_y: bool = true
var no_control_x_timer: float
var no_control_y_timer: float
var apply_gravity: bool = true
var no_gravity_timer: float

var velocity_conservation_timer = Vector2(VELOCITY_CONSERVATION_TIME, VELOCITY_CONSERVATION_TIME)

var velocity: Vector2
var direction_x: int
var direction_y: int
var jump_timer: float
var coyote_timer: float
#var bounce_timer: float
#var bounce_bounce_timer: float
#var bounce_dash_holder: float

var rolling: bool
var rolling_visually: bool
var unroll_cooldown: float
var ang_vel: float
var true_rotation: float
var can_roll: bool

var grounded: bool
var wallsliding: bool
var actually_wallsliding: bool
var wallslide_fcounter: int
var last_ground_y: float
var last_wall_normal: int
var jumping: bool

var dashing_allowed: bool
var dashing_refreshed: bool
var dash_direction: Vector2
var dash_cancel_timer: float
var dash_waiting: bool
var dashing: bool
var dash_timer: float
var dash_exit_timer: float
var stick_to_ceiling_timer: float
var facing: int

export var bouncing_allowed: bool
export var rolling_allowed: bool

var in_cutscene: bool
var cutscene_info # Global.CutscenePlayerInfo
var cutscene_velocity

var dying: bool

onready var collider = $CollisionShape2D

onready var animation_player = $AnimationPlayer
onready var anim_container = $SpriteContainer
onready var anim_idle = $SpriteContainer/SpriteIdle
onready var anim_run = $SpriteContainer/SpriteRun
onready var anim_jump = $SpriteContainer/SpriteJump
onready var anim_hangtime = $SpriteContainer/SpriteHangtime
onready var anim_fall = $SpriteContainer/SpriteFall
onready var anim_dash = $SpriteContainer/SpriteDash
onready var anim_roll = $SpriteContainer/SpriteRoll
onready var anim_rolling = $SpriteContainer/ViewportContainer/Viewport/circle

onready var anim_current
onready var anim_list = [anim_idle, anim_run, anim_jump, anim_hangtime,
						 anim_fall, anim_dash, anim_roll, anim_rolling]

var palette_normal_texture: StreamTexture
var palette_dash_texture: StreamTexture
var palette_white_texture: StreamTexture
var palette_white_petals_texture: StreamTexture
var palette_current: StreamTexture

var dash_refill_anim_timer: float

var dash_particles_packed: PackedScene
var dash_particles: Node


onready var anim_dash_raw_offset = anim_dash.offset

func _ready():
	Global.connect("DialogFinished",self,"DialogFinishedCode")
	Global.connect("DialogStarted",self,"DialogStartedCode")
	#what's up?
	Global.connect("MoveCharacter",self,"ForcedMoveCutscene")
	
	set_anim(anim_idle, "Idle")
	dashing_allowed = true
	dashing_refreshed = true
	facing = -1 if facing_left else 1
	can_roll = true
	
	palette_normal_texture = preload("res://Aseprite/Main character/Palette nonsense/normal_palette.png")
	palette_dash_texture = preload("res://Aseprite/Main character/Palette nonsense/dash_palette.png")
	palette_white_texture = preload("res://Aseprite/Main character/Palette nonsense/white_palette.png")
	palette_white_petals_texture = preload("res://Aseprite/Main character/Palette nonsense/white_petals_palette.png")
	palette_current = anim_container.material.get_shader_param("palette")
	
	dash_particles_packed = preload("res://Actors/Player/Particles/DashParticles.tscn")
	
	dash_particles = dash_particles_packed.instance()
	dash_particles.player_reference = self
	Global.where_particles_should_be.add_child(dash_particles)
	
	Global.camera.add_pt_of_interest(self, 1.0, INF, true)


func _physics_process(delta):
	direction_x = (
		int(Input.is_action_pressed("Right")) -
		int(Input.is_action_pressed("Left"))
	)
	direction_y = (
		int(Input.is_action_pressed("Down")) -
		int(Input.is_action_pressed("Up"))
	)
	if rolling:
		if velocity.x:
			facing = sign(velocity.x)
	elif direction_x == sign(velocity.x) and direction_x != 0 and in_control_x:
		facing = direction_x
	
	if in_cutscene and not dying:
		velocity.x = cutscene_velocity
	else:
		if not in_control_x:
			no_control_x_timer -= delta
			if no_control_x_timer <= 0:
				no_control_x_timer = 0
				in_control_x = true
		if not in_control_y:
			no_control_y_timer -= delta
			if no_control_y_timer <= 0:
				no_control_y_timer = 0
				in_control_y = true
		if not apply_gravity:
			no_gravity_timer -= delta
			if no_gravity_timer <= 0:
				no_gravity_timer = 0
				apply_gravity = true
	
	# Rolling
	
	if unroll_cooldown > 0:
		unroll_cooldown -= delta
		if unroll_cooldown < 0:
			unroll_cooldown = 0
	
	if Input.is_action_pressed("Roll") and can_roll:
		if not rolling:
			rolling = true
			unroll_cooldown = ROLLING_MIN_DURATION
			collider.shape.extents = EXTENTS_ROLLING
			collider.position = HITBOX_OFFSET_ROLLING
			true_rotation = 0
			reset_rotation()
	elif not unroll_cooldown and rolling:
		var temp_pos: Vector2 = position
		align_to_grid()
		collider.shape.extents = EXTENTS_DEFAULT
		collider.position = HITBOX_OFFSET_DEFAULT
		if test_move(transform, Vector2.ZERO):
			position = temp_pos
			collider.shape.extents = EXTENTS_ROLLING
			collider.position = HITBOX_OFFSET_ROLLING
		else:
			rolling = false
	
	# Landing and Sticky Landing
	
	if is_on_floor():
		if not grounded:
			if not rolling:
				var speed_excess: float = abs(velocity.x) - STICKY_LANDING_MIN
				if direction_x == 0 and speed_excess > 0:
					velocity.x -= sign(velocity.x) * min(STICKY_LANDING_FORCE, speed_excess)
			grounded = true
	else:
		var test_grounded = move_and_collide(Vector2(0, get_safe_margin()), true, true, true)
		if test_grounded and test_grounded.normal == Vector2.UP:
				grounded = true
		elif grounded:
			grounded = false
	
	if grounded:
		jumping = false
	if grounded and dashing_allowed:
		refill_dash()
	
	# Replace this mess (and also in the walljump code) with a "facing" variable
	# This will also make animations easier to implement
	# Note from the future: lmao no that didn't help you're still stuck with this mess
	if is_on_wall():
		if test_move(
			collider_transform(),
			Vector2(sign(velocity.x) * get_safe_margin(), 0)
		):
			last_wall_normal = -int(sign(velocity.x))
		else:
			last_wall_normal = int(sign(velocity.x))
		if not wallsliding:
			wallsliding = true
		wallslide_fcounter = WALLSLIDE_FCOUNT
	elif wallsliding:
		wallslide_fcounter -= 1
		if wallslide_fcounter <= 0:
			wallsliding = false
	
	# Acceleration and friction nonsense
	# this is a huge mess, see line 4
	# @ future me, have fun refactoring (or probably not)
	
	if in_control_x:
		if rolling:
			# fuck this i'm using a simpler code
			if abs(velocity.x) < ROLL_MAX_SPEED and direction_x:
				velocity.x += direction_x * ROLL_ACCEL * delta
			else:
				velocity.x *= (
					ROLLING_FRIC_HOLDING if sign(direction_x) == sign(velocity.x)
					else (
					ROLLING_FRIC_ON_GROUND if grounded else ROLLING_FRIC_IN_AIR
					)
				)
		else:
			if abs(velocity.x) > RUN_SPEED_MAX:
				if direction_x == 0:
					velocity.x -= min(
						abs(velocity.x) - RUN_SPEED_MAX,
						abs(velocity.x) * (1 - CORRECTION_FRIC_TEMP)
					) * sign(velocity.x)
				elif sign(direction_x) == sign(velocity.x):
					velocity.x -= min(
						abs(velocity.x) - RUN_SPEED_MAX,
						abs(velocity.x) * (1 - (
							CORRECTION_FRIC_ATTENUATED_TEMP if grounded else
							CORRECTION_FRIC_ATTENUATED_AIR_TEMP
						))
					) * sign(velocity.x)
				else:
					velocity.x -= min(
						abs(velocity.x) - RUN_SPEED_MAX,
						abs(velocity.x) * (1 - CORRECTION_FRIC_TEMP * (
							RUN_FRIC_TEMP if grounded else AIR_FRIC_TEMP
						))
					) * sign(velocity.x)
				if abs(velocity.x) < JUMP_SPBOOST_MAX:
					velocity.x -= min(
						abs(velocity.x) - RUN_SPEED_MAX,
						abs(velocity.x) * (1 - CORRECTION_EVEN_MORE_FOR_JUMP_SPBOOSTS_TEMP)
					) * sign(velocity.x)
			else:
				if (not direction_x) or direction_x * velocity.x < 0:
					# will have to figure out how to timestep this later
					velocity.x *= RUN_FRIC_TEMP if grounded else AIR_FRIC_TEMP
				if direction_x:
					velocity.x += (RUN_ACC if grounded else RUN_AIR_ACC) * delta * direction_x
					velocity.x = clamp(velocity.x, -RUN_SPEED_MAX, RUN_SPEED_MAX)
	
	# Variable Height Jump and Fastfalling and Wallsliding
	
	if apply_gravity:
		var current_gravity: float = GRAVITY
		
		if direction_y == 1 and velocity.y > FASTFALL_BEGIN:
			current_gravity *= FASTFALL_MULTIPLIER
		
		var max_fall_speed: float
		if direction_y == 1:
			max_fall_speed = FASTFALL_SPEED
		elif wallsliding and not rolling:
			max_fall_speed = WALLSLIDE_MAX_SPEED
		else:
			max_fall_speed = FALL_SPEED
		
		if velocity.y < max_fall_speed:
			if not grounded and in_control_y:
				if wallsliding and not rolling and velocity.y >= WALLSLIDE_MIN_SPEED:
					actually_wallsliding = true
					current_gravity = WALLSLIDE_GRAVITY
				else:
					actually_wallsliding = false
					if jumping:
						if Input.is_action_pressed("Accept"):
							if GRAVMOD_BIGLEAP_BEGIN < velocity.y and velocity.y < GRAVMOD_BIGLEAP_END:
								current_gravity *= GRAVMOD_BIGLEAP_MULTIPLIER
						elif GRAVMOD_SHORTHOP_BEGIN < velocity.y and velocity.y < GRAVMOD_SHORTHOP_END:
							current_gravity *= GRAVMOD_SHORTHOP_MULTIPLIER
				if direction_y == 1 and velocity.y >= FASTFALL_BEGIN:
					current_gravity *= FASTFALL_MULTIPLIER
			
			velocity.y = min(
				velocity.y + current_gravity * delta,
				max_fall_speed
			)
		else:
			velocity.y = max(velocity.y * AIR_Y_FRICTION_TEMP, max_fall_speed)
	
	# Jump
	if not in_cutscene:
		if Input.is_action_just_pressed("Accept"):
			jump_timer = JUMP_TIME
		if grounded:
			coyote_timer = COYOTE_TIME_WHEN_DASHING if dashing else COYOTE_TIME
			last_ground_y = position.y
	
	if jump_timer and coyote_timer and in_control_y:
		on_jump()
		jump_timer = 0
		coyote_timer = 0
		move_and_collide(Vector2(0, last_ground_y - position.y))
		velocity.y = ROLL_JUMP_FORCE if rolling else JUMP_FORCE
		if abs(velocity.x) < JUMP_SPBOOST_MAX:
			velocity.x *= ROLL_JUMP_SPBOOST if rolling else JUMP_SPBOOST_MULTIPLIER
			velocity.x = clamp(velocity.x, -JUMP_SPBOOST_MAX, JUMP_SPBOOST_MAX)
		jump_timer = 0
		coyote_timer = 0
		grounded = false
	else:
		jump_timer = max(jump_timer - delta, 0.0)
		coyote_timer = max(coyote_timer - delta, 0.0)
	
	# Walljump
	if in_control_y:
		if jump_timer:
			var wall_normal: int
			if test_move(collider_transform(), Vector2(WALLJUMP_MARGIN * facing, 0)):
				wall_normal = -facing
				last_wall_normal = wall_normal
			elif test_move(collider_transform(), Vector2(WALLJUMP_MARGIN * (-facing), 0)):
				wall_normal = facing
				last_wall_normal = wall_normal
			
			if wall_normal:
				jump_timer = 0
				on_jump()
				velocity.y = ROLL_WALLJUMP_FORCE if rolling else WALLJUMP_FORCE
				velocity.x = (ROLL_WALLJUMP_PUSH if rolling else
					(WALLJUMP_PUSH if direction_x else
					WALLJUMP_PUSH_NEUTRAL)) * wall_normal
				in_control_x = false
				in_control_y = false
				if direction_x:
					no_control_x_timer = WALLJUMP_CONTROL_REMOVED_TIME
					no_control_y_timer = WALLJUMP_CONTROL_REMOVED_TIME
					facing = int(wall_normal)
				else:
					no_control_x_timer = WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
					no_control_y_timer = WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
				grounded = false
	
	# Dash
	
	if (Input.is_action_just_pressed("Cancel") and dashing_allowed and
			dashing_refreshed and not (in_cutscene or rolling)):
		coyote_timer = 0
		dashing_allowed = false
		dash_cancel_timer = DASH_DELAY
		dash_waiting = true
		velocity *= DASH_PRE_VEL_MULTIPLIER
		dash_direction = Vector2.ZERO
		in_control_x = false
#		in_control_y = false
		apply_gravity = false
		no_gravity_timer = DASH_DURATION + DASH_DELAY
		no_control_x_timer = DASH_DURATION + DASH_DELAY
		no_control_y_timer = DASH_DURATION + DASH_DELAY
		align_to_grid()
	if dash_waiting:
		dash_cancel_timer -= delta
		if dash_cancel_timer <= 0:
			dash()
	if dashing:
		dash_timer -= delta
		if dash_timer <= DASH_DURATION * (1 - DASH_REGAIN_AFTER_RATIO):
			dashing_allowed = true
		if dash_timer <= 0:
			exit_dash()

# Please pay respects to the now unused bouncing code
# "Goodbye, I hated you." -An old friend

#	# Bouncing
#
#	if bounce_timer > 0:
#		if Input.is_action_pressed("Cancel"):
#			bounce_dash_holder = BOUNCE_DASH_HOLD_TIME
#
#		if bounce_dash_holder > 0:
#			if jump_timer > 0 or Input.is_action_pressed("Accept"):
#				var bounce_from: Vector2
#
#				if (dash_direction.x and (not dash_direction.y) and
#					test_move(
#						collider_transform(),
#						dash_direction.project(Vector2.RIGHT) *
#						BOUNCE_CHECK_DISTANCE
#					)):
#					bounce_from.x = sign(dash_direction.x)
#				if (dash_direction.y and (not dash_direction.x) and
#					test_move(
#						collider_transform(),
#						dash_direction.project(Vector2.DOWN) *
#						BOUNCE_CHECK_DISTANCE
#					)):
#					bounce_from.y = sign(dash_direction.y)
#
#				if bounce_from:
#					bounce_timer = 0.0
#					in_control_x = false
#					no_control_x_timer = BOUNCE_REMOVE_CONTROL_TIME
#					in_control_y = false
#					no_control_y_timer = BOUNCE_REMOVE_CONTROL_TIME
#					if bounce_from.x:
#						velocity.x = BOUNCE_FROM_SIDE.x * bounce_from.x
#						velocity.y = BOUNCE_FROM_SIDE.y
#						facing = -bounce_from.x
#					if bounce_from.y:
#						if bounce_from.y > 0:
#							velocity = BOUNCE_FROM_FLOOR
#							refill_dash()
#						else:
#							velocity = BOUNCE_FROM_CEILING
#					on_bounce()
#					bounce_bounce_timer = BOUNCE_DURATION
#			bounce_dash_holder -= delta
#		bounce_timer -= delta
#	else:
#		bounce_dash_holder = 0
#
#	# haha boing boing <-- this is still funny though
#	if bounce_bounce_timer > 0:
#		bounce_bounce_timer -= delta
#		if bounce_bounce_timer < 0:
#			bounce_bounce_timer = 0
	
	# Apply velocity
	
	if in_cutscene and not dying:
		move_and_slide(Vector2(0, velocity.y), Vector2.UP)
		if cutscene_info.set_position:
			if grounded:
				move_and_collide(Vector2(velocity.x, 0) * delta)
			if sign(cutscene_info.position_x - global_position.x) != sign(cutscene_velocity):
				move_and_collide(Vector2(cutscene_info.position_x - global_position.x, 0))
				Global.emit_signal("CutscenePlayerStoppedMoving", true)
				if cutscene_info.facing:
					facing = cutscene_info.facing
				cutscene_velocity = 0
				cutscene_info.set_position = false
			cutscene_info.maximum_time -= delta
			if cutscene_info.maximum_time <= 0:
				cutscene_velocity = 0
				Global.emit_signal("CutscenePlayerStoppedMoving", false)
				cutscene_info.set_position = false
	else:
		move_and_slide(velocity, Vector2.UP)
	var squeezed_around: bool
	if (dashing and not Input.is_action_pressed("Accept")):
		# Squeezing around corners
		if get_slide_count():
			var collision = get_slide_collision(0)
			var check_axis = Vector2.DOWN if collision.normal.x else Vector2.RIGHT
			var check_movement = collision.remainder.clamped(DASH_SQUEEZE_AROUND_CHECK_DISTANCE_MAX)
			# Assumes DASH_SQUEEZE_AROUND_MAX < 4 which it really should
			for i in range(DASH_SQUEEZE_AROUND_MAX + 1):
				if not test_move(collider_transform().translated(check_axis * i), check_movement):
					position += check_axis * i + collision.remainder
					squeezed_around = true
					break
				if not test_move(collider_transform().translated(check_axis * -i), check_movement):
					position += check_axis * -i + collision.remainder
					squeezed_around = true
					break
	
	# Reseting velocity and bouncing
	
	if not squeezed_around:
		
		var will_bounce: bool
		if dashing or dash_exit_timer:
			will_bounce = true
		
		if is_on_ceiling():
			if rolling and will_bounce and dash_direction.y == --1:
				exit_dash()
				velocity.y = BOUNCE_CEILING
			elif rolling and velocity.y < ROLL_BOUNCE_MIN_Y:
				velocity.y = -velocity.y * ROLL_BOUNCINESS_Y
			else:
				if velocity_conservation_timer.y > 0:
					velocity_conservation_timer.y -= delta
				if velocity_conservation_timer.y <= 0 and not stick_to_ceiling_timer:
					velocity.y = 0
		else:
			velocity_conservation_timer.y = VELOCITY_CONSERVATION_TIME
		if is_on_floor():
			if rolling and will_bounce and dash_direction.y == 1:
				exit_dash()
				dashing_allowed = true
				velocity.y = BOUNCE_FLOOR
				coyote_timer = 0
				grounded = false
			elif rolling and velocity.y > ROLL_BOUNCE_MIN_Y:
				velocity.y = -velocity.y * ROLL_BOUNCINESS_Y
				coyote_timer = 0
				grounded = false
			else:
				velocity.y = 0
		if is_on_wall():
			if rolling and will_bounce and abs(dash_direction.x) == 1:
				exit_dash()
				velocity.x = dash_direction.x * BOUNCE_WALL
			elif rolling and abs(velocity.x) > ROLL_BOUNCE_MIN_X:
				velocity.x = -velocity.x * ROLL_BOUNCINESS_X
			else:
				if velocity_conservation_timer.x > 0:
					velocity_conservation_timer.x -= delta
				if velocity_conservation_timer.x <= 0:
					velocity.x = 0
		else:
			velocity_conservation_timer.x = VELOCITY_CONSERVATION_TIME
	
	if stick_to_ceiling_timer > 0.0:
		stick_to_ceiling_timer -= delta
		if stick_to_ceiling_timer < 0.0:
			stick_to_ceiling_timer = 0.0
	
	if dash_exit_timer:
		dash_exit_timer -= delta
		if dash_exit_timer < 0:
			dash_exit_timer = 0
	
	# Animations
	
	if not dying:
		if rolling:
			if not rolling_visually:
				set_anim(anim_roll, "Roll")
				rolling_visually = true
			ang_vel = lerp(
				ang_vel,
				(velocity.x) / (2 * PI),
				ROLLING_ROTATION_ON_GROUND if grounded else ROLLING_ROTATION_IN_AIR
			)
			true_rotation = fmod(
				true_rotation + ang_vel * delta,
				2 * PI
			)
			anim_rolling.rotation = (
				round(true_rotation * (ROLL_NB_OF_ANGLES / 2) / PI) /
				(ROLL_NB_OF_ANGLES / 2) * PI
			)
			if facing < 0:
				anim_rolling.rotation = PI - anim_rolling.rotation + ROLL_FACING_LEFT_ROTATION_OFFSET
		elif rolling_visually:
			set_anim(anim_roll, "Unroll")
		else:
			if dashing:
				set_anim(anim_dash, "Dash")
				anim_dash.offset = (
					anim_dash_raw_offset +
					Vector2(int(dash_direction.x != 0), int(dash_direction.y != 0))
				)
			else:
				if grounded:
					if abs(velocity.x) > RUNNING_THRESHOLD and not wallsliding:
						set_anim(anim_run, "Run")
					else:
						set_anim(anim_idle, "Idle")
				else:
					if anim_current == anim_run or anim_current == anim_idle or anim_current == anim_roll:
						set_anim(anim_idle, "Hangtime")
					if velocity.y >= FALLING_THRESHOLD:
						set_anim(anim_fall, "Fall")
		
		if anim_container.scale.x == -1:
			if facing > 0:
				anim_container.scale.x = 1
		elif facing < 0:
			anim_container.scale.x = -1
		
		# Change palette
		
		if dash_refill_anim_timer > 0:
			set_palette_uniform(
				palette_white_petals_texture,
				palette_normal_texture,
				1 - (dash_refill_anim_timer / DASH_REFILL_ANIM_DURATION) *
				1 - (dash_refill_anim_timer / DASH_REFILL_ANIM_DURATION)
			)
			dash_refill_anim_timer -= delta
		elif not dashing_refreshed:
			set_palette_uniform(palette_dash_texture)
		else:
			set_palette_uniform(palette_normal_texture)
	
	# Particles
	
	if dashing:
		dash_particles.direction = dash_direction
		dash_particles.emitting = true
	else:
		dash_particles.emitting = false


func collider_transform():
#	return transform.scaled(
#		(
#			collider.shape.extents -
#			Vector2(get_safe_margin(), get_safe_margin())
#		) / collider.shape.extents
#	).translated(Vector2(get_safe_margin(), get_safe_margin()))
	return transform


func align_to_grid():
	position = position.round()


func dash(override_other_directions: bool = true):
	coyote_timer = 0
	dashing_refreshed = false
	dash_waiting = false
	dashing = true
	dash_timer = DASH_DURATION
	if direction_x != 0 or direction_y != 0:
		dash_direction = Vector2(direction_x, direction_y).normalized()
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2(facing, 0)
	if override_other_directions:
		velocity = dash_direction * DASH_SPEED
	else:
		if dash_direction.x:
			velocity.x = dash_direction.x * DASH_SPEED
		if dash_direction.y:
			velocity.y = dash_direction.y * DASH_SPEED
	on_dash()


func exit_dash():
	if not dashing:
		dash_cancel_timer = 0
		dash(false)
	
	dashing_allowed = true
	dashing = false
	dash_timer = 0
	dash_exit_timer = DASH_EXIT_TIME
	
	if not in_control_x:
		no_control_x_timer = 0
		in_control_x = true
	if not apply_gravity:
		no_gravity_timer = 0
		apply_gravity = true
	var exit_velocity: Vector2
	var exit_vel: Vector2
	if dash_direction.y == -1.0:
		exit_vel.y = DASH_UP_EXIT_SPEED;
	elif dash_direction.y <= 0:
		exit_vel = (dash_direction * DASH_EXIT_SPEED).abs()
	else:
		exit_vel = Vector2(
			abs(dash_direction.x * DASH_DIAG_X_EXIT_SPEED),
			abs(dash_direction.y * DASH_DIAG_Y_EXIT_SPEED)
		)
	if dash_direction.x:
		exit_velocity.x = min(abs(velocity.x), exit_vel.x) * sign(velocity.x)
	else:
		exit_velocity.x = velocity.x
	if dash_direction.y:
		exit_velocity.y = min(abs(velocity.y), exit_vel.y) * sign(velocity.y)
	else:
		exit_velocity.y = velocity.y	
	
	if rolling:
		velocity = lerp(velocity, exit_velocity, ROLL_DASH_EXIT_VEL_RATIO)
	else:
		velocity = exit_velocity



func set_anim(new_anim: Sprite, anim: String):
	if not anim_current == new_anim:
		for spr in anim_list:
			if spr != new_anim:
				spr.visible = false
			else:
				spr.visible = true
		anim_current = new_anim
	if not animation_player.current_animation == anim:
		animation_player.play(anim)


func animationplayer_set_hangtime():
	set_anim(anim_hangtime, "Hangtime")


func animationplayer_set_rolling():
	set_anim(anim_rolling, "Rolling")


func animationplayer_deroll():
	rolling_visually = false


func set_palette_uniform(palette_a: StreamTexture, palette_b: StreamTexture = null, blend: float = 0.0):
	anim_container.material.set_shader_param("palette_a", palette_a)
	anim_container.material.set_shader_param("palette_b", palette_b)
	anim_container.material.set_shader_param("blend", blend)
	anim_rolling.material.set_shader_param("palette_a", palette_a)
	anim_rolling.material.set_shader_param("palette_b", palette_b)
	anim_rolling.material.set_shader_param("blend", blend)


func reset_rotation():
	ang_vel = 0
	if facing == 1:
		true_rotation = 0
	else:
		true_rotation = PI + ROLL_FACING_LEFT_ROTATION_OFFSET


func on_jump():
	if dashing or dash_waiting:
		exit_dash()
	align_to_grid()
	jumping = true
	Music.GUISFXPLAYER.stream = preload('res://SFX/jump.wav')
	Music.GUISFXPLAYER.play()
	if not rolling_visually:
		set_anim(anim_jump, "Jump")
	dashing = false
	dashing_allowed = true


func on_dash():
	jumping = false
	Music.GUISFXPLAYER.stream = preload('res://SFX/arrow.wav')
	Music.GUISFXPLAYER.play()
	if dash_direction.x:
		facing = sign(dash_direction.x)
	Global.camera.shake(dash_direction, DASH_SHAKE_DURATION)


func on_death():
	in_cutscene = true
	in_control_x = false
	in_control_y = false
	apply_gravity = false
	no_gravity_timer = 2.0
	dashing_allowed = false
	can_roll = false
	Music.GUISFXPLAYER.stream = preload('res://SFX/disappear.ogg')
	Music.GUISFXPLAYER.play()
	dying = true
	dashing = false
	velocity = Vector2.ZERO
	animation_player.play("Death")


func refill_dash():
	if dashing_allowed and not dashing_refreshed and not dashing:
		dashing_refreshed = true
		dash_refill_anim_timer = DASH_REFILL_ANIM_DURATION


func DialogFinishedCode():
	in_cutscene = false
	can_roll = true
	dashing_allowed = true


func DialogStartedCode(playerInfo):
	in_cutscene = true
	in_control_x = false
	in_control_y = false
	no_control_x_timer = 0
	no_control_y_timer = 0
	refill_dash()
	dashing_allowed = false
	dashing = false
	apply_gravity = true
	can_roll = false
	force_move(playerInfo)
	


func force_move(playerInfo):
	cutscene_info = playerInfo
	if playerInfo.set_position:
		if playerInfo.position_x == global_position.x:
			Global.emit_signal("CutscenePlayerStoppedMoving", true)
			if cutscene_info.facing:
				facing = cutscene_info.facing
			cutscene_velocity = 0
			cutscene_info.set_position = false
		else:
			var cutsc_dir = sign(playerInfo.position_x - global_position.x)
			cutscene_velocity = (
				cutsc_dir *
				(playerInfo.movement_speed if playerInfo.movement_speed > 0 else
				CUTSCENE_WALKING_SPEED)
			)
			facing = cutsc_dir if cutsc_dir else facing
	else:
		cutscene_velocity = 0
		Global.emit_signal("CutscenePlayerStoppedMoving", true)


func ForcedMoveCutscene(character,xaxis):
	match character:
		"MC":
			#walk to xaxis
			pass
		_:
			pass


func die():
	if not Global.loading_level:
		Global.loading_level = true
		Global.connect("transition_animation_finished", self, "death_leaving")
		on_death()
		# TEMP
		Global.transition.sprite.rotation = PI
		Global.transition.play_backwards("OpenX")


func death_leaving():
	Global.disconnect("leaving_animation_finished", self, "death_leaving")
	Global.load_level()
