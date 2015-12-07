unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Buttons, SdpoSerial;

type

  { TFm_Main }

  TFm_Main = class(TForm)
    BitBtn_About: TBitBtn;
    BitBtn_Clear: TBitBtn;
    Btn_Open: TButton;
    Btn_Send: TButton;
    Btn_Save: TButton;
    Btn_OpenFile: TButton;
    Btn_Cleear: TButton;
    CB_SendHex: TCheckBox;
    CB_RecHex: TCheckBox;
    Combo_BaudRate: TComboBox;
    Combo_DataBits: TComboBox;
    Combo_Devices: TComboBox;
    Combo_Parity: TComboBox;
    Combo_StopBits: TComboBox;
    E_Rx: TEdit;
    E_Tx: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    L_BaudRate: TLabel;
    L_DataBits: TLabel;
    L_Devices: TLabel;
    L_Parity: TLabel;
    L_StopBits: TLabel;
    M_RecData: TMemo;
    M_SendData: TMemo;
    OpenDialog1: TOpenDialog;
    P_Setting: TPanel;
    SaveDialog1: TSaveDialog;
    SdpoSerial1: TSdpoSerial;
    StatusBar1: TStatusBar;
    procedure BitBtn_AboutClick(Sender: TObject);
    procedure BitBtn_ClearClick(Sender: TObject);
    procedure Btn_OpenClick(Sender: TObject);
    procedure Btn_OpenFileClick(Sender: TObject);
    procedure Btn_SendClick(Sender: TObject);
    procedure Btn_SaveClick(Sender: TObject);
    procedure Btn_CleearClick(Sender: TObject);
    procedure CB_SendHexChange(Sender: TObject);
    procedure CB_RecHexChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SdpoSerial1RxData(Sender: TObject);
  private

  public
    function TransChar(AChar: char): integer;
    function StrToHex(AStr: string): string;
    function HexToStr(AStr: string): string;
  public
    OpenFlag: Boolean;
    RecHexFlag: Boolean;
    SendHexFlag: Boolean;
  end;

var
  Fm_Main: TFm_Main;


implementation

{$R *.lfm}

{ TFm_Main }

procedure TFm_Main.Btn_OpenClick(Sender: TObject);
begin
  if(False = OpenFlag) then
  begin
    SdpoSerial1.BaudRate := TBaudRate(Combo_BaudRate.ItemIndex);
    SdpoSerial1.DataBits := TDataBits(Combo_DataBits.ItemIndex);
    SdpoSerial1.Device := Combo_Devices.Text;
    SdpoSerial1.Parity := TParity(Combo_Parity.ItemIndex);
    SdpoSerial1.StopBits := TStopBits(Combo_StopBits.ItemIndex);
    try
      SdpoSerial1.Open;
      OpenFlag := True;
      Btn_Open.Caption := 'Close';
      StatusBar1.SimpleText := 'Open Devices Successful';
    except
      on E:Exception do
      begin
        OpenFlag := False;
        Btn_Open.Caption := 'Open';
        ShowMessage(E.Message);
        StatusBar1.SimpleText := 'Open Devices Failed';
      end;
    end;
  end
  else
  begin
    SdpoSerial1.Close;
    OpenFlag := False;
    Btn_Open.Caption := 'Open';
    StatusBar1.SimpleText := 'Devices Closed';
  end;
end;

procedure TFm_Main.BitBtn_ClearClick(Sender: TObject);
begin
  E_Rx.Text := '0';
  E_Tx.Text := '0';
end;

procedure TFm_Main.BitBtn_AboutClick(Sender: TObject);
begin
  ShowMessage(  'Just for you'+ #13#10 + '  By wangxian');
end;

procedure TFm_Main.Btn_OpenFileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    M_SendData.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TFm_Main.Btn_SendClick(Sender: TObject);
begin
  //SendData and display the TX size;
  if SendHexFlag then
    E_Tx.Text := IntToStr(StrToInt(E_Tx.Text) + SdpoSerial1.WriteData(HexToStr(M_SendData.Text)))
  else
    E_Tx.Text := IntToStr(StrToInt(E_Tx.Text) + SdpoSerial1.WriteData(M_SendData.Text))
end;

procedure TFm_Main.Btn_SaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    M_RecData.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TFm_Main.Btn_CleearClick(Sender: TObject);
begin
  M_RecData.Text := '';
end;

procedure TFm_Main.CB_SendHexChange(Sender: TObject);
begin
  if CB_SendHex.Checked then
  begin
    if not SendHexFlag then
    begin
      M_SendData.Text := StrToHex(M_SendData.Lines.Text);
      SendHexFlag := True;
    end
    else
      SendHexFlag := True;
  end
  else
  begin
    SendHexFlag := False;
    M_SendData.Text := HexToStr(M_SendData.Lines.Text);
  end;
end;

procedure TFm_Main.CB_RecHexChange(Sender: TObject);
begin
  if CB_RecHex.Checked then
  begin
    if not RecHexFlag then
    begin
      M_RecData.Text := StrToHex(M_RecData.Lines.Text);
      RecHexFlag := True;
    end
    else
      RecHexFlag := True;
  end
  else
  begin
    RecHexFlag := False;
    M_RecData.Text := HexToStr(M_RecData.Lines.Text);
  end;
end;

procedure TFm_Main.FormCreate(Sender: TObject);
begin
  OpenFlag := False;
end;

procedure TFm_Main.FormResize(Sender: TObject);
begin
  if Self.Width < 527 then
    self.Width := 527;
  if Self.Height < 386 then
    Self.Height := 386;
end;

procedure TFm_Main.SdpoSerial1RxData(Sender: TObject);
var
  TempStr: String;
begin
  TempStr := SdpoSerial1.ReadData;
  //add the display RX size
  E_Rx.Text := IntToStr(StrToInt(E_Rx.Text) + Length(TempStr));
  if RecHexFlag then
      M_RecData.Text := M_RecData.Text + StrToHex(TempStr)
  else
      M_RecData.Text := M_RecData.Text + TempStr;
end;

function TFm_Main.TransChar(AChar: Char): Integer;
begin
  if AChar in ['0'..'9'] then
  Result := Ord(AChar) - Ord('0')
  else
  Result := 10 + Ord(AChar) - Ord('A');
end;

function TFm_Main.StrToHex(AStr: string): string;
var
  I ,Len: Integer;
  s:char;
begin
  len:=length(AStr);
  Result:='';
  for i:=1 to len  do
  begin
    s:=AStr[i];
    Result:=Result + IntToHex(Ord(s),2) + ' ';
  end;
end;

function TFm_Main.HexToStr(AStr: string): string;
var
  I,len : Integer;
  CharValue: Word;
  Tmp:string;
  s:char;
begin
  Tmp:='';
  len:=length(Astr);
  for i:=1 to len  do
  begin
    s:=Astr[i];
    if s <> ' ' then
      Tmp:=Tmp+ string(s);
  end;
  Result := '';
  For I := 1 to Trunc(Length(Tmp)/2) do
  begin
    Result := Result + ' ';
    CharValue := TransChar(Tmp[2*I-1])*16 + TransChar(Tmp[2*I]);
    Result[I] := Char(CharValue);
  end;
end;

end.

