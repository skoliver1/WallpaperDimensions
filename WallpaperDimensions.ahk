; 1.1
#NoEnv

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

Loop, Files, %NeedSize%\*.*, F
	Num := A_Index

WinGetPos,,, pWidth,, %A_ScriptName% ahk_exe AutoHotkey.exe
Gui add, progress, xCenter yCenter w%pWidth% h20 Range0-%Num%
Gui Show,, Progress

; adding WxH to the file name and moving to appropriate folder
SetWorkingDir, %NeedSize%
Loop, Files, %NeedSize%\*.*, F
{
    SplitPath, A_LoopFileFullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

    RegExMatch( OutNameNoExt, "\d+x\d+$", HasDimensions ) ; an "x" with 1 or more numbers before AND after

    If (A_LoopFileExt = "webp") { ; .webp files are not correctly processed by Gdip and must be done manually
        If ( HasDimensions ) {
            RegExMatch(HasDimensions, "^\d*", w)
            RegExMatch(HasDimensions, "\d*$", h)
        } else {
            NotMoved := NotMoved . OutFileName . "`n"
            GuiControl,, msctls_progress321, +1
            Continue
        }
    } else {
        pToken := Gdip_StartUp()
		pBitmap := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
		Gdip_GetImageDimensions(pBitmap, w, h)
		Gdip_DisposeImage(pBitmap)
		Gdip_ShutDown(pToken)
    }

    If ( OutExtension = "jpeg" ) {
        OutExtension := "jpg"
    }

    OutNameNoExt := RegExReplace(OutNameNoExt, "\d+x\d+$", "")

    if ( !RegExMatch(OutNameNoExt, "_$") ) { ; add "_" to end of name, in case I didn't already
        OutNameNoExt := OutNameNoExt "_"
    }
        Dimensions := w "x" h
		NewName := OutNameNoExt Dimensions "." OutExtension

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
        Sleep, 10
}

FileAppend,
(
NOT MOVED:
%NotMoved%

PORTRAITS MOVED:
%PortraitsMoved%

PORTRAITS NOT MOVED:
%PortraitsNotMoved%

LANDSCAPE MOVED:
%LandscapeMoved%

LANDSCAPE NOT MOVED:
%LandscapeNotMoved%
), %FileName%
Run notepad.exe "%FileName%"
ExitApp
