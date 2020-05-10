extends KinematicBody
class_name Character

## Signals definition ##
signal character_hurt
signal character_die

## Ressource import ##
var miniature = preload("res://icon.png")

## General Variables
var my_name = "No_0ne"

var start_health = 15 
var current_health

func change_material(material_key):
	$MeshInstance.set_surface_material(0, Global.materials[material_key])
