unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Windows, Messages, dbugintf;

type

  { TForm1 }

  TForm1 = class(TForm)
    cmdDdeGetData: TButton;
    cmdConnect: TButton;
    cmdMeasureSizeString: TButton;
    cmdMeasureSizeArrayOfByte: TButton;
    cmdDdeInitialize: TButton;
    cmdDdeCreateStringHandle: TButton;
    cmdMeasureSizeArrayOfAnsiChar: TButton;
    cmdUninitialize: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    txtService1: TEdit;
    txtTopic1: TEdit;
    txtItem1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure cmdConnectClick(Sender: TObject);
    procedure cmdDdeCreateStringHandleClick(Sender: TObject);
    procedure cmdDdeGetDataClick(Sender: TObject);
    procedure cmdDdeInitializeClick(Sender: TObject);
    procedure cmdMeasureSizeArrayOfAnsiCharClick(Sender: TObject);
    procedure cmdMeasureSizeArrayOfByteClick(Sender: TObject);
    procedure cmdMeasureSizeStringClick(Sender: TObject);
    procedure cmdUninitializeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;
const
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
  Form1: TForm1;
  InstId: DWORD;
  DdeInitializeResultCode: UINT;
  g_hszAppName, g_hszTopicName, g_hszItemName: HSZ;
  hConv_: HCONV;
  hTranData: HDDEDATA;
implementation

{$R *.lfm}

{ TForm1 }

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

procedure log(LINENUM_: integer; message_: string);
begin
  SendDebug(LINENUM_.ToString+message_);
end;

procedure log2(LINENUM_: integer; message_: string);
begin
  Form1.Memo1.Append(LINENUM_.ToString+message_);
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
      log({$I %LINENUM%},': XTYP_ADVDATA');
      lSize := DdeGetData(hData, nil, 0, 0);
      log({$I %LINENUM%},' lSize: '+lSize.ToString);
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
      log({$I %LINENUM%},': XTYP_ADVSTART');
    end;
    if (uType = XTYP_ADVSTOP) then
    begin
      log({$I %LINENUM%},': XTYP_ADVSTOP');
    end;
    if (uType = XTYP_CONNECT) then
    begin
      log({$I %LINENUM%},': XTYP_CONNECT');
      Result := 1;
    end;
    if (uType = XTYP_CONNECT_CONFIRM) then
    begin
      log({$I %LINENUM%},': XTYP_CONNECT_CONFIRM');
    end;
    if (uType = XTYP_DISCONNECT) then
    begin
      log({$I %LINENUM%},': XTYP_DISCONNECT');
    end;
    if (uType = XTYP_ERROR) then
    begin
      log({$I %LINENUM%},': XTYP_ERROR');
    end;
    if (uType = XTYP_EXECUTE) then
    begin
      log({$I %LINENUM%},': XTYP_EXECUTE');
    end;
    if (uType = XTYP_MASK) then
    begin
      log({$I %LINENUM%},': XTYP_MASK');
    end;
    if form1.CheckBox2.Checked then
    if (uType = XTYP_MONITOR) then
    begin
      log({$I %LINENUM%},': XTYP_MONITOR');
    end;
    if (uType = XTYP_POKE) then
    begin
      log({$I %LINENUM%},': XTYP_POKE');

      // Must return DDE_FACK to tell the client the server accepted it
      Result := DDE_FACK;

    end;
    if (uType = XTYP_REGISTER) then
    begin
      log({$I %LINENUM%},': XTYP_REGISTER');
    end;
    if (uType = XTYP_REQUEST) then
    begin
      log({$I %LINENUM%},': XTYP_REQUEST');
    end;
    if (uType = XTYP_SHIFT) then
    begin
      log({$I %LINENUM%},': XTYP_SHIFT');
    end;
    if (uType = XTYP_UNREGISTER) then
    begin
      log({$I %LINENUM%},': XTYP_UNREGISTER');
    end;
    if (uType = XTYP_WILDCONNECT) then
    begin
      log({$I %LINENUM%},': XTYP_WILDCONNECT');
      //DdeCreateDataHandle(InstId, nil, 2 * sizeof(HSZPAIR),0,0,0,0);
    end;
    if (uType = XTYP_XACT_COMPLETE) then   {DDE Client receiving asynchronous request results }
    begin
      // Data contains the result of the completed transaction
      log({$I %LINENUM%},': XTYP_XACT_COMPLETE');
      // Must return DDE_FACK to acknowledge success
      Result := DDE_FACK;
    end;
  end;
end;

procedure TForm1.cmdDdeCreateStringHandleClick(Sender: TObject);
begin
  if (DdeInitializeResultCode = DMLERR_NO_ERROR) and (InstId>0) then
  begin
    g_hszAppName := DdeCreateStringHandle(InstId, PAnsiChar(txtService1.Text), CP_WINANSI);
    g_hszTopicName := DdeCreateStringHandle(InstId, PAnsiChar(txtTopic1.Text), CP_WINANSI);
    g_hszItemName := DdeCreateStringHandle(InstId, PAnsiChar(txtItem1.Text), CP_WINANSI);
    log({$I %LINENUM%},' DdeCreateStringHandle Success  g_hszAppName: '+IntToHex(g_hszAppName, 8));
  end
  else
  begin
    log({$I %LINENUM%},' DDE Not Initialize  DdeInitializeResultCode: '+ DdeInitializeResultCode.ToString);
    log({$I %LINENUM%},' DDE Not Initialize  InstId: '+ IntToHex(InstId, 8));
  end;

end;

procedure TForm1.cmdDdeGetDataClick(Sender: TObject);
var
  DataSize: DWORD;
  AnsiStr: AnsiString;
begin
  if hConv_ = 0 then
  begin
    log({$I %LINENUM%},' DDE Not Connect hConv_: '+ IntToHex(hConv_, 8));
    exit
  end
  else
    begin
      log({$I %LINENUM%},' Send the request transaction ---------------------');
      hTranData := DdeClientTransaction(
      nil,               // No outbound data
      0,                 // Data size is 0
      hConv_,             // Active conversation handle
      g_hszItemName,           // The item handle we want (e.g., 'R1C1' for Excel)
      CF_TEXT,           // Request data as standard text
      XTYP_REQUEST,      // Transaction type
      5000,              // 5-second timeout
      nil                // Ignore result flag
      );

      if hTranData > 0 then
      begin
        log({$I %LINENUM%},' DdeClientTransaction Request Success hTranData: ' + IntToHex(hTranData, 8));
      end
      else
      begin
        log({$I %LINENUM%},' DdeClientTransaction Request Failed hTranData: ' + IntToHex(hTranData, 8));
        TranslateError();
        exit;
      end;
    end;

  if hTranData > 0 then
  begin
    AnsiStr:='';
    log({$I %LINENUM%},' DdeGetData---------------------');

    //Get target DDE size
    DataSize := DdeGetData(hTranData, nil, 0, 0);
    log({$I %LINENUM%},' DataSize: ' + DataSize.ToString);

    if DataSize > 0 then
    begin
      //Allocate/Resize local memory buffer
      SetLength(AnsiStr, DataSize);
      //Fetch the actual data into our buffer
      DataSize := DdeGetData(hTranData, PByte(PAnsiChar(AnsiStr)), Length(AnsiStr), 0);
      log({$I %LINENUM%},' DataSize: ' + DataSize.ToString);
      log({$I %LINENUM%},' Length(AnsiStr): ' + Length(AnsiStr).ToString);

      Label1.Caption:='DDE data: '+string(PAnsiChar(AnsiStr));
    end
    else
    begin
      Label1.Caption:='DDE data: '
    end;
  end
  else
  begin
    log({$I %LINENUM%},' No ClientTransaction hTranData: ' + IntToHex(hTranData, 8));
  end;
end;

procedure TForm1.cmdConnectClick(Sender: TObject);
begin

  If (InstId>0) Then
  begin
    log({$I %LINENUM%},' Open the conversation/connect ----------------');
    hConv_ := DdeConnect(InstId, g_hszAppName, g_hszTopicName, nil);
    if hConv_ > 0 then
    begin
      log({$I %LINENUM%},' Connected Success hConv: '+IntToHex(hConv_, 8));
    end
    else
    begin
      log({$I %LINENUM%},' Connect failed hConv: '+IntToHex(hConv_, 8));
      TranslateError();
    end;
  end
  else
  begin
      log({$I %LINENUM%},' DDE Not Initialize  InstId: '+ IntToHex(InstId, 8));
  end;

end;

procedure TForm1.cmdDdeInitializeClick(Sender: TObject);
begin
  if (InstId=0) then
  begin
    DdeInitializeResultCode := DdeInitialize
    (
    @InstId,
    @DdeCallback,
    APPCLASS_STANDARD or APPCMD_CLIENTONLY,     //APPCLASS_STANDARD APPCMD_CLIENTONLY  APPCMD_TARGETONLY  CBF_FAIL_ALLSVRXACTIONS
    0
    );
    if (DdeInitializeResultCode = DMLERR_NO_ERROR) and (InstId>0) then
    begin
      log({$I %LINENUM%},' DDE Initialize Success  InstId: '+ IntToHex(InstId, 8));
    end
    else
    begin
      log({$I %LINENUM%},' DDE Initialize Failure  DdeInitializeResultCode: '+ DdeInitializeResultCode.ToString);
      TranslateError();
    end ;
  end
  else
  begin
    log2({$I %LINENUM%},' DDE already initialize  InstId: '+ IntToHex(InstId, 8));
  end;
end;

procedure TForm1.cmdMeasureSizeArrayOfAnsiCharClick(Sender: TObject);
var
  DataSize: DWORD;
  Buffer: array of AnsiChar;
  AnsiStr: AnsiString;

begin
  if hConv_ = 0 then
  begin
    log2({$I %LINENUM%},' DDE Not Connect hConv_: '+ IntToHex(hConv_, 8));
    exit
  end
  else
  begin
    log2({$I %LINENUM%},' Send the request transaction ---------------------');
    hTranData := DdeClientTransaction(
    nil,               // No outbound data
    0,                 // Data size is 0
    hConv_,             // Active conversation handle
    g_hszItemName,           // The item handle we want (e.g., 'R1C1' for Excel)
    CF_TEXT,           // Request data as standard text
    XTYP_REQUEST,      // Transaction type
    5000,              // 5-second timeout
    nil                // Ignore result flag
    );

    if hTranData > 0 then
    begin
      log2({$I %LINENUM%},' DdeClientTransaction Request Success hTranData: ' + IntToHex(hTranData, 8));
    end
    else
    begin
      log2({$I %LINENUM%},' DdeClientTransaction Request Failed hTranData: ' + IntToHex(hTranData, 8));
      TranslateError();
      exit;
    end;
  end;

  if hTranData > 0 then
  begin
    log2({$I %LINENUM%},' Measure Size Array Of AnsiChar -------------------------');
    DataSize:=40;
    log2({$I %LINENUM%},' DataSize: '+DataSize.ToString);
    SetLength(Buffer, DataSize);
    log2({$I %LINENUM%},' Length(Buffer): '+Length(Buffer).ToString+'  OK');
    log2({$I %LINENUM%},' SizeOf(Buffer): '+SizeOf(Buffer).ToString+'  Wrong!');
    log2({$I %LINENUM%},' SizeOf use for a static array');

    log2({$I %LINENUM%},' Measure Size Of DdeClientTransaction hTranData -------------------------');
    DataSize := DdeGetData(hTranData, nil, 0, 0);
    log2({$I %LINENUM%},' DdeGetData DataSize: ' + DataSize.ToString);

    if DataSize > 0 then
    begin
      //FillChar(Buffer, Length(Buffer) * SizeOf(AnsiChar), 0);  //not work with FPC
      SetLength(Buffer, 0); // Resets all elements to 0
      SetLength(Buffer, DataSize);
      log2({$I %LINENUM%},' Length(Buffer): '+Length(Buffer).ToString);
      //Fetch the actual data into our buffer
      DataSize := DdeGetData(hTranData, @Buffer[0], Length(Buffer), 0);
      log2({$I %LINENUM%},' DdeGetData DataSize: '+DataSize.ToString);
      log2({$I %LINENUM%},' Length(Buffer): '+Length(Buffer).ToString);

      SetString(AnsiStr, PAnsiChar(@Buffer[0]), Length(Buffer));
      log2({$I %LINENUM%},' AnsiStr: ' + string(AnsiStr));
      Label1.Caption:='DDE data: '+string(AnsiStr);
    end
    else
    begin
      Label1.Caption:='DDE data: '
    end;
  end
  else
  begin
    log2({$I %LINENUM%},' DdeClientTransaction Failure hTranData: ' + IntToHex(hTranData, 8));
    TranslateError();
  end;

  SetLength(Buffer, 0); // Free/Clean up memory

end;

procedure TForm1.cmdMeasureSizeArrayOfByteClick(Sender: TObject);
var
  DataSize: DWORD;
  Buffer: array of Byte;
  AnsiStr: AnsiString;
begin
  if hConv_ = 0 then
  begin
    log2({$I %LINENUM%},' DDE Not Connect hConv_: '+ IntToHex(hConv_, 8));
    exit
  end
  else
  begin
    log2({$I %LINENUM%},' Send the request transaction ---------------------');
    hTranData := DdeClientTransaction(
    nil,               // No outbound data
    0,                 // Data size is 0
    hConv_,             // Active conversation handle
    g_hszItemName,           // The item handle we want (e.g., 'R1C1' for Excel)
    CF_TEXT,           // Request data as standard text
    XTYP_REQUEST,      // Transaction type
    5000,              // 5-second timeout
    nil                // Ignore result flag
    );

    if hTranData > 0 then
    begin
      log2({$I %LINENUM%},' DdeClientTransaction Request Success hTranData: ' + IntToHex(hTranData, 8));
    end
    else
    begin
      log2({$I %LINENUM%},' DdeClientTransaction Request Failed hTranData: ' + IntToHex(hTranData, 8));
      TranslateError();
      exit;
    end;
  end;

  if hTranData > 0 then
  begin
    log2({$I %LINENUM%},' Measure Size Array Of Byte -------------------------');
    DataSize:=40;
    log2({$I %LINENUM%},' DataSize: '+DataSize.ToString);
    SetLength(Buffer, DataSize);
    log2({$I %LINENUM%},' Length(Buffer): '+Length(Buffer).ToString+'  OK');
    log2({$I %LINENUM%},' SizeOf(Buffer): '+SizeOf(Buffer).ToString+'  Wrong!');
    log2({$I %LINENUM%},' SizeOf use for a static array');

    log2({$I %LINENUM%},' Measure Size Of DdeClientTransaction hTranData -------------------------');
    DataSize := DdeGetData(hTranData, nil, 0, 0);
    log2({$I %LINENUM%},' DdeGetData DataSize: ' + DataSize.ToString);

    if DataSize > 0 then
    begin
      Buffer:= Default(TByteArray); // Resets all elements to 0
      SetLength(Buffer, DataSize);
      log2({$I %LINENUM%},' Length(Buffer): '+Length(Buffer).ToString);
      //Fetch the actual data into our buffer
      DataSize := DdeGetData(hTranData, @Buffer[0], Length(Buffer), 0);
      log2({$I %LINENUM%},' DdeGetData DataSize: '+DataSize.ToString);
      log2({$I %LINENUM%},' Length(Buffer): '+Length(Buffer).ToString);

      SetString(AnsiStr, PAnsiChar(@Buffer[0]), Length(Buffer));
      log2({$I %LINENUM%},' AnsiStr: ' + string(AnsiStr));
      Label1.Caption:='DDE data: '+string(AnsiStr);
    end
    else
    begin
      Label1.Caption:='DDE data: '
    end;
  end
  else
  begin
    log2({$I %LINENUM%},' DdeClientTransaction Failure hTranData: ' + IntToHex(hTranData, 8));
    TranslateError();
  end;

  SetLength(Buffer, 0); // Free/Clean up memory
end;

procedure TForm1.cmdMeasureSizeStringClick(Sender: TObject);
var
  DataSize: DWORD;
  AnsiStr: AnsiString;
begin
  if hConv_ = 0 then
  begin
    log2({$I %LINENUM%},' DDE Not Connect hConv_: '+ IntToHex(hConv_, 8));
    exit
  end
  else
  begin
    log2({$I %LINENUM%},' Send the request transaction ---------------------');
    hTranData := DdeClientTransaction(
    nil,               // No outbound data
    0,                 // Data size is 0
    hConv_,             // Active conversation handle
    g_hszItemName,           // The item handle we want (e.g., 'R1C1' for Excel)
    CF_TEXT,           // Request data as standard text
    XTYP_REQUEST,      // Transaction type
    5000,              // 5-second timeout
    nil                // Ignore result flag
    );

    if hTranData > 0 then
    begin
      log2({$I %LINENUM%},' DdeClientTransaction Request Success hTranData: ' + IntToHex(hTranData, 8));
    end
    else
    begin
      log2({$I %LINENUM%},' DdeClientTransaction Request Failed hTranData: ' + IntToHex(hTranData, 8));
      TranslateError();
      exit;
    end;
  end;

  if hTranData > 0 then
  begin
    AnsiStr:='';
    log2({$I %LINENUM%},' Measure Size Array Of AnsiChar -------------------------');
    DataSize:=40;
    log2({$I %LINENUM%},' Length_: '+DataSize.ToString);
    SetLength(AnsiStr, DataSize);
    log2({$I %LINENUM%},' Length(AnsiStr): '+Length(AnsiStr).ToString+'  OK');
    log2({$I %LINENUM%},' SizeOf(AnsiStr): '+SizeOf(AnsiStr).ToString+'  Wrong!');

    log2({$I %LINENUM%},' Measure Size Of DdeClientTransaction hTranData -------------------------');
    DataSize := DdeGetData(hTranData, nil, 0, 0);
    log2({$I %LINENUM%},' DdeGetData DataSize: ' + DataSize.ToString);

    if DataSize > 0 then
    begin
      //Allocate/Resize local memory buffer
      SetLength(AnsiStr, DataSize);

      //Fetch the actual data into our buffer
      DataSize := DdeGetData(hTranData, PByte(PAnsiChar(AnsiStr)), Length(AnsiStr), 0);
      log2({$I %LINENUM%},' DdeGetData DataSize: ' + DataSize.ToString);
      log2({$I %LINENUM%},' Length(AnsiStr): ' + Length(AnsiStr).ToString);
      log2({$I %LINENUM%},' AnsiStr: ' + string(PAnsiChar(AnsiStr)));
      Label1.Caption:='DDE data: '+string(PAnsiChar(AnsiStr));
    end
    else
    begin
      Label1.Caption:='DDE data: '
    end;
  end
  else
  begin
    log2({$I %LINENUM%},' DdeClientTransaction Failure hTranData: ' + IntToHex(hTranData, 8));
    TranslateError();
  end;

  SetLength(AnsiStr, 0);  // Free/Clean up memory
end;

procedure TForm1.cmdUninitializeClick(Sender: TObject);
begin
  if hConv_ > 0 then
  begin
    If DdeDisconnect(hConv_) Then
    begin
      log({$I %LINENUM%},' DDE Disconnect Success.  hConv_: '+ IntToHex(hConv_, 8));
    end
    Else
    begin
      log({$I %LINENUM%},' DDE Disconnect Failure.  hConv_: '+ IntToHex(hConv_, 8));
      TranslateError();
    End;
    hConv_ := 0;
  end
  else
  begin
    log({$I %LINENUM%},' DDE Not Connect hConv_: '+ IntToHex(hConv_, 8));
  end;

  If (InstId>0) Then
  begin
    log({$I %LINENUM%},' Dde Free all String Handle');
    DdeFreeStringHandle(InstId, g_hszAppName);
    DdeFreeStringHandle(InstId, g_hszTopicName);
    DdeFreeStringHandle(InstId, g_hszItemName);

    If DdeUninitialize(InstId) Then
    begin
      log({$I %LINENUM%},' DDE Uninitialize Success: '+ IntToHex(DdeInitializeResultCode, 8));
      log({$I %LINENUM%},' InstId: '+ InstId.ToString);
    end
    Else
    begin
      log({$I %LINENUM%},' DDE Uninitialize Failure. '+ IntToHex(DdeInitializeResultCode, 8));
      log({$I %LINENUM%},' InstId: '+ IntToHex(hConv_, 8));
      TranslateError();
    End;

    InstId := 0;
  End
  else
  begin
    log({$I %LINENUM%},' DDE Not Initialize  InstId: '+ IntToHex(InstId, 8));
  end;

  SendDebug('-------------------- End DDE Test ------------------------');


end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InstId:=0;
  hConv_:=0;
  hTranData:=0;
end;

end.

