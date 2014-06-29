meseingravel = {}

-- \register\ Bucket of wather with gravel
minetest.register_craft({
	output = 'meseingravel:bucket_gravel 1',
	recipe = {
		{'', 'default:gravel', ''},
		{'', 'bucket:bucket_water', ''},
	}
})

minetest.register_craftitem("meseingravel:bucket_gravel", {
	description = "Bucket of wather with gravel",
	inventory_image = "bucket_gravel.png",
	stack_max = 1,
	on_place = function(itemstack, user, pointed_thing)
	-- \settings\ What is placed when you make right click with bucket_gravel
					local source = "meseingravel:watergravel_1"
	-- /settings/
	-- \control\ Must be pointing to node
					if pointed_thing.type ~= "node" then
						return
					end
	-- /control/
	-- \control\ Call on_rightclick if the pointed node defines it
					local node = minetest.get_node_or_nil(pointed_thing.under)
					local node_def
					if node then
						node_def = minetest.registered_nodes[node.name]
					end
					
					if node_def and node_def.on_rightclick and
					   user and not user:get_puncher_control().sneak then
						return node_def.on_rightclick(
							pointed_thing.under,
							node, user,
							itemstack) or itemstack
					end
	-- /control/
	-- \function\ Place node (where, what)
					local place_it = function(pos, source)
							minetest.add_node(pos, {name=source})
					end
	-- /function/
	-- \controls & calling function 'place_it'\
					if node_def and node_def.buildable_to then
						-- | it is buildable (not solid blocks - 'free place')-> replace the node
						place_it(pointed_thing.under, source)
					else
						-- | it is not buildable to -> place above ...
						local node = minetest.get_node_or_nil(pointed_thing.above)
						-- | ...but it is important check if is it posible ...
						if node and minetest.registered_nodes[node.name].buildable_to then
							place_it(pointed_thing.above, source)
						else
							-- | ...it is not so stop placing process -> do not remove the bucket from inventory
							return
						end
					end
	-- /controls & calling function above/
					-- | replace meseingravel:bucket_gravel by bucket:bucket_empty
					return {name = "bucket:bucket_empty"}
				end
		})
-- /register/

--\function\ The 'erosion' of Water with gravel
function meseingravel:add_weathering(full_grown, names, interval, chance)
	minetest.register_abm({
				nodenames = names,
				interval = interval,
				chance = chance,
				action = function(pos, node)
	-- \check\ Floor must be solid block (A water can not spill from the Water with gravel.)
				pos.y = pos.y-1
				node_under = minetest.env:get_node(pos).name
				if ((minetest.get_item_group(node_under, "crumbly") > 0) or (minetest.env:get_node(pos).name == "air")) and
				   (node_under ~= "meseingravel:gravelwithmese") then
			-- | watergravel_ will be replace by default:gravel because water have spilled to box on position y-1
					pos.y = pos.y+1
					minetest.remove_node(pos)
					minetest.add_node(pos, {name="default:gravel"})
					return
				elseif  minetest.get_item_group(node_under, "falling_node") > 0 then
			-- | Blocks of watergravel_ are not crumbly but they can  falling so this is code for them. It is not so important, but I thing that is better stopping 'erosing' if is watergravel_ placed above another watergravel_.
					return
				else
			-- | 'erosing' can continuing
					pos.y = pos.y+1
				end
	-- /check/
	-- \main part\
				local stage = nil -- | stages in cycle of 'erosion'
		-- | The stages are set as parameters of this function in variable names
				for i,name in ipairs(names) do
					if name == node.name then
						stage = i
						break
					end
				end
				if stage == nil then
					return
				end
		-- | next stage in cycle of 'erosion'
				local new_node = {name=names[stage+1]}
				if new_node.name == nil then
		-- | it is done -> last stage is in variable full_grown
				new_node.name = full_grown
				end
				minetest.env:set_node(pos, new_node)
				end
	})
	-- /main part/
end
-- /function/

-- \register\ Stages of 'erosion'
minetest.register_node("meseingravel:watergravel_1", {
	tiles = {"meseingravel_watergravel_1.png"},
	groups = {falling_node=1},
	on_punch = function(pos, node, puncher)
	-- \check\ If you have a shovel and an empty bucket, your bucket will be replaced by bucket_gravel
			local tool = puncher:get_wielded_item():get_name()
			if string.find(tool, "shovel") then
				for i=0, 32, 1 do
					name = puncher:get_inventory():get_stack("main", i):get_name()
					if name == "bucket:bucket_empty" then
						puncher:get_inventory():remove_item("main", "bucket:bucket_empty 1")
						puncher:get_inventory():add_item("main", "meseingravel:bucket_gravel 1")
						minetest.remove_node(pos)
						return
					end
				end
	-- /check/
			else
	-- | If you have not shovel the watergravel_ will be replaced by water and drop gravel
			minetest.remove_node(pos)
			minetest.add_node(pos, {name="default:water_source"})
			minetest.add_item(pos, {name="default:gravel"})
			end
	end,
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.45},
	})
})

minetest.register_node("meseingravel:watergravel_2", {
	tiles = {"meseingravel_watergravel_2.png"},
	groups = {falling_node=1, not_in_creative_inventory=1},
	on_punch = function(pos, node, puncher)
	-- \check\ If you have a shovel and an empty bucket, your bucket will be replaced by bucket_gravel
			local tool = puncher:get_wielded_item():get_name()
			if string.find(tool, "shovel") then
				for i=0, 32, 1 do
					name = puncher:get_inventory():get_stack("main", i):get_name()
					if name == "bucket:bucket_empty" then
						puncher:get_inventory():remove_item("main", "bucket:bucket_empty 1")
						puncher:get_inventory():add_item("main", "meseingravel:bucket_gravel 1")
						minetest.remove_node(pos)
						return
					end
				end
	-- /check/
			else
	-- | If you have not shovel the watergravel_ will be replaced by water and drop gravel
			minetest.remove_node(pos)
			minetest.add_node(pos, {name="default:water_source"})
			minetest.add_item(pos, {name="default:gravel"})
			end
	end,
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.45},
	})
})

minetest.register_node("meseingravel:watergravel_3", {
	tiles = {"meseingravel_watergravel_3.png"},
	groups = {falling_node=1, not_in_creative_inventory=1},
	on_punch = function(pos, node, puncher)
	-- \check\ If you have a shovel and an empty bucket, your bucket will be replaced by bucket_gravel
			local tool = puncher:get_wielded_item():get_name()
			if string.find(tool, "shovel") then
				for i=0, 32, 1 do
					name = puncher:get_inventory():get_stack("main", i):get_name()
					if name == "bucket:bucket_empty" then
						puncher:get_inventory():remove_item("main", "bucket:bucket_empty 1")
						puncher:get_inventory():add_item("main", "meseingravel:bucket_gravel 1")
						minetest.remove_node(pos)
						return
					end
				end
	-- /check/
			else
	-- | If you have not shovel the watergravel_ will be replaced by water and it drops gravel
			minetest.remove_node(pos)
			minetest.add_node(pos, {name="default:water_source"})
			minetest.add_item(pos, {name="default:gravel"})
			end
	end,
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.45},
	})
})

minetest.register_node("meseingravel:gravelwithmese", {
	tiles = {"meseingravel_gravelwithmese.png"},
	groups = {crumbly=2, falling_node=1, not_in_creative_inventory=1},
	drop = {
		max_items = 4,
		items = {
			{ items = {'default:mese_crystal_fragment'} },
			{ items = {'default:mese_crystal_fragment'}, rarity = 2},
			{ items = {'default:mese_crystal_fragment'}, rarity = 4},
			{ items = {'default:mese_crystal'}, rarity = 16}
			}
		},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.45},
	})
})
-- /register/

-- \call function\ Add 'erosion'
meseingravel:add_weathering("meseingravel:gravelwithmese", {"meseingravel:watergravel_1", "meseingravel:watergravel_2", "meseingravel:watergravel_3"}, 50, 7)
-- /call function/
