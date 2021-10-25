unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, discord, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Discord: TDiscordMessage;
begin
  Discord := TDiscordMessage.Create(Edit1.Text);
  try
    Discord.Content := 'TEST Simple Message';
    Discord.UserName := 'HemulGM';
    Discord.AvatarURL := 'https://a.fsdn.com/allura/p/lazarus/icon?1552026857?&w=90';
    Discord.SendMessage;
  finally
    FreeAndNil(Discord);
  end;
end;

end.
