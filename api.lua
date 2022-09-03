local api = {}

api.group_replacements = {}
api.item_replacements = {}

function api.register_replacement(item, replacement)
	local mod, name = item:match("^([^:]+):([^:]+)$")

	if not mod and name then
		error(("don't understand item named %q"):format(item))
	end

	if mod == "group" then
		if api.group_replacements[name] then
			craftsystem.log("warning", "overriding replacement for group %q; %q -> %q",
				name, api.group_replacements[name], replacement)
		end

		api.group_replacements[name] = replacement

	else
		if api.item_replacements[item] then
			craftsystem.log("warning", "overriding replacement for %q; %q -> %q",
				item, api.item_replacements[item], replacement)
		end

		api.item_replacements[item] = replacement
	end
end

api.shaped_crafts = {}
api.shapeless_crafts = {}
api.cooking_crafts = {}
api.fuel_crafts = {}

function api.register_shaped_craft(output, recipe)
	table.insert(api.shaped_crafts, {
		output = output,
		recipe = recipe,
	})
end

function api.register_shapeless_craft(output, recipe)
	table.insert(api.shapeless_crafts, {
		output = output,
		recipe = recipe,
	})
end

function api.register_cooking_craft(output, recipe, cooktime)
	table.insert(api.cooking_crafts, {
		output = output,
		recipe = recipe,
		cooktime = cooktime,
	})
end

function api.register_fuel_craft(recipe, burntime)
	table.insert(api.fuel_crafts, {
		recipe = recipe,
		burntime = burntime,
	})
end

minetest.register_on_mods_loaded(function()
	local items_by_group = {}

	for name, def in pairs(minetest.registered_items) do
		for group, value in pairs(def.groups or {}) do
			if value > 0 then
				local items = items_by_group[group] or {}
				table.insert(items, name)
				items_by_group[group] = items
			end
		end
	end

	api.items_by_groups = items_by_group
end)

function api.get_item_replacements(item)
	return {api.item_replacements[item]}
end

function api.get_group_replacements(group)
	if api.group_replacements[group] then
		return {api.group_replacements[group]}
	end

	local replacements = {}
	for _, item in ipairs(api.items_by_groups[group]) do
		table.insert_all(replacements, api.get_item_replacements(item))
	end
	return replacements
end

craftsystem.api = api
