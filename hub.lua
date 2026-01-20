-- Black Grimoire: Legacy Mobile HUB | Feito por Grok para Mauro
-- Jogo: https://www.roblox.com/games/4632627223/Black-Grimoire
-- Auto Farm NPCs/Bosses, Chests, Pull, Kill Aura, Auto Stats/Reset, Quests
-- Use em Arceus X, Delta, etc. | Atualizado Jan 2026

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local player = Players.LocalPlayer

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🖤 Black Grimoire Legacy HUB | Mobile", "DarkTheme")

local Tab = Window:NewTab("Farm & Bosses")
local SecFarm = Tab:NewSection("Farms Automáticos")
local SecBoss = Tab:NewSection("Bosses Específicos")
local SecUtils = Tab:NewSection("Utilitários")

local t = {  -- toggles
    farmNPC = false, chests = false, killAura = false, pull = false,
    autoStats = false, resetFarm = false, missoes = false,
    dungeonBoss = false, lich = false, bruxa = false
}

local function hrp() 
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart", 5) 
end

local function tp(pos) 
    local r = hrp()
    if r then r.CFrame = CFrame.new(pos) end 
end

local function nearest(range, cond)
    local r, minD = hrp(), range or 500
    if not r then return end
    local closest
    for _, v in WS:GetChildren() do
        local hum = v:FindFirstChildWhichIsA("Humanoid")
        if hum and v ~= player.Character and hum.Health > 0 then
            local th = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
            if th then
                local d = (th.Position - r.Position).Magnitude
                local name = v.Name:lower()
                if d < minD and (not cond or cond(name)) then
                    minD, closest = d, v
                end
            end
        end
    end
    return closest
end

local function attack(targ)
    if not targ then return end
    local folders = {RS:FindFirstChild("Remotes"), RS:FindFirstChild("Events"), RS:FindFirstChild("RemoteEvents"), RS:FindFirstChild("Combat")}
    for _, folder in folders do
        if folder then
            for _, rem in folder:GetChildren() do
                if rem:IsA("RemoteEvent") then
                    pcall(function()
                        rem:FireServer(targ)
                        rem:FireServer(targ.Name)
                        rem:FireServer(targ:FindFirstChildWhichIsA("Humanoid"))
                        rem:FireServer("Attack", targ)  -- Brute extra pro Legacy
                    end)
                end
            end
        end
    end
end

local function collectChests()
    for _, obj in WS:GetDescendants() do
        local n = obj.Name:lower()
        if n:find("chest") or n:find("bau") or n:find("treasure") or n:find("grimoire") or (obj:IsA("ProximityPrompt") and obj.ActionText:lower():find("open")) then
            local part = obj:IsA("BasePart") and obj or obj.Parent:FindFirstChildWhichIsA("BasePart")
            if part then
                tp(part.Position + Vector3.new(0, 5, 0))
                task.wait(0.1)
                attack(obj.Parent)
                if obj:IsA("ProximityPrompt") then
                    pcall(function() obj:InputHoldBegin(); task.wait(0.3); obj:InputHoldEnd() end)
                end
            end
        end
    end
end

local function pullMobs()
    local r = hrp()
    if not r then return end
    for _, v in WS:GetChildren() do
        local hum = v:FindFirstChildWhichIsA("Humanoid")
        if hum and v ~= player.Character and hum.Health > 0 then
            local th = v:FindFirstChild("HumanoidRootPart")
            if th then
                th.CFrame = r.CFrame * CFrame.new(0, 0, -4)
                attack(v)
            end
        end
    end
end

local function interactNPC(kw)
    for _, obj in WS:GetDescendants() do
        local n = obj.Name:lower()
        if n:find("reset") or n:find("stat") or n:find("quest") or n:find("missao") or n:find("npc") or n:find("grimoire") or (kw and n:find(kw)) then
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                tp(obj.Position + Vector3.new(0, 6, 0))
                task.wait(0.15)
                pcall(function()
                    prompt:InputHoldBegin()
                    task.wait(0.35)
                    prompt:InputHoldEnd()
                end)
                attack(obj.Parent)
            end
        end
    end
end

-- Loop otimizado
task.spawn(function()
    while true do
        task.wait(0.08)
        local r = hrp()
        if not r then continue end

        if t.farmNPC then
            local enemy = nearest(200)
            if enemy then
                tp(enemy.PrimaryPart.Position + Vector3.new(0, 7, 0))
                attack(enemy)
            end
        end

        if t.chests then collectChests() end

        if t.killAura or t.missoes then
            pullMobs()
            if t.missoes then interactNPC("quest") end
        end

        if t.pull then pullMobs() end

        if t.autoStats or t.resetFarm then
            interactNPC("reset")
            interactNPC("stat")
            task.wait(0.6)
        end

        if t.dungeonBoss then
            local boss = nearest(300, function(n) return n:find("dungeon") or n:find("boss") or n:find("tower") end)
            if boss then tp(boss.PrimaryPart.Position + Vector3.new(0, 7, 0)); attack(boss) end
        end

        if t.lich then
            local lich = nearest(400, function(n) return n:find("lich") or n:find("licht") or n:find("undead") end)
            if lich then tp(lich.PrimaryPart.Position + Vector3.new(0, 7, 0)); attack(lich) end
        end

        if t.bruxa then
            local witch = nearest(400, function(n) return n:find("witch") or n:find("bruxa") or n:find("queen") end)
            if witch then tp(witch.PrimaryPart.Position + Vector3.new(0, 7, 0)); attack(witch) end
        end
    end
end)

SecFarm:NewToggle("Auto Farm Todos NPCs", "High farm mobs infinitos", function(s) t.farmNPC = s end)
SecFarm:NewToggle("Auto Pegar Baús/Itens", "Coleta chests e grimoires", function(s) t.chests = s end)
SecFarm:NewToggle("Kill Aura + Auto Missões", "Aura + quests auto", function(s) t.killAura = s; t.missoes = s end)

SecBoss:NewToggle("Auto Dungeon Boss", "Farm bosses de dungeon", function(s) t.dungeonBoss = s end)
SecBoss:NewToggle("Auto Lich", "Farm Lich/Undead", function(s) t.lich = s end)
SecBoss:NewToggle("Auto Bruxa/Witch Queen", "Farm Witch bosses", function(s) t.bruxa = s end)

SecUtils:NewToggle("Puxar Todos NPCs", "Traga mobs pra perto", function(s) t.pull = s end)
SecUtils:NewToggle("Auto Stats + Farm Reset", "Reset e aloca stats auto", function(s) t.autoStats = s; t.resetFarm = s end)

SecUtils:NewButton("Anti-AFK", "Sem kick idle", function()
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
end)

print("🖤 Black Grimoire Legacy HUB carregado! Ative e farme! Feito por Grok 🔥")
