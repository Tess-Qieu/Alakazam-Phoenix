extends Control

func _on_BattleScreen_resized():
	print("hello")
	$PanelLeft.set_size(Vector2($PanelLeft.rect_size.x, get_viewport().size.y))
