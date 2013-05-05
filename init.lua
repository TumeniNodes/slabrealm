-- slabrealm 0.4.0 by paramat.
-- License WTFPL, see license.txt.
-- Textures license CC BY-SA.
-- The snow, ice, needles and psapling textures are from the snow biomes mod by Splizard, bob and cornernote, license CC BY-SA.
-- The jleaf and jsapling sapling textures are from the jungletree mod by Bas080, license WTFPL.

-- Parameters.

local SLABREALM = true -- Enable generation (true / false).
local YMIN = 4000 -- 4000 -- Approx realm bottom, will be rounded down to chunk edge.
local YMAX = 4700 -- 4700 -- Approx realm top, will be rounded up to chunk edge.
local OFFCEN = 4008 -- 4008 -- Offset centre. Average y of terrain.
local GRAD = 340 -- 340 -- Noise gradient. Controls maximum height and steepness of terrain.
local WATY = 4008 -- 4008 -- Water surface y.

local CAVOFF = -0.01 -- -0.01 -- Cave offset. Controls cave size and size of cave entrances at the surface.
local CAVEXP = 2 -- 2 -- Average cave expansion below surface, expansion is varied by perlin2 (noise10).
local AIRTHR = 0.06 -- 0.06 -- Air noise threshold. Controls total depth of terrain and slith base.
local SLITHR = 0.045 -- 0.045 -- Slith noise threshold. Controls terrain depth.
local STOTHR = 0.015 -- 0.015 -- Stone noise threshold. Controls depth of dirt / sand.

local HITET = 0.15 -- 0.15 -- Desert / rainforest temperature noise threshold.
local LOTET = -0.65 -- -0.65 -- Tundra / taiga temperature noise threshold.
local TGRAD = 384 -- 384 -- Temperature noise gradient. Approx height above sea level for snow biome only.
local HIWET = 0.25 -- 0.25 -- Wet grassland / rainforest wetness noise threshold.
local LOWET = -0.35 -- -0.35 -- Tundra / dry grassland wetness noise threshold.

local SAVY = 4520 -- 4520 -- Snowline average y. Where snow thins out due to thin atmosphere.
local SAMP = 64 -- 64 -- Snowline amplitude.
local SDIS = 64 -- 64 -- Transition distance.

local RAVY = 4200 -- 4200 -- Rockline average y where dirt / sand starts to thin.
local RAMP = 64 -- 64 -- Rockline amplitude.
local RDIS = 64 -- 64 -- Transition distance.

local SANY = 4012 -- 4012 -- Sandline average y where sand starts to thin.
local SANA = 4 -- 4 -- Sandline amplitude.
local SAND = 2 -- 2 -- Transition distance.

local PAPCHA = 2 -- 2 -- Papyrus 1/x chance per waterlevel node.
local PAPTET = 0.15 -- 0.15 -- Papyrus temperature noise threshold.
local DESCACCHA = 421 -- 421 -- Cactus 1/x chance per full node in desert.
local DESGRACHA = 265 -- 265 -- Dry shrub 1/x chance per full node in desert.
local TUNGRACHA = 145 -- 145 -- Dry shrub 1/x chance per full node in tundra.
local TAIGRACHA = 60 -- 60 -- Dry shrub 1/x chance per full node in taiga.
local DRYGRACHA = 3 -- 3 -- Dry shrub 1/x chance per full node in dry grasslands.
local WETGRACHA = 2 -- 2 -- Junglegrass 1/x chance per full node in wet grasslands.
local DECAPPCHA = 85 -- 85 -- Appletree sapling 1/x chance per full node in deciduous forest.
local TAIPINCHA = 25 -- 25 -- Pine 1/x chance per full node in taiga.
local RAIJUNCHA = 13 -- 13 -- Jungletree 1/x chance per full node in rainforest.

local CLOUDY = 4136 -- 4136 -- Cloud y.
local CLOTHR = 0.6 -- 0.6 -- Cloud threshold (-2.0 to 2.0). Cloud cover, -2.0 = overcast, 0 = 1/2 cover, 0.4 = 1/3, 2.0 = none.
local CLOINT = 59 -- 59 -- Cloud drift abm interval in seconds.
local CLOCHA = 4096 -- 4096 = 64^2*4/4 -- Cloud drift abm 1/x chance per slith node.

local SNOABM = true -- Enable snowing abm.
local SNOINT = 57 -- 57 -- Snowing abm interval in seconds.
local SNOCHA = 4096 -- 4096 = 64^2*4/4 -- 1/x chance per slith node.

local GRAINT = 61 -- 61 -- Dirtslab to grassslab abm interval in seconds.
local GRACHA = 11 -- 11 -- 1/x chance per dirtslab.

local PININT = 67 -- 67 -- Pine from sapling abm interval in seconds.
local PINCHA = 11 -- 11 -- 1/x chance per node.

local JUNINT = 71 -- 71 -- Jungletree from sapling abm interval in seconds.
local JUNCHA = 11 -- 11 -- 1/x chance per node.

local MECHA = 103823 -- 103823 = 47^3 -- Mese block 1/x chance per node.
local IRCHA = 2197 -- 2197 = 13^3 -- Iron ore 1/x chance per node.
local COCHA = 1331 -- 1331 = 11^3 -- Coal ore 1/x chance per node.

local DEBUG = true

-- 3D Perlin1 for terrain (noise1 and noise2).
local SEEDDIFF1 = 5829058
local OCTAVES1 = 8 -- 8
local PERSISTENCE1 = 0.53 -- 0.53 -- Roughness of terrain.
local SCALE1 = 1024 -- 1024 -- Largest scale of terrain.

-- 2D Perlin2 for temperature (noise3), clouds (noise4), rockline (noise7), cave size (noise10).
local SEEDDIFF2 = 7690676
local OCTAVES2 = 5 -- 5
local PERSISTENCE2 = 0.5 -- 0.5
local SCALE2 = 512 -- 512

-- 3D Perlin3 for caves (noise5).
local SEEDDIFF3 = 8486984
local OCTAVES3 = 2 -- 2
local PERSISTENCE3 = 0.53 -- 0.53
local SCALE3 = 16 -- 16

-- 2D Perlin4 for wetness (noise9), sandline (noise6), snowline (noise8).
local SEEDDIFF4 = 1035756
local OCTAVES4 = 5 -- 5
local PERSISTENCE4 = 0.5 -- 0.5
local SCALE4 = 512 -- 512

-- Stuff.

slabrealm = {}

local yminq = (80 * math.floor((YMIN + 32) / 80)) - 32
local ymaxq = (80 * math.floor((YMAX + 32) / 80)) + 47
local cloudyq = (80 * math.floor((CLOUDY + 32) / 80)) - 32

-- Nodes.

minetest.register_node("slabrealm:grassslab", {
	description = "SR Grass Slab",
	tiles = {"default_grass.png", "default_dirt.png", "default_grass_side.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {crumbly=3},
	drop = "slabrealm:dirtslab",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

minetest.register_node("slabrealm:dirtslab", {
	description = "SR Dirt Slab",
	tiles = {"default_dirt.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
	on_construct = function(pos, newnode)
		local nodename = minetest.env:get_node({x=pos.x,y=pos.y-1,z=pos.z}).name
		if nodename == "slabrealm:dirtslab" or nodename == "slabrealm:grassslab" then
			minetest.env:remove_node({x=pos.x,y=pos.y,z=pos.z})
			minetest.env:add_node({x=pos.x,y=pos.y-1,z=pos.z},{name="default:dirt"})
		end
	end,
})

minetest.register_node("slabrealm:desertsandslab", {
	description = "SR Desert Sand Slab",
	tiles = {"default_desert_sand.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {sand=1, crumbly=3, falling_node=1},
	sounds = default.node_sound_sand_defaults(),
	on_construct = function(pos, newnode)
		local nodename = minetest.env:get_node({x=pos.x,y=pos.y-1,z=pos.z}).name
		if nodename == "slabrealm:desertsandslab" then
			minetest.env:remove_node({x=pos.x,y=pos.y,z=pos.z})
			minetest.env:add_node({x=pos.x,y=pos.y-1,z=pos.z},{name="default:desert_sand"})
		end
	end,
})

minetest.register_node("slabrealm:sandslab", {
	description = "SR Sand Slab",
	tiles = {"default_sand.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {sand=1, crumbly=3, falling_node=1},
	sounds = default.node_sound_sand_defaults(),
	on_construct = function(pos, newnode)
		local nodename = minetest.env:get_node({x=pos.x,y=pos.y-1,z=pos.z}).name
		if nodename == "slabrealm:sandslab" then
			minetest.env:remove_node({x=pos.x,y=pos.y,z=pos.z})
			minetest.env:add_node({x=pos.x,y=pos.y-1,z=pos.z},{name="default:sand"})
		end
	end,
})

minetest.register_node("slabrealm:snowslab", {
	description = "SR Snow Slab",
	tiles = {"slabrealm_snow.png"},
	light_source = 1,
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {crumbly=3,melts=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.3},
	}),
	on_construct = function(pos, newnode)
		local nodename = minetest.env:get_node({x=pos.x,y=pos.y-1,z=pos.z}).name
		if nodename == "slabrealm:snowslab" then
			minetest.env:remove_node({x=pos.x,y=pos.y,z=pos.z})
			minetest.env:add_node({x=pos.x,y=pos.y-1,z=pos.z},{name="slabrealm:snowblock"})
		end
	end,
})

minetest.register_node("slabrealm:slith", {
	description = "SR Unbreakable Slith",
	tiles = {"slabrealm_slith.png"},
	groups = {unbreakable=1, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("slabrealm:cloud", {
	drawtype = "glasslike",
	tiles = {"slabrealm_cloud.png"},
	light_source = 1,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	post_effect_color = {a=127, r=255, g=255, b=255},
	groups = {not_in_creative_inventory=1},
})

minetest.register_node("slabrealm:stone", {
	description = "SR Stone",
	tiles = {"slabrealm_stone.png"},
	groups = {cracky=3},
	drop = "default:cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("slabrealm:redstone", {
	description = "SR Redstone",
	tiles = {"slabrealm_redstone.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("slabrealm:snowblock", {
	description = "SR Snow Block",
	tiles = {"slabrealm_snow.png"},
	light_source = 1,
	groups = {crumbly=3,melts=2},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.3},
	}),
})

minetest.register_node("slabrealm:ice", {
	description = "SR Ice",
	tiles = {"slabrealm_ice.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,melts=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("slabrealm:needles", {
	description = "SR Pine Needles",
	visual_scale = 1.3,
	tiles = {"slabrealm_needles.png"},
	paramtype = "light",
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"slabrealm:psapling"}, rarity = 20},
			{items = {"slabrealm:needles"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("slabrealm:psapling", {
	description = "SR Pine Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"slabrealm_psapling.png"},
	inventory_image = "slabrealm_psapling.png",
	wield_image = "slabrealm_psapling.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("slabrealm:jleaf", {
	description = "SR Jungle Leaves",
	visual_scale = 1.3,
	tiles = {"slabrealm_jleaf.png"},
	paramtype = "light",
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"slabrealm:jsapling"}, rarity = 20},
			{items = {"slabrealm:jleaf"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("slabrealm:jsapling", {
	description = "SR Jungletree Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"slabrealm_jsapling.png"},
	inventory_image = "slabrealm_jsapling.png",
	wield_image = "slabrealm_jsapling.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})

-- Crafting

minetest.register_craft({
    output = "default:dirt",
    recipe = {
        {"slabrealm:dirtslab"},
        {"slabrealm:dirtslab"},
    },
})

minetest.register_craft({
    output = "default:desert_sand",
    recipe = {
        {"slabrealm:desertsandslab"},
        {"slabrealm:desertsandslab"},
    },
})

minetest.register_craft({
    output = "default:sand",
    recipe = {
        {"slabrealm:sandslab"},
        {"slabrealm:sandslab"},
    },
})

minetest.register_craft({
    output = "slabrealm:snowblock",
    recipe = {
        {"slabrealm:snowslab"},
        {"slabrealm:snowslab"},
    },
})

minetest.register_craft({
    output = "slabrealm:dirtslab 4",
    recipe = {
        {"default:dirt", "default:dirt"},
    },
})

minetest.register_craft({
    output = "slabrealm:desertsandslab 4",
    recipe = {
        {"default:desert_sand", "default:desert_sand"},
    },
})

minetest.register_craft({
    output = "slabrealm:sandslab 4",
    recipe = {
        {"default:sand", "default:sand"},
    },
})

minetest.register_craft({
    output = "slabrealm:snowslab 4",
    recipe = {
        {"slabrealm:snowblock", "slabrealm:snowblock"},
    },
})

-- On generated function.

if SLABREALM then
	minetest.register_on_generated(function(minp, maxp, seed)
		if minp.y >= yminq and maxp.y <= ymaxq then
			local env = minetest.env
			local xl = maxp.x - minp.x
			local yl = maxp.y - minp.y
			local zl = maxp.z - minp.z
			local x0 = minp.x
			local y0 = minp.y
			local z0 = minp.z
			local perlin1 = env:get_perlin(SEEDDIFF1, OCTAVES1, PERSISTENCE1, SCALE1)
			local perlin2 = env:get_perlin(SEEDDIFF2, OCTAVES2, PERSISTENCE2, SCALE2)
			local perlin3 = env:get_perlin(SEEDDIFF3, OCTAVES3, PERSISTENCE3, SCALE3)
			local perlin4 = env:get_perlin(SEEDDIFF4, OCTAVES4, PERSISTENCE4, SCALE4)
			for k = 0, zl do -- for each plane do
				local z = z0 + k
				if DEBUG then
					print ("[slabrealm] Processing "..k.." ("..minp.x.." "..minp.y.." "..minp.z..")")
				end
				for i = 0, xl do -- for each column do
					local x = x0 + i
					local surf = false -- has surface been found?
					local uland = false -- is column inland not under sand?
					local des = false -- desert biome
					local rai = false -- rainforest biome
					local wet = false -- wet grassland biome
					local dry = false -- dry grassland biome
					local dec = false -- deciduous forest biome
					local tun = false -- tundra biome
					local tai = false -- taiga forest biome
					local noise3 = perlin2:get2d({x=x,y=z})
					local noise9 = perlin4:get2d({x=x,y=z})
					local noise6 = perlin4:get2d({x=x*4,y=z*4})
					local noise7 = perlin2:get2d({x=x*2,y=z*2})
					local noise8 = perlin4:get2d({x=x+1024,y=z+1024})
					local noise10 = perlin2:get2d({x=x*4,y=z*4})
					local sandy = SANY + noise6 * SANA + math.random(SAND)
					local rocky = RAVY + noise7 * RAMP
					local snowy = SAVY + noise8 * SAMP + math.random (SDIS)
					for j = yl, 0, -1 do -- working downwards in a column, for each node do
						local y = y0 + j
						local noise1 = perlin1:get3d({x=x,y=y-0.25,z=z}) -- noise at centre of lower slab
						local offset1 = (OFFCEN - (y - 0.25)) / GRAD
						if noise1 + offset1 >= AIRTHR or y <= yminq + 18 then
							break -- if below slith base break y loop new column
						elseif (noise1 + offset1 >= SLITHR and noise1 + offset1 < AIRTHR) -- if slith base
						or y <= yminq + 23 then
							env:add_node({x=x,y=y,z=z},{name="slabrealm:slith"})
						elseif noise1 + offset1 >= 0 and noise1 + offset1 < SLITHR then -- if terrain
							local noise5 = perlin3:get3d({x=x,y=y-0.25,z=z})
							if math.abs(noise5) - (noise1 + offset1) * (CAVEXP + noise10 / 2) + CAVOFF > 0 then -- if no cave
								if not surf then -- when surface found decide biome
									local temp = noise3 - (y - WATY) / TGRAD
									if temp > HITET + math.random() / 10 then
										if noise9 > HIWET + math.random() / 10 then
											rai = true
										else
											des = true
										end
									elseif temp < LOTET + math.random() / 10 then
										if noise9 < LOWET + math.random() / 10 then
											tun = true
										else
											tai = true
										end
									elseif noise9 > HIWET + math.random() / 10 then
										wet = true
									elseif noise9 < LOWET + math.random() / 10 then
										dry = true
									else
										dec = true
									end
								end
								-- bring stone to surface above rocky
								if y > rocky then
									thrsto = STOTHR * (1 - (y - rocky) / RDIS)
								else
									thrsto = STOTHR
								end
								if noise1 + offset1 > thrsto then -- if stone layer
									if math.random(MECHA) == 2 and noise1 + offset1 >= STOTHR then
										env:add_node({x=x,y=y,z=z},{name="default:mese"})
									else
										if des then
											env:add_node({x=x,y=y,z=z},{name="slabrealm:redstone"})
										else
											if math.random(IRCHA) == 2 and noise1 + offset1 >= STOTHR then
												env:add_node({x=x,y=y,z=z},{name="default:stone_with_iron"})
											elseif math.random(COCHA) == 2 and noise1 + offset1 >= STOTHR then
												env:add_node({x=x,y=y,z=z},{name="default:stone_with_coal"})
											else
												env:add_node({x=x,y=y,z=z},{name="slabrealm:stone"})
											end
										end
									end
									if (tun or tai) and not surf and y < snowy then
										if tai then
											env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowblock"})
										else
											env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowslab"})
										end
									end
								elseif not surf and y > WATY then -- when surface found above water add slab or cube 
									if y > sandy then uland = true end
									local noise2 = perlin1:get3d({x=x,y=y+0.25,z=z})
									local offset2 = (OFFCEN - (y+0.25)) / GRAD
									if noise2 + offset2 > 0 then -- if centre of upper slab is solid add cube
										if tai then
											env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowblock"})
										elseif tun then
											env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowslab"})
										end
										if y <= sandy then -- if beach
											env:add_node({x=x,y=y,z=z},{name="default:sand"})
										elseif des then -- if desert
											env:add_node({x=x,y=y,z=z},{name="default:desert_sand"})
											if math.random(DESGRACHA) == 2 then
												env:add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
											elseif math.random(DESCACCHA) == 2 then
												for c = 1, math.random(1,6) do
													env:add_node({x=x,y=y+c,z=z},{name="default:cactus"})
												end
											end
										elseif tun then -- if tundra
											env:add_node({x=x,y=y,z=z},{name="default:dirt"})
											if math.random(TUNGRACHA) == 2 then
												env:add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
											end
										else -- dry / wet grasslands, taige, deciduous forest, rainforest
											env:add_node({x=x,y=y,z=z},{name="default:dirt_with_grass"})
											if dry and math.random(DRYGRACHA) == 2 then
												env:add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
											elseif wet and math.random(WETGRACHA) == 2 then
												env:add_node({x=x,y=y+1,z=z},{name="default:junglegrass"})
											elseif tai and math.random(TAIGRACHA) == 2 then
												env:add_node({x=x,y=y+1,z=z},{name="default:dry_shrub"})
											elseif dec and y > sandy and math.random(DECAPPCHA) == 2 then
												env:add_node({x=x,y=y+1,z=z},{name="default:sapling"})
											elseif tai and math.random(TAIPINCHA) == 2 then
												slabrealm_pine({x=x,y=y+1,z=z})
											elseif rai and math.random(RAIJUNCHA) == 2 then
												slabrealm_jtree({x=x,y=y+1,z=z})
											end
										end
									else
										if (tun or tai) then
											env:add_node({x=x,y=y,z=z},{name="slabrealm:snowblock"})
											if tai then
												env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowslab"})
											end
										elseif y <= sandy then
											env:add_node({x=x,y=y,z=z},{name="slabrealm:sandslab"})
										elseif des then
											env:add_node({x=x,y=y,z=z},{name="slabrealm:desertsandslab"})
										else
											env:add_node({x=x,y=y,z=z},{name="slabrealm:grassslab"})
										end
									end
								else
									if y <= sandy and not uland then -- if below sandline and not under land
										env:add_node({x=x,y=y,z=z},{name="default:sand"})
									elseif des then
										env:add_node({x=x,y=y,z=z},{name="default:desert_sand"})
									else
										env:add_node({x=x,y=y,z=z},{name="default:dirt"})
									end
									if not surf and y == WATY then -- when surface found, water level
										if tai then
											env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowblock"})
										elseif tun then
											env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowslab"})
										end
										if temp > PAPTET + math.random() / 10 and math.random(PAPCHA) == 1 then
											env:add_node({x=x,y=y,z=z},{name="default:dirt_with_grass"}) -- marshy ground
											for p = 1, math.random(2,5) do
												env:add_node({x=x,y=y+p,z=z},{name="default:papyrus"})
											end
										end
									end
								end
								surf = true
							end
						elseif y <= yminq + 28 then -- realm boundary sand
							env:add_node({x=x,y=y,z=z},{name="default:sand"})
						elseif y <= WATY then -- ice and water
							if (tun or tai) and y == WATY then
								env:add_node({x=x,y=y,z=z},{name="slabrealm:ice"})
								if tai then
									env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowslab"})
								end
							else
								env:add_node({x=x,y=y,z=z},{name="default:water_source"})
							end
						end
					end
				end
			end
			if minp.y == cloudyq then
				if DEBUG then
					print ("[slabrealm] Clouds ("..minp.x.." "..minp.y.." "..minp.z..")")
				end
				for i = 0, xl, 16 do
				for k = 0, zl, 16 do
					local noise4 = perlin2:get2d({x=(x0+i)*4,y=(z0+k)*16})
					if noise4 > CLOTHR then
						for a = 0, 15 do
						for b = 0, 15 do
							local x = x0 + i + a
							local z = z0 + k + b
							if env:get_node({x=x,y=CLOUDY,z=z}).name == "air" then
								env:add_node({x=x,y=CLOUDY,z=z},{name="slabrealm:cloud"})
							end
						end
						end
					end
				end
				end
			end
		end
	end)
end

-- Abm.

-- Dirtslab to grassslab abm.

minetest.register_abm({
	nodenames = {"slabrealm:dirtslab"},
	interval = GRAINT,
	chance = GRACHA,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:add_node(pos,{name="slabrealm:grassslab"})
	end,
})

-- Cloud drift abm.

minetest.register_abm({
	nodenames = {
		"slabrealm:slith",
	},
	interval = CLOINT,
	chance = CLOCHA,
	action = function(pos, node, _, _)
		local env = minetest.env
		-- Find cloud above slabstone.
		local cy = false
		for j = 1, 160 do
			local y = pos.y + j
			if env:get_node({x=pos.x,y=y,z=pos.z}).name == "slabrealm:cloud" then
				cy = y
				break
			end
		end
		-- If no cloud above slabstone then return.
		if not cy then return end
		-- Find air at east edge of cloud.
		local cee = false
		for i = 1, 176 do
			local x = pos.x + i
			if env:get_node({x=x,y=cy,z=pos.z}).name == "air" then
				cee = x
				break
			end
		end
		-- Find air at west edge of cloud.
		local cew = false
		for i = 1, 176 do
			local x = pos.x - i
			if env:get_node({x=x,y=cy,z=pos.z}).name == "air" then
				cew = x
				break
			end
		end
		-- If either cloud edge not found or if world not loaded for cloud to move into then halt abm.
		if not cee or not cew then return end
		if env:get_node({x=cew-15,y=cy,z=pos.z}).name == "ignore" then return end
		if DEBUG then
			print ("[slabrealm] Cloud drifts")
		end
		-- Quantize pos.z to edge of 16x16 cloud pixels.
		local nodezq = 16 * math.floor((pos.z) / 16)
		-- Add 16x16 of cloud onto west edge. Only replace air.
		for a = 0, 15 do
		for b = 0, 15 do
			local x = cew - 15 + a
			local z = nodezq + b
			if env:get_node({x=x,y=cy,z=z}).name == "air" then
				env:add_node({x=x,y=cy,z=z},{name="slabrealm:cloud"})
			end
		end
		end
		-- Remove 16x16 of cloud from east edge. Only remove cloud nodes.
		for a = 0, 15 do
		for b = 0, 15 do
			local x = cee - 16 + a
			local z = nodezq + b
			if env:get_node({x=x,y=cy,z=z}).name == "slabrealm:cloud" then
				env:remove_node({x=x,y=cy,z=z})
			end
		end
		end
	end
})

-- Accumulating snow abm.

if SNOABM then
	minetest.register_abm({
		nodenames = {
			"slabrealm:slith",
		},
		interval = SNOINT,
		chance = SNOCHA,
		action = function(pos, node, _, _)
			local env = minetest.env
			local perlin2 = env:get_perlin(SEEDDIFF2, OCTAVES2, PERSISTENCE2, SCALE2)
			local perlin4 = env:get_perlin(SEEDDIFF4, OCTAVES4, PERSISTENCE4, SCALE4)
			local noise3 = perlin2:get2d({x=pos.x,y=pos.z})
			local noise9 = perlin4:get2d({x=pos.x,y=pos.z})
			if noise3 < LOTET and noise9 > LOWET then -- if taiga biome
				local surfy = false
				for j = 79, 0, -1 do
					local y = pos.y + j
					anodename = nodename
					nodename = env:get_node({x=pos.x,y=y,z=pos.z}).name
					if nodename == "default:water_source"
					or nodename == "default:water_flowing" then
						return
					elseif nodename ~= "air" and nodename ~= "ignore" and nodename ~= "slabrealm:cloud" and anodename == "air" then
						surfy = y
						break
					end
				end
				if surfy and surfy < SAVY - SAMP then
					if DEBUG then
						print ("[slabrealm] Snow falls")
					end
					if nodename == "slabrealm:grassslab"
					or nodename == "slabrealm:dirtslab"
					or nodename == "slabrealm:sandslab" then
						env:add_node({x=pos.x,y=surfy,z=pos.z},{name="slabrealm:snowblock"})
					else
						env:add_node({x=pos.x,y=surfy+1,z=pos.z},{name="slabrealm:snowslab"})
					end
				end
			end
		end
	})
end

-- Pine sapling abm.

minetest.register_abm({
    nodenames = {"slabrealm:psapling"},
    interval = PININT,
    chance = PINCHA,
    action = function(pos, node, active_object_count, active_object_count_wider)
		slabrealm_pine(pos)
		if DEBUG then
			print ("[slabrealm] Pine sapling grows")
		end
    end,
})

-- Jungletree sapling abm.

minetest.register_abm({
    nodenames = {"slabrealm:jsapling"},
    interval = JUNINT,
    chance = JUNCHA,
    action = function(pos, node, active_object_count, active_object_count_wider)
		slabrealm_jtree(pos)
		if DEBUG then
			print ("[slabrealm] Jungletree sapling grows")
		end
    end,
})

-- Functions.

-- Pine tree function

function slabrealm_pine(pos)
	local env = minetest.env
	local t = 5 + math.random(3)
	for j= -2, t - 2 do
		env:add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="default:tree"})
		if j >= 1 and j <= t - 4 then
			for i = -1, 1 do
			for k = -1, 1 do
				if i ~= 0 or k ~= 0 then
					env:add_node({x=pos.x+i,y=pos.y+j,z=pos.z+k},{name="slabrealm:needles"})
				end
				if j == t - 4 and i ~= 0 and k ~= 0 then
					env:add_node({x=pos.x+i,y=pos.y+j+1,z=pos.z+k},{name="slabrealm:snowslab"})
				end
			end
			end
		elseif j >= t - 3 then
			for i = -1, 1 do
			for k = -1, 1 do
				if (i == 0 and k ~= 0) or (i ~= 0 and k == 0) then
					env:add_node({x=pos.x+i,y=pos.y+j,z=pos.z+k},{name="slabrealm:needles"})
					if j == t - 2 then
						env:add_node({x=pos.x+i,y=pos.y+j+1,z=pos.z+k},{name="slabrealm:snowslab"})
					end
				end
			end
			end
		end
	end
	for j = t - 1, t do
		env:add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="slabrealm:needles"})
	end
	env:add_node({x=pos.x,y=pos.y+t+1,z=pos.z},{name="slabrealm:snowslab"})
end

-- Jungletree function

function slabrealm_jtree(pos)
	local env = minetest.env
	local t = 12 + math.random(5)
	for j = -3, t do
		if j == math.floor(t * 0.8) or j == t then
			for i = -2, 2 do
			for k = -2, 2 do
				if math.random(5) ~= 2 then
					env:add_node({x=pos.x+i,y=pos.y+j,z=pos.z+k},{name="slabrealm:jleaf"})
				end
			end
			end
		end
		env:add_node({x=pos.x,y=pos.y+j-1,z=pos.z},{name="default:jungletree"})
	end
end
