; https://www.autohotkey.com/docs/commands/FileInstall.htm
;   CAN BE USED TO compile all the folders/files and script into an exe???
;
;
; X Need to figure out how to use OCR and find the best place to use it/ where it matches best
;     THIS COULD BE USEFUL FOR CHECKING CHAT BEFORE TRYING TO ENTER IT
;       NEED TO test, in trade and outside of trade.
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
;       requires that the script not pick up extra items
;       would have to be able to detect and give a message to customer to pick up and move any items from the banking area
;   Could even give new players discounts if I can find out what the current guild card numbers are ( make new accnt )
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
; X ADDED CHECK for currencies in the inventory and stackable items when the user iniates the trading script ( Ctrl + J )
;   Script requires atleast one of each accepted currency at the end of it's inventory or a full inventory 30/30
;       otherwise it could lead to vulnerabilities when/if it messes up in chat ( picking up dropped items )
;   script is currently not capable of trading stackable items
;   currency that is being accepted should not also be sold, at least at this time
;
;
; I SHOULD look into where the item reader addon pulls its data from???
;       I COULD POSSIBLY use it to replace the inventory.txt parsing???
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
; Their is risk of the inventory desyncing 
;   Ender said "This game is old and almost everything is client side and the server just tries to match what clients are doing with tons of sanity checks. Inventory desync seems to happen for no reason sometimes, probably obscure client bugs given how rare."
;       Cameron was able to make it desync on it's first public shop.  I did not watch to see what would happen afterwards :(  logged out/in and restarted instead
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
;   While NOT in a trade, if the message is not found recently in the chatlog:
;       then it should be assumed:
;           the chat input is still up, which could stop trade offers from appearing
;               chat input could still be up do to somebody recently joining or currently joining
;                   ??? check to make sure their is not a player joining ??? playerJoining.PNG or look into searching for a pixel of the playerJoining.PNG pixelSearch ???
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
; SayMsgInTrade() can skip the beginning of it's messages if/when transparency in the ImageSearches is too much or little
;   VerifyScreen( filePath, searchTime ) and VerifyImageInPosition( positions, filePath, searchTime ) for imageSearching
;
;
; leftSide images used when there is less then 3 itemsInTrade
;   leftSide3rd.PNG needed when currentPos == 3 and there is 3 itemsInTrade
; Or when it is the first two or last two itemsInTrade as they share the same slider image and need an additional image check to verify it is at the correct spot
; leftSide1 matches incorrectly above *145
; leftSide2 matches the 3rd item, *140, when there is 4 items in the inventory
;    leftSide2.PNG matches 2nd item - 3rdToLast item, when there is 5 or more items in the inventory
; leftSide3 matches for 2nd item, above *140, when there is 4 items in the inventory
;    leftSide3.PNG matches 3rd item - 2ndToLast item, when there is 5 or more items in the inventory
; leftSide4 matches incorrectly above *160  ( where imagery was taken ) ( old images had issues at *110 )
;
; When there is only 3 items in trade and the 3rd is highlighted leftSide4.PNG matches at *150???
;
; confirmed.PNG matches incorrectly above *145
;
;
; Issue fixed on FindPurposePos() and HoverCancelCandidate() 
;   TRANSPARENCY MATTERS for many of the menu positions ( if highlights ) should test further/take notes of image transparency requirements
;
;
; I MIGHT BE ABLE TO take images of the size of the green slider its self inside the cancel/verify items menu
;   and use them to find inventory size? not sure it would be of any use
;
;
; PEOPLE CAN TRICK THE SCRIPT INTO PICKING UP ITEMS WHEN IT TRIES TO CHAT
;   if the script starts with no pds at the end of the inventory it can be tricked into picking up items from chat mess ups and stop it from trading
;       if it doesn't have a full inventory or pds at the end of it's inventory when starting IT COULD BE A PROBLEM
; Script can also go off walking if chat input is not up and it's trying to input a message
;   Could require the use of f11 ( turns keyboad into chat only? ), would have to edit chat sending/functions
;   X NOW loops through the message and Send each individual character its self
;       should help prevent picking up items / unwanted inputs
;
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
;#IfWinActive Ephinea: Phantasy Star Online Blue Burst
; #Include <Vis2>
SendMode Event        ; REQUIRED!!!! PSOBB won't accept the deemed superior
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 290, 80   ; SetKeyDelay, 220, 70  1st parameter is delay between keys 2nd is how long the button is pressed
SetBatchLines, -1

; CHANGE THIS TO PSO's DIRECTORY
global g_psoDirectory := "C:\Users\beeni\EphineaPSO"

; g_inventory DOES NOT store/track accepted/incoming currencies, as it does not want to add it to the trade window
global g_inventory := GetInventory()
MessageArray( g_inventory )
global g_itemPrices := []
Loop % g_inventory.Length() {
    g_itemPrices.Push( 1 )
    }

global g_timeItemsShown := 0
global g_photonDrops := 0

; rough position of a blank piece of red menu that should only be blank during a trade
global g_emptyMenuPosition := [ 45, 60, 145, 110 ]

; rough positions used for imageSearching when removing items
global g_leftBarPosition := [ 15, 370, 50, 480 ]
; owner's slider position during "Add item for trade"
global g_sliderPosition := [ 335, 370, 350, 475 ]

; rough positions for chat input
global g_chatPosition := [ 20, 435, 220, 475 ]


^p:: Pause  ; Ctrl + P - Pauses script.
     

t:: ; Ctrl + T - Test
    MsgBox % GetTradeTotal( [ 1, 2, 3 ] )
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

    IsInvAllowed() ; Check to make sure the inventory follows the scripts guidelines

    WaitForTrades()

    ; SHOULD CHANGE GAME ROOM NAME TO "OOS" Out Of Stock or ( Service )
                
    MsgBox "End of the trading script"
    return


; Gives directions to trade, accepts incoming trade offers then calls the appropriate functions
WaitForTrades()
{
    loopsWithNoTrade := 0
    ; WILL NEED TO CHANGE THE CURRENCY CHECK when it accepts multiple currencies, or when individual item prices can be set
    while ( g_inventory.Length() > 0 and ( g_photonDrops + g_itemPrices[ 1 ] ) <= 99 ) 
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
                    GiveInstructions() ; tell other player/s to tell me the index of the item/s they want to buy.
                    ; currentTraderName should only be needed if people start to grieve my shop script I.E intentionally try to mess it up by saying random index/s while it's trading with others
                    ; currentTraderName := WindowOCR(40,280,120,15, "Ephinea: Phantasy Star Online Blue Burst") ; using Optical Character Recognition (OCR), get current tradee's username

                    ; watch chat log for trade instructions for up to 5 minutes? while also checking to make sure trade is not cancelled OR CONFIRMED
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
}


; Any acceptable currency placed at the end will be tracked, if less than 30 items or contains other stackables ExitApp
IsInvAllowed()
{
    lastItem := g_inventory[ g_inventory.Length() ]
    ; last item/s in inventory is photon drop/s
    if ( InStr( lastItem, "Photon Drop" ) )
    {
        splitItem := StrSplit( lastItem, "x" ) ; the 2nd index should contain a number
        g_photonDrops += splitItem[ 2 ]
        g_inventory.RemoveAt( g_inventory.Length() ) ; remove Photon Drop/s from the array
        g_itemPrices.RemoveAt( g_itemPrices.Length() ) ; removes the price that was listed for Photon Drop/s
    }
    else if ( g_inventory.Length() < 30 )
    {
        MsgBox "Please start with an inventory of 30/30.  Or end your inventory with Photon Drop/s.  Exiting script."
        ExitApp
    }
    ; Loop through the inventory and make sure their are no stackable items
    Loop % g_inventory.Length() {
        checkItem := g_inventory[ A_Index ]
        splitItem := StrSplit( checkItem, "x" )
        if ( splitItem[ 2 ] and IsDigit( splitItem[ 2 ] ) )
        {
            MsgBox "Accepted currencies at the end of inventory are the only allowed stackables.  Exiting script."
            ExitApp
        }
    }
}


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
        ImageSearch, , , 0, 0, A_ScreenWidth, A_ScreenHeight, *120 %filePath%
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
        ; CHECK THAT "add item for trade" is highlighted on odds and itemList.PNG is present for evens. KeyIfInTrade( "Enter" )
        if ( Mod( A_Index, 2 ) != 0 and VerifyScreen( "TradeImages\addItem.PNG", 3000 ) )
        {
            KeyIfInTrade( "Enter" )
        }
        else if ( Mod( A_Index, 2 ) == 0 and VerifyScreen( "TradeImages\itemList.PNG", 3000 ) )
        {
            KeyIfInTrade( "Enter" )
        }
        
    }
    ; no currencies in inventory and no items left in "Add item for trade" menu
    if ( g_photonDrops == 0 and VerifyImageInPosition( tradeInventoryPosition, "TradeImages\addNoItem.PNG", 2000 ) )
    {
        KeyIfInTrade( "Esc" ) ; all items added, return to the purpose menu
    }
    ; when the script has pds check for them in position 1 of the "Add item for trade" menu
    else if ( g_photonDrops > 0 and VerifyImageInPosition( tradeInventoryPosition, "TradeImages\addPdPos1.PNG", 2000 )  )
    {
        KeyIfInTrade( "Esc" ) ; all items besides currencies added, return to the purpose menu
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
    message := "Trade me, my items cost " g_itemPrices[ 1 ] " pd each."
    Send {Space}%message%{Enter}

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
    instructions := "Tell me the index/s (1-" numOfItems ")"
    SayMsgInTrade( instructions )
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
    while ( IsInTrade() )
    {
        tradeTotal := GetTradeTotal( requestedItemIndexes )
        ; array of index numbers found in the current chat log
        requestedIndex := FindRequestedIndexes()

        ; trade has lasted longer than 5 minutes (300 = 5mins)
        if ( TradeTimer( g_timeItemsShown ) > 300 )
        {
            ; SHOULD CONSIDER ADDING A MESSAGE TO LET CUSTOMER KNOW TRADE IS BEING CANCELED

            ; NAVIGATE TO AND SELECT CANCEL TRADE
            EscAndCancelTrade()

            Continue ; Make it jump to the next while() check.  This will make sure it made it out of the trade menu.
        }

        ; if it's the initial item/s request
        if ( requestedItemIndexes.Length() == 0 and requestedIndex.Length() > 0 ) 
        {
            requestedItemIndexes := requestedIndex
            tradeTotal := GetTradeTotal( requestedItemIndexes )
            message := tradeTotal "pd, then confirm plz"
            SayMsgInTrade( message )
            ; Removes non requested items from the trade window
            RemoveExcessItems( requestedItemIndexes )
        }
        ; Give customer instructions every 5 loops, if nothing has been requested. 
        else if ( requestedItemIndexes.Length() == 0 and Mod( A_Index, 5) == 0 )
        {
            GiveInstructions()
        }
        ; should only go into this if statement after items have been requested and left/added to trade
        else if ( requestedItemIndexes.Length() > 0 and !VerifyScreen( "TradeImages\my1stConfirm.PNG", 1500 ) )
        {
            ; if script is in the purpose menu
            if ( VerifyScreen( "TradeImages\purposeMenu.png", 500 ) )
            {
                ; Should navigate to the first trade confirm and select it.
                InitialTradeConfirm()
            }
            ; double check that it's not in the purpose menu
            else if ( !VerifyScreen( "TradeImages\purposeMenu.png", 500 ) )
            {
                ; Send {Esc} until it's in the purpose menu
                KeyIfInTrade( "Esc" )
            }
        }
        ; if customer has confirmed the 1st time or final time and 1 or more items have been requested
        ;  ( only requested items should be in the trade window )
        else if ( requestedItemIndexes.Length() > 0 and  VerifyScreen( "TradeImages\customerConfirmed.PNG", 1500 ) or VerifyScreen( "TradeImages\customerFinalConfirmed.PNG", 1500 ) )
        {
            Sleep 3000 ; brief sleep to give customer chance to beat the script to final confirm.
            ; Check if customer has put the appropriate payment into the trade window
            if ( IsPaymentCorrect( tradeTotal ) )
            {
                ; Verify the customer has selected the final confirmed 
                if ( VerifyScreen( "TradeImages\customerFinalConfirmed.PNG", 1500 ) )
                {
                    ; Navigate to and select the final trade confirmation
                    FinalTradeConfirmation()
                    SelectFinalYes()
                }
                ; Customer still needs to do do the final/2nd confirmation
                else
                {
                    SayMsgInTrade( "Select final confirmation plz" )
                }
            }
            else if ( VerifyScreen( "TradeImages\customerFinalConfirmed.PNG", 1500 ) )
            {
                ; Should navigate to the first trade confirm and select it.  Allowing the customer to exit the trade or put the appropriate payment in the trade
                InitialTradeConfirm()
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
    if ( IsInTrade() )
    {
        if ( VerifyScreen( "TradeImages\cancelExchange.PNG", 700 ) ) ; if cancel exchange menu is on screen
        {
            if ( VerifyScreen( "TradeImages\yes.png", 700 ) ) ; if yes is highlighted
            {
                KeyIfInTrade( "Enter" )
            }
            else 
            {
                KeyIfInTrade( "Up" ) ; no should be highlighted, send up to highlight yes
                EscAndCancelTrade()
            }
        }
        else
        {
            KeyIfInTrade( "Esc" )
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
    nonRequestedItems := GetNonRequested( requestedItems )
    ; the "Cancel Candidate" menu retains the position in between cancels
    cancelPos := 1

    ; keep track of how many items have been removed from the trade
    removedCount := 0

    ; used to decide which images to match on screen, to verify the correct items are being removed
    itemsInTrade := g_inventory.Length()

    Loop % nonRequestedItems.Length() {
        if ( IsInTrade() )
        {
            ; highlights "Cancel Candidate"
            HoverCancelCandidate()

            ; selects "Cancel Candidate"
            KeyIfInTrade( "Enter" )

            if ( cancelPos == ( nonRequestedItems[ A_Index ] - removedCount ) )
            {
                ; Checks for the correct image and removes item if image found.  Otherwise chats and leaves trade
                RemoveItem( cancelPos, itemsInTrade )
            }
            else 
            {
                ; hover/highlight the next unwanted item
                Loop % ( ( nonRequestedItems[ A_Index ] - cancelPos ) - removedCount ) {
                    KeyIfInTrade( "Down" )
                    cancelPos++
                }
                ; Checks for the correct image and removes item if image found.  Otherwise chats and leaves trade
                RemoveItem( cancelPos, itemsInTrade )
            }
        }
        else
        {
            Break
        }
    removedCount++
    itemsInTrade--
    }
    ; selects "Cancel Candidate"
    KeyIfInTrade( "Enter" )

    ; IF I DON'T CHECK HERE the last item that's getting removed could possibly remain in the trade offer
    if ( IsInTrade() and IsFinalItemRemoved( cancelPos, itemsInTrade ) )
    {
        KeyIfInTrade( "Esc" ) ; leave the "Cancel candidate" menu, return to "Purpose" menu

        ; highlights "Cancel Candidate", will find "Purpose" menu and then hover "Cancel candidate" if it's not already
        HoverCancelCandidate()
    }
    else if ( IsInTrade() ) ; make sure it's still in trade to avoid giving double fail message ( when RemoveItem() fails an imageSearch too )
    {
        ; explain mistake and exit trade
        SayMsgInTrade( "Let's try again. Extra item left in trade" )
        EscAndCancelTrade()
    }
    
}


; Decides which image is needed to check in the ???cancel candidate menu???
GetSliderImage( currentPos, itemsInTrade )
{
    x := IsFirstOrLastTwo( currentPos, itemsInTrade )

    ; when there is less than 3 itemsInTrade the slider is no longer available, return alternate image
    if ( itemsInTrade <= 3 )
    {
        if ( currentPos == 3 )
        {
            return "TradeImages\CancelVerifyImages\leftSide3rd.PNG"
        }
        else
        {
            return "TradeImages\CancelVerifyImages\leftSide" currentPos ".PNG"
        }   
    }
    ; first two and last two share the same slider image when there is 4 or more itemsInTrade
    else if ( x )
    {
        return "TradeImages\CancelVerifyImages\" x "of" itemsInTrade ".PNG"
    }
    else
    {
        return "TradeImages\CancelVerifyImages\" currentPos "of" itemsInTrade ".PNG"
    }
}


; Returns leftBarPosition or sliderPosition
GetPosition( itemsInTrade )
{

    if ( itemsInTrade <= 3 )
    {
        return g_leftBarPosition
    }
    else
    {
        return g_sliderPosition
    }
}


; True/False if it's in the position it should be after removing the final item from the trade offer
IsFinalItemRemoved( cancelPos, itemsInTrade )
{
    if ( cancelPos > itemsInTrade ) ; then picture will be itemsInTrade of itemsInTrade ??? cancelPos := itemsInTrade then proceed as any other ???
    {
        cancelPos := itemsInTrade
    }

    position := GetPosition( itemsInTrade )
    sliderImage := GetSliderImage( cancelPos, itemsInTrade )

    ; greatest from requestedItemIndexes should be highlighted
    if ( VerifyImageInPosition( position, sliderImage, 3000 ) )
    {
        ; the first two and last two slider images are the same when itemsInTrade is 4 or more, check for additional image
        if ( IsFirstOrLastTwo( position, itemsInTrade ) )
        {
            leftImage := GetSharedImage( cancelPos, itemsInTrade )
            if ( VerifyImageInPosition( g_leftBarPosition, leftImage, 3000 ) )
            {
                ; according to image checks screen matches itemsInTrade and cancelPos
                return True
            }
        }
        else if ( itemsInTrade > 3 ) ; no additional imageSearches needed
        {
            ; according to image checks screen matches itemsInTrade and cancelPos
            return True
        }
        ; 3 or less in itemsInTrade, also check that the slider is not present
        else if ( VerifyImageInPosition( g_sliderPosition, "TradeImages\CancelVerifyImages\noSlider.PNG", 1000 ) )
        {
            ; according to image checks screen matches itemsInTrade and cancelPos
            return True
        }
    }
    else
    {
        return False
    }
    
}


; Removes individual item from the trade window
RemoveItem( cancelPos, itemsInTrade )
{
    position := GetPosition( itemsInTrade )
    ;MessageArray(position)
    sliderImage := GetSliderImage( cancelPos, itemsInTrade )

    ; item to remove is highlighted
    if ( VerifyImageInPosition( position, sliderImage, 3000 ) )
    {
        ; the first two and last two slider images are the same when itemsInTrade is 4 or more, check for additional image
        if ( IsFirstOrLastTwo( cancelPos, itemsInTrade ) )
        {
            leftImage := GetSharedImage( cancelPos, itemsInTrade )
            if ( VerifyImageInPosition( g_leftBarPosition, leftImage, 3000 ) )
            {
                ; removes unwanted item from trade menu
                KeyIfInTrade( "Enter" )
            }
            else
            {
                MsgBox, %leftImage%
            }
        }
        else if ( itemsInTrade > 3 )
        {
            ; removes unwanted item from trade menu
            KeyIfInTrade( "Enter" )
        }
        ; 3 or less in itemsInTrade, also check that the slider is not present ( leftSide.PNG should have been checked already )
        else if ( VerifyImageInPosition( g_sliderPosition, "TradeImages\CancelVerifyImages\noSlider.PNG", 3000 ) )
        {
            ; removes unwanted item from trade menu
            KeyIfInTrade( "Enter" )
        }
    }
    else
    {
        MsgBox, %sliderImage%
        ; explain mistake and exit trade
        SayMsgInTrade( "Let's try again. Wrong items left in trade" )
        EscAndCancelTrade()
    }
    Sleep 500
}


; Used to decide the image needed for when there is 4+ itemsInTrade and its the first two or last two
GetSharedImage( position, itemsInTrade )
{
    if ( position <= 2 )
    {
        return "TradeImages\CancelVerifyImages\leftSide" position ".PNG"
    }
    else if ( position >= itemsInTrade ) 
    {
        return "TradeImages\CancelVerifyImages\leftSide4.PNG"
    }
    else
    {
        return "TradeImages\CancelVerifyImages\leftSide3.PNG"
    }
}

; Returns 1/itemsInTrade if it is the first two or last two of the items in trade and there is 4+ itemsInTrade ( each pair uses the same slider image )
IsFirstOrLastTwo( position, itemsInTrade )
{
    if ( itemsInTrade < 4 )
    {
        return 0
    }
    ; in position 1 or 2 and the slider is present
    else if ( position <= 2 )
    {
        return 1
    }
    ; in the 2nd to last or last position and the slider is present
    else if ( position >= ( itemsInTrade - 1 ) )
    {
        return itemsInTrade
    }

}


; hover/highlight "Cancel Candidate"
HoverCancelCandidate()
{
    if ( IsInTrade() )
    {
        currentPos := FindPurposePos()
        if ( currentPos == 2 )
        {
            ; do nothing/exit function
        }
        else if ( currentPos == 1 )
        {
            KeyIfInTrade( "Down" )
            HoverCancelCandidate()
        }
        else if ( currentPos > 2 )
        {
            Loop % currentPos - 2 {
                KeyIfInTrade( "Up" )
            }
            HoverCancelCandidate()
        }
        else
        {
            HoverCancelCandidate() ; recursively call itself, currentPos undefined?
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
    if ( IsInTrade() )
    {
        currentPos := FindPurposePos()
        ; if confirmed is highlighted 
        if ( currentPos == 4 )
        {
            KeyIfInTrade( "Enter" )
        }
        else if ( currentPos == 5 )
        {
            KeyIfInTrade( "Up" )
            InitialTradeConfirm()
        }
        else if ( currentPos <= 3 )
        {
            Loop % ( 4 - currentPos ) {
                KeyIfInTrade( "Down" ) ; Down can talk to npc's and shops
            }
            InitialTradeConfirm()
        }
        else
        {
            InitialTradeConfirm() ; recursively call itself, currentPos undefined?
        }
    }
}


; Finds current position of the "Purpose" menu returns 1 - 5
FindPurposePos()
{
    searchTime := 500

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
        if ( IsInTrade() )
        {
            KeyIfInTrade( "Esc" ) ; should eventually find it's self in the "Purpose" menu
        }
        else
        {
            EscAndCancelTrade()
            return
        }
        
        ; if it didn't match any of those images
        FindPurposePos()
    }
}


; Selects the final yes after the final confirmation was selected
SelectFinalYes()
{
    if ( IsInTrade() )
    {
        if ( VerifyScreen( "TradeImages\bothConfirmed.png", 1000 ) )
        {
            KeyIfInTrade( "Up" ) ; pressing up in this menu will not reset to the bottom selection. 
            if ( VerifyScreen( "TradeImages\yes.png", 1000 ) )
            {
                KeyIfInTrade( "Enter" )
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
    if ( IsInTrade() )
    {
        currentPos := FindConfirmedPos()
        ; if Final Confirmation is highlighted 
        if ( currentPos == 3 )
        {
            KeyIfInTrade( "Enter" )
        }
        else if ( currentPos == 4 )
        {
            KeyIfInTrade( "Up" )
            FinalTradeConfirmation()
        }
        else 
        {
            Loop % ( 3 - currentPos ) {
                KeyIfInTrade( "Down" )
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
    ; if it's a floating point, round up
    if totalCost is Float
        totalCost := Ceil( totalCost )

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
        ImageSearch, , , x1, y1, x2, y2, *25 %filePath%
        if (ErrorLevel = 2)
            MsgBox Could not conduct the search for %filePath%
        else if (ErrorLevel = 1)
        {
            imageFound := False
            /*
            if ( InStr( filepath, "TradeImages\CancelVerifyImages\" ) )
            {
                MsgBox failed to find on the screen %filePath%
            }
            */
        }
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
KeyIfInTrade( toInput )
{
    if ( IsInTrade() )
    {
        Send {%toInput%}
    }
}


; Send {Space} while in trade menu and chatStart.PNG and greenChat.PNG are not on screen
StartChatInTrade()
{
    while ( IsInTrade() )
    {
        ; do not need to check for cancelled.PNG as that is only available when redMenu.PNG is not
        if ( VerifyImageInPosition( g_chatPosition, "TradeImages\chatStart.PNG", 2000 ) or VerifyImageInPosition( g_chatPosition, "TradeImages\greenChat.PNG", 1000 ) ) 
        {
            ; Exit out of the loop, the chat is seen as started.
            Break
        }
        else
        {
            KeyIfInTrade( "Space" )
            Sleep 700
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
            KeyIfInTrade( "Enter" )
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
            KeyIfInTrade( "Esc" )
        }
    }
    ; still in trade
    else if ( IsInTrade() )
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
    splitMsg := StrSplit( msg, " " )
    Loop % splitMsg.Length() {
        if ( IsInTrade() )
        {
            if ( A_Index > 1 )
            {
                KeyIfInTrade( "Space" )
            }            
            splitWord := StrSplit( splitMsg[ A_Index ] )
            Loop % splitWord.Length() {
                if ( IsInTrade() )
                {
                    KeyIfInTrade( splitWord[ A_Index ] )
                }
                else
                {
                    Break
                }
            }
        }
        else
        {
            Break
        }
    }
    
    SendChatInTrade()
}


; Returns true if in a trade
IsInTrade()
{
    return % VerifyImageInPosition( g_emptyMenuPosition, "TradeImages\redMenu.PNG", 3000 )
}