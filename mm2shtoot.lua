do
plr=game:GetService("Players")
a=plr.LocalPlayer
b=a.Character or a.CharacterAdded:Wait()
c=b:WaitForChild("Humanoid")
d=b:WaitForChild("HumanoidRootPart")
e=20
f=0
g=false
function h()
for _,v in ipairs(a.Backpack:GetChildren())do
if v:IsA("Tool")and(v.Name:lower():find("bomb")or v.Name:lower():find("c4"))then
return v
end
end
for _,v in ipairs(b:GetChildren())do
if v:IsA("Tool")and(v.Name:lower():find("bomb")or v.Name:lower():find("c4"))then
return v
end
end
return nil
end
function i()
j=h()
if not j then
return
end
c.UseJumpPower=true
c.JumpPower=50
if j.Parent~=b then
c:EquipTool(j)
task.wait(0.2)
end
k=j:WaitForChild("Remote")
c:ChangeState(Enum.HumanoidStateType.Jumping)
repeat task.wait()
until
c:GetState()==Enum.HumanoidStateType.Freefall
repeat task.wait()
until
d.AssemblyLinearVelocity.Y<=5
k:FireServer(d.CFrame,50)
repeat task.wait()
until
d.AssemblyLinearVelocity.Y<-5
c:ChangeState(Enum.HumanoidStateType.Jumping)
end
l=Instance.new("ScreenGui")
l.Name="BombJumpGui"
l.ResetOnSpawn=false
l.Parent=a:WaitForChild("PlayerGui")
m=Instance.new("TextButton")
m.Size=UDim2.new(0,56,0,56)
m.Position=UDim2.new(1,-76,0.5,-98)
m.BackgroundColor3=Color3.fromRGB(25,25,25)
m.TextColor3=Color3.fromRGB(255,255,255)
m.Text="Jump"
m.Font=Enum.Font.GothamBold
m.TextSize=13
m.AutoButtonColor=false
m.BorderSizePixel=0
m.Parent=l
n=Instance.new("UICorner")
n.CornerRadius=UDim.new(0,10)
n.Parent=m
o=Instance.new("UIGradient")
o.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromRGB(60,60,60)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(20,20,20))
}
o.Rotation=90
o.Parent=m
p=Instance.new("UIStroke")
p.Color=Color3.fromRGB(0,0,0)
p.Thickness=1.5
p.Parent=m
q=Instance.new("Frame")
q.Size=UDim2.new(1,-12,0,5)
q.Position=UDim2.new(0,6,1,-9)
q.BackgroundColor3=Color3.fromRGB(15,15,15)
q.BorderSizePixel=0
q.Parent=m
r=Instance.new("UICorner")
r.CornerRadius=UDim.new(1,0)
r.Parent=q
s=Instance.new("Frame")
s.Size=UDim2.new(0,0,1,0)
s.BackgroundColor3=Color3.fromRGB(0,200,100)
s.BorderSizePixel=0
s.Parent=q
t=Instance.new("UICorner")
t.CornerRadius=UDim.new(1,0)
t.Parent=s
function u()
while true do
task.wait(0.05)
v=tick()
w=v-f
if w>=e then
s.Size=UDim2.new(1,0,1,0)
s.BackgroundColor3=Color3.fromRGB(0,200,100)
m.Text="Jump"
m.BackgroundColor3=Color3.fromRGB(25,25,25)
else
x=w/e
s.Size=UDim2.new(x,0,1,0)
s.BackgroundColor3=Color3.fromRGB(200,150,0)
m.Text=string.format("%.0f",e-w)
m.BackgroundColor3=Color3.fromRGB(60,50,30)
end
end
end
task.spawn(u)
m.MouseButton1Down:Connect(function()
m.BackgroundColor3=Color3.fromRGB(70,70,70)
end
)
m.MouseButton1Up:Connect(function()
if tick()-f>=e then
m.BackgroundColor3=Color3.fromRGB(25,25,25)
end
end
)
m.MouseButton1Click:Connect(function()
if g then return
end
if tick()-f<e then
return
end
if not h()then
return
end
g=true
f=tick()
y,err=pcall(i)
g=false
end
)
end
do
Ply=game:GetService("Players")
Run=game:GetService("RunService")
Lcl=Ply.LocalPlayer
RHg={enabled=true,refreshRate=0.25,fillAlpha=0.6,outlineAlpha=1,showSelf=false,color={sheriff=Color3.fromRGB(40,110,255),murderer=Color3.fromRGB(230,40,40),innocent=Color3.fromRGB(40,200,90)}}
function ali(p)
c=p.Character
if not c then return false end
h=c:FindFirstChildOfClass("Humanoid")
return h and h.Health>0
end
function car(p,tnm)
if not p then return false end
bp=p:FindFirstChild("Backpack")
if bp and bp:FindFirstChild(tnm) then return true end
c=p.Character
if c and c:FindFirstChild(tnm) then return true end
return false
end
function isM(p)
if p==Lcl or not ali(p) then return false end
return car(p,"Knife")
end
function isS(p)
if p==Lcl or not ali(p) then return false end
return car(p,"Gun")
end
function rol(p)
if isM(p) then return "murderer" end
if isS(p) then return "sheriff" end
return "innocent"
end
function col(p)
return RHg.color[rol(p)]
end
hls={}
function ghl(mdl)
if not mdl then return nil end
hl=hls[mdl]
if hl and hl.Parent==mdl then return hl end
old=mdl:FindFirstChild("__RoleHL")
if old then old:Destroy() end
h=Instance.new("Highlight")
h.Name="__RoleHL"
h.FillTransparency=1-RHg.fillAlpha
h.OutlineTransparency=1-RHg.outlineAlpha
h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
h.Adornee=mdl
h.Parent=mdl
hls[mdl]=h
return h
end
function rhl(mdl)
hl=hls[mdl]
if hl then pcall(function() hl:Destroy() end) end
hls[mdl]=nil
end
function pnt(p)
if not RHg.enabled then return end
if p==Lcl and not RHg.showSelf then return end
c=p.Character
if not c then return end
cl=col(p)
hl=ghl(c)
if hl then
hl.FillColor=cl
hl.OutlineColor=cl
end
end
function rfa()
if not RHg.enabled then return end
for _,p in ipairs(Ply:GetPlayers()) do
if p~=Lcl or RHg.showSelf then
if p.Character then
pnt(p)
end
end
end
for mdl in pairs(hls) do
if not mdl.Parent then
rhl(mdl)
end
end
end
function bnd(p)
if p==Lcl and not RHg.showSelf then
return
end
p.CharacterAdded:Connect(function(c)
task.wait(0.15)
pnt(p)
end)
task.spawn(function()
while p.Parent do
bp=p:FindFirstChildOfClass("Backpack")
if bp then break end
task.wait(0.2)
end
bp=p:FindFirstChildOfClass("Backpack")
if bp then
bp.ChildAdded:Connect(function() task.wait(0.05); pnt(p) end)
bp.ChildRemoved:Connect(function() task.wait(0.05); pnt(p) end)
end
c=p.Character
if c then
c.ChildAdded:Connect(function() task.wait(0.05); pnt(p) end)
c.ChildRemoved:Connect(function() task.wait(0.05); pnt(p) end)
end
end)
end
for _,p in ipairs(Ply:GetPlayers()) do
bnd(p)
end
Ply.PlayerAdded:Connect(bnd)
Ply.PlayerRemoving:Connect(function(p)
if p.Character then rhl(p.Character) end
end)
task.spawn(function()
while task.wait(RHg.refreshRate) do
rfa()
end
end)
rfa()
_G.MM2Roles={isMurderer=isM,isSheriff=isS,roleOf=rol,colorOf=col,refresh=rfa,RH=RHg}
end
do
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

jumpBtn=l.Parent:WaitForChild("BombJumpGui"):WaitForChild("TextButton") or l.Parent:FindFirstChild("BombJumpGui")
if jumpBtn then
jumpBtn.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
beginDrag(jumpBtn,input)
end
end
)
end

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
end
