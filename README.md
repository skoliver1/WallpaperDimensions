# WallpaperDimensions

Takes image files from source location, appends it's WxH dimensions to the file name
and moves it to either a portrait or landscape folder.

Gdip cannot correctly process .WEBP files, so they are moved if they have dimensions added.  Otherwise
they are left in source folder.

Version notes:
1.1
- Runs faster due to reduced sleep and #NoEnv
- Now moves .WEBP files to appropriate destination folder if WxH is in file name
- Fixes .JPEG to .JPG
- Appends "_" to filename (before WxH) if I didn't have it
- Changed outfile formatting

1.0
- initial script