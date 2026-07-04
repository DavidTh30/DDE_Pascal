 Technical Information Database

TI1177D.txt - DDE: A simple example

Category   :Delphi 1.x
Platform   :All Windows
Product    :

Description:
Q: How can I do DDE under Delphi using API calls ?

A: Its fairly easy to accomplish, following is an example of how to have a
client program talk with a server program.  Both are completely written in
Delphi.  In total there are 2 projects, 3 forms, and 3 units.  This demo
uses DDE ML API methods to handle the DDE requests.

The server must be running before the client will load.  This demo program
shows 3 different ways data can be moved between a client and a server.

1.  The Client can 'POKE' data to the server.
2.  The Server can automaticaly pass data to the Client and the Client
    will update a graph based on the results from the Server.
3. The Server's Data changes, then the Client will make a request to the
   Server for the new data, then update the graph.

                   *****  How to handle the program.  *****

Following are 8 files concatenated together.  Each one has a
{ *** BEGIN CODE FOR FILENAME.EXT *** }  CODE { *** END CODE FOR
FILENAME.EXT *** } take each block of code BETWEEN THE { *** } lines and
place in a file of the corresponding name, then compile and have fun !!!!



{ *** BEGIN CODE FOR DDEMLCLI.DPR *** }
program Ddemlcli;

uses
  Forms,
  Ddemlclu in 'DDEMLCLU.PAS' {Form1};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
{ ***   END CODE FOR DDEMLCLI.DPR *** }


{ *** BEGIN CODE FOR DDEMLCLU.DFM *** }
object Form1: TForm1
  Left = 197
  Top = 95
  Width = 413
  Height = 287
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'DDEML Demo, Client Application'
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'System'
  Font.Style = []
  Menu = MainMenu1
  PixelsPerInch = 96
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 16
  object PaintBox1: TPaintBox
    Left = 0
    Top = 0
    Width = 405
    Height = 241
    Align = alClient
    Color = clWhite
    ParentColor = False
    OnPaint = PaintBox1Paint
  end
  object MainMenu1: TMainMenu
    Top = 208
    object File1: TMenuItem
      Caption = '&File'
      object exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = exit1Click
      end
    end
    object DDE1: TMenuItem
      Caption = '&DDE'
      object RequestUpdate1: TMenuItem
        Caption = '&Request an Update'
        OnClick = RequestUpdate1Click
      end
      object AdviseofChanges1: TMenuItem
        Caption = '&Advise of Changes'
        OnClick = AdviseofChanges1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object PokeSomeData: TMenuItem
        Caption = '&Poke Some Data'
        OnClick = PokeSomeDataClick
      end
    end
  end
end
{ ***   END CODE FOR DDEMLCLU.DFM *** }

{ *** BEGIN CODE FOR DDEMLCLU.PAS *** }
{***************************************************}
{                                                   }
{   Delphi 1.0 DDEML Demonstration Program         }
{   Copyright (c) 1996 by Borland International     }
{                                                   }
{***************************************************}

{ This is a sample application demonstrating the use of the DDEML APIs in
  a client application.  It uses the DataEntry server application that
  is part of this demo in order to maintain a display of the entered data
  as a bar graph.

  You must run the server application first (in DDEMLSRV.PAS), and then
  run this client.  If the server is not running, this application will
  fail trying to connect.

  The interface to the server is defined by the list of names (Service,
  Topic, and Items) in the separate unit called DataEntry (DATAENTR.TPU).
  The server makes the Items available in cf_Text format; they are con-
  verted and stored locally as integers.
}

unit Ddemlclu;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, VBXCtrl, ExtCtrls, DDEML, Menus, StdCtrls;

const
  NumValues = 3;

type

     { Data Structure which constitutes a sample }
  TDataSample = array [1..NumValues] of Integer;
  TDataString = array [0..20] of Char;     { Size of Item as text }

     { Main Form }
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    exit1: TMenuItem;
    DDE1: TMenuItem;
    RequestUpdate1: TMenuItem;
    AdviseofChanges1: TMenuItem;
    PokeSomeData: TMenuItem;
    N1: TMenuItem;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RequestUpdate1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AdviseofChanges1Click(Sender: TObject);
    procedure PokeSomeDataClick(Sender: TObject);

    procedure Request(HConversation: HConv);
    procedure exit1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);

  private
    { Private declarations }
  public
    Inst: Longint;
    CallBackPtr: ^TCallback;
    ServiceHSz : HSz;
    TopicHSz   : HSz;
    ItemHSz    : array [1..NumValues] of HSz;
    ConvHdl    : HConv;

    DataSample : TDataSample;
  end;

var Form1: TForm1;

implementation

const
  DataEntryName : PChar = 'DataEntry';
  DataTopicName : PChar = 'SampledData';
  DataItemNames : array [1..NumValues] of pChar = ('DataItem1',
                                                   'DataItem2',
                                                   'DataItem3');
{$R *.DFM}

{ Local Function: CallBack Procedure for DDEML }

function CallbackProc(CallType, Fmt: Word; Conv: HConv; hsz1, hsz2: HSZ;
  Data: HDDEData; Data1, Data2: Longint): HDDEData; export;
begin
  CallbackProc := 0;    { See if proved otherwise }

  case CallType of
    xtyp_Register:
      begin
        { Nothing ... Just return 0 }
      end;
    xtyp_Unregister:
      begin
        { Nothing ... Just return 0 }
      end;
    xtyp_xAct_Complete:
      begin
        { Nothing ... Just return 0 }
      end;
    xtyp_Request, Xtyp_AdvData:
      begin
        Form1.Request(Conv);
        CallbackProc := dde_FAck;
      end;
    xtyp_Disconnect:
      begin
	ShowMessage('Disconnected!');
        Form1.Close;
      end;
  end;
end;


{ Posts a DDE request to obtain cf_Text data from the server.  Requests
  the data for all fields of the DataSample, and invalidates the window
  to cause the new data to be displayed.  Obtains the data from the
  Server synchronously, using DdeClientTransaction.
}
procedure TForm1.Request(HConversation: HConv);
var
  hDdeTemp : HDDEData;
  DataStr  : TDataString;
  Err, I   : Integer;
begin
  if HConversation <> 0 then begin
    for I := Low(ItemHSz) to High(ItemHSz) do begin
      hDdeTemp := DdeClientTransaction(nil, 0, HConversation, ItemHSz[I],
        cf_Text, xtyp_Request, 0, nil);
      if hDdeTemp <> 0 then  begin
        DdeGetData(hDdeTemp,
DataStr, SizeOf(DataStr), 0);
        Val(DataStr, DataSample[I], Err);
      end; { if }
  end; { for }
 Paintbox1.Refresh;  { Redisplay the Screen }
  end; { if }
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  I : Integer;
{ Constructs an instance of the DDE Client Window.  Constructs the
  window using the inherited constructor, then initializes the instance
  data.
}
begin
  Inst       := 0;      { Must be zero for first call to DdeInitialize }
  CallBackPtr:= nil;    { MakeProcInstance is called in SetupWindow    }
  ConvHdl    := 0;
  ServiceHSz := 0;
  TopicHSz   := 0;
  for I := Low(DataSample) to High(DataSample) do begin
    ItemHSz[I]    := 0;
    DataSample[I] := 0;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
{ Destroys an instance of the Client window.  Frees the DDE string
  handles, and frees the callback proc instance if they exist.  Also
  calls DdeUninitialize to terminate the conversation.  Then calls on
  the ancestral destructor to finish the job.
}
var I : Integer;
begin
  if ServiceHSz <> 0 then
    DdeFreeStringHandle(Inst, ServiceHSz);
  if TopicHSz <> 0 then
    DdeFreeStringHandle(Inst, TopicHSz);
  for I := Low(ItemHSz) to High(ItemHSz) do
    if ItemHSz[I] <> 0 then
      DdeFreeStringHandle(Inst, ItemHSz[I]);

  if Inst <> 0 then
    DdeUninitialize(Inst);   { Ignore the return value }

  if CallBackPtr <> nil then
    FreeProcInstance(CallBackPtr);
end;

procedure TForm1.RequestUpdate1Click(Sender: TObject);
begin
{ Generate a DDE Request in response to the DDE | Request menu selection.}
  Request(ConvHdl);
end;

procedure TForm1.FormShow(Sender: TObject);
{ Completes the initialization of the DDE Server Window.  Performs those
  actions which require a valid window.  Initializes the use of the DDEML.
}
var
  I     : Integer;
  InitOK: Boolean;
begin
  CallBackPtr := MakeProcInstance(
CallBackProc, HInstance);

{ Initialize the DDE and setup the callback function. If server is not
  present, call will fail.
}
  if CallBackPtr <> nil then begin
    if DdeInitialize(Inst, TCallback(CallBackPtr), AppCmd_ClientOnly,
      0) = dmlErr_No_Error then begin
      ServiceHSz:= DdeCreateStringHandle(Inst, DataEntryName, cp_WinAnsi);
      TopicHSz  := DdeCreateStringHandle(Inst, DataTopicName, cp_WinAnsi);
      InitOK := True;
{     for I := Low(DataItemNames) to High(DataItemNames) do begin }
      for I := 1 to NumValues do begin
        ItemHSz[I]:= DdeCreateStringHandle(Inst, DataItemNames[I],
          cp_WinAnsi);
        InitOK := InitOK and (ItemHSz[I] <> 0);
      end;

      if (ServiceHSz <> 0) and (TopicHSz <> 0) and InitOK then begin
        ConvHdl := DdeConnect(Inst, ServiceHSz, TopicHSz, nil);
        if ConvHdl = 0 then begin
	  ShowMessage('Can not start Conversation!');
          Close;
        end
      end
      else begin
        ShowMessage('Can not create Strings!');
        Close;
      end
    end
    else begin
      ShowMessage('Can not Initialie!');
      Close;
    end;
  end;
end;

procedure TForm1.AdviseofChanges1Click(Sender: TObject);
{ Toggles the state of the DDE Advise setting in response to the
  DDE | Advise menu selection.  When this is selected, all three
  Items are set for Advising.
}
var
  I: Integer;
  TransType: Word;
  TempResult: Longint;
begin
  with TMenuITem(Sender) do begin
    Checked := not Checked;
    if Checked then
       TransType:= (xtyp_AdvStart or xtypf_AckReq)
    else
       TransType:= xtyp_AdvStop;
  end; { with }

  for I := Low(ItemHSz) to High(ItemHSz) do
    if DdeClientTransaction(nil, 0, ConvHdl, ItemHSz[I], cf_Text,
        TransType, 1000,
TempResult) = 0 then
      ShowMessage('Can not perform Advise Transaction');

  if TransType and xtyp_AdvStart <> 0 then Request(ConvHdl);
end;

procedure TForm1.PokeSomeDataClick(Sender: TObject);
{ Generates a DDE Poke transaction in response to the DDE | Poke
  menu selection.  Requests a value from the user that will be
  poked into DataItem1 as an illustration of the Poke function.
}
var
   DataStr: pChar;
   S: String;
begin
  S := '0';
  if InputQuery('PokeData', 'Enter Value to Poke', S) then begin
       S := S + #0;
       DataStr :=
S[1];
       DdeClientTransaction(DataStr, StrLen(DataStr) + 1, ConvHdl,
         ItemHSz[1], cf_Text, xtyp_Poke, 1000, nil);
       Request(ConvHdl);
       end;
end;

procedure TForm1.exit1Click(Sender: TObject);
begin
   close;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
{ Repaints the window on request.  Plots a graph of the current sales
  volume.
}
const
   LMarg = 30;    { Left Margin of graph }
var
   I,
   Norm: Integer;
   Wd: Integer;
   Step : Integer;

   ARect: TRect;

begin
  Norm := 0;
  for I := Low(DataSample) to High(DataSample) do begin
    if abs(DataSample[I]) > Norm then
      Norm := abs(DataSample[I]);
    end; { for }

  if Norm = 0 then Norm := 1;   { Just in case we have all zeros }

  with TPaintBox(Sender).Canvas do begin
        { Paint Background }
     Brush.color  := clWhite;
     FillRect(ClipRect);

        { Draw Axis }
     MoveTo(0, ClipRect.Bottom div 2);
     LineTo(ClipRect.Right, ClipRect.Bottom div 2);

     MoveTo(LMarg, 0);
     LineTo(LMarg, ClipRect.Bottom);

        { Print Left MArgin Text }
     TextOut(0,0, IntToStr(Norm));
     TextOut(0, ClipRect.Bottom div 2, '0');
     TextOut(0, ClipRect.Bottom + Font.Height, IntToStr(-Norm));

     TextOut(0, ClipRect.Bottom div 2, '0');
     TextOut(0, ClipRect.Bottom div 2, '0');
     TextOut(0, ClipRect.Bottom div 2, '0');
        { Print X Axis Text }

        { Now draw the bars based on that Normalized value.  Compute the
          width of the bars so that all will fit in the window, and
          compute an inter-bar space that is approximately 20% of the
          width of a bar.
        }
{        SelectObject(PaintDC, CreateSolidBrush(RGB(255, 0, 0)));
        SetBkMode(PaintDC, Transparent);
}
     ARect := ClipRect;
     Wd  := (ARect.Right - LMarg) div NumValues;
     Step := Wd div 5;
     Wd  := Wd - Step;
     with ARect do begin
        Left := LMarg + (Step div 2);
        Top := ClipRect.Bottom div 2;
        end; { with }

        { Display Bars and X-Axis Text }
     For i := Low(DataSample) to High(DataSample) do begin
          with ARect do begin
             Right := Left + Wd;
             Bottom:= Top - Round((Top-5) * (DataSample[I] / Norm));
             end; { with }
             { Fill Bar }
          Brush.color  := clFuchsia;
          FillRect(ARect);
             { Display Text - Horizontal Axis }
          Brush.color  := clWhite;
          TextOut(ARect.Left, ClipRect.Bottom div 2 - Font.Height,
            StrPas(DataItemNames[i]));
          with ARect do
             Left := Left + Wd + Step;
        end; { for }
     end; { with }
end;
end.{ ***   END CODE FOR DDEMLCLU.PAS *** }



{ *** BEGIN CODE FOR DDEMLSVR.DPR *** }
program Ddemlsvr;

uses
  Forms,
  Ddesvru in 'DDESVRU.PAS' {Form1},
  Ddedlg in '\DELPHI\BIN\DDEDLG.PAS' {DataEntry};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDataEntry, DataEntry);
  Application.Run;
end.
{ ***   END CODE FOR DDEMLSVR.DPR *** }

{ *** BEGIN CODE FOR DDESVRU.DFM *** }
object Form1: TForm1
  Left = 712
  Top = 98
  Width = 307
  Height = 162
  Caption = 'DDEML Demo, Serve Application'
  Color = clWhite
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'System'
  Font.Style = []
  Menu = MainMenu1
  PixelsPerInch = 96
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 16
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 99
    Height = 16
    Caption = 'Current Values:'
  end
  object Label2: TLabel
    Left = 16
    Top = 24
    Width = 74
    Height = 16
    Caption = 'Data Item1:'
  end
  object Label3: TLabel
    Left = 16
    Top = 40
    Width = 74
    Height = 16
    Caption = 'Data Item2:'
  end
  object Label4: TLabel
    Left = 16
    Top = 56
    Width = 74
    Height = 16
    Caption = 'Data Item3:'
  end
  object Label5: TLabel
    Left = 0
    Top = 88
    Width = 265
    Height = 16
    Caption = 'Select Data|Enter Data to change values.'
  end
  object Label6: TLabel
    Left = 96
    Top = 24
    Width = 8
    Height = 16
    Caption = '0'
  end
  object Label7: TLabel
    Left = 96
    Top = 40
    Width = 8
    Height = 16
    Caption = '0'
  end
  object Label8: TLabel
    Left = 96
    Top = 56
    Width = 8
    Height = 16
    Caption = '0'
  end
  object MainMenu1: TMainMenu
    Left = 352
    Top = 24
    object File1: TMenuItem
      Caption = '&File'
      object Exit1: TMenuItem
        Caption = '&Exit'
        OnClick = Exit1Click
      end
    end
    object Data1: TMenuItem
      Caption = '&Data'
      object EnterData1: TMenuItem
        Caption = '&Enter Data'
        OnClick = EnterData1Click
      end
      object Clear1: TMenuItem
        Caption = '&Clear'
        OnClick = Clear1Click
      end
    end
  end
end
{ ***   END CODE FOR DDESVRU.DFM *** }

{ *** BEGIN CODE FOR DDESVRU.PAS *** }
{***************************************************}
{                                                   }
{   Delphi 1.0 DDEML Demonstration Program          }
{   Copyright (c) 1996 by Borland International     }
{                                                   }
{***************************************************}

{ This sample application uses the DDEML library in the server side of a
  cooperative application.  This server is a simple data-entry application
  which allows an operator to enter three data items, which are made
  available through DDE to interested clients.

  This server makes its service available under the following names:

       Service: 'DataEntry'
       Topic  : 'SampledData'
       Items  : 'DataItem1', 'DataItem2', 'DataItem3'

  Conceivably, other topics under this service could be defined.  Things
  such as historical data, information about the sampling, and so on
  might make useful topics.

  You must run this server BEFORE running the client (DDEMLCLI.PAS), or
  the client will fail the connection.

  The interface to this server is defined by the list of names (Service,
  Topic, and Items) in the separate unit called DataEntry (DATAENTR.TPU).
  The server makes the Items available in cf_Text format; they can be
  converted and stored locally as integers by the client.
}
unit Ddesvru;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus,

  DDEML,     { DDE APi }
  ShellApi;

const
  NumValues = 3;
  DataItemNames : array [1..NumValues] of PChar = ('DataItem1',
                                                   'DataItem2',
                                                   'DataItem3');
type
  TDataString = array [0..20] of Char;     { Size of Item as text }
  TDataSample = array [1..NumValues] of Integer;


{type
{ Data Structure which constitutes a sample }
{  TDataSample = array [1..NumValues] of Integer;
{  TDataString = array [0..20] of Char;     { Size of Item as text }

const
  DataEntryName: PChar = 'DataEntry';
  DataTopicName: PChar = 'SampledData';

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Data1: TMenuItem;
    EnterData1: TMenuItem;
    Clear1: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure Exit1Click(Sender: TObject);

    function MatchTopicAndService(Topic, Service: HSz): Boolean;
    function MatchTopicAndItem(Topic, Item: HSz): Integer;
    function WildConnect(Topic, Service: HSz; ClipFmt: Word): HDDEData;
    function AcceptPoke(Item: HSz; ClipFmt: Word;
      Data: HDDEData): Boolean;
    function DataRequested(TransType: Word; ItemNum: Integer;
      ClipFmt: Word): HDDEData;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EnterData1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);

  private
    Inst       : Longint;
    CallBack   : TCallback;
    ServiceHSz : HSz;
    TopicHSz   : HSz;
    ItemHSz    : array [1..NumValues] of HSz;
    ConvHdl    : HConv;
    Advising   : array [1..NumValues] of Boolean;

    DataSample : TDataSample;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses DDEDlg; { DataEntry Form }

{$R *.DFM}

procedure TForm1.Exit1Click(Sender: TObject);
begin
   Close;
end;
{ Initialized globals }

const
  DemoTitle   : PChar = 'DDEML Demo, Server Application';

  MaxAdvisories = 100;
  NumAdvLoops : Integer = 0;


{ Local Function: CallBack Procedure for DDEML }

{ This callback procedure responds to all transactions generated by the
  DDEML.  The target Window object is obtained from the stored global,
  and the appropriate methods within that objects are used to respond
  to the given transaction, as indicated by the CallType parameter.
}
function CallbackProc(CallType, Fmt: Word; Conv: HConv; HSz1, HSz2: HSZ;
  Data: HDDEData; Data1, Data2: Longint): HDDEData; export;
var
  ItemNum   : Integer;
begin
  CallbackProc := 0;    { See if proved otherwise }


  case CallType of

    xtyp_WildConnect:
      CallbackProc := Form1.WildConnect(HSz1, HSz2, Fmt);

    xtyp_Connect:
      if Conv = 0 then
      begin
        if Form1.MatchTopicAndService(HSz1, HSz2) then
          CallbackProc := 1;   { Connected! }
      end;
{ When a connection is confirmed, record the conversation handle as the
  window's own.
}
    xtyp_Connect_Confirm:
      Form1.ConvHdl := Conv;

{ The client has requested data, either as a direct request or
  in response to an advisory.  Return the current state of the
  data.
}
    xtyp_AdvReq, xtyp_Request:
      begin
        ItemNum := Form1.MatchTopicAndItem(HSz1, HSz2);
        if ItemNum > 0 then
          CallbackProc := Form1.DataRequested(CallType, ItemNum, Fmt);
      end;

{ Respond to Poke requests ... this demo only allows Pokes of DataItem1.
  Return dde_FAck to acknowledge the receipt, 0 otherwise.
}
    xtyp_Poke:
      begin
        if Form1.AcceptPoke(HSz2, Fmt, Data) then
          CallbackProc := dde_FAck;
      end;

{ The client has requested the start of an advisory loop.  Note
  that we assume a "hot" loop.  Set the Advising flag to indicate
  the open loop, which will be checked whenever the data is changed.
}
    xtyp_AdvStart:
      begin
        ItemNum := Form1.MatchTopicAndItem(HSz1, HSz2);
        if ItemNum > 0 then begin
          if NumAdvLoops  0 then
        begin
          if NumAdvLoops > 0 then
          begin
            Dec(NumAdvLoops);
            if NumAdvLoops = 0 then
              Form1.Advising[ItemNum] := False;
            CallbackProc := 1;
          end;
        end;
      end;
  end;  { Case CallType }

end;

{ Returns True if the given Topic and Service match those supported
  by this application.  False otherwise.
}
function TForm1.MatchTopicAndService(Topic, Service: HSz): Boolean;
begin
  Result := False;
  if DdeCmpStringHandles(TopicHSz, Topic) = 0 then
    if DdeCmpStringHandles(ServiceHSz, Service) = 0 then
      Result := True;
end;

{ Determines if the given Topic and Item match one supported by this
  application.  Returns the Item Number of the supported item (in the
  range 1..NumValues) if one is found, and zero if no match.
}
function TForm1.MatchTopicAndItem(Topic, Item: HSz): Integer;
var
  I : Integer;
begin
  Result := 0;
  if DdeCmpStringHandles(TopicHSz, Topic) = 0 then
    for I := 1 to NumValues do
      if DdeCmpStringHandles(ItemHSz[I], Item) = 0 then
        Result := I;
end;

{ Responds to wildcard connect requests.  These requests are generated
  whenever a client tries to connect to a server with either service or
  topic name set to 0.  If a server detects a wild card match, it
  returns a handle to an array of THSZPair's containing the matching
  supported Service and Topic.
}
function TForm1.WildConnect(Topic, Service: HSz; ClipFmt: Word): HDDEData;
var
  TempPairs: array [0..1] of THSZPair;
  Matched  : Boolean;
begin
  TempPairs[0].hszSvc  := ServiceHSz;
  TempPairs[0].hszTopic:= TopicHSz;
  TempPairs[1].hszSvc  := 0;     { 0-terminate the list }
  TempPairs[1].hszTopic:= 0;

  Matched := False;

  if (Topic= 0) and (Service = 0) then
    Matched := True                    { Complete wildcard }
  else
    if (Topic = 0) and (DdeCmpStringHandles(Service, ServiceHSz) = 0) then
      Matched := True
    else
      if (DdeCmpStringHandles(Topic, TopicHSz) = 0) and (Service = 0) then
        Matched := True;

  if Matched then
    WildConnect := DdeCreateDataHandle(Inst,
TempPairs, SizeOf(TempPairs),
      0, 0, ClipFmt, 0)
  else
    WildConnect := 0;
end;

{ Accepts and acts upon Poke requests from the Client.  For this
  demonstration, allows only the value of DataItem1 to be changed by a
  Poke.
}
function TForm1.AcceptPoke(Item: HSz; ClipFmt: Word;
  Data: HDDEData): Boolean;
var
  DataStr   : TDataString;
  Err       : Integer;
  TempSample: Integer;
begin
  if (DdeCmpStringHandles(Item, ItemHSz[1]) = 0) and
     (ClipFmt = cf_Text) then
  begin
    DdeGetData(Data,
DataStr, SizeOf(DataStr), 0);
    Val(DataStr, TempSample, Err);

    if IntToStr(TempSample) <> Label6.Caption then begin
      Label6.Caption := IntToStr(TempSample);
      DataSample[1] := TempSample;
      if Advising[1] then
        DdePostAdvise(Inst, TopicHSz, ItemHSz[1]);
    end;
    AcceptPoke := True;
  end
  else
    AcceptPoke := False;
end;

{ Returns the data requested by the given TransType and ClipFmt values.
  This could happen either in response to either an xtyp_Request or an
  xtyp_AdvReq.  The ItemNum parameter indicates which of the supported
  items (in the range 1..NumValues) was requested (note that this method
  assumes that the caller has already established validity and ID of the
  requested item using MatchTopicAndItem).  The corresponding data from
  the DataSample instance variable is converted to text and returned.
}
function TForm1.DataRequested(TransType: Word; ItemNum: Integer;
  ClipFmt: Word): HDDEData;
var ItemStr: TDataString;   { Defined in DataEntry.TPU }

begin
  if ClipFmt = cf_Text then
  begin
    Str(DataSample[ItemNum], ItemStr);
    DataRequested := DdeCreateDataHandle(Inst,
ItemStr,
      StrLen(ItemStr) + 1, 0, ItemHSz[ItemNum], ClipFmt, 0);
  end
  else
    DataRequested := 0;
end;


{ Constructs an instance of the DDE Server Window.  Calls on the
  inherited constructor, then sets up this objects own instandce
  data.
}
procedure TForm1.FormCreate(Sender: TObject);
var I : Integer;
begin
  Inst      := 0;      { Must be zero for first call to DdeInitialize }

CallBack := nil;    { MakeProcInstance is called in SetupWindow    }

  for I := 1 to NumValues do begin
    DataSample[I] := 0;
    Advising[I]  := False;
    end; { for }

end;



{ Destroys an instance of the DDE Server Window.  Checks to see if the
  Callback Proc Instance had been created, and frees it if so.  Also
  calls DdeUninitialize to terminate the conversation.  Then just calls
  on the ancestral destructor to finish.
}
procedure TForm1.FormDestroy(Sender: TObject);
var
  I : Integer;
begin
  if ServiceHSz <> 0 then
    DdeFreeStringHandle(Inst, ServiceHSz);
  if TopicHSz <> 0 then
    DdeFreeStringHandle(Inst, TopicHSz);
  for I := 1 to NumValues do
    if ItemHSz[I] <> 0 then
      DdeFreeStringHandle(Inst, ItemHSz[I]);

  if Inst <> 0 then
    DdeUninitialize(Inst);   { Ignore the return value }

  if
CallBack <> nil then
    FreeProcInstance(
CallBack);
end;

procedure TForm1.FormShow(Sender: TObject);
var
  I : Integer;
{ Completes the initialization of the DDE Server Window.  Initializes
  the use of the DDEML by registering the services provided by this
  application.  Recall that the actual names used to register are
  defined in a separate unit (DataEntry), so that they can be used
  by the client as well.
}
begin

CallBack:= MakeProcInstance(
CallBackProc, HInstance);

  if DdeInitialize(Inst, CallBack, 0, 0) = dmlErr_No_Error then begin
    ServiceHSz:= DdeCreateStringHandle(Inst, DataEntryName, cp_WinAnsi);
    TopicHSz  := DdeCreateStringHandle(Inst, DataTopicName, cp_WinAnsi);
    for I := 1 to NumValues do
      ItemHSz[I] := DdeCreateStringHandle(Inst, DataItemNames[I],
        cp_WinAnsi);

    if DdeNameService(Inst, ServiceHSz, 0, dns_Register) = 0 then
      ShowMessage('Registration failed.');
  end;
end;

procedure TForm1.EnterData1Click(Sender: TObject);
{ Activates the data-entry dialog, and updates the stored
  data when complete.
}
var
  I: Integer;

begin
  if DataEntry.ShowModal = mrOk then begin
    with DataEntry do begin
      Label6.Caption := S1;
      Label7.Caption := S2;
      Label8.Caption := S3;
      DataSample[1] := StrToInt(S1);
      DataSample[2] := StrToInt(S2);
      DataSample[3] := StrToInt(S3);
      end; { with }

    for I := 1 to NumValues do
      if Advising[I] then
        DdePostAdvise(Inst, TopicHSz, ItemHSz[I]);
    end; { if }
end;

procedure TForm1.Clear1Click(Sender: TObject);
{ Clears the current data.
}
var
  I: Integer;

begin
  for I := 1 to NumValues do begin
    DataSample[I] := 0;
    if Advising[I] then
      DdePostAdvise(Inst, TopicHSz, ItemHSz[I]);
  end;

  Label6.Caption := '0';
  Label7.Caption := '0';
  Label8.Caption := '0';
end;



end.
{ ***   END CODE FOR DDESVRU.PAS *** }

{ *** BEGIN CODE FOR DDEDLG.DFM *** }
object DataEntry: TDataEntry
  Left = 488
  Top = 132
  ActiveControl = OKBtn
  BorderStyle = bsDialog
  Caption = 'Data Entry'
  ClientHeight = 264
  ClientWidth = 199
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  PixelsPerInch = 96
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 177
    Height = 201
    Shape = bsFrame
    IsControl = True
  end
  object OKBtn: TBitBtn
    Left = 16
    Top = 216
    Width = 69
    Height = 39
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 3
    OnClick = OKBtnClick
    Glyph.Data = {
      BE060000424DBE06000000000000360400002800000024000000120000000100
      0800000000008802000000000000000000000000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
      A600000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F0FBFF00A4A0A000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00030303030303
      0303030303030303030303030303030303030303030303030303030303030303
      03030303030303030303030303030303030303030303FF030303030303030303
      03030303030303040403030303030303030303030303030303F8F8FF03030303
      03030303030303030303040202040303030303030303030303030303F80303F8
      FF030303030303030303030303040202020204030303030303030303030303F8
      03030303F8FF0303030303030303030304020202020202040303030303030303
      0303F8030303030303F8FF030303030303030304020202FA0202020204030303
      0303030303F8FF0303F8FF030303F8FF03030303030303020202FA03FA020202
      040303030303030303F8FF03F803F8FF0303F8FF03030303030303FA02FA0303
      03FA0202020403030303030303F8FFF8030303F8FF0303F8FF03030303030303
      FA0303030303FA0202020403030303030303F80303030303F8FF0303F8FF0303
      0303030303030303030303FA0202020403030303030303030303030303F8FF03
      03F8FF03030303030303030303030303FA020202040303030303030303030303
      0303F8FF0303F8FF03030303030303030303030303FA02020204030303030303
      03030303030303F8FF0303F8FF03030303030303030303030303FA0202020403
      030303030303030303030303F8FF0303F8FF03030303030303030303030303FA
      0202040303030303030303030303030303F8FF03F8FF03030303030303030303
      03030303FA0202030303030303030303030303030303F8FFF803030303030303
      030303030303030303FA0303030303030303030303030303030303F803030303
      0303030303030303030303030303030303030303030303030303030303030303
      0303}
    Margin = 2
    NumGlyphs = 2
    Spacing = -1
    IsControl = True
  end
  object CancelBtn: TBitBtn
    Left = 108
    Top = 216
    Width = 69
    Height = 39
    Caption = '&Cancel'
    TabOrder = 4
    Kind = bkCancel
    Margin = 2
    Spacing = -1
    IsControl = True
  end
  object Panel2: TPanel
    Left = 16
    Top = 88
    Width = 153
    Height = 49
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 24
      Top = 8
      Width = 5
      Height = 13
    end
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 48
      Height = 13
      Caption = 'Value 2:'
    end
    object Edit2: TEdit
      Left = 8
      Top = 24
      Width = 121
      Height = 20
      MaxLength = 10
      TabOrder = 0
      Text = '0'
    end
  end
  object Panel1: TPanel
    Left = 16
    Top = 16
    Width = 153
    Height = 49
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 0
    object Label4: TLabel
      Left = 8
      Top = 8
      Width = 48
      Height = 13
      Caption = 'Value 1:'
    end
    object Edit1: TEdit
      Left = 8
      Top = 24
      Width = 121
      Height = 20
      MaxLength = 10
      TabOrder = 0
      Text = '0'
    end
  end
  object Panel3: TPanel
    Left = 16
    Top = 144
    Width = 153
    Height = 49
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 2
    object Label6: TLabel
      Left = 8
      Top = 8
      Width = 48
      Height = 13
      Caption = 'Value 3:'
    end
    object Edit3: TEdit
      Left = 8
      Top = 24
      Width = 121
      Height = 20
      MaxLength = 10
      TabOrder = 0
      Text = '0'
    end
  end
end
{ ***   END CODE FOR DDEDLG.DFM *** }

{ *** BEGIN CODE FOR DDEDLG.PAS *** }
{***************************************************}
{                                                   }
{   Delphi 1.0 DDEML Demonstration Program         }
{   Copyright (c) 1996 by Borland International     }
{                                                   }
{***************************************************}

{ This unit defines the interface to the DataEntry DDE
  server (DDEMLSRV.PAS).  It defines the Service, Topic,
  and Item names supported by the Server, and also defines
  a data structure which may be used by the Client to
  hold the sampled data locally.

  The Data Entry Server makes its data samples available
  in text (cf_Text) form as three separate Topics.  Clients
  may convert these into integer form for use with the
  data structure defined here.
}
unit Ddedlg;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, Mask, ExtCtrls;

type
  TDataEntry = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Label4: TLabel;
    Panel3: TPanel;
    Label6: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    S1, S2, S3: String;
    { Public declarations }
  end;

var
  DataEntry: TDataEntry;

implementation

{$R *.DFM}

procedure TDataEntry.OKBtnClick(Sender: TObject);
begin
   S1 := Edit1.Text;
   S2 := Edit2.Text;
   S3 := Edit3.Text;
end;

procedure TDataEntry.FormShow(Sender: TObject);
begin
   Edit1.Text := '0';
   Edit2.Text := '0';
   Edit3.Text := '0';
   Edit1.SetFocus;
end;

end.
{ ***   END CODE FOR DDEDLG.PAS *** }

