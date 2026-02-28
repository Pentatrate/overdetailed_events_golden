---@diagnostic disable-next-line: unused-function
local function doOverdetailedEventsGolden(sprites)
	-- Penta: fun stuff ;) might not be the most efficient, but its nice and orderly
	--[[
		note the following wording:
			sprite
				the image data
			spriteName
				how they are referred to in the game code
				multiple events can use the same spriteName and this is problematic
			name := eventName := info.event
				how they are written in the level files
				used for sprite naming in this mod in the filesystem
	]]

	sprites.editor.overdetailed = sprites.editor.overdetailed or {}
	-- the sprite for an event with the current user settings
	sprites.editor.overdetailed.active = {} -- name = sprite
	-- the original sprite for a spriteName
	sprites.editor.overdetailed.original = {} -- name = sprite

	sprites.editor.overdetailed.category = {} -- name
	-- sort the events for visualization in the configs
	sprites.editor.overdetailed.sortedEvents = {} -- name

	-- to determine which table to override the sprite for, since all overdetailed sprites are stored in one table
	sprites.editor.overdetailed.misc = {} -- spriteName
	sprites.editor.overdetailed.notes = {} -- spriteName

-- actually effectively gets used in the code
	sprites.editor.overdetailed.map = {} -- input name get spriteName
	-- to determine conflicts when multiple events map to one sprite, irrelevant afterwards
	sprites.editor.overdetailed.map2 = {} -- input spriteName get names (!)

	-- Manually defined stuff
	sprites.editor.overdetailed.themes = {
		"original",
		"overdetailed",
		"dark",
		"silly",
		"technical",
		"technicaldark"
	}
	sprites.editor.overdetailed.tooltips = {
		"The original event sprites of the game",
		"The normal overdetailed sprites",
		"Overdetailed dark mode, these look cool ngl", -- flechadafoxy, jan 2nd, 2026
		"Poorly drawn events, play song is a speaker\nWorks best with original fallback", -- flechadafoxy, jan 28th, 2026
		"Sets the generic event to a blank sprite\nWorks best with no fallback",
		"Blank but dark\nWorks best with no fallback"
	}
	sprites.editor.overdetailed.complete = { -- whether the mod should complain if a theme doesnt have a sprite for all events, eg whether the theme is complete
		false,
		true,
		true,
		false,
		false,
		false
	}

	-- linking: some events have an UNECESSARY function to draw themselves, the automatic system cannot link them to their sprites properly, so we manually OVERRIDE the function with the sprite (see code/GameManager.lua)
	sprites.editor.overdetailed.overrideFunction = { -- name = spriteName
		extraTap = "extratap",
		comment = "comment"
	}
	-- linking: some events have an UNECESSARY function to draw themselves, the automatic system cannot link them to their sprites properly, so we manually define the links but keep the functions (see below)
	sprites.editor.overdetailed.linkFunction = { -- name = spriteName
		bookmark = "bookmark",
		trace = "trace"
	}
	sprites.editor.overdetailed.wontmake = { -- spriteName and name
		-- spriteName
		square = true,
		minehold = true,
		sideparticle = true,
		finalbouncecenter = true,
		mineexplosionparticle = true,
		mineholdparticle = true,
		beaticon = true,
		mineholdparticle2 = true,
		-- name
		block = true,
		bounce = true,
		hold = true,
		inverse = true,
		mine = true,
		mineHold = true,
		side = true
	}

	-- mapping: create a table for each ingame sprite
	for _, t in ipairs({ sprites.editor, sprites.note, sprites.editor.events }) do
		for spriteName, sprite in pairs(t) do
			if type(sprite) == "userdata" and not sprites.editor.overdetailed.wontmake[spriteName] then
				sprites.editor.overdetailed.map2[spriteName] = sprites.editor.overdetailed.map2[spriteName] or {}
			end
		end
	end

	-- misc: do lots of stuff here because these sprites dont run through the code in code/GameManager.lua
	for spriteName, sprite in pairs(sprites.editor) do
		local name = spriteName -- name == spriteName because we are in misc
		if type(sprite) == "userdata" and not sprites.editor.overdetailed.wontmake[spriteName] then
			sprites.editor.overdetailed.misc[spriteName] = true
			sprites.editor.overdetailed.original[name] = sprite
			table.insert(sprites.editor.overdetailed.map2[spriteName], name)
			sprites.editor.overdetailed.category[name] = ""
			table.insert(sprites.editor.overdetailed.sortedEvents, name)
		end
	end

	-- notes: just define them, we need this to be able to replace sprites.note so any game code using these will also use the overdetailed versions
	for spriteName, sprite in pairs(sprites.note) do
		if type(sprite) == "userdata" and not sprites.editor.overdetailed.wontmake[spriteName] then
			sprites.editor.overdetailed.notes[spriteName] = true
		end
	end

	-- linking: some events have an UNECESSARY function to draw themselves, the automatic system cannot link them to their sprites properly, so we manually define the links but keep the functions
	for name, spriteName in pairs(sprites.editor.overdetailed.linkFunction) do
		if sprites.editor.overdetailed.map2[spriteName] then
			table.insert(sprites.editor.overdetailed.map2[spriteName], name)
			sprites.editor.overdetailed.original[name] = sprites.editor[spriteName] or sprites.note[spriteName] or sprites.editor.events[spriteName]
		end
	end
end