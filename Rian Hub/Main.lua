--Rain Hub
--服务器分类执行(自愿漏库)

local function RainHub(message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Rain HUB",
        Text = message,
        Duration = 5,
        Icon = "rbxassetid://121037083128250" 
    })
end
local GameDetector = {}

GameDetector.GameList = {
    [7239319209] = {
        name = "ohio",
        version = "1.0",
        script = function()
            RainHUB("我正在做 只是不会很强")
        end
    },
    
    [79546208627805] = {
        name = "99夜大厅",
        version = "1.2",
        script = function()
            RainHub("当前服务器为:99夜\n请进入组队后再执行此脚本")
        end
    },
    
    [126509999114328] = {
        name = "99夜",
        version = "1.1",
        script = function()
 loadstring(game:HttpGet("https://raw.githubusercontent.com/ParKe001/ParKe/refs/heads/main/Rian%20Hub/99night"))()        end
    }
}

function GameDetector:Start()
    local currentGameId = game.PlaceId
    print(currentGameId)
    
    local gameConfig = self.GameList[currentGameId]
    
    if gameConfig then
        
        local success, errorMsg = pcall(gameConfig.script)
        if not success then
        else
        end
    else
        RainHub("暂时未添加这个服务器")
    end
end

GameDetector:Start()
