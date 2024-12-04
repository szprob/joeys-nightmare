extends TileMapLayer

var animated_tiles = {}
@export var fall_duration: float = 0.5
@export var spawn_duration: float = 0.5
@export var fall_distance: float = 500.0
@export var spawn_distance: float = 500.0
@export var animation_radius: int = 2

@onready var player = get_tree().get_first_node_in_group("player")
@onready var tile_map = get_parent()
# @onready var tile_set = tile_map.tile_set

func _ready():
	# 保存所有瓦片的初始状态，并隐藏它们
	for cell in get_used_cells():
		var cell_data = get_cell_tile_data(cell)
		if cell_data:
			animated_tiles[cell] = {
				"cell_data": cell_data,
				"animated": false
			}
			print('cell', cell_data)
			set_cell(cell, -1) # 隐藏所有瓦片

func _physics_process(_delta):
	if not player:
		return

	# 获取玩家的瓦片坐标
	var player_pos = to_local(player.global_position)
	var player_cell = local_to_map(player_pos)
	# print('player_cell', player_cell)
	# print('animated_tiles', animated_tiles.keys())
	# 遍历所有已存储的瓦片
	for cell in animated_tiles.keys():
		# 检查瓦片是否在玩家周围的范围内
		if (abs(cell.x - player_cell.x) <= animation_radius and
			cell.y - player_cell.y >= -animation_radius and
			cell.y - player_cell.y <= animation_radius * 2):
			
			# 如果瓦片在范围内且未被动画
			if not animated_tiles[cell]["animated"]:
				print('try animate tile', cell)
				# animate_tile(cell)
				animated_tiles[cell]["animated"] = true

func animate_tile(cell: Vector2i):
	print('animate_tile', cell)
	var tile_info = animated_tiles[cell]
	var cell_data = tile_info["cell_data"]
	var tile_pos = map_to_local(cell)
	# print('tile_pos', tile_pos)

	# 创建精灵节点
	var sprite = Sprite2D.new()

	# 获取瓦片的纹理和区域
	var source_id = cell_data.get_custom_data("source_id")
	var tileset_source = tile_set.get_source(source_id)

	if tileset_source is TileSetAtlasSource:
		var coords = cell_data.get_custom_data("atlas_coords")
		var alternative_tile = cell_data.get_custom_data("alternative_tile")
		
		# 获取瓦片的具体信息
		var tile_data = tileset_source.get_tile_data(coords, alternative_tile)
		var texture_region = tileset_source.get_tile_texture_region(coords, alternative_tile)
		
		sprite.texture = tileset_source.get_texture()
		sprite.region_enabled = true
		sprite.region_rect = texture_region
	else:
		return

	sprite.global_position = tile_pos

	add_child(sprite)

	var tween = create_tween()

	# 修改判断逻辑：根据与玩家的相对位置来决定动画效果
	var player_cell_y = local_to_map(player.global_position).y
	var is_ahead = (cell.y - player_cell_y) <= 0

	if is_ahead:
		# 玩家前方和周围的瓦片从上方降落
		print('ahead')
		sprite.global_position.y -= spawn_distance
		tween.tween_property(sprite, "global_position:y", tile_pos.y, spawn_duration) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.parallel().tween_property(sprite, "rotation", 0, spawn_duration) \
			.from(randf_range(-0.2, 0.2))
	else:
		# 玩家后方的瓦片掉落
		sprite.global_position.y = tile_pos.y
		tween.tween_property(sprite, "global_position:y", tile_pos.y + fall_distance, fall_duration) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(sprite, "rotation", randf_range(-PI, PI), fall_duration)

	# 动画结束后删除精灵
	tween.tween_callback(Callable(sprite, "queue_free"))
