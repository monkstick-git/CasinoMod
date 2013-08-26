CasinoMod = {}
MunModGoodEvents = {"Finds some money hidden behind his ear,  Fancy that?"," Bumps into a little green man with a pretty bitching beard.  After mumbling something about his pot 'o' gold, he gives you some money and staggers off."," The house was feeling generous and hands you some money."}
util.AddNetworkString("blackjack_hand")
util.AddNetworkString("casinomod_balance")
util.AddNetworkString("open_blackjack")

-- casinomodDefineCard() Call this command to get a random number between 1 and 11 (Aces are split 50/50, sometimes its a 1, sometimes 11)
-- CasinoMod.UpdateBalance (ply) This will update the players balance on the GUI,  ply is needed.
-- CasinoMod.AddExp(ply,expamount) Add or remove experiance points.

-- Configs
local CasinoPayTimer = 120 -- This is in seconds.  600 = 10 minutes
local RandomEvents = 1800 -- How often a random event happens.  This is in seconds.  1800 = 30 minutes
local RandomEventAmount = 10 -- When an event is triggered, whats the maximum amount we give them? (math.random(0,RandomEventAmount))
local ScratchCardOdds = 33 -- The chances of winning something.  This is out of 100 (so 33 means 1/3 of the time the player will win something)
local ScratchCardPayoutOdds = 33 -- The chances of winning something better a free go.  This is out of 100.  Same as above.
local ScratchCardMaxPayOut = 10 -- The maximum amount to payout for that winning card.
local ScratchCardCost = 1 -- How much do scratch cards cost
local HolWinAmount = 3 -- Whats the ratio when you win. (Eg: if it costs 4 to win, and the HolWinAmount is 3, then its  4 + (RoundsWon * 3) )
local HolCost = 4 -- How much Higher or lower costs to play
local RaffleCost = 10 -- How much it costs to enter into the raffle.
local ExpRatio = 1.1 -- The Exp levelup ratio.  Eg: 1.1 - if I needed 100 exp to level up and I leveled up, next time I will need 110. if it was 1.2 then I would need 120.  Its a percent.  1.1 = 10%, 1.3 = 30%
local BlackJackHouseLooseRatio = 17 -- The percent that the House will end up Busting.  Raise to make blackjack easier, lower to make it tougher.
-- DO NOT EDIT BELOW THIS

function CasinoMod.CreateTable() 
	MunModBetIndex = 0
	if(!sql.TableExists("munmod_player_info")) then
		MsgAll("Creating the player info table...")
		sql.Query("CREATE TABLE munmod_player_info (player_id varchar(255),player_money int,player_xp int,player_lvl varchar(255),player_xp_needed int,player_wins int,player_losses int,player_overallwon int,player_overalllost int,player_lasthere int,player_takenfunds int)")
		sql.Query("INSERT INTO munmod_player_info (`player_id`, `player_money`, `player_xp`, `player_lvl`, `player_xp_needed`, `player_wins`, `player_losses`, `player_overallwon`, `player_overalllost`, `player_lasthere`, `player_takenfunds`)VALUES ('house', '10000','0','1','100','0','0','0','0','0','1')" )
			if(sql.TableExists("munmod_player_info")) then
				MsgAll("Sucesfully made the player info table")
			else
				MsgAll("Something went horribly, horribly wrong!")
			end
	else
		MsgAll("The player info table already exists!")
	end
	
		if(!sql.TableExists("munmod_raffle")) then
		MsgAll("Creating the raffle table...")
		sql.Query("CREATE TABLE munmod_raffle (p_key varchar(255,player_id varchar(255),player_string varchar(255)")
			if(sql.TableExists("munmod_raffle")) then
				MsgAll("Sucesfully made the munmod_raffle table")
			else
				MsgAll("Something went horribly, horribly wrong!")
			end
	else
		MsgAll("The munmod_raffle table already exists!")
	end
	
	MunModBetTable = {}
	timer.Create("RandomFindMoney",RandomEvents,0,function()
	
	local RandomPlayer = math.random(table.Count(player.GetAll()))
	local randomamount = math.random(RandomEventAmount)
	PrintMessage( HUD_PRINTTALK,player.GetAll()[RandomPlayer]:Nick().." "..tostring(table.Random(MunModGoodEvents))..". +"..randomamount.." Chips!")
		local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..player.GetAll()[RandomPlayer]:SteamID().."'")
		local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")

		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + randomamount)).." WHERE player_id = '"..player.GetAll()[RandomPlayer]:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - randomamount)).." WHERE player_id = 'house'")
		CasinoMod.UpdateBalance (player.GetAll()[RandomPlayer])
	end)
	
timer.Create("PayPeople",CasinoPayTimer,0,function()
		for k,v in pairs(player.GetAll()) do
			local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..v:SteamID().."'") -- Get my money
			local CurrentLevel = sql.QueryValue("SELECT player_lvl FROM munmod_player_info WHERE player_id = '"..v:SteamID().."'") -- Get the House Money
				if(tonumber(CurrentMoney) < (10 + tonumber(CurrentLevel))) then  -- If My money is less than (Level + 10 chips)
				local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'") -- Get the house money
				sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((tonumber(HouseMoney + CurrentMoney) )).." WHERE player_id = 'house'") -- Give the house my remaining chips
				sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((10 + tonumber(CurrentLevel))).." WHERE player_id = '"..v:SteamID().."'") -- Add Chips to my account.  
					local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
					local RemoveHouseMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((tonumber(HouseMoney) - (10 + tonumber(CurrentLevel)))).." WHERE player_id = 'house'")
					v:PrintMessage( HUD_PRINTTALK,"You have been given "..(10 + tonumber(CurrentLevel)).." chips by the house to fuel your gambling habit.")
					CasinoMod.UpdateBalance (v)
				end
		end
	end)
	
end

function CasinoMod.RemoveTable()
	if(sql.TableExists("munmod_raffle")) then
		MsgAll("The raffle table exists, dropping...")
		sql.Query("DROP TABLE munmod_raffle")
			if(!sql.TableExists("munmod_raffle")) then
				MsgAll("Sucessfuly dropped the raffle table!")
			end
	end
	
			if(!sql.TableExists("munmod_raffle")) then
		MsgAll("Creating the raffle table...")
		sql.Query("CREATE TABLE munmod_raffle (p_key varchar(255),player_id varchar(255),player_string varchar(255))")
			if(sql.TableExists("munmod_raffle")) then
				MsgAll("Sucesfully made the munmod_raffle table")
			else
				MsgAll("Something went horribly, horribly wrong!")
			end
	else
		MsgAll("The munmod_raffle table already exists!")
	end
end

function CasinoMod.RemoveMainTable()()
	if(sql.TableExists("munmod_player_info")) then
		MsgAll("The munmod_player_info table exists, dropping...")
		sql.Query("DROP TABLE munmod_player_info")
			if(!sql.TableExists("munmod_player_info")) then
				MsgAll("Sucessfuly dropped the munmod_player_info table!")
			end
	end
	
			
		
	
			if(!sql.TableExists("munmod_player_info")) then
		MsgAll("Creating the munmod_player_info table...")
		sql.Query("CREATE TABLE munmod_player_info (player_id varchar(255),player_money int,player_xp int,player_lvl varchar(255),player_xp_needed int,player_wins int,player_losses int,player_overallwon int,player_overalllost int,player_lasthere int,player_takenfunds int)")
		MsgAll("Created table, now trying to insert information into it")
		sql.Query("INSERT INTO munmod_player_info (`player_id`, `player_money`, `player_xp`, `player_lvl`, `player_xp_needed`, `player_wins`, `player_losses`, `player_overallwon`, `player_overalllost`, `player_lasthere`, `player_takenfunds`)VALUES ('house', '10000','0','1','100','0','0','0','0','0','1')" )
		
			if(sql.TableExists("munmod_player_info")) then
				MsgAll("Sucesfully made the munmod_player_info table")
			else
				MsgAll("Something went horribly, horribly wrong!")
			end
	else
		MsgAll("The munmod_player_info table already exists!")
	end
end

function CasinoMod.PlayerSpawn(ply)
	if(!sql.Query("SELECT player_id, player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")) then
		MsgAll("THE PLAYERS NOT IN THE DATABASE, ADDING THEM NOW")
		sql.Query("INSERT INTO munmod_player_info (`player_id`, `player_money`, `player_xp`, `player_lvl`, `player_xp_needed`, `player_wins`, `player_losses`, `player_overallwon`, `player_overalllost`, `player_lasthere`, `player_takenfunds`)VALUES ('"..ply:SteamID().."', '100','0','1','50','0','0','0','0','"..os.time().."','0')" )
		local result = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			timer.Simple(2,function()
			PrintMessage( HUD_PRINTTALK,"[Muneris Casino Mod APLHA 0.1] - Welcome "..ply:Nick()..". You have received ❉"..result.." Chips as a gesture of good will!")
			end)
	else
		timer.Simple(2,function()
			local money = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			local Exp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			local Level = sql.QueryValue("SELECT player_lvl FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			PrintMessage( HUD_PRINTTALK,"[Muneris Casino Mod APLHA 0.1] - Welcome back "..ply:Nick()..".  You currently have ❉"..money.." Chips! ".." and have "..Exp.." Experiance Points. You are Level "..Level)
			ply:PrintMessage( HUD_PRINTTALK,"There are currently 4 commands.  /quit (to leave Higher or lower), /hol to start Higher or lower and /buyticket.")
			ply:PrintMessage( HUD_PRINTTALK,"To check your wallet, type /balance, and to give money to someone, use /give NAME AMOUNT")
		end)
end
CasinoMod.UpdateBalance (ply)
end

hook.Add( "PlayerInitialSpawn", "CasinoModPlayerSpawn", CasinoMod.PlayerSpawn )
hook.Add( "Initialize", "CasinoModCreateTable", CasinoMod.CreateTable )

--########## Chat Commands start Here ##########

function CasinoMod.ChatMessages(ply,msg,team) 
	local Target = 0
	local Message = string.Explode(" ",msg)
	
	if(Message[1]=="/give" or Message[1]=="!give") then 
		CasinoMod.Give(ply,_,Message)
		return ""
	end
		 
	if(Message[1]=="/balance" or Message[1]=="!balance") then
		CasinoMod.Balance(ply)
		return ""
	end	
	
	if(Message[1]=="/gambling") then
		CasinoMod.Gui(ply)
		CasinoMod.UpdateBalance(ply)
		return ""
	end
	
	if(Message[1]=="!buycard" or Message[1]=="/buycard") then
		CasinoMod.ScratchChard(ply)
		return ""
	end

	if((Message[1]=="/higherorlower" or Message[1]=="/hol" or Message[1]=="!hol" or Message[1]=="!higherorlower") and ply.PlayingHigherOrLower != true) then
		CasinoMod.HigherOrLower(ply)
		return ""
	else if(ply.PlayingHigherOrLower == true and Message[1]=="/higherorlower" or Message[1]=="/hol" or Message[1]=="!hol" or Message[1]=="!higherorlower") then ply:PrintMessage( HUD_PRINTTALK,"You are currently in the middle of a game!") return "" end
	end

	if(Message[1]=="/higher" and ply.PlayingHigherOrLower == true) then
		local Current = math.random(10)
			if(Current >= ply.CurrentHand) then
				ply.CurrentHand = Current
				ply.RoundsWon = ply.RoundsWon + 1
				ply:PrintMessage( HUD_PRINTTALK," Correct! You have won "..tostring(ply.RoundsWon).." Games! - The number is "..Current..", Higher or lower?")
				else
				if(ply.CurrentHand == 2 and Current == 1) then ply:PrintMessage( HUD_PRINTTALK,"Fuck you, its 1, You loose.  Type /hol to play again.") 
				CasinoMod.AddExp(ply,ply.RoundsWon)
				else
					ply:PrintMessage( HUD_PRINTTALK," Incorrect! ".."The number was "..Current..".  You loose!  Type /hol to play again")
					CasinoMod.AddExp(ply,ply.RoundsWon)
				end
			ply.PlayingHigherOrLower = false
			end
	CasinoMod.UpdateBalance(ply)
	return ""
	
	end
	
	if(Message[1]=="/lower" and ply.PlayingHigherOrLower == true) then
		local Current = math.random(10)
			if(Current <= ply.CurrentHand) then
				ply.CurrentHand = Current
				ply.RoundsWon = ply.RoundsWon + 1
				ply:PrintMessage( HUD_PRINTTALK," Correct! You have won "..tostring(ply.RoundsWon).." Games! - The number is "..Current..", Higher or lower?")
			else
				if(ply.CurrentHand == 9 and Current == 10) then ply:PrintMessage( HUD_PRINTTALK,"Fuck you, its 10, You loose.  Type /hol to play again.")
				CasinoMod.AddExp(ply,ply.RoundsWon)
				else
					ply:PrintMessage( HUD_PRINTTALK," Incorrect! ".."The number was "..Current..".  You loose!  Type /hol to play again")
					ply.PlayingHigherOrLower = false
					CasinoMod.AddExp(ply,ply.RoundsWon)
				end
				
			end
			CasinoMod.UpdateBalance (ply)
			return ""
			
	end
	
	if(Message[1] == "/quit" and ply.PlayingHigherOrLower == true) then
		if(ply.RoundsWon <4) then ply:PrintMessage( HUD_PRINTTALK,"You cannot quit a game until you have at least 4 wins")
		else	
			ply.PlayingHigherOrLower = false
			PrintMessage( HUD_PRINTTALK,"[Muneris Casino Mod APLHA 0.1] - "..ply:Nick().." has walked away from Higher or lower a winner.  They won "..(ply.RoundsWon * HolWinAmount).." Coins!")
			CasinoMod.AddExp(ply,ply.RoundsWon * 3)
			local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
			
			local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + (HolCost +(ply.RoundsWon * HolWinAmount)))).." WHERE player_id = '"..ply:SteamID().."'")
			local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - (HolCost +(ply.RoundsWon * HolWinAmount)))).." WHERE player_id = 'house'")
		end	
			CasinoMod.UpdateBalance (ply)
			return ""
			
	end

	if(Message[1]=="/buyticket" or Message[1]=="!buyticket") then
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
	
	if(tonumber(CurrentMoney) >= RaffleCost) then
		
		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney - (RaffleCost))).." WHERE player_id = '"..ply:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney + (RaffleCost))).." WHERE player_id = 'house'")
		
		local TotalTickets = sql.QueryValue("SELECT count(*) from munmod_raffle")
		local PlayerID = ply:SteamID()
		local PlayerString = ply:Nick()
		sql.Query("INSERT INTO munmod_raffle (`p_key`, `player_id`, `player_string`)VALUES ('"..(TotalTickets + 1).."', '"..PlayerID.."','"..PlayerString.."')" )
		local TotalTickets = tonumber(sql.QueryValue("SELECT count(*) from munmod_raffle"))*RaffleCost
		
		PrintMessage( HUD_PRINTTALK,ply:Nick().." entered into the raffle.  Current prize: "..TotalTickets)
		--CasinoMod.AddExp(ply,10)
	else
	ply:PrintMessage( HUD_PRINTTALK,ply:Nick().." You do not have enough chips,  you need.. "..RaffleCost.." or more to enter.")
	end
	CasinoMod.UpdateBalance (ply)
	return ""
	
	end
	
	if(Message[1]=="/runraffle" and ply:IsAdmin()) then
	local TotalTickets = tonumber(sql.QueryValue("SELECT count(*) from munmod_raffle"))
	local WinningTicket = math.random(TotalTickets)
	local RaffleWinner = sql.QueryValue("SELECT player_id FROM munmod_raffle WHERE p_key = '"..tonumber(WinningTicket).."'")
	local RaffleWinnerName = sql.QueryValue("SELECT player_string FROM munmod_raffle WHERE p_key = '"..WinningTicket.."'")
	PrintMessage( HUD_PRINTTALK,"Winner of the raffle is..."..RaffleWinnerName.."! Congratulations, you won "..(TotalTickets*RaffleCost).." Chips!")
	
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..RaffleWinner.."'")
	sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + (TotalTickets*RaffleCost))).." WHERE player_id = '"..RaffleWinner.."'")
	local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
	sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - (TotalTickets*RaffleCost))).." WHERE player_id = 'house'")
	CasinoMod.AddExp(RaffleWinner,TotalTickets*RaffleCost)
	munmodremovetable()
	return ""
	end
	
	-- if(Message[1]=="/blackjack" and ply.PlayingBlackJack != true) then
		-- local args = tostring(Message[2])
			-- MsgAll("YOUR BET AMOUNT SHOULD OF BEEN "..args)
		-- casinomodblackjack(ply,_,args)
	
		-- return ""
	-- end
	
	-- if(Message[1]=="/hit" and ply.PlayingBlackJack == true) then
		-- casinomodhit(ply)
		-- return ""
	-- end
	
	-- if(Message[1]=="/stand" and ply.PlayingBlackJack == true) then
	-- casinomodstand(ply)
	-- return ""
	-- end
	
	if(Message[1]=="/exp") then
		CasinoMod.ShowExp(ply)
		local CurrentWins = sql.QueryValue("SELECT player_wins FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		local CurrentLose = sql.QueryValue("SELECT player_losses FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		
		local CurrentWinnings = sql.QueryValue("SELECT player_overallwon FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		local Currentlosses = sql.QueryValue("SELECT player_overalllost FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		PrintMessage(HUD_PRINTTALK,"Current Wins stand at: "..CurrentWins.." Current Losses stand at: "..CurrentLose)
		PrintMessage(HUD_PRINTTALK,"Current Winnings stand at: "..CurrentWinnings.." | Current Losses stand at: "..Currentlosses)
		return ""
	end
	
		if(Message[1]=="/house") then
		
			local CurrentExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = 'house'")
			local CurrentLevel = sql.QueryValue("SELECT player_lvl FROM munmod_player_info WHERE player_id = 'house'")
			local NeededExp = sql.QueryValue("SELECT player_xp_needed FROM munmod_player_info WHERE player_id = 'house'")
			PrintMessage( HUD_PRINTTALK,"House Level: "..CurrentLevel.." | Curent Exp: "..CurrentExp.." / "..NeededExp)
		
		
		local CurrentWins = sql.QueryValue("SELECT player_wins FROM munmod_player_info WHERE player_id = 'house'")
		local CurrentLose = sql.QueryValue("SELECT player_losses FROM munmod_player_info WHERE player_id = 'house'")
		
		local CurrentWinnings = sql.QueryValue("SELECT player_overallwon FROM munmod_player_info WHERE player_id = 'house'")
		local Currentlosses = sql.QueryValue("SELECT player_overalllost FROM munmod_player_info WHERE player_id = 'house'")
		PrintMessage(HUD_PRINTTALK,"House Current Wins stand at: "..CurrentWins.." Current Losses stand at: "..CurrentLose)
		PrintMessage(HUD_PRINTTALK,"House Current Winnings stand at: "..CurrentWinnings.." | Current Losses stand at: "..Currentlosses)
		return ""
	end
end

function casinomodwinmessage(ply,amount)
PrintMessage( HUD_PRINTTALK,ply:Nick().." won ❉"..amount.." Chips!")
end

function casinomodscratchcard(ply)
		local CurrentMoney = casinomodgetmoney(ply)
			if(tonumber(CurrentMoney) >= 1) then
				local MunModRemovePlayerMoney = CasinoMod.TakePlayerChips(ply,ScratchCardCost)
				
				local Odds = math.random(100)
					if(Odds <= ScratchCardOdds) then
						local PrizeOdds = math.random(100)
							if(PrizeOdds < ScratchCardPayoutOdds) then
								local PayOut = math.random(ScratchCardMaxPayOut) casinomodwinmessage(ply,PayOut) 
								CasinoMod.AddPlayerChips(ply,PayOut)
							else
								ply:PrintMessage( HUD_PRINTTALK,ply:Nick().." You win a free go!")
								CasinoMod.AddPlayerChips(ply,ScratchCardCost)
							end
					else
						ply:PrintMessage( HUD_PRINTTALK," You didn't win anything")
					end
			end
	CasinoMod.UpdateBalance (ply)
end

function manualstarttimer1()
	timer.Create("PayPeople",60,0,function()
		for k,v in pairs(player.GetAll()) do
			local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..v:SteamID().."'")
			local CurrentLevel = sql.QueryValue("SELECT player_lvl FROM munmod_player_info WHERE player_id = '"..v:SteamID().."'")
				if(tonumber(CurrentMoney) < (10 + tonumber(CurrentLevel))) then sql.Query("UPDATE munmod_player_info SET player_money = "..tostring(10 + tonumber(CurrentLevel)).." WHERE player_id = '"..v:SteamID().."'")
					local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
					local RemoveHouseMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((tonumber(HouseMoney) - (10 + tonumber(CurrentLevel)))).." WHERE player_id = 'house'")
					v:PrintMessage( HUD_PRINTTALK,"You have been given "..(10 + tonumber(CurrentLevel)).." chips by the house to fuel your gambling habit.")
					CasinoMod.UpdateBalance (v)
				end
		end
	end)
	
end
--##Blackjack stuff##--
function casinomodblackjack(ply,_,args)
	if(ply.PlayingBlackJack != true) then  
		if(!tonumber(args[1])) then ply.BlackJackBet = 4 else ply.BlackJackBet = math.floor(math.abs(tonumber(args[1]))) end
		local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
		if(tonumber(CurrentMoney) < tonumber(ply.BlackJackBet)) then return end
		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney - (ply.BlackJackBet))).." WHERE player_id = '"..ply:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney + (ply.BlackJackBet))).." WHERE player_id = 'house'")
		ply.hascharlie = false
		ply.PlayingBlackJack = true
		
		ply.HouseHand = casinomodrandomcard()
		
		ply.Hand1 = casinomodrandomcard()
		ply.Hand2 = casinomodrandomcard()
		ply.Hand3 = casinomodrandomcard()
		ply.Hand4 = casinomodrandomcard()
		ply.Hand5 = casinomodrandomcard()
		
		ply.blackjackhand = (ply.Hand1 + ply.Hand2)
		while(ply.blackjackhand > 21) do
			ply.Hand1 = casinomodrandomcard()
			ply.Hand2 = casinomodrandomcard()
			ply.blackjackhand = (ply.Hand1 + ply.Hand2)
		end
		
		ply.Hand1String = casinomodDefineCard(ply.Hand1)
		ply.Hand2String = casinomodDefineCard(ply.Hand2)
		ply.Hand3String = casinomodDefineCard(ply.Hand3)
		ply.Hand4String = casinomodDefineCard(ply.Hand4)
		ply.Hand5String = casinomodDefineCard(ply.Hand5)
		
		ply:PrintMessage( HUD_PRINTTALK,"Hand is "..ply.Hand1String.." - "..ply.Hand2String.." total is: "..(ply.Hand1 +ply.Hand2+ply.Hand3+ply.Hand4+ply.Hand5))
		
		CasinoMod.NetSendHand(ply,(""..ply.Hand1String.." - "..ply.Hand2String.."".." | Total: "..ply.blackjackhand.." - House Has a : "..ply.HouseHand))
		
		CasinoMod.UpdateBalance (ply)
		ply.Cards = 2
		end
end 

function casinomodrandomcard()
local RandomCard = math.random(1,13)
	if RandomCard == 1 then if(math.random(2) == 1) then Card = 11 else Card = 1 end
	elseif RandomCard == 11 then Card = 10
	elseif RandomCard == 12 then Card = 10 
	elseif RandomCard == 13 then Card = 10
	else
	Card = RandomCard
	end
return Card
end

function casinomodDefineCard(In)
	if In == 1 then Out = "Ace Low"
	elseif In == 11 then Out = "Ace High"
	elseif In == 10 then Out =  table.Random({"Jack","Queen","King"})
	else
	Out = In
	end
return Out
end

function casinomodhit(ply)
if(ply.PlayingBlackJack == true) then
ply.Cards = ply.Cards + 1
		ply.blackjackhand = (ply.Hand1 + ply.Hand2)
		if(ply.Cards == 3) then ply.blackjackhand = (ply.Hand1 + ply.Hand2 + ply.Hand3) ply.blackjackstring = (""..ply.Hand1String.." - "..ply.Hand2String.." - "..ply.Hand3String.." | Total: "..ply.blackjackhand)
		elseif(ply.Cards == 4) then ply.blackjackhand = (ply.Hand1 + ply.Hand2 + ply.Hand3 + ply.Hand4) ply.blackjackstring =(""..ply.Hand1String.." - "..ply.Hand2String.." - "..ply.Hand3String.." - "..ply.Hand4String.." | Total: "..ply.blackjackhand)
		elseif(ply.Cards == 5) then ply.blackjackhand = (ply.Hand1 + ply.Hand2 + ply.Hand3 + ply.Hand4 + ply.Hand5) ply.blackjackstring = (""..ply.Hand1String.." - "..ply.Hand2String.." - "..ply.Hand3String.." - "..ply.Hand4String.." - "..ply.Hand5String.." | Total: "..ply.blackjackhand) ply.hascharlie = true
		end
			if(ply.blackjackhand > 21) then
				ply.PlayingBlackJack = false
				ply:PrintMessage( HUD_PRINTTALK,"You lose with "..ply.blackjackstring.." | ("..ply.blackjackhand..")")
				CasinoMod.NetSendHand(ply,"You lose with "..ply.blackjackstring.." | ("..ply.blackjackhand..")")
				CasinoMod.AddExp(ply,(tonumber(ply.BlackJackBet) / 2))
				ply.blackjackhand = 0
				CasinoMod.OverallWinsAndLosses(ply,"lose")
				CasinoMod.OverallLosses(ply,ply.BlackJackBet)
				else
				ply:PrintMessage( HUD_PRINTTALK,"Hand: "..ply.blackjackstring.." | ("..ply.blackjackhand..")")
				CasinoMod.NetSendHand(ply,ply.blackjackstring)
			end
end
		return ""
end

function casinomodstand(ply) 
if(ply.PlayingBlackJack == true) then
	local HouseHand = ply.HouseHand
	local HouseString = casinomodDefineCard(ply.HouseHand).." - "
	local HouseLoose = math.random(100)  
	local A = 0
	local HouseCardTable = {}
	while HouseHand < BlackJackHouseLooseRatio do A=A+1 local TempHand = (casinomodrandomcard())  HouseHand = HouseHand+TempHand HouseCardTable[A] = (tostring(casinomodDefineCard(TempHand))) end
	
	HouseString = HouseString..table.concat(HouseCardTable," - ").." | ("..HouseHand..")"
	
	if (ply.hascharlie == true) then
		CasinoMod.AddExp(ply,ply.BlackJackBet * 2) CasinoMod.NetSendHand(ply,("You win with a Charlie!"))
		CasinoMod.AddPlayerChips(ply,ply.BlackJackBet * 2)
		PrintMessage( HUD_PRINTTALK,ply:Nick().." Won "..(ply.BlackJackBet * 2).." Chips from the House with a Charlie!!")
		
		ply.PlayingBlackJack = false
		ply.hascharlie = false
		CasinoMod.OverallWinsAndLosses(ply,"win")
		CasinoMod.OverallWinnings(ply,ply.BlackJackBet)
		return
	end
	
	if (HouseHand > 21) then 
	ply:PrintMessage( HUD_PRINTTALK,"You win, House bust with: "..HouseString) CasinoMod.NetSendHand(ply,("You win, House bust with: "..HouseString))
		CasinoMod.NetSendHand(ply,("You win, House bust with: "..HouseString))
		CasinoMod.AddExp(ply,ply.BlackJackBet * 2)
		CasinoMod.AddPlayerChips(ply,ply.BlackJackBet * 2)
		PrintMessage( HUD_PRINTTALK,ply:Nick().." Won "..(ply.BlackJackBet * 2).." Chips from the House!")
		CasinoMod.OverallWinsAndLosses(ply,"win")
		CasinoMod.OverallWinnings(ply,ply.BlackJackBet)
	else
	if (HouseHand > ply.blackjackhand) then ply:PrintMessage( HUD_PRINTTALK,"You lose, House hand is: "..HouseString) CasinoMod.AddExp(ply,ply.BlackJackBet / 2) CasinoMod.NetSendHand(ply,("You lose, House hand is: "..HouseString)) CasinoMod.OverallWinsAndLosses(ply,"lose") CasinoMod.OverallLosses(ply,ply.BlackJackBet)  end
	if(HouseHand < ply.blackjackhand) then ply:PrintMessage( HUD_PRINTTALK,"You win, House hand is: "..HouseString) CasinoMod.AddExp(ply,ply.BlackJackBet * 2) CasinoMod.NetSendHand(ply,("You win, House hand is: "..HouseString))
		CasinoMod.AddPlayerChips(ply,ply.BlackJackBet * 2)
		PrintMessage( HUD_PRINTTALK,ply:Nick().." Won "..(ply.BlackJackBet * 2).." Chips from the House!")
		CasinoMod.OverallWinsAndLosses(ply,"win")
		CasinoMod.OverallWinnings(ply,ply.BlackJackBet)
	end 
	if(HouseHand == ply.blackjackhand) then ply:PrintMessage( HUD_PRINTTALK,"Draw, House hand is: "..HouseString) CasinoMod.NetSendHand(ply,("Draw, House hand is: "..HouseString))
			CasinoMod.AddExp(ply,ply.BlackJackBet)
			CasinoMod.AddPlayerChips(ply,ply.BlackJackBet )
	end 
	end
	ply.PlayingBlackJack = false
end
CasinoMod.UpdateBalance (ply)
end
--##End of blackjack stuff##--

function CasinoMod.AddExp(ply,expamount)

	local Exp = math.floor(expamount)
	ply:PrintMessage( HUD_PRINTCENTER,"You recieved "..Exp.." Experiance points!")
	local CurrentExp = 0
	CurrentExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")	
	local HouseExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = 'house'")
	local MunModAddXp = sql.Query("UPDATE munmod_player_info SET player_xp = "..tonumber((tonumber(CurrentExp) + Exp)).." WHERE player_id = '"..ply:SteamID().."'")
	local MunModAddHouseXp = sql.Query("UPDATE munmod_player_info SET player_xp = "..tostring((HouseExp + (Exp / 2))).." WHERE player_id = 'house'")
	CurrentExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local HouseExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = 'house'")
	local NeededExp = sql.QueryValue("SELECT player_xp_needed FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local HouseNeededExp = sql.QueryValue("SELECT player_xp_needed FROM munmod_player_info WHERE player_id = 'house'")
	
		while (tonumber(CurrentExp) >= tonumber(NeededExp)) do
			local LeftOver = tonumber(tonumber(CurrentExp) - tonumber(NeededExp))
			local CurrentLevel = sql.QueryValue("SELECT player_lvl FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			local MunModAddLevel = sql.Query("UPDATE munmod_player_info SET player_lvl = "..tostring((CurrentLevel + 1)).." WHERE player_id = '"..ply:SteamID().."'")
			local MunModAddXp = sql.Query("UPDATE munmod_player_info SET player_xp = "..tostring((LeftOver)).." WHERE player_id = '"..ply:SteamID().."'")
			local NeededExpOld = sql.QueryValue("SELECT player_xp_needed FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			local NewNeededExp = NeededExpOld * ExpRatio
			local MunModSetNeeded = sql.Query("UPDATE munmod_player_info SET player_xp_needed = "..tostring((NewNeededExp)).." WHERE player_id = '"..ply:SteamID().."'")
			PrintMessage( HUD_PRINTTALK,ply:Nick().." Has Leveld up to "..(CurrentLevel+1))
			CurrentExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")	
		end
		
		while (tonumber(HouseExp) >= tonumber(HouseNeededExp)) do
			local LeftOver = tonumber(tonumber(HouseExp) - tonumber(HouseNeededExp))
			local CurrentLevel = sql.QueryValue("SELECT player_lvl FROM munmod_player_info WHERE player_id = 'house'")
			local MunModAddLevel = sql.Query("UPDATE munmod_player_info SET player_lvl = "..tostring((CurrentLevel + 1)).." WHERE player_id = 'house'")
			local MunModAddXp = sql.Query("UPDATE munmod_player_info SET player_xp = "..tostring((LeftOver)).." WHERE player_id = 'house'")
			local NeededExpOld = sql.QueryValue("SELECT player_xp_needed FROM munmod_player_info WHERE player_id = 'house'")
			local NewNeededExp = NeededExpOld * ExpRatio
			local MunModSetNeeded = sql.Query("UPDATE munmod_player_info SET player_xp_needed = "..tostring((NewNeededExp)).." WHERE player_id = 'house'")
			PrintMessage( HUD_PRINTTALK,"The House Has Leveled up to "..(CurrentLevel+1))
			HouseExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = 'house'")	
		end
end

function CasinoMod.Give(ply,_,args)
	local Target = 0
			if(!tonumber(args[3])) then PrintMessage( HUD_PRINTTALK,args[3].." is not an integer.  4 is an integer.  Four is a string.")  return "" end
			local money2 = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			if( tonumber(money2) < tonumber(args[3]) ) then return end
			if(tonumber(args[3]) <= 0) then return end
			if(tonumber(args[3]) > (money2 / 5)) then PrintMessage(HUD_PRINTTALK,"You cannot give more than 20% of your funds!") return "" end
			local MunPlayerName = args[2]
			
				local MunMoney = math.floor(args[3])
					for k,v in pairs(player.GetAll()) do if (string.find(string.lower(v:Name()), string.lower(MunPlayerName)))then 

						Target = Target + 1
						TargetName = v
							end
							end
							if(Target == 0) then PrintMessage(HUD_PRINTTALK,"[MunMod] - No player found with that name") end
								if(Target > 1) then PrintMessage(HUD_PRINTTALK,"[MunMod] - Too many players found. Try refining the search criteria") end
								if(Target == 1) then
								local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
								local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney - MunMoney)).." WHERE player_id = '"..ply:SteamID().."'")
								local CurrentMoney2 = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..TargetName:SteamID().."'")
								local MunModGivePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney2 + MunMoney)).." WHERE player_id = '"..TargetName:SteamID().."'")
								PrintMessage( HUD_PRINTTALK,ply:Nick().." gave "..TargetName:Nick().."  ❉"..MunMoney.." Chips!")
								
								local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
								local CurrentMoney2 = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..TargetName:SteamID().."'")
								end
			CasinoMod.UpdateBalance (ply)
end

function CasinoMod.Balance(ply)
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
	PrintMessage( HUD_PRINTTALK,"[Muneris Casino Mod APLHA 0.1] - "..ply:Nick().." has ❉"..CurrentMoney.." Chips and the House has ❉"..HouseMoney)
	
end

function CasinoMod.UpdateBalance (ply)
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	net.Start("casinomod_balance")
	net.WriteString(tostring(CurrentMoney))
	net.Send(ply)
end

function CasinoMod.NetSendHand(ply,hand)
net.Start("blackjack_hand")
net.WriteString(tostring(hand))
net.Send(ply)
end

function CasinoMod.Gui(ply)
net.Start("open_blackjack")
net.Send(ply)
end

function CasinoMod.ShowExp(ply)
	local CurrentExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local CurrentLevel = sql.QueryValue("SELECT player_lvl FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local NeededExp = sql.QueryValue("SELECT player_xp_needed FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	ply:PrintMessage( HUD_PRINTTALK,"Level: "..CurrentLevel.." | Curent Exp: "..CurrentExp.." / "..NeededExp)
end

function CasinoMod.OverallWinsAndLosses(ply,result)
	if(result == "win") then
		local CurrentWins = sql.QueryValue("SELECT player_wins FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		sql.Query("UPDATE munmod_player_info SET player_wins = "..tostring((CurrentWins + 1)).." WHERE player_id = '"..ply:SteamID().."'")
		
		local CurrentLossesServer = sql.QueryValue("SELECT player_losses FROM munmod_player_info WHERE player_id = 'house'")
		sql.Query("UPDATE munmod_player_info SET player_losses = "..tostring((CurrentLossesServer + 1)).." WHERE player_id = 'house'")
	else
		local CurrentLosses = sql.QueryValue("SELECT player_losses FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		sql.Query("UPDATE munmod_player_info SET player_losses = "..tostring((CurrentLosses + 1)).." WHERE player_id = '"..ply:SteamID().."'")
		
		local CurrentWinsServer = sql.QueryValue("SELECT player_wins FROM munmod_player_info WHERE player_id = 'house'")
		sql.Query("UPDATE munmod_player_info SET player_wins = "..tostring((CurrentWinsServer + 1)).." WHERE player_id = 'house'")
	end
end

function CasinoMod.OverallLosses(ply,amount)
	MsgAll("Recieved a command to fuck with losses.  amount was "..amount)
	local CurrentLoss = sql.QueryValue("SELECT player_overalllost FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	sql.Query("UPDATE munmod_player_info SET player_overalllost = "..tostring((CurrentLoss + amount)).." WHERE player_id = '"..ply:SteamID().."'")

	local Currentwinnings = sql.QueryValue("SELECT player_overallwon FROM munmod_player_info WHERE player_id = 'house'")
	sql.Query("UPDATE munmod_player_info SET player_overallwon = "..tostring((Currentwinnings + amount)).." WHERE player_id = 'house'")
	
	end

function CasinoMod.OverallWinnings(ply,amount)
	local Currentwinnings = sql.QueryValue("SELECT player_overallwon FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	sql.Query("UPDATE munmod_player_info SET player_overallwon = "..tostring((Currentwinnings + amount)).." WHERE player_id = '"..ply:SteamID().."'")

	local CurrentLoss = sql.QueryValue("SELECT player_overalllost FROM munmod_player_info WHERE player_id = 'house'")
	sql.Query("UPDATE munmod_player_info SET player_overalllost = "..tostring((CurrentLoss + amount)).." WHERE player_id = 'house'")
	
end

function CasinoMod.AddPlayerChips(ply,amount)
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
		
	local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring(CurrentMoney + amount).." WHERE player_id = '"..ply:SteamID().."'")
	local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring(HouseMoney - amount).." WHERE player_id = 'house'")
end

function CasinoMod.TakePlayerChips(ply,amount)
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
		
	local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring(CurrentMoney - amount).." WHERE player_id = '"..ply:SteamID().."'")
	local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring(HouseMoney + amount).." WHERE player_id = 'house'")
end

function CasinoMod.GetPlayerMoney(ply)
local TempMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
return TempMoney
end

function CasinoMod.GetHouseMoney()
local TempMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
return TempMoney
end

function CasinoMod.HigherOrLower(ply)
		local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
		if(tonumber(CurrentMoney) < HolCost) then ply:PrintMessage( HUD_PRINTTALK,"You dont have enough chips") return end
		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney - HolCost)).." WHERE player_id = '"..ply:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney + HolCost)).." WHERE player_id = 'house'")
		
		ply.PlayingHigherOrLower = true
		PrintMessage( HUD_PRINTTALK,"[Muneris Casino Mod APLHA 0.1] - "..ply:Nick().." started playing higher or lower")
		ply.CurrentHand = math.random(2,8)
		ply:PrintMessage( HUD_PRINTTALK,"/quit to take your winnings and go. /higher and /lower.  You must win 4+ to break even")
		ply:PrintMessage( HUD_PRINTTALK,"Balance: "..CurrentMoney.." Your current hand is "..ply.CurrentHand..", Higher or Lower?")
		ply.RoundsWon = 0
		
		CasinoMod.UpdateBalance (ply)
end


hook.Add("PlayerSay", "casinomodmessages", casinomodmessages )
concommand.Add("CasinoMod.Gui",CasinoMod.Gui)
concommand.Add("casinomodhit",casinomodhit)
concommand.Add("casinomodstand",casinomodstand)
concommand.Add("casinomodblackjack",casinomodblackjack)
concommand.Add("CasinoMod.UpdateBalance ",CasinoMod.UpdateBalance )