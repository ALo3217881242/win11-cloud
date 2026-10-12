@echo off
rem win11-cloud: tinh chinh Windows cho muot khi dung Remote Desktop.
rem File nay tu chay 1 lan o buoc cuoi cua qua trinh cai dat tu dong.

rem Mui gio Viet Nam (UTC+7)
tzutil /s "SE Asia Standard Time"

rem Nguon dien: hieu nang cao, khong ngu, khong tat man hinh
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /hibernate off

rem Bat Remote Desktop va cho phep RDP toi da 60 FPS (mac dinh 30 FPS)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations" /v DWMFRAMEINTERVAL /t REG_DWORD /d 15 /f

rem Hieu ung giao dien: uu tien hieu nang
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f

rem Tat dich vu chay nen ton CPU/disk (bo qua neu tiny11 da go san)
sc config SysMain start= disabled
sc config WSearch start= disabled

exit /b 0
