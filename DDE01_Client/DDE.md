1. Prerequisite: Use the Windows API
   - Ensure your target Operating System is Windows, as DDE is a legacy Windows-specific messaging protocol .
   - Make sure your uses clause includes the standard Windows units: Windows and Messages

2. Initialize the DDE InstanceYou must initialize the Dynamic Data Exchange Management Library (DDEML) using DdeInitialize

var
  idInst: DWORD = 0;
begin
  DdeInitialize(@idInst, @DdeCallback, APPCMD_CLIENTONLY, 0);
end;

///////////////////////////////////////////////////////////////////////////
DdeInitialize(&idInst, (PFNCALLBACK)MakeProcInstance((FARPROC)DdeCallback, hInstance),
            CBF_FAIL_EXECUTES | CBF_SKIP_ALLNOTIFICATIONS, 0L);
    hszTime = DdeCreateStringHandle(idInst, "Time", 0);
    hszNow = DdeCreateStringHandle(idInst, "Now", 0);
    hszClock = DdeCreateStringHandle(idInst, "Clock", 0);
    DdeNameService(idInst, hszClock, 0L, DNS_REGISTER);



    while (GetMessage((LPMSG)&msg, NULL, 0, 0) ) {
        TranslateMessage((LPMSG)&msg);
        DispatchMessage((LPMSG)&msg);
    }

    DdeUninitialize(idInst);
///////////////////////////////////////////////////////////////////////

Note: DdeCallback is a callback function you must define to handle DDE transactions (e.g., disconnection or data arrival).

3. Connect to the Smart DDE Server
Establish a connection using DdeConnect .
You will need to provide the specific DDE Server name (provided by Brooks Instrument) and the Topic Name
var
  hszService, hszTopic: HSZ;
  hConv: HCONV;
begin
  hszService := DdeCreateStringHandle(idInst, 'SmartDDE', CP_WINANSI);
  hszTopic := DdeCreateStringHandle(idInst, 'TopicName', CP_WINANSI);
  hConv := DdeConnect(idInst, hszService, hszTopic, nil);
end;

4. Request or Send Data
Use DdeClientTransaction to request data from the flow meters or send control commands.
Reading Data: Use XTYP_REQUEST.
Writing Data: Use XTYP_POKE


if (usType == XTYP_REQUEST || usType == XTYP_ADVREQ) {

                itoa(oTime.hour, sz, 10);
                strcat(sz, ":");
                itoa(oTime.minute, &sz[strlen(sz)], 10);
                strcat(sz, ":");
                itoa(oTime.second, &sz[strlen(sz)], 10);
                return(DdeCreateDataHandle(idInst, (LPBYTE)sz, strlen(sz) + 1, 0L,
                        hszNow, CF_TEXT, 0));
            }
            if (usType == XTYP_POKE) {
                SYSTEMTIME SysTime;

                DdeGetData(hData, (LPBYTE)sz, 40L, 0L);
                GetLocalTime(&SysTime);
                sscanf(sz, "%2d:%2d:%2d", &SysTime.wHour, &SysTime.wMinute, &SysTime.wSecond);

                /* enable system-time privilege, set time, disable privilege */
                OpenProcessToken( GetCurrentProcess(),
                  TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken ) ;
                LookupPrivilegeValue( NULL, "SeSystemTimePrivilege", &luid );
                tp.PrivilegeCount           = 1;
                tp.Privileges[0].Luid       = luid;
                tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
                AdjustTokenPrivileges( hToken, FALSE, &tp,
                  sizeof(TOKEN_PRIVILEGES), NULL, NULL );
                SetLocalTime(&SysTime);
                AdjustTokenPrivileges( hToken, TRUE, &tp,
                  sizeof(TOKEN_PRIVILEGES), NULL, NULL );

                DdePostAdvise(idInst, hszTime, hszNow);
                return((HDDEDATA)DDE_FACK);
            }


