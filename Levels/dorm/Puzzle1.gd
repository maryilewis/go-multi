extends Node3D



func _on_area_3d_body_entered(body):
	print("body entered")
	pass # Replace with function body.


func _on_area_3d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("body shape entered")
	pass # Replace with function body.
