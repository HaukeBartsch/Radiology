extends StaticBody3D

const card_scene = preload("res://card.tscn")

var do_do_appears = true
@export var paused = false

var card_setup = {
	"title": "Radiology",
	"description": "A game of clinical radiology imaging",
	"cards": [
		{
			"name": "Population",
			# we will assume that the first entry is the start card
			"texture": [ "res://Images/020.png" ],
			"duration": 10, # in seconds
			"description": "All your people. They may become ill and need to see a general practitioner.",
			"auto_generates": [ [ "Condition:create:" ] ], # if we want to delete the card say "destroy"
			"variables": {},
			"create_on_ready": true,
			"position": [-0.1, -0.1],
			"package": [
				# information added to each generated output (meta-data)
				# pick one of the packages at random
				{ "PatientName": "Bob" }, { "PatientName": "Mary" }, { "PatientName": "Fiona" }, { "PatientName": "Debie" }
			]
		},
		{
			"name": "Condition",
			# we will assume that the first entry is the start card
			"texture": [ "res://Images/012.png","res://Images/013.png","res://Images/014.png","res://Images/015.png","res://Images/016.png","res://Images/017.png","res://Images/018.png","res://Images/019.png"],
			"duration": 18, # in seconds
			"description": "You have a person with some complain. They should go to a general practitioner, or to the emergency department.",
			"auto_generates": [ [ "BadStuff:add_one:disabled", ":delete:" ] ], # if we want to delete the card say "destroy"
			"variables": {},
			"position": [-0.05, -0.05],
			"package": [
				{ "Symptom": "pain in knee" }, { "Symptom": "headache" }, { "Symptom": "fever" }
			]
		},
		{
			"name": "BadStuff",
			# we will assume that the first entry is the start card
			"texture": [ "res://Images/012.png","res://Images/013.png","res://Images/014.png","res://Images/015.png","res://Images/016.png","res://Images/017.png","res://Images/018.png","res://Images/019.png"],
			"duration": 0, # in seconds
			"description": "Bad stuff happend. This should count against your overall population health.",
			"auto_generates": [ ], # if we want to delete the card say "destroy"
			"variables": { "disabled": [] },
			"position": [-0.05, -0.05],
			"package": [
				{ "Disease": "arthritis" }, { "Disease": "migranes" }, { "Disease": "long covid" }
			]
		},
		{
			"name": "WrongDiagnosis",
			# we will assume that the first entry is the start card
			"texture": [ "res://Images/012.png","res://Images/013.png","res://Images/014.png","res://Images/015.png","res://Images/016.png","res://Images/017.png","res://Images/018.png","res://Images/019.png"],
			"duration": 0, # in seconds
			"description": "Bad stuff happend. The GP could not find out what is wrong.",
			"auto_generates": [ ], # if we want to delete the card say "destroy"
			"variables": { "disabled": [] },
			"position": [-0.05, -0.05],
			"package": [
				{ "Disease": "arthritis" }, { "Disease": "migranes" }, { "Disease": "long covid" }
			]
		},
		{
			"name": "GP",
			# we will assume that the first entry is the start card
			"texture": ["res://Images/003.png"],
			"duration": 20, # in seconds
			"description": "A general practitioner that might require imaging services. It needs a condition.",
			"auto_generates": [ [ "WrongDiagnosis:add_one:disabled" ] ], # if we want to delete the card say "destroy"
			"variables": { "patient": [] },
			"position": [0.0, 0.1],
			"create_on_ready": true,
			"package": [
				{ "OrderText": "US" }, { "OrderText": "MRI" }, { "OrderText": "CT" }
			],
			"needs": [
				{ "name": "Condition" }
			],
			"needs_generates": [ "Order:create:" ]
		},
		{
			"name": "Order",
			# we will assume that the first entry is the start card
			"texture": ["res://Images/004.png"],
			"duration": 18, # in seconds
			"description": "An order from a general practitioner. Imaging or blood work services might be needed.",
			"auto_generates": [ [ "RIS:add_one:orders", ":delete:" ] ], # if we want to delete the card say "destroy"
			"variables": {},
			"position": [0, 0],
			"package": [
				{ "OrderCode": "ICD-10#1234" }, { "OrderCode": "ICD-10#56789" }
			]
		},
		{
			"name": "RIS",
			"texture": ["res://Images/005.png"],
			"duration": 0, # no tweening, just counting orders
			"description": "Radiology information system keeps track of all orders. Just counting orders right now.",
			"auto_generates": [ ],
			"variables": { "orders": [] },
			"position": [ 0.1, 0.1 ],
			"package": [
				{ "AccessionNumber": "1234" }, { "AccessionNumber": "5678" }
			],
			"needs": [
				{ "name": "Order" }
			],
			"needs_generates": [ "Modality:add_one:studies" ]
		},
		{
			"name": "Modality",
			"texture": ["res://Images/011.png"],
			"duration": 15, # no tweening, just counting orders
			"description": "An imaging modality, a machine performing scans ordered by a GP producing image studies.",
			"auto_generates": [ [ "Study:add_one:studies" ] ],
			"variables": { "studies": [] },
			"position": [ 0.1, 0.1 ],
			"package": [
				{ "DeviceSeriesNumber": "1234", "Modality": "MR" },
				{ "DeviceSeriesNumber": "9012", "Modality": "US" },
				{ "DeviceSeriesNumber": "5678", "Modality": "CT" }
			]
		}
	]
};


# lets encode the setup of the different cards, what generates
# what and what a card looks like etc.
var card_setup2 = {
	"title": "Radiology Test 01",
	"description": "A game of clinical radiology imaging - auto-generation",
	"cards": [
		{
			"name": "Population",
			# we will assume that the first entry is the start card
			"texture": [ "res://Images/020.png" ],
			"duration": 10, # in seconds
			"description": "All your people. They may become ill and need to see a general practitioner.",
			"auto_generates": [ [ "Condition:create:" ] ], # if we want to delete the card say "destroy"
			"variables": {},
			"create_on_ready": true,
			"position": [-0.1, -0.1],
			"package": [
				# information added to each generated output (meta-data)
				# pick one of the packages at random
				{ "PatientName": "Bob" }, { "PatientName": "Mary" }, { "PatientName": "Fiona" }, { "PatientName": "Debie" }
			]
		},
		{
			"name": "Condition",
			# we will assume that the first entry is the start card
			"texture": [ "res://Images/012.png","res://Images/013.png","res://Images/014.png","res://Images/015.png","res://Images/016.png","res://Images/017.png","res://Images/018.png","res://Images/019.png"],
			"duration": 8, # in seconds
			"description": "You have a person with some complain. They should go to a general practitioner, or to the emergency department.",
			"auto_generates": [ [ "GP:add_one:patient", ":delete:" ] ], # if we want to delete the card say "destroy"
			"variables": {},
			"position": [-0.05, -0.05],
			"package": [
				{ "Symptom": "pain in knee" }, { "Symptom": "headache" }, { "Symptom": "fever" }
			]
		},
		{
			"name": "GP",
			# we will assume that the first entry is the start card
			"texture": ["res://Images/003.png"],
			"duration": 20, # in seconds
			"description": "A general practitioner that might require imaging services. It needs a condition.",
			"auto_generates": [ [ "Order:create:" ] ], # if we want to delete the card say "destroy"
			"variables": { "patient": [] },
			"position": [0.0, 0.1],
			"package": [
				{ "OrderText": "US" }, { "OrderText": "MRI" }, { "OrderText": "CT" }
			],
			"needs": [
				{ "name": "Condition" }
			],
			"needs_generates": [ "Order:create:" ]
		},
		{
			"name": "Order",
			# we will assume that the first entry is the start card
			"texture": ["res://Images/004.png"],
			"duration": 5, # in seconds
			"description": "An order from a general practitioner. Imaging or blood work services might be needed.",
			"auto_generates": [ [ "RIS:add_one:orders", ":delete:" ] ], # if we want to delete the card say "destroy"
			"variables": {},
			"position": [0, 0],
			"package": [
				{ "OrderCode": "ICD-10#1234" }, { "OrderCode": "ICD-10#56789" }
			]
		},
		{
			"name": "RIS",
			"texture": ["res://Images/005.png"],
			"duration": 5, # no tweening, just counting orders
			"description": "Radiology information system keeps track of all orders. Just counting orders right now.",
			"auto_generates": [ [ "Modality:add_one:studies" ] ],
			"variables": { "orders": [] },
			"position": [ 0.1, 0.1 ],
			"package": [
				{ "AccessionNumber": "1234" }, { "AccessionNumber": "5678" }
			],
			"needs": [
				{ "name": "Order" }
			],
			"needs_generates": [ "Modality:add_one:studies" ]
		},
		{
			"name": "Modality",
			"texture": ["res://Images/011.png"],
			"duration": 15, # no tweening, just counting orders
			"description": "An imaging modality, a machine performing scans ordered by a GP producing image studies.",
			"auto_generates": [ [ "Study:add_one:studies" ] ],
			"variables": { "studies": [] },
			"position": [ 0.1, 0.1 ],
			"package": [
				{ "DeviceSeriesNumber": "1234", "Modality": "MR" },
				{ "DeviceSeriesNumber": "9012", "Modality": "US" },
				{ "DeviceSeriesNumber": "5678", "Modality": "CT" }
			]
		},
		{
			"name": "Study",
			"texture": ["res://Images/002.png"],
			"duration": 4, # no tweening, just counting orders
			"description": "An image study for a patient. Studies contain series and series contain images.",
			"auto_generates": [ [ "Series:add_one:series" ] ],
			"variables": { "studies": [] },
			"position": [ 0.1, 0.1 ],
			"package": [
				{ "StudyDate": "20200101", "StudyInstanceUID": "1.2.345" }
			]
		},
		{
			"name": "Series",
			"texture": ["res://Images/007.png"],
			"duration": 0.5, # no tweening, just counting orders
			"description": "An image series is part of an image study. Series have their own name and contain one or more images.",
			"auto_generates": [ [ "Image:add_one:images" ] ],
			"variables": { "series": [] },
			"position": [ 0.1, 0.1 ],
			"package": [
				{ "SeriesNumber": "1", "SeriesInstanceUID": "1.2.345.1", "SeriesDescription": "Loc" },
				{ "SeriesNumber": "2", "SeriesInstanceUID": "1.2.345.2", "SeriesDescription": "T1" }
			]
		},
		{
			"name": "Image",
			"texture": ["res://Images/009.png"],
			"duration": 0, # no tweening, just counting orders
			"description": "An image may contain one or more frames.",
			"auto_generates": [ ],
			"variables": { "images": [] },
			"position": [ 0.1, 0.1 ],
			"package": [
				{ "SOPInstanceUID": "1", "rows": 512, "columns": 512 },
				{ "SOPInstanceUID": "2", "rows": 512, "columns": 512 }
			]
		},
		{
			"name": "Image Archive",
			"texture": ["res://Images/008.png"],
			"duration": 0, # Its just there
			"description": "An image archive stores images for later use.",
			"auto_generates": [ ],
			"variables": { "images": [] },
			"position": [ 0.1, 0.1 ],
			"appears": { "any": [ "Image" ] },
			"package": [
				{ "StoreAcknowledge": true }
			]
		}
	]
};

var hilbert_walk = [
	[0, 0], 
	[1, 0], 
	[1, 1], 
	[0, 1],
	[0, 2], 
	[0, 3], 
	[1, 3], 
	[1, 2], 
	[2, 2], 
	[2, 3], 
	[3, 3],
	[3, 2],
	[3, 1],
	[2, 1],
	[2, 0],
	[3, 0],
	[4, 0],
	[4, 1],
	[5, 1],
	[5, 0],
	[6, 0],
	[7, 0],
	[7, 1],
	[6, 1],
	[6, 2],
	[7, 2],
	[7, 3],
	[6, 3],
	[5, 3],
	[5, 2],
	[4, 2],
	[4, 3],
	[4, 4],
	[4, 5],
	[5, 5],
	[5, 4],
	[6, 4],
	[7, 4],
	[7, 5],
	[6, 5],
	[6, 6],
	[7, 6],
	[7, 7],
	[6, 7],
	[5, 7],
	[5, 6],
	[4, 6],
	[4, 7],
	[3, 7],
	[2, 7],
	[2, 6],
	[3, 6],
	[3, 5],
	[3, 4],
	[2, 4],
	[2, 5],
	[1, 5],
	[1, 4],
	[0, 4],
	[0, 5],
	[0, 6],
	[1, 6],
	[1, 7],
	[0, 7],
	[0, 8],
	[0, 9],
	[1, 9],
	[1, 8],
	[2, 8],
	[3, 8],
	[3, 9],
	[2, 9],
	[2, 10],
	[3, 10],
	[3, 11],
	[2, 11],
	[1, 11],
	[1, 10],
	[0, 10],
	[0, 11],
	[0, 12],
	[1, 12],
	[1, 13],
	[0, 13],
	[0, 14],
	[0, 15],
	[1, 15],
	[1, 14],
	[2, 14],
	[2, 15],
	[3, 15],
	[3, 14],
	[3, 13],
	[2, 13],
	[2, 12],
	[3, 12],
	[4, 12],
	[5, 12],
	[5, 13],
	[4, 13],
	[4, 14],
	[4, 15],
	[5, 15],
	[5, 14],
	[6, 14],
	[6, 15],
	[7, 15],
	[7, 14],
	[7, 13],
	[6, 13],
	[6, 12],
	[7, 12],
	[7, 11],
	[7, 10],
	[6, 10],
	[6, 11],
	[5, 11],
	[4, 11],
	[4, 10],
	[5, 10],
	[5, 9],
	[4, 9],
	[4, 8],
	[5, 8],
	[6, 8],
	[6, 9],
	[7, 9],
	[7, 8],
	[8, 8],
	[8, 9],
	[9, 9],
	[9, 8],
	[10, 8],
	[11, 8],
	[11, 9],
	[10, 9],
	[10, 10],
	[11, 10],
	[11, 11],
	[10, 11],
	[9, 11],
	[9, 10],
	[8, 10],
	[8, 11],
	[8, 12],
	[9, 12],
	[9, 13],
	[8, 13],
	[8, 14],
	[8, 15],
	[9, 15],
	[9, 14],
	[10, 14],
	[10, 15],
	[11, 15],
	[11, 14],
	[11, 13],
	[10, 13],
	[10, 12],
	[11, 12],
	[12, 12],
	[13, 12],
	[13, 13],
	[12, 13],
	[12, 14],
	[12, 15],
	[13, 15],
	[13, 14],
	[14, 14],
	[14, 15],
	[15, 15],
	[15, 14],
	[15, 13],
	[14, 13],
	[14, 12],
	[15, 12],
	[15, 11],
	[15, 10],
	[14, 10],
	[14, 11],
	[13, 11],
	[12, 11],
	[12, 10],
	[13, 10],
	[13, 9],
	[12, 9],
	[12, 8],
	[13, 8],
	[14, 8],
	[14, 9],
	[15, 9],
	[15, 8],
	[15, 7],
	[14, 7],
	[14, 6],
	[15, 6],
	[15, 5],
	[15, 4],
	[14, 4],
	[14, 5],
	[13, 5],
	[13, 4],
	[12, 4],
	[12, 5],
	[12, 6],
	[13, 6],
	[13, 7],
	[12, 7],
	[11, 7],
	[11, 6],
	[10, 6],
	[10, 7],
	[9, 7],
	[8, 7],
	[8, 6],
	[9, 6],
	[9, 5],
	[8, 5],
	[8, 4],
	[9, 4],
	[10, 4],
	[10, 5],
	[11, 5],
	[11, 4],
	[11, 3],
	[11, 2],
	[10, 2],
	[10, 3],
	[9, 3],
	[8, 3],
	[8, 2],
	[9, 2],
	[9, 1],
	[8, 1],
	[8, 0],
	[9, 0],
	[10, 0],
	[10, 1],
	[11, 1],
	[11, 0],
	[12, 0],
	[13, 0],
	[13, 1],
	[12, 1],
	[12, 2],
	[12, 3],
	[13, 3],
	[13, 2],
	[14, 2],
	[14, 3],
	[15, 3],
	[15, 2],
	[15, 1],
	[14, 1],
	[14, 0],
	[15, 0]
];

# Called when the node enters the scene tree for the first time.
func _ready():
	# create all nodes that are there at the start
	for card_template in card_setup.cards:
		#var all_cards = get_tree().get_nodes_in_group("cards")
		#print("number of cards in group is: ", all_cards.size());
		if card_template.has("create_on_ready") and card_template.create_on_ready:
			var card = create_card_from_template(card_template)
			add_child(card);
			card.add_to_group("cards")
			card.get_node("card").input_package = {}
			var potential_variables = card.get_node("card").card_template.package
			if potential_variables.size() > 0:
				var picked_variables = potential_variables[randi_range(0,potential_variables.size()-1)]
				for key in picked_variables.keys():
					card.get_node("card").input_package[key] = picked_variables[key]
			print(card.get_node("card").input_package)
	hide_window();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if do_do_appears:
		do_appears()
	pass
	
func show_window( card ):
	var description = card.description
	var title = card.title
	var texture = card.texture
	var needs = []
	if "needs" in card.card_template:
		needs = card.card_template['needs']
		
	# we should also change the text here
	get_node("../GUIPanel3D/SubViewport/Control/Panel/RichTextLabel").text = description
	get_node("../GUIPanel3D/SubViewport/Control/Panel/Title").text = title
	get_node("../GUIPanel3D/SubViewport/Control/Panel/card_logo").texture = load(texture)
	
	# get_node("/root/Node3D/Window").title = title
	get_node("../GUIPanel3D/SubViewport/Control/Panel/HBoxContainer/frame1").hide()
	get_node("../GUIPanel3D/SubViewport/Control/Panel/HBoxContainer/frame2").hide()
	get_node("../GUIPanel3D/SubViewport/Control/Panel/HBoxContainer/frame3").hide()
	var count = 0
	for need in needs:
		# there are up to three fields in need of a card, we should probably 
		# have a texture for need fulfilled as well...
		if count == 0:
			get_node("../GUIPanel3D/SubViewport/Control/Panel/HBoxContainer/frame1").show()
		if count == 1:
			get_node("../GUIPanel3D/SubViewport/Control/Panel/HBoxContainer/frame2").show()
		if count == 2:
			get_node("../GUIPanel3D/SubViewport/Control/Panel/HBoxContainer/frame3").show()
		count = count + 1
	
	get_node("../GUIPanel3D").title = title
	get_node("../GUIPanel3D").setCurrentCard(card)
	get_node("../GUIPanel3D").show()
	pass

func hide_window():
	get_node("../GUIPanel3D").hide()
	pass
	
func toggle_window( card ):
	if get_node("../GUIPanel3D").is_visible() and get_node("../GUIPanel3D").title == card.title:
		hide_window()
	else:
		show_window(card)

func perform_card_action(this_card, todo):
	# split the string into pieces
	var todo_pieces = todo.split(":")
	if todo_pieces.size() == 1:
		# create a card with that name
		print("create a new card with name: " + todo[0])
		for card_template in card_setup.cards:
			if card_template.name == todo_pieces[0]:
				var card = create_card_from_template(card_template)
				add_child(card);
				card.add_to_group("cards")  # card.add_to_group("cards");
				# we should add the this_card.input_package to the 
				# new cards input_package
				card.get_node("card").input_package = this_card.input_package
				var potential_variables = card.get_node("card").card_template.package
				if potential_variables.size() > 0:
					var picked_variables = potential_variables[randi_range(0,potential_variables.size()-1)]
					for key in picked_variables.keys():
						card.get_node("card").input_package[key] = picked_variables[key]
				print("input_package: ", card.get_node("card").input_package)
		pass
	else:
		# if we have more than one entry we update a values instead
		# assume todo_pieces.size() == 3
		var card_name = todo_pieces[0]
		var action = todo_pieces[1]
		var target_variable = todo_pieces[2]
		print("update a variable in " + card_name + ", action: " + action + ", variable: " + target_variable);
		# check if that card exists already, if not create it first
		var found = false
		var card
		var all_cards = get_tree().get_nodes_in_group("cards")
		for c in all_cards:
			#print("title: " + c.get_node("card").title + " title: " + card_name);
			if is_instance_valid(c) and c.has_node("card") and c.get_node("card").title == card_name:
				# is_instance_valid(c.get_node("card")) and c.get_node("card").title == card_name:
				card = c
				found = true
			pass
		if !found:
			# lets create that card first, lookup the card_template
			# could this happen more than once? We should call the function
			# afterwards (wait a bit before adding more)
			for card_template in card_setup.cards:
				if card_template.name == card_name:
					card = create_card_from_template(card_template)
					add_child(card);
					card.add_to_group("cards")  # card.add_to_group("cards");
					card.get_node("card").input_package = this_card.input_package
					# we need to use one of the card_template.variables[rand()]
					if "package" in card.get_node("card").card_template:
						var potential_variables = card.get_node("card").card_template.package
						if potential_variables.size() > 0:
							var picked_variables = potential_variables[randi_range(0,potential_variables.size()-1)]
							for key in picked_variables.keys():
								card.get_node("card").input_package[key] = picked_variables[key]
						print("input_package: ", card.get_node("card").input_package)
					break
				pass
			pass
		# now increase the value in that card by 1
		if action == "add_one":
			# add one but as a package from this node, should be merged with
			# the package triggering this step
			var pack = {};
			if "package" in this_card.card_template:
				pack = this_card.card_template.package;
			if is_instance_valid(card) and card.has_node("card"):
				if !target_variable in card.get_node("card").card_template.variables:
					print("something wrong here! The card " + this_card.title + " tries to add variable " + target_variable + " to "+ card.get_node("card").title)
				card.get_node("card").card_template.variables[target_variable].append(pack);
				print("variable " + card_name + " " + target_variable + " has now value " + str(card.get_node("card").card_template.variables[target_variable]))
				card.get_node("card").update_card();
		elif action == "create":
			# create a new card of that type
			# but this happened already above there
			if found:
				for card_template in card_setup.cards:
					if card_template.name == card_name:
						card = create_card_from_template(card_template)
						add_child(card);
						card.add_to_group("cards")  # card.add_to_group("cards");
						card.get_node("card").input_package = this_card.input_package
						var potential_variables = card.get_node("card").card_template.package
						if potential_variables.size() > 0:
							var picked_variables = potential_variables[randi_range(0,potential_variables.size()-1)]
							for key in picked_variables.keys():
								card.get_node("card").input_package[key] = picked_variables[key]
						print("input_package: ", card.get_node("card").input_package)
			pass
		elif action == "delete":
			if is_instance_valid(this_card):
				this_card.card_remove()
				# remove its tween
				#this_card.tween.kill()
				# remove this card from the group
				#this_card.remove_from_group("cards");
				# remove this card
				#this_card.queue_free()
		else:
			print("unknown action: " + action + ". Ignore for now...");
	# check if we can create a card based on some rules
	do_do_appears = true
	#do_appears()
	pass

func do_appears():
	if !do_do_appears:
		return
	do_do_appears = false
	# "appears": { "any": [ "Image" ] }
	# problem with this code is that it might add more than one card.
	# in that case the placement will only know about the first card... why?
	for card_template in card_setup.cards:
		if "appears" in card_template:
			var targets = []
			if "any" in card_template.appears:
				targets = card_template.appears.any
				# any of the targets need to be there for this trigger to start
				for target in targets:
					var foundThis = false
					var foundTarget = false
					var all_cards = get_tree().get_nodes_in_group("cards")
					for c in all_cards:
						if c.get_node("card") and c.get_node("card").title == target:
							foundTarget = true
						if c.get_node("card") and c.get_node("card").title == card_template.name:
							foundThis = true
					if foundTarget and not foundThis:
						# create this card_template
						var card = create_card_from_template(card_template)
						add_child(card);
						card.add_to_group("cards")  # card.add_to_group("cards");
						card.get_node("card").input_package = {}
						var potential_variables = card.get_node("card").card_template.package
						if potential_variables.size() > 0:
							var picked_variables = potential_variables[randi_range(0,potential_variables.size()-1)]
							for key in picked_variables.keys():
								card.get_node("card").input_package[key] = picked_variables[key]
						print("input_package: ", card.get_node("card").input_package)
						# we did something so call again
						do_do_appears = true
						return
			else:
				print("Warning: found appears but no any.")
	pass

func get_pos_close_to_location(proposed_aabb):
	# goal is to retun a placement location for a new card
	# close the proposed location but not overlapping with any
	# existing card (use brute force)
	# todo: we should count only positions on the table y == 0
	# both in the received position as well as on the table (might still be in the air)
	#var we_did_something = true
	#while(we_did_something) {
	var cards = get_tree().get_nodes_in_group("cards");
	var bboxes = [];
	# fill in all current locations of cards
	for card in cards:
		#var obj2 = card.get_node("card").get_transformed_aabb()
		#var obj2 = card.get_node("card/MeshInstance3D")
		#if obj2 != null:
		#	var bbox_aabb = get_aabb_global_endpoints(obj2)
		#	pass
		if !is_instance_valid(card) or !card.has_node("card") or !card.has_node("card/MeshInstance3D"):
			continue
		var obj = card.get_node("card/MeshInstance3D")
		# why would this be empty??
		if obj != null:
			var box_aabb = obj.get_aabb()
			var box_aabb_position = obj.to_global(box_aabb.position)
			box_aabb_position.y = 0
			var box_aabb_size = box_aabb.size
			bboxes.insert(bboxes.size(), AABB(box_aabb_position, box_aabb_size))
		#else:
		#	print("Error: We found a null object, should not happen!");
	# check if we have an intersection, if not return input position
	var foundIntersection = false
	for bbox in bboxes:
		if proposed_aabb.intersects(bbox):
			foundIntersection = true
			break
	if !foundIntersection:
		return proposed_aabb.get_center()
	# Now we know that there is an intersection right now
	# lets move around until we get lucky, we would like to 
	# generate new centers that are "spaced around" the current
	# center
	var orig_position = proposed_aabb.position
	var orig_size = proposed_aabb.size
	var spacing = 0.035 # might need different values for x and y
	for entry in hilbert_walk:
		# use the entry to compute a possible location
		proposed_aabb = AABB(
			Vector3(orig_position[0] + entry[0]*spacing, 
					orig_position[1], 
					orig_position[2] + entry[1]*spacing), 
			orig_size);
		
		# and test if we have no intersection
		foundIntersection = false
		for bbox in bboxes:
			if proposed_aabb.intersects(bbox):
				foundIntersection = true
				break
		if !foundIntersection:
			return proposed_aabb.get_center()
	print("Warning: could not find a safe location to place this card, use default.")
	return proposed_aabb.get_center()


func create_card_from_template(card_template):
	print("start creating card from template " + card_template.name);
	var card = preload("res://card.tscn").instantiate(); # get_tree().get_root().get_node("card/Node3D/card")
	card.get_node("card").card_template = card_template;
	card.get_node("card").title = card_template.name;
	card.get_node("card").description = card_template.description;
	#add_child(card);
	#var nc = card.get_node("card");
	var create_pos = Vector3(0.1, 0.0, 0.1); #event.pos to Vector2()
	if card_template.position:
		create_pos = Vector3(card_template.position[0], 0, card_template.position[1]);
	#card.global_position = create_pos
	card.global_transform.origin = create_pos
	# the proposed location in global space
	var mesh = card.get_node("card/MeshInstance3D")
	var proposed_aabb = mesh.get_aabb()
	var proposed_position = proposed_aabb.position
	var proposed_size = proposed_aabb.size
	var proposed_global_aabb = AABB(mesh.to_global(proposed_position), proposed_size)
	create_pos = get_pos_close_to_location(proposed_global_aabb)
	#card.global_position = create_pos; # set the pos to the building
	#card.transform.origin = create_pos; # set the pos to the building
	card.global_transform.origin = create_pos;

	var tex_rand = card_template.texture[randi_range(0,card_template.texture.size()-1)]
	card.get_node("card").texture = tex_rand
	var imported_resource = load(tex_rand)
	#print(tex_rand)
	card.get_node("card/Sprite3D").texture = imported_resource
	card.get_node("card").ground_reference = self; # keep the Ground as a reference so ew can call perform_card_action
	#card.add_to_group("cards");
	# packages that are created at initialization do not have an id?
	# we would need continuous generation and one time generation,
	# guess its ok to just to one time but never delete, if the timeout
	# calls the structure again we can do it again, do we need an uuid?
	card.get_node("card").input_package = {};
		
	return card

func _unhandled_input(event):
	if Input.is_action_just_released("toggle_pause"):
		var cards = get_tree().get_nodes_in_group("cards")
		if !paused:
			for card in cards:
				if is_instance_valid(card) and is_instance_valid(card.get_node("card")):
					card.get_node("card").pause()
		else:
			for card in cards:
				if is_instance_valid(card) and is_instance_valid(card.get_node("card")):
					card.get_node("card").unpause()
		paused = !paused

#func _input_event(camera, event, pos, normal, shape):	
#	if event is InputEventMouseButton:
#		# we don't want this, we should create whenever a card tells us
#		if (event.button_index == 2 and event.pressed):
#			#var cards = get_tree().get_nodes_in_group("cards");
#			print("add a new card to the cards group")
#			# add a new card at a random position
#			var card = preload("res://card.tscn").instantiate(); # get_tree().get_root().get_node("card/Node3D/card")
#			var nc = card.get_node("card");
#			#add_node(nc);
#			add_child(card);
#			nc.global_position = create_pos; # set the pos to the building
#			#nc.position = new position(0.1,0.02,0.1);
#			# do some more setup
#			var imported_resource = load("res://Images/Dummy card top 2.png")
#			card.get_node("card/Sprite3D").texture = imported_resource
#			#card.add_to_group("cards");
#			# get all cards
#	pass

# linked using the user interface in godot
func _on_window_close_requested():
	hide_window()
