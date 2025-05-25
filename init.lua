
grass_divot = {
	translator = core.get_translator("grass_divot"),
	
	wet_garden_soils = {["composting:garden_soil_wet"] = true},
}

local S = grass_divot.translator;

core.register_craftitem("hades_grass_divot:grass_divot", {
		description = S("Grass Divot"),
		_tt_help = S("Place me on wet garden soil."),
		inventory_image = "grass_divot_grass_divot.png",
		
		on_place = function (itemstack, placer, pointed_thing)
			local node = core.get_node(pointed_thing.under);
			if grass_divot.wet_garden_soils[node.name] then
				core.set_node(pointed_thing.under, {name="hades_core:dirt_with_grass_l1"})
				itemstack:take_item(1);
			end
			return itemstack;
		end,
	})


local function action_get_divot(action, user, pos, node)
	core.set_node(pos, action.new_node);
	local inv = user:get_inventory();
	local leftover = inv:add_item("main", action.drop_item);
	if (leftover:get_count()>0) then
		core.add_item(pos, leftover);
	end
	return true
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

