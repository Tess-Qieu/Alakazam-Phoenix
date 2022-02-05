extends PanelContainer

# Node variables
onready var MenuBt = $VBoxContainer/MenuBar_Background/MenuBar/MenuButton
onready var MenuPopup : PopupMenu
# Ressources references
const MapClass = preload("res://Scenes/Map.tscn")

# Children references
onready var myWorldRoot = $VBoxContainer/HBoxContainer/Viewport_Container/myWorldRoot
var myMap = null

# Dictionary containing every data to compute the world (Map, Characters...)
var world : Dictionary = {}

# Path to world file
var worldSave : File = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Signal connections to MenuButton
	MenuPopup = MenuBt.get_popup()
	MenuPopup.connect("index_pressed", self, "_on_itemPressed_MenuBt")


func _on_itemPressed_MenuBt(index: int):
	# find the correct action given the 
	match(MenuPopup.get_item_text(index)):
		"New":
			newWorld()
		"Save":
			saveMap()
		"Save as":
			print("Where's the dialog window to save as ?")
		"Load":
			print("Nothing to load")
		_:
			print("Action '{0}' not handled".format([MenuPopup.get_item_text(index)]))

func saveMap():
	if myWorldRoot.get_child_count() == 0:
		print("No world to save")
	else:
		print("Can you save me ?")

func newWorld():
	print("New world!")
	# Destroy previous world
	for child in myWorldRoot.get_children():
		myWorldRoot.remove_child(child)
		child.queue_free()
	
	## Create a new map ##
	# Instanciate new map
	myMap = MapClass.instance()
	# Initialize new map
	# Generate map
	myMap.generate_grid()
	myMap.instance_map(myMap.grid)
	# Add map
	myWorldRoot.add_child(myMap)
	print("Map ok!")
