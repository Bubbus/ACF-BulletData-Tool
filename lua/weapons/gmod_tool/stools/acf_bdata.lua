
TOOL.Category		= "Construction";
TOOL.Name			= "#Tool.acf_bdata.listname";
TOOL.Author 		= "Bubbus";
TOOL.Command		= nil;
TOOL.ConfigName		= "";


local SENDTBL = "ABDT_SST"
if SERVER then util.AddNetworkString(SENDTBL) end

print("\n\n\n\n\n\n\n\n\nhi.\n\n\n\n\n\n\n\n\n")

if CLIENT then

	language.Add( "Tool.acf_bdata.listname", "ACF Bullet Data" );
	language.Add( "Tool.acf_bdata.name", "ACF Bullet Data" );
	language.Add( "Tool.acf_bdata.desc", "Paste bullet-data from a crate into the console." );
	language.Add( "Tool.acf_bdata.0", "Left click a crate to paste bullet-data into the console.  Right click for crate mini-data." );

	function TOOL.BuildCPanel( CPanel )
	
	end

	
	net.Receive(SENDTBL, function(len)
		local data = net.ReadTable()
		
		Msg("----------------\n" ..
			"ACF Bullet Data:\n" .. 
			"----------------\n\n")
			
		acf_bdata_printByNameTable(data, "self.BulletData")
		
		Msg("\n----------------\n" .. 
			"End bullet data.\n" ..
			"----------------\n")
			
	end)
	
	
end

-- Update
function TOOL:RightClick( trace )

	if CLIENT then return end

	local ent = trace.Entity;

	if !IsValid( ent ) then 
		return false;
	end

	local pl = self:GetOwner();

	if( ent:GetClass() == "acf_ammo" ) then

		local ArgsTable = {};

		local data = self:MiniBulletData(ent)
		
		net.Start(SENDTBL)
			net.WriteTable(data)
		net.Send(pl)

		ACF_SendNotify( pl, true, "Crate data sending, check console!" );

	end

	return true;
end

-- Copy
function TOOL:LeftClick( trace )

	if CLIENT then return end

	local ent = trace.Entity;

	if !IsValid( ent ) then 
		return false;
	end

	local pl = self:GetOwner();

	if( ent:GetClass() == "acf_ammo" ) then

		local ArgsTable = {};

		local data = self:ExpandBulletData(ent)
		
		net.Start(SENDTBL)
			net.WriteTable(data)
		net.Send(pl)

		ACF_SendNotify( pl, true, "Bullet data sending, check console!" );

	end

	return true;
	
end




function TOOL:MiniBulletData(crate)

	/*
	print("\n\nBEFORE EXPAND:\n")
	printByName(crate.BulletData)
	print(crate.RoundData6, crate.Data6)
	//*/

	local toconvert = {}
	toconvert["Id"] = 			crate.RoundId
	toconvert["Type"] = 		crate.RoundType
	toconvert["PropLength"] = 	crate.RoundPropellant
	toconvert["ProjLength"] = 	crate.RoundProjectile
	toconvert["Data5"] = 		crate.RoundData5
	toconvert["Data6"] = 		crate.RoundData6
	toconvert["Data7"] = 		crate.RoundData7
	toconvert["Data8"] = 		crate.RoundData8
	toconvert["Data9"] = 		crate.RoundData9
	toconvert["Data10"] = 		crate.RoundData10
	toconvert["Colour"] = 		crate:GetColor()
		
	/*
	print("\n\nTO EXPAND:\n")
	printByName(toconvert)
	//*/
	
	return toconvert

end




function TOOL:ExpandBulletData(crate)

	/*
	print("\n\nBEFORE EXPAND:\n")
	//*/

	local toconvert = {}
	toconvert["Id"] = 			crate.RoundId
	toconvert["Type"] = 		crate.RoundType
	toconvert["PropLength"] = 	crate.RoundPropellant
	toconvert["ProjLength"] = 	crate.RoundProjectile
	toconvert["Data5"] = 		crate.RoundData5
	toconvert["Data6"] = 		crate.RoundData6
	toconvert["Data7"] = 		crate.RoundData7
	toconvert["Data8"] = 		crate.RoundData8
	toconvert["Data9"] = 		crate.RoundData9
	toconvert["Data10"] = 		crate.RoundData10
	toconvert["Colour"] = 		crate:GetColor()
		
	/*
	print("\n\nTO EXPAND:\n")
	printByName(toconvert)
	//*/
		
	local ret
	
	if XCF and XCF.ProjClasses then
		local guntable = ACF.Weapons.Guns
		local gun = guntable[toconvert.Id] or {}
		local roundclass = XCF.ProjClasses[gun.roundclass or "Shell"] or error("Unrecognized projectile class " .. (gun.roundclass or "Shell") .. "!")
		toconvert.ProjClass = roundclass
		ret = roundclass.GetExpanded(toconvert)
	else
		---[[
		local rounddef = ACF.RoundTypes[toconvert.Type] or error("No definition for the shell-type", bullet.Type)
		local conversion = rounddef.convert
		--print("rdcv", rounddef, conversion)
		
		if not conversion then error("No conversion available for this shell!") end
		ret = conversion( nil, toconvert )
	end
	--]]--
	
	--ret.ProjClass = this
	
	--ret.Pos = bullet.Pos or Vector(0,0,0)
	--ret.Flight = bullet.Flight or Vector(0,0,0)
	--ret.Type = ret.Type or bullet.Type
	
	local cvarGrav = GetConVar("sv_gravity")
	ret.Accel = Vector(0,0,cvarGrav:GetInt()*-1)
	--if ret.Tracer == 0 and toconvert["Tracer"] and bullet["Tracer"] > 0 then ret.Tracer = bullet["Tracer"] end
	ret.Colour = toconvert["Colour"]
	/*
	print("\n\nAFTER EXPAND:\n")
	printByName(ret)
	//*/
	
	return ret

end




local function pairsByKeys (t, f)
  if not t then return function() end end
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f or mixedcompare)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
	i = i + 1
	if a[i] == nil then return nil
	else return a[i], t[a[i]]
	end
  end
  return iter
end

local pairsByName = pairsByKeys




function acf_bdata_printByNameTable(tbl, name)
	local typ = nil
	local typ2 = nil
	local vstr = nil
	for k, v in pairsByKeys(tbl) do
		typ = type(k)
		typ2 = type(v)
		
		vstr = typ2 == "string" and "\"" .. v .. "\"" or tostring(v)
		
		--print(typ, typ2, vstr)
		
		if typ2 == "string" then
			Msg(name, "[\"", tostring(k), "\"]\t\t= ", vstr, "\n")
		elseif typ2 == "number" then
			Msg(name, "[\"", tostring(k), "\"]\t\t= ", vstr, "\n")
		elseif typ2 == "Vector" then
			Msg(name, "[\"", tostring(k), "\"]\t\t= ", string.format("Vector(%f, %f, %f)", v.x, v.y, v.z), "\n")
		elseif typ2 == "table" and v.r and v.g and v.b then
			Msg(name, "[\"", tostring(k), "\"]\t\t= ", string.format("Color(%d, %d, %d)", v.r, v.g, v.b), "\n")
		elseif typ2 == "boolean" then
			Msg(name, "[\"", tostring(k), "\"]\t\t= ", vstr, "\n")
		else		// can't really do these
			Msg("UNKNOWN TYPE: ", typ2, " AT ", tostring(k), " = ", tostring(vstr), "\n")
		end
	end
	plst = tbl -- reference!
end