--[[
    Created by Eqplayer16
    v.2.0

    Giveit is a lua script to trade items and coin with slash commands

    Available Commands
    giveit item [pc/npc] [name/target] [itemName] [quantity (optional, default=1 or all of a stack)]
        -Use quotes around the itemName if there are spaces. Quantity will default to 1 if not used, which will trade Whole stacks of stackable items
    giveit item target [itemName] [quantity (optional, default=1 or all of a stack)]
        -Use quotes around the itemName if there are spaces. Quantity will default to 1 if not used, which will trade Whole stacks of stackable items
    giveit itemlist [pc/npc] [name] {[itemName] [quantity] .. }
        -Provide a list of itemName quantity to trade. Max 4 for NPCs, and 8 for PCs
    giveit itemlist target {[itemName] [quantity] .. }
        -Provide a list of itemName quantity to trade. Max 4 for NPCs, and 8 for PCs
    giveit coin [pc/npc] [name] [plat/gold] [amount/all]
        -using 'all' for the amount will trade the entire amount of that coin type
    giveit coin target [plat/gold] [amount/all]
        -using 'all' for the amount will trade the entire amount of that coin type
    giveit raid coin plat [amount]
        -Gives an amount of plat to all raid members

    ToDo:
    - Give every player in group/raid X item


    --Settings code from Lootly by SpecialEd https://www.redguides.com/community/resources/lootly.2196/
    --Trade code from GiveToMe by TheDroidUrLookingFor https://www.redguides.com/community/resources/give-to-me.2876/
    --Coin amount code from AutoMoney2NPC by Artien https://www.redguides.com/community/resources/automoney2npc.1626/

--]]


local mq = require('mq')
local Write = require('lib/Write')



local function PRINTMETHOD(printMessage, ...)
    printf("[GiveIt] " .. printMessage, ...)
end

local function InventoryOpen()
    if mq.TLO.Window('InventoryWindow').Open() then return true else return false end
end
local function CheckCursor()
    if mq.TLO.Cursor.ID() == 0 then return false else return true end
end
local function CursorEmpty()
    if mq.TLO.Cursor.ID() == 0 then return true else return false end
end
local function HaveTarget()
    if mq.TLO.Target.ID() ~= nil then return true else return false end
end

local WaitTime = 750

local function Give(itemName, qty)
    if mq.TLO.FindItem(itemName).ID() ~= nil then
        local itemSlot = mq.TLO.FindItem('=' .. itemName).ItemSlot()
        local itemSlot2 = mq.TLO.FindItem('=' .. itemName).ItemSlot2()
        local pickup1 = itemSlot - 22
        local pickup2 = itemSlot2 + 1
        --grab the whole stack, or specific amount
        if qty ~= 'all' and mq.TLO.FindItem('=' .. itemName).StackCount() >= 1 then
            mq.cmd('/itemnotify in pack' .. pickup1 .. ' ' .. pickup2 .. ' leftmouseup')
            mq.delay(WaitTime)
            while mq.TLO.Window("QuantityWnd").Child("QTYW_SliderInput").Text() ~= qty do
                mq.TLO.Window("QuantityWnd").Child("QTYW_SliderInput").SetText(qty)
                mq.delay(WaitTime)
            end
            while mq.TLO.Window("QuantityWnd").Open() do
                mq.TLO.Window("QuantityWnd").Child("QTYW_Accept_Button").LeftMouseUp()
                mq.delay(50)
            end
        else
            mq.cmd('/shift /itemnotify in pack' .. pickup1 .. ' ' .. pickup2 .. ' leftmouseup')
        end
        --Give it
        mq.delay(WaitTime, CheckCursor)
        mq.cmd('/click left target')
        mq.delay(WaitTime, CursorEmpty)
    end
end

local function GiveCoin(itemName, amt)
    if itemName == 'plat' then
        if mq.TLO.Me.Platinum() >= 1 then
            if amt == 'all' then
                mq.TLO.Window("InventoryWindow").Child("IW_Money0").LeftMouseUp()
                while mq.TLO.Window("QuantityWnd").Open() do
                    mq.TLO.Window("QuantityWnd").Child("QTYW_Accept_Button").LeftMouseUp()
                    mq.delay(50)
                end
            else
                mq.TLO.Window("InventoryWindow").Child("IW_Money0").LeftMouseUp()
                while mq.TLO.Window("QuantityWnd").Child("QTYW_SliderInput").Text() ~= amt do
                    mq.TLO.Window("QuantityWnd").Child("QTYW_SliderInput").SetText(amt)
                    mq.delay(WaitTime)
                end
                while mq.TLO.Window("QuantityWnd").Open() do
                    mq.TLO.Window("QuantityWnd").Child("QTYW_Accept_Button").LeftMouseUp()
                    mq.delay(50)
                end
            end
            mq.delay(WaitTime, CheckCursor)
            mq.cmd('/click left target')
            mq.delay(WaitTime, CursorEmpty)
        end
    elseif itemName == 'gold' then
        if mq.TLO.Me.Gold() >= 1 then
            if amt == 'all' then
                mq.TLO.Window("InventoryWindow").Child("IW_Money1").LeftMouseUp()
                while mq.TLO.Window("QuantityWnd").Open() do
                    mq.TLO.Window("QuantityWnd").Child("QTYW_Accept_Button").LeftMouseUp()
                    mq.delay(50)
                end
            else
                mq.TLO.Window("InventoryWindow").Child("IW_Money1").LeftMouseUp()
                while mq.TLO.Window("QuantityWnd").Child("QTYW_SliderInput").Text() ~= amt do
                    mq.TLO.Window("QuantityWnd").Child("QTYW_SliderInput").SetText(amt)
                    mq.delay(WaitTime)
                end
                while mq.TLO.Window("QuantityWnd").Open() do
                    mq.TLO.Window("QuantityWnd").Child("QTYW_Accept_Button").LeftMouseUp()
                    mq.delay(50)
                end
            end
            mq.delay(WaitTime, CheckCursor)
            mq.cmd('/click left target')
            mq.delay(WaitTime, CursorEmpty)
        end
    end
end

local function GiveAltCoin(itemName, amt)
    local haveCount = mq.TLO.FindItemCount(itemName)()

    if amt == "all" or haveCount < tonumber(amt) then
        local needCount = amt == "all" and 9999 or amt - haveCount
        -- pull some out.
        PRINTMETHOD("Not enough %s in inventory - attempting to pull %d from AltCurrTab", itemName, needCount)
        local tabPage = mq.TLO.Window("InventoryWindow").Child("IW_Subwindows")
        while tabPage.CurrentTab.Name() ~= "IW_AltCurrPage" do
            for i = 1, 5 do
                tabPage.SetCurrentTab(i)
                mq.delay(10)
                if tabPage.CurrentTab.Name() == "IW_AltCurrPage" then break end
            end
            -- tabPage.SetCurrentTab(4)
            -- mq.delay(10)
        end

        mq.delay(500)

        local currencyList = mq.TLO.Window("InventoryWindow").Child("IW_AltCurr_PointList")
        local createButton = mq.TLO.Window("InventoryWindow").Child("IW_AltCurr_CreateItemButton")
        for currencyListId = 1, 255 do
            local currentItem = currencyList.List(currencyListId, 2)()

            if not currentItem then break end

            if currentItem:find(itemName) then
                ---@diagnostic disable-next-line: undefined-field
                while currencyList.SelectedIndex() ~= currencyListId do
                    currencyList.Select(currencyListId)
                    mq.delay(50)
                end

                while not mq.TLO.Window("QuantityWnd").Open() do
                    createButton.LeftMouseUp()
                    mq.delay(50)
                end

                if amt ~= "all" then
                    local countStr = tostring(needCount)
                    while mq.TLO.Window("QuantityWnd").Child("QTYW_SliderInput").Text() ~= countStr do
                        mq.TLO.Window("QuantityWnd").Child("QTYW_SliderInput").SetText(countStr)
                        mq.delay(50)
                    end
                end

                mq.delay(500)

                while mq.TLO.Window("QuantityWnd").Open() do
                    mq.TLO.Window("QuantityWnd").Child("QTYW_Accept_Button").LeftMouseUp()
                    mq.delay(50)
                end

                while mq.TLO.Cursor.ID() ~= nil do
                    mq.cmd("/autoinv")
                end
                break
            end
        end

        tabPage.SetCurrentTab(1)

        mq.delay(500)

        haveCount = mq.TLO.FindItemCount(itemName)()

        if amt ~= "all" and haveCount < tonumber(amt) then
            PRINTMETHOD("Only have %d %s and we need %d - Not enough! Maybe go get more.", haveCount, itemName, needCount)
            return
        end
    end
    Give(itemName, amt)
    if amt == "all" then
        amt = mq.TLO.FindItemCount(itemName)()
    end

    -- if we got here we have enough.
    Give(itemName, amt)
end

local function OpenInventory()
    PRINTMETHOD('Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)
end

local function ClickTrade()
    mq.delay(WaitTime)
    mq.TLO.Window("TradeWnd").Child("TRDW_Trade_Button").LeftMouseUp()
    mq.delay(WaitTime)
end


local function NavToTrade(navTarget)
    PRINTMETHOD('Moving to %s.', navTarget)
    mq.cmd('/nav target')
    while mq.TLO.Navigation.Active() do
        if (mq.TLO.Spawn(navTarget).Distance3D() < 20) then
            mq.cmd('/nav stop')
        end
        mq.delay(50)
    end
end

local function NavTarget(name, spawntype)
    PRINTMETHOD('Targetting %s', name)
    mq.cmd('/target ="' .. name .. '" ' .. spawntype)
    mq.delay(2000, HaveTarget)
    mq.cmd('/face')

    if mq.TLO.Spawn(name).Distance3D() > 20 then
        NavToTrade(name)
    end
end

-- script functions
local function print_usage()
    Write.Info('\agAvailable Commands - ')
    Write.Info('\a-g/giveit item [pc/npc] [name] [itemName] [quantity (optional, default=1 or all of a stack)]\a-t - Use quotes around items with spaces')
    Write.Info('\a-g/giveit item target [itemName] [quantity (optional, default=1 or all of a stack)]\a-t - Use quotes around items with spaces')
    Write.Info('\a-g/giveit itemlist [pc/npc] [name] {[itemName] [quantity] .. }\a-t = Provide a list of itemName quantity to trade. Max 4 for NPCs, and 8 for PCs')
    Write.Info('\a-g/giveit itemlist target {[itemName] [quantity] .. }\a-t = Provide a list of itemName quantity to trade. Max 4 for NPCs, and 8 for PCs')
    Write.Info('\a-g/giveit coin [pc/npc] [name] [plat/gold] [amount]\a-t - use "all" for the amount to trade entire stack')
    Write.Info('\a-g/giveit coin target [plat/gold] [amount]\a-t - use "all" for the amount to trade entire stack')
    Write.Info('\a-g/giveit raid coin plat [amount]\a-t')
    Write.Info('\a-g/giveit altcoin [pc/npc/target] [name] coinname [amount|all]\a-t')
end

-- binds
local function bind_giveit(...)
    local args = { ..., }
    --Debug commands
    --for i,arg in ipairs(args) do
    --    printf('arg[%d]: %s', i, arg)
    --end

    local cmd = args[1]

    -- usage
    if cmd == nil or args[2] == nil then
        print_usage()
        return
    end

    --Check if they used target first
    local name = nil
    local spawntype = args[2]
    local itemName = nil
    local amt = nil
    --If the use target, subtract one from the rest of the args in the original command
    local argmod = 0
    if spawntype == 'target' then
        if not mq.TLO.Target() then
            Write.Info('\a-gYou do not have a target')
            return
        end
        name = mq.TLO.Target.CleanName()
        spawntype = mq.TLO.Target.Type()
        argmod = 1
    end
    -- item
    if cmd == 'item' then
        --Check if they used target first
        if not name then
            --they did not use target, so get the name arg
            name = args[3]
        end
        itemName = args[4 - argmod]
        amt = args[5 - argmod]

        if spawntype ~= nil and name ~= nil and itemName ~= nil then
            --If quantity is empty, set it to 1
            local quantity = 'all'
            if amt ~= nil then
                quantity = amt
            end
            OpenInventory()
            NavTarget(name, spawntype)

            Give(itemName, quantity)

            ClickTrade()
        else
            print_usage()
        end
    end

    -- item list
    -- giveit itemlist [pc/npc] [name] {[itemName] [quantity] .. }
    if cmd == 'itemlist' then
        --Check if they used target first
        if not name then
            --they did not use target, so get the name arg
            name = args[3]
        end
        --itemName = args[4 - argmod]  -- No need to predefine itemName here
        --amt = args[5 - argmod]        -- No need to predefine amt here

        --check for correct number of args
        if spawntype:lower() == 'pc' and args[19 - argmod] ~= nil then
            print_usage()
            return
        end
        if spawntype:lower() == 'npc' and args[11 - argmod] ~= nil then
            print_usage()
            return
        end

        OpenInventory()
        NavTarget(name, spawntype)

        --PCs have max 8 items in trade window
        local maxItems = spawntype:lower() == 'pc' and 8 or 4
        for i = 4, 3 + 2 * maxItems - argmod, 2 do
            local itemName = args[i]
            itemName = itemName:gsub('"', ''):gsub("{", "")
            if itemName == '}' then break end
            local amt = args[i + 1] or 'all'
            printf('itemName: %s, amt: %s', itemName, amt)
            if itemName then
                Give(itemName, amt)
            end
        end

        ClickTrade()
    end

    -- coins
    if cmd == 'coin' then
        --Check if they used target first
        if not name then
            --they did not use target, so get the name arg
            name = args[3]
        end
        itemName = args[4 - argmod]
        amt = args[5 - argmod]

        if spawntype ~= nil and name ~= nil and itemName ~= nil and amt ~= nil then
            OpenInventory()

            NavTarget(name, spawntype)

            GiveCoin(itemName, amt)

            ClickTrade()
        end
    end

    -- altcoin
    if cmd == 'altcoin' then
        --Check if they used target first
        if not name then
            --they did not use target, so get the name arg
            name = args[3]
        end
        itemName = args[4 - argmod]
        amt = args[5 - argmod]

        if spawntype ~= nil and name ~= nil and itemName ~= nil and amt ~= nil then
            OpenInventory()

            NavTarget(name, spawntype)

            GiveAltCoin(itemName, amt)

            ClickTrade()
        end
    end

    -- raid
    if cmd == 'raid' then
        local cmd2 = args[2]
        if cmd2 == 'coin' then
            local spawntype = 'pc'
            local itemName = 'plat'
            local amt = args[4]
            --Return if no amount entered
            if amt == nil then
                print_usage()
                return
            end

            --Open inventory
            OpenInventory()

            --For each raid member
            local raidMemberCount = mq.TLO.Raid.Members()
            for i = 1, raidMemberCount do
                if mq.TLO.Me.CleanName() ~= mq.TLO.Raid.Member(i).CleanName() then
                    NavTarget(mq.TLO.Raid.Member(i).CleanName(), spawntype)

                    GiveCoin(itemName, amt)

                    ClickTrade()
                end
            end
        end
    end
end

local function setup()
    -- register binds
    mq.bind('/giveit', bind_giveit)
end

local function in_game() return mq.TLO.MacroQuest.GameState() == 'INGAME' end

local function main()
    local last_time = os.time()
    while true do
        if in_game() then
            -- only run these every second, the loop is going
            -- to go faster to make the bind snappy
            if os.difftime(os.time(), last_time) >= 1 then
                last_time = os.time()
            end
            mq.doevents()
        end
        mq.delay(100)
    end
end

setup()
main()
