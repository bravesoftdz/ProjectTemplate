unit uCommonUtils;

interface

uses FMX.ListView.Types, FMX.Graphics, FMX.Controls, FMX.SearchBox;

  function GetScale: Single;
  //���������� ����� ������

  function GetPrivedScale: Single;
  //���������� "����������" �����

  function LVTextHeight(const AText: TListItemText): Single;
  //���������� ������ ������

  function LVTextWidth(const AText: TListItemText): Single;
  //���������� ������ ������

  function TextHeight(const AText: string; aTextSettings: TTextSettings; const aWidth: Single): Single;
  // ������� ������ ������ �� ������ ��� ������ � �������� ������

  function FileNameFromURL(const aURL: string): string;
  //���������� ��� ����� �� URL

  function InternetEnabled: Boolean;
  //�������� ������� ���������

  function FindSearchBox(const ARootControl: TControl): TSearchBox;
  //���������� � ����������� TSearchBox

  {$IFDEF ANDROID}
  function GetAndroidOSVersion: string;
  //����� ������ Android-����������
  {$ENDIF}


implementation

uses FMX.Platform, System.SysUtils, FMX.TextLayout, System.Math, System.Types,
     FMX.Types, System.Net.HttpClient, System.Net.HttpClientComponent
     {$IFDEF ANDROID},  AndroidApi.JNI.OS, Androidapi.Helpers{$ENDIF};

function FindSearchBox(const ARootControl: TControl): TSearchBox;
//���������� � ����������� TSearchBox
var
  Child: TControl;
begin
  Result := nil;
  for Child in ARootControl.Controls do
    if Child is TSearchBox then
      Exit(TSearchBox(Child));
end;

function GetScale: Single;
//���������� ����� ������
var
  ScreenService: IFMXScreenService;
begin
  Result := 1.0;
  try
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(ScreenService)) then
      Result := ScreenService.GetScreenScale;
  except
    Result := 1.0;
  end;
end;

function GetPrivedScale: Single;
//���������� "����������" �����
var
  r: Single;
begin
  r := GetScale;
  if r < 1 then
    r := 1;
  if (r >= 1.01) and (r <= 1.49) then
    r := 1;
  if (r >= 1.51) and (r <= 1.99) then
    r := 1.5;
  if (r >= 2.01) and (r <= 2.49) then
    r := 2;
  if (r >= 2.51) and (r <= 2.99) then
    r := 2.5;
  if (r >= 3.01) and (r <= 3.49) then
    r := 3;
  if (r >= 3.51) and (r <= 3.99) then
    r := 3.5;
  if r > 4.0 then
    r := 4;
  Result := r;
end;

function LVTextHeight(const AText: TListItemText): Single;
//���������� ������ ������ ��
var
  Layout: TTextLayout;
  aRect: TRectF;
  aWW: boolean;
begin
  Result := 0;
  if AText.Text.IsEmpty then
    Exit;

  aWW := Pos(#13#10, AText.Text) > 0;
  if (AText.WordWrap) or (aWW) then
    aRect := RectF(0, 0, AText.Width, MaxSingle)
  else
    aRect := RectF(0, 0, MaxSingle, MaxSingle);
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    Layout.TopLeft := aRect.TopLeft;
    Layout.MaxSize := PointF(aRect.Width, aRect.Height);
    Layout.WordWrap := AText.WordWrap;
    Layout.Trimming := AText.Trimming;
    Layout.HorizontalAlign := TTextAlign.Leading;
    Layout.VerticalAlign := TTextAlign.Leading;
    Layout.Font.Assign(AText.Font);
    Layout.Color := AText.TextColor;
    Layout.RightToLeft := False;
    Layout.Text := AText.Text;
    Layout.EndUpdate;
    aRect := Layout.TextRect;
  finally
    FreeAndNil(Layout);
  end;
  Result := aRect.Bottom;
end;

function LVTextWidth(const AText: TListItemText): Single;
//���������� ������ ������ ��
var
  Layout: TTextLayout;
  aRect: TRectF;
  aWW: boolean;
begin
  Result := 0;
  if AText.Text.IsEmpty then
    Exit;

  aWW := Pos(#13#10, AText.Text) > 0;
  if (AText.WordWrap) or (aWW) then
    aRect := RectF(0, 0, AText.Width, MaxSingle)
  else
    aRect := RectF(0, 0, MaxSingle, MaxSingle);
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    Layout.TopLeft := aRect.TopLeft;
    Layout.MaxSize := PointF(aRect.Width, aRect.Height);
    Layout.WordWrap := AText.WordWrap;
    Layout.Trimming := AText.Trimming;
    Layout.HorizontalAlign := TTextAlign.Leading;
    Layout.VerticalAlign := TTextAlign.Leading;
    Layout.Font.Assign(AText.Font);
    Layout.Color := AText.TextColor;
    Layout.RightToLeft := False;
    Layout.Text := AText.Text;
    Layout.EndUpdate;
    aRect := Layout.TextRect;
  finally
    FreeAndNil(Layout);
  end;
  Result := aRect.Right;
end;

function TextHeight(const AText: string; aTextSettings: TTextSettings; const aWidth: Single): Single;
// ������� ������ ������ �� ������ ��� ������ � �������� ������
var
  Layout: TTextLayout;
  aRect: TRectF;
  aWW: boolean;
begin
  Result := 0;
  if AText.IsEmpty then
    Exit;

  aWW := Pos(#13#10, AText) > 0;
  if (aTextSettings.WordWrap) or (aWW) then
    aRect := RectF(0, 0, aWidth, MaxSingle)
  else
    aRect := RectF(0, 0, MaxSingle, MaxSingle);
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    Layout.TopLeft := aRect.TopLeft;
    Layout.MaxSize := PointF(aRect.Width, aRect.Height);
    Layout.WordWrap := aTextSettings.WordWrap;
    Layout.HorizontalAlign := TTextAlign.Leading;
    Layout.VerticalAlign := TTextAlign.Leading;
    Layout.Font.Assign(aTextSettings.Font);
    Layout.Color := aTextSettings.FontColor;
    Layout.RightToLeft := false;
    Layout.Text := AText;
    Layout.EndUpdate;
    aRect := Layout.TextRect;
  finally
    FreeAndNil(Layout);
  end;
  Result := aRect.Bottom;
end;

function FileNameFromURL(const aURL: string): string;
//���������� ��� ����� �� URL
var
  i: Integer;
begin
  i := LastDelimiter('/', aURL);
  Result := Copy(aURL, i + 1, Length(aURL) - (i));
end;

function InternetEnabled: Boolean;
//�������� ������� ���������
var
  Resp: IHTTPResponse;
begin
  Result := False;
  with TNetHTTPClient.Create(nil) do
    begin
      try
        Resp := Head('http://google.com');
        Result := Resp.StatusCode < 400;
      except
        Result := False;
      end;
      Free;
    end;
end;

{$IFDEF ANDROID}
function GetAndroidOSVersion: string;
//����� ������ Android-����������
begin
  Result := JStringToString(TJBuild_VERSION.JavaClass.release);
end;
{$ENDIF}

end.
