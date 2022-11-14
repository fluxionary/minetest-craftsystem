local api = craftsystem.api

local count_elements = futil.table.count_elements
local resolve_item = futil.resolve_item

local function resolve_all(items)
	local resolved = {}

	for _, item in ipairs(items or {}) do
		local prefix = item:match("^([^:]+):")
		if prefix == "group" then
			table.insert(resolved, item)

		else
			local resolved_item = resolve_item(item)
			if not resolved_item then
				error(("%q doesn't exist"):format(item))
			end
			table.insert(resolved, resolved_item)
		end

	end

	return resolved
end

local function resolve_and_replace(item, no_replace_counts, replacements)
	item = ItemStack(item)
	local name = item:get_name()

	if name:sub(1, 6) ~= "group:" then
		local resolved = resolve_item(name)

		if not resolved then
			error(("craft ingredient %q doesn't exist"):format(name))
		end

		name = resolved
	end

	if (no_replace_counts[name] or 0) == 0 then
		table.insert_all(replacements, api.get_replacements(name))

	else
		no_replace_counts[name] = no_replace_counts[name] - 1
	end

	item:set_name(name)
	return item:to_string()
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

	local craft_recipe = {
		type = "shaped",
		output = output,
		recipe = recipe,
		replacements = replacements,
	}

	craftsystem.log("info", "registering craft %s", craft_recipe)

	minetest.register_craft(craft_recipe)
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

	local craft_recipe = {
		type = "shapeless",
		output = output,
		recipe = recipe,
		replacements = replacements,
	}

	craftsystem.log("info", "registering craft %s", craft_recipe)

	minetest.register_craft(craft_recipe)
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

-- before unified_inventory sets itself up
table.insert(minetest.registered_on_mods_loaded, 2, function()
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
