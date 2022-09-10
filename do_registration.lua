local api = craftsystem.api

local count_elements = futil.count_elements
local resolve_item = futil.resolve_item

local function resolve_all(items)
	local resolved = {}

	for _, item in ipairs(items or {}) do
		table.insert(resolved, resolve_item(item))
	end

	return resolved
end

local function resolve_and_replace(item, no_replace_counts, replacements)
	if item:sub(1, 6) ~= "group:" then
		local resolved = resolve_item(item)

		if not resolved then
			error(("craft ingredient %q doesn't exist"):format(item))
		end

		item = resolved
	end

	if (no_replace_counts[item] or 0) == 0 then
		table.insert_all(replacements, api.get_replacements(item))

	else
		no_replace_counts[item] = no_replace_counts[item] - 1
	end

	return item
end

local function analyze_and_register_shaped(craft)
	local output = resolve_item(craft.output)
	if not output then
		error(("craft output %q doesn't exist"):format(craft.output))
	end

	local recipe = table.copy(craft.recipe)
	local no_replace_counts = count_elements(resolve_all(craft.no_replace))
	local replacements = {}

	for _, row in ipairs(recipe) do
		for j, item in pairs(row) do
			row[j] = resolve_and_replace(item, no_replace_counts, replacements)
		end
	end

	minetest.register_craft({
		type = "shaped",
		output = output,
		recipe = recipe,
		replacements = replacements,
	})
end

local function analyze_and_register_shapeless(craft)
	local output = resolve_item(craft.output)
	if not output then
		error(("craft output %q doesn't exist"):format(craft.output))
	end

	local recipe = table.copy(craft.recipe)
	local no_replace_counts = count_elements(resolve_all(craft.no_replace))
	local replacements = {}

	for i, item in pairs(recipe) do
		recipe[i] = resolve_and_replace(item, no_replace_counts, replacements)
	end

	minetest.register_craft({
		type = "shapeless",
		output = output,
		recipe = recipe,
		replacements = replacements,
	})
end

local function analyze_and_register_cooking(craft)
	local output = resolve_item(craft.output)
	if not output then
		error(("craft output %q doesn't exist"):format(craft.output))
	end

	local item = craft.recipe
	local no_replace_counts = count_elements(resolve_all(craft.no_replace))
	local replacements = {}

	item = resolve_and_replace(item, no_replace_counts, replacements)

	minetest.register_craft({
		type = "cooking",
		output = output,
		recipe = item,
		replacements = replacements,
		cooktime = craft.cooktime,
	})
end

local function analyze_and_register_fuel(craft)
	local item = craft.recipe
	local no_replace_counts = count_elements(resolve_all(craft.no_replace))
	local replacements = {}

	item = resolve_and_replace(item, no_replace_counts, replacements)

	minetest.register_craft({
		type = "fuel",
		recipe = item,
		replacements = replacements,
		burntime = craft.burntime,
	})
end

minetest.register_on_mods_loaded(function()
	-- we assume all items and groups are final at this point

	for _, craft in ipairs(api.registered_crafts) do
		if craft.type == "shaped" then
			analyze_and_register_shaped(craft)

		elseif craft.type == "shapeless" then
			analyze_and_register_shapeless(craft)

		elseif craft.type == "cooking" then
			analyze_and_register_cooking(craft)

		elseif craft.type == "fuel" then
			analyze_and_register_fuel(craft)
		end
	end
end)
