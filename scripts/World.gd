extends Node2D

@export var noiseTexture : NoiseTexture2D
var noise : Noise
var tilemap : TileMap
var tileId = 0
var width = 1000
var height = 1000
var matrix

var tileTypes = {
	"deepOcean": {"position": Vector2i(28, 3), "tileId": 0},
	"ocean": {"position": Vector2i(21, 3), "tileId": 0},
	"sand": {"position": Vector2i(15, 3), "tileId": 0},
	"land": {"position": Vector2i(11, 3), "tileId": 0},
	"deepland": {"position": Vector2i(3, 3), "tileId": 0},
	"rock": {"position": Vector2i(0, 0), "tileId": 1},
	"tree": {"position": Vector2i(0, 4), "tileId": 1},}

func _ready():
	tilemap = $TileMap
	noise = noiseTexture.noise
	noise.seed = randi()
	createMatrix()
	createMap()
	generateTerrain()

func _process(_delta):
	pass

func createMatrix():
	matrix = []
	for x in range(width):
		var row = []
		for y in range(height):
			row.append(null)
		matrix.append(row)

func createMap():
	for x in range(width):
		for y in range(height):
			if matrix[x][y]!= null:
				continue
			var value = noise.get_noise_2d(x, y)
			if (value >= -0.1 and value <= 1) and randf() < 0.001:  
				if areaAvailable(x, y, value):
						placeObject(x, y, "tree")
						continue
			elif (value > -0.3 and value <= 1) and randf() < 0.001:
				if areaAvailable(x, y, value):
					placeObject(x, y, "rock")
					continue
			if value >= -1 and value < -0.5:
				matrix[x][y] = {"tile":"deepOcean","done": false}
			elif value >= -0.5 and value <= -0.3:
				matrix[x][y] = {"tile":"ocean","done": false}
			elif value > -0.3 and value < -0.1:
				matrix[x][y] = {"tile":"sand","done": false}
			elif value >= -0.1 and value < 0.3:
				matrix[x][y] = {"tile":"land","done": false}
			elif value >= 0.3 and value <= 1:
				matrix[x][y] = {"tile":"deepland","done": false}
				
func areaAvailable(startX, startY, value):
	for x in range(startX, startX + 4):
		for y in range(startY, startY + 4):
			if x >= width or y >= height:
				return false 
			if  noise.get_noise_2d(x,y) < -0.3:
				return false  
			if matrix[x][y]!= null:
				return false  
	return true

func placeObject(startX, startY, objectType):
	for x in range(startX, startX + 4):
		for y in range(startY, startY + 4):
			matrix[x][y] = {"tile": objectType, "done": false}				
			
func generateTerrain():
	for x in range(width):
		for y in range(height):
			if matrix [x][y]["done"]== true:
				continue
			var value = matrix [x][y]["tile"]
			if value == "tree" or value == "rock":
				for i in range(4):
					for j in range(4):
						var vector = tileTypes[value]["position"]
						tilemap.set_cell(1,Vector2(x+i,y+j) ,tileTypes[value]["tileId"], Vector2i(vector.x+i,vector.y+j ) )
						matrix [x+i][y+j]["done"] = true
				continue
			tilemap.set_cell(0,Vector2(x,y) ,tileTypes[value]["tileId"], tileTypes[value]["position"])
			matrix [x][y]["done"] = true
