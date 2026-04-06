---@diagnostic disable-next-line: unused-function
local function doOverdetailedEventsGolden()
	if overdetailedEventsGolden then return end

	--[[ Rename sprite files to match the new naming system
	for _, theme in ipairs(sprites.editor.overdetailed.themes) do
		if theme ~= "original" then
			print("[overdetailed_events_golden]\t" .. theme)
			local path = "Mods/overdetailed_events_golden/assets/textures/editor/overdetailed/" .. theme
			for _, v in ipairs(love.filesystem.getDirectoryItems(path)) do
				print("[overdetailed_events_golden]\t\t" .. v:sub(1, -5) .. " " .. tostring(not sprites.editor.overdetailed.category[v:sub(1, -5)]))
				if not sprites.editor.overdetailed.category[v:sub(1, -5)] then
					local fPath = path .. "/" .. v
					print("[overdetailed_events_golden]\t\tCANNOT FIND CASE EXACT " .. fPath)
					local name
					for k, _ in pairs(sprites.editor.overdetailed.category) do
						if k:lower() == v:sub(1, -5):lower() then
							name = k
							break
						end
					end
					if name then
						print("[overdetailed_events_golden]\t\tCHANGING " .. fPath .. " TO " .. name)
						if love.filesystem.getInfo(fPath, "file") then
							local file = love.filesystem.read(fPath)
							if love.filesystem.remove(fPath) then
								local success, error = love.filesystem.write(path .. "/" .. name .. ".png", file)
								if not success then print("[overdetailed_events_golden]\t\t" .. error) end
								print("[overdetailed_events_golden]\t\tSUCCESS CHANGING " .. fPath .. " TO " .. name)
							else
								print("[overdetailed_events_golden]\t\tERROR REMOVING " .. fPath)
							end
						end
					else
						print("[overdetailed_events_golden]\t\tFAILED")
					end
				end
			end
		end
	end
	-- ]]

	-- local a = dark and 129 / 255 or 1
	-- love.graphics.setColor(a, a, a, 1)
	-- love.graphics.setLineWidth(1)
	-- love.graphics.rectangle("fill", pos[1] - 8, pos[2] - 8, 16, 16)

	local function drawText(pos, text, x, y)
		love.graphics.printf(text, pos[1], pos[2], 32, "center", nil, nil, nil, 15 + (x or 0), 5 + (y or 0))
	end
	local function drawSprite(event, dark, pos, index, override, overrideTheme)
		love.graphics.draw(sprites.editor.overdetailed[overrideTheme or ("technical" .. (dark and "dark" or ""))][override or ((index or "icon") .. "_" .. event.type)] or  sprites.editor.overdetailed.original.genericevent, pos[1], pos[2], 0, 1, 1, 8, 8)
	end

	local eventFunctions = {
		setColor = function(event, dark)
			local pos = cs:getPosition(event.angle, event.time)

			local r, g, b = event.r, event.g, event.b
			r = (r or 0) / 255 g = (g or 0) / 255 b = (b or 0) / 255
			-- https://www.codestudy.net/blog/formula-to-determine-perceived-brightness-of-rgb-color/#1-simplified-weighted-sum-30-59-11-rule
			local brightness = 0.30 * r + 0.59 * g + 0.11 * b
			love.graphics.setColor(r, g, b, 1)
			love.graphics.rectangle("fill", pos[1] - 6, pos[2] - 6, 12, 12)

			love.graphics.setColor(1, 1, 1, 1)
			drawSprite(event, dark, pos)

			local d = brightness > 0.5 and 0 or 1
			love.graphics.setColor(d, d, d, 1)
			love.graphics.setFont(fonts.main)
			drawText(pos, event.color or "#")
		end,
		setBgColor = function(event, dark)
			local pos = cs:getPosition(event.angle, event.time)

			love.graphics.setColor(1, 1, 1, 1)
			drawSprite(event, dark, pos)

			local d = dark and 1 or 0
			love.graphics.setColor(d, d, d, 1)
			love.graphics.setFont(fonts.main)
			drawText(pos, event.color or "#", 3, 3)
			drawText(pos, event.voidColor or "#", -3, -3)
		end,
		setBoolean = function(event, dark)
			local pos = cs:getPosition(event.angle, event.time)

			love.graphics.setColor(1, 1, 1, 1)
			drawSprite(event, dark, pos, event.enable ~= nil and event.var and event.var ~= "" and (event.enable and "on" or "off"))
		end,
		hom = function(event, dark)
			local pos = cs:getPosition(event.angle, event.time)

			love.graphics.setColor(1, 1, 1, 1)
			drawSprite(event, dark, pos, event.enable == false and "off")
		end,
		forcePlayerSprite = function(event, dark)
			local pos = cs:getPosition(event.angle, event.time)

			local index = event.spriteName or "custom"

			if index then
				index = ({ [""] = "icon", ["><"] = "eyesclosed", [":3"] = "colonthree" })[index] or index
				if not ({ icon = true, idle = true, happy = true, miss = true, angry = true, none = true, eyesclosed = true, colonthree = true, custom = true })[index] then
					index = "custom"
				end
			end

			love.graphics.setColor(1, 1, 1, 1)
			drawSprite(event, dark, pos, index)
		end,
		bookmark = function(event, dark)
			local pos = cs:getPosition(event.angle, event.time)

			local r, g, b = event.r or 0, event.g or 0, event.b or 0
			local largest = math.max(r, g, b) / 255
			if largest == 0 then
				r, g, b = 255, 255, 255
			else
				r, g, b = r / largest, g / largest, b / largest
			end
			love.graphics.setColor(love.math.colorFromBytes(r, g, b, 255))
			drawSprite(event, dark, pos, "color")

			love.graphics.setColor(1, 1, 1)
			drawSprite(event, dark, pos, "nocolor")
		end,
		--[[ outline = function(event, dark)
			local pos = cs:getPosition(event.angle, event.time)

			love.graphics.setColor(1, 1, 1, 1)
			drawSprite(event, dark, pos)

			local d = dark and 1 or 0
			love.graphics.setColor(d, d, d, 1)
			love.graphics.setFont(fonts.main)
			drawText(pos, event.color or "#")
		end ]]
		--[[ setJoystickColorEvent = function(event, dark)
			local pos = cs:getPosition(event.angle, event.time)

			local a = dark and 129 / 255 or 1
			love.graphics.setColor(a, a, a, 1)
			love.graphics.setLineWidth(1)
			love.graphics.rectangle("fill", pos[1] - 8, pos[2] - 8, 16, 16)

			local r, g, b = event.r, event.g, event.b
			r = (r or 0) / 255 g = (g or 0) / 255 b = (b or 0) / 255
			love.graphics.setColor(r, g, b, 1)
			love.graphics.rectangle("fill", pos[1] - 7, pos[2] - 7, 14, 14)

			--love.graphics.setColor(1, 1, 1, 1)
			--love.graphics.draw(sprites.editor.overdetailed.technical["icon_setColor"], pos[1], pos[2], 0, 1, 1, 8, 8)
		end ]]
	}
	for name, f in pairs(eventFunctions) do
		if type(f) == "function" then
			sprites.editor.overdetailed.technical[name] = function(event) f(event) end
			sprites.editor.overdetailed.technicaldark[name] = function(event) f(event, true) end
		end
	end



	-- finish mapping
	for spriteName, names in pairs(sprites.editor.overdetailed.map2) do -- mapping: expect only one event mapped to each sprite
		if #names == 0 then
			print("[overdetailed_events_golden]\t\tNO EVENT MAPPED TO SPRITE " .. spriteName)
		elseif #names == 1 then
			sprites.editor.overdetailed.map[names[1]] = spriteName
		else
			-- try to choose the event with the same name as the spriteName
			local mapped
			for _, name in ipairs(names) do
				if name == spriteName then
					sprites.editor.overdetailed.map[name] = spriteName
					mapped = true
					break
				end
			end
			if not mapped then
				print("[overdetailed_events_golden]\t\tEVENT CONFLICT MAPPING TO SPRITE: " .. spriteName .. " " .. table.concat(names, ", "))
			end
		end
	end
	-- check for invalid, unused data
	for i, theme in ipairs(sprites.editor.overdetailed.themes) do
		if theme ~= "original" then
			---@diagnostic disable-next-line: unused-function
			local function checkSpriteUnused(name)
				if sprites.editor.overdetailed.category[name] then return end

				---@diagnostic disable-next-line: unused-function
				local function spriteWarn()
					local maybe
					if sprites.editor.overdetailed.map2[name] and #sprites.editor.overdetailed.map2[name] == 1 then
						maybe = sprites.editor.overdetailed.map2[name][1]
					end
					if not maybe then
						for name2, _ in pairs(sprites.editor.overdetailed.original) do
							if not sprites.editor.overdetailed[theme][name2] and not sprites.editor.overdetailed.wontmake[name2] and name:lower() == name2:lower() then
								maybe = name2
								break
							end
						end
					end
					print("[overdetailed_events_golden]\t\tUNUSED " .. theme .. " SPRITE " .. name .. (maybe and ". DID YOU MISNAME " .. maybe .. "?" or ""))
				end

				local index = name:find("_")
				if not index then spriteWarn() return end

				local spriteFunctions = {
					icon = { setColor = true, setBgColor = true, setBoolean = true, hom = true, forcePlayerSprite = true, bookmark = true },
					on = { setBoolean = true },
					off = { setBoolean = true, hom = true },
					idle = { forcePlayerSprite = true },
					happy = { forcePlayerSprite = true },
					miss = { forcePlayerSprite = true },
					angry = { forcePlayerSprite = true },
					none = { forcePlayerSprite = true },
					eyesclosed = { forcePlayerSprite = true },
					colonthree = { forcePlayerSprite = true },
					custom = { forcePlayerSprite = true },
					color = { bookmark = true },
					nocolor = { bookmark = true }
				}
				spriteFunctions = spriteFunctions[name:sub(1, index - 1)]
				if not spriteFunctions then spriteWarn() return end

				if spriteFunctions[name:sub(index + 1)] and sprites.editor.overdetailed.category[name:sub(index + 1)] then return end

				spriteWarn()
			end
			for name, _ in pairs(sprites.editor.overdetailed[theme]) do -- check for overdetailed sprite not used ingame
				checkSpriteUnused(name)
			end
			if sprites.editor.overdetailed.complete[i] then
				for name, _ in pairs(sprites.editor.overdetailed.category) do -- check for a missing overdetailed sprites for an event
					if not sprites.editor.overdetailed[theme][name] and not sprites.editor.overdetailed.wontmake[name] then
						print("[overdetailed_events_golden]\t\tNO " .. theme .. " SPRITE FOR EVENT " .. name)
					end
				end
				for name, _ in pairs(sprites.editor.overdetailed.original) do -- check for a missing overdetailed sprite for an original sprite
					if not sprites.editor.overdetailed[theme][name] and not sprites.editor.overdetailed.wontmake[name] then
						print("[overdetailed_events_golden]\t\tNO " .. theme .. " SPRITE FOR SPRITE " .. name)
					end
				end
			end
		end
	end
	for name, _ in pairs(sprites.editor.overdetailed.linkFunction) do -- check for unnecessary manual linking that is already done automatically
		if type(Event.editorDraw[name]) ~= "function" then
			print("[overdetailed_events_golden]\t\tNO NEED TO LINK MANUALLY " .. name)
		end
	end

	_G.overdetailedEventsGolden = {}

	function overdetailedEventsGolden.getTheme(name)
		local globalSwitch = mods.overdetailed_events_golden.config.theme or "overdetailed"
		local fallback = mods.overdetailed_events_golden.config.fallback or "overdetailed"
		local individual = mods.overdetailed_events_golden.config.individual[name]
		return ( -- individual theme
			individual and individual ~= "off" and sprites.editor.overdetailed[individual][name] and individual
		) or ( -- global theme (skips to fallback if individual is on)
			not (individual and individual ~= "off") and sprites.editor.overdetailed[globalSwitch][name] and globalSwitch
		) or ( -- fallback theme
			fallback ~= "off" and sprites.editor.overdetailed[fallback][name] and fallback
		) or ( -- themed generic event
			name ~= "genericevent" and "genericevent"
		) or ( -- original generic event
			"original"
		)
	end

	function overdetailedEventsGolden.updateSprites() -- global function to link all sprites with the current user  settings
		local globalSwitch = mods.overdetailed_events_golden.config.theme or "overdetailed"
		local fallback = mods.overdetailed_events_golden.config.fallback or "overdetailed"

		local function individualSprite(name) -- determine the sprite based off of user settings
			local individual = mods.overdetailed_events_golden.config.individual[name]
			return ( -- individual theme
				individual and individual ~= "off" and sprites.editor.overdetailed[individual][name]
			) or ( -- global theme (skips to fallback if individual is on)
				not (individual and individual ~= "off") and sprites.editor.overdetailed[globalSwitch][name]
			) or ( -- fallback theme
				fallback ~= "off" and sprites.editor.overdetailed[fallback][name]
			) or ( -- themed generic event
				name ~= "genericevent" and individualSprite("genericevent")
			) or ( -- original generic event
				sprites.editor.overdetailed.original.genericevent
			)
		end
		local function updateSprite(name) -- link the sprite to be used ingame
			if sprites.editor.overdetailed.wontmake[name] then return end

			local sprite = individualSprite(name)
			local spriteName = sprites.editor.overdetailed.map[name]
			local sprite2 = sprite
			if type(sprite) == "function" then
				local theme = overdetailedEventsGolden.getTheme(name)
				if name ~= "genericevent" and theme == "genericevent" then
					local _
					_, sprite2 = updateSprite("genericevent")
				else
					sprite2 = sprites.editor.overdetailed[overdetailedEventsGolden.getTheme(name)]["icon_" .. name] or sprites.editor.overdetailed.original.genericevent
				end
			end
			if spriteName then
				if sprites.editor.overdetailed.misc[spriteName] then
					sprites.editor[spriteName] = sprite2
				elseif sprites.editor.overdetailed.notes[spriteName] then
					sprites.note[spriteName] = sprite2
				else
					sprites.editor.events[spriteName] = sprite2
				end
			end
			sprites.editor.overdetailed.active[name] = sprite2
			return sprite, sprite2
		end

		-- loop through all events, linking their sprites
		for name, v in pairs(Event.info) do
			if not sprites.editor.overdetailed.wontmake[name] then
				local sprite = updateSprite(name)
				if type(sprites.editor.overdetailed.original[name]) ~= "function" or sprites.editor.overdetailed.overrideFunction[name] then
					-- overriding: some events have an UNECESSARY function to draw themselves, the automatic system cannot link them to their sprites properly, so we manually OVERRIDE the function with the sprite
					-- if the events have a sprite to be defined for drawing, overwrite it as well
					Event.editorDraw[name] = sprite
				elseif not sprites.editor.overdetailed.linkFunction[name] then
					print("[overdetailed_events_golden]\t\tFAILED TO LINK EVENT " .. name)
				end
			end
		end
		-- repeat the process for misc, as they are not events
		for spriteName, v in pairs(sprites.editor.overdetailed.misc) do
			local name = spriteName -- name == spriteName because we are in misc
			updateSprite(name)
		end
	end

	-- sort the events to be displayed in the configs
	table.sort(sprites.editor.overdetailed.sortedEvents, function(a, b)
		if sprites.editor.overdetailed.category[a] ~= sprites.editor.overdetailed.category[b] then
			return sprites.editor.overdetailed.category[a] < sprites.editor.overdetailed.category[b]
		end
		if sprites.editor.overdetailed.category[a] == "" then
			return (Event.info[a] or { name = a }).name:lower() >= (Event.info[b] or { name = b }).name:lower()
		end
		return (Event.info[a] or { name = a }).name:lower() < (Event.info[b] or { name = b }).name:lower()
	end)

	overdetailedEventsGolden.updateSprites()
	-- print("[overdetailed_events_golden]\nEvents (" .. #sprites.editor.overdetailed.sortedEvents .. "):\n" .. table.concat(sprites.editor.overdetailed.sortedEvents, ", "))
end