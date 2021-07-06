# Installation / Setup

### I made a new install of PSO, it's not required but recommended so you can keep settings seperate.

### You will need to install [Bloody HUD](http://universps.online.fr/pso/bb/skin/telechargement.php5?l=343&t=d)
- extract and drop the file in the data folder of PSO
	
### When running Pso and this script you will need to launch pso with 640x480 resolution

### Download/Install the current version of [AHK](https://www.autohotkey.com/)
- my PSO installs still require me to run as admin, as such I've always ran my AHK scripts with ui access or admin mode
	- ui access option needs to be enabled from more options while installing AHK
		
### Unzip PsoTradeScript, open PsoTrade.ahk in you preferred text editor (.ahk extension may or may not be visible on your machine)
- line 138 should have something like, global g_psoDirectory := "C:\YourPsoFilePathHere"
	- change "C:\YourPsoFilePathHere" to your actual Pso filepath ( make sure it's still wrapped in "" )
- line 145 g_itemPrices.Push( 1 ) change the 1 to whatever price you want for each item
	
### Now it's time to set up your inventory to sell!
- if you DO NOT have the [item reader add on](https://github.com/Solybum/PSOBBMod-Addons) installed, do so now.
### The current inventory requirements are:
- end the inventory with photon drop/s or a full inventory of 30
- can not contain any other stackable items ( items that are saved with xAmount via item reader )
- the class of character hosting the shop MUST BE ABLE to equip/use the items it's selling ( will run into issues if their is an X next to it in inventory/trade window )
### Save your current inventory with the add on following the above requirements. DO NOT RENAME THE FILE	
	
### Run PsoTrade.ahk ( run with ui access/admin privs if pso requires them ) your saved inventory should be displayed.
- If you receive the two warning messages below, then your filepath is incorrect or you have NOT saved an inventory.txt via item reader add on.
	- Warning: This variable has not been assigned a value.
	- Specifically: newestInventory (a local variable)
		
### I recommend doing a test run by making an alternate account or having a friend trade you with the auto trading started ( Control + J )
- If it fails, you can do some quick image searching testing to help ensure it's doing as it should.
	- I have NOT fully tested all images and how well they match may differ based upon your gpu/gpu's video settings for PSO ( monitor color bits may effect it as well )
	- Make an alternate account or get a friend to trade you.
	- With the script running and in a trade hover over "Confirmed"
		- then press Control + T , if it matched you hovering Confirmed, it should have displayed a message saying 1.
		- Now highlight the other options on the purpose menu one by one and press Control + T , wait for a moment.  Should all display a message saying 0.
			- if any of them return 1, the script is untrustable with it's current settings and or your gpu's settings for PSO
	- If testing went well it is not guaranteed that all images will match.  However if it completes one trade it should have a high chance of compatibility with the images.


# Hotkeys

### Control + J to start the auto trading.

### Control + P = pause

### Control + R = reload

### Control + Q = show inventory

### Should also have an icon on taskbar.
