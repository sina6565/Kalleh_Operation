extends Node3D

# Simple billboard mesh controller - placeholder for ad spaces
@export var width: float = 3.0
@export var height: float = 1.5
@export var animated: bool = false

onready var mesh_inst: MeshInstance3D = $PanelMesh

func _ready() -> void:
	# Create a QuadMesh if none provided
	if mesh_inst.mesh == null:
		var qm = QuadMesh.new()
		qm.size = Vector2(width, height)
		mesh_inst.mesh = qm
	# Create a placeholder material
	if mesh_inst.material_override == null:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1,1,1)
		mesh_inst.material_override = mat

	if animated:
		set_process(true)
	else:
		set_process(false)

func _process(delta: float) -> void:
	# subtle animated tint to indicate a 2D animated panel
	var m = mesh_inst.material_override as StandardMaterial3D
	if m:
		m.albedo_color = Color(0.9 + 0.1 * sin(OS.get_ticks_msec() / 250.0), 0.9, 0.9)

func set_texture(tex: Texture2D) -> void:
	var m = mesh_inst.material_override as StandardMaterial3D
	if m:
		m.albedo_texture = tex
