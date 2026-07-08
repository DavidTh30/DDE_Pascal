unit DDEVar;

{$mode ObjFPC}{$H+}

interface
uses
  Classes, SysUtils, Dialogs,  Windows;

Type
  Reorganize = Record
    ComponentStoryNumber_:string;
    StoreCodeNumber_:string;
    Fault_:boolean;
    GetTotal:integer;
    Found_:boolean;
    end;

function BoolToInt(State:boolean):Integer;
function IntToBool(State:Integer):boolean;
Function StrToBoolV2(BoolS_:string):boolean;
//----------------------------------------------------------------

const
  MAGIC_NUMBER = 3;
  CP_WINANSI = 1004;      // Default codepage for DDE conversations.
  CP_WINUNICODE = 1200;
  CF_TEXT = 1;
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

    g_lInstID : Long;
    DdeInitializeResultCode_VB6: UINT;
    g_hService : Long;
    g_hService2 : Long;
    g_hTopic : Long;
    g_hTopic2 : Long;
    g_hItem : Long;
    g_hDDEConv : Long;
    g_hDDEConvList : Long;
    g_hDDEPrevConv : Long;



implementation

function BoolToInt(State:boolean):Integer;
begin
  result:=0;
  if(State)then result:=1;
  if(not State)then result:=0;
end;

function IntToBool(State:Integer):boolean;
begin
  result:=false;
  if(State>0)then result:=true;
  if(State<=0)then result:=false;
end;

Function StrToBoolV2(BoolS_:string):boolean;
begin
  //[Remark boolean as string]
  //input 1.) 'true'
  //input 2.) '1'
  //input 2.) '-1'
  //result:= true/false
  if((LowerCase(BoolS_)='true')or(LowerCase(BoolS_)='1')or(LowerCase(BoolS_)='-1')) then
  result:= true
  else
  result:= false;
end;

end.

