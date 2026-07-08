unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Windows, Messages, dbugintf, StrUtils, DDE_Call_Back;

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
    procedure CheckBox1EditingDone(Sender: TObject);
    procedure CheckBox2EditingDone(Sender: TObject);
    procedure cmdAdviseClick(Sender: TObject);
    procedure cmdCheckConversationClick(Sender: TObject);
    procedure cmdCreateServiceNameClick(Sender: TObject);
    procedure cmdDdeCreateStringHandleClick(Sender: TObject);
    procedure cmdDdeInitializeClick(Sender: TObject);
    procedure cmdDisconnectConversationClick(Sender: TObject);
    procedure cmdMeasureSizeStringClick(Sender: TObject);
    procedure cmdUninitializeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure txtAdviseEditingDone(Sender: TObject);
    procedure txtItemEditingDone(Sender: TObject);
    procedure txtServiceEditingDone(Sender: TObject);
    procedure txtTopicEditingDone(Sender: TObject);
    procedure txtValueEditingDone(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  InstId:=0;
  hConv_:=0;
  hDdeServiceName:=0;

  new(DDE_data);
  DDE_data^:=Label1;

  New(Server_data);
  Server_data^:=txtValue;

  txtService_:=txtService.Text;
  txtTopic_:=txtTopic.Text;
  txtItem_:=txtItem.Text;
  txtAdvise_:=txtAdvise.Text;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Dispose(DDE_data);
  if DDE_data <> nil then DDE_data^:=nil;   //Assigned(Ted)  //Assigned(MyPointer)

  Dispose(Server_data);
  if Server_data <> nil then Server_data^:=nil;   //Assigned(Ted)  //Assigned(MyPointer)
end;


procedure TForm1.txtAdviseEditingDone(Sender: TObject);
begin
  txtAdvise_:=txtAdvise.Text;
end;

procedure TForm1.txtItemEditingDone(Sender: TObject);
begin
  txtItem_:=txtItem.Text;
end;

procedure TForm1.txtServiceEditingDone(Sender: TObject);
begin
  txtService_:=txtService.Text;
end;

procedure TForm1.txtTopicEditingDone(Sender: TObject);
begin
  txtTopic_:=txtTopic.Text;
end;

procedure TForm1.txtValueEditingDone(Sender: TObject);
begin

end;

procedure TForm1.cmdAdviseClick(Sender: TObject);
begin
  // We have to initiate a DDEPostAdvise() in order to let all interested clients
  // know that something has changed.
  If (DdePostAdvise(InstId, 0, 0)) Then
  begin
    //log({$I %LINENUM%},' DDE Disconnect Success.: '+ IntToHex(DdeInitializeResultCode_VB6, 8));
    log({$I %LINENUM%},' Server: DdePostAdvise() Success.');
  end
  Else
  begin
    log({$I %LINENUM%},' Server: DdePostAdvise() Failed.');
  End;
end;

procedure TForm1.CheckBox1EditingDone(Sender: TObject);
begin
  uFmt_uType_message:=CheckBox1.Checked;
end;

procedure TForm1.CheckBox2EditingDone(Sender: TObject);
begin
  XTYP_MONITOR_message:=CheckBox2.Checked;
end;

procedure TForm1.cmdCheckConversationClick(Sender: TObject);
begin

  log({$I %LINENUM%},' Server: Open the conversation/connect ----------------');
    hConv_ := DdeConnect(InstId, g_hszAppName, g_hszTopicName, nil);
    if hConv_ > 0 then
    begin
      log({$I %LINENUM%},' Server: New conversation/connect  hConv_: '+ IntToHex(hConv_, 8));
    end
    else
    begin
      log({$I %LINENUM%},' Server: No Dde Server  hConv_: '+ IntToHex(hConv_, 8));
      TranslateError();
    end;
end;

procedure TForm1.cmdCreateServiceNameClick(Sender: TObject);
begin
  if (hConv_ > 0) then
  begin
    log({$I %LINENUM%},' Server: Dde Server already have hConv_: '+ IntToHex(hConv_, 8));
    exit;
  end;
  if (hDdeServiceName = 0) then
  begin
    hDdeServiceName:=DdeNameService(InstId, g_hszAppName, 0, DNS_REGISTER);
    If (hDdeServiceName>0) Then
    begin
      log({$I %LINENUM%},' Server: DdeNameService Success  hDdeServiceName: '+ IntToHex(hDdeServiceName, 8));
      // Set the server running flag.
      bRunning := True;
    End
    else
    begin
      log({$I %LINENUM%},' Server: DdeNameService Failure  hDdeServiceName: '+ IntToHex(hDdeServiceName, 8));
      TranslateError();
    end;
  end
  else
  begin
    log({$I %LINENUM%},' Server: DdeNameService already create  hDdeServiceName: '+ IntToHex(hDdeServiceName, 8));
  end;
end;

procedure TForm1.cmdDdeCreateStringHandleClick(Sender: TObject);
begin
  g_hszAppName := DdeCreateStringHandle(InstId, PAnsiChar(txtService.Text), CP_WINANSI);
  g_hszTopicName := DdeCreateStringHandle(InstId, PAnsiChar(txtTopic.Text), CP_WINANSI);
  g_hszItemName := DdeCreateStringHandle(InstId, PAnsiChar(txtItem.Text), CP_WINANSI);
  g_hszItemAdvise := DdeCreateStringHandle(InstId, PAnsiChar(txtAdvise.Text), CP_WINANSI);
  g_hszValue := DdeCreateStringHandle(InstId, PAnsiChar(txtValue.Text), CP_WINANSI);

  log({$I %LINENUM%},' Server: DdeCreateStringHandle------------------------');
  log({$I %LINENUM%},' Server: DdeCreateStringHandle  g_hszAppName: '+ IntToHex(g_hszAppName, 8));
  log({$I %LINENUM%},' Server: DdeCreateStringHandle  g_hszTopicName: '+ IntToHex(g_hszTopicName, 8));
  log({$I %LINENUM%},' Server: DdeCreateStringHandle  g_hszItemName: '+ IntToHex(g_hszItemName, 8));
  log({$I %LINENUM%},' Server: DdeCreateStringHandle  g_hszItemAdvise: '+ IntToHex(g_hszItemAdvise, 8));
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
      log({$I %LINENUM%},' Server: DDE Initialize Success  InstId: '+ IntToHex(InstId, 8));
    end
    else
    begin
      log({$I %LINENUM%},' Server: DDE Initialize Failure  DdeInitializeResultCode: '+ DdeInitializeResultCode.ToString);
      TranslateError();
    end ;
  end
  else
  begin
    log({$I %LINENUM%},' Server: DDE already initialize  InstId: '+ IntToHex(InstId, 8));
  end;
end;

procedure TForm1.cmdDisconnectConversationClick(Sender: TObject);
begin
  if hConv_ > 0 then
  begin
    If DdeDisconnect(hConv_) Then
    begin
      log({$I %LINENUM%},' Server: DDE Disconnect Success.  hConv_: '+ IntToHex(hConv_, 8));
    end
    Else
    begin
      log({$I %LINENUM%},' Server: DDE Disconnect Failure.  hConv_: '+ IntToHex(hConv_, 8));
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
    log({$I %LINENUM%},' Server: ResultString s: '+s);
  end
  else
  begin
    log({$I %LINENUM%},' Server: String handle not create');
  end;

  Length_ := DdeQueryString(InstId, g_hszTopicName, nil, 0, CP_WINANSI);
  if Length_ > 0 then
  begin
    SetLength(AnsiStr, 0); // Resets all elements to 0
    SetLength(AnsiStr, Length_+1);
    Length_ := DdeQueryString(InstId, g_hszTopicName, PAnsiChar(AnsiStr), Length(AnsiStr), CP_WINANSI);
    s := string(AnsiStr);
    log({$I %LINENUM%},' Server: ResultString s: '+s);
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
    log({$I %LINENUM%},' Server: ResultString s: '+s);
  end
  else
  begin
    log({$I %LINENUM%},' Server: String handle not create');
  end;

  Length_ := DdeQueryString(InstId, g_hszItemAdvise, nil, 0, CP_WINANSI);
  if Length_ > 0 then
  begin
    SetLength(AnsiStr, 0); // Resets all elements to 0
    SetLength(AnsiStr, Length_+1);
    Length_ := DdeQueryString(InstId, g_hszItemAdvise, PAnsiChar(AnsiStr), Length(AnsiStr), CP_WINANSI);
    s := string(AnsiStr);
    log({$I %LINENUM%},' Server: ResultString s: '+s);
  end
  else
  begin
    log({$I %LINENUM%},' Server: String handle not create');
  end;

  Length_ := DdeQueryString(InstId, g_hszValue, nil, 0, CP_WINANSI);
  if Length_ > 0 then
  begin
    SetLength(AnsiStr, 0); // Resets all elements to 0
    SetLength(AnsiStr, Length_+1);
    Length_ := DdeQueryString(InstId, g_hszValue, PAnsiChar(AnsiStr), Length(AnsiStr), CP_WINANSI);
    s := string(AnsiStr);
    log({$I %LINENUM%},' Server: ResultString s: '+s);
  end
  else
  begin
    log({$I %LINENUM%},' Server: String handle not create');
  end;

  SetLength(AnsiStr, 0);  // Free/Clean up memory
end;

procedure TForm1.cmdUninitializeClick(Sender: TObject);
begin
  if hConv_ > 0 then
  begin
    If DdeDisconnect(hConv_) Then
    begin
      log({$I %LINENUM%},' Server: DDE Disconnect Success.  hConv_: '+ IntToHex(hConv_, 8));
    end
    Else
    begin
      log({$I %LINENUM%},' Server: DDE Disconnect Failure.  hConv_: '+ IntToHex(hConv_, 8));
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
      log({$I %LINENUM%},' Server: DdeNameService DNS_UNREGISTER -------------------------');
    End;
    DdeFreeStringHandle(InstId, g_hszAppName);
    DdeFreeStringHandle(InstId, g_hszTopicName);
    DdeFreeStringHandle(InstId, g_hszItemName);
    DdeFreeStringHandle(InstId, g_hszItemAdvise);
    DdeFreeStringHandle(InstId, g_hszValue);
    log({$I %LINENUM%},' Server: DdeFreeStringHandle -------------------------');

    If DdeUninitialize(InstId) Then
    begin
      log({$I %LINENUM%},' Server: DDE Uninitialize Success: '+ IntToHex(DdeInitializeResultCode, 8));
      log({$I %LINENUM%},' Server: InstId: '+ InstId.ToString);
    end
    Else
    begin
      log({$I %LINENUM%},' Server: DDE Uninitialize Failure. '+ IntToHex(DdeInitializeResultCode, 8));
      log({$I %LINENUM%},' Server: InstId: '+ IntToHex(hConv_, 8));
      TranslateError();
    End;

    InstId := 0;
  End
  else
  begin
    log({$I %LINENUM%},' Server: DDE Not Initialize  InstId: '+ IntToHex(InstId, 8));
  end;


  log({$I %LINENUM%},' Server: DdeUninitialize -------------------------');
end;

end.

