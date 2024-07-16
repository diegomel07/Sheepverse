extends Node2D

@export var noiseTexture : NoiseTexture2D
var noise : Noise
var tilemap : TileMap
var tileId = 0

func _ready():
	tilemap = $TileMap
	noise = noiseTexture.noise
	noise.seed = randi()
	createWorld()

func _process(delta):
	pass

func createWorld():
	var deepOcean = Vector2i(28,3)
	var ocean = Vector2i(21,3)
	var sand = Vector2i(15,3)
	var land = Vector2i(11,3)
	var deepland = Vector2i(3,3)
	var iron = Vector2i(34,3)  # Define el tileset de mineral
	var width = 1000
	var height = 1000
	for x in range(width):
		for y in range(height):
			var value = noise.get_noise_2d(x, y)
			if value >= -1 and value < -0.1:
				tilemap.set_cell(0, Vector2(x,y), tileId, deepOcean)
			if value >= - 0.1 and value < 0:
				tilemap.set_cell(0, Vector2(x,y), tileId, ocean)
			if value >=  0 and value < 0.1:
				tilemap.set_cell(0, Vector2(x,y), tileId, sand)
			if value >=  0.1 and value < 0.3:
				tilemap.set_cell(0, Vector2(x,y), tileId, land)
				if randi()%100 == 0:
					tilemap.set_cell(0, Vector2(x,y), tileId, iron)
			if value >=  0.3 and value <= 1:
				tilemap.set_cell(0, Vector2(x,y), tileId, deepland)
				if randi()%100 == 0:
					tilemap.set_cell(0, Vector2(x,y), tileId, iron)
				
