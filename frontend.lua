local player_timer_util = require("player_timer")
local term = require("term")
local task = require("task")

print("Starting Player Timer...")
player_timer_util.init()
while true do
    local player_table = player_timer_util.PlayerWatchLoop()
    print("Player Table:")
    for name, time in pairs(player_table) do
        print(name .. " = " .. time)
    end
    print("------------------------------")
    task.wait(1)
end