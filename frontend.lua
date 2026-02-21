local player_timer_util = require("player_timer")
local term = require("term")

print("Starting Player Timer...")
while true do
    local player_table = player_timer_util.PlayerWatchLoop()
    print("Player Table:")
    for name, time in pairs(player_table) do
        print(name .. " = " .. time)
    end
    print("------------------------------")
end