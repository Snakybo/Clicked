:: Updates the icon data for WoW Classic. Writes to ..\ClickedMedia\MediaBurningCrusade.lua.
:: In order to update the icon data, download the latest "Community CSV for wow_classic X.X.X.X (ClassicRetail)" listfile
:: from https://wow.tools/files and place it inside of this folder.
:: Rename it to "listfile-bc.csv" and run this batch script.

@echo off
py .\update-icon-db.py --listfile ".\listfile-bc.csv" --output "..\ClickedMedia\MediaBurningCrusade.lua" --namespace "ClickedMedia" --function "GetBurningCrusadeIcons"
pause
