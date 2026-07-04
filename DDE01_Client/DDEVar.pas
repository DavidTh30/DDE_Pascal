unit DDEVar;

{$mode ObjFPC}{$H+}

interface
uses
  Classes, SysUtils, StdCtrls, Dialogs, Math, Windows, Messages;

Type
  Reorganize = Record
    ComponentStoryNumber_:string;
    StoreCodeNumber_:string;
    Fault_:boolean;
    GetTotal:integer;
    Found_:boolean;
    end;

generic procedure abcd();
function BoolToInt(State:boolean):Integer;
function IntToBool(State:Integer):boolean;
Function StrToBoolV2(BoolS_:string):boolean;
Function ErrorEvenToBoolean(ErrorEven:string):string;
Function ErrorEvenToCode(ErrorEven:string):string;
Function BoolS_CodeToErrorEven(BoolS_:string;Code_:string):string;
Function Bool_CodeToErrorEven(Bool_:boolean;Code_:string):string;
Function GenerateAndEncodingAction(ActionType:string):string;
Function DecoderAction(EncodingAction:string):string;
Function RandomAsEncoderFormat():string;
procedure InitRamdomNumber(Debug_:TMemo);
//----------------------------------------------------------------

//----------------------------------------------------------------
Function TextComparator_(S1_:string; S2_:string):string; // '>', '<', '='
Function DateTimeToEncoder(DateTime_:string):string;
Function EncoderToDateTime(Encoder_:string):string;

type
  StoreSimulation = class
    //procedure SaveAs1ButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }

  end;

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


 StoData:StoreSimulation;

 RegisterColCount:integer = 0;
 ReceiveColCount:integer = 0;
 RequisitionIssueColCount:integer = 0;
 BorrowColCount:integer = 0;
 AsfoundColCount:integer = 0;

 TotalItem:integer;

 DebugMode_: boolean;

 X0_:integer;
 N_:integer;
 P1:integer;
 P2:integer;

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

generic procedure abcd();
begin
  Showmessage('abcd');
end;

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

Function ErrorEvenToBoolean(ErrorEven:string):string;
begin
  //[Remark error events]
  //input 1.) '[1]YYYYMMDDhhnnss' =3+14
  //input 2.) '[0]YYYYMMDDhhnnss' =3+14
  //input 3.) '[1]0' =3+1
  //input 4.) '[0]0' =3+1
  //input 5.) ''
  //result:= 'true','false','YYYYMMDDhhnnss','','error'

  result:= 'error';
  if((length(ErrorEven)<>17)and(length(ErrorEven)<>4)and(ErrorEven<>'0')and(ErrorEven<>'1')and(ErrorEven<>'-1')and(ErrorEven<>''))then exit;
  if(ErrorEven='')then begin result:='false'; exit; end;
  if(ErrorEven='0')then begin result:='false'; exit; end;
  if(ErrorEven='1')then begin result:='true'; exit; end;
  if(ErrorEven='-1')then begin result:='true'; exit; end;
  if((length(ErrorEven)=17)or(length(ErrorEven)=4))then
  begin
    if((LeftStr(ErrorEven,1)<>'[') or (RightStr(LeftStr(ErrorEven,3),1)<>']'))then exit;
    if ((RightStr(LeftStr(ErrorEven,2),1)='1') or (RightStr(LeftStr(ErrorEven,3),2)='-1')) then result:= 'true'  else result:= 'false';
  end;
end;

Function ErrorEvenToCode(ErrorEven:string):string;
begin
  //[Remark error events]
  //input 1.) '[1]YYYYMMDDhhnnss' =3+14
  //input 2.) '[0]YYYYMMDDhhnnss' =3+14
  //input 3.) '[1]0' =3+1
  //input 4.) '[0]0' =3+1
  //input 5.) ''
  //result:= 'true','false','YYYYMMDDhhnnss','','error'

  result:= 'error';
  if((length(ErrorEven)<>17)and(length(ErrorEven)<>4)and(ErrorEven<>''))then exit;
  if((ErrorEven='')or(length(ErrorEven)=4))then begin result:=''; exit; end;
  if(length(ErrorEven)=17)then
  begin
    if((LeftStr(ErrorEven,1)<>'[') or (RightStr(LeftStr(ErrorEven,3),1)<>']'))then exit;
    result:= RightStr(ErrorEven,14);
  end;
end;

Function BoolS_CodeToErrorEven(BoolS_:string;Code_:string):string;
begin
  //[Remark error events]
  //input 1.) '[1]YYYYMMDDhhnnss' =3+14
  //input 2.) '[0]YYYYMMDDhhnnss' =3+14
  //input 3.) '[1]0' =3+1
  //input 4.) '[0]0' =3+1
  //input 5.) ''
  //result:= 'true','false','YYYYMMDDhhnnss','','error'

  result:= 'error';
  if((length(BoolS_)=2)and(BoolS_='-1'))then BoolS_:='1';
  if((length(BoolS_)<>3)and(length(BoolS_)<>1))then exit;
  if((length(Code_)<>14)and(length(Code_)<>1)and(Code_<>''))then exit;
  if((length(Code_)=1)and(Code_<>'0'))then exit;
  if((length(BoolS_)=1)and(BoolS_<>'0')and(BoolS_<>'1'))then exit;
  if((length(BoolS_)=3)and(LeftStr(BoolS_,1)<>'[') or (RightStr(BoolS_,1)<>']'))then exit;
  if((length(BoolS_)=3)and(RightStr(LeftStr(BoolS_,2),1)<>'1')and(RightStr(LeftStr(BoolS_,2),1)<>'0'))then exit;
  if((length(BoolS_)=3)and(length(Code_)=14))then result:= BoolS_+Code_;
  if((length(BoolS_)=3)and(Code_='0'))then result:= '['+BoolS_+']0';
  if((length(BoolS_)=3)and(Code_=''))then result:= '['+BoolS_+']0';
  if((length(BoolS_)=1)and(length(Code_)=14))then result:= '['+BoolS_+']'+Code_;
  if((length(BoolS_)=1)and(length(Code_)=1))then result:= '['+BoolS_+']0';
  if((length(BoolS_)=1)and(Code_=''))then result:= '['+BoolS_+']0';
end;

Function Bool_CodeToErrorEven(Bool_:boolean;Code_:string):string;
begin
  //[Remark error events]
  //input 1.) '[1]YYYYMMDDhhnnss' =3+14
  //input 2.) '[0]YYYYMMDDhhnnss' =3+14
  //input 3.) '[1]0' =3+1
  //input 4.) '[0]0' =3+1
  //input 5.) ''
  //result:= 'true','false','YYYYMMDDhhnnss','','error'

  result:= 'error';
  if((length(Code_)<>14)and(length(Code_)<>1)and(Code_<>''))then exit;
  if((length(Code_)=1)and(Code_<>'0'))then exit;
  if ((Bool_)and(length(Code_)=14)) then result:= '[1]'+Code_;
  if ((not Bool_)and(length(Code_)=14)) then result:= '[0]'+Code_;
  if ((Bool_)and((length(Code_)=1) or (Code_=''))) then result:= '[1]0';
  if ((not Bool_)and((length(Code_)=1) or (Code_=''))) then result:= '[0]0';
end;

Function GenerateAndEncodingAction(ActionType:string):string;
begin
  result:='';
  if(ActionType='Receive')then result:='0100'+FormatDateTime('YYYYMMDDhhnnss',Now);
  if(ActionType='Requisition')then result:='0200'+FormatDateTime('YYYYMMDDhhnnss',Now);
  if(ActionType='Borrow')then result:='0300'+FormatDateTime('YYYYMMDDhhnnss',Now);
  if(ActionType='AsFound')then result:='0400'+FormatDateTime('YYYYMMDDhhnnss',Now);
end;
Function DecoderAction(EncodingAction:string):string;  //Receive, Requisition, Borrow, AsFound
var
  i:integer;
begin
  result:='';

  //{EncoderOfItemGroup, EncoderOfSingleItem}
  //{XXXX+XXXXXXXXXXXXXX}

  //Check EncoderOfItemGroup format
  if(length(EncodingAction)<>18)then exit;
  if not TryStrToInt(LeftStr(EncodingAction,2), i) then exit;
  if not TryStrToInt(LeftStr(EncodingAction,3), i) then exit;
  if not TryStrToInt(RightStr(LeftStr(EncodingAction,4),2), i) then exit;

  //Check EncoderOfSingleItem format
  if not TryStrToInt(RightStr(LeftStr(EncodingAction,8),4), i) then exit;
  if not TryStrToInt(RightStr(LeftStr(EncodingAction,12),4), i) then exit;
  if not TryStrToInt(RightStr(LeftStr(EncodingAction,16),4), i) then exit;
  if not TryStrToInt(RightStr(EncodingAction,4), i) then exit;

  if(LeftStr(EncodingAction,2) ='01')then result:='Receive';
  if(LeftStr(EncodingAction,2) ='02')then result:='Requisition';
  if(LeftStr(EncodingAction,2) ='03')then result:='Borrow';
  if(LeftStr(EncodingAction,2) ='03')then result:='AsFound';
end;

Function RandomAsEncoderFormat():string;
var
  s:string;
begin
  Randomize();
  s:='';
  //s:=s+FormatFloat('0000',1990+random(2022-1990+1)); //YYYY       //low+random(high-low+1)
  //s:=s+FormatFloat('00',1+random(12-1+1)); //MM
  //s:=s+FormatFloat('00',1+random(30-1+1)); //DD
  //s:=s+FormatFloat('00',1+random(24-1+1)); //HH
  //s:=s+FormatFloat('00',0+random(59-0+1)); //NN
  //s:=s+FormatFloat('00',0+random(59-0+1)); //SS
  sleep(10);
  s:=s+FormatFloat('0000',RandomRange(1990,2022));
  sleep(10);
  s:=s+FormatFloat('00',RandomRange(1,12));
  sleep(10);
  s:=s+FormatFloat('00',RandomRange(1,30));
  sleep(10);
  s:=s+FormatFloat('00',RandomRange(1,24));
  sleep(10);
  s:=s+FormatFloat('00',RandomRange(0,59));
  sleep(10);
  s:=s+FormatFloat('00',RandomRange(0,59));

  //N_:=10000;//10=1Digits  100=2Digits  1000=3Digits 10000=4Digits
  //X0_:=(((X0_*P1)+P2) mod N_);
  //while (X0_<1990) or (X0_>2022) do
  //begin
  //  X0_:=(((X0_*P1)+P2) mod N_);
  //  P2:=(P1+P2);
  //  if(P2>10000)then P2:=round(P2 / 25);
  //end;
  //s:=s+FormatFloat('0000',X0_); //YYYY
  //
  //N_:=100;//10=1Digits  100=2Digits  1000=3Digits 10000=4Digits
  //X0_:=(((X0_*P1)+P2) mod N_);
  //while (X0_<1) or (X0_>12) do
  //begin
  //  X0_:=(((X0_*P1)+P2) mod N_);
  //  P2:=(P1+P2);
  //  if(P2>10000)then P2:=round(P2 / 25);
  //end;
  //s:=s+FormatFloat('00',X0_); //MM
  //
  //N_:=100;//10=1Digits  100=2Digits  1000=3Digits 10000=4Digits
  //X0_:=(((X0_*P1)+P2) mod N_);
  //while (X0_<1) or (X0_>30) do
  //begin
  //  X0_:=(((X0_*P1)+P2) mod N_);
  //  P2:=(P1+P2);
  //  if(P2>10000)then P2:=round(P2 / 25);
  //end;
  //s:=s+FormatFloat('00',X0_); //DD
  //
  //N_:=100;//10=1Digits  100=2Digits  1000=3Digits 10000=4Digits
  //X0_:=(((X0_*P1)+P2) mod N_);
  //while (X0_<1) or (X0_>24) do
  //begin
  //  X0_:=(((X0_*P1)+P2) mod N_);
  //  P2:=(P1+P2);
  //  if(P2>10000)then P2:=round(P2 / 25);
  //end;
  //s:=s+FormatFloat('00',X0_); //HH
  //
  //N_:=100;//10=1Digits  100=2Digits  1000=3Digits 10000=4Digits
  //X0_:=(((X0_*P1)+P2) mod N_);
  //while (X0_<0) or (X0_>59) do
  //begin
  //  X0_:=(((X0_*P1)+P2) mod N_);
  //  P2:=(P1+P2);
  //  if(P2>10000)then P2:=round(P2 / 25);
  //end;
  //s:=s+FormatFloat('00',X0_); //NN
  //
  //N_:=100;//10=1Digits  100=2Digits  1000=3Digits 10000=4Digits
  //X0_:=(((X0_*P1)+P2) mod N_);
  //while (X0_<0) or (X0_>59) do
  //begin
  //  X0_:=(((X0_*P1)+P2) mod N_);
  //  P2:=(P1+P2);
  //  if(P2>10000)then P2:=round(P2 / 25);
  //end;
  //s:=s+FormatFloat('00',X0_); //SS

  result:=s;
end;

procedure InitRamdomNumber(Debug_:TMemo);
begin
  Randomize();
  sleep(10);
  X0_:=2+random(79-0+1); //79;
  N_:=100;//.47483647;  //10=1Digits  100=2Digits  1000=2Digits
  P1:=263;
  P2:=71;

  //x n+1 = P 1 x n + P 2       (mod N)
  //Debug_.Append('X0_='+IntToStr(X0_));
  //Debug_.Append('N_='+IntToStr(N_));
  //Debug_.Append('P1='+IntToStr(P1));
  //Debug_.Append('P2='+IntToStr(P2));

  //for i:=1 to 1000 do
  //begin
    //Digits1:=StrToInt(RightStr(FormatFloat('00',X0_),1));
    //Digits2:=StrToInt(LeftStr(FormatFloat('00',X0_),1));
    //X0_:=(((X0_*P1)+P2) mod N_);
    //if N_<=1 then N_:=99;
    //if(IntToStr(Digits1)=RightStr(FormatFloat('00',X0_),1))then
    //  X0_:=StrToInt(LeftStr(FormatFloat('00',X0_),1)+RightStr(FormatFloat('00',Digits1+1),1));
    //if(IntToStr(Digits2)=LeftStr(FormatFloat('00',X0_),1))then
    // X0_:=StrToInt(RightStr(FormatFloat('00',Digits2+1),1)+RightStr(FormatFloat('00',X0_),1));
    //if X0_<=0 then     P2:=P2+X0_;
    //if X0_>0 then P2:=P2 mod X0_;
    //if P2<=1 then P2:=P2+79;
    //if(P2>100)then
    //begin
      //P2:=(P2 mod 9);
      //if (P2 < 5) then P2:=P2+5;
      //if (P2 mod 2)=0 then P2:=P2+3;
      //P1:=P1+2;
    //end;
    //P2:=(P1+P2);
    //if(P2>10000)then P2:=round(P2 / 25);
    //Debug_.Append('Sequent'+IntToStr(i)+' X0_='+IntToStr(X0_)+' P1='+IntToStr(P1)+' P2='+IntToStr(P2));
  //end;
end;

Function TextComparator_(S1_:string; S2_:string):string; // '>', '<', '='
var
  i1:Extended;
  i2:Extended;
begin
  result:='';
  if not TryStrToFloat(S1_,i1) then i1:=0;
  if not TryStrToFloat(S2_,i2) then i2:=0;

  if(i1>i2)then begin result:='>'; exit; end;
  if(i1<i2)then begin result:='<'; exit; end;
  result:='=';
end;

Function DateTimeToEncoder(DateTime_:string):string;
begin
  //FormatDateTime('DD/MM/YYYY hh:nn:ss',Now)
  //[DD+/+MM+/+YYYY+' '+HH+:+NN+:+SS]
  result:='';
  //Check format
  if(length(DateTime_)<>19)then exit;
  if(RightStr(LeftStr(DateTime_,3),1)<>'/')then exit;
  if(RightStr(LeftStr(DateTime_,6),1)<>'/')then exit;
  if(RightStr(LeftStr(DateTime_,11),1)<>' ')then exit;
  if(RightStr(LeftStr(DateTime_,14),1)<>':')then exit;
  if(RightStr(LeftStr(DateTime_,17),1)<>':')then exit;

  //to
  //[YYYY+MM+DD+HH+NN+SS]
  result:=RightStr(LeftStr(DateTime_,10),4);
  result:=result + LeftStr(RightStr(DateTime_,2),5);
  result:=result + LeftStr(DateTime_,2);
  result:=result + RightStr(LeftStr(DateTime_,13),2);
  result:=result + RightStr(LeftStr(DateTime_,16),2);
  result:=result + RightStr(DateTime_,2);
end;

Function EncoderToDateTime(Encoder_:string):string;
var
  i:integer;
begin
  //FormatDateTime('YYYYMMDDhhnnss',Now)
  //[YYYY+MM+DD+HH+NN+SS]
  result:='';
  //Check format
  if(length(Encoder_)<>14)then exit;
  if not TryStrToInt(LeftStr(Encoder_,4), i) then exit;
  if not TryStrToInt(RightStr(LeftStr(Encoder_,6),2), i) then exit;
  if not TryStrToInt(RightStr(LeftStr(Encoder_,8),2), i) then exit;
  if not TryStrToInt(RightStr(LeftStr(Encoder_,10),2), i) then exit;
  if not TryStrToInt(RightStr(LeftStr(Encoder_,12),2), i) then exit;
  if not TryStrToInt(RightStr(Encoder_,2), i) then exit;

  //to
  //[DD+/+MM+/+YYYY+' '+HH+:+NN+:+SS]
  result:=RightStr(LeftStr(Encoder_,8),2);
  result:=result+'/'+RightStr(LeftStr(Encoder_,6),2);
  result:=result+'/'+LeftStr(Encoder_,4);
  result:=result+' '+RightStr(LeftStr(Encoder_,10),2);
  result:=result+':'+RightStr(LeftStr(Encoder_,12),2);
  result:=result+':'+RightStr(Encoder_,2);
end;

end.

