extends Node

# MobileOptimizer: runtime optimizations applied on Android devices.
@export var max_particles: int = 300
@export var particle_speed_scale: float = 0.8
@export var particle_lifetime_scale: float = 0.85
@export var max_light_energy: float = 1.0

func _ready() -> void:
	if OS.get_name() != "Android":
		return
	# Apply optimizations after a short delay to ensure scene nodes exist
	await get_tree().create_timer(0.05).timeout
	var root = get_tree().get_current_scene()
	if not root:
		root = get_tree().get_root()
	_apply_recursive(root)
	print("MobileOptimizer: optimizations applied for Android")

func _apply_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is GPUParticles3D:
			_optimize_particles(child)
		if child is DirectionalLight3D:
			_optimize_light(child)
		_apply_recursive(child)

func _optimize_particles(p: GPUParticles3D) -> void:
	if p.amount > max_particles:
		p.amount = max_particles
	var mat = p.process_material
	if mat and mat is ParticlesMaterial:
		mat.speed_scale *= particle_speed_scale
		mat.lifetime = max(0.05, mat.lifetime * particle_lifetime_scale)
		mat.emission_box_extents *= Vector3(0.9, 0.9, 0.9)

func _optimize_light(l: DirectionalLight3D) -> void:
	if l.light_energy > max_light_energy:
		l.light_energy = max_light_energy
