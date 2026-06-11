-- INFINITE YIELD FE v6.4.1 (ТОЧНАЯ КОПИЯ С ФОТО)
-- by zwery

local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local cam = workspace.CurrentCamera

local s = {
    noclip=false, speed=false, esp=false, fov=70, fovOn=true,
    flingAura=false, antiGrab=false, jerk=false, third=true
}

local espData = {}
local speedConn,noclipConn,flingConn,antiGrabConn,jerkConn = nil,nil,nil,nil,nil
local jerking,menuOpen = false,false
local speedBV = nil

local gui = Instance.new("ScreenGui")
gui.Name = "InfiniteYield"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
pcall(function() gui.Parent = player.PlayerGui end)

-- МЕНЮ (КАК НА ФОТО)
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0,320,0,450)
menu.Position = UDim2.new(0.5,-160,0.5,-225)
menu.BackgroundColor3 = Color3.new(0.05,0.05,0.05)
menu.BorderSizePixel = 2
menu.BorderColor3 = Color3.new(0.3,0.5,0.8)
menu.Visible = true
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0,8)
menuCorner.Parent = menu

-- ЗАГОЛОВОК КАК НА ФОТО
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0.1,0)
title.BackgroundColor3 = Color3.new(0.15,0.15,0.2)
title.Text = "11260"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = menu

local title2 = Instance.new("TextLabel")
title2.Size = UDim2.new(1,0,0.07,0)
title2.Position = UDim2.new(0,0,0.1,0)
title2.BackgroundTransparency = 1
title2.Text = "МЕНЮ ИГРУШЕК"
title2.TextColor3 = Color3.new(0.7,0.7,0.9)
title2.TextScaled = true
title2.Font = Enum.Font.GothamBold
title2.Parent = menu

local title3 = Instance.new("TextLabel")
title3.Size = UDim2.new(1,0,0.07,0)
title3.Position = UDim2.new(0,0,0.17,0)
title3.BackgroundTransparency = 1
title3.Text = "IV ch"
title3.TextColor3 = Color3.new(0.5,0.5,0.5)
title3.TextScaled = true
title3.Font = Enum.Font.Gotham
title3.Parent = menu

local title4 = Instance.new("TextLabel")
title4.Size = UDim2.new(1,0,0.08,0)
title4.Position = UDim2.new(0,0,0.24,0)
title4.BackgroundTransparency = 1
title4.Text = "Infinite Yield FE v6.4.1"
title4.TextColor3 = Color3.new(0.3,0.7,1)
title4.TextScaled = true
title4.Font = Enum.Font.GothamBold
title4.Parent = menu

local close = Instance.new("TextButton")
close.Size = UDim2.new(0.1,0,0.1,0)
close.Position = UDim2.new(0.88,0,0,0)
close.BackgroundColor3 = Color3.new(0.5,0.1,0.1)
close.Text = "✖"
close.TextColor3 = Color3.new(1,1,1)
close.TextScaled = true
close.Font = Enum.Font.GothamBold
close.Parent = menu

close.MouseButton1Click:Connect(function()
    menu.Visible = false
    gui:Destroy()
end)

-- КНОПКИ
local buttons = {
    {name="Noclip", y=0.35, setting="noclip"},
    {name="Speed", y=0.42, setting="speed"},
    {name="ESP", y=0.49, setting="esp"},
    {name="Fling Aura", y=0.56, setting="flingAura"},
    {name="Anti-Grab", y=0.63, setting="antiGrab"},
    {name="Jerk", y=0.70, setting="jerk"},
    {name="Camera (3rd/1st)", y=0.77, setting="camera"},
}

local btnList = {}
for _,btn in pairs(buttons) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9,0,0.06,0)
    b.Position = UDim2.new(0.05,0,btn.y,0)
    b.BackgroundColor3 = Color3.new(0.1,0.1,0.15)
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.new(0.3,0.5,0.8)
    b.Text = btn.name .. ": OFF"
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.Gotham
    b.Parent = menu
    btnList[btn.setting] = b
end

-- FOV
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.3,0,0.05,0)
fovLabel.Position = UDim2.new(0.05,0,0.85,0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: 70°"
fovLabel.TextColor3 = Color3.new(1,1,0)
fovLabel.TextScaled = true
fovLabel.Font = Enum.Font.GothamBold
fovLabel.Parent = menu

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.5,0,0.04,0)
sliderBg.Position = UDim2.new(0.28,0,0.86,0)
sliderBg.BackgroundColor3 = Color3.new(0.3,0.3,0.4)
sliderBg.Parent = menu

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0.1,0,1,0)
sliderBtn.BackgroundColor3 = Color3.new(0.3,0.7,1)
sliderBtn.Text = ""
sliderBtn.Parent = sliderBg

local fovOnBtn = Instance.new("TextButton")
fovOnBtn.Size = UDim2.new(0.12,0,0.05,0)
fovOnBtn.Position = UDim2.new(0.82,0,0.85,0)
fovOnBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.3)
fovOnBtn.Text = "ON"
fovOnBtn.TextColor3 = Color3.new(1,1,1)
fovOnBtn.TextScaled = true
fovOnBtn.Font = Enum.Font.Gotham
fovOnBtn.Parent = menu

-- ФУНКЦИИ
local function setFOV(val)
    s.fov = math.clamp(val,70,120)
    fovLabel.Text = "FOV: " .. math.floor(s.fov) .. "°"
    if s.fovOn then cam.FieldOfView = s.fov end
    local t = (s.fov-70)/50
    sliderBtn.Position = UDim2.new(t, -sliderBtn.AbsoluteSize.X/2, 0, 0)
end

local dragging = false
sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
uis.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = sliderBg.AbsolutePosition.X
        local w = sliderBg.AbsoluteSize.X
        local mx = i.Position.X
        local t = math.clamp((mx-pos)/w,0,1)
        setFOV(70+t*50)
    end
end)

fovOnBtn.MouseButton1Click:Connect(function()
    s.fovOn = not s.fovOn
    fovOnBtn.Text = s.fovOn and "ON" or "OFF"
    if s.fovOn then cam.FieldOfView = s.fov else cam.FieldOfView = 70 end
end)

-- NOCLIP
local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = rs.RenderStepped:Connect(function()
        if s.noclip and player.Character then
            for _,part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

-- SPEED
local function startSpeed()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if speedBV then speedBV:Destroy() end
    speedBV = Instance.new("BodyVelocity")
    speedBV.MaxForce = Vector3.new(9e9,0,9e9)
    speedBV.Parent = root
    if speedConn then speedConn:Disconnect() end
    speedConn = rs.RenderStepped:Connect(function()
        if s.speed and root and root.Parent then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    speedBV.Velocity = Vector3.new(moveDir.X * 80, 0, moveDir.Z * 80)
                else
                    speedBV.Velocity = Vector3.new(0,0,0)
                end
                hum.WalkSpeed = 16
            end
        end
    end)
end

local function stopSpeed()
    if speedConn then speedConn:Disconnect() speedConn = nil end
    if speedBV then speedBV:Destroy() speedBV = nil end
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end

-- ESP
local function addESP(p)
    if espData[p] then return end
    local char = p.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local h = Instance.new("Highlight")
    h.Name = "ESP"
    h.FillTransparency = 1
    h.OutlineColor = Color3.new(1,0,0)
    h.Parent = char
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0,120,0,40)
    bill.StudsOffset = Vector3.new(0,2.5,0)
    bill.AlwaysOnTop = true
    bill.Parent = root
    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1,0,0.5,0)
    nameL.BackgroundTransparency = 1
    nameL.Text = p.Name
    nameL.TextColor3 = Color3.new(1,1,1)
    nameL.TextScaled = true
    nameL.Font = Enum.Font.GothamBold
    nameL.Parent = bill
    local distL = Instance.new("TextLabel")
    distL.Size = UDim2.new(1,0,0.5,0)
    distL.Position = UDim2.new(0,0,0.5,0)
    distL.BackgroundTransparency = 1
    distL.TextScaled = true
    distL.Font = Enum.Font.Gotham
    distL.Parent = bill
    espData[p] = {bill=bill, dist=distL, root=root, char=char}
end

local function remESP(p)
    local e = espData[p]
    if e then
        if e.bill then e.bill:Destroy() end
        if e.char and e.char:FindFirstChild("ESP") then e.char.ESP:Destroy() end
        espData[p] = nil
    end
end

local function updateESP()
    local myChar = player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    for p,e in pairs(espData) do
        if p.Character and e.root and e.root.Parent then
            local dist = (myPos - e.root.Position).Magnitude
            e.dist.Text = string.format("%.1f m", dist)
            if dist < 20 then e.dist.TextColor3 = Color3.new(1,0.3,0.3)
            elseif dist < 50 then e.dist.TextColor3 = Color3.new(1,1,0)
            else e.dist.TextColor3 = Color3.new(0.5,1,0.5) end
        else
            remESP(p)
        end
    end
end

-- FLING AURA
local function flingTarget(p)
    local char = p.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0,9e9,0)
    bv.Velocity = Vector3.new(0,500,0)
    bv.Parent = root
    local bv2 = Instance.new("BodyVelocity")
    bv2.MaxForce = Vector3.new(9e9,0,9e9)
    bv2.Velocity = Vector3.new(math.random(-100,100),0,math.random(-100,100))
    bv2.Parent = root
    task.wait(1)
    bv:Destroy()
    bv2:Destroy()
end

local function checkFling()
    if not s.flingAura then return end
    local myChar = player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and (myPos - root.Position).Magnitude <= 10 then
                    flingTarget(p)
                end
            end
        end
    end
end

-- ANTI-GRAB
local function startAntiGrab()
    if antiGrabConn then antiGrabConn:Disconnect() end
    antiGrabConn = rs.RenderStepped:Connect(function()
        if s.antiGrab and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, bv in pairs(char:GetChildren()) do
                    if bv:IsA("BodyVelocity") then bv:Destroy() end
                end
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.PlatformStand then hum.PlatformStand = false end
            end
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character then
                    local line = p.Character:FindFirstChild("LineHandle")
                    if line then line:Destroy() end
                end
            end
        end
    end)
end

-- JERK
local function doJerk()
    local char = player.Character
    if not char then return end
    local arm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
    if not arm then return end
    local orig = arm.CFrame
    for i=1,10 do
        if not s.jerk and not jerking then break end
        arm.CFrame = orig * CFrame.new(0,0,1.5)
        task.wait(0.04)
        arm.CFrame = orig * CFrame.new(0,0,-0.2)
        task.wait(0.04)
    end
    arm.CFrame = orig
    jerking = false
end

local function manualJerk()
    if jerking then return end
    jerking = true
    task.spawn(doJerk)
end

local function startJerk()
    if jerkConn then jerkConn:Disconnect() end
    jerkConn = rs.RenderStepped:Connect(function()
        if s.jerk and not jerking then
            jerking = true
            task.spawn(doJerk)
        end
    end)
end

-- CAMERA
local function setThird()
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = player.Character
    s.third = true
    btnList.camera.Text = "Camera (3rd/1st): 3rd"
end

local function setFirst()
    cam.CameraType = Enum.CameraType.Attach
    if player.Character then
        cam.CameraSubject = player.Character:FindFirstChild("Head")
    end
    s.third = false
    btnList.camera.Text = "Camera (3rd/1st): 1st"
end

-- НАЗНАЧЕНИЕ КНОПОК
btnList.noclip.MouseButton1Click:Connect(function()
    s.noclip = not s.noclip
    btnList.noclip.Text = "Noclip: "..(s.noclip and "ON" or "OFF")
    if s.noclip then startNoclip() elseif noclipConn then noclipConn:Disconnect() noclipConn = nil end
end)

btnList.speed.MouseButton1Click:Connect(function()
    s.speed = not s.speed
    btnList.speed.Text = "Speed: "..(s.speed and "ON" or "OFF")
    if s.speed then startSpeed() else stopSpeed() end
end)

btnList.esp.MouseButton1Click:Connect(function()
    s.esp = not s.esp
    btnList.esp.Text = "ESP: "..(s.esp and "ON" or "OFF")
    if s.esp then
        for _,p in pairs(game.Players:GetPlayers()) do
            if p ~= player then
                if p.Character then addESP(p) end
                p.CharacterAdded:Connect(function() task.wait(0.5); if s.esp then addESP(p) end end)
            end
        end
        rs.Heartbeat:Connect(function() if s.esp then updateESP() end end)
    else
        for p in pairs(espData) do remESP(p) end
    end
end)

btnList.flingAura.MouseButton1Click:Connect(function()
    s.flingAura = not s.flingAura
    btnList.flingAura.Text = "Fling Aura: "..(s.flingAura and "ON" or "OFF")
    if s.flingAura then
        if flingConn then flingConn:Disconnect() end
        flingConn = rs.Heartbeat:Connect(checkFling)
    else
        if flingConn then flingConn:Disconnect() flingConn = nil end
    end
end)

btnList.antiGrab.MouseButton1Click:Connect(function()
    s.antiGrab = not s.antiGrab
    btnList.antiGrab.Text = "Anti-Grab: "..(s.antiGrab and "ON" or "OFF")
    if s.antiGrab then startAntiGrab() elseif antiGrabConn then antiGrabConn:Disconnect() antiGrabConn = nil end
end)

btnList.jerk.MouseButton1Click:Connect(function()
    s.jerk = not s.jerk
    btnList.jerk.Text = "Jerk: "..(s.jerk and "ON" or "OFF")
    if s.jerk then startJerk() elseif jerkConn then jerkConn:Disconnect() jerkConn = nil end
end)

btnList.camera.MouseButton1Click:Connect(function()
    if s.third then setFirst() else setThird() end
end)

uis.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.J then manualJerk() end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if s.speed then startSpeed() end
    if s.noclip then startNoclip() end
    if s.antiGrab then startAntiGrab() end
    if s.third then setThird() else setFirst() end
    if s.fovOn then cam.FieldOfView = s.fov end
end)

setThird()
setFOV(70)

print("✅ Infinite Yield FE v6.4.1 загружен! Нажми ✖ чтобы закрыть меню")
