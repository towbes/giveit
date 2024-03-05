--[[
    Created by Eqplayer16
    v.2.0

    Giveit is a lua script to trade items and coin with slash commands
    
    Available Commands
    giveit item [pc/npc] [name] [itemName] [quantity (optional, default=1 or all of a stack)]
        -Use quotes around the itemName if there are spaces. Quantity will default to 1 if not used, which will trade Whole stacks of stackable items
    giveit coin [pc/npc] [name] [plat/gold] [amount/all]
        -using 'all' for the amount will trade the entire amount of that coin type
    giveit raid coin plat [amount]
        -Gives an amount of plat to all raid members

    ToDo: 
    - Implement trading multiple items at once
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
		local itemSlot = mq.TLO.FindItem(itemName).ItemSlot()
		local itemSlot2 = mq.TLO.FindItem(itemName).ItemSlot2()
		local pickup1 = itemSlot - 22
		local pickup2 = itemSlot2 + 1
        --grab the whole stack, or specific amount
        if qty > 1 and mq.TLO.FindItem(itemName).StackCount() >= 1 then
            mq.cmd('/itemnotify in pack' .. pickup1 .. ' ' .. pickup2 .. ' leftmouseup')
            mq.delay(WaitTime)
            mq.cmd('/notify QuantityWnd QTYW_Slider newvalue ' .. qty)
            mq.delay(WaitTime)
            mq.cmd('/notify QuantityWnd QTYW_Accept_Button leftmouseup')
		else
            mq.cmd('/shift /itemnotify in pack' .. pickup1 .. ' ' .. pickup2 .. ' leftmouseup')
        end
        --Trade it
        mq.delay(WaitTime, CheckCursor)
        mq.cmd('/click left target')
        mq.delay(WaitTime, CursorEmpty)
    end
end

local function GiveCoin(itemName, amt)
    if itemName == 'plat' then
        if mq.TLO.Me.Platinum() >= 1 then
            if amt == 'all' then
                mq.cmd('/shift /notify InventoryWindow IW_Money0 leftmouseup')
            else
                mq.cmd('/notify InventoryWindow IW_Money0 leftmouseup')
                mq.delay(WaitTime)
                mq.cmd('/notify QuantityWnd QTYW_Slider newvalue ' .. amt)
                mq.delay(WaitTime)
                mq.cmd('/notify QuantityWnd QTYW_Accept_Button leftmouseup')
            end
            mq.delay(WaitTime, CheckCursor)
            mq.cmd('/click left target')
            mq.delay(WaitTime, CursorEmpty)
        end
    elseif itemName == 'gold' then
        if mq.TLO.Me.Gold() >= 1 then
            if amt == 'all' then
                mq.cmd('/shift /notify InventoryWindow IW_Money1 leftmouseup')
            else
                mq.cmd('/notify InventoryWindow IW_Money1 leftmouseup')
                mq.delay(WaitTime)
                mq.cmd('/notify QuantityWnd QTYW_Slider newvalue ' .. amt)
                mq.delay(WaitTime)
                mq.cmd('/notify QuantityWnd QTYW_Accept_Button leftmouseup')
            end
            mq.delay(WaitTime, CheckCursor)
            mq.cmd('/click left target')
            mq.delay(WaitTime, CursorEmpty)
        end
    end
end

local function OpenInventory()
    PRINTMETHOD('Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)
end

local function ClickTrade()
    mq.delay(WaitTime)
    mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
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
    mq.cmd('/target "' .. name .. '" ' .. spawntype)
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
    Write.Info('\a-g/giveit coin [pc/npc] [name] [plat/gold] [amount]\a-t - use "all" for the amount to trade entire stack')
    Write.Info('\a-g/giveit raid coin plat [amount]\a-t')
end

-- binds
local function bind_giveit(cmd, val1, val2, val3, val4)

    -- usage
    if cmd == nil then 
        print_usage() 
        return
    end

    -- item
    if cmd == 'item' then
        local spawntype = val1
        local name = val2
        local itemName = val3
        local amt = val4
        if spawntype ~= nil and name ~= nil and itemName ~= nil then
            --If quantity is empty, set it to 1
            local quantity = 1
            if amt ~= nil then
                quantity = tonumber(amt)
            end
            OpenInventory()
            NavTarget(name, spawntype)

            Give(itemName, quantity)

            ClickTrade()

        else
            print_usage() 
        end

    end

    -- item
    if cmd == 'coin' then
        local spawntype = val1
        local name = val2
        local itemName = val3
        local amt = val4
        if spawntype ~= nil and name ~= nil and itemName ~= nil and amt ~= nil then
            OpenInventory()

            NavTarget(name, spawntype)

            GiveCoin(itemName, amt)

            ClickTrade()
        else
            print_usage() 
        end

    end

    -- raid
    if cmd == 'raid' then
        local cmd2 = val1
        if cmd2 == 'coin' then
            local spawntype = 'pc'
            local itemName = 'plat'
            local amt = val3
            --Return if no amount entered
            if amt == nil then
                print_usage()
                return
            end

            --Open inventory
            OpenInventory()

            --For each raid member
            local raidMemberCount = mq.TLO.Raid.Members()
            for i=1,raidMemberCount do
                if mq.TLO.Me.CleanName() ~= mq.TLO.Raid.Member(i).CleanName() then 

                    NavTarget(mq.TLO.Raid.Member(i).CleanName(), spawntype)

                    GiveCoin(itemName, amt)
        
                    ClickTrade()

                end
            end

        else
            print_usage()    
        end
    else
        print_usage()
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