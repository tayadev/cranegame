extends StaticBody3D

func on_interact():
	print("Button pressed!")
	# run on_button_pressed() on parent
	get_parent().on_button_pressed()
