extends Node

signal leaderboard_updated

var centrifuge = "https://skaterboy42069.q1studios.at/"
var fetch_endpoint = "get_scores"
var post_endpoint = "add_score"
var fetch_request: HTTPRequest
var post_request: HTTPRequest

var local_path = "user://scoreboard.json"
var scoreboard = {
	"scores": []
}

func _ready() -> void:
	fetch_request = HTTPRequest.new()
	add_child(fetch_request)
	fetch_request.request_completed.connect(_on_fetch_completed)
	
	post_request = HTTPRequest.new()
	add_child(post_request)
	post_request.request_completed.connect(_on_post_completed)
	
	fetch_online_scoreboard()
	
func add_score(username: String, score: int):
	load_local_scoreboard()
	scoreboard["scores"].append({
		"name": username,
		"score": score
	})
	save_local_scoreboard()
	post_score_online(username, score) 
	leaderboard_updated.emit()
	
func load_local_scoreboard():
	if !FileAccess.file_exists(local_path):
		return
	
	var file = FileAccess.open(local_path, FileAccess.READ)
	var json = JSON.new()
	
	if json.parse(file.get_as_text()) == OK:
		scoreboard = json.data
	
	leaderboard_updated.emit()

func save_local_scoreboard():
	var file = FileAccess.open(local_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(scoreboard))


func fetch_online_scoreboard():
	var url = centrifuge + fetch_endpoint
	var error = fetch_request.request(url)
	
	if error != OK:
		push_warning("Failed to fetch online leaderboard. Falling back to local.")
		load_local_scoreboard()

func _on_fetch_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			scoreboard = json.data
			save_local_scoreboard()
			leaderboard_updated.emit()
			return
			
	push_warning("Failed to fetch online leaderboard. Falling back to local.")
	load_local_scoreboard()

func post_score_online(username: String, score: int):
	var url = centrifuge + post_endpoint
	var headers = ["Content-Type: application/json"]
	
	var data_to_send = {
		"name": username,
		"score": score
	}
	var json_string = JSON.stringify(data_to_send)
	post_request
	var error = post_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	if error != OK:
		push_warning("Online save failed. Score only saved locally, will be overwritten on next online - sync.")

func _on_post_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("Score successfully saved online!")
		fetch_online_scoreboard()
	else:
		push_warning("Online save failed. Score only saved locally, will be overwritten on next online - sync.")
