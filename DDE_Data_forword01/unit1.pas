unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Windows, Messages, dbugintf;

type

  { TForm1 }

  TForm1 = class(TForm)
    cmdDdeInitialize: TButton;
    cmdDdeCreateStringHandle: TButton;
    cmdUninitialize: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    txtService1: TEdit;
    txtTopic1: TEdit;
    txtItem1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure cmdDdeCreateStringHandleClick(Sender: TObject);
    procedure cmdDdeInitializeClick(Sender: TObject);
    procedure cmdUninitializeClick(Sender: TObject);
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
   end
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

  end;
end;

procedure TForm1.cmdUninitializeClick(Sender: TObject);
begin

  If (InstId>0) Then
  begin
    If DdeUninitialize(InstId) Then
    begin
      log({$I %LINENUM%},' DDE Uninitialize Success: '+ IntToHex(DdeInitializeResultCode, 8));
      log({$I %LINENUM%},' InstId: '+ InstId.ToString);
    end
    Else
    begin
      log({$I %LINENUM%},' DDE Uninitialize Failure. '+ IntToHex(DdeInitializeResultCode, 8));
      log({$I %LINENUM%},' InstId: '+ InstId.ToString);
      TranslateError();
    End;

    InstId := 0;
  End;

  SendDebug('-------------------- End DDE Test ------------------------');


end;

end.

