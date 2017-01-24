unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Effects,
  FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.MultiView, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView;

type
  TSpeedButton = class(FMX.StdCtrls.TSpeedButton)
  protected
    procedure AdjustFixedSize(const Ref: TControl); override;
  end;

  TfmMain = class(TForm)
    mvSideMenu: TMultiView;
    loAllForm: TLayout;
    loClient: TLayout;
    recToolbar: TRectangle;
    sbDetailsBack: TSpeedButton;
    seToolbarShadow: TShadowEffect;
    lvSideMenu: TListView;
    sbStyle: TStyleBook;
    lbHeader: TLabel;
    recStatusbar: TRectangle;
    procedure lvSideMenuApplyStyleLookup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvSideMenuUpdatingObjects(const Sender: TObject;
      const AItem: TListViewItem; var AHandled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure sbDetailsBackClick(Sender: TObject);
    procedure lvSideMenuItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure mvSideMenuStartShowing(Sender: TObject);
    procedure mvSideMenuHidden(Sender: TObject);
    procedure lvSideMenuTap(Sender: TObject; const Point: TPointF);
  private
    { Private declarations }
    FSideMenuActivated: Integer; //������ ��������� ����� �������� ����
    procedure CreateSideMenu;
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.fmx}

uses uConsts, uCommonUtils, FontAwesome
     {$IFDEF ANDROID}, FMX.StatusBar{$ENDIF};

procedure TfmMain.FormCreate(Sender: TObject);
begin
  {> ����������� ������� ���� �������}
  lvSideMenu.TransparentSeparators := True;
  if lvSideMenu.getAniCalc <> nil then
    lvSideMenu.getAniCalc.BoundsAnimation := False;
  lvSideMenu.ShowScrollBar := False;
  {$IFDEF ANDROID}
  lvSideMenu.OnItemClick := nil;
  {$ENDIF}
  FSideMenuActivated := -1;
  {<}
end;

procedure TfmMain.FormResize(Sender: TObject);
begin
  {> �������� ������ ������� � ������������ � ������������}
  if (Width >= 306) and (Width <= 480) then
    mvSideMenu.Width := Width - 56;
  {<}
end;

procedure TfmMain.CreateSideMenu;
//������� ������� ���� � �������
var
  aItem: TListViewItem;
  aItemImg: TListViewItem;
  i: Integer;
  ImgRes: TResourceStream;
begin
  {> ��������� ����������� ��� ����}
  ImgRes := TResourceStream.Create(HInstance, SideMenuHeaderResourceName +
                                   Trunc(GetPrivedScale * 10).ToString, RT_RCDATA);
  aItemImg := lvSideMenu.Items.Add;
  aItemImg.Data[SideMenuHeaderIndicator] := True;
  aItemImg.Bitmap.LoadFromStream(ImgRes);
  aItemImg.Data[SideMenuHeaderTitle] := Caption;
  lvSideMenu.Adapter.ResetView(aItemImg);
  {$IF defined(MSWINDOWS)}
  FreeAndNil(ImgRes);
  {$ELSEIF defined(ANDROID)}
  ImgRes.DisposeOf;
  ImgRes := nil;
  {$ENDIF}
  {<}

  {> ��������� ������� � ��������}
  for i := Low(SideMenuGlyphsArray) to High(SideMenuGlyphsArray) do
    begin
      aItem := lvSideMenu.Items.Add;
      aItem.Data[SideMenuGlyph] := SideMenuGlyphsArray[i];
      aItem.Data[SideMenuTitle] := SideMenuTitlesArray[i];
      aItem.Data[SideMenuHeaderIndicator] := False;
      lvSideMenu.Adapter.ResetView(aItem);
    end;
  {<}
end;

procedure TfmMain.FormShow(Sender: TObject);
var
  SBHeight, NBHeight: Integer;
begin
  {> ��� ������ ����� ��������� ������ ���� �������
     � �������� �����}
  CreateSideMenu;
  recStatusbar.Fill.Color := PrimaryColor;
  recToolbar.Fill.Color := PrimaryColor;
  {<}
  {> ��������� ����� FontAwesome ��� ������ sbDetailsBack}
  FontAwesomeAssign(sbDetailsBack);
  sbDetailsBack.Text := fa_bars;
  {<}
  {> ������� Stausbar, ���� ������ Android >= 5}
  {$IFDEF ANDROID}
  if StrToInt(Copy(GetAndroidOSVersion, 1, 1)) >= 5 then
    begin
      StatusBarGetBounds(SBHeight, NBHeight);
      recStatusBar.Height := SBHeight;
      recStatusBar.Visible := True;
      recStatusBar.BringToFront;
      recToolbar.BringToFront;
    end;
  {$ENDIF}
  {<}
end;

procedure TfmMain.lvSideMenuApplyStyleLookup(Sender: TObject);
// ��������� ����� ��� �������� ����
begin
  lvSideMenu.SetColorItemFill(WhiteColor);
  lvSideMenu.SetColorItemSelected(LightPrimaryColor);
  if Assigned(lvSideMenu.Items[0]) then
    lvSideMenu.SetCustomColorForItem(0, PrimaryColor);
end;

procedure TfmMain.lvSideMenuItemClick(const Sender: TObject;
  const AItem: TListViewItem);
//���������� ������� �� ������ �������� ����
begin
  FSideMenuActivated := AItem.Index;
  mvSideMenu.HideMaster;
end;

procedure TfmMain.lvSideMenuTap(Sender: TObject; const Point: TPointF);
// ���������� ������� �� ������ �������� ����
var
  indx: Integer;
begin
  indx := lvSideMenu.FindItemByPosition(lvSideMenu.AbsoluteToLocal(Point).X, lvSideMenu.AbsoluteToLocal(Point).Y);
  if not Assigned(lvSideMenu.Items[indx]) then
    Exit;
  FSideMenuActivated := indx;
  mvSideMenu.HideMaster;
end;

procedure TfmMain.lvSideMenuUpdatingObjects(const Sender: TObject;
  const AItem: TListViewItem; var AHandled: Boolean);
// ����������� ��� �������� � ������� ����
var
  aImg: TListItemImage;
  aGlyph: TListItemText;
  aTitle: TListItemText;
begin
  if AItem.Data[SideMenuHeaderIndicator].AsBoolean then
    begin
      aImg := AItem.Objects.FindObjectT<TListItemImage>(SideMenuHeaderBackgroundImage);
      if aImg = nil then
        aImg := TListItemImage.Create(AItem);
      aImg.Name := SideMenuHeaderBackgroundImage;
      aImg.PlaceOffset.X := 0;
      aImg.PlaceOffset.Y := 0;
      aImg.Width := lvSideMenu.Width;
      aImg.Height := 176;
      aImg.Bitmap := AItem.Bitmap;
      aImg.ScalingMode := TImageScalingMode.Original;
      AItem.Height := 176;

      aTitle := AItem.Objects.FindObjectT<TListItemText>(SideMenuHeaderTitle);
      if aTitle = nil then
        aTitle := TListItemText.Create(AItem);
      aTitle.Name := SideMenuHeaderTitle;
      aTitle.TextAlign := TTextAlign.Leading;
      aTitle.TextVertAlign := TTextAlign.Trailing;
      aTitle.SelectedTextColor := WhiteColor;
      aTitle.TextColor := WhiteColor;
      aTitle.Font.Style := [TFontStyle.fsBold];
      aTitle.Font.Size := 14;
      aTitle.WordWrap := True;
      aTitle.PlaceOffset.X := 24;
      aTitle.PlaceOffset.Y := AItem.Height - 48;
      aTitle.Width := lvSideMenu.Width - 48;
      aTitle.Text := AItem.Data[SideMenuHeaderTitle].AsString;
      aTitle.Height := 24;
    end
  else
    begin
      aGlyph := AItem.Objects.FindObjectT<TListItemText>(SideMenuGlyph);
      if aGlyph = nil then
        aGlyph := TListItemText.Create(AItem);
      aGlyph.Name := SideMenuGlyph;
      aGlyph.TextAlign := TTextAlign.Leading;
      aGlyph.TextVertAlign := TTextAlign.Center;
      aGlyph.SelectedTextColor := PrimaryColor;
      aGlyph.TextColor := PrimaryColor;
      aGlyph.Font.Family := FontAwesomeName;
      aGlyph.Font.Style := [TFontStyle.fsBold];
      aGlyph.Font.Size := 24;
      aGlyph.WordWrap := True;
      aGlyph.PlaceOffset.X := 24;
      aGlyph.PlaceOffset.Y := 0;
      aGlyph.Width := 48;
      aGlyph.Text := AItem.Data[SideMenuGlyph].AsString;
      aGlyph.Height := 60;

      aTitle := AItem.Objects.FindObjectT<TListItemText>(SideMenuTitle);
      if aTitle = nil then
        aTitle := TListItemText.Create(AItem);
      aTitle.Name := SideMenuTitle;
      aTitle.TextAlign := TTextAlign.Leading;
      aTitle.TextVertAlign := TTextAlign.Center;
      aTitle.SelectedTextColor := PrimaryTextColor;
      aTitle.TextColor := PrimaryTextColor;
      aTitle.Font.Style := [];
      aTitle.Font.Size := 14;
      aTitle.WordWrap := True;
      aTitle.PlaceOffset.X := 72;
      aTitle.PlaceOffset.Y := 0;
      aTitle.Width := lvSideMenu.Width - 80;
      aTitle.Text := AItem.Data[SideMenuTitle].AsString;
      aTitle.Height := 60;
      AItem.Height := 60;
    end;

  AHandled := True;
end;

procedure TfmMain.mvSideMenuHidden(Sender: TObject);
//�������� �������� ��� ������� �������
//���� ��� ������ ����� ����, �� ��������� ��������������� ��������
begin
  if FSideMenuActivated <= 0 then
    Exit;
  {> ��������� ����������� ��������}
  ShowMessage(lvSideMenu.Items[FSideMenuActivated].Data[SideMenuTitle].AsString);
  {<}
  FSideMenuActivated := -1;
end;

procedure TfmMain.mvSideMenuStartShowing(Sender: TObject);
//��������� �������� ����� ������� �������:
//������� ��������� � �������� � ������� ��������
begin
  lvSideMenu.ItemIndex := -1;
  lvSideMenu.ScrollViewPos := 0;
end;

procedure TfmMain.sbDetailsBackClick(Sender: TObject);
//��������� ��������/������� ������� ��� ��������� �������� ��� ������ "�����"
//����������� ����, ��� ����� ����� ��������� �������� �������� Tag � ������ sbDetailsBack
begin
  if sbDetailsBack.Tag = 0 then
    begin
      if mvSideMenu.IsShowed then
        mvSideMenu.HideMaster
      else
        mvSideMenu.ShowMaster;
    end
  else
    begin
      {> ��������� �������� ��� ������ "�����"}
      {<}
      sbDetailsBack.Tag := 0;
      sbDetailsBack.Text := fa_bars;
    end;
end;

{ TSpeedButton }

procedure TSpeedButton.AdjustFixedSize(const Ref: TControl);
begin
  SetAdjustType(TAdjustType.None);
end;

end.
