# craftystem

a minetest API mod to automate generating recipe replacements

## usage

* `craftsystem.api.register_replacement("group:bucket_water", "bucket:bucket_empty")`
  indicate that whenever `"group:bucket_water"` is used in a craft recipe registered w/ this mod, it will be replaced
  with "bucket:bucket_empty".
* `craftsystem.api.register_replacement("bees:bottle_honey", "vessels:bottle_empty")`
  whenever `"bees:bottle_honey"` is used in a recipe registered w/ this mod, it will be replaced w/
  "vessels:bottle_empty" - even if the recipe uses a group e.g. `"group:food_sugar"`
* `craftystem.api.register_shaped("mod:candy_apple", {{"group:food_sugar", "group:food_apple"}})`
  automatically get a bottle if `"bees:bottle_honey"` is used, but not if `"default:sugar"` is used
* `craftystem.api.register_shapeless("mod:candy_apple", {"group:food_sugar", "group:food_apple"})`
  automatically get a bottle if `"bees:bottle_honey"` is used, but not if `"default:sugar"` is used
