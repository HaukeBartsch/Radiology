extends Node3D

@export var title = "No title"
var current_card = null
var highlighted = false

func highlight(highlight):
	if highlight:
		#print("Highlighted region")
		var imported_resource = load("res://Images Raw/frame_highlighted.png")
		get_node("SubViewport/Control/Panel/HBoxContainer/frame1").texture = imported_resource
		get_node("SubViewport/Control/Panel/HBoxContainer/frame2").texture = imported_resource
		get_node("SubViewport/Control/Panel/HBoxContainer/frame3").texture = imported_resource
		highlighted = true
	else:
		#print("disable highlight region")
		var imported_resource = load("res://Images Raw/frame.png")
		get_node("SubViewport/Control/Panel/HBoxContainer/frame1").texture = imported_resource
		get_node("SubViewport/Control/Panel/HBoxContainer/frame2").texture = imported_resource
		get_node("SubViewport/Control/Panel/HBoxContainer/frame3").texture = imported_resource
		highlighted = false

func isHighlighted():
	return highlighted

func setCurrentCard(card):
	current_card = card

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
				return true
	return false

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
		var toggle_fulfilled = true
		for need in needs:
			if not "fulfilled" in need and need['name'] == card.title:
				need['fulfilled'] = true
			if not "fulfilled" in need:
				toggle_fulfilled = false
		if needs.size() > 0 and toggle_fulfilled:
			print("We have everything for this card! Do something needs_generate for ", current_card.title)
			var ground_reference = get_tree().get_root().get_node("Node3D/Ground")
			# what should we do?
			if "needs_generates" in current_card.card_template:
				var todo = current_card.card_template["needs_generates"][randi_range(0,current_card.card_template["needs_generates"].size()-1)]
				ground_reference.perform_card_action(current_card, todo)
			# reset the fulfilled entries so we can do this again
			for need in needs:
				if "fulfilled" in need:
					need.erase('fulfilled')
			highlight(false)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

