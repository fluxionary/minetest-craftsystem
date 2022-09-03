local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

craftsystem = {
	version = os.time({year = 2022, month = 9, day = 2}),
	fork = "fluxionary",

	modname = modname,
	modpath = modpath,
	S = S,

	has = {
	},

	log = function(level, messagefmt, ...)
		return minetest.log(level, ("[%s] %s"):format(modname, messagefmt:format(...)))
	end,

	dofile = function(...)
		return dofile(table.concat({modpath, ...}, DIR_DELIM) .. ".lua")
	end,
}

craftsystem.dofile("util")
craftsystem.dofile("api")
craftsystem.dofile("do_registration")