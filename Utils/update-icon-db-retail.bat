:: Updates the icon data for WoW retail. Writes to ..\ClickedMedia\MediaRetail.lua.
:: In order to update the icon data, download the latest "Community CSV for wow X.X.X.X (Retail)" listfile
:: from https://wow.tools/files and place it inside of this folder.
:: Rename it to "listfile-retail.csv" and run this batch script.

@echo off
py .\update-icon-db.py --listfile ".\listfile-retail.csv" --output "..\ClickedMedia\MediaRetail.lua" --blacklist ".\icon-blacklist-retail.txt" --namespace "ClickedMedia" --function "GetRetailIcons"
pause
