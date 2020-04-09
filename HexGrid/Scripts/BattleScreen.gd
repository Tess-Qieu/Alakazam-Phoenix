extends Control

func _on_BattleScreen_resized():
	# Resize the BattleScreen when the size of the window change
	$HBoxContainer.set_size(get_viewport().size)
