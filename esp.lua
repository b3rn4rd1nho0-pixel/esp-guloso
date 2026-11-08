--// SERVIÇOS
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

--// GUI (O botão de ligar/desligar)
local gui = Instance.new("ScreenGui")
gui.Name = "ControleESP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 100, 0, 35)
btn.Position = UDim2.new(0, 20, 0, 200)
btn.BackgroundColor3 = Color3.fromRGB(50, 180, 80) -- Verde (Ativado)
btn.Text = "ESP: ON"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 12
btn.Font = Enum.Font.GothamBold
btn.Parent = gui

local corner = Instance.new("UICorner", btn)
corner.CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", btn)
stroke.Color = Color3.fromRGB(0, 0, 0)
stroke.Thickness = 2

--// PASTA DAS BOLINHAS
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_Bolinhas"
espFolder.Parent = gui

local espAtivo = true

--// FUNÇÃO QUE CRIA A BOLINHA
local function criarBolinha(plr)
    if plr == player or not espAtivo then return end

    local function anexar(character)
        local head = character:WaitForChild("Head", 5)
        if not head or not espAtivo then return end
        
        if espFolder:FindFirstChild(plr.Name) then
            espFolder:FindFirstChild(plr.Name):Destroy()
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = plr.Name
        billboard.Size = UDim2.new(0, 10, 0, 10)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.StudsOffset = Vector3.new(0, 1.5, 0)
        billboard.Parent = espFolder

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(1, 0, 1, 0)
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 80) -- Verde neon
        dot.Parent = billboard
        
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local s = Instance.new("UIStroke", dot)
        s.Color = Color3.fromRGB(0, 0, 0)
        s.Thickness = 2
        s.Parent = dot
    end

    if plr.Character then anexar(plr.Character) end
    plr.CharacterAdded:Connect(anexar)
end

--// LOOP PRA CRIAR AS BOLINHAS EM QUEM JÁ TÁ NO JOGO
for _, p in ipairs(Players:GetPlayers()) do criarBolinha(p) end
Players.PlayerAdded:Connect(criarBolinha)
Players.PlayerRemoving:Connect(function(plr)
    local b = espFolder:FindFirstChild(plr.Name)
    if b then b:Destroy() end
end)

--// FUNÇÃO PRA APAGAR TODAS
local function limparTodas()
    for _, b in ipairs(espFolder:GetChildren()) do
        b:Destroy()
    end
end

--// LÓGICA DO BOTÃO DE LIGAR/DESLIGAR
btn.MouseButton1Click:Connect(function()
    espAtivo = not espAtivo
    if espAtivo then
        btn.Text = "ESP: ON"
        btn.BackgroundColor3 = Color3.fromRGB(50, 180, 80) -- Verde
        for _, p in ipairs(Players:GetPlayers()) do criarBolinha(p) end
    else
        btn.Text = "ESP: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(200, 60, 60) -- Vermelho
        limparTodas()
    end
end)

--// SISTEMA PRA ARRASTAR O BOTÃO PELA TELA
local arrastando = false
local inicioMouse, inicioPos

btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        arrastando = true
        inicioMouse = input.Position
        inicioPos = btn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then arrastando = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if arrastando and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - inicioMouse
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            btn.Position = UDim2.new(inicioPos.X.Scale, inicioPos.X.Offset + delta.X, inicioPos.Y.Scale, inicioPos.Y.Offset + delta.Y)
        end
    end
end)
