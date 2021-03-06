;*********************************************************************************
;                               THREADS
;*********************************************************************************

; TODO: place in a shared library
;returns first thread for the <processID>
;sets optional <List> to pipe | separated thread list for the <processID>
Threads_GetProcessThreadOrList( processID, byRef list="" )
{
   ;THREADENTRY32 {
   THREADENTRY32_dwSize=0 ; DWORD
   THREADENTRY32_cntUsage = 4   ;DWORD
   THREADENTRY32_th32ThreadID = 8   ;DWORD
   THREADENTRY32_th32OwnerProcessID = 12   ;DWORD
   THREADENTRY32_tpBasePri = 16   ;LONG
   THREADENTRY32_tpDeltaPri = 20   ;LONG
   THREADENTRY32_dwFlags = 24   ;DWORD
   THREADENTRY32_SIZEOF = 28

   TH32CS_SNAPTHREAD=4

   hProcessSnap := DllCall("CreateToolhelp32Snapshot","uint",TH32CS_SNAPTHREAD, "uint",0)
   ifEqual,hProcessSnap,-1, return

   VarSetCapacity( thE, THREADENTRY32_SIZEOF, 0 )
   NumPut( THREADENTRY32_SIZEOF, thE )

   ret=-1

   if( DllCall("Thread32First","uint",hProcessSnap, "uint",&thE ))
      loop
      {
         if( NumGet( thE ) >= THREADENTRY32_th32OwnerProcessID + 4)
            if( NumGet( thE, THREADENTRY32_th32OwnerProcessID ) = processID )
            {   th := NumGet( thE, THREADENTRY32_th32ThreadID )
               IfEqual,ret,-1
                  ret:=th
               list .=  th "|"
            }
         NumPut( THREADENTRY32_SIZEOF, thE )
         if( DllCall("Thread32Next","uint",hProcessSnap, "uint",&thE )=0)
            break
      }

   DllCall("CloseHandle","uint",hProcessSnap)
   StringTrimRight,list,list,1
   return ret
}

; TODO: place in a shared library
; Returns thread owning specified window handle
; default = Active window
Threads_GetThreadOfWindow( hWnd=0 )
{
   IfEqual,hWnd,0
      hWnd:=WinExist("A")
   DllCall("GetWindowThreadProcessId", "uint",hWnd, "uintp",id)
   Threads_GetProcessThreadOrList(  id, threads )
   IfEqual,threads,
      return 0
   CB:=RegisterCallback("Threads_GetThreadOfWindowCallBack","Fast")
   lRet=0
   lParam:=hWnd
   loop,parse,threads,|
   {   NumPut( hWnd, lParam )
      DllCall("EnumThreadWindows", "uint",A_LoopField, "uint",CB, "uint",&lParam)
      if( NumGet( lParam )=true )
      {   lRet:=A_LoopField
         break
      }
   }
   DllCall("GlobalFree", "uint", CB)
   return lRet
}

Threads_GetThreadOfWindowCallBack( hWnd, lParam )
{
   IfNotEqual,hWnd,% NumGet( 0+lParam )
      return true
   NumPut( true, 0+lParam )
   return 0
}