local load_time_start = os.clock()


local function is_meng(x,y)
	for i = 1,math.ceil(math.log(math.min(x,y))/math.log(3)) do
		local a = 3^(i-1)
		local b = 3^i
		if x%b > a
		and x%b <= a*2
		and y%b > a
		and y%b <= a*2 then
			return true
		end
	end
	return false
end

local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
minetest.register_on_generated(function(minp, maxp)
	t1 = os.clock()
	local geninfo = "[meng] generates..."
	print(geninfo)
	minetest.chat_send_all(geninfo)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for z=minp.z,maxp.z do
		local az = math.abs(z)
		for y=minp.y,maxp.y do
			local ay = math.abs(y)
			local yzmeng = is_meng(ay,az)
			for x=minp.x,maxp.x do
				local p = area:index(x, y, z)
				local ax = math.abs(x)
				if yzmeng
				or is_meng(ax,ay)
				or is_meng(ax,az) then
					data[p] = c_air
				else
					data[p] = c_stone
				end
			end
		end
	end

	vm:set_data(data)
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()

	local geninfo = string.format("[mg] done after: %.2fs", os.clock() - t1)
	print(geninfo)
	minetest.chat_send_all(geninfo)
end)


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[simple_menger_mg] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
