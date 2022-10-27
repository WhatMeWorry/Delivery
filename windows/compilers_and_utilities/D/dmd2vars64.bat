@echo.
@echo Setting up 64-bit environment for using DMD 2 from %~dp0dmd2\windows\bin.
@echo.
@echo dmd must still be called with -m64 in order to generate 64-bit code.
@echo This command prompt adds the path of extra 64-bit DLLs so generated programs
@echo which use the extra DLLs (notably libcurl) can be executed.
@set PATH=%~dp0dmd2\windows\bin;%PATH%
@set PATH=%~dp0dmd2\windows\bin64;%PATH%
