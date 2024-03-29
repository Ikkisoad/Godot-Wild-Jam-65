extends CharacterBody2D

@onready var timer = $releaseTimer
@onready var animated_sprite_2d = $AnimatedSprite2D

const PACKAGES_REMOVED = 1
const SPEED = 300.0
const JUMP_VELOCITY = -280.0
const MAX_Y_VELOCITY = 250
const DOWN_VELOCITY = 100
const package = preload("res://Scenes/released_pakcage.tscn")
#Speed up the plane fall
const GRAVITY_MULTIPLIER = 1.8
var spawnPosition = Vector2(0,0)
var overloaded = 1
@onready var collision_shape_2d = $CollisionShape2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	spawnPosition = global_position
	Autoload.on_overload.connect(OverloadSequence)
	Autoload.off_overload.connect(overloadOff)

func _process(delta):
	if Input.is_action_pressed("release") && timer.is_stopped() && Autoload.packages > 0:
		var releasePackage = package.instantiate()
		releasePackage.global_position.y += 50
		add_child(releasePackage)
		timer.start()
		Autoload.RemovePackages()
		
func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta * GRAVITY_MULTIPLIER
		#if velocity.y > MAX_Y_VELOCITY:
			#velocity.y = MAX_Y_VELOCITY

	#if Input.is_action_pressed("up"):
		#velocity.y = JUMP_VELOCITY
	#if Input.is_action_pressed("down"):
		#velocity.y += DOWN_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED / overloaded
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	direction = Input.get_axis("up", "down")
	if direction:
		velocity.y = direction * SPEED / overloaded
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

func Die():
	animated_sprite_2d.modulate = Color(Color.WHITE,0.5)
	Autoload.playerDeath()
	setInvul(true)
	get_tree().create_timer(3).timeout.connect(endInvul)
	global_position = spawnPosition

func setInvul(value):
	if value == null:
		value = false
	collision_shape_2d.set_deferred("disabled", value)
	
func endInvul():
	animated_sprite_2d.modulate = Color.WHITE
	collision_shape_2d.set_deferred("disabled", false)
#func rotate():
	#rotation = 
	#pass
func collectPackage():
	Autoload.collectPackage()

func OverloadSequence():
	overloaded = 2

func overloadOff():
	overloaded = 1
