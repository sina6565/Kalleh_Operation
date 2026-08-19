extends Node

# MobileOptimizer: runtime optimizations applied on Android devices.
# - Reduces GPU particle counts and scales particle speed/lifetime
# - Lowers directional light energy for mobile
# - Intended to be attached under the Level root so it runs when the level loads

@export var max_particles: int = 300
@export var particle_speed_scale: float = 0.8
@export var particle_lifetime_scale: float = 0.85
@export var max_light_energy: float = 1.0

func _ready() -> void:
	if OS.get_name() != "Android":
		return
	# Apply optimizations after a short delay to ensure scene nodes exist
	yield(get_tree().create_timer(0.05), "timeout")
	var root = get_tree().get_current_scene()
	if not root:
		root = get_tree().get_root()
	_apply_recursive(root)
	print("MobileOptimizer: optimizations applied for Android")

func _apply_recursive(node: Node) -> void:
	for child in node.get_children():
		# Particles
		if child is GPUParticles3D:
			_optimize_particles(child)
		# Directional lights
		if child is DirectionalLight3D:
			_optimize_light(child)
		# Recurse
		_apply_recursive(child)

func _optimize_particles(p: GPUParticles3D) -> void:
	# Clamp amount
	if p.amount > max_particles:
		p.amount = max_particles
	# Tweak process material if present
	var mat = p.process_material
	if mat and mat is ParticlesMaterial:
		mat.speed_scale *= particle_speed_scale
		mat.lifetime = max(0.05, mat.lifetime * particle_lifetime_scale)
		# Reduce emission and spread for mobile
		mat.emission_box_extents *= Vector3(0.9, 0.9, 0.9)

func _optimize_light(l: DirectionalLight3D) -> void:
	if l.light_energy > max_light_energy:
		l.light_energy = max_light_energy
	# Optionally reduce shadow bias/influence; be conservative
	# if "shadow_enabled" in l:
	#	l.shadow_enabled = false
