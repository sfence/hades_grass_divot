
grass_divot = {
	translator = core.get_translator("grass_divot"),
	
	grass_plant_soils = 
		{
			["hades_farming:soil_wet"] = {name="hades_grass_divot:farming_soil_wet_l1"},
			["hades_farming:soil"] = {name="hades_grass_divot:farming_soil_l1"},
		},
}

local S = grass_divot.translator

local planted_divots = {
	{
		name = "farming_soil_wet_l1",
		description = S("Wet farming soil with planted grass divot"),
    tiles = {{name="default_dirt.png^hades_farming_soil_wet.png", color="white"},{name="default_dirt.png", color="white"}},
		dead_chance = 25,
		soil = {
			base = "hades_core:dirt",
			dry = "hades_farming:soil",
			wet = "hades_farming;soil_wet",
		},
		wet = 1,
	},
	{
		name = "farming_soil_l1",
		description = S("Farming soil with planted grass divot"),
    tiles = {{name="default_dirt.png^hades_farming_soil.png", color="white"},{name="default_dirt.png^hades_farming_soil_wet_side.png", color="white"}},
		dead_chance = 50,
		soil = {
			base = "hades_core:dirt",
			dry = "hades_farming:soil",
			wet = "hades_farming;soil_wet",
		},
	},
	{
		name = "dirt_with_grass_l1",
		description = S("Dirt with planted grass divot"),
		tiles = {{name="default_dirt.png", color="white"}},
		dead_chance = 75,
		soil = {
			base = "hades_core:dirt",
			dry = "hades_farming:soil",
			wet = "hades_farming;soil_wet",
		},
	},
}

if core.get_modpath("composting") then
	grass_divot.grass_plant_soils["composting:garden_soil_wet"] = {name="hades_grass_divot:garden_soil_wet_l1"}
	grass_divot.grass_plant_soils["composting:garden_soil"] = {name="hades_grass_divot:garden_soil_l1"}

	table.insert(planted_divots, {
			name = "garden_soil_wet_l1",
			description = S("Wet garden soil with planted grass divot"),
    	tiles = {{name="composting_garden_soil_wet.png^[multiply:#6A4B31^hades_farming_soil_wet.png", color="white"}, {name="composting_garden_soil_wet.png^[multiply:#6A4B31^hades_farming_soil_wet_side.png", color="white"}},
			dead_chance = 1,
			soil = {
				base = "hades_core:dirt",
				dry = "composting:garden_soil",
				wet = "composting;garden_soil_wet",
			},
			wet = 1,
		})
	table.insert(planted_divots, {
			name = "garden_soil_l1",
			description = S("Garden soil with planted grass divot"),
    	tiles = {{name="composting_garden_soil.png^[multiply:#6A4B31^hades_farming_soil.png", color="white"}, {name="composting_garden_soil.png^[multiply:#6A4B31", color="white"}},
			dead_chance = 33,
			soil = {
				base = "hades_core:dirt",
				dry = "composting:garden_soil",
				wet = "composting;garden_soil_wet",
			},
		})
end

for _,data in pairs(planted_divots) do
	core.register_node("hades_grass_divot:"..data.name, {
		description = data.description,
		tiles = data.tiles,
		overlay_tiles = {
			"hades_core_grass_cover_colorable.png^[mask:hades_core_grass_mask_l1.png",
			"",
			{name="hades_core_grass_side_cover_colorable.png^[mask:hades_core_grass_side_mask_l1_xm.png", tileable_vertical=false},
			{name="hades_core_grass_side_cover_colorable.png^[mask:hades_core_grass_side_mask_l1_xp.png", tileable_vertical=false},
			{name="hades_core_grass_side_cover_colorable.png^[mask:hades_core_grass_side_mask_l1_zm.png", tileable_vertical=false},
			{name="hades_core_grass_side_cover_colorable.png^[mask:hades_core_grass_side_mask_l1_zp.png", tileable_vertical=false},
		},
		paramtype2 = "color",
		color = "#acef6a",
		palette = "hades_core_palette_grass.png",
		is_ground_content = true,
		groups = {crumbly=3,soil=1,dirt=1,grass_divot=1,porous=1,wet=data.wet},
		drop = 'hades_core:dirt',
		sounds = hades_sounds.node_sound_dirt_defaults(),
		soil = data.soil,
		on_place = function(itemstack, placer, pointed_thing)
			-- pick the correct grass color
			 local param2 = hades_seasons.get_seasonal_palette_color_param2()
			 local ret = core.item_place(itemstack, placer, pointed_thing, param2)
			 return ret
		end,
		_hades_magic_next = "hades_core:dirt_with_grass_l2",
		_hades_dead_chance = data.dead_chance,
	})
end

if core.get_modpath("wateringcan") then
	wateringcan.wettable_nodes["hades_grass_divot:farming_soil_l1"] = function(pos)
		core.set_node(pos, { name = "hades_grass_divot:farming_soil_wet_l1" })
	end
	if core.get_modpath("composting") then
		wateringcan.wettable_nodes["hades_grass_divot:garden_soil_l1"] = function(pos)
			core.set_node(pos, { name = "hades_grass_divot:garden_soil_wet_l1" })
		end
	end
end

local random = PcgRandom(os.time()+414646468)

core.register_abm({
	name = "hades_grass_divot:grow_planted_grass_divot",
	label = "Growing planted grass divot",
	nodenames = {"group:grass_divot"},
	interval = 2,
	chance = 200,
	action = function(pos, node)
		local def = core.registered_nodes[node.name]
		if def._hades_dead_chance < random:next(0, 100) then
			local above = {x=pos.x, y=pos.y+1, z=pos.z}
    	local node_above = core.get_node(above)
			local adef = core.registered_nodes[node_above.name]
			if adef and (adef.sunlight_propagates or adef.paramtype == "light")
        	and adef.liquidtype == "none"
        	and (core.get_node_light(above) or 0) >= 13 then
				core.set_node(pos, {name = "hades_core:dirt_with_grass_l1", param2 = node.param2})
			end
		else
			core.set_node(pos, {name = "hades_core:dirt"})
		end
	end,
})

core.register_craftitem("hades_grass_divot:grass_divot", {
		description = S("Grass Divot"),
		_tt_help = S("Place me on wet garden soil/garden soil/farming wet soil/farming soil.").."\n".."Use Garden Trowel to place me into dirt.",
		inventory_image = "grass_divot_grass_divot.png",
		
		on_place = function (itemstack, placer, pointed_thing)
			local node = core.get_node(pointed_thing.under)
			if grass_divot.grass_plant_soils[node.name] then
				core.set_node(pointed_thing.under, grass_divot.grass_plant_soils[node.name])
				itemstack:take_item(1)
			end
			return itemstack
		end,
	})

local function action_get_divot(action, user, pos, node)
	core.set_node(pos, action.new_node)
	local inv = user:get_inventory()
	local leftover = inv:add_item("main", action.drop_item)
	if (leftover:get_count()>0) then
		core.add_item(pos, leftover)
	end
	return 1.0
end

moretools.trowel_actions["hades_core:dirt_with_grass"] = {
		action_on_use = action_get_divot,
		new_node = {name="hades_core:dirt_with_grass_l2"},
		drop_item = "hades_grass_divot:grass_divot",
	}
moretools.trowel_actions["hades_core:dirt_with_grass_l3"] = {
		action_on_use = action_get_divot,
		new_node = {name="hades_core:dirt_with_grass_l1"},
		drop_item = "hades_grass_divot:grass_divot",
	}
moretools.trowel_actions["hades_core:dirt_with_grass_l2"] = {
		action_on_use = action_get_divot,
		new_node = {name="hades_core:dirt"},
		drop_item = "hades_grass_divot:grass_divot",
	}

local function action_plant_grass_divot(action, user, pos, node)
  local inv = user:get_inventory()
  local index = user:get_wield_index()
  local use_item = inv:get_stack("main", index+10)
  if use_item:get_name()=="hades_grass_divot:grass_divot" then
    use_item:take_item(1)
    inv:set_stack("main", index+10, use_item)
    core.set_node(pos, action.new_node)
    core.swap_node(pos, action.new_node)
    return action.wear
  end
	if action.second_action then
		action = action.second_action
		return action.action_on_use(action, user, pos, node)
	end
  return false
end

moretools.trowel_actions["hades_core:dirt"] = {
		action_on_use = action_plant_grass_divot,
		new_node = {name="hades_grass_divot:dirt_with_grass_l1"},
		wear = 0.4,
	}

local function add_trowel_action(nodename, action)
	action.second_action = moretools.trowel_actions[nodename]
	moretools.trowel_actions[nodename] = action
end

add_trowel_action("hades_farming:soil", {
		action_on_use = action_plant_grass_divot,
		new_node = {name="hades_grass_divot:farming_soil_l1"},
		wear = 0.2,
	})
add_trowel_action("hades_farming:soil_wet", {
		action_on_use = action_plant_grass_divot,
		new_node = {name="hades_grass_divot:farming_soil_wet_l1"},
		wear = 0.2,
	})

if core.get_modpath("composting") then
	add_trowel_action("composting:garden_soil", {
			action_on_use = action_plant_grass_divot,
			new_node = {name="hades_grass_divot:garden_soil_l1"},
			wear = 0.2,
		})
	add_trowel_action("composting:garden_soil_wet", {
			action_on_use = action_plant_grass_divot,
			new_node = {name="hades_grass_divot:garden_soil_wet_l1"},
			wear = 0.2,
		})
end

