extends Control

var Team_Container = preload("res://Scenes/GUI/TeamContainer.tscn")
var SpellButton = preload("res://Scenes/GUI/SpellButton.tscn")

var node_battle : Node



func _ready():
	node_battle = get_parent()




## BUTTON EVENTS ##
func _on_ButtonSpell_pressed(spell_button):
	node_battle.state = 'cast_spell'
	node_battle.current_spell = spell_button.name
	node_battle.display_fov()
	node_battle.clear_arena()

func _on_ButtonEndTurn_pressed():
	node_battle.clear_arena()
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

func update_spell_list(character : Character):
	for child in $PanelRight/SpellListContainer.get_children():
		child.queue_free()
		
	for spell_key in character.Spells.keys():
		var spell_bt = SpellButton.instance()
		$PanelRight/SpellListContainer.add_child(spell_bt)
		spell_bt.initialize(spell_key, character.Spells[spell_key].miniature)
		spell_bt.connect("pressed", self, "_on_ButtonSpell_pressed", [spell_bt])

