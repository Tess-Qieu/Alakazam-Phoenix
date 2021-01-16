extends Control

var Team_Container = preload("res://Scenes/GUI/TeamContainer.tscn")
var SpellButton = preload("res://Scenes/GUI/SpellButton.tscn")

var node_battle : Node
var selected_button : Button


func _ready():
	node_battle = get_parent()



## BUTTON EVENT MANAGEMENT
func _on_SpellButton_toggled(button_pressed, spell_button ):
	# Spell Activation
	if button_pressed:
		# Deselection of previous spell
		if selected_button != null:
			selected_button.pressed = false
		# new button memorization
		selected_button = spell_button
		
		# battle management
		node_battle.state = 'cast_spell'
		node_battle.current_spell = spell_button.name
	else:
		# memorization reset
		selected_button = null
		
		# battle management
		node_battle.state = "normal"
		node_battle.current_spell = ""
	
	# reset of Map enlightment 
	node_battle.display_fov()

func _on_ButtonEndTurn_pressed():
	# Memoriazation reset before ending turn
	selected_button = null
	
	# New turn
	node_battle.ask_end_turn()


## USEFULL FUNCTIONS ##
func add_character_info(character:Character, team:Team):
	# Looking through each team container existing. If one has the same name
	#  as the character's team name, the character is added, then an early return
	#  is used.
	for elt in $PanelLeft/ScrollContainer/VBoxContainer.get_children():
		if elt.get_team_name() == team.name:
			elt.add_teammate(character)
			return
	
	# If we get here, the character hasn't been add to a team
	# A new team container is instanciated and the character is added
	var new_team = Team_Container.instance()
	# Addition of the new team to the view
	$PanelLeft/ScrollContainer/VBoxContainer.add_child(new_team)
	
	new_team.config_team(team)
	new_team.add_teammate(character)
	
# warning-ignore:unused_argument
func _process(delta):
	# disable or enable spell button
	if node_battle.memory_on_turn != null :
		# we have to wait until it receives informations from the server to be set
		if node_battle.selected_character \
							in node_battle.memory_on_turn['cast spell'].keys():
			# Activation/Deactivation of spell buttons
			toggle_spell_buttons(node_battle.memory_on_turn['cast spell']\
											[node_battle.selected_character])

func update_spell_list(character : Character):
	# When selecting a new character, the spell list must be cleaned and the
	#  new spells must be added
	
	# Old list cleaning
	for child in $PanelRight/SpellListContainer.get_children():
		$PanelRight/SpellListContainer.remove_child(child)
		child.queue_free()
	# if any button was selected, reset of memorization
	selected_button = null
	
	# Addition of new spells
	for spell_key in character.Spells.keys():
		# Creation of a new button
		var spell_bt = SpellButton.instance()
		# Addition of the button to the children
		$PanelRight/SpellListContainer.add_child(spell_bt)
		
		# Signal connections
		spell_bt.initialize(spell_key, character.Spells[spell_key].miniature)
		spell_bt.connect("toggled", self, "_on_SpellButton_toggled", [spell_bt])

func toggle_spell_buttons(disabled : bool):
	# Function allowing to able/disabl every spell button for a given character
	for node in $PanelRight/SpellListContainer.get_children():
		node.disabled = disabled
	
	# If all buttons must be disabled, then the previous selection is reset
	if disabled:
		selected_button = null
