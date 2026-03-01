local player_timer_util = require("player_timer")
local term = require("term")
local os = require("os")
local math = require("math")
-- gpu
local component = require("component")
local gpu = component.gpu
local screen = component.screen
gpu.setResolution(60, 16)

-- Change the background and foreground
gpu.setBackground(0x000000) -- black
gpu.setForeground(0xFFFFFF) -- white

--print("Starting Player Timer...")
player_timer_util.init()

-- Set background color
gpu.setBackground(0x000000)
-- Fill the entire screen with spaces
local w, h = gpu.getResolution()
gpu.fill(1, 1, w, h, " ")

-- func declare
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%d hours %d minutes %d seconds", hours, minutes, secs)
end

local function drawBar(x, y, width, height, value, maxValue, bgColor, fillColor, text)
    -- Draw background
    gpu.setBackground(bgColor)
    for i = 0, height-1 do
        gpu.fill(x, y+i, width, 1, " ")
    end

    -- Draw fill
    local fillWidth = math.floor((value / maxValue) * width)
    gpu.setBackground(fillColor)
    for i = 0, height-1 do
        gpu.fill(x, y+i, fillWidth, 1, " ")
    end

    -- Draw text above
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.set(x, y-1, text .. "                                        ")
    if text == "Karol" then
        gpu.set(x, y-1, text .. ":         " .. formatTime(value)) -- my name 1 char longer than rory and jack
    else
        gpu.set(x, y-1, text .. ":          " .. formatTime(value))
    end
    --gpu.set(x, y-1, text .. ":          " .. formatTime(value))
end

local function drawSquare(x, y, size, colour)
    gpu.setBackground(colour)
    gpu.fill(x, y, size+1, size, " ")
end

while true do
    local player_table, player_clock_status = player_timer_util.PlayerWatchLoop()
    local max_value = math.max(player_table["Karol"], player_table["Rory"], player_table["Jack"])
    drawBar(1,3,59,2, player_table["Karol"], max_value, 0x303030, 0x00FF00, "Karol")
    drawBar(1,6,59,2, player_table["Rory"], max_value, 0x303030, 0x00FF00, "Rory")
    drawBar(1,9,59,2, player_table["Jack"], max_value, 0x303030, 0x00FF00, "Jack")

    for name, clock_state in pairs(player_clock_status) do
        if clock_state then
            if name == "Karol" then
                drawSquare(17, 16, 2, 0x00FF00)
            elseif name == "Rory" then
                drawSquare(25, 16, 2, 0x00FF00)
            elseif name == "Jack" then
                drawSquare(34, 16, 2, 0x00FF00)
            end
        else
            if name == "Karol" then
                drawSquare(17, 16, 2, 0xFF0000)
            elseif name == "Rory" then
                drawSquare(25, 16, 2, 0xFF0000)
            elseif name == "Jack" then
                drawSquare(34, 16, 2, 0xFF0000)
            end
        end
    end
    drawSquare(42, 16, 2, 0xFF0000)
    --drawSquare(17, 16, 2, 0x00FF00)
    --drawSquare(25, 16, 2, 0x00FF00)
    --drawSquare(34, 16, 2, 0x00FF00)
    -- print("Player Table:")
    -- for name, time in pairs(player_table) do
    --     print(name .. " = " .. time)
    -- end
    -- print("------------------------------")
    os.sleep(1)
end