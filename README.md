# KiwiItemInfo
WoW Classic Addon, Shows iLvl (with colors), Vendor Prices (unit/stack), highlights all grey named items for vendor selling with LCTRL, and provides a item database to search items in-client

Provides a command /kiwiii (kiwi item info) to search items by name or by id. It has an argument to show you items based on level. Please use `/kiwiii --help` for more information for parameters to reduce results. There are like 17,121 btw.

To install:  

0. Download `https://github.com/tilkinsc/KiwiItemInfo/archive/master.zip` and skip step 1 or do step 1 instead
1. Navigate to your WoW Classic addons folder. `S:\WoW\World of Warcraft\_classic_\Interface\AddOns`
2. `git clone https://github.com/tilkinsc/KiwiItemInfo`

You should be all set up.

Edit KiwiItemInfo.lua if you need to change the `LCTRL` keybinding for revealing grey-named items or adjust level range for iLvl colors. Or you could also edit the range, but tbh it works pretty well. Perhaps you want to add another level above red as purple. It's easy and legible.

iLvl coloration works like this:
- iLvl is your level or higher? Red
- iLvl is 1-3 levels under you? Yellow
- iLvl is 4-6 levels under you? Green
- iLvl is 7-9+ levels under you? Grey

![image](https://user-images.githubusercontent.com/7494772/65168133-e4d56400-da11-11e9-9a56-57daaaf7eb51.png)
(Kiwi was level 39 for this picture)

![image](https://user-images.githubusercontent.com/7494772/65673394-be6a8680-e018-11e9-8852-fd889d9bcf4b.png)

![image](https://user-images.githubusercontent.com/7494772/65168180-f9b1f780-da11-11e9-8b1a-b6efece584c5.png)

![image](https://user-images.githubusercontent.com/7494772/65168217-0b939a80-da12-11e9-9203-6dced0cca7d3.png)

![image](https://user-images.githubusercontent.com/7494772/65168271-282fd280-da12-11e9-8fff-30dbffeded71.png)


