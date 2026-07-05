unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Windows, Messages, dbugintf;

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    cmdAdvise: TButton;
    cmdCheckConversation: TButton;
    cmdCreateServiceName: TButton;
    cmdDdeInitialize: TButton;
    cmdDdeCreateStringHandle: TButton;
    cmdMeasureSizeString: TButton;
    cmdDisconnectConversation: TButton;
    cmdUninitialize: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    txtItem: TEdit;
    txtAdvise: TEdit;
    txtValue: TEdit;
    txtService: TEdit;
    txtTopic: TEdit;
    procedure cmdAdviseClick(Sender: TObject);
    procedure cmdCheckConversationClick(Sender: TObject);
    procedure cmdCreateServiceNameClick(Sender: TObject);
    procedure cmdDdeCreateStringHandleClick(Sender: TObject);
    procedure cmdDdeInitializeClick(Sender: TObject);
    procedure cmdDisconnectConversationClick(Sender: TObject);
    procedure cmdMeasureSizeStringClick(Sender: TObject);
    procedure cmdUninitializeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure txtItemChange(Sender: TObject);
  private

  public

  end;

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
  Form1: TForm1;
  bRunning : Boolean;         // Server running flag.
  g_hszAppName, g_hszTopicName, g_hszItemName, g_hszItemAdvise: HSZ;
  InstId: DWORD;
  DdeInitializeResultCode: UINT;
  hConv_: HCONV;
  hDdeServiceName: HDDEDATA;

implementation

{$R *.lfm}

{ TForm1 }
procedure log(LINENUM_: integer; message_: string);
begin
  SendDebug(LINENUM_.ToString+message_);
end;

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
  Buffer: array of AnsiChar;
  AnsiStr: AnsiString;
  Ret : Long;
  ReceivedText: string;
  s:string;
  i:integer;
begin

  Result := DDE_FNOTPROCESSED; //Result := 0;

  // Handle transactions here
  if form1.CheckBox1.Checked then
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
      log({$I %LINENUM%},': Server: XTYP_ADVSTART');
    end;
    if (uType = XTYP_ADVSTOP) then
    begin
      log({$I %LINENUM%},': Server: XTYP_ADVSTOP');
    end;
    if (uType = XTYP_CONNECT) then
    begin
      log({$I %LINENUM%},': Server: XTYP_CONNECT');
      Result := 1;
      Result := DDE_FACK;
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
      SetLength(Buffer, 0); // Resets all elements to 0
      SetLength(Buffer, lSize+1);
      DdeGetData(hData, @Buffer[0], Length(Buffer), 0);
    end;
    if (uType = XTYP_MASK) then
    begin
      log({$I %LINENUM%},': Server: XTYP_MASK');
    end;
    if form1.CheckBox2.Checked then
    if (uType = XTYP_MONITOR) then
    begin
      log({$I %LINENUM%},': Server: XTYP_MONITOR');
    end;
    if (uType = XTYP_POKE) then
    begin
      log({$I %LINENUM%},': Server: XTYP_POKE');

      // Must return DDE_FACK to tell the client the server accepted it
      Result := DDE_FACK;

    end;
    if (uType = XTYP_REGISTER) then
    begin
      log({$I %LINENUM%},': Server: XTYP_REGISTER');
    end;
    if (uType = XTYP_REQUEST) then
    begin
      log({$I %LINENUM%},': Server: XTYP_REQUEST');
      lSize := DdeQueryString(InstId, hsz2, nil, 0, CP_WINANSI);
      log({$I %LINENUM%},' lSize: '+lSize.ToString);
      if lSize > 0 then
      begin
        SetLength(Buffer, 0); // Resets all elements to 0
        SetLength(Buffer, lSize+1);
        log({$I %LINENUM%},' Length(Buffer): '+Length(Buffer).ToString);
        lSize := DdeQueryString(InstId, hsz2, @Buffer[0], Length(Buffer), CP_WINANSI);
        log({$I %LINENUM%},' Length(Buffer): '+Length(Buffer).ToString);
        log({$I %LINENUM%},' Length(Form1.txtItem.Text): '+Length(Form1.txtItem.Text).ToString);
        i:=0;
        if Length(Buffer)>=1 then
        if IntToHex(Ord(Buffer[High(Buffer)])) = '00' then i:=1;
        SetString(AnsiStr, PAnsiChar(@Buffer[0]), Length(Buffer)-i);
        ////////////////////////////////////////////////
        s := string(AnsiStr);
        //log({$I %LINENUM%},' s := string(AnsiStr) Length(s): '+Length(s).ToString);
        //s:=s;
        //log({$I %LINENUM%},' s:=s Length(s): '+Length(s).ToString);
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
        //log({$I %LINENUM%},' Server: s: '+s);
        /////////////////////////////////////////////////
        //log({$I %LINENUM%},' Length(s): '+Length(s).ToString);
        //log({$I %LINENUM%},' Length(Form1.txtItem.Text): '+Length(Form1.txtItem.Text).ToString);
        //////////////////////////////////////////////////
        If (s = Form1.txtItem.Text) Then
        begin
          s:=Form1.txtValue.Text;
          //DdeCreateDataHandle
          //idInst: Instance Identifier ที่ได้จากการเรียก
          //DdeInitializepSrc: พอยน์เตอร์ไปยังบัฟเฟอร์ที่เก็บข้อมูล
          //cb: ขนาดของข้อมูล (เป็นไบต์)
          //cbOff: ระยะออฟเซ็ตจากจุดเริ่มต้นของข้อมูล
          //hszItem: String Handle ที่ระบุชื่อรายการข้อมูล
          //wFmt: รูปแบบข้อมูล (เช่น CF_TEXT)afCmd: ค่าแฟล็ก เช่น
          //HDATA_APPOWNED (ระบุว่าแอปพลิเคชันเป็นเจ้าของออบเจ็กต์นี้)
          Result := DdeCreateDataHandle(InstId, PByte(PAnsiChar(s)), Length(s), 0, hsz2, CF_TEXT, 0);
        end
        else
        begin
          Result := DDE_FNOTPROCESSED;
        end;
      end
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
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InstId:=0;
  hConv_:=0;
  hDdeServiceName:=0;

end;

procedure TForm1.txtItemChange(Sender: TObject);
begin

end;

procedure TForm1.cmdAdviseClick(Sender: TObject);
begin
  // We have to initiate a DDEPostAdvise() in order to let all interested clients
  // know that something has changed.
  If (DdePostAdvise(InstId, 0, 0)) Then
  begin
    //log({$I %LINENUM%},' DDE Disconnect Success.: '+ IntToHex(DdeInitializeResultCode_VB6, 8));
    log({$I %LINENUM%},' DdePostAdvise() Success.');
  end
  Else
  begin
    log({$I %LINENUM%},' DdePostAdvise() Failed.');
  End;
end;

procedure TForm1.cmdCheckConversationClick(Sender: TObject);
begin

  log({$I %LINENUM%},' Open the conversation/connect ----------------');
    hConv_ := DdeConnect(InstId, g_hszAppName, g_hszTopicName, nil);
    if hConv_ > 0 then
    begin
      log({$I %LINENUM%},' New conversation/connect  hConv_: '+ IntToHex(hConv_, 8));
    end
    else
    begin
      log({$I %LINENUM%},' No Dde Server  hConv_: '+ IntToHex(hConv_, 8));
      TranslateError();
    end;
end;

procedure TForm1.cmdCreateServiceNameClick(Sender: TObject);
begin
  if (hConv_ > 0) then
  begin
    log({$I %LINENUM%},' Dde Server already have hConv_: '+ IntToHex(hConv_, 8));
    exit;
  end;
  if (hDdeServiceName = 0) then
  begin
    hDdeServiceName:=DdeNameService(InstId, g_hszAppName, 0, DNS_REGISTER);
    If (hDdeServiceName>0) Then
    begin
      log({$I %LINENUM%},' DdeNameService Success  hDdeServiceName: '+ IntToHex(hDdeServiceName, 8));
      // Set the server running flag.
      bRunning := True;
    End
    else
    begin
      log({$I %LINENUM%},' DdeNameService Failure  hDdeServiceName: '+ IntToHex(hDdeServiceName, 8));
      TranslateError();
    end;
  end
  else
  begin
    log({$I %LINENUM%},' DdeNameService already create  hDdeServiceName: '+ IntToHex(hDdeServiceName, 8));
  end;
end;

procedure TForm1.cmdDdeCreateStringHandleClick(Sender: TObject);
begin
  g_hszAppName := DdeCreateStringHandle(InstId, PAnsiChar(txtService.Text), CP_WINANSI);
  g_hszTopicName := DdeCreateStringHandle(InstId, PAnsiChar(txtTopic.Text), CP_WINANSI);
  g_hszItemName := DdeCreateStringHandle(InstId, PAnsiChar(txtItem.Text), CP_WINANSI);
  g_hszItemAdvise := DdeCreateStringHandle(InstId, PAnsiChar(txtAdvise.Text), CP_WINANSI);

  log({$I %LINENUM%},' DdeCreateStringHandle------------------------');
  log({$I %LINENUM%},' DdeCreateStringHandle  g_hszAppName: '+ IntToHex(g_hszAppName, 8));
  log({$I %LINENUM%},' DdeCreateStringHandle  g_hszTopicName: '+ IntToHex(g_hszTopicName, 8));
  log({$I %LINENUM%},' DdeCreateStringHandle  g_hszItemName: '+ IntToHex(g_hszItemName, 8));
  log({$I %LINENUM%},' DdeCreateStringHandle  g_hszItemAdvise: '+ IntToHex(g_hszItemAdvise, 8));
end;

procedure TForm1.cmdDdeInitializeClick(Sender: TObject);
begin
  if (InstId=0) then
  begin
    DdeInitializeResultCode := DdeInitialize
    (
    @InstId,
    @DdeCallback,
    APPCMD_FILTERINITS,     //APPCLASS_STANDARD APPCMD_CLIENTONLY  APPCMD_TARGETONLY  CBF_FAIL_ALLSVRXACTIONS
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
    log({$I %LINENUM%},' DDE already initialize  InstId: '+ IntToHex(InstId, 8));
  end;
end;

procedure TForm1.cmdDisconnectConversationClick(Sender: TObject);
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
end;

procedure TForm1.cmdMeasureSizeStringClick(Sender: TObject);
var
  Length_: DWORD;
  Buffer: array of AnsiChar;
  AnsiStr: AnsiString;
  s:string;
begin

  Length_ := DdeQueryString(InstId, g_hszAppName, nil, 0, CP_WINANSI);
  if Length_ > 0 then
  begin
    SetLength(AnsiStr, 0); // Resets all elements to 0
    SetLength(AnsiStr, Length_+1);
    Length_ := DdeQueryString(InstId, g_hszAppName, PAnsiChar(AnsiStr), Length(AnsiStr), CP_WINANSI);
    s := string(AnsiStr);
    log({$I %LINENUM%},' ResultString s: '+s);
  end
  else
  begin
    log({$I %LINENUM%},' String handle not create');
  end;

  Length_ := DdeQueryString(InstId, g_hszTopicName, nil, 0, CP_WINANSI);
  if Length_ > 0 then
  begin
    SetLength(AnsiStr, 0); // Resets all elements to 0
    SetLength(AnsiStr, Length_+1);
    Length_ := DdeQueryString(InstId, g_hszTopicName, PAnsiChar(AnsiStr), Length(AnsiStr), CP_WINANSI);
    s := string(AnsiStr);
    log({$I %LINENUM%},' ResultString s: '+s);
  end
  else
  begin
    log({$I %LINENUM%},' String handle not create');
  end;

  Length_ := DdeQueryString(InstId, g_hszItemName, nil, 0, CP_WINANSI);
  if Length_ > 0 then
  begin
    SetLength(AnsiStr, 0); // Resets all elements to 0
    SetLength(AnsiStr, Length_+1);
    Length_ := DdeQueryString(InstId, g_hszItemName, PAnsiChar(AnsiStr), Length(AnsiStr), CP_WINANSI);
    s := string(AnsiStr);
    log({$I %LINENUM%},' ResultString s: '+s);
  end
  else
  begin
    log({$I %LINENUM%},' String handle not create');
  end;

  Length_ := DdeQueryString(InstId, g_hszItemAdvise, nil, 0, CP_WINANSI);
  if Length_ > 0 then
  begin
    SetLength(AnsiStr, 0); // Resets all elements to 0
    SetLength(AnsiStr, Length_+1);
    Length_ := DdeQueryString(InstId, g_hszItemAdvise, PAnsiChar(AnsiStr), Length(AnsiStr), CP_WINANSI);
    s := string(AnsiStr);
    log({$I %LINENUM%},' ResultString s: '+s);
  end
  else
  begin
    log({$I %LINENUM%},' String handle not create');
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
  end;

  If (InstId>0) Then
  begin
    // Unregister the DDE server.
    If bRunning Then
    begin
      DdeNameService(InstId, g_hszAppName, 0, DNS_UNREGISTER);
      hDdeServiceName:=0;
      log({$I %LINENUM%},' DdeNameService DNS_UNREGISTER -------------------------');
    End;
    DdeFreeStringHandle(InstId, g_hszAppName);
    DdeFreeStringHandle(InstId, g_hszTopicName);
    DdeFreeStringHandle(InstId, g_hszItemName);
    DdeFreeStringHandle(InstId, g_hszItemAdvise);
    log({$I %LINENUM%},' DdeFreeStringHandle -------------------------');

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


  log({$I %LINENUM%},' DdeUninitialize -------------------------');
end;

end.

