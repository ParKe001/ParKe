screenGui=Instance.new("ScreenGui")
screenGui.Name="ShootButtonGui"
screenGui.ResetOnSpawn=false
screenGui.Parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

button=Instance.new("TextButton")
button.Name="ShootButton"
button.Size=UDim2.new(0,56,0,56)
button.Position=UDim2.new(1,-270,0,8)
button.BackgroundColor3=Color3.fromRGB(25,25,25)
button.TextColor3=Color3.fromRGB(255,255,255)
button.Text="shoot"
button.Font=Enum.Font.GothamBold
button.TextSize=13
button.AutoButtonColor=false
button.BorderSizePixel=0
button.Parent=screenGui

corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,10)
corner.Parent=button

gradient=Instance.new("UIGradient")
gradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromRGB(60,60,60)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(20,20,20))
}
gradient.Rotation=90
gradient.Parent=button

stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(0,0,0)
stroke.Thickness=1.5
stroke.Parent=button

button.MouseButton1Down:Connect(function()
button.BackgroundColor3=Color3.fromRGB(70,70,70)
end
)
button.MouseButton1Up:Connect(function()
button.BackgroundColor3=Color3.fromRGB(25,25,25)
end
)

panel=Instance.new("Frame")
panel.Name="ControlPanel"
panel.Size=UDim2.new(0,90,0,56)
panel.Position=UDim2.new(1,-200,0,8)
panel.BackgroundColor3=Color3.fromRGB(25,25,25)
panel.BorderSizePixel=0
panel.Parent=screenGui

panelCorner=Instance.new("UICorner")
panelCorner.CornerRadius=UDim.new(0,10)
panelCorner.Parent=panel

moveBtn=Instance.new("TextButton")
moveBtn.Name="MoveToggle"
moveBtn.Size=UDim2.new(0,38,0,20)
moveBtn.Position=UDim2.new(0,6,0,8)
moveBtn.BackgroundColor3=Color3.fromRGB(60,60,60)
moveBtn.TextColor3=Color3.fromRGB(255,255,255)
moveBtn.Text="move"
moveBtn.Font=Enum.Font.GothamBold
moveBtn.TextSize=11
moveBtn.AutoButtonColor=false
moveBtn.BorderSizePixel=0
moveBtn.Parent=panel

moveCorner=Instance.new("UICorner")
moveCorner.CornerRadius=UDim.new(0,6)
moveCorner.Parent=moveBtn

lockBtn=Instance.new("TextButton")
lockBtn.Name="LockToggle"
lockBtn.Size=UDim2.new(0,38,0,20)
lockBtn.Position=UDim2.new(0,46,0,8)
lockBtn.BackgroundColor3=Color3.fromRGB(60,60,60)
lockBtn.TextColor3=Color3.fromRGB(255,255,255)
lockBtn.Text="lock"
lockBtn.Font=Enum.Font.GothamBold
lockBtn.TextSize=11
lockBtn.AutoButtonColor=false
lockBtn.BorderSizePixel=0
lockBtn.Parent=panel

lockCorner=Instance.new("UICorner")
lockCorner.CornerRadius=UDim.new(0,6)
lockCorner.Parent=lockBtn

moveEnabled=false
locked=false

function updateMoveColor()
if moveEnabled then
moveBtn.BackgroundColor3=Color3.fromRGB(0,140,255)
else
moveBtn.BackgroundColor3=Color3.fromRGB(60,60,60)
end
end

function updateLockColor()
if locked then
lockBtn.BackgroundColor3=Color3.fromRGB(255,80,80)
else
lockBtn.BackgroundColor3=Color3.fromRGB(60,60,60)
end
end

moveBtn.MouseButton1Click:Connect(function()
moveEnabled=not moveEnabled
if moveEnabled then locked=false updateLockColor() end
updateMoveColor()
end
)

lockBtn.MouseButton1Click:Connect(function()
locked=not locked
if locked then moveEnabled=false updateMoveColor() end
updateLockColor()
end
)

dragging=false
dragStart=nil
startPos=nil
activeFrame=nil

function beginDrag(frame,input)
if locked or not moveEnabled then return end
dragging=true
activeFrame=frame
dragStart=input.Position
startPos=frame.Position
end

button.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
beginDrag(button,input)
end
end
)

panel.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
beginDrag(panel,input)
end
end
)

UserInputService=game:GetService("UserInputService")

UserInputService.InputChanged:Connect(function(input)
if not dragging or not activeFrame then return end
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement then
delta=input.Position-dragStart
activeFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
end
end
)

UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=false
activeFrame=nil
end
end)

Players=game:GetService("Players")
RunService=game:GetService("RunService")
Stats=game:GetService("Stats")
LocalPlayer=Players.LocalPlayer

CFG={
range=600,
teamSafe=false,
aimHead=true,
autoShoot=true,
shootDelay=0.5,
autoThrow=true,
throwDelay=0.9,
autoStab=true,
stabRange=14,
bulletSpeed=900,
leadTime=1.0,
leadEnabled=true,
throwLead=1.0,
pingComp=true,
}

lastShot,lastThrow=0,0
now=tick

function ch()return LocalPlayer.Character
end

function myRoot()
c=ch()
return c and c:FindFirstChild("HumanoidRootPart")
end

function alive(p)
c=p.Character
if not c then return false
end
h=c:FindFirstChildOfClass("Humanoid")
return h and h.Health>0
end

function isEnemy(p)
if p==LocalPlayer or not alive(p)then return false
end
if CFG.teamSafe and p.Team and p.Team==LocalPlayer.Team then return false
end
return true
end

PARTS={"Head","UpperTorso","LowerTorso","Torso","HumanoidRootPart"}

function partsOf(c)
t={}
if not c then return t
end
for _,n in ipairs(PARTS)do
p=c:FindFirstChild(n)
if p and p:IsA("BasePart")then t[#t+1]=p
end
end
return t
end

function centerOf(c)
ps=partsOf(c)
if#ps==0 then return nil
end
v=Vector3.zero
for _,p in ipairs(ps)do v=v+p.Position
end
return v/#ps
end

function pingScale()
if not CFG.pingComp then return 1
end
ok,ping=pcall(function()
return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end
)
if ok and ping and ping>0 then
return 1+math.clamp(ping/1000,0,0.5)
end
return 1
end

function getKnife()
c=ch()
return c and c:FindFirstChild("Knife")
end

function getGun()
c=ch()
return c and c:FindFirstChild("Gun")
end

function knifeEv()
k=getKnife()
return k and k:FindFirstChild("Events")
end

function throwRemote()
e=knifeEv()
return e and e:FindFirstChild("KnifeThrown")
end

function shootRemote()
g=getGun()
return g and g:FindFirstChild("Shoot")
end

function gunOrigin()
r=myRoot()
if not r then return nil
end
att=r:FindFirstChild("GunRaycastAttachment")
if att then return att.WorldCFrame
end
g=getGun()
if g then
h=g:FindFirstChild("Handle")or g:FindFirstChild("Gun")or g:FindFirstChild("Barrel")
if h and h:IsA("BasePart")then return h.CFrame
end
end
return r.CFrame
end

function predPart(part,fromPos,coeff)
if not CFG.leadEnabled then return part.Position
end
v=part.AssemblyLinearVelocity
if v.Magnitude<1 then return part.Position
end
p0=part.Position
p=p0
scale=pingScale()
for _=1,3 do
t=(p-fromPos).Magnitude/CFG.bulletSpeed
p=p0+v*t*coeff*scale
end
return p
end

function pickTargetPart(c,fromPos)
ps=partsOf(c)
if#ps==0 then return nil
end
if CFG.aimHead then
head=c:FindFirstChild("Head")
if head and head:IsA("BasePart")then return head
end
end
best,bestD=nil,math.huge
for _,p in ipairs(ps)do
d=(p.Position-fromPos).Magnitude
if d<bestD then best,bestD=p,d
end
end
return best or ps[1]
end

function doShoot(plr)
remote=shootRemote()
origin=gunOrigin()
if not(remote and origin)then return
end
if not plr.Character then return
end
r=myRoot()
if not r then return
end
ctr=centerOf(plr.Character)
if ctr and(ctr-r.Position).Magnitude>CFG.range then return
end
part=pickTargetPart(plr.Character,origin.Position)
if not part then return
end
aimPos=predPart(part,origin.Position,CFG.leadTime)
fromCF=CFrame.lookAt(origin.Position,aimPos)
goalCF=CFrame.new(aimPos)
pcall(function()remote:FireServer(fromCF,goalCF)
end
)
end

function doThrow(plr)
remote=throwRemote()
if not remote then return
end
knife=getKnife()
handle=knife and(knife:FindFirstChild("Handle")or knife:FindFirstChild("Blade"))
r=myRoot()
fromCF=(handle and handle.CFrame)or(r and r.CFrame)
if not fromCF or not plr.Character then return
end
ctr=centerOf(plr.Character)
if r and ctr and(ctr-r.Position).Magnitude>CFG.range then return
end
part=pickTargetPart(plr.Character,fromCF.Position)
if not part then return
end
aimPos=predPart(part,fromCF.Position,CFG.throwLead)
startCF=CFrame.lookAt(fromCF.Position,aimPos)
goalCF=CFrame.new(aimPos)
pcall(function()remote:FireServer(startCF,goalCF)
end
)
end

STAB={"HumanoidRootPart","UpperTorso","LowerTorso","Torso","Head"}

function doStab(plr)
ev=knifeEv()
tc=plr and plr.Character
if not(ev and tc)then return
end
ht=ev:FindFirstChild("HandleTouched")
ks=ev:FindFirstChild("KnifeStabbed")
if ks then pcall(function()ks:FireServer()
end
)
end
if ht then
for _,n in ipairs(STAB)do
part=tc:FindFirstChild(n)
if part then
pcall(function()ht:FireServer(part)
end
)
break
end
end
end
end

function nearestEnemy()
r=myRoot()
if not r then return nil
end
best,bestD=nil,math.huge
for _,p in ipairs(Players:GetPlayers())do
if isEnemy(p)then
ctr=centerOf(p.Character)
if ctr then
d=(ctr-r.Position).Magnitude
if d<bestD and d<=CFG.range then best,bestD=p,d
end
end
end
end
return best
end

function executeOnce()
c=ch()
if not c then return
end
r=myRoot()
if not r then return
end
tgt=nearestEnemy()
if not tgt then return
end
ctr=centerOf(tgt.Character)
dist=ctr and(ctr-r.Position).Magnitude or math.huge
if CFG.autoShoot and getGun()and now()-lastShot>=CFG.shootDelay then
lastShot=now()
doShoot(tgt)
end
if getKnife()then
if dist<=CFG.stabRange and CFG.autoStab then
doStab(tgt)
elseif
CFG.autoThrow and now()-lastThrow>=CFG.throwDelay then
lastThrow=now()
doThrow(tgt)
end
end
end

button.MouseButton1Click:Connect(function()
if dragging then return end
button.Text="shooting..."
task.wait(0.1)
button.Text="shoot"
pcall(executeOnce)
end
)
