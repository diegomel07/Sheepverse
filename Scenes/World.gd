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
	var land = Vector2i(7,17)
	var water = Vector2i(5,23)
	var width = 1000
	var height = 1000
	for x in range(width):
		for y in range(height):
			var value = noise.get_noise_2d(x, y)
			if value <= 0:
				tilemap.set_cell(0, Vector2(x,y), tileId, water)
			else:
				tilemap.set_cell(0, Vector2(x,y), tileId, land)  

