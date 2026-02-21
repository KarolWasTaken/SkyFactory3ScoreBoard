local event = require("event")

local player_timer_util = {}
local playerTimes = {}

function player_timer_util.PlayerWatchLoop()
  -- watch for player joins
    local _, _, player, message = event.pull("chat_message")

    local joinedPlayer = message:match("^(.+) joined the game$")
    if joinedPlayer then
        print(joinedPlayer .. " has connected!")
        PlayerJoined(joinedPlayer)
    end

  -- increment ticks for all players
    for name, time in pairs(playerTimes) do
        playerTimes[name] = time + 1
    end

    print("Returning player times...")
    return playerTimes
end

function PlayerJoined(player_joined)
    -- read all of player_time.txt and store it in a table
    local file = io.open("player_time.txt", "r")
    if file then
        for line in file:lines() do
            local name, time = string.match(line, "^(%w+)=(%d+)$")

            if name and time then
                playerTimes[name] = tonumber(time)
            end
        end
        file:close()
    end

    -- check if player name is in player_time.txt, if not add it with time 0
    if playerTimes[player_joined] then
        print(player_joined .. " has played for " .. playerTimes[player_joined] .. " seconds.")
    else
        playerTimes[player_joined] = 0
        local file = io.open("player_time.txt", "a")
        file:write(player_joined .. "=" .. 0 .. "\n")
        file:close()
    end
end

return player_timer_util