extends Control

@onready var tree = get_tree().get_first_node_in_group("skill_tree")

func _process(_delta):
	queue_redraw()

func _draw():
	var t = Time.get_ticks_msec() * 0.002

	for pair in tree.connections:
		var a = pair[0]
		var b = pair[1]

		if not tree.buttons.has(a) or not tree.buttons.has(b):
			continue

		var from_pos = tree.buttons[a].position + Vector2(60, 20)
		var to_pos = tree.buttons[b].position + Vector2(60, 20)

		var pulse = (sin(t + a + b) + 1.0) * 0.5
		var width = lerp(1.0, 3.0, pulse)

		draw_line(
			from_pos,
			to_pos,
			Color(0.6, 0.6, 0.6, 0.5 + pulse * 0.5),
			width
		)
