FileName = C:\Temp\Files Moved.txt
RegRead ODHome, HKCU, Software\Microsoft\OneDrive\Accounts\Personal, UserFolder
Landscape = %ODHome%\Wallpapers\Landscape\
FileDelete %fileName%

pic := GetWallpaper()
pToken := Gdip_StartUp()
pBitmap := Gdip_CreateBitmapFromFile(pic)
Gdip_GetImageDimensions(pBitmap, w, h)
Gdip_DisposeImage(pBitmap)
Gdip_ShutDown(pToken)

height := a_screenheight - 60
ratio := w / h
width := height * ratio
if (width > A_ScreenWidth)
{
	picH := "-1"
	picW := A_ScreenWidth
}
Else
{
	picH := height
	picW := "-1"
}
Gui -DPIScale -Caption
Gui, Margin, 0, 0
Gui, Add, Picture,h%picH% w%picW%, %pic%
Gui Show,, %A_ScriptName%

Loop %ODHome%\Wallpapers\1\Need Size\*.*, F
	Num := A_Index

WinGetPos,,, pWidth,, %A_ScriptName% ahk_exe AutoHotkey.exe
Gui add, progress, xCenter yCenter w%pWidth% h20 Range0-%Num%
Gui Show,, Progress

Loop Files, %ODHome%\Wallpapers\1\Need Size\*.*, F
{
	pToken := Gdip_StartUp()
	pBitmap := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
	Gdip_GetImageDimensions(pBitmap, w, h)
	Gdip_DisposeImage(pBitmap)
	Gdip_ShutDown(pToken)
	
	if (w > h)
	{
		If !FileExist(ODHome "\Wallpapers\Landscape\" A_LoopFileName)
		{
			FileMove %A_LoopFileFullPath%, %Landscape%
			Moved := Moved . A_LoopFileName . "`r`n"
			;file.Write(line)
		}
		else NotMoved := NotMoved . A_LoopFileName . "`r`n"
	}
	else
	{
		If !FileExist(ODHome "\Wallpapers\" A_LoopFileName)
		{
			FileMove %A_LoopFileFullPath%, %Landscape%
			Tall := Tall . A_LoopFileName . "`r`n"
		}
		else
			Tallnotmoved := Tallnotmoved . A_LoopFileName . "`r`n"
	}
	GuiControl,, msctls_progress321, +1
	;Progress %A_Index%
}
;file.Close()

FileAppend Landscape items moved:`n`n%Moved%`n`n`n`nItems that are wide but not moved:`n`n%NotMoved%`n`n`n`nPortrait items moved:`n`n%Tall%`n`n`n`nPortraits not moved:`n`n%Tallnotmoved%, %FileName%
Run notepad.exe "%FileName%"
ExitApp