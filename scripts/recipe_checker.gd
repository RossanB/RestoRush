extends RefCounted
class_name RecipeChecker

# Check if stored items match any recipe step at a station and return the result
static func check_recipe(stored_items: Array[int], station_type: String) -> Dictionary:
	# Returns: {"success": bool, "result": int, "error": String}
	
	if stored_items.is_empty():
		return {"success": false, "result": -1, "error": "No items to process!"}
	
	# Check each recipe for steps that happen at this station
	for recipe_result in Recipes.RECIPES.keys():
		var recipe = Recipes.RECIPES[recipe_result]
		
		# Check all steps in this recipe
		for step in recipe["steps"]:
			if not step.has("station") or step["station"] != station_type:
				continue
			
			# Get items needed for this step
			var needed_items: Array[int] = []
			
			if step["action"] == "chop":
				# Single item to chop
				needed_items.append(step["item"])
			elif step["action"] == "mix":
				# Multiple items to mix
				if step.has("items"):
					var items_array: Array = step["items"] as Array
					for item in items_array:
						needed_items.append(item as int)
			elif step["action"] == "assemble":
				# Multiple items to assemble
				if step.has("items"):
					var items_array: Array = step["items"] as Array
					for item in items_array:
						needed_items.append(item as int)
			elif step["action"] == "cook":
				# Single item to cook
				needed_items.append(step["item"])
			
			# Check if stored items match needed items
			if items_match(stored_items, needed_items):
				var result = step.get("result", -1)
				if result != -1:
					print("Recipe matched! Action: ", step["action"], " Result: ", result)
					return {"success": true, "result": result, "error": ""}
	
	# No recipe found - check if items match a recipe at a different station
	var possible_stations = []
	for recipe_result in Recipes.RECIPES.keys():
		var recipe = Recipes.RECIPES[recipe_result]
		for step in recipe["steps"]:
			if step.has("station") and step.has("action") and step["action"] == "assemble":
				if step.has("items"):
					var items_array: Array = step["items"] as Array
					var needed_items: Array[int] = []
					for item in items_array:
						needed_items.append(item as int)
					if items_match(stored_items, needed_items):
						if step["station"] not in possible_stations:
							possible_stations.append(step["station"])
	
	if possible_stations.size() > 0:
		return {"success": false, "result": -1, "error": "Recipe exists but wrong station! Try: " + possible_stations[0]}
	
	return {"success": false, "result": -1, "error": "Recipe does not exist!"}

# Check if stored items match needed items (order doesn't matter, counts matter)
static func items_match(stored: Array[int], needed: Array[int]) -> bool:
	if stored.size() != needed.size():
		return false
	
	# Count occurrences
	var stored_count = {}
	for item in stored:
		stored_count[item] = stored_count.get(item, 0) + 1
	
	var needed_count = {}
	for item in needed:
		needed_count[item] = needed_count.get(item, 0) + 1
	
	# Compare counts
	for item in needed_count.keys():
		if stored_count.get(item, 0) != needed_count[item]:
			return false
	
	return true
