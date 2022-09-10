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

api.registered_crafts = {}

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

function api.get_replacements(item)
	local mod, name = item:match("^([^:]+):([^:]+)$")

	if not mod and name then
		error(("don't understand item named %q"):format(item))
	end

	if mod == "group" then
		if api.group_replacements[name] then
			return {api.group_replacements[name]}
		end

		if not api.items_by_groups then
			error("cannot invoke craftsystem.api.get_group_replacements until after mods are loaded")
		end

		local replacements = {}

		for _, other_item in ipairs(api.items_by_groups[name]) do
			table.insert_all(replacements, api.get_item_replacements(other_item))
		end

		return replacements

	else
		return {api.item_replacements[item]}
	end
end

craftsystem.api = api
