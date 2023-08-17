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
var tween: Tween
var tween_duration: int
var tween_tiny: Tween
var tween_tiny_duration: int

# queue of jobs
var job_active = false
var job_tiny_active = false
var job_queue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label3D.text = title;
	# we should also keep the package that triggers the processing here
	
	if tween:
		tween.kill()
	# only tween if we have to
	create_my_tween()

func queue_job( time, needs_generates ):
	job_queue.append({ "time": time, "needs_generates": needs_generates })

func enqueue_job():
	if not is_instance_valid(self):
			return
	if !self.job_tiny_active and job_queue.size() > 0:
		var j = job_queue.pop_front()
		var self_card = self
		create_job(j["time"], func():
			for n in j["needs_generates"]:
				ground_reference.perform_card_action(self_card, n)
			self_card.job_tiny_active = false
		)

# create a job that is done after time seconds
func create_job(time, callback):
	self.job_tiny_active = true
	progress_time = time
	$ProgressBarTiny.scale.x = 1.0  # reset the progress bar
	self.tween_tiny = create_tween().set_speed_scale(1.0/progress_time)
	self.tween_tiny.tween_property($ProgressBarTiny, "scale:x", 0.0, 1.0).set_delay(0.01)
	self.tween_tiny.tween_callback(callback)
	self.tween_tiny.tween_property($ProgressBarTiny, "scale:x", 1.0, 0)
	self.tween_tiny_duration = time
	self.tween_tiny.bind_node(self)
	# we need to pause this card in case the game is paused
	if get_tree().get_root().get_node("Node3D/Ground").paused:
		pause()

func create_my_tween():
	if card_template.has("duration") and card_template.duration >= 0:
		progress_time = card_template.duration;
		$ProgressBar.scale.x = 1.0  # reset the progress bar
		self.tween = create_tween().set_loops().set_speed_scale(1.0/progress_time)
		self.tween.tween_property($ProgressBar, "scale:x", 0.0, 1.0).set_delay(0.01)
		self.tween.tween_callback(card_create)
		self.tween.tween_property($ProgressBar, "scale:x", 1.0, 0)
		self.tween_duration = card_template.duration
		self.tween.bind_node(self)
		self.job_active = true # prevent job to run its own jobs from the job_queue
		# we need to pause this card in case the game is paused
		if get_tree().get_root().get_node("Node3D/Ground").paused:
			pause()
	

func pause():
	if tween:
		tween.pause()
	if tween_tiny:
		tween_tiny.pause()

func unpause():
	if tween and tween.is_valid():
		tween.play()
	if tween_tiny and tween_tiny.is_valid():
		tween_tiny.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (LastPressedTime > 0):
		LastPressedTime = max(0, LastPressedTime - delta)
		if (LastPressedTime == 0):
			OnSingleClick()
	# print the remaining seconds on the bar
	if tween and tween.is_valid():
		var t = self.tween.get_total_elapsed_time()*self.tween_duration
		while (t > self.tween_duration):
			t -= self.tween_duration
		if self.tween_duration > 0:
			$TimerText.text = "%.01f sec" % [self.tween_duration - t]
	if tween_tiny and tween_tiny.is_valid():
		var t = self.tween_tiny.get_total_elapsed_time()*self.tween_tiny_duration
		while (t > self.tween_tiny_duration):
			t -= self.tween_tiny_duration
		#if self.tween_tiny_duration > 0:
		#	$TimerText.text = "%.01f sec" % [self.tween_duration - t]

func reset_counter(_val):
	# TODO: does not work. the Tween is supposed to start over at 0
	if tween:
		self.tween.kill() # should reset the tween
	if tween_tiny:
		self.tween_tiny.kill()
		
	create_my_tween()
	pass

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
	# update color if there is any
	if "color" in card_template:
		var material = $MeshInstance3D.get_active_material(0)
		material = material.duplicate()
		material.albedo_color = Color(card_template["color"][0], card_template["color"][1], card_template["color"][2])
		$MeshInstance3D.set_surface_override_material(0,material)
	pass

func card_remove():
	# remove its tween
	if self.tween and self.tween.is_valid():
		self.tween.kill()
	if self.tween_tiny and self.tween_tiny.is_valid():
		self.tween_tiny.kill()
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
	# every time a card is created we might need to create more cards if they depend on its existence
	pass

func _physics_process(delta):
	# try to run a job, if none are currently active
	enqueue_job()
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
					var compatible = GUIPanel3D.isCompatibleWithCurrent(self)
					if compatible.ok: 
						GUIPanel3D.SetHighlight(true, compatible.need)
			else:
				GUIPanel3D.SetHighlight(false, null)
		else:
			GUIPanel3D.SetHighlight(false, null)
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
		# store the current location as the next create position
		# global_position
		var GUIPanel3D = get_tree().get_root().get_node("Node3D/GUIPanel3D")
		# check if we are over a compatible GUIPanel3D and destroy this card
		var compatible = GUIPanel3D.isCompatibleWithCurrent(self)
		if compatible.ok and GUIPanel3D.isHighlighted(compatible.need):
			# we release and we are compatible with, but are we also highlighted?
			print("We got a drop, should destroy this card now ", self.title, " add add the scores.")
			GUIPanel3D.doDrop(self)
			self.card_remove()
		else:
			# remember the last man-made card position, some order is good
			card_template.position[0] = global_position[0]
			card_template.position[1] = global_position[2]
		if not $click_timer.is_stopped():
			# a single release right after a click (in less than 0.4 sec)
			selected = false
			GUIPanel3D.SetHighlight(false, null)
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
			#var GUIPanel3D = get_tree().get_root().get_node("Node3D/GUIPanel3D")
			#GUIPanel3D.highlight(false)
		#if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		#	ground_reference.hide_window()


func _on_click_timer_timeout():
	# we reached a timeout, start moving the card
	selected = true
	pass # Replace with function body.
