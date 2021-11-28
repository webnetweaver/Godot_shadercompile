extends Node

export(int) var verticalDisplacement = 0
export(int) var existFrames = 5
var instances: Array
var instance
var meshInst: MeshInstance
var meshInstSurfaceCount: int
var mesh: Mesh
var meshSurfaceCount: int
var processCount = 0
var meshParticles: Particles

func _ready():
	get_tree().current_scene.get_node("World").connect("ready", self, "compileShaders")
	set_process(false)
	
func _process(delta):
	processCount += 1
	if processCount > existFrames:
		var quadMeshes = get_tree().get_nodes_in_group("compiledShaders")
		for quadMeshInst in quadMeshes:
			quadMeshInst.visible = false
		set_process(false)
		get_tree().current_scene.onMaterialsCached()
	

func compileShaders():
	instances = get_tree().get_nodes_in_group("materials")
	if instances.size() > 0:
		for instance in instances:
			if instance is MeshInstance:
				meshInst = instance as MeshInstance
				setupShaderCompile(meshInst.material_override)
				meshInstSurfaceCount = meshInst.get_surface_material_count()
				if meshInstSurfaceCount > 0:
					for index in range(0, meshInstSurfaceCount):
						setupShaderCompile(meshInst.get_surface_material(index))
				mesh = meshInst.mesh
				
				meshSurfaceCount = mesh.get_surface_count()
				if meshSurfaceCount > 0:
					for index in range(0, meshSurfaceCount):
						setupShaderCompile(mesh.surface_get_material(index))
			elif instance is Particles:
				meshParticles = instance as Particles
				setupShaderCompile(meshParticles.process_material)
				var num_passes = meshParticles.draw_passes
				setupShaderCompile(meshParticles.draw_pass_1.material)
				if num_passes > 1:
					setupShaderCompile(meshParticles.draw_pass_2.material)
					if num_passes > 2:
						setupShaderCompile(meshParticles.draw_pass_3.material)
						if num_passes > 3:
							setupShaderCompile(meshParticles.draw_pass_4.material)
	if existFrames <= 0:
		var quadMeshes = get_tree().get_nodes_in_group("compiledShaders")
		for quadMeshInst in quadMeshes:
			quadMeshInst.visible = false
		get_tree().current_scene.onMaterialsCached()
	else:
		set_process(true)

func setupShaderCompile(material: Material):
	if material:
		while material:
			compileShader(material)
			material = material.get_next_pass()
		
func compileShader(material):
	var quadMesh: QuadMesh
	quadMesh = QuadMesh.new()
	quadMesh.material = material
	var mi: MeshInstance
	mi = MeshInstance.new()
	mi.mesh = quadMesh
	mi.cast_shadow = false
	mi.global_transform.origin.y = -1*verticalDisplacement
	mi.add_to_group("compiledShaders")
	get_parent().add_child(mi)


