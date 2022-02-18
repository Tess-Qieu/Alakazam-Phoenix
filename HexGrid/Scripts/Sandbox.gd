extends PanelContainer

enum actions {None, MapTool_DrawPath}

# Node variables
onready var MenuBt = $VBoxContainer/MenuBar_Background/MenuBar/MenuButton
onready var MenuPopup : PopupMenu
onready var PathSlider = $VBoxContainer/HBoxContainer/ToolsMenu/MapTools/PathWidget/HSlider
# Ressources references
const MapClass = preload("res://Scenes/Map.tscn")

# Children references
onready var viewportContainer = $VBoxContainer/HBoxContainer/Viewport_Container
onready var myWorldRoot = $VBoxContainer/HBoxContainer/Viewport_Container/myWorldRoot
var myMap : HexMap = null

# Dictionary containing every data to compute the world (Map, Characters...)
var world : Dictionary = {}

# Path to world file
var worldSave : File = null

# Set of cells to be memorized
var cells_set = []

# Action being activated
var current_action = actions.None



# Called when the node enters the scene tree for the first time.
func _ready():
	# Signal connections to MenuButton
	MenuPopup = MenuBt.get_popup()
	MenuPopup.connect("index_pressed", self, "_on_itemPressed_MenuBt")
	$VBoxContainer/HBoxContainer/ToolsMenu/MapTools/PathWidget/Button\
		.connect("toggled", self, "_on_PathButton_toggled")


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
	myMap.generate_grid(true)
	myMap.instance_map(myMap.grid, self)
	# Add map
	myWorldRoot.add_child(myMap)
	print("Map ok!")

func _on_cell_hovered(cell):
	# Behaviour to draw path
	if current_action == actions.MapTool_DrawPath:
		if cells_set.empty():
			# If no cell is selected, only the hovered cell is highlighted
			myMap.clear()
			myMap.display_path(cell, cell, 10)
		elif cells_set.size() == 1:
			# Draw a path from selected cell to hovered cell
			myMap.clear()
			cells_set[0].change_material("darkgreen")
			myMap.display_path(cells_set[0], cell, PathSlider.value)
			
func _on_cell_clicked(cell):
	# Behaviour to draw path
	if current_action == actions.MapTool_DrawPath:
		if cells_set.empty():
			# If no cell is selected, save the clicked cell as path beginning
			cells_set = [cell]
		else:
			# Saves the path from initial cell to clicked cell
			cells_set = myMap.display_path(cells_set[0], cell, PathSlider.value, true)


func _on_PathButton_toggled(button_pressed:bool):
	if button_pressed:
		current_action = actions.MapTool_DrawPath
	else:
		current_action = actions.None
	# Clear cell selection
	cells_set.clear()
	myMap.clear()
