echo %0 %*
powershell.exe .\download-teddy.ps1
.\InfiniTAM.exe Teddy/calib.txt "Teddy/Frames/%%04i.ppm" "Teddy/Frames/%%04i.pgm"
