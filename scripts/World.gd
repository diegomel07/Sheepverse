extends Node2D

@export var noiseTexture : NoiseTexture2D
#@onready var loadingScreen = preload("res://Scenes/load_screen.tscn")

var noise : Noise
var tilemap : TileMap
var tileId = 0
var width = 1000
var height = 1000
var matrix

var tileTypes = {
	"ocean": {"position": Vector2i(2, 7), "tileId": 0},
	"sand": {"position": Vector2i(4, 5), "tileId": 0},
	"land": {"position": Vector2i(3, 5), "tileId": 0},
	"darkLand": {"position": Vector2i(0, 6), "tileId": 0},}
	
var tileObjects = {
	"rock": {"position": Vector2i(0, 0), "tileId": 0},
	"tree": {"position": Vector2i(0, 2), "tileId": 0},
	"grass": {"position": Vector2i(0, 4), "tileId": 0},}

func _ready():
	tilemap = $TileMap
	noise = noiseTexture.noise
	noise.seed = randi()
	createMatrix()
	createMap()
	generateTerrain()

func _process(_delta):
	print("jejej")
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
			var zone : String
			var value = noise.get_noise_2d(x, y)
			zone = getZone(value)
			matrix[x][y]={"tile":zone,"object":null,"done": false}
			if (value >= -0.4 and value <= 1) and randf() < 0.05:  
				if areaAvailable(x, y, value):
						#placeObject(x, y, zone, "tree")
						matrix[x][y] = {"tile":zone,"object": "tree", "done": false}
						continue
			elif (value > -0.1 and value <= 1) and randf() < 0.05:
				if areaAvailable(x, y, value):
					#placeObject(x, y, zone, "rock")
					matrix[x][y] = {"tile":zone,"object": "rock", "done": false}
					continue
			elif (value > -0.1 and value <= 1) and randf() < 0.05:
				if areaAvailable(x, y, value):
					#placeObject(x, y, zone, "rock")
					matrix[x][y] = {"tile":zone,"object": "grass", "done": false}
					continue
					
func getZone(value):
	var zone : String
	if value >= -1 and value < -0.4:
		zone = "ocean"
	elif value >= -0.4 and value < -0.1:
		zone = "sand"
	elif value >= -0.1 and value <= 1:
		var probLand = 1 + value
		if randf_range(-0.4, probLand) > 0.7:
			zone = "land"
		else:
			zone = "darkLand"
	return zone
		
func areaAvailable(startX, startY, value):
	for x in range(startX-2, startX + 2):
		for y in range(startY-2, startY + 2):
			if (x < 17 and x > 0) and (y < 16 and y > 0) :
				return false
			if x >= width or y >= height:
				return false 
			if  noise.get_noise_2d(x,y) < -0.1:
				return false  
			if matrix[x][y]!= null:
				if matrix[x][y]["object"]!= null:
					return false  
	return true

func placeObject(startX, startY, zone, objectType):
	for x in range(startX, startX + 2):
		for y in range(startY, startY + 2):
			matrix[x][y] = {"tile":zone,"object": objectType, "done": false}				
			
func generateTerrain():
	for x in range(width):
		for y in range(height):
			var cell = matrix [x][y]
			if cell["done"]== true:
				continue
			tilemap.set_cell(0,Vector2(x,y) ,tileTypes[cell["tile"]]["tileId"], tileTypes[cell["tile"]]["position"])
			#matrix [x][y]["done"] = true
			if cell["object"] != null:
				tilemap.set_cell(1,Vector2(x,y) ,tileObjects[cell["object"]]["tileId"], tileObjects[cell["object"]]["position"])
				#for i in range(2):
					#for j in range(2):
						#var vector = tileTypes[cell["tile"]]["position"]
						#tilemap.set_cell(0,Vector2(x+i,y+j) ,tileTypes[cell["tile"]]["tileId"], Vector2i(vector.x+i,vector.y+j ))
						#matrix [x+i][y+j]["done"] = true


func _on_inventory_closed():
	get_tree().paused = false


func _on_inventory_opened():
	get_tree().paused = true
