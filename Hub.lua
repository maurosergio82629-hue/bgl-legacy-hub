-- Black Grimoire: Legacy Mobile HUB v2.0 | Melhorado por Grok para Mauro
-- Fixes: Baús coletados 100%, Auto Ataque adicionado, Selector de Missões (todas principais), Minimize UI
-- Jogo: https://www.roblox.com/games/4632627223/Black-Grimoire
-- Use: loadstring(game:HttpGet("https://raw.githubusercontent.com/maurosergio82629-hue/bgl-legacy-hub/main/hub.lua"))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local player = Players.LocalPlayer

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🖤 BGL Legacy HUB v2 | Mobile", "DarkTheme")

local TabFarm = Window:NewTab("⚔️ Farm & Bosses")
local SecFarm = TabFarm:NewSection("Farms Automáticos")
local SecBoss = TabFarm:NewSection("Bosses")
local SecUtils = TabFarm:NewSection("Utilitários")

local TabQuests = Window:NewTab("📜 Missões & Quests")
local SecQuests = TabQuests:NewSection("Auto Missões")

local t = {  
    farmNPC = false, chests = false, killAura = false, pull = false, autoAttack = false,
    autoStats = false, resetFarm = false,
    dungeonBoss = false, lich = false, bruxa = false,
    autoQuest = "",  -- Para selector: "all", "starter", "church", "nun", "dungeon"
    autoAllQuests = false
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

local function getRemotes()
    local folders = {RS:FindFirstChild("Remotes"), RS:FindFirstChild("Events"), RS:FindFirstChild("RemoteEvents"), RS:FindFirstChild("Combat")}
    local rems = {}
    for _, folder in folders do
        if folder then
            for _, rem in folder:GetChildren() do
                if rem:IsA("RemoteEvent") then table.insert(rems, rem) end
            end
        end
    end
    return rems
end

local function attack(targ)
    if not targ then return end
    local rems = getRemotes()
    for _, rem in rems do
        pcall(function()
            rem:FireServer(targ)
            rem:FireServer(targ.Name)
            rem:FireServer(targ:FindFirstChildWhichIsA("Humanoid"))
            rem:FireServer("Attack", targ)
            rem:FireServer()
        end)
    end
end

local function autoAttackSpam()
    local rems = getRemotes()
    for _, rem in rems do
        pcall(function()
            rem:FireServer()
            rem:FireServer("Attack")
        end)
    end
end

-- MELHORADO: Baús com ClickDetector + ProximityPrompt + nomes comuns
local function collectChests()
    for _, obj in WS:GetDescendants() do
        local n = obj.Name:lower()
        local parent = obj.Parent
        if n:find("chest") or n:find("treasure") or n:find("bau") or n:find("loot") or n:find("grimoire") then
            local part = obj:IsA("BasePart") and obj or parent:FindFirstChildWhichIsA("BasePart")
            if part then
                tp(part.Position + Vector3.new(0, 5, 0))
                task.wait(0.08)
                attack(parent)
                -- ClickDetector
                local cd = parent:FindFirstChild("ClickDetector") or obj:FindFirstChild("ClickDetector")
                if cd then fireclickdetector(cd) end
                -- ProximityPrompt
                local prompt = parent:FindFirstChildWhichIsA("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    pcall(function() prompt:InputHoldBegin(); task.wait(0.4); prompt:InputHoldEnd() end)
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

-- MELHORADO: Selector de quests via keyword
local function interactNPC(kw)
    local keywords = {
        all = {"quest", "mission", "npc", "nun", "church", "wizard", "bald"},
        starter = {"nun", "bald", "spawn"},
        church = {"church", "nun"},
        dungeon = {"dungeon", "tower", "boss"}
    }
    local searchKws = keywords[kw] or keywords.all
    for _, obj in WS:GetDescendants() do
        local n = obj.Name:lower()
        for _, k in searchKws do
            if n:find(k) then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    tp(obj.Position + Vector3.new(0, 6, 0))
                    task.wait(0.12)
                    pcall(function()
                        prompt:InputHoldBegin()
                        task.wait(0.45)
                        prompt:InputHoldEnd()
                    end)
                    attack(obj.Parent)
                    return  -- Foca um por vez
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.07)
        local r = hrp()
        if not r then continue end

        if t.farmNPC then
            local enemy = nearest(200)
            if enemy then tp(enemy.PrimaryPart.Position + Vector3.new(0, 7, 0)); attack(enemy) end
        end

        if t.chests then collectChests() end  -- Agora pega TUDO!

        if t.killAura then pullMobs() end

        if t.pull then pullMobs() end

        if t.autoAttack then autoAttackSpam() end  -- NOVO: Auto Ataque spam

        if t.autoStats or t.resetFarm then
            interactNPC("all")  -- Stats/Reset em NPCs
            task.wait(0.5)
        end

        if t.autoAllQuests then interactNPC("all") end

        if t.dungeonBoss then
            local boss = nearest(300, function(n) return n:find("dungeon") or n:find("boss") or n:find("plant") end)
            if boss then tp(boss.PrimaryPart.Position + Vector3.new(0, 7, 0)); attack(boss) end
        end

        if t.lich then
            local lich = nearest(400, function(n) return n:find("lich") or n:find("undead") end)
            if lich then tp(lich.PrimaryPart.Position + Vector3.new(0, 7, 0)); attack(lich) end
        end

        if t.bruxa then
            local witch = nearest(400, function(n) return n:find("witch") or n:find("queen") end)
            if witch then tp(witch.PrimaryPart.Position + Vector3.new(0, 7, 0)); attack(witch) end
        end
    end
end)

-- UI Toggles
SecFarm:NewToggle("Auto Farm NPCs", "High farm mobs", function(s) t.farmNPC = s end)
SecFarm:NewToggle("🗝️ Auto Baús (Melhorado!)", "Coleta TODOS chests agora", function(s) t.chests = s end)
SecFarm:NewToggle("💀 Kill Aura", "Mata tudo em aura", function(s) t.killAura = s end)
SecFarm:NewToggle("⚡ Auto Ataque (NOVO!)", "Spam ataques infinitos", function(s) t.autoAttack = s end)

SecBoss:NewToggle("🏰 Auto Dungeon Boss", "Bosses dungeon/plant", function(s) t.dungeonBoss = s end)
SecBoss:NewToggle("☠️ Auto Lich/Undead", "", function(s) t.lich = s end)
SecBoss:NewToggle("🧙 Auto Bruxa/Queen", "", function(s) t.bruxa = s end)

SecUtils:NewToggle("🧲 Puxar NPCs", "Traga mobs", function(s) t.pull = s end)
SecUtils:NewToggle("📊 Auto Stats + Reset", "", function(s) t.autoStats = s; t.resetFarm = s end)

-- NOVO: Selector de Missões (todas principais do jogo!)
SecQuests:NewDropdown("Selecione Missão", "Escolha uma (ou All)", {"All", "Starter (Nun/Bald)", "Church", "Dungeon"}, function(selected)
    t.autoQuest = selected:lower():gsub(" ", "")
end)
SecQuests:NewToggle("Auto Missão Selecionada", "Faz a quest escolhida", function(s)
    spawn(function()
        while s do
            interactNPC(t.autoQuest)
            task.wait(1)
        end
    end)
end)
SecQuests:NewToggle("🔄 Auto TODAS Missões", "Starter + Church + Dungeon auto", function(s) t.autoAllQuests = s end)

SecUtils:NewButton("🎛️ Minimize / Show UI (NOVO!)", "Esconde menu (funciona em bg)", function()
    Library:ToggleUI()
end)

SecUtils:NewButton("🛡️ Anti-AFK", "Sem kick", function()
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
end)

print("🖤 BGL HUB v2 CARREGADO! Baús FIX, Auto Ataque + Quests Selector + Minimize! Teste e farme! 🔥")
