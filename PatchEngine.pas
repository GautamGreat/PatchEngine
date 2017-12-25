unit PatchEngine;

interface

uses
  Windows, Classes, SysUtils;

type
  TPatchEngine = class
    private
      stPatchFile : string;
      msMemorySt  : TMemoryStream;
      inFileSize  : Integer;
    public
      constructor Create(Filename : string);
      function FindPattern(Pattern : string; Hits : Integer):Integer;
      function PatchFile(Offset : Integer; ReplaceBytes : string) : Boolean;
      function SavePatchFile(Filename : string) : Boolean;
      destructor Destroy;
  end;

implementation

constructor TPatchEngine.Create(Filename: string);
begin
  stPatchFile := Filename;
  msMemorySt := TMemoryStream.Create;
  msMemorySt.LoadFromFile(stPatchFile);
  inFileSize := msMemorySt.Size;
end;

procedure StringToByteArray(var Pattern, Mask : array of Byte; PatternString : string);
var
  i          : Integer;
  ByteS      : string;
begin
  for i := 1 to Length(PatternString) div 2 do
  begin
    ByteS := Copy(PatternString, (i-1)*2+1, 2);
    if ByteS = '??' then
    begin
      Mask[i-1] := 1;
      Pattern[i-1] := $00;
    end
    else
    begin
      Mask[i-1] := 0;
      Pattern[i-1] := StrToInt('$' + ByteS);
    end;
  end;
end;

function TPatchEngine.FindPattern(Pattern: string; Hits: Integer):Integer;
var
  MaskBytes : array of Byte;
  PatternBytes : array of Byte;
  NewSize, j, HitCount, i  : Integer;
  PByte   : ^Byte;
begin
  Result := 0;
  if not Odd(Length(Pattern)) then
  begin
    NewSize := Length(Pattern) div 2;
    SetLength(PatternBytes, NewSize);
    SetLength(MaskBytes, NewSize);
    StringToByteArray(PatternBytes, MaskBytes, Pattern);
    j := 0;
    HitCount := 0;
    PByte := msMemorySt.Memory;
    for i := 0 to ((inFileSize)-NewSize-1) do
    begin
      if (PatternBytes[j] = PByte^) or (MaskBytes[j] = 1) then
      begin
        Inc(j);
        if Length(PatternBytes) = j then
        begin
          Inc(HitCount);
          Result := i - Length(PatternBytes)+1;
          if HitCount = Hits then
            Break;
        end;
      end
      else
        j := 0;
      Inc(PByte);
    end;
  end
  else
    Result := 0;
end;

function TPatchEngine.PatchFile(Offset: Integer; ReplaceBytes : string):Boolean;
var
  NewSize, j : Integer;
  Mask, By  : Byte;
  ReplaceBytesA : array of Byte;
  ReplaceBytesMask : array of Byte;
  PByte : ^Byte;
begin
  NewSize := Length(ReplaceBytes) div 2;
  if not(Odd(NewSize)) then
  begin
    SetLength(ReplaceBytesA, NewSize);
    SetLength(ReplaceBytesMask, NewSize);
    StringToByteArray(ReplaceBytesA, ReplaceBytesMask, ReplaceBytes);
    PByte := msMemorySt.Memory;
    Inc(PByte, Offset);
    for j := 0 to NewSize - 1 do
    begin
      Mask := ReplaceBytesMask[j];
      By :=   ReplaceBytesA[j];
      if Mask = 0 then
        PByte^ := By;
      Inc(PByte);
    end;
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

function TPatchEngine.SavePatchFile(Filename: string):Boolean;
begin
  try
    msMemorySt.SaveToFile(Filename);
    Result := True;
  except
    Result := False;
  end;
end;

destructor TPatchEngine.Destroy;
begin
  msMemorySt.Free;
  inFileSize := 0;
  stPatchFile := '';
end;

end.
