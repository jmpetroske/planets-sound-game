extends OSCsender

func _ready():
	pass

func _process(delta):
	send_osc_update(get_parent().global_position, get_parent().position, get_parent().velocity)

func send_osc_update(global_p, relative_p, v):
	msg_address("/planet/update")
	msg_add_int(get_parent().uid)
	# flip the x coordinate so it makes sense in supercollider
	msg_add_real(global_p.x)
	msg_add_real(-global_p.y)
	msg_add_real(relative_p.x)
	msg_add_real(-relative_p.y)
	msg_add_real(v.x)
	msg_add_real(-v.y)
	msg_send()