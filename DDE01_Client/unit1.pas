unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Windows, Messages, DDEVar, dbugintf, StrUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button10: TButton;
    Button11: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    cmdInitialize: TButton;
    cmdExecute: TButton;
    cmdUninitialize: TButton;
    cmdClear: TButton;
    cmdStartAdv: TButton;
    cmdStopAdv: TButton;
    cmdRequest: TButton;
    cmdPoke: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Shape1: TShape;
    txtService1: TEdit;
    txtTopic1: TEdit;
    txtValue: TEdit;
    txtService: TEdit;
    txtTopic: TEdit;
    cboItem: TComboBox;
    Label1: TLabel;
    txtItem1: TEdit;
    txtItem: TEdit;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure cmdClearClick(Sender: TObject);
    procedure cmdExecuteClick(Sender: TObject);
    procedure cmdInitializeClick(Sender: TObject);
    procedure cmdPokeClick(Sender: TObject);
    procedure cmdRequestClick(Sender: TObject);
    procedure cmdStartAdvClick(Sender: TObject);
    procedure cmdStopAdvClick(Sender: TObject);
    procedure cmdUninitializeClick(Sender: TObject);
    procedure cboItemEditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  InstId: DWORD;
  DdeInitializeResultCode_Pascal: UINT;

  Buffer: array[0..255] of AnsiChar;
  Length_: DWORD;
  ResultString: string;
  Result_:pbyte;
  pData: Pointer;
  hDataQUOTE: HDDEDATA;
  hszString: HSZ;
  g_hszAppName, g_hszTopicName, g_hszItemName: HSZ;
  DataSize: DWORD;
  hConv_: HCONV;

  bAdvise:boolean;

implementation

{$R *.lfm}

{ TForm1 }

procedure log(LINENUM_: integer; message_: string);
begin
  SendDebug(LINENUM_.ToString+message_);
end;

function ReadDdeWithAccessData(hData: HDDEDATA): string;
var
  DataPtr: PByte;
  DataSize: DWORD;
  AnsiStr: AnsiString;
begin
  Result := '';
  if hData = 0 then Exit;

  // 1. Lock the memory handle and retrieve its memory address pointer
  // Passing @DataSize fills the variable with the total byte length
  DataPtr := DdeAccessData(hData, @DataSize);

  if DataPtr <> nil then
  begin
    try
      if DataSize > 0 then
      begin
        // 2. Map the pointer directly to a Pascal string
        // DDE standard transmission uses null-terminated ANSI strings
        SetString(AnsiStr, PAnsiChar(DataPtr), DataSize);

        // 3. Convert to native Unicode string (for Delphi 2009 and newer)
        Result := DelChars(string(AnsiStr),#0);
      end;
    finally
      // 4. Always unlock the memory handle in a finally block
      DdeUnaccessData(hData);
    end;
  end;
end;

function ExtractDdeString(hData: HDDEDATA): string;
var
  DataSize: DWORD;
  Buffer: array of Byte;
  AnsiStr: AnsiString;
begin
  Result := '';
  if hData = 0 then Exit;

  // 1. Get the required buffer size by passing nil to pDst
  DataSize := DdeGetData(hData, nil, 0, 0);

  if DataSize > 0 then
  begin
    // 2. Allocate the local memory buffer
    SetLength(Buffer, DataSize);

    // 3. Fetch the actual data into our buffer
    DdeGetData(hData, @Buffer[0], DataSize, 0);

    // 4. Convert the buffer to a usable Pascal string format
    // (DDE data is traditionally transferred as ANSI/Null-terminated)
    SetString(AnsiStr, PAnsiChar(@Buffer[0]), DataSize);

    // Convert to native Unicode string if using modern Delphi
    Result := string(AnsiStr);
  end;
end;

function ExtractStringFromDde(hData: HDDEDATA): string;
var
  DataPtr: PByte;
  DataSize: DWORD;
  AnsiStr: AnsiString;
begin
  Result := '';
  if hData = 0 then Exit;

  // Lock memory handle and read data pointer directly
  DataPtr := DdeAccessData(hData, @DataSize);
  if DataPtr <> nil then
  begin
    try
      if DataSize > 0 then
      begin
        // DDE traditionally uses null-terminated ANSI strings
        SetString(AnsiStr, PAnsiChar(DataPtr), DataSize);
        Result := string(AnsiStr);
      end;
    finally
      // Always free the memory lock in a finally block
      DdeUnaccessData(hData);
    end;
  end;
end;

procedure TranslateError();
var
  lRet : Long;
begin
    lRet := DdeGetLastError(g_lInstID);

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

procedure DDE_Disconnect();
Begin
  // Disconnect the DDE conversation.
  log({$I %LINENUM%},' Client: g_hDDEConv: '+ g_hDDEConv.ToString);

  If (g_hDDEConv>0) Then
  begin
    If DdeDisconnect(g_hDDEConv) Then
    begin
      log({$I %LINENUM%},' Client: DDE Disconnect Success.: '+ IntToHex(DdeInitializeResultCode_VB6, 8));
    end
    Else
    begin
      log({$I %LINENUM%},' Client: DDE Disconnect Failure.: '+ IntToHex(DdeInitializeResultCode_VB6, 8));
      TranslateError();
    End;
    g_hDDEConv := 0;
  End;
End;

Function CheckData(sCommand : String): Boolean;
var
  bRet : Boolean;
begin
  bRet:=false;
  case sCommand of
    'Execute':
            If (form1.txtService.Text <> '') And (form1.txtTopic.Text <> '') Then
            begin
              bRet := True;
            End;
    'Poke', 'Request', 'Advise' :
            If (form1.txtService.Text <> '') And (form1.txtTopic.Text <> '') And (form1.cboItem.Text <> '<None>') Then
            begin
                bRet := True;
            End;
  end;
  CheckData := bRet;

End;

procedure DDE_CreateStringHandles(var sTheService : String; var sTheTopic : String; const sTheItem : String = '');
begin
  // Create the string handles for the service and topic. DDEML will not
  // allow you to use standard strings. NOTE: Make sure to release the
  // string handles once you are done with them.

  g_hService := DdeCreateStringHandle(g_lInstID, PAnsiChar(sTheService), CP_WINANSI);
  g_hTopic := DdeCreateStringHandle(g_lInstID, PAnsiChar(sTheTopic), CP_WINANSI);

  // Only convert the item if we were passed a string otherwise you'll get a memory
  // error.
  If (sTheItem <> '') Then
  begin
    g_hItem := DdeCreateStringHandle(g_lInstID, PAnsiChar(sTheItem), CP_WINANSI);
  End;

  log({$I %LINENUM%},' After create string handles -------------------------');
  log({$I %LINENUM%},' Client: g_hService: '+ g_hService.ToString);
  log({$I %LINENUM%},' Client: g_hTopic: '+ g_hTopic.ToString);
  log({$I %LINENUM%},' Client: g_hItem: '+ g_hItem.ToString);
End;

Function DDE_Connect() : Long;
var
  udtConvCont : CONVCONTEXT;
  hDDEConv : Long;
begin

    // Set up the conversation context structure.
    udtConvCont.iCodePage := CP_WINANSI;
    udtConvCont.cb := SizeOf(udtConvCont);  //Length(udtConvCont)

    hDDEConv := 0;

    // Open the connection to the service.
    hDDEConv := DdeConnect(g_lInstID, g_hService, g_hTopic, udtConvCont);

    // Do we have a connection?
    If (hDDEConv>0) Then
    begin
      log({$I %LINENUM%},' Client: DDE Connection Success.');
    end
    Else
    begin
      log({$I %LINENUM%},' Client: DDE Connection Failure.');
      TranslateError();

    End;

    DDE_Connect := hDDEConv;

End;

procedure DDE_FreeStringHandles();
begin
    // Release our string handles.
    If (g_hService <> 0) Then
    begin
        DdeFreeStringHandle(g_lInstID, g_hService);
        DdeFreeStringHandle(g_lInstID, g_hTopic );

    End;

    If (g_hItem <> 0) Then
    begin
        DdeFreeStringHandle(g_lInstID, g_hItem);

    End;

    g_hService := 0;
    g_hTopic := 0;
    g_hItem := 0;

End;

//function ReadDDEData(const ServiceName, TopicName, ItemName: string): string;
//var
//  DDEClient: TDDEClientConv;
//  DataPtr: PAnsiChar;
//begin
//  Result := '';
//  DDEClient := TDDEClientConv.Create(nil);
//  try
//    // Set the link parameters
//    DDEClient.SetLink(ServiceName, TopicName);
//
//    // Attempt to open the connection
//    if DDEClient.OpenLink then
//    begin
//      // Request data for a specific Item (e.g. an Excel cell R1C1)
//      DataPtr := DDEClient.RequestData(ItemName);
//
//      if DataPtr <> nil then
//      begin
//        Result := StrPas(DataPtr); // Convert PChar to String
//        SysUtils.StrDispose(DataPtr); // Free the memory allocated by the server
//      end;
//    end;
//  finally
//    DDEClient.Free;
//  end;
//end;

procedure AppendTextToDDE(var MainhData: HDDEDATA; const NewText: AnsiString);
var
  //DataPtr: Pointer;
  //DataLen: DWORD;
  AnsiVal: AnsiString;
  DataPtr: PByte;
  DataLen: DWORD;
  hData: HDDEDATA;
  ResultData: HDDEDATA;
begin



  if MainhData = 0 then Exit;

  //AnsiVal: AnsiString;
  //DataPtr: PByte;
  //DataLen: DWORD
  AnsiVal := AnsiString(NewText) + #0;
  DataPtr := PByte(PAnsiChar(AnsiVal));
  DataLen := Length(AnsiVal); // Includes the null terminator character

  //DataPtr: Pointer;
  //DataLen: DWORD;
  //DataPtr := PAnsiChar(NewText);
  //DataLen := Length(NewText) + 1;

  hData := DdeCreateDataHandle(
               InstId,
               PByte(PAnsiChar(AnsiVal)),
               Length(AnsiVal),
               0,         // Offset 0 (Start of object)
               0,         // No structural item string handle attached
               CF_TEXT,   // Clipboard layout standard
               0          // Creation flags
               );

  ResultData := DdeAddData(hData, DataPtr, DataLen, 0);

  if ResultData > 0 then
  begin
    hData := ResultData;  // Update with the newly generated handle
    log({$I %LINENUM%},' Client: DdeAddData Success ResultData: '+ResultData.ToString);
  end
  else
  begin
    log({$I %LINENUM%},' Client: Handle error DdeAddData ResultData: '+ResultData.ToString);
    TranslateError();
  end;
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
  sBuffer : array of Byte;
  Ret : Long;
  ReceivedText: string;
  s:string;
begin

  Result := DDE_FNOTPROCESSED; //Result := 0;

  // Handle transactions here
  if form1.CheckBox1.Checked then
  begin
    log({$I %LINENUM%},': In client callback. uFmt:'+ IntToHex(uFmt, 8) );
    log({$I %LINENUM%},': In client callback. uType:'+ IntToHex(uType, 8));
  end;

  if (uFmt = CF_TEXT) or (uFmt =0) then
  begin
    if (uType = XTYP_ADVDATA) then
    begin
      log({$I %LINENUM%},': Client: XTYP_ADVDATA');
      lSize := DdeGetData(hData, nil, 0, 0);
      log({$I %LINENUM%},': Client: lSize: '+lSize.ToString);
      If (lSize > 0) Then
      begin
        // Allocate a buffer for the return data.
        //sBuffer := StringOfChar(chr(0), lSize - MAGIC_NUMBER); // String$(lSize - MAGIC_NUMBER, 0);
        SetLength(sBuffer, lSize);
        // Grab the data.
        if lSize <= SizeOf(sBuffer) then lSize := DdeGetData(hData, @sBuffer[0], SizeOf(sBuffer), 0); //lSize := DdeGetData(hData, @sBuffer, Length(sBuffer), 0);
        SetString(s, PAnsiChar(@sBuffer[0]), lSize);
        form1.Label1.caption := 'DDE data: '+String(s); //form1.Label1.caption := 'DDE data: '+sBuffer;
      End;
      Result := DDE_FACK;
    end;
    if (uType = XTYP_ADVSTART) then
    begin
      log({$I %LINENUM%},': Client: XTYP_ADVSTART');
    end;
    if (uType = XTYP_ADVSTOP) then
    begin
      log({$I %LINENUM%},': Client: XTYP_ADVSTOP');
    end;
    if (uType = XTYP_CONNECT) then
    begin
      log({$I %LINENUM%},': Client: XTYP_CONNECT');
      Result := 1;
    end;
    if (uType = XTYP_CONNECT_CONFIRM) then
    begin
      log({$I %LINENUM%},': Client: XTYP_CONNECT_CONFIRM');
    end;
    if (uType = XTYP_DISCONNECT) then
    begin
      log({$I %LINENUM%},': Client: XTYP_DISCONNECT');
    end;
    if (uType = XTYP_ERROR) then
    begin
      log({$I %LINENUM%},': Client: XTYP_ERROR');
    end;
    if (uType = XTYP_EXECUTE) then
    begin
      log({$I %LINENUM%},': Client: XTYP_EXECUTE');
    end;
    if (uType = XTYP_MASK) then
    begin
      log({$I %LINENUM%},': Client: XTYP_MASK');
    end;
    if form1.CheckBox2.Checked then
    if (uType = XTYP_MONITOR) then
    begin
      log({$I %LINENUM%},': Client: XTYP_MONITOR');
    end;
    if (uType = XTYP_POKE) then
    begin
      log({$I %LINENUM%},': Client: XTYP_POKE');
      // Data contains the text payload sent by the client
      ReceivedText := ExtractStringFromDde(hData);
      SendDebug('ReceivedText: '+ReceivedText);
      // Hsz2 contains the Item name string handle
      // TODO: Process the payload text assigned to this specific item

      // Must return DDE_FACK to tell the client the server accepted it
      Result := DDE_FACK;

    end;
    if (uType = XTYP_REGISTER) then
    begin
      log({$I %LINENUM%},': Client: XTYP_REGISTER');
      If (g_lInstID>0) Then
      begin
        log({$I %LINENUM%},' Client: XTYP_REGISTER DdeQueryString');
        lSize := DdeQueryString(g_lInstID, hsz2, nil, 0, CP_WINANSI);
        log({$I %LINENUM%},' Client: hsz2 lSize: '+lSize.ToString);

        Buffer:=Space(SizeOf(sBuffer));
        s := string(Buffer);
        log({$I %LINENUM%},' Client: Empty: '+s);

        //sBuffer := Space(lSize);
        //DdeQueryString(g_lInstID, hsz2, @sBuffer, lSize + 1, CP_WINANSI);
        lSize := DdeQueryString(g_lInstID, hsz2, Buffer, lSize+1, CP_WINANSI);
        //sBuffer := UpperCase(sBuffer);
        s := string(Buffer);
        log({$I %LINENUM%},' Client: ResultString: '+s);

        lSize := DdeQueryString(g_lInstID, hsz1, nil, 0, CP_WINANSI);
        log({$I %LINENUM%},' Client: hsz1 lSize: '+lSize.ToString);
        Buffer:=Space(SizeOf(sBuffer));
        s := string(Buffer);
        log({$I %LINENUM%},' Client: Empty: '+s);
        lSize := DdeQueryString(g_lInstID, hsz2, Buffer, lSize+1, CP_WINANSI);
        s := string(Buffer);
        log({$I %LINENUM%},' Client: ResultString: '+s);
      end;
    end;
    if (uType = XTYP_REQUEST) then
    begin
      log({$I %LINENUM%},': Client: XTYP_REQUEST');
    end;
    if (uType = XTYP_SHIFT) then
    begin
      log({$I %LINENUM%},': Client: XTYP_SHIFT');
    end;
    if (uType = XTYP_UNREGISTER) then
    begin
      log({$I %LINENUM%},': Client: XTYP_UNREGISTER');
    end;
    if (uType = XTYP_WILDCONNECT) then
    begin
      log({$I %LINENUM%},': Client: XTYP_WILDCONNECT');
      //DdeCreateDataHandle(InstId, nil, 2 * sizeof(HSZPAIR),0,0,0,0);
    end;
    if (uType = XTYP_XACT_COMPLETE) then   {DDE Client receiving asynchronous request results }
    begin
      // Data contains the result of the completed transaction
      log({$I %LINENUM%},': Client: XTYP_XACT_COMPLETE');
      ReceivedText := ExtractStringFromDde(hData);

      // TODO: Process your asynchronously received string data here
      //..
      //..

      // Must return DDE_FACK to acknowledge success
      Result := DDE_FACK;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  bAdvise:=false;


end;

procedure TForm1.Button10Click(Sender: TObject);
var
  sValue : String;
  AnsiVal: AnsiString;
  DataPtr: PByte;
  DataLen: DWORD;
  hData: HDDEDATA;
  ResultData: HDDEDATA;
begin

  AnsiVal := AnsiString(txtValue.Text) + #0;
  DataPtr := PByte(PAnsiChar(AnsiVal));
  DataLen := Length(AnsiVal); // Includes the null terminator character

  if hConv_ = 0 then
  begin
    log({$I %LINENUM%},' Client: Connect bad hConv_: '+hConv_.ToString);
  end
  else
  begin
    //sValue := txtValue.Text;
    // Send the POKE transaction
    //hDataQUOTE := DdeClientTransaction(@sValue[1], length(sValue), hConv_, g_hszItemName, CF_TEXT, XTYP_POKE, 2000, nil); //<=@sValue[1] -------------------------------------------------------
    hDataQUOTE := DdeClientTransaction(DataPtr, DataLen, hConv_, g_hszItemName, CF_TEXT, XTYP_POKE, 2000, nil);

    if hDataQUOTE > 0 then
    begin
      log({$I %LINENUM%},' Client: DdeClientTransaction POKE Success hDataQUOTE: ' + hDataQUOTE.ToString);

      //hData := DdeCreateDataHandle(
      //         InstId,
      //         PByte(PAnsiChar(AnsiVal)),
      //         Length(AnsiVal),
      //         0,         // Offset 0 (Start of object)
      //         0,         // No structural item string handle attached
      //         CF_TEXT,   // Clipboard layout standard
      //         0          // Creation flags
      //         );
      //
      //ResultData:=DdeAddData(hData, DataPtr, DataLen, 0);
      //if ResultData > 0 then
      //begin
      //  hDataQUOTE := ResultData;  // Update with the newly generated handle
      //  SendDebug(i.ToString+' DdeAddData Success ResultData: '+ResultData.ToString);
      //end
      //else
      //begin
      //  SendDebug(i.ToString+' Handle error DdeAddData ResultData: '+ResultData.ToString);
      //  TranslateError();
      //end;
    end
    Else
    begin
      log({$I %LINENUM%},' Client: DdeClientTransaction POKE Failed hDataQUOTE: ' + hDataQUOTE.ToString);
      TranslateError();
      exit;
    End;

  end;

end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  if hDataQUOTE > 0 then
    begin
      AppendTextToDDE(hDataQUOTE,txtValue.Text);
    end
    Else
    begin
      log({$I %LINENUM%},' Client: DdeClientTransaction POKE Failed hDataQUOTE: ' + hDataQUOTE.ToString);
    End;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  //Registers or unregisters the service names
  //XTYP_REGISTER or XTYP_UNREGISTER
  //HDDEDATA DdeNameService
  //(
  //[in]           DWORD idInst,
  //[in, optional] HSZ   hsz1,
  //[in, optional] HSZ   hsz2,
  //[in]           UINT  afCmd
  //);

  // Initialize DDEML
  //DdeInitializeResultCode_Pascal := DdeInitialize
  //(
  //  @InstId,                     // Pointer to instance ID
  //  @DdeCallback,                // Callback function pointer
  //  APPCLASS_STANDARD or         // Application type flags
  //  CBF_FAIL_ALLSVRXACTIONS,     // Filter flags (example)
  //  0                            // Reserved
  //);

  DdeInitializeResultCode_Pascal := DdeInitialize
  (
  @InstId,
  @DdeCallback,
  APPCLASS_STANDARD or APPCMD_CLIENTONLY,     //APPCLASS_STANDARD APPCMD_CLIENTONLY  APPCMD_TARGETONLY  CBF_FAIL_ALLSVRXACTIONS
  0
  );

   if DdeInitializeResultCode_Pascal <> DMLERR_NO_ERROR then
   begin
     log({$I %LINENUM%},' Client: DdeInitialize failed! Error code: '+ IntToHex(DdeInitializeResultCode_Pascal, 8));
     log({$I %LINENUM%},' Client: g_lInstID: '+ InstId.ToString);
     TranslateError();
     exit;
   end
   Else
   begin
     log({$I %LINENUM%},' Client: DDE Initialize Success: '+ IntToHex(DdeInitializeResultCode_Pascal, 8));
     log({$I %LINENUM%},' Client: InstId: '+ InstId.ToString);
   End;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // Create string handles
  g_hszAppName := DdeCreateStringHandle(InstId, PAnsiChar(txtService1.Text), CP_WINANSI);
  g_hszTopicName := DdeCreateStringHandle(InstId, PAnsiChar(txtTopic1.Text), CP_WINANSI);
  g_hszItemName := DdeCreateStringHandle(InstId, PAnsiChar(txtItem1.Text), CP_WINANSI);

   // 'hszString' represents the string handle you obtained previously

  //Study case: Check empty string: hszString
  //Length_ := DdeQueryString(InstId, hszString, Buffer, SizeOf(Buffer), CP_WINANSI);
  //if Length_ > 0 then
  //begin
  //  // ResultString now contains the string value
  //  ResultString := string(Buffer);
  //  showmessage('hszString (empty string): '+ResultString);
  //end;

  log({$I %LINENUM%},' After create string handles -------------------------');
  log({$I %LINENUM%},' Client: g_hszAppName: '+ g_hszAppName.ToString);
  log({$I %LINENUM%},' Client: g_hszTopicName: '+ g_hszTopicName.ToString);
  log({$I %LINENUM%},' Client: g_hszItemName: '+ g_hszItemName.ToString);

  log({$I %LINENUM%},'Recheck string handles -------------------------');
  Length_ := DdeQueryString(InstId, g_hszAppName, Buffer, SizeOf(Buffer), CP_WINANSI);
  if Length_ > 0 then
  begin
    // ResultString now contains the string value
    ResultString := string(Buffer);
    log({$I %LINENUM%},' Client: ResultString g_hszAppName: '+ResultString);
  end;

  Length_ := DdeQueryString(InstId, g_hszTopicName, Buffer, SizeOf(Buffer), CP_WINANSI);
  if Length_ > 0 then
  begin
    // ResultString now contains the string value
    ResultString := string(Buffer);
    log({$I %LINENUM%},' Client: ResultString g_hszTopicName: '+ResultString);
  end;

  Length_ := DdeQueryString(InstId, g_hszItemName, Buffer, SizeOf(Buffer), CP_WINANSI);
  if Length_ > 0 then
  begin
    // ResultString now contains the string value
    ResultString := string(Buffer);
    log({$I %LINENUM%},' Client: ResultString g_hszItemName: '+ResultString);
  end;


end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  // Open the conversation/connect
  log({$I %LINENUM%},' Client: Open the conversation/connect ----------------');
  hConv_ := DdeConnect(InstId, g_hszAppName, g_hszTopicName, nil);

  if hConv_ > 0 then
  begin
    log({$I %LINENUM%},' Client: Connected Success hConv_: '+hConv_.ToString);
  end
  else
  begin
    log({$I %LINENUM%},' Client: Connect failed hConv_: '+hConv_.ToString);
    TranslateError();
  end;

end;

procedure TForm1.Button5Click(Sender: TObject);
var
  i:integer;
begin

  if hConv_ = 0 then
  begin
    SendDebug(i.ToString+' Client: Connect bad hConv_: '+hConv_.ToString);
  end
  else
    begin
      //ShowMessage('Connect OK Handle: ' + IntToStr(hConv_));
      ////hDataQUOTE := DdeClientTransaction(nil, 0, hConv_, g_hszItemName, CF_TEXT, XTYP_REQUEST, 50, nil);

      // Send the request transaction
      hDataQUOTE := DdeClientTransaction(
      nil,               // No outbound data
      0,                 // Data size is 0
      hConv_,             // Active conversation handle
      g_hszItemName,           // The item handle we want (e.g., 'R1C1' for Excel)
      CF_TEXT,           // Request data as standard text
      XTYP_REQUEST,      // Transaction type
      5000,              // 5-second timeout
      nil                // Ignore result flag
      );

      if hDataQUOTE > 0 then
      begin
        log({$I %LINENUM%},' Client: DdeClientTransaction Request Success hDataQUOTE: ' + hDataQUOTE.ToString);
      end
      Else
      begin
        log({$I %LINENUM%},' Client: DdeClientTransaction Request Failed hDataQUOTE: ' + hDataQUOTE.ToString);
        TranslateError();
      End;

    end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  DataSize: DWORD;
  sBuffer: array of Byte;
  s:AnsiString;
begin

  if hDataQUOTE > 0 then
  begin
    SendDebug(' Client: DdeGetData---------------------');

    //Get target DDE size
    DataSize := DdeGetData(hDataQUOTE, nil, 0, 0);
    log({$I %LINENUM%},' Client: DataSize: ' + DataSize.ToString);

    //Allocate/Resize local memory buffer
    SetLength(sBuffer, DataSize);

    //Fetch the actual data into our buffer
    DdeGetData(hDataQUOTE, @sBuffer[0], DataSize, 0);

    //***********************
    //Alternative Approach: Direct Pointer AccessInstead of copying bytes using DdeGetData,
    //you can alternatively lock the memory handle directly in place to read it using DdeAccessData.
    //This avoids an explicit local buffer allocation but
    //requires you to call DdeUnaccessData immediately after reading

    //Convert the buffer to a usable Pascal string format
    // (DDE data is traditionally transferred as ANSI/Null-terminated)
    SetString(s, PAnsiChar(@sBuffer[0]), DataSize);
    s:=DelChars(s,#0);

    //DdeGetData(hDataQUOTE, @Buffer, SizeOf(Buffer), 0);
    //ShowMessage('Data received: ' + String(Buffer));

    //Label1.Caption:='DDE data: '+ String(Buffer);
    //Label1.Caption:='DDE data: '+ExtractDdeString(hDataQUOTE);
    Label1.Caption:='DDE data: '+string(s);
  end
  else
  begin
    log({$I %LINENUM%},' Client: ClientTransaction Failed hDataQUOTE: ' + hDataQUOTE.ToString);
  end;


end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  SendDebug('-------------------- End DDE Test ------------------------');

  If (hConv_>0) Then
  begin
    log({$I %LINENUM%},' Client: Make sure we don''t have any open connections');
    If DdeDisconnect(hConv_) Then
    begin
      log({$I %LINENUM%},' Client: DDE Disconnect Success.: '+ IntToHex(DdeInitializeResultCode_Pascal, 8));
    end
    Else
    begin
      log({$I %LINENUM%},' Client: DDE Disconnect Failure.: '+ IntToHex(DdeInitializeResultCode_Pascal, 8));
      TranslateError();
    End;
    hConv_ := 0;
  End;

  // Tear down the initialized instance.
  If (InstId>0) Then
  begin
    If DdeUninitialize(InstId) Then
    begin
      log({$I %LINENUM%},' Client: DDE Uninitialize Success: '+ IntToHex(DdeInitializeResultCode_Pascal, 8));
      log({$I %LINENUM%},' Client: InstId: '+ InstId.ToString);
    end
    Else
    begin
      log({$I %LINENUM%},' Client: DDE Uninitialize Failure. '+ IntToHex(DdeInitializeResultCode_Pascal, 8));
      log({$I %LINENUM%},' Client: InstId: '+ InstId.ToString);
      TranslateError();
    End;

    InstId := 0;
  End;

  //DdeClientTransaction
  //Free dde
  DdeFreeStringHandle(InstId, g_hszAppName);
  DdeFreeStringHandle(InstId, g_hszTopicName);
  DdeFreeStringHandle(InstId, g_hszItemName);

  log({$I %LINENUM%},' Client: After DdeFreeStringHandle -------------------------');
  log({$I %LINENUM%},' Client: g_hszAppName: '+ g_hszAppName.ToString);
  log({$I %LINENUM%},' Client: g_hszTopicName: '+ g_hszTopicName.ToString);
  log({$I %LINENUM%},' Client: g_hszItemName: '+ g_hszItemName.ToString);

  log({$I %LINENUM%},' Client: Recheck string handles -------------------------');
  Length_ := DdeQueryString(InstId, g_hszAppName, Buffer, SizeOf(Buffer), CP_WINANSI);
  if Length_ > 0 then
  begin
    ResultString := string(Buffer);
    log({$I %LINENUM%},' Client: ResultString g_hszAppName: '+ResultString);
  end;

  Length_ := DdeQueryString(InstId, g_hszTopicName, Buffer, SizeOf(Buffer), CP_WINANSI);
  if Length_ > 0 then
  begin
    ResultString := string(Buffer);
    log({$I %LINENUM%},' Client: ResultString g_hszTopicName: '+ResultString);
  end;

  Length_ := DdeQueryString(InstId, g_hszItemName, Buffer, SizeOf(Buffer), CP_WINANSI);
  if Length_ > 0 then
  begin
    ResultString := string(Buffer);
    log({$I %LINENUM%},' Client: ResultString g_hszItemName: '+ResultString);
  end;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  i:integer;
  s:AnsiString;
begin

  SendDebug(' Client: DdeAccessData---------------------');

  if hDataQUOTE > 0 then
  begin
    s:=ReadDdeWithAccessData(hDataQUOTE);
    Label1.Caption:='DDE data: '+string(s);
  end
  else
  begin
    log({$I %LINENUM%},' Client: ClientTransaction Failed hDataQUOTE: ' + hDataQUOTE.ToString);
  end;

end;

procedure TForm1.cmdClearClick(Sender: TObject);
begin
    // Clear out the text boxes.
    cboItem.ItemIndex := 0;
    txtValue.Text := '';
end;

procedure TForm1.cmdExecuteClick(Sender: TObject);
var
  lRet : Long;
  sValue : String;
  txtService_ : string;
  txtTopic_ : string;
begin

  If (CheckData('Execute')) Then
  begin
    log({$I %LINENUM%},' Client: Execute -------------------------');
    // Load the buffer.
    sValue := txtValue.Text;

    // Create the string handles.
    txtService_:= txtService.Text;
    txtTopic_ := txtTopic.Text;
    DDE_CreateStringHandles(txtService_, txtTopic_);

    log({$I %LINENUM%},' Client: Recheck string handles -------------------------');
    Length_ := DdeQueryString(g_lInstID, g_hService, Buffer, SizeOf(Buffer), CP_WINANSI);
    if Length_ > 0 then
    begin
      // ResultString now contains the string value
      ResultString := string(Buffer);
      log({$I %LINENUM%},' Client: ResultString g_hszAppName: '+ResultString);
    end;

    Length_ := DdeQueryString(g_lInstID, g_hTopic, Buffer, SizeOf(Buffer), CP_WINANSI);
    if Length_ > 0 then
    begin
      // ResultString now contains the string value
      ResultString := string(Buffer);
      log({$I %LINENUM%},' Client: ResultString g_hszTopicName: '+ResultString);
    end;

    Length_ := DdeQueryString(g_lInstID, g_hItem, Buffer, SizeOf(Buffer), CP_WINANSI);
    if Length_ > 0 then
    begin
      // ResultString now contains the string value
      ResultString := string(Buffer);
      log({$I %LINENUM%},' Client: ResultString g_hszItemName: '+ResultString);
    end;

    // Open the conversation.
    If (g_hDDEConv = 0) Then
    begin
      g_hDDEConv := DDE_Connect();
    End;

    If (g_hDDEConv>0) Then
    begin
      // Perform the transaction.
      lRet := DdeClientTransaction(@sValue[1], Length(sValue)+1, g_hDDEConv, 0, 0, XTYP_EXECUTE, 2000, nil);

      If (lRet>0) Then
      begin
        log({$I %LINENUM%},' Client: DDE Execute Success.');
      end

      Else
      begin
        log({$I %LINENUM%},' Client: DDE Execute Failure.');
        TranslateError();

      End;

    End;

    // Release the memory.
    DDE_FreeStringHandles();
  end
  Else
  begin
    showmessage('Client: Please enter the required data for the transaction.');
  End;
end;

procedure TForm1.cmdInitializeClick(Sender: TObject);
begin

  SendDebug('Client: ------------------- Begin DDE Test -----------------------');

  g_lInstID := 0;

  // Initialize the DDE subsystem. This only needs to be done once.
  DdeInitializeResultCode_VB6:=DdeInitialize(@g_lInstID, @DDECallback, APPCMD_CLIENTONLY Or MF_SENDMSGS Or MF_POSTMSGS, 0);
  if DdeInitializeResultCode_VB6 <> DMLERR_NO_ERROR then
  begin
    log({$I %LINENUM%},' Client: DDE Initialize failed! Error code: '+ IntToHex(DdeInitializeResultCode_VB6, 8));
    log({$I %LINENUM%},' Client: g_lInstID: '+ g_lInstID.ToString);
    TranslateError();
    exit;
  end
  Else
  begin
    log({$I %LINENUM%},' Client: DDE Initialize Success: '+ IntToHex(DdeInitializeResultCode_VB6, 8));
    log({$I %LINENUM%},' Client: g_lInstID: '+ g_lInstID.ToString);
  End;

  cboItem.Enabled:=true;
  txtValue.Enabled:=true;

  cmdInitialize.Enabled := False;
  cmdUninitialize.Enabled := True;
  cmdClear.Enabled := True;
  cboItem.ItemIndex := 0;
end;

procedure TForm1.cmdPokeClick(Sender: TObject);
var
  lRet : Long;
  sValue : String;
  AnsiVal: AnsiString;
  DataPtr: PByte;
  DataLen: DWORD;
  txtService_:string;
  txtTopic_:string;
  txtItem_:string;
  i:integer;
begin
  txtService_:=txtService.Text;
  txtTopic_:=txtTopic.Text;
  txtItem_:= txtItem.Text;
  If (CheckData('Poke')) Then
  begin
        // Load the buffer.
        sValue := txtValue.Text;  //length(sValue)+1
        sValue := txtValue.Text+ #0;  //length(sValue)

        DDE_CreateStringHandles(txtService_, txtTopic_, txtItem_);

        // Open the conversation.
        If (g_hDDEConv = 0) Then
        begin
            g_hDDEConv := DDE_Connect();
        End;

        If (g_hDDEConv>0) Then
        begin
          // Perform the transaction.

          AnsiVal := AnsiString(txtValue.Text) + #0;
          DataPtr := PByte(PAnsiChar(AnsiVal));
          DataLen := Length(AnsiVal);
          i:= length(sValue);
          log({$I %LINENUM%},' Client: length(sValue): '+i.ToString+'  DataLen: '+DataLen.ToString);
          //lRet := DdeClientTransaction(DataPtr, DataLen, g_hDDEConv, g_hItem, CF_TEXT, XTYP_POKE, 2000, nil);
          lRet := DdeClientTransaction(@sValue[1], length(sValue), g_hDDEConv, g_hItem, CF_TEXT, XTYP_POKE, 2000, nil);

            If (lRet>0) Then
            begin
                log({$I %LINENUM%},'  Client: DDE Poke Success');
            end
            Else
            begin
                log({$I %LINENUM%},'  Client: DDE Poke Failed');
                TranslateError();
            End;
        End;

        DDE_FreeStringHandles();
    end
    Else
    begin
        showmessage('Please enter the required data for the transaction.');
    End;
end;

procedure TForm1.cmdRequestClick(Sender: TObject);
var
  lRet : Long;
  lSize : Long;
  //sBuffer : String;
  sBuffer: array of Byte;
  sFinal : AnsiString;
  txtService_:string;
  txtTopic_:string;
  txtItem_:string;
begin
  txtService_:=txtService.Text;
  txtTopic_:=txtTopic.Text;
  txtItem_:= txtItem.Text;

  If (CheckData('Request')) Then
  begin

    DDE_CreateStringHandles(txtService_, txtTopic_, txtItem_);

    log({$I %LINENUM%},' Client: Recheck string handles -------------------------');
    Length_ := DdeQueryString(g_lInstID, g_hService, Buffer, SizeOf(Buffer), CP_WINANSI);
    if Length_ > 0 then
    begin
      // ResultString now contains the string value
      ResultString := string(Buffer);
      log({$I %LINENUM%},' Client: ResultString g_hszAppName: '+ResultString);
    end;

    Length_ := DdeQueryString(g_lInstID, g_hTopic, Buffer, SizeOf(Buffer), CP_WINANSI);
    if Length_ > 0 then
    begin
      // ResultString now contains the string value
      ResultString := string(Buffer);
      log({$I %LINENUM%},' Client: ResultString g_hszTopicName: '+ResultString);
    end;

    Length_ := DdeQueryString(g_lInstID, g_hItem, Buffer, SizeOf(Buffer), CP_WINANSI);
    if Length_ > 0 then
    begin
      // ResultString now contains the string value
      ResultString := string(Buffer);
      log({$I %LINENUM%},' Client: ResultString g_hszItemName: '+ResultString);
    end;

    // Open the conversation.
    If (g_hDDEConv = 0) Then
    begin
      log({$I %LINENUM%},' Client: g_lInstID: '+ g_lInstID.ToString);
      g_hDDEConv := DDE_Connect();
    End;

    If (g_hDDEConv>0) Then
    begin
      // Perform the transaction request.
      lRet := DdeClientTransaction(nil, 0, g_hDDEConv, g_hItem, CF_TEXT, XTYP_REQUEST, 2000, nil);

      If (lRet>0) Then
      begin
        log({$I %LINENUM%},' Client: (DdeClientTransaction) DDE Request Success.');

        // Grab the data from the DDE object create during the transaction. The DDE object
        // is part of the DDE subsystem memory. Once we get what we want we need to free
        // the object. Check the Microsoft Platform SDK for more information on freeing
        // DDE global memory.

        // The first call returns the size of the of the string. For some reason there's
        // always an extra 3 bytes attached to the end of the string. That's why I have a magic
        // number.
        lSize := DdeGetData(lRet, nil, 0, 0);
        log({$I %LINENUM%},' Client: lSize: ' + lSize.ToString);

        // Allocate a buffer for the return data.
        //sBuffer := StringOfChar(chr(0), lSize); //sBuffer := String$(lSize, 0);
        SetLength(sBuffer, lSize);
        log({$I %LINENUM%},' Client: Length(sBuffer): ' + Length(sBuffer).ToString);

        // Grab the data.
        lSize := DdeGetData(lRet, @sBuffer[0], Length(sBuffer), 0);
        log({$I %LINENUM%},' lSize: ' + lSize.ToString);

        SetString(sFinal, PAnsiChar(@sBuffer[0]), Length(sBuffer));
        Label1.caption := 'DDE data: '+string(sFinal);
        log({$I %LINENUM%},' Client: sFinal: '+sFinal);

        // Free the DDE subsystem resources.
        DdeFreeDataHandle (lRet);
      end
      Else
      begin
        log({$I %LINENUM%},' Client: (DdeClientTransaction) DDE Request Failed');
        TranslateError();
      End;
    End;
    DDE_FreeStringHandles();
  end
  Else
  begin
    showmessage('Client: Please enter the required data for the transaction.');
  End;
end;

procedure TForm1.cmdStartAdvClick(Sender: TObject);
var
  lRet : Long;
  lTransVal : Long;
  txtService_:string;
  txtTopic_:string;
begin
  txtService_:=txtService.Text;
  txtTopic_:=txtTopic.Text;
  DDE_CreateStringHandles(txtService_, txtTopic_, txtItem.Text);

    // Open the conversation.
    If (g_hDDEConv = 0) Then
    begin
        g_hDDEConv := DDE_Connect();
    End;

    If g_hDDEConv>0 Then
    begin
        // Perform the transaction.
        lRet := DdeClientTransaction(nil, 0, g_hDDEConv, g_hItem, CF_TEXT, XTYP_ADVSTART, 2000, @lTransVal);

        If (lRet>0) Then
        begin
            log({$I %LINENUM%},' Client: DDE Advise Start Success.');

            // Enable the Advise Stop button and disable the Advise Start button.
            cmdStopAdv.Enabled := True;
            cmdStartAdv.Enabled := False;
        end
        Else
        begin
            log({$I %LINENUM%},' Client: DDE Advise Start Failure.');

        End;

    End;

    DDE_FreeStringHandles();
end;

procedure TForm1.cmdStopAdvClick(Sender: TObject);
var
  lRet : Long;
  lTransVal : Long;
  txtService_:string;
  txtTopic_:string;
begin
  txtService_:=txtService.Text;
  txtTopic_:=txtTopic.Text;
  DDE_CreateStringHandles(txtService_, txtTopic_, txtItem.Text);

    If (g_hDDEConv>0) Then
    begin
        lRet := DdeClientTransaction(nil, 0, g_hDDEConv, g_hItem, CF_TEXT, XTYP_ADVSTOP, 2000, @lTransVal);

        If (lRet>0) Then
        begin
            log({$I %LINENUM%},' Client: DDE Advise Stop Success.');

            // Disable the Advise Stop button.
            cmdStopAdv.Enabled := False;
            cmdStartAdv.Enabled := True;
        end

        Else
        begin
            log({$I %LINENUM%},' Client: DDE Advise Stop Failure.');

        End;

    End;

    DDE_FreeStringHandles();
end;

procedure TForm1.cmdUninitializeClick(Sender: TObject);
begin

  If (g_hDDEConv <> 0) Then
  begin
    SendDebug('Make sure we don''t have any open connections');
    DDE_Disconnect();
  End;

  // Tear down the initialized instance.
  If (g_lInstID>0) Then
  begin
    If DdeUninitialize(g_lInstID) Then
    begin
      log({$I %LINENUM%},' Client: DDE Uninitialize Success: '+ IntToHex(DdeInitializeResultCode_VB6, 8));
      log({$I %LINENUM%},' Client: g_lInstID: '+ g_lInstID.ToString);
    end
    Else
    begin
      log({$I %LINENUM%},' Client: DDE Uninitialize Failure. '+ IntToHex(DdeInitializeResultCode_VB6, 8));
      log({$I %LINENUM%},' Client: g_lInstID: '+ g_lInstID.ToString);
      TranslateError();
    End;

    g_lInstID := 0;
  End;

  SendDebug('Client: -------------------- End DDE Test ------------------------');

  // Disable the command buttons and the text boxes.
  cboItem.Enabled:=false;
  //txtValue.Enabled:=false;
  cmdExecute.Enabled:=false;
  cmdStartAdv.Enabled:=false;
  cmdStopAdv.Enabled:=false;
  cmdRequest.Enabled:=false;
  cmdPoke.Enabled:=false;
  cmdUninitialize.Enabled:=false;
  cmdClear.Enabled:=false;

  cmdInitialize.Enabled := True;

end;

procedure TForm1.cboItemEditingDone(Sender: TObject);
begin
  if cboItem.Text = '<None>' then
  begin
    cmdExecute.Enabled := True;
    cmdPoke.Enabled := False;
    cmdRequest.Enabled := False;
    cmdStopAdv.Enabled := False;
    cmdStartAdv.Enabled := False;
  end;
  if cboItem.Text = 'Advise' then
  begin
    If (bAdvise) Then
      cmdStopAdv.Enabled := True
    Else
      cmdStartAdv.Enabled := True;

    cmdExecute.Enabled := False;
    cmdPoke.Enabled := False;
    cmdRequest.Enabled := False;
  end;
  if cboItem.Text = 'Poke' then
  begin
    cmdExecute.Enabled := False;
    cmdPoke.Enabled := True;
    cmdRequest.Enabled := False;
    cmdStopAdv.Enabled := False;
    cmdStartAdv.Enabled := False;
  end;
  if cboItem.Text = 'Request' then
  begin
    cmdExecute.Enabled := False;
    cmdPoke.Enabled := False;
    cmdRequest.Enabled := True;
    cmdStopAdv.Enabled := False;
    cmdStartAdv.Enabled := False;
  end;
end;

end.

