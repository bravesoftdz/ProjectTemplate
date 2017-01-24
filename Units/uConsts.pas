unit uConsts;

interface

uses FontAwesome;

const
  {> ��������� ��� �������� �������}
  SideMenuHeaderResourceName = 'SIDEMENU_';
  SideMenuHeaderIndicator = 'header';
  SideMenuHeaderBackgroundImage = 'smBackgroundImage';
  SideMenuHeaderTitle = 'smHeaderTitle';
  SideMenuGlyph = 'smGlypth';
  SideMenuTitle = 'smTitile';
  //������ � �������� ������� ����, ������� �� FontAwesome}
  SideMenuGlyphsArray: array [0 .. 3] of string =
  (fa_book, fa_bell, fa_calendar, fa_info_circle);
  //������ � ������� ������� ����}
  SideMenuTitlesArray: array [0 .. 3] of string =
  ('����� ���� #1', '����� ���� #2',
   '����� ���� #3', '����� ���� #4');
  {<}

  {> ����� ����������}
  PrimaryColor = $FF3F51B5;
  LightPrimaryColor = $FFC5CAE9;
  DarkPrimaryColor = $FF303F9F;
  WhiteColor = $FFFFFFFF;
  AccentColor = $FFFF5722;
  PrimaryTextColor = $FF212121;
  SecondaryTextColor = $FF757575;
  DividerColor = $FFBDBDBD;
  {<}


implementation

end.
