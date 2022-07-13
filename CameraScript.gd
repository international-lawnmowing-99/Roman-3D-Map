extends Camera

export var MAX_FOV = 150
export var MIN_FOV  = 20
export var camSpeed:float = 5
export var camRotateSpeed:float = 50
export var lerpSpeed = 10

const xBounds = 80
const zBounds = 40

var myFov
var targetPos

onready var pivot = get_parent()

var zoomLevel:float = 100

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	myFov = fov
	targetPos = pivot.translation

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			if fov > MIN_FOV:
				
				myFov -= 2
				zoomLevel -=2
		elif event.button_index == BUTTON_WHEEL_DOWN:
			if fov < MAX_FOV:
				myFov += 2
				zoomLevel +=2
		elif event.button_index == BUTTON_RIGHT:

			var spaceState = get_world().direct_space_state
			var mousePos = get_viewport().get_mouse_position()
			var rayOrigin = project_ray_origin(mousePos)
			var rayEnd = project_ray_normal(mousePos) * 99999
			var intersection = spaceState.intersect_ray(rayOrigin,rayEnd)
			
			if not intersection.empty():
				#print("hit")
				targetPos = Vector3(intersection.position.x, 1, intersection.position.z)
				
func _process(delta):
	pivot.translation = lerp(pivot.translation, targetPos, lerpSpeed * delta)
	fov = lerp (fov, myFov, lerpSpeed * delta)
	
	var accelerator = 1
	if Input.is_action_pressed("shift"):
		accelerator = 3#lerp(accelerator, 3, delta)
		
	var desiredHeight = 1 +   pow(zoomLevel/33, 3)
	var thisFrameHeight = lerp(translation.y, desiredHeight, lerpSpeed * delta)

	var desiredLocalZ = (140-zoomLevel)/4
	var thisFrameZ = lerp(translation.z, desiredLocalZ, lerpSpeed * delta)
	
	translation = Vector3(translation.x, thisFrameHeight ,thisFrameZ)

	
	look_at(pivot.transform.origin, Vector3.UP) 
	
	if Input.is_action_pressed("rotate_left"):
		pivot.rotate_object_local(Vector3.UP,deg2rad(delta * camRotateSpeed * accelerator * zoomLevel/100))
	elif Input.is_action_pressed("rotate_right"):
		pivot.rotate_object_local(Vector3.UP,deg2rad(-delta * camRotateSpeed * accelerator * zoomLevel/100))
	
	
	if WithinBounds():
		#print(("yep"))
		var moveDir = Vector3.ZERO
		if Input.is_action_pressed("ui_up"):
			moveDir -= pivot.transform.basis.z.normalized()
			
		elif Input.is_action_pressed("ui_down"):
			moveDir += pivot.transform.basis.z.normalized()
		
		elif Input.is_action_pressed("ui_left"):
			moveDir -= pivot.transform.basis.x.normalized()
		elif Input.is_action_pressed("ui_right"):
			moveDir += pivot.transform.basis.x.normalized()
			
		moveDir = moveDir.normalized()
		targetPos += moveDir * delta * camSpeed * accelerator * zoomLevel/100
		pivot.translation = Vector3(clamp(pivot.translation.x, -xBounds, xBounds), 1, clamp(pivot.translation.z, -zBounds, zBounds))

	else: 
		print("nup")
		pivot.translation = Vector3(clamp(pivot.translation.x, -xBounds + 1, xBounds - 1), 1, clamp(pivot.translation.z, -zBounds + 1, zBounds - 1))
		targetPos = pivot.translation
	
func WithinBounds():
	if pivot.translation.x >= -xBounds && pivot.translation.x <= xBounds && pivot.translation.z \
	 		>= -zBounds && pivot.translation.z <= zBounds:
		return true
	else:
		return false
