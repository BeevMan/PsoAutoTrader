﻿; X Need to figure out how to use OCR and find the best place to use it/ where it matches best
;     I should only try to implement this if people decide to try to grieve my shop script???
;     It works fairly well to retrieve names but I would have to add multiple languages and that may or may not be worth it???
;     If I do use it I should allow it to fuzzy match names???
;     X SODABODY FIXED THE BELOW ON 4/5/2021 
;       X Some names are cut off when stored in the games chat log files
;           X Such as MagMaker3k , that is saved as gMaker3k
;
; 
; I could make a variable that will store the guildcard of a player and apply the discount for buying multiple items in seperate purchases
;   Would mostly be useful if/once I can accept and bank meseta 
;
;
; Should be able to accept up to 3 different currencies at a time
;     based on the background of the trade window, anymore than 3 and I might have to consider adding the slider images in to check for correct payment
;       the slider imagery is required for checking to make sure the correct items were removed from the trade window
;     if I accept more then 3 at a time, the 3rd position item images will have to be taken twice as it slides down with 3+ items
;     currently only accepting photon drops as currency, just adding the GetTradeTotal() to g_photonDrops to keep track
;       when/if it accepts multiple currencies, it will have to change when and how it stores the currencies
;
;
; SHOULD ADD A CHECK for currencies in the inventory and stackable items when the script parses the inventory txt file
;   script is currently not capable of trading stackable items
;   currency that is being accepted should not also be sold, at least at this time
;
;
; WILL NEED TO MAKE SURE currency images are taken at the same position ( and are the same size??? position alone should be fine)
;   will make searching easier and more reliable
;
;
; ImageSearch supports 8-bit color screens (256-color) or higher.
;   The search behavior may vary depending on the display adapter's color depth. 
;       Therefore, if a script will run under multiple color depths, it is best to test it on each depth setting. 
;           You can use the shades-of-variation option (*n) to help make the behavior consistent across multiple color depths.
;               *200+ to find a match on my laptop with 6-bit color depth, image snipped from desktop
;               *125 to find a match on my desktop with 8-bit color depth, image snipped from laptop
;               *0 to find a match when using an image snipped from itself
;               ONLY TESTED VARIATIONS OF 25
;
;
; In the future I may want to add a check to see if the customer is final confirmed with the wrong payment offered
;   in the case of the above being true, It would cancel confirmation
;       allowing the other player to be able to adjust their payment without having to leave/rejoin the game
;
;
; their is risk of the inventory desyncing 
;   Ender said "This game is old and almost everything is client side and the server just tries to match what clients are doing with tons of sanity checks. Inventory desync seems to happen for no reason sometimes, probably obscure client bugs given how rare."
;   if it happens the customer will not necessarily see the same items as the client the script is running on
;   I would guess it's most likely/only possible to happen when things change in the inventory or the inventory is loaded??? ( joining game/changing areas )
;       if my above guess is correct that could be manageable otherwise it could be risky to sell high value items??? or attempt banking ??? :(
;
;
; WHEN ADDING IN the fail saves, I should check to make sure the player joining window is not displayed?
;   SHOULD PREVENT trying to repeat actions while no inputs are accepted
;   IF ANOTHER PLAYER IS NOT JOINING, lag should be the only issue for inputs/macros messing up
;
;
; I NEED TO DECIDE HOW TO SAFELY MAKE THE SCRIPT CHAT IN GAME ( verify chat has been said, it's not still in chat input, and the chats end/Send, {Enter} was used to send the chat )
; I NEED TO DECIDE WHAT TO DO WHEN A msg IS NOT FOUND using IsMessageInLog()
;   I may want to repeat the instructions or just make sure it's not still trying to talk by escaping multiple times??
;       escaping/backspacing during a trade at worse will end up in the "cancel exchange" confirmation menu
;   ImageSearching seems to do a good job at finding chatStart.PNG and greenChat.PNG during a trade
;       greenChat.PNG requires *1 transparency on the original machine during the image search to match in multiple spots
;       which can be used during the trade to confirm that the chat input is ready to begin and that there has been 1 input or more in the chat
;       X I MADE Send {Space} send in a trade until chatStart.PNG or greenChat.PNG is on screen while in a trade ??? THIS COULD POSSIBLY SOLVE INTERUPTION ISSUES WHILE PPL ARE JOINING MID CHAT
;       X I MADE Send {Enter} recursively send in a trade until cancelled.PNG, or greenChat.PNG is on screen??? similar to the above
;           COULD/SHOULD NOW check that the chat made it into the chat log ???
;               currently has to be said perfectly if checked with IsMessageInLog()
;               ???could change to fuzzy search for the string or simply check that the scripts character said something recently???
;   While in trade,
;       I may want to rely on the above recursive chat starting/ending idea for mid trade chat
;       ??? if I do the above it should be able to find it's way in WatchChatLog() ???
;   While NOT in a trade, if the message is not found recently in the chatlog:
;       then it should be assumed:
;           the chat input is still up, which could stop trade offers from appearing
;               chat input could still be up do to somebody recently joining or currently joining
;                   ??? check to make sure their is not a player joining ??? playerJoining.PNG
;           or the chat input was never started and it could possibly hit enter on a trade offer
;               could get stuck in a trade window at this point ( small possibility ) TO PREVENT THIS I COULD:
;                   X check for the redMenu.PNG in the j hotkey while loop, if found it would simply exit out of the trade menu??? as it's not suppose to be in there
;           I THINK SENDING {Esc} AT WORST would turn down a trade offer/exit chat input if it's still up
;  
;
;   I have not fully tested my timer functions/math ( seems to time out at the set time )
;       Will need to decide how to handle retrieving the chat log and when, if the trade takes place during a date change on client machine 
;       I need to look further into AHK's native time methods
;           using A_TickCount becomes unstable on slow machines ( times are often off by varying amounts sometimes drastic )
;       
;
;   STILL NEED TO ADD the image searches when showing/removing items from the trade window ( to verify it only leaves the requested items )
;       I STILL NEED TO TAKE THE IMAGES FOR THE SEARCH AS WELL
;       WHEN ADDING ITEMS TO TRADE WINDOW the last 4 do not include the slider
;           to verify all items were added to the trade window:
;               X Checks the add item window for no items or whatever currencies it expects to have ( in ShowItems() )
;                   the above should require a lot less imagery and script execution time compared to using images to verify each item is added one by one
;       WHEN REMOVING ITEMS FROM THE TRADE WINDOW the last 3 items do not inlcude the slider in "Cancel candidate" menu
;           this will use the same slider images that could be used in the "verify items" menu
;           implenent imageSearch inside of RemoveExcessItems()
;



#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#IfWinActive Ephinea: Phantasy Star Online Blue Burst
; #Include <Vis2>
SendMode Event        ; REQUIRED!!!! PSOBB won't accept the deemed superior
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 290, 80   ; SetKeyDelay, 150, 70  1st parameter is delay between keys 2nd is how long the button is pressed

; CHANGE THIS TO PSO's DIRECTORY
global g_psoDirectory := "C:\Program Files\EphineaPSO"

; g_inventory DOES NOT store/track accepted/incoming currencies, as it does not want to add it to the trade window
global g_inventory := GetInventory()
MessageArray( g_inventory )
global g_itemPrices := []
Loop % g_inventory.Length() {
    g_itemPrices.Push( 2 )
    }

global g_timeItemsShown := 0
global g_photonDrops := 0

; rough position of a blank piece of red menu that should only be blank during a trade
global g_emptyMenuPosition := [ 45, 60, 145, 110 ]


^p:: Pause  ; Ctrl + P - Pauses script.
     

t:: ; Ctrl + T - Test
    test := VerifyScreen( "TradeImages\addPdPos1.PNG", 2500 )

    ;emptyMenuPosition := [ 45, 60, 145, 110 ]
    ; checks for a blank piece of the red menu that should only be blank in this position during a trade???
    ;test := VerifyImageInPosition( emptyMenuPosition, "TradeImages\redMenu.PNG", 500 )
    ; this will not be true if
    ; not in a trade
    ; trade is cancelled/finished ( cancelled.PNG or itemsExchanged.PNG is present )
    MsgBox %test%
    return


^q:: ; Ctrl + Q - Display itemsInventory 
    /*
    displayInventory := ""
    Loop % g_inventory.Length() {
        displayInventory := displayInventory "`n" g_inventory[ A_Index ]
    } 
    MsgBox  itemsInventory, starting at index 1 %displayInventory%
    */
    MessageArray( g_inventory )
    MessageArray( g_itemPrices )
    return

^r::reload  ; Ctrl + R - Restarts script.

^j::    ; Ctrl + J - Begins the trading script.
    loopsWithNoTrade := 0
    while ( g_inventory.Length() > 0 ) 
    {
        if ( g_inventory.Length() != g_itemPrices.Length() )
        {
            MsgBox, Error! inventory and item prices have different lengths!
        }
        ; if divisible by 3 SHOULD MAYBE CHANGE TO SOMETHING ELSE?
        else if ( loopsWithNoTrade >= 3 and Mod( loopsWithNoTrade, 3 ) == 0 )
        {
            TradeMeText() ; speaks and tells anybody in the game to initiate the trade with me 
        }
        ; if somebody is offering to trade
        if ( VerifyScreen( "TradeImages\tradeProposal.png", 3000 ) ) 
        {
            ; if 
            if ( VerifyScreen( "TradeImages\yesTradeProposal.png", 3000 ) )
            {
                Send {Enter} ; accept the trade offer
                if ( VerifyScreen( "TradeImages\addItem.png", 3000 ) )
                {
                    ShowItems() ; adds all items from your inventory to the trade, allowing other player to see the goods.
                    g_timeItemsShown := TimeInSecs( A_Hour, A_Min, A_Sec )
                    GiveInstructions() ; tell other player/s to tell me the index of the item/s they want to buy.
                    ; currentTraderName should only be needed if people start to grieve my shop script I.E intentionally try to mess it up by saying random index/s while it's trading with others
                    ; currentTraderName := WindowOCR(40,280,120,15, "Ephinea: Phantasy Star Online Blue Burst") ; using Optical Character Recognition (OCR), get current tradee's username

                    ; watch chat log for trade instructions for up to 5 minutes? while also checking to make sure trade is not cancelled OR CONFIRMED???
                    ;   will also call to a function that will leave only the requested items in the trade ??? after tradee has requested it/them.
                    WatchChatLog()
                }
            }
        }
        else if ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 1500 ) )
        {
            EscAndCancelTrade()
        }
        else 
        {
            sleep, 3000
            ++loopsWithNoTrade
        }
    }
    MsgBox "End of the trading script"
    return


; Returns the "inventory" from the newest Item Reader file
GetInventory()
{
    newestInventoryTxt := GetInventoryPath()
    FileRead, inventoryTxt, %newestInventoryTxt%
    inventoryTxt := StrSplit( inventoryTxt, "`n" )
    ; Item reader add on ends the file with "`n", remove the blank/final newline
    inventoryTxt.RemoveAt( inventoryTxt.Length() )
    return inventoryTxt
}


; Finds the newest inventory.txt file in your addons directory
GetInventoryPath()
{
    Loop, Files, %g_psoDirectory%\addons\Item Reader\inventory\*saved_inventory.txt
    {
        newestInventory := ""
        lastModifiedTime := 0  
        if (  lastModifiedTime - A_LoopFileTimeModified < 0 or lastModifiedTime == 0 )
        {
            newestInventory := A_LoopFileName
            lastModifiedTime := A_LoopFileTimeModified
        } 
    }
    return g_psoDirectory "\addons\Item Reader\inventory\" newestInventory
}


; ----------------------------------------------------------
;
;  Function
;      Verify Screen - returns true when images can be found.
;
;  Arguments
;      filePath - string containing the file path of the image.
;      searchTime - the maximum allowed time to search 
; ----------------------------------------------------------

VerifyScreen( filePath, searchTime )
{
    imageFound := false
    searchTimer := A_TickCount
    ; while imageFound == false, loop for up to 3 seconds
    while ( !imageFound and A_TickCount - searchTimer < searchTime )
    {
        ; using *200 color variations allows my laptop to find the initial tradeproposal 
        ; ImageSearch, , , 0, 0, A_ScreenWidth, A_ScreenHeight, *200 %filePath%
        ImageSearch, , , 0, 0, A_ScreenWidth, A_ScreenHeight, *1 %filePath%
        if (ErrorLevel = 2)
            MsgBox Could not conduct the search for %filePath%
        else if (ErrorLevel = 1)
            imageFound := false
        else
            imageFound := true
    }
    return imageFound
}


; ----------------------------------------------------------
;  Function
;      Show Items - Add all items of your inventory to the trade, except for currencies.
; ----------------------------------------------------------

ShowItems()
{
    tradeInventoryPosition := [ 20, 350, 350, 475 ]

    ; +1 so after all items are added it should be in a position to check for addNoItem.PNG or current currencies
    Loop % ( g_inventory.Length() * 2 ) + 1 {
        ; CHECK THAT "add item for trade" is highlighted on odds and itemList.PNG is present for evens
        ; EnterIfInTrade()
        if ( Mod( A_Index, 2 ) != 0 and VerifyScreen( "TradeImages\addItem.PNG", 3000 ) )
        {
            EnterIfInTrade()
        }
        else if ( Mod( A_Index, 2 ) == 0 and VerifyScreen( "TradeImages\itemList.PNG", 3000 ) )
        {
            EnterIfInTrade()
        }
        
    }
    
    ; WILL EVENTUALLY ADD IMAGE SEARCHES TO VERIFY no items or only currency is left in my inventory ???

    ; no currencies in inventory and no items left in "Add item for trade" menu
    if ( g_photonDrops == 0 and VerifyImageInPosition( tradeInventoryPosition, "TradeImages\addNoItem.PNG", 2000 ) )
    {
        Send {Esc} ; all items added, return to the purpose menu
    }
    ; when the script has pds check for them in position 1 of the "Add item for trade" menu
    else if ( g_photonDrops > 0 and VerifyImageInPosition( tradeInventoryPosition, "TradeImages\addPdPos1.PNG", 2000 )  )
    {
        Send {Esc} ; all items besides currencies added, return to the purpose menu
    }
    else
    {
        ; SHOULD TELL CUSTOMER SOMETHING WENT WRONG AND THEN EscAndCancelTrade()
        SayMsgInTrade( "Incorrect items, let's try again." )
        EscAndCancelTrade() ; assume not all items were added or the currencies were added as well and exit the trade
    }
}



TradeMeText()
{
    message := "Trade me txt"
    Send {Space}%message%{Enter}
    ; Send {Space}I am an automated trader, running via AHK script :){Enter}
    ; Send {Space}Please send me a trade offer to see what I have for sale :){Enter}

    textTimeStamp := TimeInSecs( A_Hour, A_Min, A_Sec )
    Sleep, 5000
    ; if the message was not said recently
    if ( !IsMessageInLog( message, textTimeStamp ) and !VerifyScreen( "TradeImages\playerJoining.PNG", 1200 ) ) 
    {
        Send {Esc}
        ;MsgBox did not say the trade me txt recently
        ; Will need to decide how I will want to handle the text not being in the log
        ; I suspect the main reason it will not have the message in the chat recently is because of players joining
        ; SHOULD I JUST MAKE SURE ITS NOT TRYING TO TALK STILL?? send escape or backspace to make sure its not still sending a message?
        ; THERE SHOULD BE NO HARM IN USING Send {Space} , except that it should bring up the chat input if it's not already up
        ; SHOULD I CHECK IF THE PLAYER IS JOINING WINDOW IS UP?
    }
}


; used after showing items in trade, is said again while in a trade and no index/s have been requested
GiveInstructions()
{
    numOfItems := g_inventory.Length()
    ; instructions := Tell me the index (1-%numOfItems%) of the item/s you are interested in
    instructions := "Tell me the index (1-" numOfItems ")"
    StartChatInTrade()
    Send %instructions%
    SendChatInTrade()
    ; WILL EVENTUALLY RUN some sort of check to make sure the script spoke in chat
}


/*
WindowOCR(x1,y1,x2,y2, windowName)
{
	WinActivate, %windowName%
	WinGetPos, WinX,WinY,,,,,,
	x := WinX + x1
	y := WinY + y1
	w := x2
	h := y2
	coords := [x,y,w,h]
	return OCR(coords)
}
/*
coords for attempting OCR name grab during trade offer 35,315,250,20, "Ephinea: Phantasy Star Online Blue Burst"
coords for attempting OCR name grab during trade 40,280,120,15, "Ephinea: Phantasy Star Online Blue Burst"
*/


WatchChatLog()
{
    ; keep track of indexes that were requested in the below while loop
    requestedItemIndexes := []

    ; while in trade menu 
    while ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
    {
        tradeTotal := GetTradeTotal( requestedItemIndexes )
        ; array of index numbers found in the current chat log
        requestedIndex := FindRequestedIndexes()

        ; trade has lasted longer than 5 minutes (300 = 5mins)
        if ( TradeTimer( g_timeItemsShown ) > 300 )
        {
            ; SHOULD CONSIDER ADDING A MESSAGE TO LET CUSTOMER KNOW TRADE IS BEING CANCELED

            ; NAVIGATE TO AND SELECT CANCEL TRADE
            ;   I think backspacing/Esc will always get you to the "cancel exchange" confirmation menu.  Unless you have already selected the final confirmation. 
            ;   Also Esc will not exit out of the cancel exchange menu
            EscAndCancelTrade()

            ; Make it jump to the next while() check.  This will make sure it made it out of the trade menu.
            Continue
        }


        ; if it's the initial item/s request
        if ( requestedItemIndexes.Length() == 0 and requestedIndex.Length() > 0 ) 
        {
            requestedItemIndexes := requestedIndex
            ; Removes non requested items from the trade window
            RemoveExcessItems( requestedItemIndexes )
        }
        ; if nothing has been requested, Give customer instructions again
        /* UN COMMENT THIS AFTER TESTING it's annoying to have it talk that much during testing
        else if ( requestedItemIndexes.Length() == 0 and requestedIndex.Length() == 0 )
        {
            GiveInstructions()
        }
        */
        ; should only go into this if statement after items have been requested and left/added to trade
        else if ( requestedItemIndexes.Length() > 0 and !VerifyScreen( "TradeImages\my1stConfirm.PNG", 1500 ) )
        {
            ; if script is in the purpose menu
            if ( VerifyScreen( "TradeImages\purposeMenu.png", 500 ) )
            {
                ; should navigate to the first trade confirm and select it
                InitialTradeConfirm()
            }
            ; double check that it's not in the purpose menu
            else if ( !VerifyScreen( "TradeImages\purposeMenu.png", 500 ) )
            {
                ; Send {Esc} until it's in the purpose menu
                Send {Esc}
            }
        }
        ; if customer has confirmed the 1st time or final time and 1 or more items have been requested
        ;  ( only requested items should be in the trade window )
        else if ( requestedItemIndexes.Length() > 0 and  VerifyScreen( "TradeImages\customerConfirmed.PNG", 1500 ) or VerifyScreen( "TradeImages\customerFinalConfirmed.PNG", 1500 ) )
        {
            ; Check if customer has put the appropriate payment into the trade window
            if ( IsPaymentCorrect( tradeTotal ) )
            {
                ; Verify the customer has selected the final confirmed 
                if ( VerifyScreen( "TradeImages\customerFinalConfirmed.PNG", 1500 ) )
                {
                    ;MsgBox customer has confirmed and put the correct payment up

                    ; Navigate to and select the final trade confirmation
                    FinalTradeConfirmation()
                    SelectFinalYes()
                }
                ; Customer still needs to do do the final/2nd confirmation
                else
                {
                    SayMsgInTrade( "Select the final confirmation plz" )
                }
            }
            ; Tell customer how much to pay, placed it here so it checks for the payment first
            ; should help prevent spamming the customer to put the money in the trade window when it's already there 
            else
            {
                message := tradeTotal "pd, then confirm trade plz"
                SayMsgInTrade( message )
            }
        }
        ; if 1 or more items requested but customer has not confirmed.  COULD MAYBE GET RID OF THE VerifyScreen() call
        else if ( requestedItemIndexes.Length() > 0 and  !VerifyScreen( "TradeImages\customerConfirmed.PNG", 1500 ) )
        {
            ; I COULD AND MIGHT CHECK TO SEE IF THE PDS ARE IN THE TRADE WINDOW 
            ; THEN RESPOND TO CUSTOMER APPROPRIATELY 
            message := tradeTotal "pd, then confirm plz"
            SayMsgInTrade( message )
            Sleep 3000
        }
    }

    ; the images commented below can all be found WHILE SOMEBODY IS JOINING THE GAME ( cancelled.PNG is cutting it close ???might not be found while someone joins??? !!!NEED TO CHECK!!! )
    ; tradeWindow.PNG is displayed when either of the following images is on the screen: cancelled.PNG, itemsExchanged.PNG

    ; if the customer has cancelled the trade or left the game
    if ( VerifyScreen( "TradeImages\cancelled.PNG", 2500 ) )
    {
        ; exit out of the cancel pop up and tell customer thanks for looking
        HandleTradeCancel()
    }
    ; trade is completed
    else if ( VerifyScreen( "TradeImages\itemsExchanged.PNG", 2500 ) )
    {
        ; adjust the inventory and price array
        RemoveSoldItems( requestedItemIndexes )
        ; currently only accept photon drops
        g_photonDrops += tradeTotal

        ; exit out of the trade finished menu and say TY
        HandleTradeFinish()
    }
}


; sort soldIndexes from greatest to least, then remove the sold index/s from g_inventory and g_itemPrices
RemoveSoldItems( soldIndexes )
{
    ; reverse the array, It's already sorted least to greatest.  Array needs to be sorted this way in order to properly remove the indexes from g_inventory
    soldIndexes := ReverseArray( soldIndexes )
    Loop % soldIndexes.Length() {
        g_inventory.RemoveAt( soldIndexes[ A_Index ] )
        g_itemPrices.RemoveAt( soldIndexes[ A_Index ] )
    }
}


; reverses array contents indexes
ReverseArray( toRev )
{
    reversedArray := []
    i := toRev.Length()
    Loop % toRev.Length() {
        reversedArray.Push( toRev[ i ] )
        i--
    }
    return reversedArray
}


; Send the Escape keep until asked yes/no during cancel exchange menu
EscAndCancelTrade()
{
    ; if in trade menu 
    if ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
    {
        if ( VerifyScreen( "TradeImages\cancelExchange.PNG", 700 ) ) ; if cancel exchange menu is on screen
        {
            if ( VerifyScreen( "TradeImages\yes.png", 700 ) ) ; if yes is highlighted
            {
                EnterIfInTrade()
            }
            else 
            {
                Send {Up} ; no should be highlighted, send up to highlight yes
                EscAndCancelTrade()
            }
        }
        else
        {
            Send {Esc}
            Sleep, 500 ; without this sleep it seems impossible for the function to see cancelExchange.png after recalling itself, sleep time could be lowered??? 
            ; ??? or simply add the time to the search for cancelExchange.png ???
            EscAndCancelTrade()
        }
    }
}


; Makes sure to exit out of the cancel pop up, cancel pop up is triggered by customers ONLY???
HandleTradeCancel()
{
    ; double check that the trade cancel pop up is present
    if ( VerifyScreen( "TradeImages\cancelled.PNG", 500 ) )
    {
        ; exit out of the cancel pop up
        Send {Enter}
    }
    ; if the cancel pop up is still present (should only happen when the previous enter did not register)
    if ( VerifyScreen( "TradeImages\cancelled.PNG", 1000 ) )
    {
        ; recursively call itself until the trade is cancelled
        HandleTradeCancel()
    }
    ; SHOULD CONSIDER LOOKING FOR A IMAGE THAT IS FOUND AFTER CANCELLING THE TRADE, check for it here
    ; or simply check to make sure that cancelled.PNG can NOT be found
    else
    {
        ; tell the customer thanks for looking
        Send {Space}TY for looking :){Enter}
    }
}


; Makes sure to exit out of the trade finished menu.  Only displayed after a trade is completed
HandleTradeFinish()
{
    ; double check that the trade trade finished menu is present
    if ( VerifyScreen( "TradeImages\itemsExchanged.png", 500 ) )
    {
        ; exit out of the trade finished menu.
        Send {Enter}
    }
    ; if the trade finished menu is still present (should only happen when the previous enter did not register)
    if ( VerifyScreen( "TradeImages\itemsExchanged.png", 1000 ) )
    {
        ; recursively call itself until the trade is cancelled
        HandleTradeFinish()
    }
    ; SHOULD CONSIDER LOOKING FOR A IMAGE THAT IS FOUND ONLY when it's not in a trade
    else
    {
        ; tell the customer TY
        Send {Space}TY :){Enter}
    }
}


; Finds the newest chat log in your PSO directory
GetCurrentChatLog()
{
    Loop, Files, %g_psoDirectory%\log\chat*.txt 
    {
        newestChatLog := ""
        lastModifiedTime := 0  
        if (  lastModifiedTime - A_LoopFileTimeModified < 0 or lastModifiedTime == 0 )
        {
            newestChatLog := A_LoopFileName
            lastModifiedTime := A_LoopFileTimeModified
        } 
    }
    return  g_psoDirectory "\log\" newestChatLog
}



TradeTimer( timeStart )
{
    timeInTrade := 0
    if ( TimeInSecs( A_Hour, A_Min, A_Sec ) <= 300 ) ; if the current time is under 5 minutes past midnight
    {
        if ( timeStart >= 86100 ) ; if trade was started before midnight, 86400 seconds in 24 Hours
        {
            timeInTrade := 86400 - timeStart + TimeInSecs( A_Hour, A_Min, A_Sec )
        }
        else 
        {
            timeInTrade := TimeInSecs( A_Hour, A_Min, A_Sec ) - timeStart
        }
    }
    else
    {
        timeInTrade := TimeInSecs( A_Hour, A_Min, A_Sec ) - timeStart
    }
    ; if it returns 300 or more it has been 5+ minutes 1 = 1second
    return timeInTrade
}


; SHOULD PROBABLY RENAME THIS
TimeInSecs( hour, min, sec )
{
    currentTime := ( hour * 60 * 60 ) + ( min * 60 ) + sec
    return currentTime
}


ChatLogTimeInSecs( chatTimeString )
{
    ; chatTime[1] = hours, [2] = minutes, [3] = seconds
    chatTime := StrSplit( chatTimeString, ":")
    return TimeInSecs( chatTime[1], chatTime[2], chatTime[3] )
}


; Loops through array converting it into a string then displays it via MsgBox
MessageArray( displayMe )
{
    arrayToDisplay := displayMe
    displayString := ""
    Loop % arrayToDisplay.Length() {
        displayString := displayString "`n"
        displayString := displayString arrayToDisplay[ A_Index ]
    } 
    MsgBox  requested array, %displayString%
}


; Returns the newest chat log as an array, index = new line in chat log
GetChatAsArray()
{
    newestChatTxt := GetCurrentChatLog()
    FileRead, entireChatLog, %newestChatTxt%
    chatLogArray := StrSplit( entireChatLog, "`n" )
    return chatLogArray
}


; Filter chat log to only chat that has been said since items were shown.
SaidInThisTrade( log )
{
    saidSinceShown := []
    Loop % log.Length() {
        ; splitLine[1] = time, splitLine[2] = guildcard/KeyPress, splitLine[3] = aUserName/WhatKeyPressDid, splitLine[4+] = words in chat ( there can be more than 4 if there is a tab in the chat )
        splitLine := StrSplit( log[ A_Index ], "`t" ) ; could also use A_Tab ?
       
        ; If the line of chat was said since being shown the items for trade.
        if ( TradeTimer( ChatLogTimeInSecs( splitLine[1] ) ) <= TradeTimer( g_timeItemsShown ) )
        {
            ; I STILL NEED TO CHECK IF THERE IS ANY indexes higher than 4 in splitLine
            ; pushes splitLine[ 4+ ] into a variable 
            Loop % splitLine.Length() - 3 {
                saidSinceShown.Push( splitLine[ A_Index + 3 ] )
            }
        }
    }
    return saidSinceShown
}


; Loops array then splits strings by spaces then returns new array
SplitByWords( chat )
{
    splitIntoWords := []
    Loop % chat.Length() {
        splitChat := StrSplit( chat[ A_Index ], A_Space )
        Loop % splitChat.Length() {
            splitIntoWords.Push( splitChat[ A_Index ] )
        }
    }
    return splitIntoWords
}



; return true if string can be converted to a digit greater than 0
IsDigit( chatString )
{
    ; converts to 0 if it's a string of text that doesn't end with a number greater than 0
    chatString += 0
    isIt := False
    if chatString is digit
    {
        if ( chatString > 0 )
        {
            isIt := True
        }
    }
    return isIt
}


; Returns an array of numbers
NumbersInArray( playerChat ) 
{
    foundNumbers := ""

    wordsInChat := SplitByWords( playerChat )
    Loop % wordsInChat.Length() {
        if ( IsDigit( wordsInChat[ A_Index ] ) )
        {   
            foundNumbers := foundNumbers wordsInChat[ A_Index ] ","
        } 
        if ( A_Index == wordsInChat.Length() and foundNumbers != "" ) 
        {
            ; remove the final comma if a number was found
            foundNumbers := SubStr( foundNumbers, 1 , -1 )
        }
    }
    Sort foundNumbers, N D, U  ; Sort numerically, use comma as delimiter and remove duplicates.
    arrFoundNumbers := StrSplit( foundNumbers, "," )
    return arrFoundNumbers
}


; Returns the requested indexes from the current chat log, they can then be used to add the items to to the trade.
FindRequestedIndexes()
{
    requestedIndexes := []

    ; Get the newest chat log as an array, each newline in the log is a new index of the array.
    chatLogLines := GetChatAsArray()

    ; Filter chatLogLines to only the chat that has been said since trade started.
    saidDuringTrade := SaidInThisTrade( chatLogLines )

    ; Filter to unique numbers found in saidDuringTrade, also sort them least to greatest
    numbersInChat := NumbersInArray( saidDuringTrade ) 

    ;Loops the numbers found in the chat log then pushes them into requestedIndexes if they are in within g_inventory.Length()
    Loop % numbersInChat.Length() {
        numbInChat := numbersInChat[ A_Index ]
        ; convert to a number if possible
        numbInChat += 0
        
        if ( numbInChat <= g_inventory.Length() and numbInChat > 0 )
        {
            requestedIndexes.Push( numbInChat )
        }
        /* ; FOR TESTING  
        else if ( numbInChat <= g_inventory.Length() )
        {
            MsgBox it considers it less than or equal to the inventories length %numbInChat%
        }
        else if ( numbInChat > 0 )
        {
            MsgBox it considers it greater then 0 but not less than or equal to the inventories length %numbInChat%
        }
        else 
        {
            MsgBox it doesn not consider it greater then 0 or less than or equal to the inventories length %numbInChat%
        }
        */
    }
    return requestedIndexes
}


; Removes items that are not requested after the first item/s request is found in chat log
RemoveExcessItems( requestedItems )
{
    ; if all items are requested, exit this function
    if ( requestedItems.Length() == g_inventory.Length() ) 
    {
        return
    }

    ; highlights "Cancel Candidate"
    HoverCancelCandidate()
    
    nonRequestedItems := GetNonRequested( requestedItems )
    ; the "Cancel Candidate" menu retains the position in between cancels
    cancelPos := 1

    ; keep track of how many items have been removed from the trade
    removedCount := 0
    ; this variable will be used later to decide which images to match on screen, to verify the correct items are being removed
    itemsInTrade := g_inventory.Length() - removedCount 
    

    Loop % nonRequestedItems.Length() {
        ; if in trade menu 
        if ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
        {
            ; selects "Cancel Candidate"
            EnterIfInTrade()

            
            if ( cancelPos == ( nonRequestedItems[ A_Index ] - removedCount ) )
            {
                ; Checks for the correct image and removes item if image found.  Otherwise chats and leaves trade
                RemoveItem( cancelPos, itemsInTrade )
            }
            else 
            {
                ; hover/highlight the next unwanted item
                Loop % ( ( nonRequestedItems[ A_Index ] - cancelPos ) - removedCount ) {
                    Send {Down}
                    cancelPos++
                }
                ; Checks for the correct image and removes item if image found.  Otherwise chats and leaves trade
                RemoveItem( cancelPos, itemsInTrade )
            }
        }
    ; keep track of how many items have been removed from the trade
    removedCount++
    }

}


; Decides which image is needed to check in the ???cancel candidate menu???
GetSliderImage( currentPos, itemsInTrade )
{
    ; when there is less than 3 itemsInTrade the slider is no longer available
    if ( itemsInTrade <= 3 )
    {
        return "TradeImages\CancelVerifyImages\leftSide" currentPos ".PNG"
    }
    else
    {
        return "TradeImages\CancelVerifyImages\" currentPos "of" itemsInTrade ".PNG"
    }
}


; Returns leftBarPosition or sliderPosition
GetPosition( itemsInTrade )
{
    ; rough positions used for imageSearching
    leftBarPosition := [ 20, 380, 50, 475 ]
    sliderPosition := [ 335, 370, 350, 475 ]

    if ( itemsInTrade <= 3 )
    {
        return leftBarPosition
    }
    else
    {
        return sliderPosition
    }
}


; Removes individual item from the trade window
RemoveItem( cancelPos, itemsInTrade )
{
    position := GetPosition( itemsInTrade )
    sliderImage := GetSliderImage( cancelPos, itemsInTrade )

    ; item to remove is highlighted
    if ( VerifyImageInPosition( position, sliderImage, 3000 ) )
    {
        ; removes unwanted item from trade menu
        EnterIfInTrade()
    }
    else
    {
        ; explain mistake and exit trade
        SayMsgInTrade( "Let's try again. Wrong items left in trade" )
        EscAndCancelTrade()
    }
}


; hover/highlight "Cancel Candidate"
HoverCancelCandidate()
{
    ; if in trade menu 
    if ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
    {
        currentPos := FindPurposePos()
        if ( currentPos == 2 )
        {
            ; do nothing/exit function
        }
        else if ( currentPos == 1 )
        {
            Send {Down}
            HoverCancelCandidate()
        }
        else if ( currentPos > 2 )
        {
            Loop % currentPos - 2 {
                Send {Up}
            }
            HoverCancelCandidate()
        }
    }
}


; Returns indexes that were not requested
GetNonRequested( requested )
{
    notRequested := []

    ; index used for iterating over requested
    i := 1
    Loop % g_inventory.Length() {
        if ( A_Index != requested[ i ] )
        {
            notRequested.Push( A_Index )
        }
        else 
        {
            i++
        }
    }
    return notRequested
}


; selects the first confirmation in the trade
InitialTradeConfirm()
{
    ; if in the trade menu
    if ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
    {
        currentPos := FindPurposePos()
        ; if confirmed is highlighted 
        if ( currentPos == 4 )
        {
            EnterIfInTrade()
        }
        else if ( currentPos == 5 )
        {
            Send {Up}
            InitialTradeConfirm()
        }
        else 
        {
            Loop % ( 4 - currentPos ) {
                Send {Down}
            }
            InitialTradeConfirm()
        }
    }
}


; SHOULD MAKE A FUNCTION that will find which menu it's in and use it in the else statement???
; Finds current position of the "Purpose" menu returns 1 - 5
FindPurposePos()
{
    searchTime := 400

    if ( VerifyScreen( "TradeImages\addItem.png", searchTime ) )
    {
        return 1
    }
    else if ( VerifyScreen( "TradeImages\cancelCandidate.png", searchTime ) )
    {
        return 2
    }
    else if ( VerifyScreen( "TradeImages\verifyItems.png", searchTime ) )
    {
        return 3
    }
    else if ( VerifyScreen( "TradeImages\confirmed.png", searchTime ) )
    {
        return 4
    }
    else if ( VerifyScreen( "TradeImages\cancelTrade.png", searchTime ) )
    {
        return 5
    }
    else 
    {
        ; if it didn't match any of those images
        FindPurposePos()
    }
}


; Selects the final yes after the final confirmation was selected
SelectFinalYes()
{
    ; if in the trade menu
    if ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
    {
        if ( VerifyScreen( "TradeImages\bothConfirmed.png", 1000 ) )
        {
            Send {Up} ; pressing up in this menu will not reset to the bottom selection. 
            if ( VerifyScreen( "TradeImages\yes.png", 1000 ) )
            {
                EnterIfInTrade()
            }
        }
        else
        {
            SelectFinalYes() ; recursively call itself in the chance that it didn't find the bothConfirmed.png in time
        }
    }
}


; selects the final trade confirmation
FinalTradeConfirmation()
{
    ; if in the trade menu
    if ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
    {
        currentPos := FindConfirmedPos()
        ; if Final Confirmation is highlighted 
        if ( currentPos == 3 )
        {
            EnterIfInTrade()
        }
        else if ( currentPos == 4 )
        {
            Send {Up}
            FinalTradeConfirmation()
        }
        else 
        {
            Loop % ( 3 - currentPos ) {
                Send {Down}
            }
            FinalTradeConfirmation()
        }
    }
}


; Finds current position of the "Confirmed" menu returns 1 - 4
FindConfirmedPos()
{
    searchTime := 400

    if ( VerifyScreen( "TradeImages\confirmedVerifyItems.png", searchTime ) )
    {
        return 1
    }
    else if ( VerifyScreen( "TradeImages\cancelConfirmation.png", searchTime ) )
    {
        return 2
    }
    else if ( VerifyScreen( "TradeImages\finalConfirmation.png", searchTime ) )
    {
        return 3
    }
    else if ( VerifyScreen( "TradeImages\cancelTrade.png", searchTime ) )
    {
        return 4
    }
    else 
    {
        ; if it didn't match any of the above images
        FindConfirmedPos()
    }
}


; returns the total of all requested items
GetTradeTotal( requestedInventory )
{
    totalCost := 0
    Loop % requestedInventory.Length() {
        totalCost += g_itemPrices[ requestedInventory[ A_Index ] ]
    }
    return totalCost
}


; Checks screen to verify the correct payment is in the trade window.  WILL NOT ACCEPT OVER PAYMENT
IsPaymentCorrect( totalCost )
{
    customerPay := 0
    ; Looks like the background is different for all 3 positions, position 3 will scroll down and look different if there is 4 or more items in the trade window
    ; I CAN PROBABLY USE THE SAME xNumber pic for all positions as long as they are same color and I keep the pic small (pos3 has markings close by)
    ; FOR NOW I will only implement POS 1 and pds 

    ; CUSTOMERS TRADE OFFER WINDOW POSITIONS
    offerWindowPositions := [ 30, 300, 350, 370 ]
    amountPos1 := [ 315, 300, 350, 325 ] 
    amountPos2 := [ 315, 315, 350, 350 ]
    amountPos3 := [ 315, 335, 350, 370 ]


    ; if there's photon drops in the first position
    if ( VerifyImageInPosition( offerWindowPositions, "TradeImages\photonDropPos1.png", 2000 ) )
    {
        xAmountImage := "TradeImages\xAmount\x" totalCost ".png"
        if ( VerifyImageInPosition( amountPos1, xAmountImage, 2000 ) )
        {
            customerPay += totalCost
        }
    }
    ; check to make sure there is nothing in the second trade offer position
    ; accepting unacknowledged items will throw the script off
    if ( !VerifyImageInPosition( offerWindowPositions, "TradeImages\emptyPos2.png", 2000 ) )
    {
        ; set it back to 0 if there is unexpected item offers in the window
        customerPay := 0
    }
    return customerPay == totalCost
}


; Verify that the image is in the specified positions
VerifyImageInPosition( positions, filePath, searchTime )
{
    ; starting corner for image searching
    x1 := positions[1]
    y1 := positions[2]

    ; ending corner for image searching
    x2 := positions[3]
    y2 := positions[4]

    imageFound := False
    searchTimer := A_TickCount
    ; while imageFound == false, loop for up to searchTime seconds
    while ( !imageFound and A_TickCount - searchTimer < searchTime )
    { 

        ; ImageSearch, , , 0, 0, A_ScreenWidth, A_ScreenHeight, *200 %filePath%
        ImageSearch, , , x1, y1, x2, y2, *125 %filePath%
        if (ErrorLevel = 2)
            MsgBox Could not conduct the search for %filePath%
        else if (ErrorLevel = 1)
            imageFound := False
        else
            imageFound := True
    }
    return imageFound
}


; Returns true if the message was said close to the time expected
IsMessageInLog( msg, timeSaid )
{
    foundInTime := False
    chatLog := GetChatAsArray()
    saidWithinTime := SaidRecentlyInLog( chatLog, timeSaid )
    /* DELETE THIS COMMENT AFTER TESTING IS FINISHED
    MessageArray( saidWithinTime )
    test := StrLen(saidWithinTime[ 1 ])
    msgTest := StrLen(msg)
    MsgBox said in log length %test%  msg length %msgTest%
    */
    if ( saidWithinTime )
    {
        Loop % saidWithinTime.Length() {
            ; it seems that the strings returned from the chatlog have an extra space added to them
            ; HAVE ONLY TESTED WITH "Trade me txt" so far
            logText := SubStr( saidWithinTime[ A_Index ], 1, -1 )
            if ( msg == logText ) 
            {
                foundInTime := True
            }
        }
    }
    return foundInTime
}


; Was message said in X time 
SaidRecentlyInLog( log, timeSaid )
{
    saidInTimeLine := []
    Loop % log.Length() {
        ; splitLine[1] = time, splitLine[2] = guildcard/KeyPress, splitLine[3] = aUserName/WhatKeyPressDid, splitLine[4+] = words in chat ( there can be more than 4 if there is a tab in the chat ?? )
        splitLine := StrSplit( log[ A_Index ], "`t" ) ; could also use A_Tab ?
       
        ; time stamp of the chat log was said within 20 seconds of the timeSaid variable
        if ( TradeTimer( ChatLogTimeInSecs( splitLine[1] ) ) - TradeTimer( timeSaid ) <= 20 )
        {
            ; I STILL NEED TO CHECK IF THERE IS ANY indexes higher than 4 in splitLine
            ; pushes splitLine[ 4+ ] into a variable 
            Loop % splitLine.Length() - 3 {
                saidInTimeLine.Push( splitLine[ A_Index + 3 ] )
            }
        }
    }
    return saidInTimeLine
}


; Send {Enter} if in trade window
EnterIfInTrade()
{
    if ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
    {
        Send {Enter}
    }
}


; Send {Space} while in trade menu and chatStart.PNG and greenChat.PNG are not on screen
StartChatInTrade()
{
    ; while in the trade menu
    while ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
    {
        ; do not need to check for cancelled.PNG as that is only available when redMenu.PNG is not
        if ( VerifyScreen( "TradeImages\chatStart.PNG", 2000 ) or VerifyScreen( "TradeImages\greenChat.PNG", 1000 ) ) 
        {
            ; Exit out of the loop, the chat is seen as started.
            Break
        }
        else
        {
            Send {Space}
            Sleep 200
        }
    }
}


; Finish/say/send in-game chat
SendChatInTrade()
{
    if ( VerifyScreen( "TradeImages\greenChat.PNG", 1000 ) )
    {
        if ( VerifyScreen( "TradeImages\playerJoining.PNG", 1000 ) )
        {
            Sleep 1000
            SendChatInTrade()
        }
        else
        {
            ; maybe want to replace this with regular Send {Enter} ??? 
            EnterIfInTrade()
        }
    }
    ; if chat was started, but no other keys have been input
    else if ( VerifyScreen( "TradeImages\chatStart.PNG", 1000 ) )
    {
        if ( VerifyScreen( "TradeImages\playerJoining.PNG", 1000 ) )
        {
            Sleep 1000
            SendChatInTrade()
        }
        else
        {
            ; chat input was started but the message was never input, Send {Esc} and hopefully get out of chat input
            Send {Esc}
            Sleep 1000
        }
    }
    ; still in trade
    else if ( VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 ) )
    {
        if ( !VerifyScreen( "TradeImages\playerJoining.PNG", 1000 ) and !VerifyScreen( "TradeImages\greenChat.PNG", 1000 ) and !VerifyScreen( "TradeImages\chatStart.PNG", 1000 ) )
        {
            ; it's believed that the chat input is not up
        }
        else
        {
            SendChatInTrade()
        }
    }
}


; Script says message in game, during trade.
SayMsgInTrade( msg )
{
    StartChatInTrade()
    Send %msg%
    SendChatInTrade()
    ; WILL EVENTUALLY RUN some sort of check to make sure the script spoke in chat
}