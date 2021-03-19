; Need to figure out how to use OCR and find the best place to use it/ where it matches best
;     I should only try to implement this if people decide to try to grieve my shop script???
;     It works fairly well to retrieve names but I would have to add multiple languages and that may or may not be worth it???
;     If I do use it I should allow it to fuzzy match names???
;     Some names are cut off when stored in the games chat log files
;       Such as MagMaker3k , that is saved as gMaker3k
;
; 
; I could make a variable that will store the guildcard of a player and apply the discount for buying multiple items in seperate purchases
;   Would mostly be useful once I can accept and bank meseta 
;
;
; Should be able to accept up to 3 different currencies at a time
;     based on the background of the trade window, anymore than 3 and I might have to consider adding the slider into images which = a headache
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
; WHEN ADDING IN the fail saves, I should check to make sure the player joining window is not displayed?
;   SHOULD PREVENT trying to repeat actions while no inputs are accepted
;   IF ANOTHER PLAYER IS NOT JOINING, lag should be the only issue for inputs/macros messing up
;
;
; WILL NEED TO MAKE SURE currency images are taken at the same position ( and are the same size??? position alone should be fine)
;   will make searching easier and more reliable
;
;
; I NEED TO WRITE A FUNCTION that will check the chatlog to make sure that it has completed & was succesful when talking to customers/ giving instructions
;   I may want to repeat the instructions or just make sure it's not still trying to talk by escaping multiple times
;       IsMessageInLog( msg, timeSaid ), still needs to be tested and implemented when the script sends a message in game
;
;
;   I have not fully tested my timer functions/math ( STILL HAVE NOT TESTED TO SEE IF IT TIMES OUT AT 5 MINS )
;       I need to look further into AHK's native time methods
;           using A_TickCount becomes unstable on slow machines ( times are often off by varying amounts sometimes drastic )
;       
;
;   CURRENTLY ADDING AND WILL NEED TO TEST:
;       correctly cancel out of the trade window,  HandleTradeCancel()
;       check if other player left game/ trade window.  If so break out of WatchChatLog()
;       check if the message that the script tried to relay to the customer made it to the chat log, IsMessageInLog( msg, timeSaid )
;
;       STILL NEED TO WRITE IsPaymentCorrect( totalCost ) TO CHECK PAYMENTS
;           check if other player has paid the correct amount and confirmed the trade 
;       
; 

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#IfWinActive Ephinea: Phantasy Star Online Blue Burst
; #Include <Vis2>
SendMode Event        ; REQUIRED!!!! PSOBB won't accept the deemed superior
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 190, 70   ; SetKeyDelay, 150, 70  1st parameter is delay between keys 2nd is how long the button is pressed

; CHANGE THIS TO PSO's DIRECTORY
global g_psoDirectory := "C:\Program Files\EphineaPSO"

global g_inventory := GetInventory()
MessageArray( g_inventory )
global g_itemPrices := []
Loop % g_inventory.Length() {
    g_itemPrices.Push( 2 )
    }

global g_timeItemsShown := 0


^p:: Pause  ; Ctrl + P - Pauses script.
     

^t:: ; Ctrl + T - Test if it's parsing the chatlog down to numbers only
    
    test := VerifyScreen( "TradeImages\laptoptradeProposal.png", 3000 )
    MsgBox %test% 
    return


^q:: ; Ctrl + Q - Display itemsInventory 
    displayInventory := ""
    Loop % g_inventory.Length() {
        displayInventory := displayInventory "`n" g_inventory[ A_Index ]
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
            ; if 
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
        ImageSearch, , , 0, 0, A_ScreenWidth, A_ScreenHeight, *125 %filePath%
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
;      Show Items - Add all items of your inventory to the trade.
; ----------------------------------------------------------

ShowItems()
{
    Loop % ( g_inventory.Length() * 2 ) {
        Send {Enter}
        ; if I add in one extra Send "{Enter}" and check on the final iteration of the loop for the noItem.png or check for the currency that should be inventory
        ;   It would verify that all items are displayed/in trade and in order ( because it was just sending the Enter key ) 
        ; Would need to add a Send "{Backspace}" after seeing noItem.png
        ;   then verify that it's back in the trade menu with, VerifyScreen( "TradeImages\addItem.png" )
    }
}



TradeMeText()
{
    message := "Trade me txt"
    Send {Space}%message%{Enter}
    ; Send {Space}I am an automated trader, running via AHK script :) {Enter}
    ; Send {Space}Please send me a trade offer to see what I have for sale :) {Enter}

    textTimeStamp := TimeInSecs( A_Hour, A_Min, A_Sec )
    ; if the message was not said recently
    if ( !IsMessageInLog( message, textTimeStamp ) ) 
    {
        MsgBox did not say the trade me txt recently
        ; Will need to decide how I will want to handle the text not being in the log
        ; I suspect the main reason it will not have the message in the chat recently is because of players joining
        ; SHOULD I JUST MAKE SURE ITS NOT TRYING TO TALK STILL?? send escape or backspace to make sure its not still sending a message?
        ; THERE SHOULD BE NO HARM IN USING Send {Space} , except that it should bring up the chat input if it's not already up
        ; SHOULD I CHECK IF THE PLAYER IS JOINING WINDOW IS UP?
    }
}



GiveInstructions()
{
    numOfItems := g_inventory.Length()
    instructions := "Tell me the index (1-" numOfItems ")"
    ;Send {Space}Tell me the index (1-%numOfItems%){Enter}
    Send {Space}%instructions%{Enter}
    ; Send {Space}Tell me the index (1-%numOfItems%) of the item you are interested in {Enter}
    ;textVar :=  "%s or it's stats :)"
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
    ; WILL PROBABLY HAVE TO MAKE THIS VARIABLE GLOBAL
    tradeFinished := False
    requestedItemIndexes := []
    tradeTotal := GetTradeTotal( requestedItemIndexes )
    ; trade for up to 5 minutes (300 = 5mins), or until tradeFinished = true
    while ( TradeTimer( g_timeItemsShown ) < 300 and !tradeFinished ) 
    {
        ; array of index numbers found in the current chat log
        requestedIndex := FindRequestedIndexes()

        if ( VerifyScreen( "TradeImages\cancelled.PNG", 1500 ) )
        {
            ; exit out of the cancel pop up and tell customer thanks for looking
            HandleTradeCancel()
            ; set to True to stop the loop it's in, COULD ALSO THROW A BREAK IN HERE INSTEAD
            tradeFinished := True
        }
        /*
        ; CHECK TO MAKE SURE YOU ARE IN THE TRADE WINDOW.  To make sure the other player didn't leave the game/log off
        else if ( "SomeImageOnlySeenInTrades I STILL NEED TO TAKE THE IMAGE!!!" )
        {
            Break
        }
        */
        

        ; if it's the initial item/s request
        if ( requestedItemIndexes.Length() == 0 and requestedIndex.Length() > 0 ) 
        {
            requestedItemIndexes := requestedIndex
            ; Removes non requested items from the trade window
            RemoveExcessItems( requestedItemIndexes )
        }
        /*  COMMENTED OUT, CAN ADD THIS IDEA IN AT A LATER DATE if I still want to
        ; else if more items are requested
        else if ( requestedItemIndexes.Length() < requestedIndex.Length() )
        {
            requestedItemIndexes := requestedIndex

            ; add the requestedItemIndexes to the trade if they are not already
            ; WILL WRITE THIS FUNCTION AT A LATER DATE / not needed for beta concept
        }
        */
        ; should only go into this if statement after items have been requested and left/added to trade one or more times
        else if ( requestedItemIndexes.Length() > 0  )
        {
            ; should navigate to the first trade confirm and select it
            InitialTradeConfirm()
        }
        ; if customer has confirmed the 1st time and 1 or more items have been requested
        ;  ( only requested items should be in the trade window )
        else if ( requestedItemIndexes.Length() > 0 and  VerifyScreen( "TradeImages\customerConfirmed.PNG", 1500 ) )
        {
            ; Check if customer has put the appropriate payment into the trade window
            if ( IsPaymentCorrect( tradeTotal ) )
            {
                ; Verify the customer has selected the final confirmed 
                if ( VerifyScreen( "TradeImages\customerFinalConfirmed.PNG" ) )
                {

                }
                ; Customer still needs to do do the final/2nd confirmation
                else
                {
                    Send {Space}Select the final confirmation plz{Enter}
                }
            }
            ; Tell customer how much to pay, placed it here so it checks for the payment first
            ; should help prevent spamming the customer to put the money in the trade window when it's already there 
            else
            {
                Send {Space}%tradeTotal%pd, then confirm trade plz{Enter}
            }
        }
        ; if 1 or more items requested but customer has not confirmed
        else if ( requestedItemIndexes.Length() > 0 and  !VerifyScreen( "TradeImages\customerConfirmed.PNG", 1500 ) )
        {
            ; I COULD AND MIGHT CHECK TO SEE IF THE PDS ARE IN THE TRADE WINDOW 
            ; THEN RESPOND TO CUSTOMER APPROPRIATELY 
            Send {Space}%tradeTotal%pd, then confirm plz{Enter}
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


; NOT FUNCTIONING YET
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
    
    nonRequestedItems := GetNonRequested()
    ; the "Cancel Candidate" menu retains the position in between cancels
    cancelPos := 1

    ; this variable will be used later to decide which images to match on screen, to verify the correct items are being removed
    itemsInTrade := g_inventory.Length()

    Loop % nonRequestedItems.Length() {
        ; selects "Cancel Candidate"
        Send {Enter}

        
        if ( cancelPos == nonRequestedItems[ A_Index ] )
        {
            ; removes unwanted item from trade menu
            Send {Enter}
        }
        else 
        {
            ; unsure if A_Index from the above loop will be accepted here
            ; should hover/highlight the next unwanted item
            Loop % ( nonRequestedItems[ A_Index ] - cancelPos ) {
                Send {Down}
                cancelPos++
            }
            ; removes unwanted item from trade menu
            Send {Enter}
        }
    ; decrease the variable to reflect the item that was removed from trade    
    itemsInTrade--
    }

}


; hover/highlight "Cancel Candidate"
HoverCancelCandidate()
{
    currentPos = FindPurposePos()
    if ( currentPos == 2 )
    {
        ; do nothing/exit function
    }
    else if ( currentPos == 1 )
    {
        Send {Up}
        HoverCancelCandidate()
    }
    else 
    {
        Loop % FindPurposePos() - 2 {
            Send {Down}
        }
        HoverCancelCandidate()
    }
}


; Returns items that were not requested
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
    currentPos = FindPurposePos()
    ; if confirmed is highlighted 
    if ( currentPos == 4 )
    {
        Send {Enter}
    }
    else if ( currentPos == 5 )
    {
        Send {Down}
        InitialTradeConfirm()
    }
    else 
    {
        Loop % ( 4 - currentPos ) {
            Send {Up}
        }
        InitialTradeConfirm()
    }
}


; Finds current position of the "Purpose" menu returns 1 - 5
FindPurposePos()
{
    if ( VerifyScreen( "TradeImages\addItem.png", 200 ) )
    {
        return 1
    }
    else if ( VerifyScreen( "TradeImages\cancelCandidate.png", 200 ) )
    {
        return 2
    }
    else if ( VerifyScreen( "TradeImages\verifyItems.png", 200 ) )
    {
        return 3
    }
    else if ( VerifyScreen( "TradeImages\confirmed.png", 200 ) )
    {
        return 4
    }
    else if ( VerifyScreen( "TradeImages\cancelTrade.png", 200 ) )
    {
        return 5
    }
    else 
    {
        FindPurposePos()
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


; Checks screen to verify the correct payment is in the trade window
IsPaymentCorrect( totalCost )
{
    customerPay := 0
    position1 := 
    ; I NEED TO FIGURE OUT WHAT IS POS 1, 2 and 3 of the customers window
    ; FOR NOW I will only implement POS 1 and pds 

    ; if theirs photon drops in the first position
    if ( VerifyImageAt( position1 ) )
    {

    }
}


; Verify that the image is at the specified position
VerifyImageAt(  position, filePath, searchTime )
{
    /* 
    ; I SHOULD ONLY NEED THE START POSITION TO FIND THE IMAGES IN THE CORRECT POSITION
    ; Otherwise if I need the end point and I know the pictures dimensions
    ;   then the below will help
    xSize := ; THE PICTURES WIDTH
    xEnd := xStart + xSize

    ySize := ; THE PICTURES HEIGHT
    yEnd := yStart + ySize
    */

    imageFound := False
    searchTimer := A_TickCount
    ; while imageFound == false, loop for up to searchTime seconds
    while ( !imageFound and A_TickCount - searchTimer < searchTime )
    { 

        ; ImageSearch, , , 0, 0, A_ScreenWidth, A_ScreenHeight, *200 %filePath%
        ImageSearch, , , position, A_ScreenWidth, A_ScreenHeight *125 %filePath%
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
    saidWithinTime := SaidInThisTrade( chatLog, timeSaid )
    if ( saidWithinTime )
    {
        Loop % saidWithinTime.Length() {
            if ( saidWithinTime == msg ) 
            {
                foundInTime := True
            }
        }
    }
    return foundInTime
}


; Was message said in X time 
SaidInThisTrade( log, timeSaid )
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