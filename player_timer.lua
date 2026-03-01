local event = require("event")
local component = require("component")
local redstone = component.redstone

local player_timer_util = {}
local playerTimes = {}
local player_clock_tracker = {}
-- forward declared funcs
local is_player_clocked_in
local clock_player
local save_data

function player_timer_util.init()
    -- initialize player_time.txt if it doesn't exist
    local file = io.open("player_time.txt", "r")
    if not file then
        file = io.open("player_time.txt", "w")
        file:write("Karol:0=0\n")
        file:write("Rory:0=0\n")
        file:write("Jack:0=0\n")
        file:close()
    else
        file:close()
    end

    -- populate playerTimes and player_clock_tracker from player_time.txt
    file = io.open("player_time.txt", "r")
    for line in file:lines() do
        local player_name, clock_state, time = string.match(line, "^(%w+):(%d+)=(%d+)$")
        player_clock_tracker[player_name] = clock_state == "1"
        playerTimes[player_name] = tonumber(time)
    end
end

function player_timer_util.PlayerWatchLoop()
  -- watch for redstone signals for player clock in/out
  -- this func runs 1 per second 

    local signal = redstone.getInput(2) -- 2 = back side

    -- find out which player is clocking in or out based on signal strength
    local player_clocked = ""
    local player_current_clock_state = false

    if signal == 8 then
        player_clocked = "Karol"
    elseif signal == 9 then
        player_clocked = "Rory"
    elseif signal == 6 then
        player_clocked= "Jack"
    else
        print("no one detected wtf do i even do here??")
        return -1
    end

    print("Player activity detected: " .. player_clocked)
    if is_player_clocked_in(player_clocked) then
        print(player_clocked .. "is clockeded in")
        player_current_clock_state = true
    else
        print(player_clocked .. "is clocked out")
        player_current_clock_state = false
    end

    -- change players clock state
    clock_player(not player_current_clock_state, player_clocked)

    -- update player times
    for name, clocked_in in pairs(player_clock_tracker) do
        if clocked_in then
            playerTimes[name] = (playerTimes[name] or 0) + 1
        end
    end
    save_data()
    return playerTimes
end

local function is_player_clocked_in(name)
    local file = io.open("player_time.txt", "r")
    if not file then
        return false
    end
    
    for line in file:lines() do
        local player_name, clock_state, time = string.match(line, "^(%w+):(%d+)=(%d+)$")

        if clock_state == "1" and player_name == name then
            file:close()
            return clock_state == "1"
        end
    end
    file:close()
    return false
end

local function clock_player(new_clock_state, player_joined)
    -- read all of player_time.txt and store it in a table
    local file = io.open("player_time.txt", "r")
    if file then
        for line in file:lines() do
            local player_name, clock_state, time = string.match(line, "^(%w+):(%d+)=(%d+)$")
            
            -- debug
            if new_clock_state == true and player_name == player_joined then
                print(player_joined .. " clocked in")
            elseif new_clock_state == false and player_name == player_joined then
                print(player_joined .. " clocked out")
            end

            -- log players new clock state and current time in time.txt
            player_clock_tracker[player_name] = new_clock_state
            playerTimes[player_name] = tonumber(time)
        end
        file:close()
    end
end

local function boolean_to_string(bool)
    return bool and "1" or "0"
end
local function save_data()
    local file = io.open("player_time.txt", "w")
    for name, time in pairs(playerTimes) do
        if time ~= nil then
            file:write(name .. ":" .. boolean_to_string(player_clock_tracker[name]) .. "=" .. time .."\n")
            -- Karol:{0/1}=1234
        end
    end
    file:close()
end

return player_timer_util