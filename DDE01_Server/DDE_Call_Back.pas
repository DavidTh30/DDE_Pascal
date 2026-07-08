unit DDE_Call_Back;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Windows, Messages, dbugintf, StrUtils;

function AnsiArrayToHex(const Arr: array of AnsiChar): string;
function TextToHex(const InputStr: string): string;
procedure TranslateError();
procedure log(LINENUM_: integer; message_: string);
function DdeCallback(uType, uFmt: UINT; hConv: HCONV; hsz1, hsz2: HSZ;
  hData: HDDEDATA; dwData1, dwData2: DWORD): HDDEDATA; stdcall;

const
  APPCMD_FILTERINITS = $00000020;
  APPCMD_CLIENTONLY = $00000010;
  CBF_FAIL_ALLSVRXACTIONS =$0003f000;
  DMLERR_NO_ERROR = $0;
  MF_CALLBACKS = $8000000;
  MF_CONV = $40000000;
  MF_ERRORS = $10000000;
  MF_HSZ_INFO = $1000000;
  MF_LINKS = $20000000;
  MF_POSTMSGS = $4000000;
  MF_SENDMSGS = $2000000;
  XTYP_MASK = $F0;
  XTYP_MONITOR = (XCLASS_NOTIFICATION Or $F0 Or XTYPF_NOBLOCK);
  XTYP_SHIFT = 4;  //  shift to turn XTYP_ into an index

var
  uFmt_uType_message:boolean;
  XTYP_MONITOR_message:boolean;
  DDE_data: ^TLabel;
  Server_data:^TEdit;
  bRunning : Boolean;         // Server running flag.
  g_hszAppName, g_hszTopicName, g_hszItemName, g_hszItemAdvise, g_hszValue: HSZ;
  InstId: DWORD;
  DdeInitializeResultCode: UINT;
  hConv_: HCONV;
  hDdeServiceName: HDDEDATA;
  txtService_:string;
  txtTopic_:string;
  txtItem_:string;
  txtAdvise_:string;

implementation
procedure TranslateError();
var
  lRet : Long;
begin
    lRet := DdeGetLastError(InstId);

    Case lRet of
      DMLERR_NO_ERROR : SendDebug('DMLERR_NO_ERROR');
      DMLERR_ADVACKTIMEOUT : SendDebug('DMLERR_ADVACKTIMEOUT');
      DMLERR_BUSY : SendDebug('DMLERR_BUSY');
      DMLERR_DATAACKTIMEOUT : SendDebug('DMLERR_DATAACKTIMEOUT');
      DMLERR_DLL_NOT_INITIALIZED : SendDebug('DMLERR_NOT_INITIALIZED');
      DMLERR_DLL_USAGE : SendDebug('DMLERR_USAGE');
      DMLERR_EXECACKTIMEOUT : SendDebug('DMLERR_EXECACKTIMEOUT');
      DMLERR_INVALIDPARAMETER : SendDebug('DMLERR_INVALIDPARAMETER');
      DMLERR_LOW_MEMORY : SendDebug('DMLERR_LOW_MEMORY');
      DMLERR_MEMORY_ERROR : SendDebug('DMLERR_MEMORY_ERROR');
      DMLERR_NOTPROCESSED : SendDebug('DMLERR_NOTPROCESSED');
      DMLERR_NO_CONV_ESTABLISHED : SendDebug('DMLERR_NO_CONV_ESTABLISHED');
      DMLERR_POKEACKTIMEOUT : SendDebug('DMLERR_POKEACKTIMEOUT');
      DMLERR_POSTMSG_FAILED : SendDebug('DMLERR_POSTMSG_FAILED');
      DMLERR_REENTRANCY : SendDebug('DMLERR_REENTRANCY');
      DMLERR_SERVER_DIED : SendDebug('DMLERR_SERVER_DIED');
      DMLERR_SYS_ERROR : SendDebug('DMLERR_SYS_ERROR');
      DMLERR_UNADVACKTIMEOUT : SendDebug('DMLERR_UNADVACKTIMEOUT');
      DMLERR_UNFOUND_QUEUE_ID : SendDebug('DMLERR_UNFOUND_QUEUE_ID');
    end;
End;

function AnsiArrayToHex(const Arr: array of AnsiChar): string;
var
  i: Integer;
  HexStr: string;
begin
  HexStr := '';
  for i := Low(Arr) to High(Arr) do
  begin
    // Convert AnsiChar to its byte value, then to a 2-digit hex string
    HexStr := HexStr + IntToHex(Ord(Arr[i]), 2);
  end;
  Result := HexStr;
end;

function TextToHex(const InputStr: string): string;
begin
  // Handle empty string edge case
  if Length(InputStr) = 0 then
    Exit('');

  // Set the result length (each character requires 2 hex digits)
  SetLength(Result, Length(InputStr) * 2);

  // Convert buffer to hex string
  BinToHex(PChar(InputStr), PChar(Result), Length(InputStr));
end;

procedure log(LINENUM_: integer; message_: string);
begin
  SendDebug(LINENUM_.ToString+message_);
end;

// DDE Callback function
function DdeCallback(uType, uFmt: UINT; hConv: HCONV; hsz1, hsz2: HSZ;
  hData: HDDEDATA; dwData1, dwData2: DWORD): HDDEDATA; stdcall;
var
  cb: DWORD;
  //HSZPAIR FAR *phszp;
  phszp : ^HSZPAIR;
  lSize : Long;
  //sBuffer : String;
  BufferByte : array of Byte;
  BufferAnsiChar: array of AnsiChar;
  BufferAnsiString: AnsiString;
  BufferString: string;
  s:string;
  i:integer;
begin

  Result := DDE_FNOTPROCESSED; //Result := 0;

  // Handle transactions here
  if uFmt_uType_message then
  begin
    log({$I %LINENUM%},': In server callback. uFmt:'+ IntToHex(uFmt, 8) );
    log({$I %LINENUM%},': In server callback. uType:'+ IntToHex(uType, 8));
  end;

  if (uFmt = CF_TEXT) or (uFmt =0) then
  begin
    if (uType = XTYP_ADVDATA) then
    begin
      log({$I %LINENUM%},': Server: XTYP_ADVDATA');
      lSize := DdeGetData(hData, nil, 0, 0);
      log({$I %LINENUM%},' Server: lSize: '+lSize.ToString);
      If (lSize > 0) Then
      begin
        // Allocate a buffer for the return data.
        //sBuffer := StringOfChar(chr(0), lSize - MAGIC_NUMBER); // String$(lSize - MAGIC_NUMBER, 0);
        SetLength(BufferByte, lSize);
        // Grab the data.
        lSize := DdeGetData(hData, @BufferByte[0], Length(BufferByte), 0); //lSize := DdeGetData(hData, @sBuffer, SizeOf(sBuffer), 0);
        SetString(s, PAnsiChar(@BufferByte[0]), lSize);
        DDE_data^.Caption:=String(s);
      end;
      Result := DDE_FACK;
      log({$I %LINENUM%},': Server: Result := DDE_FACK');
    end;
    if (uType = XTYP_ADVREQ) then
    begin
      log({$I %LINENUM%},': Server: XTYP_ADVREQ');

          s:=Server_data^.Text+#0;
          log({$I %LINENUM%},' Server: Length(Server_data): '+Length(s).ToString);

          //DdeCreateDataHandle
          //idInst: Instance Identifier ที่ได้จากการเรียก
          //DdeInitializepSrc: พอยน์เตอร์ไปยังบัฟเฟอร์ที่เก็บข้อมูล
          //cb: ขนาดของข้อมูล (เป็นไบต์)
          //cbOff: ระยะออฟเซ็ตจากจุดเริ่มต้นของข้อมูล
          //hszItem: String Handle ที่ระบุชื่อรายการข้อมูล
          //wFmt: รูปแบบข้อมูล (เช่น CF_TEXT)afCmd: ค่าแฟล็ก เช่น
          //HDATA_APPOWNED (ระบุว่าแอปพลิเคชันเป็นเจ้าของออบเจ็กต์นี้)
          Result := DdeCreateDataHandle(InstId, PByte(PAnsiChar(s)), Length(s), 0, g_hszValue, CF_TEXT, 0);
          log({$I %LINENUM%},': Server: Result := '+Result.ToString);

    end;
    if (uType = XTYP_ADVSTART) then
    begin
      log({$I %LINENUM%},': Server: XTYP_ADVSTART');

      Result := DDE_FACK;
      log({$I %LINENUM%},': Server: Result := DDE_FACK');
    end;
    if (uType = XTYP_ADVSTOP) then
    begin
      log({$I %LINENUM%},': Server: XTYP_ADVSTOP');

      Result := DDE_FACK;
      log({$I %LINENUM%},': Server: Result := DDE_FACK');
    end;
    if (uType = XTYP_CONNECT) then
    begin
      log({$I %LINENUM%},': Server: XTYP_CONNECT');
      Result := 1;
      Result := DDE_FACK;
      log({$I %LINENUM%},': Server: Result := DDE_FACK');
    end;
    if (uType = XTYP_CONNECT_CONFIRM) then
    begin
      log({$I %LINENUM%},': Server: XTYP_CONNECT_CONFIRM');
    end;
    if (uType = XTYP_DISCONNECT) then
    begin
      log({$I %LINENUM%},': Server: XTYP_DISCONNECT');
    end;
    if (uType = XTYP_ERROR) then
    begin
      log({$I %LINENUM%},': Server: XTYP_ERROR');
    end;
    if (uType = XTYP_EXECUTE) then
    begin
      log({$I %LINENUM%},': Server: XTYP_EXECUTE');
      lSize := DdeGetData(hData, nil, 0, 0);
      SetLength(BufferAnsiChar, 0);
      SetLength(BufferAnsiChar, lSize+1);
      BufferString:= StringOfChar(#00, lSize+1); //clear / Initialize  Resets all elements to 0

      DdeGetData(hData, @BufferAnsiChar[0], Length(BufferAnsiChar), 0);
      BufferString:=string(BufferAnsiChar);
      BufferString:=UpCase(BufferString);
      //Result := DDE_FNOTPROCESSED  // Did the client specify a command that server not understa
      Result := DDE_FACK;  // Did the client specify a command that server understand

      //If (sBuffer := DDE_COMMAND1) Then
      //begin
      //  frmDDEServer.WindowState = vbMaximized
      //end
      //else if (sBuffer := DDE_COMMAND2) Then
      //begin
      //  frmDDEServer.WindowState := vbMinimized
      //end
      //else If (sBuffer = DDE_COMMAND3) Then
      //begin
      //  frmDDEServer.WindowState := vbNormal
      //end
      //Else
      //begin
      //  Result := DDE_FNOTPROCESSED
      //end;
      log({$I %LINENUM%},': Server: Result := DDE_FACK');
    end;
    if (uType = XTYP_MASK) then
    begin
      log({$I %LINENUM%},': Server: XTYP_MASK');
    end;
    if XTYP_MONITOR_message then
    if (uType = XTYP_MONITOR) then
    begin
      log({$I %LINENUM%},': Server: XTYP_MONITOR');
    end;
    if (uType = XTYP_POKE) then
    begin
      log({$I %LINENUM%},': Server: XTYP_POKE');    //txtItem_
      lSize := DdeQueryString(InstId, hsz2, nil, 0, CP_WINANSI);

      if lSize > 0 then
      begin
        SetLength(BufferAnsiChar, 0); //clear / Initialize
        SetLength(BufferAnsiChar, lSize+1); //clear / Initialize
        lSize := DdeQueryString(InstId, hsz2, @BufferAnsiChar[0], Length(BufferAnsiChar), CP_WINANSI);

        SetString(s, PAnsiChar(BufferAnsiChar), Length(BufferAnsiChar)); // Dynamic Array
        s:=DelChars(s,#0);

        log({$I %LINENUM%},': Server: s= "'+s+'"');
        log({$I %LINENUM%},': Server: txtItem_= "'+txtItem_+'"');
        If (s = txtItem_) Then
        begin
          lSize := DdeGetData(hData, nil, 0, 0);
          SetLength(BufferAnsiChar, 0);
          SetLength(BufferAnsiChar, lSize+1);
          BufferString:= StringOfChar(#00, lSize+1); //clear / Initialize  Resets all elements to 0

          DdeGetData(hData, @BufferAnsiChar[0], Length(BufferAnsiChar), 0);

          SetString(s, PAnsiChar(BufferAnsiChar), Length(BufferAnsiChar)); // Dynamic Array
          Server_data^.Text:=s;
          DdeFreeStringHandle(InstId, g_hszValue);
          g_hszValue := DdeCreateStringHandle(InstId, PAnsiChar(Server_data^.Text), CP_WINANSI);
          DdePostAdvise(InstId, 0, 0);

          // Must return DDE_FACK to tell the client the server accepted it
          Result := DDE_FACK;
          log({$I %LINENUM%},': Server: Result := DDE_FACK');
        end
        else
        begin
          // Must return DDE_FACK to tell the client the server not accepted it
         Result := DDE_FNOTPROCESSED;
         log({$I %LINENUM%},': Server: Result := DDE_FNOTPROCESSED');
        end;

    end;
    end;
    if (uType = XTYP_REGISTER) then
    begin
      log({$I %LINENUM%},': Server: XTYP_REGISTER');
    end;
    if (uType = XTYP_REQUEST) then
    begin
      log({$I %LINENUM%},': Server: XTYP_REQUEST');
      lSize := DdeQueryString(InstId, hsz2, nil, 0, CP_WINANSI);
      log({$I %LINENUM%},' Server: lSize: '+lSize.ToString);

      if lSize > 0 then
      begin
        SetLength(BufferAnsiChar, 0); // Resets all elements to 0
        SetLength(BufferAnsiChar, lSize+1);
        log({$I %LINENUM%},' Server: Length(Buffer): '+Length(BufferAnsiChar).ToString);
        lSize := DdeQueryString(InstId, hsz2, @BufferAnsiChar[0], Length(BufferAnsiChar), CP_WINANSI);
        log({$I %LINENUM%},' Server: Length(Buffer): '+Length(BufferAnsiChar).ToString);
        log({$I %LINENUM%},' Server: Length(txtItem_): '+Length(txtItem_).ToString);

        //i:=0;
        //if Length(BufferAnsiChar)>=1 then
        //if IntToHex(Ord(BufferAnsiChar[High(BufferAnsiChar)])) = '00' then i:=1;
        //SetString(BufferAnsiString, PAnsiChar(@BufferAnsiChar[0]), Length(BufferAnsiChar)-i);

        SetString(BufferAnsiString, PAnsiChar(@BufferAnsiChar[0]), Length(BufferAnsiChar));

        ////////////////////////////////////////////////

        SetString(s, PAnsiChar(BufferAnsiChar), Length(BufferAnsiChar)); // Dynamic Array
        s:=DelChars(s,#0);

        //log({$I %LINENUM%},' Server: s := string(AnsiStr) Length(s): '+Length(s).ToString);
        //s:=s;
        //log({$I %LINENUM%},' Server: s:=s Length(s): '+Length(s).ToString);
        //////////////////////////////////////////////////
        //s:='';
        //for i:=0 to High(Buffer) do
        //s:=s+':'+i.ToString;
        //log({$I %LINENUM%},' Server: s: '+s);
        //s:='';
        //for i:=0 to High(Buffer) do
        //s:=s+':'+IntToHex(Ord(Buffer[i]));
        //log({$I %LINENUM%},' Server: s: '+s);
        /////////////////////////////////////////////////
        //i:=low(Form1.txtItem.Text);
        //log({$I %LINENUM%},' Server: low(Form1.txtItem.Text): '+i.ToString);
        //i:=High(Form1.txtItem.Text);
        //log({$I %LINENUM%},' Server: High(Form1.txtItem.Text): '+i.ToString);
        /////////////////////////////////////////////////
        //s:='';
        //for i:=low(Form1.txtItem.Text) to High(Form1.txtItem.Text) do
        //s:=s+':'+IntToHex(Ord(Form1.txtItem.Text[i]));
        //log({$I %LINENUM%},' Server: Server: s: '+s);
        /////////////////////////////////////////////////
        //log({$I %LINENUM%},' Server: Length(s): '+Length(s).ToString);
        //log({$I %LINENUM%},' Server: Length(Form1.txtItem.Text): '+Length(Form1.txtItem.Text).ToString);
        //////////////////////////////////////////////////
        If (s = txtItem_) Then
        begin
          s:=Server_data^.Text+#0;
          //DdeCreateDataHandle
          //idInst: Instance Identifier ที่ได้จากการเรียก
          //DdeInitializepSrc: พอยน์เตอร์ไปยังบัฟเฟอร์ที่เก็บข้อมูล
          //cb: ขนาดของข้อมูล (เป็นไบต์)
          //cbOff: ระยะออฟเซ็ตจากจุดเริ่มต้นของข้อมูล
          //hszItem: String Handle ที่ระบุชื่อรายการข้อมูล
          //wFmt: รูปแบบข้อมูล (เช่น CF_TEXT)afCmd: ค่าแฟล็ก เช่น
          //HDATA_APPOWNED (ระบุว่าแอปพลิเคชันเป็นเจ้าของออบเจ็กต์นี้)

          Result := DdeCreateDataHandle(InstId, PByte(PAnsiChar(s)), Length(s), 0, hsz2, CF_TEXT, 0);
          log({$I %LINENUM%},': Server: Result := '+Result.ToString);
        end
        else
        begin
          Result := DDE_FNOTPROCESSED;
          log({$I %LINENUM%},': Server: Result := DDE_FNOTPROCESSED');
        end;
      end;
    end;
    if (uType = XTYP_SHIFT) then
    begin
      log({$I %LINENUM%},': Server: XTYP_SHIFT');
    end;
    if (uType = XTYP_UNREGISTER) then
    begin
      log({$I %LINENUM%},': Server: XTYP_UNREGISTER');
    end;
    if (uType = XTYP_WILDCONNECT) then
    begin
      log({$I %LINENUM%},': Server: XTYP_WILDCONNECT');
      //DdeCreateDataHandle(InstId, nil, 2 * sizeof(HSZPAIR),0,0,0,0);
    end;
    if (uType = XTYP_XACT_COMPLETE) then   {DDE Client receiving asynchronous request results }
    begin
      // Data contains the result of the completed transaction
      log({$I %LINENUM%},': Server: XTYP_XACT_COMPLETE');
      // Must return DDE_FACK to acknowledge success
      Result := DDE_FACK;
      log({$I %LINENUM%},': Server: Result := DDE_FACK');
    end;
  end;
end;
end.
