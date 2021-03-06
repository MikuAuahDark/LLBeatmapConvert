local JSON = require("JSON")

local function hasbit(a, b)
	return a % (b * 2) >= b
end

function load_sif_beatmap(file)
	local f = io.open(file, "rb")
	local x = JSON:decode(f:read("*a"))

	f:close()
	return x
end

function load_rs_beatmap(file)
	local f = io.open(file, "rb")
	local x = JSON:decode(f:read("*a"))
	
	return x.song_info[1].notes
end

function load_llp_beatmap(file)
	local f = io.open(file, "rb")
	local x = JSON:decode(f:read("*a"))
	
	f:close()
	return x
end

function save_sif_beatmap(file, beatmap)
	local f = io.open(file, "wb")

	f:write(JSON:encode(beatmap))
	f:close()
end

function rs2sif(rs_map, attribute)
	local sif_map = {}
	
	for n, v in pairs(rs_map) do
		local new_effect = 1
		
		if hasbit(v.effect, 3) then
			new_effect = 3
		elseif hasbit(v.effect, 4) then
			new_effect = 4
		end
		
		table.insert(sif_map, {
			timing_sec = v.timing_sec,
			notes_attribute = attribute or 1,
			notes_level = 1,
			effect = new_effect,
			effect_value = v.effect_value,
			position = v.position
		})
	end
	
	return sif_map
end

function llp2sif(llp, attribute)
	local sif_map = {}
	
	for n, v in pairs(llp.lane) do
		for a, b in pairs(v) do
			local new_effect = 1
			local new_effect_val = 2
			
			if b.longnote then
				new_effect = 3
				new_effect_val = (b.endtime - b.starttime) / 1000
			end
			
			table.insert(sif_map, {
				timing_sec = b.starttime / 1000,
				notes_attribute = attribute or 1,
				notes_level = 1,
				effect = new_effect,
				effect_value = new_effect_val,
				position = 9 - b.lane
			})
		end
	end
	
	table.sort(sif_map, function(a, b) return a.timing_sec < b.timing_sec end)
	return sif_map
end
