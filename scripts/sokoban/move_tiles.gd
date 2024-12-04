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
			var source_id = get_cell_source_id(cell)
			var atlas_coords = get_cell_atlas_coords(cell)
			animated_tiles[cell] = {
				"cell_data": cell_data,
				"source_id": source_id,
				"atlas_coords": atlas_coords,
				"animated": false
			}
			
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
				print('tile info', animated_tiles[cell])
				print('tile info', animated_tiles[cell]['cell_data'])
				# animate_tile(cell)
				animated_tiles[cell]["animated"] = true

func animate_tile(cell: Vector2i):
	print("Animating tile", cell)
	print('tile info', animated_tiles)
	var tile_info = animated_tiles[cell]['cell_data']
	var cell_id = tile_info["cell_id"]

	# 获取瓦片的纹理和信息
	var tile_texture = tile_set.tile_get_texture(cell_id)
	if not tile_texture:
		print("No texture found for cell", cell)
		return

	var tile_position = tile_map.map_to_world(cell) + tile_map.cell_size / 2 # 中心位置
	print('tile_position', tile_position)
	# 创建精灵节点
	var sprite = Sprite2D.new()
	sprite.texture = tile_texture
	sprite.position = tile_map.map_to_world(cell) # 使用相对位置

	tile_map.add_child(sprite)

	# 决定动画方向
	var player_cell = tile_map.world_to_map(player.global_position)
	var is_ahead = (cell.y - player_cell.y) <= 0

	var tween = Tween.new()
	sprite.add_child(tween)
	tween.active = true

	if is_ahead:
		# 玩家前方和周围的瓦片从上方飞入
		sprite.position.y -= spawn_distance
		tween.tween_property(sprite, "position:y", tile_map.map_to_world(cell).y, spawn_duration).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "rotation", 0, spawn_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	else:
		# 玩家后方的瓦片掉落
		tween.tween_property(sprite, "position:y", tile_map.map_to_world(cell).y + fall_distance, fall_duration) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "rotation", randf_range(-PI, PI), fall_duration) \
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

	# 动画结束后删除精灵并还原 TileMap 中的瓦片
	tween.tween_callback(func(): _on_tween_completed(sprite, cell))

func _on_tween_completed(sprite: Sprite2D, cell: Vector2i):
	# 删除动画精灵
	sprite.queue_free()

	# 重新设置 TileMap 中的瓦片
	tile_map.set_cellv(cell, animated_tiles[cell]["cell_id"])
