MunModGoodEvents = {"Finds some money hidden behind his ear,  Fancy that?"," Bumps into a little green man with a pretty bitching beard.  After mumbling something about his pot 'o' gold, he gives you some money and staggers off."," The house was feeling generous and hands you some money."}
util.AddNetworkString("blackjack_hand")
util.AddNetworkString("casinomod_balance")
util.AddNetworkString("open_blackjack")
function munmodcreatetable()
	MunModBetIndex = 0
	if(!sql.TableExists("munmod_player_info")) then
		MsgAll("Creating the player info table...")
		sql.Query("CREATE TABLE munmod_player_info (player_id varchar(255),player_money int,player_xp int,player_lvl varchar(255),player_xp_needed int)")
		sql.Query("INSERT INTO munmod_player_info (`player_id`, `player_money`, `player_xp`, `player_lvl`, `player_xp_needed`)VALUES ('house', '1000','0','1','100')" )
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
	timer.Create("RandomFindMoney",1800,0,function()
	
	local RandomPlayer = math.random(table.Count(player.GetAll()))
	local randomamount = math.random(10)
	PrintMessage( HUD_PRINTTALK,player.GetAll()[RandomPlayer]:Nick().." "..tostring(table.Random(MunModGoodEvents))..". +"..randomamount.." Chips!")
		local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..player.GetAll()[RandomPlayer]:SteamID().."'")
		local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")

		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + randomamount)).." WHERE player_id = '"..player.GetAll()[RandomPlayer]:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - randomamount)).." WHERE player_id = 'house'")
		casinomodupdatebalance(ply)
	end)
	
timer.Create("PayPeople",600,0,function()
		for k,v in pairs(player.GetAll()) do
			local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..v:SteamID().."'")
			local CurrentLevel = sql.QueryValue("SELECT player_lvl FROM munmod_player_info WHERE player_id = '"..v:SteamID().."'")
				if(tonumber(CurrentMoney) < (10 + tonumber(CurrentLevel))) then sql.Query("UPDATE munmod_player_info SET player_money = "..tostring(10 + tonumber(CurrentLevel)).." WHERE player_id = '"..v:SteamID().."'")
					local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
					local RemoveHouseMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((tonumber(HouseMoney) - (10 + tonumber(CurrentLevel)))).." WHERE player_id = 'house'")
					v:PrintMessage( HUD_PRINTTALK,"You have been given "..(10 + tonumber(CurrentLevel)).." chips by the house to fuel your gambling habit.")
					casinomodupdatebalance(v)
				end
		end
	end)
	
end

function munmodremovetable()
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

function munmodremovemaintable()
	if(sql.TableExists("munmod_player_info")) then
		MsgAll("The munmod_player_info table exists, dropping...")
		sql.Query("DROP TABLE munmod_player_info")
			if(!sql.TableExists("munmod_player_info")) then
				MsgAll("Sucessfuly dropped the munmod_player_info table!")
			end
	end
	
			if(!sql.TableExists("munmod_player_info")) then
		MsgAll("Creating the munmod_player_info table...")
		sql.Query("CREATE TABLE munmod_player_info (player_id varchar(255),player_money int,player_xp int,player_lvl varchar(255),player_xp_needed int)")
		MsgAll("Created table, now trying to insert information into it")
		sql.Query("INSERT INTO munmod_player_info ('player_id', 'player_money', 'player_xp', 'player_lvl', 'player_xp_needed')VALUES ('house','1000','0','1','100')" )
		
			if(sql.TableExists("munmod_player_info")) then
				MsgAll("Sucesfully made the munmod_player_info table")
			else
				MsgAll("Something went horribly, horribly wrong!")
			end
	else
		MsgAll("The munmod_player_info table already exists!")
	end
end

function munsqlplayerspawned(ply)
	if(!sql.Query("SELECT player_id, player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")) then
		MsgAll("THE PLAYERS NOT IN THE DATABASE, ADDING THEM NOW")
		sql.Query("INSERT INTO munmod_player_info (`player_id`, `player_money`, `player_xp`, `player_lvl`, `player_xp_needed`)VALUES ('"..ply:SteamID().."', '100','0','1','10')" )
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
-- timer.Create("munmodtesttimer1",1,0,function()
-- local money2 = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
-- local MunUpdateMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((money2 + 100)).." WHERE player_id = '"..ply:SteamID().."'")
-- PrintMessage( HUD_PRINTTALK,"You currently have "..money2.." betting chips!")
-- end)
end
casinomodupdatebalance(ply)
end

hook.Add( "PlayerInitialSpawn", "munsqlplayerspawned", munsqlplayerspawned )
hook.Add( "Initialize", "munfirstspawn", munmodcreatetable )

function casinomodmessages(ply,msg,team) 
	local Target = 0
	local Message = string.Explode(" ",msg)
		 if(Message[1]=="/give" or Message[1]=="!give") then 
			if(table.Count(Message)==1) then return end
			if(!tonumber(Message[3])) then PrintMessage( HUD_PRINTTALK,Message[3].." is not an integer.  4 is an integer.  Four is a string.")  return "" end
			local money2 = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			if( tonumber(money2) < tonumber(Message[3]) ) then return end
			if(tonumber(Message[3]) <= 0) then return end
			
			local MunPlayerName = Message[2]
			
				local MunMoney = math.floor(Message[3])
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
			casinomodupdatebalance(ply)
		 end
		 
	if(Message[1]=="/balance" or Message[1]=="!balance") then
	casinomodbalance(ply)
	return ""
	end	
	
	if(Message[1]=="/gambling") then
	MsgAll("Recieved the command!")
	casinomodgui(ply)
	return ""
	end
	
	if(Message[1]=="!buycard" or Message[1]=="/buycard") then
		local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
			if(tonumber(CurrentMoney) >= 1) then
				local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney - 1)).." WHERE player_id = '"..ply:SteamID().."'")
				local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney + 1)).." WHERE player_id = 'house'")
				local Odds = math.random(100)
					if(Odds <= 33) then
						local PrizeOdds = math.random(30)
							if(PrizeOdds < 10) then
								local PayOut = math.random(10) PrintMessage( HUD_PRINTTALK,ply:Nick().." won ❉"..PayOut) 
								local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
								local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + PayOut)).." WHERE player_id = '"..ply:SteamID().."'")
								local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
								local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - PayOut)).." WHERE player_id = 'house'")
							else
								ply:PrintMessage( HUD_PRINTTALK,ply:Nick().." won a free go")
								local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
								local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + 1)).." WHERE player_id = '"..ply:SteamID().."'")
								local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
								local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - 1)).." WHERE player_id = 'house'")
							end
					else
						ply:PrintMessage( HUD_PRINTTALK,"You didn't win anything")
					end
			end
	casinomodupdatebalance(ply)
	return ""
	
	end

	if((Message[1]=="/higherorlower" or Message[1]=="/hol" or Message[1]=="!hol" or Message[1]=="!higherorlower") and ply.PlayingHigherOrLower != true) then
		local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
		if(tonumber(CurrentMoney) < 4) then ply:PrintMessage( HUD_PRINTTALK,"You dont have enough chips") return end
		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney - 4)).." WHERE player_id = '"..ply:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney + 4)).." WHERE player_id = 'house'")
		
		ply.PlayingHigherOrLower = true
		PrintMessage( HUD_PRINTTALK,"[Muneris Casino Mod APLHA 0.1] - "..ply:Nick().." started playing higher or lower")
		ply.CurrentHand = math.random(2,8)
		ply:PrintMessage( HUD_PRINTTALK,"/quit to take your winnings and go. /higher and /lower.  You must win 4+ to break even")
		ply:PrintMessage( HUD_PRINTTALK,"Balance: "..CurrentMoney.." Your current hand is "..ply.CurrentHand..", Higher or Lower?")
		ply.RoundsWon = 0
		return ""
	else if(ply.PlayingHigherOrLower == true and Message[1]=="/higherorlower" or Message[1]=="/hol" or Message[1]=="!hol" or Message[1]=="!higherorlower") then ply:PrintMessage( HUD_PRINTTALK,"You are currently in the middle of a game!") return "" end
	casinomodupdatebalance(ply)
	end

	if(Message[1]=="/higher" and ply.PlayingHigherOrLower == true) then
		local Current = math.random(10)
			if(Current >= ply.CurrentHand) then
				ply.CurrentHand = Current
				ply.RoundsWon = ply.RoundsWon + 1
				ply:PrintMessage( HUD_PRINTTALK," Correct! You have won "..tostring(ply.RoundsWon).." Games! - The number is "..Current..", Higher or lower?")
				else
				if(ply.CurrentHand == 2 and Current == 1) then ply:PrintMessage( HUD_PRINTTALK,"Fuck you, its 1, You loose.  Type /hol to play again.") 
				munmodhandleexp(ply,ply.RoundsWon)
				else
					ply:PrintMessage( HUD_PRINTTALK," Incorrect! ".."The number was "..Current..".  You loose!  Type /hol to play again")
					munmodhandleexp(ply,ply.RoundsWon)
				end
			ply.PlayingHigherOrLower = false
			end
	casinomodupdatebalance(ply)
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
				munmodhandleexp(ply,ply.RoundsWon)
				else
					ply:PrintMessage( HUD_PRINTTALK," Incorrect! ".."The number was "..Current..".  You loose!  Type /hol to play again")
					ply.PlayingHigherOrLower = false
					munmodhandleexp(ply,ply.RoundsWon)
				end
				
			end
			casinomodupdatebalance(ply)
			return ""
			
	end
	
	if(Message[1] == "/quit" and ply.PlayingHigherOrLower == true) then
		if(ply.RoundsWon <=4) then ply:PrintMessage( HUD_PRINTTALK,"You cannot quit a game until you have at least 4 wins")
		else	
			ply.PlayingHigherOrLower = false
			PrintMessage( HUD_PRINTTALK,"[Muneris Casino Mod APLHA 0.1] - "..ply:Nick().." has walked away from Higher or lower a winner.  They won "..(ply.RoundsWon * 3).." Coins!")
			munmodhandleexp(ply,ply.RoundsWon * 3)
			local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
			
			local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + (4+(ply.RoundsWon * 3)))).." WHERE player_id = '"..ply:SteamID().."'")
			local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - (4+(ply.RoundsWon * 3)))).." WHERE player_id = 'house'")
		end	
			casinomodupdatebalance(ply)
			return ""
			
	end

	if(Message[1]=="/buyticket" or Message[1]=="!buyticket") then
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
	
	if(tonumber(CurrentMoney) >= 10) then
		
		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney - (10))).." WHERE player_id = '"..ply:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney + (10))).." WHERE player_id = 'house'")
		
		local TotalTickets = sql.QueryValue("SELECT count(*) from munmod_raffle")
		local PlayerID = ply:SteamID()
		local PlayerString = ply:Nick()
		sql.Query("INSERT INTO munmod_raffle (`p_key`, `player_id`, `player_string`)VALUES ('"..(TotalTickets + 1).."', '"..PlayerID.."','"..PlayerString.."')" )
		local TotalTickets = tonumber(sql.QueryValue("SELECT count(*) from munmod_raffle"))*10
		
		PrintMessage( HUD_PRINTTALK,ply:Nick().." entered into the raffle.  Current prize: "..TotalTickets)
		--munmodhandleexp(ply,10)
	else
	ply:PrintMessage( HUD_PRINTTALK,ply:Nick().." You do not have enough chips,  you need 10 or more to enter.")
	end
	casinomodupdatebalance(ply)
	return ""
	
	end
	
	if(Message[1]=="/runraffle" and ply:IsAdmin()) then
	local TotalTickets = tonumber(sql.QueryValue("SELECT count(*) from munmod_raffle"))
	local WinningTicket = math.random(TotalTickets)
	local RaffleWinner = sql.QueryValue("SELECT player_id FROM munmod_raffle WHERE p_key = '"..tonumber(WinningTicket).."'")
	local RaffleWinnerName = sql.QueryValue("SELECT player_string FROM munmod_raffle WHERE p_key = '"..WinningTicket.."'")
	PrintMessage( HUD_PRINTTALK,"Winner of the raffle is..."..RaffleWinnerName.."! Congratulations, you won "..(TotalTickets*10).." Chips!")
	
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..RaffleWinner.."'")
	sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + (TotalTickets*10))).." WHERE player_id = '"..RaffleWinner.."'")
	local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
	sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - (TotalTickets*10))).." WHERE player_id = 'house'")
	munmodhandleexp(RaffleWinner,TotalTickets*10)
	munmodremovetable()
	return ""
	end
	
	if(Message[1]=="/blackjack" and ply.PlayingBlackJack != true) then
		casinomodblackjack(ply,_,Message[2])
		--MsgAll("YOUR BET AMOUNT SHOULD OF BEEN "..Message[2])
		return ""
	end
	
	if(Message[1]=="/hit" and ply.PlayingBlackJack == true) then
		casinomodhit(ply)
		return ""
	end
	
	if(Message[1]=="/stand" and ply.PlayingBlackJack == true) then
	casinomodstand(ply)
	return ""
	end
	
	if(Message[1]=="/exp") then
	local CurrentExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local NeededExp = sql.QueryValue("SELECT player_xp_needed FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	ply:PrintMessage( HUD_PRINTTALK,"Curent Exp: "..CurrentExp.." / "..NeededExp)
	end
end

function munmodhandleexp(ply,expamount)
	ply:PrintMessage( HUD_PRINTCENTER,"You recieved "..expamount.." Experiance points!")
	local CurrentExp = 0
	CurrentExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local HouseExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = 'house'")
	local MunModAddXp = sql.Query("UPDATE munmod_player_info SET player_xp = "..tonumber((tonumber(CurrentExp) + expamount)).." WHERE player_id = '"..ply:SteamID().."'")
	local MunModAddHouseXp = sql.Query("UPDATE munmod_player_info SET player_xp = "..tostring((HouseExp + (expamount / 2))).." WHERE player_id = 'house'")
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
			local NewNeededExp = NeededExpOld * 1.1
			local MunModSetNeeded = sql.Query("UPDATE munmod_player_info SET player_xp_needed = "..tostring((NewNeededExp)).." WHERE player_id = '"..ply:SteamID().."'")
			PrintMessage( HUD_PRINTTALK,ply:Nick().." Has Leveld up to "..(CurrentLevel+1))
			CurrentExp = sql.QueryValue("SELECT player_xp FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")	
		end
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
					casinomodupdatebalance(v)
				end
		end
	end)
	
end
--##Blackjack stuff##--
function casinomodblackjack(ply,_,args)
MsgAll(ply.PlayingBlackJack)
	if(ply.PlayingBlackJack != true) then  
		if(!tonumber(args)) then ply.BlackJackBet = 4 else ply.BlackJackBet = math.abs(tonumber(args)) end
		local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
		if(tonumber(CurrentMoney) < tonumber(ply.BlackJackBet)) then return end
		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney - (ply.BlackJackBet))).." WHERE player_id = '"..ply:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney + (ply.BlackJackBet))).." WHERE player_id = 'house'")
		
		ply.PlayingBlackJack = true
		local Hand1 = math.random(11)
		local Hand2 = math.random(11)
		if(Hand1 == 11 and Hand2 == 11) then Hand2 = 1 end
		ply.blackjackhand = (Hand1 + Hand2)
		
		ply:PrintMessage( HUD_PRINTTALK,"Hand is "..(Hand1 + Hand2))
		
		netsendhand(ply,(Hand1 + Hand2))
		
		casinomodupdatebalance(ply)
		end
end

function casinomodhit(ply)
if(ply.PlayingBlackJack == true) then
local RandomCard = math.random(11)
		ply.blackjackhand = ply.blackjackhand + RandomCard
			if(ply.blackjackhand > 21) then
				ply.PlayingBlackJack = false
				ply:PrintMessage( HUD_PRINTTALK,"You lose.  Hand was "..ply.blackjackhand)
				netsendhand(ply,"You lose.  Hand was "..ply.blackjackhand)
				munmodhandleexp(ply,(tonumber(ply.BlackJackBet) / 2))
				ply.blackjackhand = 0
				else
				ply:PrintMessage( HUD_PRINTTALK,"Hand is "..ply.blackjackhand)
				netsendhand(ply,ply.blackjackhand)
			end
end
		return ""
end

function casinomodstand(ply)
if(ply.PlayingBlackJack == true) then
	local HouseHand = 0
	local HouseLoose = math.random(100)
	if HouseLoose < 10 then HouseHand = math.random(22,25) else HouseHand = math.random(16,21) end
	
	if (HouseHand > 21) then 
	ply:PrintMessage( HUD_PRINTTALK,"You win, House bust with: "..HouseHand) netsendhand(ply,("You win, House bust with: "..HouseHand))
		netsendhand(ply,("You win, House bust with: "..HouseHand))
		munmodhandleexp(ply,ply.BlackJackBet * 2)
		local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
		
		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + (ply.BlackJackBet * 2))).." WHERE player_id = '"..ply:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - (ply.BlackJackBet * 2))).." WHERE player_id = 'house'")
		PrintMessage( HUD_PRINTTALK,ply:Nick().." Won "..(ply.BlackJackBet * 2).." Chips from the House!")
	else
	if (HouseHand > ply.blackjackhand) then ply:PrintMessage( HUD_PRINTTALK,"You lose, House hand is: "..HouseHand) munmodhandleexp(ply,ply.BlackJackBet / 2) netsendhand(ply,("You lose, House hand is: "..HouseHand))  end
	if(HouseHand < ply.blackjackhand) then ply:PrintMessage( HUD_PRINTTALK,"You win, House hand is: "..HouseHand) munmodhandleexp(ply,ply.BlackJackBet * 2) netsendhand(ply,("You win, House hand is: "..HouseHand))
		local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
		local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
		
		local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + (ply.BlackJackBet * 2))).." WHERE player_id = '"..ply:SteamID().."'")
		local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - (ply.BlackJackBet * 2))).." WHERE player_id = 'house'")
		PrintMessage( HUD_PRINTTALK,ply:Nick().." Won "..(ply.BlackJackBet * 2).." Chips from the House!")
	end 
	if(HouseHand == ply.blackjackhand) then ply:PrintMessage( HUD_PRINTTALK,"Draw, House hand is: "..HouseHand) netsendhand(ply,("Draw, House hand is: "..HouseHand))
			munmodhandleexp(ply,ply.BlackJackBet)
			local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
			local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
		
			local MunModRemovePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((CurrentMoney + (ply.BlackJackBet))).." WHERE player_id = '"..ply:SteamID().."'")
			local MunModAddHousePlayerMoney = sql.Query("UPDATE munmod_player_info SET player_money = "..tostring((HouseMoney - (ply.BlackJackBet))).." WHERE player_id = 'house'")
	end 
	end
	ply.PlayingBlackJack = false
end
casinomodupdatebalance(ply)
end
--##End of blackjack stuff##--

function casinomodbalance(ply)
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	local HouseMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = 'house'")
	PrintMessage( HUD_PRINTTALK,"[Muneris Casino Mod APLHA 0.1] - "..ply:Nick().." has ❉"..CurrentMoney.." Chips and the House has ❉"..HouseMoney)
	
end

function casinomodupdatebalance(ply)
	local CurrentMoney = sql.QueryValue("SELECT player_money FROM munmod_player_info WHERE player_id = '"..ply:SteamID().."'")
	net.Start("casinomod_balance")
	net.WriteString(tostring(CurrentMoney))
	net.Send(ply)
end

function netsendhand(ply,hand)
net.Start("blackjack_hand")
net.WriteString(tostring(hand))
net.Send(ply)
end

function casinomodgui(ply)
net.Start("open_blackjack")
net.Send(ply)
end


hook.Add("PlayerSay", "casinomodmessages", casinomodmessages )
concommand.Add("casinomodgui",casinomodgui)
concommand.Add("casinomodhit",casinomodhit)
concommand.Add("casinomodstand",casinomodstand)
concommand.Add("casinomodblackjack",casinomodblackjack)
concommand.Add("casinomodupdatebalance",casinomodupdatebalance)