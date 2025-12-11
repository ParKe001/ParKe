-- Rain Hub
-- 加载器

local function RainHub1(message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Rain Hub",
        Text = message,
        Duration = 5,
        Icon = "rbxassetid://121037083128250" 
    })
end

local RainHub2 = {}

RainHub2.RainHub3 = {
    [7239319209] = {
        name = "ohio",
        version = "1.0",
        script = function()
            RainHub1("我正在做 只是不会很强")
        end
    },
    
    [79546208627805] = {
        name = "99夜大厅",
        version = "1.2",
        script = function()
            RainHub1("当前服务器为:99夜\n请进入组队后再执行此脚本")
        end
    },
    
    [126509999114328] = {
        name = "99夜",
        version = "1.1",
        script = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ParKe001/ParKe/refs/heads/main/Rian%20Hub/99night"))()
        end
    },
    
    [3101667897] = { 
        name = "极速传奇",
        version = "1.1",
        script = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ParKe001/ParKe/refs/heads/main/Rian%20Hub/Jisulegend"))()
        end
    },
    
    [106487781999308] = { 
        name = "凌晨3点后大厅",
        version = "1.1",
        script = function()
            RainHub1("当前服务器为:凌晨3点后\n请进入游戏后再执行此脚本")
        end
    },
    
    [138103330716004] = { 
        name = "凌晨3点后",
        version = "1.1",
        script = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ParKe001/ParKe/refs/heads/main/Rian%20Hub/After%203%20a.m."))()
        end
    }
}

function RainHub2:RainHub4()
    local RainHub5 = game.PlaceId
    print(RainHub5)
    
    local RainHub6 = self.RainHub3[RainHub5]
    
    if RainHub6 then
        local RainHub7, RainHub8 = pcall(RainHub6.script)
        if not RainHub7 then
        end
    else
        RainHub1("暂时未添加这个服务器")
    end
end

RainHub2:RainHub4()
