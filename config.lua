local changed = false

-- helper functions for ImGui
-- Penta: This is blatantly stolen from utilitools, but i made that mod so im allowed to hehe :P
local imguiHelpers = {}
imguiHelpers.visibleLabel = function(label)
	return tostring(label):sub(1, (tostring(label):find("##", nil, true) or 0) - 1)
end
imguiHelpers.tooltip = function(tooltip)
	if imgui.IsItemHovered() and tooltip ~= nil and (type(tooltip) ~= "string" or tooltip:len() > 0) then
		imgui.PushTextWrapPos(imgui.GetFontSize() * 7 / 13 * 65)
		imgui.SetItemTooltip(tostring(tooltip))
		imgui.PopTextWrapPos()
	end
end
imguiHelpers.getWidth = function(label)
	if label == nil or imguiHelpers.visibleLabel(label):len() == 0 then
		return -1 ^ -9
	else
		return -imgui.GetFontSize() * 7 / 13 * imguiHelpers.visibleLabel(label):len() - imgui.GetStyle().ItemInnerSpacing.x
	end
end
imguiHelpers.setWidth = function(label)
	imgui.SetNextItemWidth(imguiHelpers.getWidth(label))
end
imguiHelpers.inputInt = function(label, current, default, tooltip, flags, step, stepFast)
	if current == nil then current = default end
	local v = ffi.new("int[1]", { current })
	imguiHelpers.setWidth(label)
	imgui.InputInt(label, v, step or 0, stepFast, flags or (2 ^ 12))
	imguiHelpers.tooltip(tooltip)
	-- code changed from original:
	if v[0] ~= current then
		changed = true
	end
	return v[0]
end
imguiHelpers.inputCombo = function(label, current, default, tooltip, flags, values, tooltips)
	if current == nil then current = default end
	if flags then imguiHelpers.setWidth(label) end
	local open = imgui.BeginCombo(label, current, flags or (2 ^ 4 + 2 ^ 5 + 2 ^ 7))
	imguiHelpers.tooltip(tooltip)
	local rv = current
	if open then
		for i, v in ipairs(values) do
			local selected = imgui.Selectable_Bool(v, v == current)
			if tooltips then imguiHelpers.tooltip(tooltips[i]) end
			if selected then
				rv = v
			end
		end
		imgui.EndCombo()
	end
	-- code changed from original:
	if rv ~= current then
		changed = true
	end
	return rv
end

-- additional mod specific helpers for the helper functions
local optionalTheme = { "off", unpack(sprites.editor.overdetailed.themes) }
local function optionalTooltips(option)
	return { tostring(option), unpack(sprites.editor.overdetailed.tooltips) }
end

-- user configs
mod.config.theme = imguiHelpers.inputCombo("Theme", mod.config.theme, "overdetailed", "The overall theme for all events by default", nil, sprites.editor.overdetailed.themes, sprites.editor.overdetailed.tooltips)
mod.config.fallback = imguiHelpers.inputCombo("Fallback Theme", mod.config.fallback, "overdetailed", "The fallback theme for all events by default\nLittle effect for now as only the original sprites dont fully cover all events", nil, optionalTheme, optionalTooltips("Turns off fallback and skips to the generic event spite"))
mod.config.previewSize = imguiHelpers.inputInt("Preview Size", mod.config.previewSize, 2, "The size of the events previewed in the configs", nil, 1, nil)
mod.config.individual = mod.config.individual or {}

-- showing all events in the configs
local justShow = true
if imgui.BeginTabBar("overdetailed_events_golden") then -- tab for setting individual sprite themes
	if imgui.BeginTabItem("Show Events##overdetailed_events_golden") then
		imgui.EndTabItem("Show Events##overdetailed_events_golden")
	end
	if imgui.BeginTabItem("Edit Events##overdetailed_events_golden") then
		justShow = false
		imgui.EndTabItem("Edit Events##overdetailed_events_golden")
	end
	imgui.EndTabBar()
end

-- the `selected` sprite is larger than the rest, so have handle the first row differently
local imageSize = 16 * mod.config.previewSize
local first = true
local width = imageSize + (imgui.GetStyle().ItemSpacing.x + imgui.GetStyle().FramePadding.x * 2) * (justShow and 1 or 2) + (justShow and 0 or #"overdetailed" * imgui.GetFontSize() * 7 / 13)
local maxSpace = imgui.GetContentRegionAvail().x + imgui.GetStyle().ItemSpacing.x
local maxCount = math.floor((maxSpace - (22 - 16) * mod.config.previewSize) / width)
local count = 1
for _, name in ipairs(sprites.editor.overdetailed.sortedEvents) do
	if not sprites.editor.overdetailed.wontmake[name] then
		if count ~= 1 then -- force the first sprite of a row even if it would get cut off
			if maxCount >= count then -- old row
				local freeSpace = (maxSpace - maxCount * width - (first and (22 - 16) * mod.config.previewSize or 0)) / (maxCount - 1)
				imgui.SameLine((count - 1) * width + (count - 1) * freeSpace + (first and (22 - 16) * mod.config.previewSize or 0))
			else -- new row
				if first then
					first = false
					maxCount = math.floor(maxSpace / width)
				end
				count = 1
			end
		end
		-- use a nonsense sprite to be able to tell errors effectively
		local sprite = sprites.editor.overdetailed.active[name] or sprites.editor.overdetailed.original.selected
		local currentImageSize = imageSize
		if name == "selected" then
			currentImageSize = 22 * mod.config.previewSize
		end
		imgui.ImageButton("##sprite" .. name, sprite, imgui.ImVec2_Float(currentImageSize, currentImageSize))
		imguiHelpers.tooltip(tostring((Event.info[name] or { name = name }).name))
		if not justShow then -- setting individual sprite themes
			imgui.SameLine()
			mod.config.individual[name] = imguiHelpers.inputCombo("##combo" .. name, mod.config.individual[name], "off", "The individual theme for this event\nSkips the general theme and uses the fallback theme upon failure", nil, optionalTheme, optionalTooltips("Turns off the individual theme and follows the general theme"))
			if mod.config.individual[name] == "off" then
				mod.config.individual[name] = nil
			end
		end
		count = count + 1
	end
end

-- update sprite links upon change in the user settings, this does not save the configs
-- i have decided against autosaving for testing and consistancy purposes
if changed then
	overdetailedEventsGolden.updateSprites()
end