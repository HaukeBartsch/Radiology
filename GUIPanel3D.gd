extends Node3D

@export var title = "No title"
var current_card = null
var highlighted = [false, false, false]

func SetHighlight(highlight, need):
	if highlight:
		var imported_resource = load("res://Images Raw/frame_highlighted.png")
		# in case we have a need we can find out what texture to highlight
		if need != null:
			# find the frame for this need
			var need_title = need["name"]
			if need_title == get_node("SubViewport/Control/Panel/HBoxContainer/frame1/RichTextLabel").text:
				get_node("SubViewport/Control/Panel/HBoxContainer/frame1").texture = imported_resource
				highlighted[0] = true
			elif need_title == get_node("SubViewport/Control/Panel/HBoxContainer/frame2/RichTextLabel").text:
				get_node("SubViewport/Control/Panel/HBoxContainer/frame2").texture = imported_resource
				highlighted[1] = true
			elif need_title == get_node("SubViewport/Control/Panel/HBoxContainer/frame3/RichTextLabel").text:
				get_node("SubViewport/Control/Panel/HBoxContainer/frame3").texture = imported_resource
				highlighted[2] = true
		else:
			get_node("SubViewport/Control/Panel/HBoxContainer/frame1").texture = imported_resource
			get_node("SubViewport/Control/Panel/HBoxContainer/frame2").texture = imported_resource
			get_node("SubViewport/Control/Panel/HBoxContainer/frame3").texture = imported_resource
			highlighted = [true, true, true]
	else:
		var imported_resource = load("res://Images Raw/frame.png")
		if need != null:
			# find the frame for this need
			var need_title = need["name"]
			if need_title == get_node("SubViewport/Control/Panel/HBoxContainer/frame1/RichTextLabel").text:
				get_node("SubViewport/Control/Panel/HBoxContainer/frame1").texture = imported_resource
				highlighted[0] = false
			elif need_title == get_node("SubViewport/Control/Panel/HBoxContainer/frame2/RichTextLabel").text:
				get_node("SubViewport/Control/Panel/HBoxContainer/frame2").texture = imported_resource
				highlighted[1] = false
			elif need_title == get_node("SubViewport/Control/Panel/HBoxContainer/frame3/RichTextLabel").text:
				get_node("SubViewport/Control/Panel/HBoxContainer/frame3").texture = imported_resource
				highlighted[2] = false
		else:
			#print("disable highlight region")
			get_node("SubViewport/Control/Panel/HBoxContainer/frame1").texture = imported_resource
			get_node("SubViewport/Control/Panel/HBoxContainer/frame2").texture = imported_resource
			get_node("SubViewport/Control/Panel/HBoxContainer/frame3").texture = imported_resource
			highlighted = [false, false, false]

func isHighlighted(need):
	# check if that need is highlighted
	if need != null:
		var need_title = need["name"]
		var t = get_node("SubViewport/Control/Panel/HBoxContainer/frame1/RichTextLabel").text
		if need_title == get_node("SubViewport/Control/Panel/HBoxContainer/frame1/RichTextLabel").text:
			return highlighted[0]
		elif need_title == get_node("SubViewport/Control/Panel/HBoxContainer/frame2/RichTextLabel").text:
			return highlighted[1]
		elif need_title == get_node("SubViewport/Control/Panel/HBoxContainer/frame3/RichTextLabel").text:
			return highlighted[2]
	else:
		pass
	return false

func setCurrentCard(card):
	current_card = card
	# set the names of all the needs
	var counter = 0
	if "needs" in current_card.card_template:
		for need in current_card.card_template["needs"]:
			if counter == 0:
				get_node("SubViewport/Control/Panel/HBoxContainer/frame1/RichTextLabel").text = need["name"]
			elif counter == 1:
				get_node("SubViewport/Control/Panel/HBoxContainer/frame2/RichTextLabel").text = need["name"]
			elif counter == 2:
				get_node("SubViewport/Control/Panel/HBoxContainer/frame3/RichTextLabel").text = need["name"]
			counter = counter + 1


func getCurrentCard():
	# return the current card
	return current_card	

func isCompatibleWithCurrent( other_card ):
	# we are compatible if the other_card matches the needs array in current_card
	if current_card != null:
		var needs = []
		if "needs" in current_card.card_template:
			needs = current_card.card_template['needs']
		for need in needs:
			if not "fulfilled" in need and need['name'] == other_card.title:
				# need['fulfilled'] = true
				return { "ok": true, "need": need }
	return { "ok": false, "need": null }

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func doDrop(card):
	# perform the operation done when a card is dropped on a frame
	print("Drop the card here")
	# do something if all needs are fulfilled for current_card
	if current_card != null:
		var needs = []
		if "needs" in current_card.card_template:
			needs = current_card.card_template['needs']
		var toggle_all_fulfilled = true
		for need in needs:
			# we can only have a single card fill a need
			if not "fulfilled" in need and need['name'] == card.title:
				need['fulfilled'] = true
				# fulfill this needs local stuff immediately
				if 'needs_generates' in need:
					var time = 0
					if "time" in need:
						time = need["time"]
						current_card.queue_job(time, need["needs_generates"])
					else:
						var ground_reference = get_tree().get_root().get_node("Node3D/Ground")
						for n in need["needs_generates"]:
							ground_reference.perform_card_action(current_card, n)
					need.erase('fulfilled')
			if not "fulfilled" in need:
				# any single need not fulfilled will make this whole thing not fulfilled
				toggle_all_fulfilled = false
		if needs.size() > 0 and toggle_all_fulfilled:
			print("We have everything for this card! Do something needs_generate for ", current_card.title)
			var ground_reference = get_tree().get_root().get_node("Node3D/Ground")
			# what should we do?
			# we need to perform everthing in this needs generates
			if "needs_generates" in current_card.card_template:
				for n in current_card.card_template["needs_generates"]:
					ground_reference.perform_card_action(current_card, n)
			# reset the fulfilled entries so we can do this again
			for need in needs:
				if "fulfilled" in need:
					need.erase('fulfilled')
					SetHighlight(false, need)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

