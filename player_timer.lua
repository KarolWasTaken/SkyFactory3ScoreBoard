local event = require("event")
local component = require("component")
local redstone = component.redstone

local player_timer_util = {}
local playerTimes = {}
local player_clock_tracker = {}

-- local funcs delcared here
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

local function clock_player(new_clock_state, target_player_name)
    -- read all of player_time.txt and store it in a table
    local file = io.open("player_time.txt", "r")
    if file then
        for line in file:lines() do
            local player_name, clock_state, time = string.match(line, "^(%w+):(%d+)=(%d+)$")
            
            if(player_name ~= target_player_name) then
                goto end_func
            end

            -- debug
            -- if new_clock_state == true and player_name == target_player_name then
            --     print(player_name .. " clocked in")
            -- elseif new_clock_state == false and player_name == target_player_name then
            --     print(player_name .. " clocked out")
            -- end

            -- log players new clock state and current time in time.txt
            player_clock_tracker[target_player_name] = new_clock_state
            playerTimes[target_player_name] = tonumber(time)

            ::end_func::
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

-- global funcs declared here

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
        --print("Initializing player: " .. player_name .. ", clock state: " .. clock_state .. ", time: " .. time)
        player_clock_tracker[player_name] = clock_state == "1"
        playerTimes[player_name] = tonumber(time)
    end
end
function player_timer_util.PlayerWatchLoop()
  -- watch for redstone signals for player clock in/out
  -- this func runs 1 per second 

    local signal = redstone.getInput(2) -- 2 = back side

    -- before checking for inputs, increment all clocked in players
    for name, clocked_in in pairs(player_clock_tracker) do
        --print(name .. " clocked state: " .. tostring(clocked_in))
        if clocked_in then
            playerTimes[name] = (playerTimes[name] or 0) + 1
        end
    end
    save_data()

    -- find out which player is clocking in or out based on signal strength
    local player_clocked = ""
    local player_current_clock_state = false

    -- debug
    --print("Redstone signal detected: " .. signal)

    if signal == 8 then
        player_clocked = "Karol"
    elseif signal == 9 then
        player_clocked = "Rory"
    elseif signal == 6 then
        player_clocked= "Jack"
    else
        return playerTimes, player_clock_tracker
    end

    -- debug
    --print("Player activity detected: " .. player_clocked)
    if is_player_clocked_in(player_clocked) then
        --print(player_clocked .. "is clockeded in")
        player_current_clock_state = true
    else
        --print(player_clocked .. "is clocked out")
        player_current_clock_state = false
    end

    -- change players clock state
    clock_player(not player_current_clock_state, player_clocked)
    -- update player times
    save_data()

    return playerTimes, player_clock_tracker
end

return player_timer_util