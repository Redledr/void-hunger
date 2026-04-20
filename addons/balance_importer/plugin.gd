# addons/balance_importer/plugin.gd
@tool
extends EditorPlugin

const OBJECT_URL := "https://docs.google.com/spreadsheets/d/e/2PACX-1vT4Ij8zsG0kcS2doeQUEmHi7CFS1wfKnVY9fZK6oVq-0JksjQVupBwpt6V4ZawdOyKQwfFYvCBlz1iS/pub?gid=0&single=true&output=csv"
const SKILL_URL  := "https://docs.google.com/spreadsheets/d/e/2PACX-1vT4Ij8zsG0kcS2doeQUEmHi7CFS1wfKnVY9fZK6oVq-0JksjQVupBwpt6V4ZawdOyKQwfFYvCBlz1iS/pub?gid=946542281&single=true&output=csv"

func _enter_tree() -> void:
	add_tool_menu_item("Re-import balance sheet", _run_importer)
	call_deferred("_run_importer")

func _exit_tree() -> void:
	remove_tool_menu_item("Re-import balance sheet")

func _build() -> bool:
	_run_importer()
	return true

func _run_importer() -> void:
	var dir := DirAccess.open("res://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")

	_download("object_data.csv", OBJECT_URL)
	_download("skill_data.csv", SKILL_URL)

func _download(filename: String, url: String) -> void:
	var http := HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):

		# Handle redirects manually
		if response_code in [301, 302, 307, 308]:
			var location := ""
			
			for h in headers:
				if h.to_lower().begins_with("location:"):
					location = h.substr(9).strip_edges()
					break
			
			if location != "":
				print("BalanceImporter: redirecting to " + location)
				http.queue_free()
				_download(filename, location)
				return
			else:
				push_error("BalanceImporter: redirect with no location for %s" % filename)
				http.queue_free()
				return

		if result != HTTPRequest.RESULT_SUCCESS:
			push_error("BalanceImporter: request failed for %s" % filename)
			http.queue_free()
			return

		if response_code != 200:
			push_error("BalanceImporter: bad response %d for %s" % [response_code, filename])
			http.queue_free()
			return

		var text: String = body.get_string_from_utf8()

		if text.begins_with("<!DOCTYPE html") or text.begins_with("<html"):
			push_error("BalanceImporter: received HTML instead of CSV for %s" % filename)
			http.queue_free()
			return

		var file := FileAccess.open("res://data/" + filename, FileAccess.WRITE)
		file.store_string(text)
		file.close()

		print("BalanceImporter: wrote " + filename)

		http.queue_free()
		EditorInterface.get_resource_filesystem().scan()
	)

	var err := http.request(url)
	if err != OK:
		push_error("BalanceImporter: could not start request for %s" % filename)
		http.queue_free()
