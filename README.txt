http://forum.minetest.net/viewtopic.php?id=5686
Slabrealm 0.5.1 by paramat
For latest stable Minetest and back to 0.4.3
Depends default
Licenses: code WTFPL, original textures CC BY_SA
The snow, ice, needles and psapling textures are from the snow biomes mod by Splizard, license CC BY-SA
The jleaf and jsapling sapling textures are from the jungletree mod by Bas080, license WTFPL

Version 0.1.0
-------------
In newly generated chunks this mod generates a large 'smooth' realm with grass, sand, desert sand and snow slabs (half nodes), making less extreme gradients walkable without jumping. The structure was inspired by Larry Niven's Ringworld, since the base rises with the terrain the total thickness remains relatively small, so generation time is usually under 1 minute per chunk.

By default the realm is found between 3900m and 4800m.
10 chunks / 800m thick with a shallow sea and mountains rising 300+m above.
The base is made from unbreakable 'slith' nodes.
Perlin generated caves with full nodes (caves are not smooth or easily walked).
Bug created caves and occasional holes to the underside.
Beaches and dunes with smooth transition to dirt / desert sand.
Above a chosen altitude the dirt and sand gradually thins out to leave full node rocky terrain.
Snow biomes create ice in water and add a slab thickness of snow to land, above a chosen altitude the snow thins out.
All transitions are varied by perlin noise.
Clouds occasionally drift westwards in a cute pixelated way.

Version 0.2.0
-------------
Added dirt slab that changes to grass slab by abm, digging a grass slab now drops a dirt slab.
Digging any slab now drops that slab, they can then be crafted into full blocks if necessary.
Dirt, sand, desert sand and snow slabs are craftable from 2 full nodes side by side in the grid.
Full nodes are craftable from 2 slabs stacked in the grid.
Placing a slab above another slab creates a full node.
Increased PERSISTENCE1 and PERSISTENCE3 to 0.53 for more crazy terrain, overhangs, floaty stuff.
Added jungle biome.
Biomes chosen using 2 perlin patterns: temperature and wetness.
Snowing abm that adds snow slabs on new nodes such as trees grown from saplings or player constructions.
Apple trees, junglegrass in the new jungle biomes (with an option to add jungletree saplings if those exist in your version), papyrus at sea level, dry shrubs and cactus in deserts.
Tweaked default parameters: seas are shallower for faster generation; clouds, rockline and snowline are higher.

Version 0.2.1
-------------
Improved snow abm: fixed bugs, abm can be disabled, snow now slowly accumulates slab by slab in wet snow biomes.

Version 0.4.0
-------------
New biome system with 2 perlin noise patterns for temperature and wetness, temperature also falls with altitude, from these one of 7 biomes is chosen:
Desert (cacti and occasional dry shrub)
Rainforest (my own abstract fast generating jungletree)
Dry grassland (dense dry shrubs)
Deciduous forest (appletree saplings)
Wet grassland (dense junglegrass)
Tundra (cold and dry) (half slab snow, occasional dry shrub)
Taiga (cold and wet) (accumulating snow, occasional dry shrub, pine trees copied from the snow biomes mod but with some height variation)
New fast generating jungletrees and pine trees derived from those of the snow biomes mod by Splizard.
New weblike highly connected cave generation, long curving twisting fissures. Caves occasionally pierce the surface and expand below the surface by an amount varied by perlin noise.
Ore generation in stone: mese block, iron ore and coal.

Version 0.5.0
-------------
1 km walls 4km apart to create bishop ring space habitat.
'Function at line *** has more than 60 upvalues', starting to pack paramters into tables.
Snowblock crafts to default:water_source.
Added lights but not yet added to wall.
Slabrealm:stone crafts to cobble.
Terrain is thicker, average 30 nodes.

Version 0.5.0
-------------
2 colour walls grey / red defined by temperature perlin.
