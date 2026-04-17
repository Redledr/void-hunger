extends Control

@onready var tree = get_tree().get_first_node_in_group("skill_tree")


@onready var viewport = $Viewport
var dragging := false
var last_mouse_pos := Vector2.ZERO
var view_start := Vector2.ZERO

var zoom := 1.0
const ZOOM_MIN := 0.5
const ZOOM_MAX := 2.0

var node_container
var line_container
var branch_colors = {
	"gravity": Color(1, 0.4, 0.4),
	"mass": Color(1, 1, 0.4),
	"chaos": Color(0.4, 0.6, 1),
}
const NODE_SIZE = Vector2(120, 40)

var layout = {
	1: Vector2(400, 600),

	2: Vector2(250, 520),
	3: Vector2(400, 520),
	4: Vector2(550, 520),

	5: Vector2(400, 450),
	6: Vector2(400, 380),
	7: Vector2(400, 310),

	8: Vector2(200, 250),
	9: Vector2(400, 250),
	10: Vector2(600, 250),

	11: Vector2(200, 180),
	12: Vector2(400, 180),
	13: Vector2(600, 180),

	14: Vector2(400, 110),

	15: Vector2(200, 50),
	16: Vector2(400, 50),
	17: Vector2(600, 50),

	18: Vector2(200, -20),
	19: Vector2(400, -20),
	20: Vector2(600, -20),
}

var connections = [
	[1,2],[1,3],[1,4],[1,5],
	[5,6],[6,7],

	[2,8],[8,11],
	[3,9],[9,12],
	[4,10],[10,13],

	[11,14],[12,14],[13,14],

	[11,15],[15,18],
	[12,16],[16,19],
	[13,17],[17,20],
]

var buttons = {}

func _process(_delta):
	queue_redraw()
		
func _ready():
	node_container = $Viewport/Nodes
	line_container = $Viewport/Lines

	_create_nodes()
	queue_redraw()
	
func _create_nodes():
	for id in layout.keys():
		var btn = Button.new()
		btn.name = "Button_%d" % id
		btn.text = str(id)
		btn.size = NODE_SIZE
		btn.position = layout[id] - NODE_SIZE / 2

		btn.pressed.connect(_on_node_pressed.bind(id))

		node_container.add_child(btn)
		buttons[id] = btn
		
func _on_node_pressed(id):
	print("Clicked upgrade:", id)
	
func set_node_state(id, state):
	var btn = buttons[id]

	match state:
		"locked":
			btn.modulate = Color(0.3, 0.3, 0.3)
			btn.disabled = true

		"available":
			btn.modulate = Color(1, 1, 1)
			btn.disabled = false

		"unlocked":
			btn.modulate = Color(0.2, 1, 0.4)
			btn.disabled = false
var unlocked = {}

func can_unlock(id):
	#var data = upgrades[id]
	#for req in data.prereq:
		#if not unlocked.has(req):
			#return false
	return true

func refresh_tree():
	for id in buttons.keys():
		if unlocked.has(id):
			set_node_state(id, "unlocked")
		elif can_unlock(id):
			set_node_state(id, "available")
		else:
			set_node_state(id, "locked")

func _unhandled_input(event):
	# Start drag
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_pos = event.position
			view_start = viewport.position

	# Dragging motion
	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		viewport.position += delta
		last_mouse_pos = event.position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom(1.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom(0.9)

func _set_zoom(factor):
	var old_zoom = zoom
	zoom = clamp(zoom * factor, ZOOM_MIN, ZOOM_MAX)

	var mouse = get_global_mouse_position()

	var before = (mouse - viewport.position) / old_zoom
	var after = (mouse - viewport.position) / zoom

	viewport.position += (after - before)
	viewport.scale = Vector2.ONE * zoom
