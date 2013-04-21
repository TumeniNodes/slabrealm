-- slabrealm 0.1.0 by paramat.
-- License WTFPL, see license.txt.
-- Textures license CC BY-SA.
-- The snow and ice textures are from the snow biomes mod by Splizard, bob and cornernote, license CC BY-SA.

-- Parameters.

local SLABREALM = true -- Enable generation (true / false).
local YMIN = 3968 -- Approx realm bottom, will be rounded down to chunk edge.
local YMAX = 4687 -- Approx realm top, will be rounded up to chunk edge.
local OFFCEN = 4008 -- Offset centre. Average y of terrain.
local GRAD = 328 -- Noise gradient. Controls maximum height and steepness of terrain.
local WATY = 4008 -- Water surface y.
local CAVOFF = 0.6 -- 0.6 -- Caves offset. Controls cave size and density of cave entrances at the surface.

local AIRTHR = 0.065 -- 0.065 -- Air noise threshold. Controls total depth of terrain and slith base.
local SLITHR = 0.05 -- 0.05 -- Slith noise threshold. Controls terrain depth.
local STOTHR = 0.015 -- 0.015 -- Stone noise threshold. Controls depth of dirt / sand below rockline.

local DESTHR = 0.5 -- 0.5 -- Desert noise threshold.
local SNOTHR = -0.5 -- -0.5 -- Snow noise threshold.

local SAVY = 4200 -- Snowline average y.
local SAMP = 64 -- Snowline amplitude.
local SDIS = 8 -- Snowline transition distance.

local RAVY = 4136 -- Rockline average y.
local RAMP = 64 -- Rockline amplitude.
local RDIS = 64 -- Dirt/sand thinning distance.

local SANY = 4012 -- Sandline average y.
local SANA = 4 -- Sandline amplitude.
local SAND = 2 -- Sandline transition distance.

local CLOUDY = 4072 -- Cloud y.
local CLOTHR = 0.7 -- 0.7 -- Cloud threshold (-2.0 to 2.0). Cloud cover, -2.0 = overcast, 0 = 1/2 cover, 0.4 = 1/3, 2.0 = none.
local CLOINT = 23 -- 23 -- Cloud drift abm interval in seconds.
local CLOCHA = 4096 -- 4096 = 64^2 -- Cloud drift abm 1/x chance per node.

local DEBUG = true

-- 3D Perlin noise for terrain (noise1 and noise2).
local SEEDDIFF1 = 7131313
local OCTAVES1 = 8 -- 8
local PERSISTENCE1 = 0.5 -- 0.5 -- Roughness of terrain.
local SCALE1 = 1024 -- 1024 -- Largest scale of terrain.

-- 2D Perlin noise for biomes (noise3), clouds (noise4), sandline (noise6), rockline (noise7), snowline (noise8).
local SEEDDIFF2 = 2222867
local OCTAVES2 = 4 -- 4
local PERSISTENCE2 = 0.5 -- 0.5
local SCALE2 = 256 -- 256

-- 3D Perlin noise for caves (noise5).
local SEEDDIFF3 = 1752323
local OCTAVES3 = 2 -- 2
local PERSISTENCE3 = 0.5 -- 0.5
local SCALE3 = 8 -- 8

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
	drop = {
		items = {
			{items = {"default:dirt"}, rarity = 2},
		}
	},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
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
	drop = {
		items = {
			{items = {"default:desert_sand"}, rarity = 2},
		}
	},
	sounds = default.node_sound_sand_defaults(),
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
	drop = {
		items = {
			{items = {"default:sand"}, rarity = 2},
		}
	},
	sounds = default.node_sound_sand_defaults(),
})

minetest.register_node("slabrealm:snowslab", {
	description = "SR Snow Slab",
	tiles = {"slabrealm_snow.png"},
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
	drop = {
		items = {
			{items = {"slabrealm:snowblock"}, rarity = 2},
		}
	},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.3},
	}),
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
			for k = 0, zl do -- for each plane do
				local z = z0 + k
				if DEBUG then
					print ("[slabrealm] Processing "..k.." ("..minp.x.." "..minp.y.." "..minp.z..")")
				end
				for i = 0, xl do -- for each column do
					local x = x0 + i
					local surf = false
					local uland = false
					local des = false
					local sno = false
					local noise3 = perlin2:get2d({x=x,y=z})
					local noise6 = perlin2:get2d({x=x-1024,y=z-1024})
					local noise7 = perlin2:get2d({x=x+1024,y=z+1024})
					local noise8 = perlin2:get2d({x=x+1024,y=z})
					if noise3 > DESTHR + math.random() / 10 then des = true end
					if noise3 < SNOTHR - math.random() / 10 then sno = true end
					local sandy = SANY + noise6 * SANA + math.random(SAND)
					local rocky = RAVY + noise7 * RAMP
					local snowy = SAVY + noise8 * SAMP + math.random (SDIS)
					for j = yl, 0, -1 do -- working downwards in a column, for each node do
						local y = y0 + j
						local noise1 = perlin1:get3d({x=x,y=y-0.25,z=z}) -- noise at centre of lower slab
						local offset1 = (OFFCEN - (y - 0.25)) / GRAD
						if noise1 + offset1 >= AIRTHR or y <= yminq + 15 then
							break -- if below slith base break y loop new column
						elseif (noise1 + offset1 >= SLITHR and noise1 + offset1 < AIRTHR) -- if slith base
						or y <= yminq + 20 then
							env:add_node({x=x,y=y,z=z},{name="slabrealm:slith"})
						elseif noise1 + offset1 >= 0 and noise1 + offset1 < SLITHR then -- if terrain
							local noise5 = perlin3:get3d({x=x,y=y-0.25,z=z})
							if noise5 - noise1 - offset1 + CAVOFF > 0 then -- if no cave
								if y > rocky then
									thrsto = STOTHR * (1 - (y - rocky) / RDIS)
								else
									thrsto = STOTHR
								end
								if noise1 + offset1 > thrsto then -- if stone layer
									if des then -- if desert biome
										env:add_node({x=x,y=y,z=z},{name="slabrealm:redstone"})
									else
										env:add_node({x=x,y=y,z=z},{name="slabrealm:stone"})
									end
									if sno and not surf and y < snowy then
										env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowslab"})
									end
								elseif not surf and y > WATY then -- if at surface and above water
									if y > sandy then uland = true end
									local noise2 = perlin1:get3d({x=x,y=y+0.25,z=z})
									local offset2 = (OFFCEN - (y+0.25)) / GRAD
									if noise2 + offset2 > 0 then -- if centre of upper slab is solid
										if y <= sandy then -- if beach
											env:add_node({x=x,y=y,z=z},{name="default:sand"})
										elseif des then
											env:add_node({x=x,y=y,z=z},{name="default:desert_sand"})
										else
											env:add_node({x=x,y=y,z=z},{name="default:dirt_with_grass"})
										end
										if sno then
											env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowslab"})
										end
									else
										if sno then
											env:add_node({x=x,y=y,z=z},{name="slabrealm:snowblock"})
										elseif y <= sandy then
											env:add_node({x=x,y=y,z=z},{name="slabrealm:sandslab"})
										elseif des then
											env:add_node({x=x,y=y,z=z},{name="slabrealm:desertsandslab"})
										else
											env:add_node({x=x,y=y,z=z},{name="slabrealm:grassslab"})
										end
									end
								else
									if y <= sandy and not uland then -- if below sandline and not inland column
										env:add_node({x=x,y=y,z=z},{name="default:sand"})
									elseif des then
										env:add_node({x=x,y=y,z=z},{name="default:desert_sand"})
									else
										env:add_node({x=x,y=y,z=z},{name="default:dirt"})
									end
									if not surf and y == WATY and sno then -- if at surface and at water level in snow
										env:add_node({x=x,y=y+1,z=z},{name="slabrealm:snowslab"})
									end
								end
								surf = true
							end
						elseif y <= yminq + 25 then
							env:add_node({x=x,y=y,z=z},{name="default:sand"})
						elseif y <= WATY then
							if sno and y == WATY then
								env:add_node({x=x,y=y,z=z},{name="slabrealm:ice"})
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
					local noise4 = perlin2:get2d({x=(x0+i)*2,y=(z0+k)*16})
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
