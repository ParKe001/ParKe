local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local BTN = 56
local GAP = 8
local ROW_Y = 8
local P_SH  = UDim2.new(1, -(270), 0, ROW_Y)
local P_ESP = UDim2.new(1, -(270 - (BTN + GAP)), 0, ROW_Y)
local P_JMP = UDim2.new(1, -(270 - 2*(BTN + GAP)), 0, ROW_Y)
local P_PANEL = UDim2.new(1, -(270), 0, ROW_Y + BTN + GAP)

local C4 = {
    cooldown = 20,
    lastUse  = 0,
    busy     = false,
}

local plr = LP
local char = plr.Character or plr.CharacterAdded:Wait()
local hum  = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

plr.CharacterAdded:Connect(function(ch)
    char = ch
    hum  = ch:WaitForChild("Humanoid")
    root = ch:WaitForChild("HumanoidRootPart")
end)

local function getC4()
    if plr.Backpack then
        for _, v in ipairs(plr.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.Name:lower():find("bomb") or v.Name:lower():find("c4")) then
                return v
            end
        end
    end
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") and (v.Name:lower():find("bomb") or v.Name:lower():find("c4")) then
                return v
            end
        end
    end
    return nil
end

local function hasC4()
    return getC4() ~= nil
end

local function doC4Jump()
    local tool = getC4()
    if not tool then return end

    hum.UseJumpPower = true
    hum.JumpPower = 50

    if tool.Parent ~= char then
        hum:EquipTool(tool)
        task.wait(0.2)
    end

    local remote = tool:FindFirstChild("Remote")
        or tool:FindFirstChild("Place")
        or tool:FindFirstChild("Throw")
        or tool:FindFirstChild("Activate")
    if not remote then
        pcall(function() tool:Activate() end)
    end

    root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    repeat task.wait() until hum:GetState() == Enum.HumanoidStateType.Freefall
    repeat task.wait() until root.AssemblyLinearVelocity.Y <= 5

    if remote then
        pcall(function() remote:FireServer(root.CFrame, 50) end)
    end

    repeat task.wait() until root.AssemblyLinearVelocity.Y < -5

    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end

local RHg = {
    enabled     = false,
    refreshRate = 0.25,
    fillAlpha   = 0.6,
    outlineAlpha = 1,
    showSelf    = false,
    color = {
        sheriff  = Color3.fromRGB(40, 110, 255),
        murderer = Color3.fromRGB(230, 40, 40),
        innocent = Color3.fromRGB(40, 200, 90),
    },
}

local function ali(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function car(p, tnm)
    if not p then return false end
    local bp = p:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild(tnm) then return true end
    local c = p.Character
    if c and c:FindFirstChild(tnm) then return true end
    return false
end

local function isM(p)
    if p == LP or not ali(p) then return false end
    return car(p, "Knife")
end

local function isS(p)
    if p == LP or not ali(p) then return false end
    return car(p, "Gun")
end

local function rol(p)
    if isM(p) then return "murderer" end
    if isS(p) then return "sheriff" end
    return "innocent"
end

local function col(p)
    return RHg.color[rol(p)]
end

local hls = {}

local function ghl(mdl)
    if not mdl then return nil end
    local hl = hls[mdl]
    if hl and hl.Parent == mdl then return hl end
    local old = mdl:FindFirstChild("__RoleHL")
    if old then old:Destroy() end
    local h = Instance.new("Highlight")
    h.Name = "__RoleHL"
    h.FillTransparency = 1 - RHg.fillAlpha
    h.OutlineTransparency = 1 - RHg.outlineAlpha
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = mdl
    h.Parent = mdl
    hls[mdl] = h
    return h
end

local function rhl(mdl)
    local hl = hls[mdl]
    if hl then pcall(function() hl:Destroy() end) end
    hls[mdl] = nil
end

local function pnt(p)
    if not RHg.enabled then return end
    if p == LP and not RHg.showSelf then return end
    local c = p.Character
    if not c then return end
    local cl = col(p)
    local hl = ghl(c)
    if hl then
        hl.FillColor = cl
        hl.OutlineColor = cl
    end
end

local function rfa()
    if not RHg.enabled then
        for mdl in pairs(hls) do rhl(mdl) end
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP or RHg.showSelf then
            if p.Character then pnt(p) end
        end
    end
    for mdl in pairs(hls) do
        if not mdl.Parent then rhl(mdl) end
    end
end

local function bnd(p)
    if p == LP and not RHg.showSelf then return end
    p.CharacterAdded:Connect(function()
        task.wait(0.15)
        pnt(p)
    end)
    task.spawn(function()
        while p.Parent do
            local bp = p:FindFirstChildOfClass("Backpack")
            if bp then break end
            task.wait(0.2)
        end
        local bp = p:FindFirstChildOfClass("Backpack")
        if bp then
            bp.ChildAdded:Connect(function() task.wait(0.05); pnt(p) end)
            bp.ChildRemoved:Connect(function() task.wait(0.05); pnt(p) end)
        end
        local c = p.Character
        if c then
            c.ChildAdded:Connect(function() task.wait(0.05); pnt(p) end)
            c.ChildRemoved:Connect(function() task.wait(0.05); pnt(p) end)
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do bnd(p) end
Players.PlayerAdded:Connect(bnd)
Players.PlayerRemoving:Connect(function(p)
    if p.Character then rhl(p.Character) end
end)

task.spawn(function()
    while task.wait(RHg.refreshRate) do
        rfa()
    end
end)

_G.MM2Roles = {
    isMurderer = isM,
    isSheriff  = isS,
    roleOf     = rol,
    colorOf    = col,
    refresh    = rfa,
    RH         = RHg,
}

local gui = Instance.new("ScreenGui")
gui.Name = "UnifiedGui"
gui.ResetOnSpawn = false
gui.Parent = PG

local function makeBtn(name, pos, label)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, BTN, 0, BTN)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = label
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.Parent = gui

    local cr = Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, 10)
    cr.Parent = b

    local gr = Instance.new("UIGradient")
    gr.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
    }
    gr.Rotation = 90
    gr.Parent = b

    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(0, 0, 0)
    st.Thickness = 1.5
    st.Parent = b

    return b
end

local shootBtn = makeBtn("ShootButton", P_SH, "shoot")
local espBtn = makeBtn("EspButton", P_ESP, "esp")
local jumpBtn = makeBtn("JumpButton", P_JMP, "Jump")

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -12, 0, 5)
barBg.Position = UDim2.new(0, 6, 1, -9)
barBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
barBg.BorderSizePixel = 0
barBg.Parent = jumpBtn
local barBgC = Instance.new("UICorner")
barBgC.CornerRadius = UDim.new(1, 0)
barBgC.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
local barFillC = Instance.new("UICorner")
barFillC.CornerRadius = UDim.new(1, 0)
barFillC.Parent = barFill

local panel = Instance.new("Frame")
panel.Name = "ControlPanel"
panel.Size = UDim2.new(0, 90, 0, 36)
panel.Position = P_PANEL
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.BorderSizePixel = 0
panel.Parent = gui
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

local moveBtn = Instance.new("TextButton")
moveBtn.Name = "MoveToggle"
moveBtn.Size = UDim2.new(0, 38, 0, 20)
moveBtn.Position = UDim2.new(0, 6, 0.5, -10)
moveBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
moveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
moveBtn.Text = "move"
moveBtn.Font = Enum.Font.GothamBold
moveBtn.TextSize = 11
moveBtn.AutoButtonColor = false
moveBtn.BorderSizePixel = 0
moveBtn.Parent = panel
local moveCorner = Instance.new("UICorner")
moveCorner.CornerRadius = UDim.new(0, 6)
moveCorner.Parent = moveBtn

local lockBtn = Instance.new("TextButton")
lockBtn.Name = "LockToggle"
lockBtn.Size = UDim2.new(0, 38, 0, 20)
lockBtn.Position = UDim2.new(0, 46, 0.5, -10)
lockBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lockBtn.Text = "lock"
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 11
lockBtn.AutoButtonColor = false
lockBtn.BorderSizePixel = 0
lockBtn.Parent = panel
local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(0, 6)
lockCorner.Parent = lockBtn

local moveEnabled, locked = false, false

local function updateMoveColor()
    moveBtn.BackgroundColor3 = moveEnabled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(60, 60, 60)
end
local function updateLockColor()
    lockBtn.BackgroundColor3 = locked and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(60, 60, 60)
end

moveBtn.MouseButton1Click:Connect(function()
    moveEnabled = not moveEnabled
    if moveEnabled then locked = false; updateLockColor() end
    updateMoveColor()
end)

lockBtn.MouseButton1Click:Connect(function()
    locked = not locked
    if locked then moveEnabled = false; updateMoveColor() end
    updateLockColor()
end)

local dragging, dragStart, startPos, activeFrame = false, nil, nil, nil

local function beginDrag(frame, input)
    if locked or not moveEnabled then return end
    dragging = true
    activeFrame = frame
    dragStart = input.Position
    startPos = frame.Position
end

for _, el in ipairs({ shootBtn, espBtn, jumpBtn, panel }) do
    el.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            beginDrag(el, input)
        end
    end)
end

UIS.InputChanged:Connect(function(input)
    if not dragging or not activeFrame then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        activeFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        activeFrame = nil
    end
end)

local CFG = {
    range       = 600,
    teamSafe    = false,
    aimHead     = true,
    autoShoot   = true,
    shootDelay  = 0.5,
    autoThrow   = true,
    throwDelay  = 0.9,
    autoStab    = true,
    stabRange   = 14,
    bulletSpeed = 900,
    leadTime    = 1.0,
    leadEnabled = true,
    throwLead   = 1.0,
    pingComp    = true,
}

local lastShot, lastThrow = 0, 0
local now = tick

local function ch() return LP.Character end
local function myRoot()
    local c = ch()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function alive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function isEnemy(p)
    if p == LP or not alive(p) then return false end
    if CFG.teamSafe and p.Team and p.Team == LP.Team then return false end
    return true
end

local function isGunTarget(p)
    if p == LP or not alive(p) then return false end
    if _G.MM2Roles and _G.MM2Roles.isMurderer then
        return _G.MM2Roles.isMurderer(p)
    end
    local c = p.Character
    if not c then return false end
    local bp = p:FindFirstChild("Backpack")
    if (c and c:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife")) then
        return true
    end
    return false
end

local PARTS = { "Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart" }

local function partsOf(c)
    local t = {}
    if not c then return t end
    for _, n in ipairs(PARTS) do
        local p = c:FindFirstChild(n)
        if p and p:IsA("BasePart") then t[#t + 1] = p end
    end
    return t
end

local function centerOf(c)
    local ps = partsOf(c)
    if #ps == 0 then return nil end
    local v = Vector3.zero
    for _, p in ipairs(ps) do v = v + p.Position end
    return v / #ps
end

local function pingScale()
    if not CFG.pingComp then return 1 end
    local ok, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and ping and ping > 0 then
        return 1 + math.clamp(ping / 1000, 0, 0.5)
    end
    return 1
end

local function getKnife() local c = ch(); return c and c:FindFirstChild("Knife") end
local function getGun()   local c = ch(); return c and c:FindFirstChild("Gun") end
local function knifeEv()  local k = getKnife(); return k and k:FindFirstChild("Events") end
local function throwRemote()
    local e = knifeEv()
    return e and e:FindFirstChild("KnifeThrown")
end
local function shootRemote()
    local g = getGun()
    return g and g:FindFirstChild("Shoot")
end

local function gunOrigin()
    local r = myRoot()
    if not r then return nil end
    local att = r:FindFirstChild("GunRaycastAttachment")
    if att then return att.WorldCFrame end
    local g = getGun()
    if g then
        local h = g:FindFirstChild("Handle") or g:FindFirstChild("Gun") or g:FindFirstChild("Barrel")
        if h and h:IsA("BasePart") then return h.CFrame end
    end
    return r.CFrame
end

local function predPart(part, fromPos, coeff)
    if not CFG.leadEnabled then return part.Position end
    local v = part.AssemblyLinearVelocity
    if v.Magnitude < 1 then return part.Position end
    local p0 = part.Position
    local p = p0
    local scale = pingScale()
    for _ = 1, 3 do
        local t = (p - fromPos).Magnitude / CFG.bulletSpeed
        p = p0 + v * t * coeff * scale
    end
    return p
end

local function pickTargetPart(c, fromPos)
    local ps = partsOf(c)
    if #ps == 0 then return nil end
    if CFG.aimHead then
        local head = c:FindFirstChild("Head")
        if head and head:IsA("BasePart") then return head end
    end
    local best, bestD = nil, math.huge
    for _, p in ipairs(ps) do
        local d = (p.Position - fromPos).Magnitude
        if d < bestD then best, bestD = p, d end
    end
    return best or ps[1]
end

local function doShoot(plr)
    local remote = shootRemote()
    local origin = gunOrigin()
    if not (remote and origin) then return end
    if not plr.Character then return end
    local r = myRoot()
    if not r then return end
    local ctr = centerOf(plr.Character)
    if ctr and (ctr - r.Position).Magnitude > CFG.range then return end
    local part = pickTargetPart(plr.Character, origin.Position)
    if not part then return end
    local aimPos = predPart(part, origin.Position, CFG.leadTime)
    local fromCF = CFrame.lookAt(origin.Position, aimPos)
    local goalCF = CFrame.new(aimPos)

    local ok = pcall(function() remote:FireServer(fromCF, goalCF) end)
    if not ok then
        ok = pcall(function() remote:FireServer(goalCF) end)
    end
    if not ok then
        pcall(function() remote:FireServer(fromCF, aimPos) end)
    end
end

local function doThrow(plr)
    local remote = throwRemote()
    if not remote then return end
    local knife = getKnife()
    local handle = knife and (knife:FindFirstChild("Handle") or knife:FindFirstChild("Blade"))
    local r = myRoot()
    local fromCF = (handle and handle.CFrame) or (r and r.CFrame)
    if not fromCF or not plr.Character then return end
    local ctr = centerOf(plr.Character)
    if r and ctr and (ctr - r.Position).Magnitude > CFG.range then return end
    local part = pickTargetPart(plr.Character, fromCF.Position)
    if not part then return end
    local aimPos = predPart(part, fromCF.Position, CFG.throwLead)
    local startCF = CFrame.lookAt(fromCF.Position, aimPos)
    local goalCF = CFrame.new(aimPos)
    pcall(function() remote:FireServer(startCF, goalCF) end)
end

local STAB = { "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso", "Head" }

local function doStab(plr)
    local ev = knifeEv()
    local tc = plr and plr.Character
    if not (ev and tc) then return end
    local ht = ev:FindFirstChild("HandleTouched")
    local ks = ev:FindFirstChild("KnifeStabbed")
    if ks then
        pcall(function() ks:FireServer() end)
    end
    if ht then
        for _, n in ipairs(STAB) do
            local part = tc:FindFirstChild(n)
            if part then
                pcall(function() ht:FireServer(part) end)
                break
            end
        end
    end
end

local function nearestEnemy()
    local r = myRoot()
    if not r then return nil end
    local best, bestD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) then
            local ctr = centerOf(p.Character)
            if ctr then
                local d = (ctr - r.Position).Magnitude
                if d < bestD and d <= CFG.range then best, bestD = p, d end
            end
        end
    end
    return best
end

local function nearestGunTarget()
    local r = myRoot()
    if not r then return nil end
    local best, bestD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if isGunTarget(p) then
            local ctr = centerOf(p.Character)
            if ctr then
                local d = (ctr - r.Position).Magnitude
                if d < bestD and d <= CFG.range then best, bestD = p, d end
            end
        end
    end
    return best
end

local function executeOnce()
    local c = ch()
    if not c then return end
    local r = myRoot()
    if not r then return end
    if CFG.autoShoot and getGun() and now() - lastShot >= CFG.shootDelay then
        local gt = nearestGunTarget()
        if gt then
            lastShot = now()
            doShoot(gt)
        end
    end
    if getKnife() then
        local et = nearestEnemy()
        if et then
            local ctr = centerOf(et.Character)
            local dist = ctr and (ctr - r.Position).Magnitude or math.huge
            if dist <= CFG.stabRange and CFG.autoStab then
                doStab(et)
            elseif CFG.autoThrow and now() - lastThrow >= CFG.throwDelay then
                lastThrow = now()
                doThrow(et)
            end
        end
    end
end

shootBtn.MouseButton1Down:Connect(function()
    shootBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end)
shootBtn.MouseButton1Up:Connect(function()
    shootBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
end)
shootBtn.MouseButton1Click:Connect(function()
    if dragging then return end
    shootBtn.Text = "shooting..."
    task.wait(0.1)
    shootBtn.Text = "shoot"
    pcall(executeOnce)
end)

espBtn.MouseButton1Click:Connect(function()
    if dragging then return end
    RHg.enabled = not RHg.enabled
    espBtn.BackgroundColor3 = RHg.enabled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(60, 60, 60)
    rfa()
end)

jumpBtn.MouseButton1Down:Connect(function()
    jumpBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end)
jumpBtn.MouseButton1Up:Connect(function()
    if now() - C4.lastUse >= C4.cooldown then
        jumpBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        local t = tick()
        local elapsed = t - C4.lastUse
        if elapsed >= C4.cooldown then
            barFill.Size = UDim2.new(1, 0, 1, 0)
            barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            jumpBtn.Text = "Jump"
            if not hasC4() then
                jumpBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
            else
                jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        else
            local x = elapsed / C4.cooldown
            barFill.Size = UDim2.new(x, 0, 1, 0)
            barFill.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
            jumpBtn.Text = string.format("%.0f", C4.cooldown - elapsed)
            jumpBtn.TextColor3 = hasC4() and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
        end
    end
end)

jumpBtn.MouseButton1Click:Connect(function()
    if dragging then return end
    if C4.busy then return end
    if now() - C4.lastUse < C4.cooldown then return end
    if not getC4() then return end
    C4.busy = true
    C4.lastUse = now()
    pcall(doC4Jump)
    C4.busy = false
end)

_G.UnifiedGuiRef = gui
