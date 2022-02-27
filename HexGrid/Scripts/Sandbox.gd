extends Control

enum actions {None, MapTool_DrawPath, MapTool_CellKindChange, MapTool_DrawCircle}

# Node variables
onready var MenuBt = $PanelContainer/VBoxContainer/MenuBar_Background/MenuBar/MenuButton
onready var MenuPopup : PopupMenu
onready var PathWidget = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/PathWidget
onready var Pathbutton = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/PathWidget/Button
onready var PathSlider = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/PathWidget/HSlider
onready var ToolsMenu  = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu
onready var CellKindBt = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/CellKindWidget/CellKind_Bt
onready var CellKindPopup = $CellKindPopup
onready var kindHoleBt  = $CellKindPopup/VBoxContainer/HBoxContainer/KindBt_Hole
onready var kindFloorBt = $CellKindPopup/VBoxContainer/HBoxContainer/KindBt_Floor
onready var kindWallBt  = $CellKindPopup/VBoxContainer/HBoxContainer/KindBt_Wall
onready var myFileDialog = $FileDialog
onready var circleBt = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/ShapeDrawingWidget/CircleButton
# Ressources references
const MapClass = preload("res://Scenes/Map.tscn")

# Children references
onready var myWorldRoot = $PanelContainer/VBoxContainer/HBoxContainer/Viewport_Container/myWorldRoot
var myMap : HexMap = null
var current_bt : Button = null

# Dictionary containing every data to compute the world (Map, Characters...)
var world : Dictionary = {}

# Path to world file
var myWorldSave = ""

# Set of cells to be memorized
var cells_set = []

# Action being activated
var current_action = actions.None



# Called when the node enters the scene tree for the first time.
func _ready():
	# Signal connections to MenuButton
	MenuPopup = MenuBt.get_popup()
	# warning-ignore:return_value_discarded
	MenuPopup.connect("index_pressed", self, "_on_itemPressed_MenuBt")
	
	## Path widget connections ##
	# Button action
	Pathbutton.connect("toggled", self, "_on_Button_Toggled", [Pathbutton])
	# Popup link
	PathWidget.popUp = $DrawPathPanel
	
	## Cell Kind Widget connections ##
	# Button action
	CellKindBt.connect("toggled", self, "_on_Button_Toggled", [CellKindBt])
	# Cell kind popup buttons
	kindFloorBt.connect("pressed", self, "_on_cellKindChange_requested", ['floor'])
	kindHoleBt.connect("pressed", self, "_on_cellKindChange_requested", ['hole'])
	kindWallBt.connect("pressed", self, "_on_cellKindChange_requested", ['full'])
	
	circleBt.connect("toggled", self, "_on_Button_Toggled", [circleBt])
	
	
	myFileDialog.connect("file_selected", self, "_on_file_selected")
	
	
	# At openning the sandbox, no world exists. So all tabs are deactivated
	for child_index in range(ToolsMenu.get_child_count()):
		ToolsMenu.set_tab_disabled(child_index, true)
		ToolsMenu.visible = false


func _on_itemPressed_MenuBt(index: int):
	# find the correct action given the 
	match(MenuPopup.get_item_text(index)):
		"New":
			newWorld()
		"Save":
			saveWorld()
		"Save as":
			saveWorldAs()
		"Load":
			myFileDialog.mode = FileDialog.MODE_OPEN_FILE
			myFileDialog.show()
		_:
			print("Action '{0}' not handled".format([MenuPopup.get_item_text(index)]))

func saveWorld():
	if myWorldRoot.get_child_count() == 0:
		print("No world to save")
	elif myWorldSave.empty():
		saveWorldAs()
	else:
		var saveFile = File.new()
		saveFile.open(myWorldSave, File.WRITE)
		print("Saving in {0}\n".format([saveFile.get_path()]))
		var data_to_save = {}
		data_to_save["myMap"] = myMap.save()
		saveFile.store_line(to_json(data_to_save))
		saveFile.close()

func saveWorldAs():
	if myWorldRoot.get_child_count() == 0:
		print("No world to save")
	else :
		myFileDialog.mode = FileDialog.MODE_SAVE_FILE
		myFileDialog.show()

func loadWorld():
	if myWorldSave.empty():
		print("No file to load")
	else:
		var loadFile = File.new()
		loadFile.open(myWorldSave, File.READ)
		print("Loading world from {0}".format([loadFile.get_path()]))
		var world_data = parse_json(loadFile.get_line())
		if world_data is Dictionary and world_data.has("myMap"):
				newWorld(world_data["myMap"])
		else:
			print("Error loading map in data: {0}".format((world_data)))
		loadFile.close()

func _destroyPreviousWorld():
	# Remove and destroy all childs of 
	for child in myWorldRoot.get_children():
			myWorldRoot.remove_child(child)
			child.queue_free()

func newWorld(grid = null):
#	print("New world!")
	_destroyPreviousWorld()
	
	## Create a new map ##
	# Instanciate new map
	myMap = MapClass.instance()
	# Initialize new map
	# Generate map
	if (grid == null):
		myMap.generate_grid(true)
	else:
		myMap.grid = grid
	myMap.instance_map(myMap.grid, self)
	# Add map
	myWorldRoot.add_child(myMap)
#	print("Map ok!")
	
	# Activate MapTools in ToolMenu
	ToolsMenu.visible = true
	var index = ToolsMenu.get_node("MapTools").get_index()
	ToolsMenu.set_tab_disabled(index, false)

func _on_cell_hovered(cell):
	match current_action:
		actions.MapTool_DrawPath:
			# Behaviour to draw path
			if myMap.is_cell_selectible(cell):
				if cells_set.empty():
					# If no cell is selected, only the hovered cell is highlighted
					myMap.clear()
					myMap.change_cell_color(cell, 'green')
				elif cells_set.size() == 1:
					# Draw a path from selected cell to hovered cell
					myMap.clear()
					myMap.change_cell_color(cells_set[0], 'darkgreen')
					myMap.display_path(cells_set[0], cell, PathSlider.value)
		
		actions.MapTool_CellKindChange:
			if cells_set.empty() and cell.kind != "border":
				myMap.clear_all()
				myMap.change_cell_color(cell, 'grey')
		
		actions.MapTool_DrawCircle:
			if cells_set.empty() and myMap.is_cell_selectible(cell):
				# If no cell is selected, only the hovered cell is highlighted
				myMap.clear()
				myMap.change_cell_color(cell, 'green')
			elif cells_set.size() == 1:
				var radius = myMap.distance_cells(cell, cells_set[0])
				myMap.clear()
				myMap.change_cell_color(cells_set[0], 'darkgreen')
				myMap.display_circle(cells_set[0], radius)

func _on_cell_clicked(cell):
	match current_action:
		actions.MapTool_DrawPath:
			# Behaviour to draw path
			if cells_set.size() != 1:
				# If no cell is selected, save the clicked cell as path beginning
				cells_set = [cell]
				myMap.clear()
				myMap.change_cell_color(cells_set[0],"darkgreen")
			else:
				# Saves the path from initial cell to clicked cell
				cells_set = myMap.display_path(cells_set[0], cell, PathSlider.value, true)
		
		actions.MapTool_CellKindChange:
			if cells_set.empty():
				# Behaviour to change cell kind
				CellKindPopup.rect_position = get_global_mouse_position() \
							+ Vector2(-CellKindPopup.rect_size[0], 0)
				CellKindPopup.show()
				cells_set = [cell]
		
		actions.MapTool_DrawCircle:
			# Behaviour to draw path
			if cells_set.size() != 1:
				# If no cell is selected, save the clicked cell as path beginning
				cells_set = [cell]
				myMap.clear()
				myMap.change_cell_color(cells_set[0],"darkgreen")
			else:
				# Saves the path from initial cell to clicked cell
				var radius = myMap.distance_cells(cell, cells_set[0])
				cells_set = myMap.display_circle(cells_set[0], radius)

func _on_Button_Toggled(button_pressed:bool, changed_bt : Button):
	#print("Button {0} set to {1}".format([changed_bt.name, button_pressed]))
	
	if button_pressed:
		# Select action given the pressed button
		match changed_bt:
			Pathbutton:
				current_action = actions.MapTool_DrawPath
			CellKindBt:
				current_action = actions.MapTool_CellKindChange
			circleBt:
				current_action = actions.MapTool_DrawCircle
		
		# If a button was already pressed, it is unpressed. The currently active
		# button is now the clicked button
		var previous_bt : Button = current_bt
		current_bt = changed_bt
		if previous_bt != null:
			#print("Button unselected: {0}".format([previous_bt.name]))
			previous_bt.pressed = false
			match previous_bt:
				CellKindBt:
					CellKindPopup.hide()
	
	elif current_bt == changed_bt:
		# If a button is unpressed and the currently active button is himself
		# then no specific behaviour or action must be active
#		print("Button: {0}\nAction: {1}".format([changed_bt.name, actions.keys()[current_action]]))
		match current_action:
			actions.MapTool_CellKindChange:
				CellKindPopup.hide()
		
		current_action = actions.None
		current_bt = null

	# print("Current action: {0}".format([actions.keys()[current_action]]))
	# Clear cell selection
	cells_set.clear()
	myMap.clear_all()

func _on_cellKindChange_requested(kind):
	if cells_set.size() == 1:
		myMap.change_cell_kind(cells_set[0], kind, self)
		CellKindPopup.hide()
		# Clear cell selection
		cells_set.clear()
		myMap.clear()

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			# Unselect current mode on escape key pressed
			match current_action:
				actions.MapTool_DrawPath:
					Pathbutton.pressed = false
				actions.MapTool_CellKindChange:
					CellKindBt.pressed = false
				actions.MapTool_DrawCircle:
					circleBt.pressed = false

func _on_file_selected(file_selected: String):
	myWorldSave = file_selected
	match myFileDialog.mode:
		FileDialog.MODE_SAVE_FILE:
			# When the dialog is openned to save the world
			saveWorld()
		FileDialog.MODE_OPEN_FILE:
			# When the dialog is oppened to load a saved world
			loadWorld()
	myFileDialog.hide()
