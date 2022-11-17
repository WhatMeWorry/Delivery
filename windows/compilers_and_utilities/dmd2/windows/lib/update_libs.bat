if -%1-==-- echo Missing Windows SDK folder argument & exit /b

:: CTL3D32 is missing in Windows SDK
:: Uuid is a static library in Windows SDK
for %%l in (COMCTL32.LIB CTL3D32.LIB ODBC32.LIB OLEAUT32.LIB WS2_32.LIB advapi32.lib comdlg32.lib gdi32.lib glu32.lib kernel32.lib ole32.lib opengl32.lib rpcrt4.lib shell32.lib user32.lib uuid.lib version.lib wininet.lib winmm.lib winspool.lib wsock32.lib) do coffimplib %1\%%l %%l
