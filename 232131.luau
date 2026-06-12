-- Obsidian-based GUI script (with safe fallback)
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local cam = workspace.CurrentCamera

local s = {
    noclip=false, speed=false, esp=false, fov=70, fovOn=true,
    flingAura=false, antiGrab=false, jerk=false, third=true
}

local espData = {}
local espConn = nil
local speedConn,noclipConn,flingConn,antiGrabConn,jerkConn,fpsConn = nil,nil,nil,nil,nil,nil
local speedBV = nil

local function safeDestroyGui(g)
    if g and g.Parent then
        if fpsConn then fpsConn:Disconnect() fpsConn = nil end
        if speedConn then speedConn:Disconnect() speedConn = nil end
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if flingConn then flingConn:Disconnect() flingConn = nil end
        if antiGrabConn then antiGrabConn:Disconnect() antiGrabConn = nil end
        if jerkConn then jerkConn:Disconnect() jerkConn = nil end
        if espConn then espConn:Disconnect() espConn = nil end
        g:Destroy()
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "InfiniteYield_Obsidian"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game.CoreGui end)
pcall(function() if not gui.Parent then gui.Parent = player.PlayerGui end end)

-- Core feature implementations
local function setFOV(val)
    s.fov = math.clamp(val,70,120)
    if s.fovOn then cam.FieldOfView = s.fov end
end

local function startNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    noclipConn = rs.RenderStepped:Connect(function()
        if s.noclip and player.Character then
            for _,part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end

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
    if char then local hum = char:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = 16 end end
end

local function addESPForPlayer(p)
    if espData[p] then return end
    if not p.Character then return end
    local h = Instance.new("Highlight")
    h.Name = "ESP"
    h.FillTransparency = 1
    h.OutlineColor = Color3.new(1,0,0)
    h.Parent = p.Character
    espData[p] = h
end

local function remESPForPlayer(p)
    local h = espData[p]
    if h and h.Parent then h:Destroy() end
    espData[p] = nil
end

local function updateESP()
    for p,h in pairs(espData) do
        if not (p and p.Character and h and h.Parent) then remESPForPlayer(p) end
    end
end

local function flingTarget(p)
    if not (p and p.Character) then return end
    local root = p.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(0,9e9,0)
    bv.Velocity = Vector3.new(0,500,0)
    local bv2 = Instance.new("BodyVelocity", root)
    bv2.MaxForce = Vector3.new(9e9,0,9e9)
    bv2.Velocity = Vector3.new(math.random(-100,100),0,math.random(-100,100))
    task.delay(1,function() if bv then bv:Destroy() end if bv2 then bv2:Destroy() end end)
end

local function checkFling()
    if not s.flingAura then return end
    local myChar = player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root and (myRoot.Position - root.Position).Magnitude <= 10 then flingTarget(p) end
        end
    end
end

local function startAntiGrab()
    if antiGrabConn then antiGrabConn:Disconnect() antiGrabConn = nil end
    antiGrabConn = rs.RenderStepped:Connect(function()
        if s.antiGrab and player.Character then
            local char = player.Character
            for _, bv in pairs(char:GetChildren()) do if bv:IsA("BodyVelocity") then bv:Destroy() end end
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.PlatformStand then hum.PlatformStand = false end
            for _, p in pairs(game.Players:GetPlayers()) do if p.Character then local line = p.Character:FindFirstChild("LineHandle") if line then line:Destroy() end end end
        end
    end)
end

local function stopAntiGrab()
    if antiGrabConn then antiGrabConn:Disconnect() antiGrabConn = nil end
end

local jerking = false
local function doJerk()
    local char = player.Character
    if not char then return end
    local arm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
    if not arm then return end
    local orig = arm.CFrame
    for i=1,10 do
        if not s.jerk then break end
        arm.CFrame = orig * CFrame.new(0,0,1.5)
        task.wait(0.04)
        arm.CFrame = orig * CFrame.new(0,0,-0.2)
        task.wait(0.04)
    end
    arm.CFrame = orig
    jerking = false
end

local function startJerk()
    if jerkConn then jerkConn:Disconnect() jerkConn = nil end
    jerkConn = rs.RenderStepped:Connect(function()
        if s.jerk and not jerking then jerking = true task.spawn(doJerk) end
    end)
end

local function stopJerk()
    if jerkConn then jerkConn:Disconnect() jerkConn = nil end
    jerking = false
end

local function setThird()
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = player.Character
    s.third = true
end

local function setFirst()
    cam.CameraType = Enum.CameraType.Attach
    if player.Character then cam.CameraSubject = player.Character:FindFirstChild("Head") end
    s.third = false
end

-- Load Obsidian properly (Library + addons). If it fails, use fallback GUI above.
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Lib,TM,SM = nil,nil,nil
local okLib,loadedLib = pcall(function() return loadstring(game:HttpGet(repo.."Library.lua"))() end)
if okLib and type(loadedLib) == "table" then
    Lib = loadedLib
    pcall(function() TM = loadstring(game:HttpGet(repo.."addons/ThemeManager.lua"))() end)
    pcall(function() SM = loadstring(game:HttpGet(repo.."addons/SaveManager.lua"))() end)
end

local menu = nil
if Lib then
    local success, W = pcall(function()
        return Lib:CreateWindow({Title = "Infinite Yield FE", Icon = "", Footer = "v1", NotifySide = "Right"})
    end)
    if success and W then
        menu = W
        if TM and type(TM.SetLibrary) == "function" then pcall(function() TM:SetLibrary(Lib) end) end

        local Tabs = {}
        Tabs.Main = W:AddTab("Main","house")
        local ML = Tabs.Main:AddLeftGroupbox("Main","settings")
        local MR = Tabs.Main:AddRightGroupbox("Settings","cog")

        ML:AddToggle("Noclip",{Text="Noclip",Default=false,Callback=function(v)
            s.noclip = v
            if v then startNoclip() else stopNoclip() end
        end})

        ML:AddToggle("Speed",{Text="Speed",Default=false,Callback=function(v)
            s.speed = v
            if v then startSpeed() else stopSpeed() end
        end})

        ML:AddToggle("ESP",{Text="ESP",Default=false,Callback=function(v)
            s.esp = v
            if v then
                for _,p in pairs(game.Players:GetPlayers()) do if p~=player and p.Character then addESPForPlayer(p) end end
                if espConn then espConn:Disconnect() espConn = nil end
                espConn = rs.Heartbeat:Connect(function() if s.esp then updateESP() end end)
            else
                for p in pairs(espData) do remESPForPlayer(p) end
                if espConn then espConn:Disconnect() espConn = nil end
            end
        end})

        ML:AddToggle("FlingAura",{Text="Fling Aura",Default=false,Callback=function(v)
            s.flingAura = v
            if v then if flingConn then flingConn:Disconnect() end flingConn = rs.Heartbeat:Connect(checkFling) else if flingConn then flingConn:Disconnect() flingConn = nil end end
        end})

        ML:AddToggle("AntiGrab",{Text="Anti-Grab",Default=false,Callback=function(v)
            s.antiGrab = v
            if v then startAntiGrab() else stopAntiGrab() end
        end})

        ML:AddToggle("Jerk",{Text="Jerk",Default=false,Callback=function(v)
            s.jerk = v
            if v then startJerk() else stopJerk() end
        end})

        ML:AddButton({Text="Toggle Camera",Func=function() if s.third then setFirst() else setThird() end end})

        MR:AddSlider("FOV",{Text="FOV",Min=70,Max=120,Default=70,Rounding=0,Callback=function(v) setFOV(v) end})
        MR:AddToggle("FOVOn",{Text="FOV Enabled",Default=true,Callback=function(v) s.fovOn = v if v then cam.FieldOfView = s.fov else cam.FieldOfView = 70 end end})

        MR:AddButton({Text="Close UI",Func=function() safeDestroyGui(gui) end})
    end
end

-- If Obsidian failed to load, create a simple fallback Frame menu
if not menu then
    local menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0,260,0,380)
    menuFrame.Position = UDim2.new(0.5,-130,0.5,-190)
    menuFrame.BackgroundColor3 = Color3.fromRGB(12,12,15)
    menuFrame.BorderSizePixel = 1
    menuFrame.BorderColor3 = Color3.fromRGB(77,127,204)
    menuFrame.Parent = gui
    local menuCorner = Instance.new("UICorner", menuFrame)
    menuCorner.CornerRadius = UDim.new(0,8)
    local title = Instance.new("TextLabel", menuFrame)
    title.Size = UDim2.new(1,0,0,36)
    title.BackgroundColor3 = Color3.fromRGB(30,30,40)
    title.Text = "Infinite Yield FE"
    title.TextColor3 = Color3.new(1,1,1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    local close = Instance.new("TextButton", menuFrame)
    close.Size = UDim2.new(0,28,0,28)
    close.Position = UDim2.new(1,-34,0,4)
    close.Text = "✖"
    close.TextScaled = true
    close.BackgroundColor3 = Color3.fromRGB(128,25,25)
    close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.GothamBold
    close.MouseButton1Click:Connect(function() safeDestroyGui(gui) end)
    menu = menuFrame
end

-- Draggable FPS / Ping indicator
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(0,140,0,48)
statsFrame.Position = UDim2.new(0.02,0,0.02,0)
statsFrame.BackgroundColor3 = Color3.fromRGB(20,20,24)
statsFrame.BorderSizePixel = 1
statsFrame.BorderColor3 = Color3.fromRGB(77,127,204)
statsFrame.Parent = gui
Instance.new("UICorner", statsFrame)
local fpsLabel = Instance.new("TextLabel", statsFrame)
fpsLabel.Size = UDim2.new(1,0,0.5,0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.TextScaled = true
fpsLabel.Font = Enum.Font.GothamBold
local pingLabel = Instance.new("TextLabel", statsFrame)
pingLabel.Size = UDim2.new(1,0,0.5,0)
pingLabel.Position = UDim2.new(0,0,0.5,0)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: 0 ms"
pingLabel.TextColor3 = Color3.fromRGB(170,255,170)
pingLabel.TextScaled = true
pingLabel.Font = Enum.Font.Gotham

local draggingStats = false
local dragStart = Vector2.new(0,0)
local startPos = statsFrame.Position
statsFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingStats = true
        dragStart = input.Position
        startPos = statsFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingStats = false end
        end)
    end
end)
uis.InputChanged:Connect(function(input)
    if draggingStats and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        statsFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local frameCount,frameSum = 0,0
fpsConn = rs.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1
    frameSum = frameSum + dt
    if frameSum >= 0.5 then
        local fps = math.floor(frameCount / frameSum + 0.5)
        fpsLabel.Text = "FPS: "..fps
        frameCount = 0
        frameSum = 0
    end
    if player and player.GetNetworkPing then
        local ping = math.floor(player:GetNetworkPing() * 1000 + 0.5)
        pingLabel.Text = "Ping: "..ping.." ms"
    end
end)

-- RightControl toggles menu visibility
uis.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightControl then
        if type(menu) == "table" and menu.Toggle then
            pcall(function() menu:Toggle() end)
        elseif menu and menu.Parent then
            menu.Visible = not menu.Visible
        end
    end
    if i.KeyCode == Enum.KeyCode.J then
        -- manual jerk
        if player.Character then
            local arm = player.Character:FindFirstChild("Right Arm") or player.Character:FindFirstChild("RightHand")
            if arm then
                local orig = arm.CFrame
                for i=1,10 do
                    arm.CFrame = orig * CFrame.new(0,0,1.5)
                    task.wait(0.04)
                    arm.CFrame = orig * CFrame.new(0,0,-0.2)
                    task.wait(0.04)
                end
                arm.CFrame = orig
            end
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if s.speed then startSpeed() end
    if s.noclip then startNoclip() end
    if s.antiGrab then startAntiGrab() end
    if s.jerk then startJerk() end
    if s.third then setThird() else setFirst() end
    if s.fovOn then cam.FieldOfView = s.fov end
end)

print("✅ Infinite Yield FE (Obsidian-style) loaded. Press RightCtrl to toggle menu.")
