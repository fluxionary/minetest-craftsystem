local api = craftsystem.api
local resolve_item = craftsystem.util.resolve_item

local function analyze_and_register_shaped_craft(shaped_craft)
	local output = resolve_item(shaped_craft.output)
	if not output then
		error(("craft output %q doesn't exist"):format(shaped_craft.output))
	end

	local recipe = table.copy(shaped_craft.recipe)
	local replacements = {}

	for i, row in ipairs(recipe) do
		for j, item in pairs(row) do
			if item:sub(1, 6) == "group:" then
				table.insert_all(replacements, api.get_group_replacements(item:sub(7)))

			else
				local resolved = resolve_item(item)

				if not resolved then
					error(("craft ingredient %q doesn't exist"):format(item))
				end

				row[j] = resolved

				table.insert_all(replacements, api.get_item_replacements(resolved))
			end
		end
	end

	minetest.register_craft({
		type = "shaped",
		output = output,
		recipe = recipe,
		replacements = replacements,
	})
end

local function analyze_and_register_shapeless_craft(shapeless_craft)
	local output = resolve_item(shapeless_craft.output)
	if not output then
		error(("craft output %q doesn't exist"):format(shapeless_craft.output))
	end

	local recipe = table.copy(shapeless_craft.recipe)
	local replacements = {}

	for i, item in pairs(recipe) do
		if item:sub(1, 6) == "group:" then
			table.insert_all(replacements, api.get_group_replacements(item:sub(7)))

		else
			local resolved = resolve_item(item)

			if not resolved then
				error(("craft ingredient %q doesn't exist"):format(item))
			end

			recipe[i] = resolved

			table.insert_all(replacements, api.get_item_replacements(resolved))
		end
	end

	minetest.register_craft({
		type = "shapeless",
		output = output,
		recipe = recipe,
		replacements = replacements,
	})
end

local function analyze_and_register_cooking_craft(cooking_craft)
	local output = resolve_item(cooking_craft.output)
	if not output then
		error(("craft output %q doesn't exist"):format(cooking_craft.output))
	end

	local recipe = cooking_craft.recipe
	local replacements = {}

	if recipe:sub(1, 6) == "group:" then
		table.insert_all(replacements, api.get_group_replacements(recipe:sub(7)))

	else
		local resolved = resolve_item(recipe)

		if not resolved then
			error(("craft ingredient %q doesn't exist"):format(recipe))
		end

		recipe = resolved

		table.insert_all(replacements, api.get_item_replacements(resolved))
	end

	minetest.register_craft({
		type = "cooking",
		output = output,
		recipe = recipe,
		replacements = replacements,
		cooktime = cooking_craft.cooktime,
	})
end

local function analyze_and_register_fuel_craft(fuel_craft)
	local recipe = fuel_craft.recipe
	local replacements = {}

	if recipe:sub(1, 6) == "group:" then
		table.insert_all(replacements, api.get_group_replacements(recipe:sub(7)))

	else
		local resolved = resolve_item(recipe)

		if not resolved then
			error(("craft ingredient %q doesn't exist"):format(recipe))
		end

		recipe = resolved

		table.insert_all(replacements, api.get_item_replacements(resolved))
	end

	minetest.register_craft({
		type = "fuel",
		recipe = recipe,
		replacements = replacements,
		burntime = fuel_craft.burntime,
	})
end

minetest.register_on_mods_loaded(function()
	-- we assume all items and groups are final at this point

	for _, shaped_craft in ipairs(api.shaped_crafts) do
		analyze_and_register_shaped_craft(shaped_craft)
	end

	for _, shapeless_craft in ipairs(api.shapeless_crafts) do
		analyze_and_register_shapeless_craft(shapeless_craft)
	end

	for _, cooking_craft in ipairs(api.cooking_crafts) do
		analyze_and_register_cooking_craft(cooking_craft)
	end

	for _, fuel_craft in ipairs(api.fuel_crafts) do
		analyze_and_register_fuel_craft(fuel_craft)
	end
end)
