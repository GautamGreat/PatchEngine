unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, PatchEngine;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  PatchFile : TPatchEngine;
begin
  PatchFile := TPatchEngine.Create('C:\Users\Gautam\Desktop\Delphi_Projects\SPD Reset by Diag\V2\DiagTOOl.exe');
  PatchFile.PatchFile(PatchFile.FindPattern('75??6A016A08', 1), '7455??05');
  PatchFile.SavePatchFile('C:\Test.exe');
end;

end.
