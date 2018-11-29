extends OSCsender

func _ready():
	pass

func _process(delta):
	send_osc_update(get_parent().global_position, get_parent().get_relative_position(), get_parent().velocity)

func send_osc_update(global_p, relative_p, v):
	msg_address("/planet/update")
	msg_add_int(get_parent().uid)
	msg_add_v2(global_p)
	msg_add_v2(relative_p)
	msg_add_v2(v)
	msg_send()