:: Updates the icon data for WoW Classic Era. Writes to ..\ClickedMedia\MediaClassic.lua.
:: In order to update the icon data, download the latest "Community CSV for wow_classic_era X.X.X.X (ClassicRetail)" listfile
:: from https://wow.tools/files and place it inside of this folder.
:: Rename it to "listfile-classic.csv" and run this batch script.

@echo off
py .\update-icon-db.py --listfile ".\listfile-classic.csv" --output "..\ClickedMedia\MediaClassic.lua" --namespace "ClickedMedia" --function "GetClassicIcons"
pause
