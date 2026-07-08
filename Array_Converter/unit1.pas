unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  StrUtils, PublicValue;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    Private_String: string;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

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

procedure log2(LINENUM_: integer; message_: string);
begin
  Form1.Memo1.Append(LINENUM_.ToString+message_);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  BufferByte : array of Byte;  // DynamicArray
  s:string;
begin

  //#00 => Char
  //'A' => Char
  //char($0) = #00 => Char
  //$0 => Byte
  //Ord('A') => Byte
  //0 = $0 => Byte
  //if low(Array) > 0 then  'Static Array'  Allocated on the Stack                          Fixed at compile time. Cannot change.
  //if low(Array) = 0 then  'Dynamic Array' Allocated on the Heap (as a reference pointer)  Modifiable at runtime using SetLength()

  log2({$I %LINENUM%},' Dynamic Array of Byte  ------------------------------------------');
  SetLength(BufferByte, 0); //clear / Initialize
  SetLength(BufferByte, 10); //clear / Initialize

  BufferByte[low(BufferByte)]:=$0;
  BufferByte[low(BufferByte)+1]:=Ord('a');
  BufferByte[low(BufferByte)+2]:=0;
  BufferByte[low(BufferByte)+3]:=Ord('A');
  BufferByte[low(BufferByte)+8]:=Ord('Z');

  SetLength(s, Length(BufferByte)*2);
  BinToHex(@BufferByte[0], PChar(s), Length(BufferByte));
  log2({$I %LINENUM%},' Hex BufferByte: '+ s);

  log2({$I %LINENUM%},' BufferByte: "'+ string(BufferByte)+'"');
  SetString(s, PAnsiChar(@BufferByte[0]), Length(BufferByte));
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  log2({$I %LINENUM%},' BufferByte: "'+ StringOf(BufferByte)+'"');
  s := TEncoding.UTF8.GetString(BufferByte);
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  s := StringOf(BufferByte);
  if low(s) > 0 then  s:= StringOfChar(#00, Length(BufferByte)*2);
  BinToHex(@BufferByte[0], PChar(s), Length(BufferByte));
  log2({$I %LINENUM%},' Hex BufferByte: '+ s);

  BufferByte := BytesOf(DelChars(string(BufferByte),#0));

  log2({$I %LINENUM%},' BufferByte: "'+ string(BufferByte)+'"');
  SetString(s, PAnsiChar(@BufferByte[0]), Length(BufferByte));
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  log2({$I %LINENUM%},' BufferByte: "'+ StringOf(BufferByte)+'"');
  s := TEncoding.UTF8.GetString(BufferByte);
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  s := StringOf(BufferByte);
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  if low(s) > 0 then  s:= StringOfChar(#00, Length(BufferByte)*2);
  BinToHex(@BufferByte[0], PChar(s), Length(BufferByte));
  log2({$I %LINENUM%},' Hex BufferByte: '+ s);
  log2({$I %LINENUM%},'');

  SetLength(BufferByte, 10); //clear / Initialize

  BufferByte[low(BufferByte)]:=Ord('a');
  BufferByte[low(BufferByte)+1]:=$0;
  BufferByte[low(BufferByte)+2]:=0;
  BufferByte[low(BufferByte)+3]:=Ord('A');
  BufferByte[low(BufferByte)+8]:=Ord('Z');

  SetLength(s, Length(BufferByte)*2);
  BinToHex(@BufferByte[0], PChar(s), Length(BufferByte));
  log2({$I %LINENUM%},' Hex BufferByte: '+ s);

  log2({$I %LINENUM%},' BufferByte: "'+ string(BufferByte)+'"');
  SetString(s, PAnsiChar(@BufferByte[0]), Length(BufferByte));
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  log2({$I %LINENUM%},' BufferByte: "'+ StringOf(BufferByte)+'"');
  s := TEncoding.UTF8.GetString(BufferByte);
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  s := StringOf(BufferByte);
  if low(s) > 0 then  s:= StringOfChar(#00, Length(BufferByte)*2);
  BinToHex(@BufferByte[0], PChar(s), Length(BufferByte));
  log2({$I %LINENUM%},' Hex BufferByte: '+ s);

  BufferByte := BytesOf(DelChars(string(BufferByte),#0));

  log2({$I %LINENUM%},' BufferByte: "'+ string(BufferByte)+'"');
  SetString(s, PAnsiChar(@BufferByte[0]), Length(BufferByte));
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  log2({$I %LINENUM%},' BufferByte: "'+ StringOf(BufferByte)+'"');
  s := TEncoding.UTF8.GetString(BufferByte);
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  s := StringOf(BufferByte);
  log2({$I %LINENUM%},' BufferByte: "'+ s+'"');
  if low(s) > 0 then  s:= StringOfChar(#00, Length(BufferByte)*2);
  BinToHex(@BufferByte[0], PChar(s), Length(BufferByte));
  log2({$I %LINENUM%},' Hex BufferByte: '+ s);
  log2({$I %LINENUM%},'');

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  BufferAnsiChar: array of AnsiChar;  // DynamicArray
  s:string;
begin

  //#00 => Char
  //'A' => Char
  //char($0) = #00 => Char
  //$0 => Byte
  //Ord('A') => Byte
  //0 = $0 => Byte
  //if low(Array) > 0 then  'Static Array'  Allocated on the Stack                          Fixed at compile time. Cannot change.
  //if low(Array) = 0 then  'Dynamic Array' Allocated on the Heap (as a reference pointer)  Modifiable at runtime using SetLength()

  log2({$I %LINENUM%},' Dynamic Array of AnsiChar  ------------------------------------------');
  SetLength(BufferAnsiChar, 0); //clear / Initialize
  SetLength(BufferAnsiChar, 10); //clear / Initialize

  BufferAnsiChar[low(BufferAnsiChar)]:=#00;
  BufferAnsiChar[low(BufferAnsiChar)+1]:='a';
  BufferAnsiChar[low(BufferAnsiChar)+2]:=char($0);
  BufferAnsiChar[low(BufferAnsiChar)+3]:='A';

  s:=string(BufferAnsiChar);  // Static Array
  SetString(s, PAnsiChar(@BufferAnsiChar[0]), Length(BufferAnsiChar)); // Static Array
  SetString(s, PAnsiChar(BufferAnsiChar), Length(BufferAnsiChar)); // Dynamic Array

  log2({$I %LINENUM%},' BufferAnsiChar: "'+ s+'"');
  log2({$I %LINENUM%},' Hex BufferAnsiChar: '+ AnsiArrayToHex(BufferAnsiChar));

  BufferAnsiChar:=DelChars(string(BufferAnsiChar),#0).ToCharArray;

  SetString(s, PAnsiChar(BufferAnsiChar), Length(BufferAnsiChar)); // Dynamic Array
  log2({$I %LINENUM%},' BufferAnsiChar: "'+ s+'"');
  log2({$I %LINENUM%},' Hex BufferAnsiChar: '+ AnsiArrayToHex(BufferAnsiChar));

  SetLength(BufferAnsiChar, 10);
  BufferAnsiChar[low(BufferAnsiChar)]:='a';
  BufferAnsiChar[low(BufferAnsiChar)+1]:=#00;
  BufferAnsiChar[low(BufferAnsiChar)+2]:=char($0);
  BufferAnsiChar[low(BufferAnsiChar)+3]:='A';

  s:=string(BufferAnsiChar);  // Static Array
  SetString(s, PAnsiChar(BufferAnsiChar), Length(BufferAnsiChar)); // Dynamic Array

  log2({$I %LINENUM%},' BufferAnsiChar: "'+ s +'"');
  log2({$I %LINENUM%},' Hex BufferAnsiChar: '+ AnsiArrayToHex(BufferAnsiChar));

  BufferAnsiChar:=DelChars(string(BufferAnsiChar),#0).ToCharArray;

  SetString(s, PAnsiChar(BufferAnsiChar), Length(BufferAnsiChar)); // Dynamic Array
  log2({$I %LINENUM%},' BufferAnsiChar: "'+ s+'"');
  log2({$I %LINENUM%},' Hex BufferAnsiChar: '+ AnsiArrayToHex(BufferAnsiChar));
  log2({$I %LINENUM%},'');

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  BufferString:string; // Static Array
begin

  //#00 => Char
  //'A' => Char
  //char($0) = #00 => Char
  //$0 => Byte
  //Ord('A') => Byte
  //0 = $0 => Byte
  //if low(Array) > 0 then  'Static Array'  Allocated on the Stack                          Fixed at compile time. Cannot change.
  //if low(Array) = 0 then  'Dynamic Array' Allocated on the Heap (as a reference pointer)  Modifiable at runtime using SetLength()

  log2({$I %LINENUM%},' Dynamic Array of String  ------------------------------------------');

  Initialize(BufferString);   //not clear / not Initialize

  //Convert to Dynamic Array
  SetLength(BufferString, 0); //not clear / not Initialize
  SetLength(BufferString, 10);//not clear / not Initialize
  BufferString:= StringOfChar(#00, 10); //clear / Initialize

  BufferString[low(BufferString)]:=#00;
  BufferString[low(BufferString)+1]:='a';
  BufferString[low(BufferString)+2]:=char($0);
  BufferString[low(BufferString)+3]:='A';
  log2({$I %LINENUM%},' BufferString: "'+ BufferString+'"');
  log2({$I %LINENUM%},' Hex BufferString: '+ TextToHex(BufferString));

  BufferString:=DelChars(BufferString,#0);

  log2({$I %LINENUM%},' BufferString: "'+ BufferString+'"');
  log2({$I %LINENUM%},' Hex BufferString: '+ TextToHex(BufferString));

  BufferString:= StringOfChar(#00, 10);
  BufferString[low(BufferString)]:='a';
  BufferString[low(BufferString)+1]:=#00;
  BufferString[low(BufferString)+2]:=char($0);
  BufferString[low(BufferString)+3]:='A';
  log2({$I %LINENUM%},' BufferString: "'+ BufferString+'"');
  log2({$I %LINENUM%},' Hex BufferString: '+ TextToHex(BufferString));

  BufferString:=DelChars(BufferString,#0);

  log2({$I %LINENUM%},' BufferString: "'+ BufferString+'"');
  log2({$I %LINENUM%},' Hex BufferString: '+ TextToHex(BufferString));
  log2({$I %LINENUM%},'');

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  BufferByte : array of Byte;  // DynamicArray
  BufferString: string;
  s:string;
begin
  log2({$I %LINENUM%},' String to Array of Byte ------------------------------------------');
  SetLength(BufferString, 10);//not clear / not Initialize
  BufferString:= StringOfChar(#00, 10); //clear / Initialize

  BufferString[low(BufferString)]:='a';
  BufferString[low(BufferString)+1]:=#00;
  BufferString[low(BufferString)+2]:=char($0);
  BufferString[low(BufferString)+3]:='A';

  BufferByte := BytesOf(BufferString);
  log2({$I %LINENUM%},' Length(BufferString) : '+Length(BufferString).ToString);
  log2({$I %LINENUM%},' Length(BufferByte) : '+Length(BufferByte).ToString);

  s := AnsiString(StringOf(BufferByte));
  log2({$I %LINENUM%},' BufferByte: "'+ s +'"');
  SetString(s, PAnsiChar(BufferByte), Length(BufferByte)); // Dynamic Array
  log2({$I %LINENUM%},' BufferByte: "'+ s +'"');

  SetLength(s, Length(BufferByte)*2);
  BinToHex(@BufferByte[0], PChar(s), Length(BufferByte));
  log2({$I %LINENUM%},' Hex BufferByte: "'+ s +'"');
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  BufferAnsiChar : array of AnsiChar;  // DynamicArray
  BufferString: string;
  s:string;
begin
  log2({$I %LINENUM%},' String to Array of AnsiChar ------------------------------------------');
  SetLength(BufferString, 10);//not clear / not Initialize
  BufferString:= StringOfChar(#00, 10); //clear / Initialize

  BufferString[low(BufferString)]:='a';
  BufferString[low(BufferString)+1]:=#00;
  BufferString[low(BufferString)+2]:=char($0);
  BufferString[low(BufferString)+3]:='A';

  BufferAnsiChar := BufferString.ToCharArray;
  log2({$I %LINENUM%},' Length(BufferString) : '+Length(BufferString).ToString);
  log2({$I %LINENUM%},' Length(BufferAnsiChar) : '+Length(BufferAnsiChar).ToString);

  s := string(BufferAnsiChar);
  log2({$I %LINENUM%},' BufferAnsiChar: "'+ s +'"'); // Static Array
  SetString(s, PAnsiChar(BufferAnsiChar), Length(BufferAnsiChar)); // Dynamic Array
  log2({$I %LINENUM%},' BufferAnsiChar: "'+ s +'"');
  log2({$I %LINENUM%},' Hex BufferAnsiChar: "'+ AnsiArrayToHex(BufferAnsiChar) +'"');
end;

procedure TForm1.Button7Click(Sender: TObject);
//var
//  FTextPtr: PString;
//  CharPointer: PChar;
//  s:string;
begin
  //FTextPtr := PAnsistring(Edit1.Text);
  //FTextPtr := PAnsistring(s);
  //CharPointer:= @Edit1.Text[1];
  ////FTextPtr^ := 'U';
  //CharPointer^:='h';
  ////Application.QueueAsyncCall(@FormCreate,Sender);

  if Ted <> nil then
  begin
    Private_String:='Private';
    Ted^.Text:=Private_String;
  end;
  Change();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  new(Ted);
  Ted^:=Edit1;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Dispose(Ted);
  if Ted <> nil then Ted^:=nil;   //Assigned(Ted)  //Assigned(MyPointer)
end;

end.

