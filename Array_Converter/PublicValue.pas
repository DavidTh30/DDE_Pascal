unit PublicValue;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, ExtCtrls;

procedure Change();

const
  APPCMD_FILTERINITS = $00000020;

var
  Ted: ^TEdit;

implementation

procedure Change();
begin
  if Ted = nil then exit; //not Assigned(Ted)  //not Assigned(MyPointer)
  Ted^.Text:=Ted^.Text+'/Public';
  if Ted^.Text = '' then Ted^.Text:='q';
end;

end.
