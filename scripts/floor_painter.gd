extends Node

const TEXTURE_SIZE := 1024
const FLOOR_SIZE := Vector2(100.0, 100.0)
const FLOOR_CENTER := Vector3(0.0, 0.0, 0.0)
const PAINT_Y_OFFSET := 0.8

var _image: Image
var _texture: ImageTexture
var _mesh_instance: MeshInstance3D
var _dirty := false

func _ready() -> void:
	# create new empty image, whose pixels can be painted
	_image = Image.create_empty(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	_image.fill(Color.TRANSPARENT)
	
	# create texture from image
	_texture = ImageTexture.create_from_image(_image)

	# create plane mesh instance which will be placed above the game map
	var plane := PlaneMesh.new()
	plane.size = FLOOR_SIZE

	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = _texture
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS

	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.mesh = plane
	_mesh_instance.material_override = mat
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh_instance.position = Vector3(FLOOR_CENTER.x, FLOOR_CENTER.y + PAINT_Y_OFFSET, FLOOR_CENTER.z)

	add_child(_mesh_instance)

func _process(_delta: float) -> void:
	if _dirty:
		_texture.update(_image)
		_dirty = false

func paint(world_pos: Vector3, color: Color, brush_world_radius: float = 1.0) -> void:
	var tex_u := (world_pos.x - FLOOR_CENTER.x + FLOOR_SIZE.x * 0.5) / FLOOR_SIZE.x
	var tex_v := (world_pos.z - FLOOR_CENTER.z + FLOOR_SIZE.y * 0.5) / FLOOR_SIZE.y

	#UV coordinates must be between top left (0.0, 0.0) and bottom right (1.0, 1.0)
	if tex_u < 0.0 or tex_u > 1.0 or tex_v < 0.0 or tex_v > 1.0:
		return

	# get pixel coordinates from UV coordinates
	var pixel_x := int(tex_u * TEXTURE_SIZE)
	var pixel_y := int(tex_v * TEXTURE_SIZE)
	var pixel_radius := maxi(1, int(brush_world_radius / FLOOR_SIZE.x * TEXTURE_SIZE))

	#Paint all pixels within the pixel_radius
	for offset_y in range(-pixel_radius, pixel_radius + 1):
		for offset_x in range(-pixel_radius, pixel_radius + 1):
			if offset_x * offset_x + offset_y * offset_y <= pixel_radius * pixel_radius:
				_image.set_pixel(
					clampi(pixel_x + offset_x, 0, TEXTURE_SIZE - 1),
					clampi(pixel_y + offset_y, 0, TEXTURE_SIZE - 1),
					color
				)
	_dirty = true
