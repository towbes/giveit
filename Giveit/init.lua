--[[
    Created by Eqplayer16
    v.1.0

    Giveit is a lua script to trade items and coin with slash commands
    
    Available Commands
    giveit item [pc/npc] [name] [itemName]
        -Use quotes around the itemName if there are spaces
    giveit coin [pc/npc] [name] [plat/gold] [amount/all]
        -using 'all' for the amount will trade the entire amount of that coin type

    ToDo: Implement trading multiple items at once

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

local function Give(itemName)
    if mq.TLO.FindItem(itemName).ID() ~= nil then
		local itemSlot = mq.TLO.FindItem(itemName).ItemSlot()
		local itemSlot2 = mq.TLO.FindItem(itemName).ItemSlot2()
		local pickup1 = itemSlot - 22
		local pickup2 = itemSlot2 + 1
		mq.cmd('/shift /itemnotify in pack' .. pickup1 .. ' ' .. pickup2 .. ' leftmouseup')
		mq.delay(WaitTime, CheckCursor)
		mq.cmd('/click left target')
		mq.delay(WaitTime, CursorEmpty)
    end
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

-- script functions
local function print_usage()
    Write.Info('\agAvailable Commands - ')
    Write.Info('\a-g/giveit item [pc/npc] [name] [itemName]\a-t - Use quotes around items with spaces')
    Write.Info('\a-g/giveit coin [pc/npc] [name] [plat/gold] [amount]\a-t - use "all" for the amount to trade entire stack')
end

-- binds
local function bind_giveit(cmd, type, name, itemName, amt)

    -- usage
    if cmd == nil then 
        print_usage() 
        return
    end

    -- item
    if cmd == 'item' and type ~= nil and name ~= nil and itemName ~= nil then

		PRINTMETHOD('Opening Inventory')
		mq.TLO.Window('InventoryWindow').DoOpen()
		mq.delay(1500, InventoryOpen)

		PRINTMETHOD('Targetting %s', name)
		mq.cmd('/target "' .. name .. '" ' .. type)
		mq.delay(2000, HaveTarget)
		mq.cmd('/face')

		if mq.TLO.Spawn(name).Distance3D() > 20 then
			NavToTrade(name)
		end

		Give(itemName)

		mq.delay(WaitTime)
		mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
		mq.delay(WaitTime)

    end

    -- item
    if cmd == 'coin' and type ~= nil and name ~= nil and itemName ~= nil and amt ~= nil then

		PRINTMETHOD('Opening Inventory')
		mq.TLO.Window('InventoryWindow').DoOpen()
		mq.delay(1500, InventoryOpen)

		PRINTMETHOD('Targetting %s', name)
		mq.cmd('/target "' .. name .. '" ' .. type)
		mq.delay(2000, HaveTarget)
		mq.cmd('/face')

		if mq.TLO.Spawn(name).Distance3D() > 20 then
			NavToTrade(name)
		end

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

		mq.delay(WaitTime)
		mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
		mq.delay(WaitTime)

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