FileName := A_Temp "\Files Moved.txt"
FileDelete %FileName%

EnvGet, ODHome, OneDriveConsumer
NeedSize := ODHome "\Wallpapers\1\Need Size"
Landscape := ODHome "\Wallpapers\Landscape"
Portrait := ODHome "\Wallpapers"

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
Gui, -DPIScale -Caption
Gui, Margin, 0, 0
Gui, Add, Picture,h%picH% w%picW%, %pic%
Gui, Show,, %A_ScriptName%

Loop %NeedSize%\*.*, F
	Num := A_Index

WinGetPos,,, pWidth,, %A_ScriptName% ahk_exe AutoHotkey.exe
Gui add, progress, xCenter yCenter w%pWidth% h20 Range0-%Num%
Gui Show,, Progress

; adding WxH to the file name and moving to appropriate folder
SetWorkingDir, %NeedSize%
Loop Files, %NeedSize%\*.*, F
{
	SplitPath, A_LoopFileFullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	Endpos := InStr(OutNameNoExt, "_",, -1) + 1
    dimensions := SubStr(OutNameNoExt, Endpos)
    RegExMatch(dimensions, "\d+x\d+", result) ; an "x" with 1 or more numbers before AND after
    If !(result) ; meaning the dimensions were not found at the end of the file name
    {
        pToken := Gdip_StartUp()
		pBitmap := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
		Gdip_GetImageDimensions(pBitmap, w, h)
		Gdip_DisposeImage(pBitmap)
		Gdip_ShutDown(pToken)
		NewName := OutNameNoExt w "x" h "." OutExtension

		If (h >= w)
		{
			If !FileExist(Portrait "\" NewName)
			{
				FileMove %A_LoopFileFullPath%, %Portrait%\%NewName%
				PortraitsMoved := PortraitsMoved . NewName . "`n"
			}
			Else
				PortraitsNotMoved := PortraitsNotMoved . NewName . "`n"
		}
        Else
        {
            If !FileExist(Landscape "\" NewName)
            {
                FileMove %A_LoopFileFullPath%, %Landscape%\%NewName%
                LandscapeMoved := LandscapeMoved . NewName . "`n"
            }
            Else
                LandscapeNotMoved := LandscapeNotMoved . NewName . "`n"
        }
        GuiControl,, msctls_progress321, +1
        Sleep, 50
    }
    else
    {
        GuiControl,, msctls_progress321, +1
        Continue
    }
}

FileAppend,
(
Portrait items moved:

%PortraitsMoved%


Portraits not moved:

%PortraitsNotMoved%


Landscape items moved:

%LandscapeMoved%


Landscape not moved:

%LandscapeNotMoved%
), %FileName%
Run notepad.exe "%FileName%"
ExitApp
