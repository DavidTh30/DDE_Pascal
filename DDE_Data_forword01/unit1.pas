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
  i:integer;
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
    i:={$I %LINENUM%};
    SendDebug(i.ToString+': In client callback. uFmt:'+ IntToHex(uFmt, 8) );
    SendDebug(i.ToString+': In client callback. uType:'+ IntToHex(uType, 8));
  end;

  if (uFmt = CF_TEXT) or (uFmt =0) then
  begin
    if (uType = XTYP_ADVDATA) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_ADVDATA');
      lSize := DdeGetData(hData, nil, 0, 0);
      SendDebug(i.ToString+' lSize: '+lSize.ToString);
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
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_ADVSTART');
    end;
    if (uType = XTYP_ADVSTOP) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_ADVSTOP');
    end;
    if (uType = XTYP_CONNECT) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_CONNECT');
      Result := 1;
    end;
    if (uType = XTYP_CONNECT_CONFIRM) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_CONNECT_CONFIRM');
    end;
    if (uType = XTYP_DISCONNECT) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_DISCONNECT');
    end;
    if (uType = XTYP_ERROR) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_ERROR');
    end;
    if (uType = XTYP_EXECUTE) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_EXECUTE');
    end;
    if (uType = XTYP_MASK) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_MASK');
    end;
    if form1.CheckBox2.Checked then
    if (uType = XTYP_MONITOR) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_MONITOR');
    end;
    if (uType = XTYP_POKE) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_POKE');

      // Must return DDE_FACK to tell the client the server accepted it
      Result := DDE_FACK;

    end;
    if (uType = XTYP_REGISTER) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_REGISTER');
    end;
    if (uType = XTYP_REQUEST) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_REQUEST');
    end;
    if (uType = XTYP_SHIFT) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_SHIFT');
    end;
    if (uType = XTYP_UNREGISTER) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_UNREGISTER');
    end;
    if (uType = XTYP_WILDCONNECT) then
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_WILDCONNECT');
      //DdeCreateDataHandle(InstId, nil, 2 * sizeof(HSZPAIR),0,0,0,0);
    end;
    if (uType = XTYP_XACT_COMPLETE) then   {DDE Client receiving asynchronous request results }
    begin
      // Data contains the result of the completed transaction
      i:={$I %LINENUM%};
      SendDebug(i.ToString+': XTYP_XACT_COMPLETE');
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
var
  i:integer;
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
      i:={$I %LINENUM%};
      SendDebug(i.ToString+' DDE Uninitialize Success: '+ IntToHex(DdeInitializeResultCode_VB6, 8));
      SendDebug(i.ToString+' g_lInstID: '+ g_lInstID.ToString);
    end
    Else
    begin
      i:={$I %LINENUM%};
      SendDebug(i.ToString+' DDE Uninitialize Failure. '+ IntToHex(DdeInitializeResultCode_VB6, 8));
      SendDebug(i.ToString+' g_lInstID: '+ g_lInstID.ToString);
      TranslateError();
    End;

    g_lInstID := 0;
  End;

  SendDebug('-------------------- End DDE Test ------------------------');


end;

end.

