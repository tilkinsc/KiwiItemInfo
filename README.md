# KiwiItemInfo
WoW Classic Addon, Shows iLvl (with colors), Vendor Price (unit/stack), and highlights all grey named items for vendor selling with LCTRL

Provides a command /kii to search items by name or by id. It has an argument to show you items based on level.

To install:
1. Navigate to your WoW Classic addons folder. `S:\WoW\World of Warcraft\_classic_\Interface\AddOns`
2. `git clone https://github.com/tilkinsc/KiwiItemInfo`

You should be all set up.

Edit KiwiItemInfo.lua if you need to change the `LCTRL` keybinding for revealing grey-named items or adjust level range for iLvl colors.

iLvl coloration works like this:
- iLvl is your level or higher? Red
- iLvl is 1-3 levels under you? Yellow
- iLvl is 4-6 levels under you? Green
- iLvl is 7-9+ levels under you? Grey

![image](https://user-images.githubusercontent.com/7494772/65168133-e4d56400-da11-11e9-9a56-57daaaf7eb51.png)
(Kiwi was level 39 for this picture)

![image](https://user-images.githubusercontent.com/7494772/65168180-f9b1f780-da11-11e9-8b1a-b6efece584c5.png)

![image](https://user-images.githubusercontent.com/7494772/65168217-0b939a80-da12-11e9-9203-6dced0cca7d3.png)

![image](https://user-images.githubusercontent.com/7494772/65168271-282fd280-da12-11e9-8fff-30dbffeded71.png)
