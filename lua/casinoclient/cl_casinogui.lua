local D = {}
local AdjustFocus

local function InitD() 
	D.Frame = vgui.Create( "DFrame" )
	D.Frame:SetSize(650,400)
	D.Frame:SetPos(ScrW()/3,ScrH()/3)
	D.Frame:SetTitle( "Welcome 2 zee Gambling" )
	D.Frame:MakePopup()
	D.Frame:SetDeleteOnClose(false)
	D.Frame:SetAlpha(255)
	
	D.Button = vgui.Create("DButton", D.Frame)
	D.Button:SetSize(80,30)
	D.Button:SetPos(135,350)
	D.Button:SetText("Hit")
	D.Button.DoClick = function()
		RunConsoleCommand("casinomodhit")
	end
	
	D.Button = vgui.Create("DButton", D.Frame)
	D.Button:SetSize(80,30)
	D.Button:SetPos(425,350)
	D.Button:SetText("Stand")
	D.Button.DoClick = function()
		RunConsoleCommand("casinomodstand")
	end
	
	D.Button = vgui.Create("DButton", D.Frame)
	D.Button:SetSize(80,30)
	D.Button:SetPos(275,300)
	D.Button:SetText("Bet")
	D.Button.DoClick = function()
		RunConsoleCommand("casinomodblackjack",(tostring(D.Text:GetValue())))
		print(D.Text:GetValue())
	end
	
	D.Text = vgui.Create("DTextEntry",D.Frame)
	D.Text:SetSize(80,25)
	D.Text:SetPos(275,350)
	
	DLabel = vgui.Create( "DLabel", D.Frame )
	DLabel:SetPos( 325, 200 )
	DLabel:SetText( " " )
	DLabel:SizeToContents()
	DLabel:Center()
	DLabel:SetFont("TargetID")
	DLabel:SizeToContents()
	
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

 if !D.Frame then InitD() D.Frame:SetVisible(false) end

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
end

function open_blackjack()
	AdjustFocus(true) 
	
end

net.Receive("open_blackjack",open_blackjack)
net.Receive("blackjack_hand",updatehand)
net.Receive("casinomod_balance",updatebalance)



timer.Create("RenderTest",1,0,function()
local orgin_ents = ents.FindInSphere(LocalPlayer():GetPos(),256)
for k,v in pairs(ents.GetAll()) do
if(!table.HasValue(orgin_ents,v)) then
v:Entity:SetNoDraw( true )
--v:SetModelScale(0,0)
v:DrawShadow(false)
else
v:Entity:SetNoDraw( false )
--v:SetModelScale(1,0)
v:DrawShadow(false)
end
end
end)

function Draw1(ent)
--print(ent:GetModel())
ent:SetColor(255,0,0,50)
ent:SetAlpha(50)
end


-- hook.Add("Draw","DrawTest",Draw1)
hook.Add("Think","testthink",function()
for k,v in pairs(ents.GetAll()) do
v:DrawShadow(false)
end
end)