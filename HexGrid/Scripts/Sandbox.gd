extends Control

enum actions {None, MapTool_DrawPath, MapTool_CellKindChange, 
					MapTool_DrawCircle, MapTool_ResizeArena,
					MapTool_SelectKind, MapTool_CircleAnim, MapTool_SpiralAnim,
					MapTool_Symmetry }

# Node variables ###############################################################
onready var MenuBt = $PanelContainer/VBoxContainer/MenuBar_Background/MenuBar/MenuButton
onready var MenuPopup : PopupMenu
onready var ToolsMenu = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu
onready var myFileDialog  = $FileDialog

# Path
onready var PathWidget = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/VBoxContainer2/PathWidget
onready var Pathbutton = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/VBoxContainer2/PathWidget/Button
onready var PathSlider = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/VBoxContainer2/PathWidget/HSlider

# Shapes
onready var circleBt = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/VBoxContainer2/ShapeDrawingWidget/CircleButton

# Symmetry
onready var SymmetryBt = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/VBoxContainer2/SymmetryWidget/SymmetryBt
onready var SymOpti_Bt = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/VBoxContainer2/SymmetryWidget/SymOptionButton

# Arena size
onready var ArenaSizeBt   = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/ArenaSizeWidget/ResizeArena_Bt
onready var ArenaSizeSl   = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/ArenaSizeWidget/ArenaSize_Slider

# Kind change
onready var CellKindBt    = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/VBoxContainer/CellKindWidget/CellKind_Bt
onready var CellKindPopup = $CellKindPopup
onready var kindHoleBt    = $CellKindPopup/VBoxContainer/HBoxContainer/KindBt_Hole
onready var kindFloorBt   = $CellKindPopup/VBoxContainer/HBoxContainer/KindBt_Floor
onready var kindWallBt    = $CellKindPopup/VBoxContainer/HBoxContainer/KindBt_Wall

# Kind selection
onready var KindSelBt     = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/VBoxContainer/KindSelectorWidget/KindSelectBt

# Animation // circles
onready var CirclesAnimBt         = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/AnimationWidget/CirclesWidget/CirclesAnimBt
onready var CirclesAnimRadiusSBox = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/AnimationWidget/CirclesWidget/Radius_SpinBox
onready var CirclesAnimWidth_SBox = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/AnimationWidget/CirclesWidget/WaveWidth_SpinBox
onready var CirclesAnimModeGroup  = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/AnimationWidget/CirclesWidget/AnimationMode_Selector/Both_CircleCBox.group

# Animation // spiral
onready var SpiralAnimBt         = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/AnimationWidget/SpiralWidget/SpiralAnimBt
onready var SpiralAnimRadiusSBox = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/AnimationWidget/SpiralWidget/Radius_SpinBox
onready var SpiralAnimWidth_SBox = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/AnimationWidget/SpiralWidget/WaveWidth_SpinBox
onready var SpiralAnimModeGroup  = $PanelContainer/VBoxContainer/HBoxContainer/ToolsMenu/MapTools/AnimationWidget/SpiralWidget/AnimationMode_Selector/Both_SpiralCBox.group
################################################################################

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
	
	## Symmetry widget connections ##
	# Button action
	SymmetryBt.connect("toggled", self, "_on_Button_Toggled", [SymmetryBt])
	
	## Cell Kind Widget connections ##
	# Button action
	CellKindBt.connect("toggled", self, "_on_Button_Toggled", [CellKindBt])
	# Cell kind popup buttons
	kindFloorBt.connect("pressed", self, "_on_cellKindChange_requested", ['floor'])
	kindHoleBt.connect("pressed", self, "_on_cellKindChange_requested", ['hole'])
	kindWallBt.connect("pressed", self, "_on_cellKindChange_requested", ['full'])
	
	## Shapes drawing widget  connections ##
	circleBt.connect("toggled", self, "_on_Button_Toggled", [circleBt])
	
	## Arena Size widget ##
	ArenaSizeBt.connect("toggled", self, "_on_Button_Toggled", [ArenaSizeBt])
	
	## Kind Selector widget ##
	KindSelBt.connect("item_selected", self, "_on_kind_selected")
	
	## Animation Widget ##
	CirclesAnimBt.connect("toggled", self, "_on_Button_Toggled", [CirclesAnimBt])
	CirclesAnimModeGroup.get_buttons()[0].pressed = true
	SpiralAnimBt.connect("toggled", self, "_on_Button_Toggled", [SpiralAnimBt])
	SpiralAnimModeGroup.get_buttons()[0].pressed = true
	
	## PopUps
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
		
		actions.MapTool_CircleAnim, actions.MapTool_SpiralAnim:
			if cells_set.empty() and myMap.is_cell_selectible(cell):
				# If no cell is selected, only the hovered cell is highlighted
				myMap.clear()
				myMap.change_cell_color(cell, 'skyblue')
		
		actions.MapTool_Symmetry:
			if cells_set.empty():
				myMap.clear_all()
				myMap.change_cell_color(cell, 'darkgreen')
				myMap.change_cell_color(myMap.get_symmetrical_cell(cell, SymOpti_Bt.selected), 'green')

func _on_cell_clicked(cell):
	match current_action:
		actions.MapTool_DrawPath:
			if myMap.is_cell_selectible(cell):
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
			if myMap.is_cell_selectible(cell):
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
		
		actions.MapTool_CircleAnim:
			if myMap.is_cell_selectible(cell) and cells_set.empty():
				myMap.clear()
				myMap.change_cell_color(cell, "blue")
				# Unselect button at animation ending. 
				# Animation is started only if the connection did go well
				if myMap.connect("animation_ended", CirclesAnimBt, "set_pressed", [false]) == OK:
					# Get animation mode
					var anim_mode
					match CirclesAnimModeGroup.get_pressed_button().name:
						"OutIn_CircleCBox":
							anim_mode = myMap.anim_mode.OUT_IN
						"Both_CircleCBox":
							anim_mode = myMap.anim_mode.BOTH
						_,"InOut_CircleCBox":
							anim_mode = myMap.anim_mode.IN_OUT
					myMap.animate_cirles(cell, CirclesAnimRadiusSBox.value, anim_mode, CirclesAnimWidth_SBox.value)
					cells_set = [cell]
		
		actions.MapTool_SpiralAnim:
			if myMap.is_cell_selectible(cell) and cells_set.empty():
				myMap.clear()
				myMap.change_cell_color(cell, "blue")
				# Unselect button at animation ending. 
				# Animation is started only if the connection did go well
				if myMap.connect("animation_ended", SpiralAnimBt, "set_pressed", [false]) == OK:
					# Get animation mode
					var anim_mode
					match SpiralAnimModeGroup.get_pressed_button().name:
						"OutIn_SpiralCBox":
							anim_mode = myMap.anim_mode.OUT_IN
						"Both_SpiralCBox":
							anim_mode = myMap.anim_mode.BOTH
						_,"InOut_SpiralCBox":
							anim_mode = myMap.anim_mode.IN_OUT
					myMap.animate_spiral(cell, SpiralAnimRadiusSBox.value, anim_mode, SpiralAnimWidth_SBox.value)
					cells_set = [cell]


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
			ArenaSizeBt:
				current_action = actions.MapTool_ResizeArena
				myMap.change_arena_size(ArenaSizeSl.value, self)
				ArenaSizeBt.pressed = false
			KindSelBt:
				current_action = actions.MapTool_SelectKind
			CirclesAnimBt:
				current_action = actions.MapTool_CircleAnim
			SpiralAnimBt:
				current_action = actions.MapTool_SpiralAnim
			SymmetryBt:
				current_action = actions.MapTool_Symmetry
		
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
				KindSelBt:
					if changed_bt != KindSelBt:
						KindSelBt.select(0)
	
	elif current_bt == changed_bt:
		# If a button is unpressed and the currently active button is himself
		# then no specific behaviour or action must be active
#		print("Button: {0}\nAction: {1}".format([changed_bt.name, actions.keys()[current_action]]))
		match current_action:
			actions.MapTool_CellKindChange:
				CellKindPopup.hide()
			actions.MapTool_SelectKind:
				KindSelBt.select(0)
			actions.MapTool_CircleAnim:
				# Disconnect the callback when animation has ended to avoid
				#  conflicts between various animations
				myMap.disconnect("animation_ended", CirclesAnimBt, "set_pressed")
			actions.MapTool_SpiralAnim:
				# Disconnect the callback when animation has ended to avoid
				#  conflicts between various animations
				myMap.disconnect("animation_ended", SpiralAnimBt, "set_pressed")
		
		current_action = actions.None
		current_bt = null

	# print("Current action: {0}".format([actions.keys()[current_action]]))
	# Clear cell selection
	cells_set.clear()
	myMap.clear_all()

func _on_kind_selected(index : int):
	# When selecting a kind in the option button, the option text is saved
	# Button toggling function is called to ensure a coherent behaviour between
	#  all buttons.
	# Special case: if the selected option is "None" (index 0), the button
	#  behaviour is similar to untoggled button
	var str_out = ""
	str_out = KindSelBt.get_item_text(index).to_lower()
	# print(str_out.to_lower())
	
	# Ensure coherent button behaviour
	_on_Button_Toggled(index != 0, KindSelBt)
	
	# If a kind is specified (not None), all cells from the given kind are 
	#  are selected and highlighted
	if index != 0:
		cells_set = myMap.get_all_cells(str_out)
		for cell in cells_set:
			myMap.change_cell_color(cell, 'green')


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
				actions.MapTool_CircleAnim:
					CirclesAnimBt.pressed = false
				actions.MapTool_ResizeArena:
					ArenaSizeBt.pressed = false
				actions.MapTool_SpiralAnim:
					SpiralAnimBt.pressed = false

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
