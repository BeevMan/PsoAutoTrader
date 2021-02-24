; PSO's chatlog saves to C:\Users\bilbo\EphineaPSO\log
;   Will be useful when needing to read customers response/request
;
;
; Need to figure out how to use OCR and find the best place to use it/ where it matches best
;     I should only try to implement this if people decide to try to grieve my shop script
;     It works fairly well to retrieve names but I would have to add multiple languages and that may or may not be worth it
;     If I do use it I should make it match names from the chatlog by having so many of the same characters, in the chance that it didn't find the name perfectly
;
; 
; I could probably make a variable that will store the guildcard of a player and apply the discount for buying multiple items in seperate purchases
;   Would mostly be useful once I can accept and bank meseta 
;
;
; Should be able to accept up to 4 different currencies at a time
;     based on the background of the trade window, anymore than 4 and I might have to consider adding the slider into images which = a headache
;
;
;
;   CURRENTLY I AM WORKING ON sorting through the chat log to decide which index/item the customer wants
;   

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#IfWinActive Ephinea: Phantasy Star Online Blue Burst
; #Include <Vis2>
SendMode Event        ; REQUIRED!!!! PSOBB won't accept the deemed superior
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 100, 70   ; SetKeyDelay, 150, 70  1st parameter is delay between keys 2nd is how long the button is pressed

; change the directory and save the inventory as inventory.txt
; I SHOULD REWORK THIS TO GET THE NEWEST saved_inventory.txt from the directory
FileRead, inventoryTxt, C:\Program Files\EphineaPSO\addons\Item Reader\inventory\inventory.txt
global g_inventory := StrSplit( inventoryTxt, "`n" )
; when the item reader addon saves an inventory file, it ends in a newline
;   remove the last newline so it's the same length as the inventory
g_inventory.RemoveAt( g_inventory.Length() )
global g_itemPrices := []
Loop % g_inventory.Length() {
    g_itemPrices.Push( 2 )
    }

global g_timeItemsShown := 0


^p:: Pause  ; Ctrl + P - Pauses script.
     

^t::
    
    return

^q:: ; Ctrl + Q - Display itemsInventory 
    displayInventory := ""
    Loop % g_inventory.Length() {
        displayInventory := g_inventory "`n"
        displayInventory := displayInventory g_inventory[ A_Index ]
    } 
    MsgBox  itemsInventory, starting at index 1 %displayInventory%
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
            if ( VerifyScreen( "TradeImages\yesTradeProposal.png", 3000 ) )
                {
                Send {Enter} ; accept the trade offer
                if ( VerifyScreen( "TradeImages\addItem.png", 3000 ) )
                    {
                    ShowItems() ; adds all items from your inventory to the trade, allowing other player to see the goods.
                    g_timeItemsShown := TimeInSecs( A_Hour, A_Min, A_Sec )
                    GiveInstructions() ; tell other player/s to tell me the index or stats/%s of the item they want to buy.
                    ; currentTraderName should only be needed if people start to grieve my shop script I.E intentionally try to mess it up by saying random numbers and or stats while it's trading with others
                    ; currentTraderName := WindowOCR(40,280,120,15, "Ephinea: Phantasy Star Online Blue Burst") ; using Optical Character Recognition (OCR), get current tradee's username
                
                    ;
                    ; watch chat log for trade instructions for up to 5 minutes? while also checking to make sure trade is not cancelled OR CONFIRMED???
                    ;   will also call to a function that will leave only the requested items in the trade ??? after tradee has requested it/them.
                    WatchChatLog()
                    


                    }
                }
            }
        else 
            {
            sleep, 3000
            ++loopsWithNoTrade
            }
        }
    return




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
        ImageSearch, , , 0, 0, A_ScreenWidth, A_ScreenHeight, %filePath%
        if (ErrorLevel = 2)
            MsgBox Could not conduct the search for %filePath%
        else if (ErrorLevel = 1)
            imageFound := false
        else
            imageFound := true
    }

    /*
    ; if the image could not be found in the while loop
    if ( !imageFound )
        {
        g_failedSearches.Push( filePath ) 
        }
    */
    return imageFound
}


; ----------------------------------------------------------
;  Function
;      Show Items - Add all items of your inventory to the trade.
; ----------------------------------------------------------

ShowItems()
{
    Loop % ( g_inventory.Length() * 2 ) {
        Send {Enter}
        ; if I add in one extra Send "{Enter}" and check on the final iteration of the loop for the noItem.png 
        ;   It would verify that all items are displayed/in trade and in order ( because it was just sending the Enter key ) 
        ; Would need to add a Send "{Backspace}" after seeing noItem.png
        ;   then verify that it's back in the trade menu with, VerifyScreen( "TradeImages\addItem.png" )
    }
}



TradeMeText()
{
    Send {Space}I am an automated trader, running via AHK script :) {Enter}
    Send {Space}Please send me a trade offer to see what I have for sale :) {Enter}
}



GiveInstructions()
{
    numOfItems := g_inventory.Length()
    Send {Space}Tell me the index (1-%numOfItems%) of the item you are interested in {Enter}
    textVar :=  "%s or it's stats :)"
    ;Send {Space}Alternitavely, tell me the item's %textVar% {Enter}
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
    tradeFinished := false
    
    ; trade for up to 5 minutes (300 = 5mins), or until tradeFinished = true
    while ( TradeTimer( g_timeItemsShown ) < 300 and !tradeFinished ) 
    {
        chatLogDuringTrade := []
        requestedIndex := []

        if ( VerifyScreen( "TradeImages\cancelled.PNG", 1500 ) )
        {
            ; exit out of the cancel pop up and tell customer thanks for looking?
            Send {Enter}
            if ( VerifyScreen( "TradeImages\cancelled.PNG", 2000 ) )
            {
                Send {Enter}
                ; THIS WILL NOT FOR SURELY GET ME OUT OF HERE I NEED A BETTER CHECK
            }
            if ( !VerifyScreen( "TradeImages\cancelled.PNG", 1500 ) )
            {
                Send {Space}TY for looking :){Enter}
            }
            else 
            {
                ; THIS WILL NOT FOR SURELY GET ME OUT OF HERE I NEED A BETTER CHECK
                Send {Enter}
            }
        }
        else if ( chatLogDuringTrade.Length() <= 0 )
        {
            newestChatTxt := GetCurrentChatLog()
            FileRead, entireChatLog, %newestChatTxt%
            chatLogArray := StrSplit( entireChatLog, "`n" )


            Loop % chatLogArray.Length() {
                ; splitLine[1] = time, splitLine[2] = guildcard/KeyPress, splitLine[3] = aUserName/WhatKeyPressDid, splitLine[4+] = words in chat ( there can be more than 4 if there is a tab in the chat )
                splitLine := StrSplit( chatLogArray[ A_Index ], "`t" )

                
                ; If the line of chat was said since being shown the items for trade.
                if ( TradeTimer( ChatLogTimeInSecs( splitLine[1] ) ) <= TradeTimer( g_timeItemsShown ) )
                {
                    wordsInChat := StrSplit( splitLine[4], " " )
                    chatLogDuringTrade.Push( splitLine[4] )
                    /*
                    Loop % wordsInChat.Length() {
                        checkNumb := wordsInChat[ A_Index ] + 0
                        if checkNumb is number ; Will only be true if it contains only Numbers! ; is KEYWORD is not valid in an expression
                           requestedIndex.Push( wordsInChat[ A_Index ] )
                    }
                    */
                }

            }

            ; check for messages since the trade had my items shown
            ;   then check through that for item requests I.E what GiveInstructions() tells user
        }

        displayChat := ""
        Loop % chatLogDuringTrade.Length() {
            displayChat := displayChat "`n" chatLogDuringTrade[ A_index ]
            ;MsgBox, %displayChat%
        }
        MsgBox, Should contain only chat occuring since I showed my items. %displayChat%

        /*
        requested := ""
        Loop % requestedIndex.Length() {
            requested += "`n" requestedIndex[ A_index ]
        }
        MsgBox, these numbers were found in the chatlog during the trade %requested%
        */
    }
}




GetCurrentChatLog()
{
    Loop, Files, C:\Program Files\EphineaPSO\log\chat*.txt 
    {
        newestChatLog := ""
        lastModifiedTime := 0  
        if (  lastModifiedTime - A_LoopFileTimeModified > 0 or lastModifiedTime == 0 )
        {
            newestChatLog := A_LoopFileName
            lastModifiedTime := A_LoopFileTimeModified
        } 
    }
    return "C:\Program Files\EphineaPSO\log\"newestChatLog
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
    ; if it returns 300 or more it has been 5+ minutes
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