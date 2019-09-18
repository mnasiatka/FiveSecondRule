local addon_name, addon_data = ...
local maxWidth = 150
local height = 15
timeSinceLastCast = 0

function OnLoad()
    local frame, events = CreateFrame("Frame"), {};
    -- On addon loaded
    function events:ADDON_LOADED(name)
        if name == addon_name then
            if ProgressBarPosition == nil then
                ProgressBarPosition = {
                    x=0,
                    y=-100
                }; -- This is the first time this addon is loaded; initialize the count to 0.
            end
            if ProgressBarIsActive == nil then
                ProgressBarIsActive = true; -- This is the first time this addon is loaded; initialize the count to 0.
            end
            
            f = CreateFrame("Frame", "FiveSecondFrame")
            f:SetToplevel(true)
            f:EnableMouse(true)
            f:SetMovable(true)
            f:SetClampedToScreen(true)
            f:SetWidth(maxWidth)
            f:SetHeight(height)

            tex = f:CreateTexture(nil, "BACKGROUND")
            tex:SetAllPoints()
            tex:SetColorTexture(1, 1, 1, 0.5)
            
            text = f:CreateFontString("TimeRemainingFrame", "OVERLAY", "SystemFont_Outline_Small")
            text:SetPoint("TOP", 0, 15)
            text:SetWidth(maxWidth)
            text:SetText("")
            text:Hide()
            -- f:SetHeight(text:GetHeight() + 15)
            local w = GetScreenWidth() * UIParent:GetEffectiveScale()
            local h = GetScreenHeight() * UIParent:GetEffectiveScale()
            f:SetPoint("CENTER", ProgressBarPosition.x-w/2, ProgressBarPosition.y-h/2)
            f:SetScript('OnShow', function() PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION or 'igMainMenuOption') end)
            f:SetScript('OnHide', function() PlaySound(SOUNDKIT and SOUNDKIT.GS_TITLE_OPTION_EXIT or 'gsTitleOptionExit') end)

            progress = CreateFrame("Frame", "FiveSecondFrame", f)
            progress:SetWidth(maxWidth)
            progress:SetHeight(height)
            texProg = progress:CreateTexture(nil, "BACKGROUND")
            texProg:SetAllPoints()
            texProg:SetColorTexture(1, 0, 0, 0.5)
            progress:SetPoint("CENTER", 0, 0)
            progress:SetScript('OnShow', function() PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION or 'igMainMenuOption') end)
            progress:SetScript('OnHide', function() PlaySound(SOUNDKIT and SOUNDKIT.GS_TITLE_OPTION_EXIT or 'gsTitleOptionExit') end)
            progress:SetScript('OnUpdate', OnUpdate)

            f:RegisterForDrag('LeftButton')
            f:SetScript('OnDragStart', function(f) f:StartMoving() end)
            f:SetScript('OnDragStop', function(f)
                f:StopMovingOrSizing()
                x, y = f:GetCenter()
                ProgressBarPosition = {
                    x=x,
                    y=y
                }
            end)
            f:Show()

            progress:Show()

            tinsert(UISpecialFrames, f:GetName());
        end
    end
    -- UNIT_SPELLCAST_SUCCEEDED
    function events:UNIT_SPELLCAST_SUCCEEDED(...)
        local unit, cast, id = ...
        if unit == "player" and id ~= 5019 then
            timeSinceLastCast = 0
            progress:SetWidth(0)
            text:Hide()
            texProg:SetColorTexture(1, 0, 0, 0.5)
        end
    end
    frame:SetScript("OnEvent", function(self, event, ...)
        events[event](self, ...); -- call one of the functions above
    end);
    for k, v in pairs(events) do
        frame:RegisterEvent(k); -- Register all events for which handlers have been defined
    end
end

function OnUpdate(self, elapsed)
    timeSinceLastCast = timeSinceLastCast + elapsed
    local regenHasStarted = timeSinceLastCast >= 5
    local scale = math.min(timeSinceLastCast, 5) / 5
    local width = maxWidth * scale

    local maxMana = UnitPowerMax("player")
    local currentMana = UnitPower("player")
    local regenRate = GetManaRegen()
    local timeToFullMana = (maxMana - currentMana) / regenRate
    local displayTimeToFullMana = tostring(math.floor(timeToFullMana)).."s"
    progress:SetWidth(width)
    text:SetText(displayTimeToFullMana)
    -- progress:SetWidth(50)
    if regenHasStarted then
        texProg:SetColorTexture(0, 1, 0, 0.8)
        if maxMana ~= currentMana then
            text:Show()
        else
            text:Hide()
        end
    end
end

function _printList(list)
    for key, value in pairs(list) do
        print(key, value)
    end
end

SLASH_FIVESECONDRULE1 = "/5s";
SlashCmdList["FIVESECONDRULE"] = function(msg)
    -- ProgressBarIsActive = not ProgressBarIsActive
    -- print("5 second rule is now "..((ProgressBarIsActive and "ACTIVE") or "NOT active"))
end