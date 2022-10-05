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

local function validate(def)
	assert(def, "recipe is nil")

	if def.type == "fuel" then
		assert(type(def.recipe) == "string", ("invalid fuel recipe %q"):format(dump(def.recipe)))
		return
	end

	assert(type(def.output) == "string", ("invalid output %q"):format(dump(def.output)))
	assert(not def.output:match("^group:"), ("invalid output %q"):format(dump(def.output)))

	if def.type == "cooking" then
		assert(type(def.recipe) == "string", ("invalid cooking recipe %q"):format(dump(def.recipe)))

	elseif def.type == "shapeless" then
		assert(type(def.recipe) == "table" and #def.recipe > 0, ("invalid shapeless recipe %q"):format(dump(def.recipe)))

		local expeted_count = #def.recipe
		local count = 0

		for k, v in pairs(def.recipe) do
			count = count + 1
			assert(type(k) == "number" and type(v) == "string", ("invalid shapeless recipe %q"):format(dump(def.recipe)))
		end

		assert(count == expeted_count, ("invalid shapeless recipe %q"):format(dump(def.recipe)))

	elseif def.type == nil or def.type == "shaped" then
		assert(type(def.recipe) == "table" and #def.recipe > 0, ("invalid shaped recipe %q"):format(dump(def.recipe)))
		local expected_width = #def.recipe[1]
		for k, v in pairs(def.recipe) do
			assert(type(k) == "number" and type(v) == "table" and #v == expected_width,
                               ("invalid shaped recipe %q"):format(dump(def.recipe)))
			local width = 0
			for k1, v1 in pairs(v) do
				assert(type(k1) == "number" and type(v1) == "string", ("invalid shaped recipe %q"):format(dump(def.recipe)))
				width = width + 1
			end
			assert(width == expected_width)
		end

	else
		error(("unknown recipe type %q"):format(def.type))
	end
end

api.registered_crafts = {}

function api.register_craft(def)
	validate(def)
	table.insert(api.registered_crafts, def)
end

function api.override_craft(def)
	minetest.clear_craft({output = def.output})
	for i = #api.registered_crafts, 1, -1 do
		if api.registered_crafts[i].output == def.output then
			table.remove(api.registered_crafts, i)
		end
	end
	api.register_craft(def)
end

minetest.register_on_mods_loaded(function()
	local items_by_group = {}

	for name, def in pairs(minetest.registered_items) do
		for group, value in pairs(def.groups or {}) do
			if type(value) ~= "number" then
				craftsystem.log("error", "value %q for group %s of item %s is type %s; must be number",
					value, group, name, type(value))

				value = tonumber(value)
			end

			if value and value > 0 then
				local items = items_by_group[group] or {}
				table.insert(items, name)
				items_by_group[group] = items
			end
		end
	end

	api.items_by_groups = items_by_group
end)

function api.get_replacements(item)
	local mod, name = item:match("^([^:]+):([^:]+)$")

	if not mod and name then
		error(("don't understand item named %q"):format(item))
	end

	if mod == "group" then
		if api.group_replacements[name] then
			return {{name, api.group_replacements[name]}}
		end

		if not api.items_by_groups then
			error("cannot invoke craftsystem.api.get_group_replacements until after mods are loaded")
		end

		local replacements = {}

		for _, other_item in ipairs(api.items_by_groups[name] or {}) do
			table.insert_all(replacements, api.get_replacements(other_item))
		end

		return replacements

	elseif api.item_replacements[item] then
		return {{item, api.item_replacements[item]}}
	end

	return {}
end

craftsystem.api = api
