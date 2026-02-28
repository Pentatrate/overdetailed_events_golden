---@diagnostic disable-next-line: unused-function
local function doOverdetailedEventsGolden(filePath, info, editorDraw)
	-- find the category using the filepath parent folders
	local category = ""
	filePath = filePath:lower()
	local index = filePath:find("/events/") or (1 - #"/events/")
	filePath = filePath:sub(index + #"/events/")
	if filePath:sub(1, 1) == "/" then filePath = filePath:sub(2) end -- custom events have a double / in them
	category = filePath:sub(1, #filePath - (filePath:reverse():find("/") or 0))

	-- do not redefine events, as some mods choose to do so as a shortcut (custom events are loaded after official ones)
	if not sprites.editor.overdetailed.category[info.event] and not sprites.editor.overdetailed.wontmake[info.event] then
		table.insert(sprites.editor.overdetailed.sortedEvents, info.event)
		sprites.editor.overdetailed.category[info.event] = sprites.editor.overdetailed.category[info.event] or category

		-- find the matching sprite to link it
		for _, t in ipairs({ sprites.editor, sprites.note, sprites.editor.events }) do
			for spriteName, sprite in pairs(t) do
				if not sprites.editor.overdetailed.wontmake[spriteName] and sprites.editor.overdetailed.map2[spriteName] then
					-- overriding: some events have an UNECESSARY function to draw themselves, the automatic system cannot link them to their sprites properly, so we manually OVERRIDE the function with the sprite (see code/main.lua for the actual overriding)
					if sprites.editor.overdetailed.overrideFunction[info.event] and spriteName == sprites.editor.overdetailed.overrideFunction[info.event] then
						table.insert(sprites.editor.overdetailed.map2[spriteName], info.event)
						sprites.editor.overdetailed.original[info.event] = sprite
						break
					end
					if type(sprite) == "userdata" then
						if editorDraw == sprite then
							table.insert(sprites.editor.overdetailed.map2[spriteName], info.event)
							break
						elseif sprites.editor.overdetailed.notes[spriteName] and spriteName == info.event then
							table.insert(sprites.editor.overdetailed.map2[spriteName], info.event)
							break
						end
					end
				end
			end
		end
		-- saving the original sprite to be able to effectively switch themes
		if type(editorDraw) == "userdata" then
			sprites.editor.overdetailed.original[info.event] = editorDraw
		elseif editorDraw and not sprites.editor.overdetailed.linkFunction[info.event] and not sprites.editor.overdetailed.overrideFunction[info.event] then
			print("[overdetailed_events_golden]\t\tUNABLE TO LINK SPRITE TO EVENT " .. info.event)
		end
	end
end