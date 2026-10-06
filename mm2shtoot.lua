do
screenGui=Instance.new("ScreenGui")
screenGui.Name="ShootButtonGui"
screenGui.ResetOnSpawn=false
screenGui.Parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
button=Instance.new("TextButton")
button.Name="ShootButton"
button.Size=UDim2.new(0,56,0,56)
button.Position=UDim2.new(1,-76,0.5,-28)
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
Players=game:GetService("Players")
RunService=game:GetService("RunService")
UserInputService=game:GetService("UserInputService")
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
b=ch()
return b and b:FindFirstChild("HumanoidRootPart")
end
function alive(a)
b=a.Character
if not b then return false
end
h=b:FindFirstChildOfClass("Humanoid")
return h and h.Health>0
end
function isEnemy(a)
if a==LocalPlayer or not alive(a)then return false
end
if CFG.teamSafe and a.Team and a.Team==LocalPlayer.Team then return false
end
return true
end
PARTS={"Head","UpperTorso","LowerTorso","Torso","HumanoidRootPart"}
function partsOf(b)
t={}
if not b then return t
end
for _,n in ipairs(PARTS)do
a=b:FindFirstChild(n)
if a and a:IsA("BasePart")then t[#t+1]=a
end
end
return t
end
function centerOf(b)
ps=partsOf(b)
if#ps==0 then return nil
end
v=Vector3.zero
for _,a in ipairs(ps)do v=v+a.Position
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
b=ch()
return b and b:FindFirstChild("Knife")
end
function getGun()
b=ch()
return b and b:FindFirstChild("Gun")
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
function predPart(c,d,e)
if not CFG.leadEnabled then return c.Position
end
v=c.AssemblyLinearVelocity
if v.Magnitude<1 then return c.Position
end
p0=c.Position
a=p0
scale=pingScale()
for _=1,3 do
t=(a-d).Magnitude/CFG.bulletSpeed
a=p0+v*t*e*scale
end
return a
end
function pickTargetPart(b,d)
ps=partsOf(b)
if#ps==0 then return nil
end
if CFG.aimHead then
head=b:FindFirstChild("Head")
if head and head:IsA("BasePart")then return head
end
end
best,bestD=nil,math.huge
for _,a in ipairs(ps)do
d=(a.Position-d).Magnitude
if d<bestD then best,bestD=a,d
end
end
return best or ps[1]
end
function doShoot(f)
remote=shootRemote()
origin=gunOrigin()
if not(remote and origin)then return
end
if not f.Character then return
end
r=myRoot()
if not r then return
end
ctr=centerOf(f.Character)
if ctr and(ctr-r.Position).Magnitude>CFG.range then return
end
c=pickTargetPart(f.Character,origin.Position)
if not c then return
end
aimPos=predPart(c,origin.Position,CFG.leadTime)
fromCF=CFrame.lookAt(origin.Position,aimPos)
goalCF=CFrame.new(aimPos)
pcall(function()remote:FireServer(fromCF,goalCF)
end
)
end
function doThrow(f)
remote=throwRemote()
if not remote then return
end
knife=getKnife()
handle=knife and(knife:FindFirstChild("Handle")or knife:FindFirstChild("Blade"))
r=myRoot()
fromCF=(handle and handle.CFrame)or(r and r.CFrame)
if not fromCF or not f.Character then return
end
ctr=centerOf(f.Character)
if r and ctr and(ctr-r.Position).Magnitude>CFG.range then return
end
c=pickTargetPart(f.Character,fromCF.Position)
if not c then return
end
aimPos=predPart(c,fromCF.Position,CFG.throwLead)
startCF=CFrame.lookAt(fromCF.Position,aimPos)
goalCF=CFrame.new(aimPos)
pcall(function()remote:FireServer(startCF,goalCF)
end
)
end
STAB={"HumanoidRootPart","UpperTorso","LowerTorso","Torso","Head"}
function doStab(f)
ev=knifeEv()
tc=f and f.Character
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
c=tc:FindFirstChild(n)
if c then
pcall(function()ht:FireServer(c)
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
for _,a in ipairs(Players:GetPlayers())do
if isEnemy(a)then
ctr=centerOf(a.Character)
if ctr then
d=(ctr-r.Position).Magnitude
if d<bestD and d<=CFG.range then best,bestD=a,d
end
end
end
end
return best
end
function executeOnce()
b=ch()
if not b then return
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
button.Text="shooting..."
task.wait(0.1)
button.Text="shoot"
pcall(executeOnce)
end
)
end
