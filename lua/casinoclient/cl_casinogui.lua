local D = {}
local AdjustFocus

local function InitD() 
	D.Frame = vgui.Create( "DFrame" )
	D.Frame:SetSize(400,400)
	D.Frame:SetPos(ScrW()/3,ScrH()/3)
	D.Frame:SetTitle( "Welcome 2 zee Gambling" )
	D.Frame:MakePopup()
	D.Frame:SetDeleteOnClose(false)
	D.Frame:SetAlpha(255)
	
	D.Button = vgui.Create("DButton", D.Frame)
	D.Button:SetSize(80,30)
	D.Button:SetPos(10,350)
	D.Button:SetText("Hit")
	D.Button.DoClick = function()
		RunConsoleCommand("casinomodhit")
	end
	
	D.Button = vgui.Create("DButton", D.Frame)
	D.Button:SetSize(80,30)
	D.Button:SetPos(300,350)
	D.Button:SetText("Stand")
	D.Button.DoClick = function()
		RunConsoleCommand("casinomodstand")
	end
	
	D.Button = vgui.Create("DButton", D.Frame)
	D.Button:SetSize(80,30)
	D.Button:SetPos(150,300)
	D.Button:SetText("Bet")
	D.Button.DoClick = function()
		RunConsoleCommand("casinomodblackjack",(tostring(D.Text:GetValue())))
		print(D.Text:GetValue())
	end
	
	D.Text = vgui.Create("DTextEntry",D.Frame)
	D.Text:SetSize(80,25)
	D.Text:SetPos(150,350)
	
	DLabel = vgui.Create( "DLabel", D.Frame )
	DLabel:SetPos( 200, 200 )
	DLabel:SetText( "Hand" )
	DLabel:SizeToContents()
	DLabel:Center()
	DLabel:SetFont("TargetID")
	
	DLabelStatic = vgui.Create( "DLabel", D.Frame )
	DLabelStatic:SetPos( 10, 25 )
	DLabelStatic:SetText( "Balance:" )
	DLabelStatic:SizeToContents()
	DLabelStatic:SetAutoStretchVertical(true)
	DLabelStatic:SetFont("TargetID")
	DLabelStatic:SizeToContents()
	
	DLabelBalance = vgui.Create( "DLabel", D.Frame )
	DLabelBalance:SetPos( 100, 25 )
	DLabelBalance:SetText( "1000" )
	DLabelBalance:SizeToContents()
	DLabelBalance:SetAutoStretchVertical(true)
	DLabelBalance:SetFont("TargetID")
	DLabelBalance:SizeToContents()
	
	D.CloseButton = vgui.Create("DImageButton",D.Frame)
	D.CloseButton:SetImage("icon16/circlecross.png")
	D.CloseButton:SetWide(16)
	D.CloseButton:SetPos(375,375)
	D.CloseButton:SetTooltip("Remove Focus!")
	D.CloseButton.DoClick = function() 
		AdjustFocus(false)
	end
	D.CloseButton:SetAlpha(255)

end

AdjustFocus = function(bool)
	if !D.Frame then InitD() end
	D.Frame:SetKeyBoardInputEnabled(bool)
	D.Frame:SetMouseInputEnabled(bool)
	if bool then 
		D.Frame:SetVisible(true)
		//D.TextBox:RequestFocus() 
	end
end


hook.Add("GUIMousePressed", "Check4Gambling",function(enum,vec)
	if !D.Frame then return end
	local vecx,vecy = gui.MousePos()
	local x,y = D.Frame:GetPos()
	local x2,y2 = D.Frame:GetSize()
	x2,y2 = x2 + x, y2 + y
	
	if (vecx > x) && (vecx < x2) && (vecy > y) && (vecy < y2) then AdjustFocus(true) end
	
end)

function updatehand()

local currenthand = net.ReadString()
DLabel:SetText(tostring(currenthand))
DLabel:SizeToContents()
	DLabel:Center()
end

function updatebalance()
local currentmoney = net.ReadString()
if(!tonumber(currentmoney)) then currentmoney = "Loading..." end
DLabelBalance:SetText(tostring(currentmoney))
DLabelBalance:SizeToContents()
--DLabelBalance:Center()
end

function open_blackjack()
	AdjustFocus(true) 
	
end

net.Receive("open_blackjack",open_blackjack)
net.Receive("blackjack_hand",updatehand)
net.Receive("casinomod_balance",updatebalance)