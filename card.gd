extends PhysicsBody3D

var selected = false
var GRAVITY = -9.81;
var LastPressedTime = 0;

# cards have a title
@export var title = "Order";
@export var description = "Order";
@export var texture = "";
# cards can have a progress time
@export var progress_time = 10; 
@export var card_template = {}; # the template that was used to create this card
@export var ground_reference = Node3D; # reference to game scene
@export var input_package = {}; # this will hold the input package, we want to 
# add the card_template.package key-value pairs

# animate the progress bar
var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label3D.text = title;
	# we should also keep the package that triggers the processing here
	
	if tween:
		tween.kill()
	# only tween if we have to
	if card_template.has("duration") and card_template.duration >= 0:
		progress_time = card_template.duration;
		tween = create_tween().set_loops().set_speed_scale(1.0/progress_time)
		tween.tween_property($ProgressBar, "scale:x", 0.0, 1.0).set_delay(0.01)
		tween.tween_callback(card_create)
		tween.tween_property($ProgressBar, "scale:x", 1.0, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (LastPressedTime > 0):
		LastPressedTime = max(0, LastPressedTime - delta)
		if (LastPressedTime == 0):
			OnSingleClick()

func OnSingleClick():
	# show the dialog window
	ground_reference.toggle_window(self)

func update_card():
	if !is_instance_valid(self):
		return
	# update the cards variables (if there are any)
	if card_template.has("variables"):
		var idx = 0;
		for variable in card_template.variables.keys():
			if idx == 0:
				$Node3D/Variable01.text = variable + ": " + str(card_template.variables[variable].size());
			if idx == 1:
				$Node3D/Variable02.text = variable + ": " + str(card_template.variables[variable].size());
			if idx == 3:
				$Node3D/Variable03.text = variable + ": " + str(card_template.variables[variable].size());
			idx = idx + 1
	pass

func card_remove():
	# remove its tween
	self.tween.kill()
	# remove this card from the group
	self.remove_from_group("cards");
	# remove this card
	self.queue_free()

# do the card job after the timing period
func card_create():
	if not is_instance_valid(self):
		return
	#print("do whatever the card does...") # like create another card or make the card disappear
	# the information on what to do is in card_template.auto_generates
	if card_template.has("auto_generates"):
		for todo_list in card_template.auto_generates:
			for todo in todo_list:
				# what is the package that caused this action (input_package)?
				ground_reference.perform_card_action(self, todo)
				#get_tree().get_root().get_node("Ground").perform_card_action(todo)
	pass

func _physics_process(delta):
	if selected:
		# we would like to ray intersect the ground with the mouse position
		# and move the card to that location, with a pickup motion
		var position2D = get_viewport().get_mouse_position();
		var dropPlane  = Plane(Vector3(0, 1, 0), 0.03); # height is the last value
		var camera = get_tree().get_root().get_camera_3d(); 
		var position3D = dropPlane.intersects_ray(camera.project_ray_origin(position2D),camera.project_ray_normal(position2D));
		global_position = lerp(global_position, position3D, 25 * delta);
		#print(global_position)
		# we could also intersect with the plane, is that visible?
		var GUIPanel3D = get_tree().get_root().get_node("Node3D/GUIPanel3D")
		if GUIPanel3D.is_visible():
			# see if our view ray intersects the frame1
			var space_state = get_world_3d().get_direct_space_state()
			var params = PhysicsRayQueryParameters3D.new()
			params.from = camera.project_ray_origin(position2D)
			params.to = camera.project_ray_origin(position2D) + camera.project_ray_normal(position2D)
			params.exclude = [ self, ground_reference ]
			params.collision_mask = 1
			# we want to collide with an Area3D
			params.collide_with_areas = true
			params.collide_with_bodies = false
			var result = space_state.intersect_ray(params)
			if result:
				var c = result['collider']
				if c == GUIPanel3D.get_node("MeshInstance3D/Area3D"):
					# check if we can use the current object's title
					# should we highlight?
					if GUIPanel3D.isCompatibleWithCurrent(self): 
						GUIPanel3D.highlight(true)
			else:
				GUIPanel3D.highlight(false)
		else:
			GUIPanel3D.highlight(false)
	else:
		var velocity = Vector3(0,0,0);
		velocity.y += delta * GRAVITY;
		var motion = velocity * delta;
		var _collision_info = move_and_collide(motion)
		#if collision_info:
		#	velocity = velocity.bounce(collision_info.get_normal());
	pass

func _input_event(_camera, _event, _pos, _normal, _shape):
	if Input.is_action_just_pressed("grab_card"):
		# start a timer to move the card (if no release earlier)
		if not $click_timer.is_stopped():
			# stop and start again
			$click_timer.stop()
		$click_timer.start(0.4)
		
		#if (LastPressedTime > 0):
		#	#OnDoubleClick(get_local_mouse_position())
		#	selected = true
		#	LastPressedTime = 0
		#else:
		#	LastPressedTime = 0.4
	if Input.is_action_just_released("grab_card"):
		var GUIPanel3D = get_tree().get_root().get_node("Node3D/GUIPanel3D")
		# check if we are over a compatible GUIPanel3D and destroy this card
		if GUIPanel3D.isCompatibleWithCurrent(self) and GUIPanel3D.isHighlighted():
			# we release and we are compatible with, but are we also highlighted?
			print("We got a drop, should destroy this card now ", self.title, " add add the scores.")
			GUIPanel3D.doDrop(self)
			self.card_remove()
		if not $click_timer.is_stopped():
			# a single release right after a click (in less than 0.4 sec)
			selected = false
			GUIPanel3D.highlight(false)
			$click_timer.stop()
			# LastPressedTime = 0
			# toggle the window on
			OnSingleClick()
	#if Input.is_action_just_pressed("click_card") and event.double_click:
	#	# show the dialog for this card
	#	ground_reference.show_window(description);

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
			var GUIPanel3D = get_tree().get_root().get_node("Node3D/GUIPanel3D")
			#GUIPanel3D.highlight(false)
		#if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		#	ground_reference.hide_window()


func _on_click_timer_timeout():
	# we reached a timeout, start moving the card
	selected = true
	pass # Replace with function body.
