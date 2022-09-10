# craftystem

a minetest API mod to automate generating recipe replacements

## usage

* `craftsystem.api.register_replacement("group:bottle_honey", "vessels:bottle_empty")`
  indicate that whenever `"group:bottle_honey"` is used in a craft recipe registered w/ this mod, it will be replaced
  with `"vessels:bottle_empty"`.
* `craftsystem.api.register_replacement("bees:bottle_honey", "vessels:bottle_empty")`
  whenever `"bees:bottle_honey"` is used in a recipe registered w/ this mod, it will be replaced w/
  `"vessels:bottle_empty"` - even if the recipe uses a group e.g. `"group:food_sugar"`.
* ```lua
  craftystem.api.register_craft({
    type = "shaped",
    output = "mod:candy_apple",
    recipe = {{"group:food_sugar", "group:food_apple"}},
  })
  ```
  automatically get a bottle if `"bees:bottle_honey"` is used, but not if `"default:sugar"` is used
