{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFMisc;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
{$endif}
 llPDFTypes;

const
  MLS = MaxInt div 16;

type
  TTextCTM = record
    a, b, c, d, x, y: Extended;
  end;

  PExt = ^Single;

  TSingleArray = array [ 0..$FFFF ] of Single;
  PSingleArray = ^TSingleArray;

  TDoublePoint = record
    x, y: Extended;
  end;



  function IntToStrWithZero ( ID, Count: Integer ): AnsiString;
  function DPoint ( x, y: Extended ): TDoublePoint;
  function FormatFloat ( Value: Extended; Quality:Boolean = false ): AnsiString;
  procedure RotateCoordinate ( X, Y, Angle: Extended; var XO, YO: Extended );
  procedure NormalizeRect ( var Rect: TRect ); overload;
  procedure NormalizeRect ( var x1, y1, x2, y2: integer ); overload;
  procedure NormalizeRect ( var x1, y1, x2, y2: Extended ); overload;
  procedure QuickSortArray ( var Arr: array of Word );
  procedure swp ( var A, B: Integer ); overload;
  procedure swp ( var A, B: Extended ); overload;

  function CharSetToCodePage ( Charset: Byte ): Integer;
  function EscapeSpecialChar ( TextStr: AnsiString ): AnsiString;
  function StringToHex(TextStr:AnsiString;WithPrefix:Boolean = True):AnsiString;

  procedure FlipBMP(BMP:TBitmap;FlipX, FlipY:Boolean);


  function IsTrueType(FontName: String; Charset: Byte): Boolean;
  function GetFontByCharset ( Charset: Byte ): AnsiString;

  function ByteToANSIUNICODE ( B: Byte ): Word;
  function IsANSICode ( UNICODE: Word ): Boolean;
  function ANSIUNICODEToByte ( Unicode: Word ): Byte;


  function StrToOctet ( st: string ): string;
  function ByteToOct ( B: Byte ): string;

  function ByteToHex ( B: Byte ): AnsiString;
  function WordToHex ( W: Word ): AnsiString;

  function ReplStr ( Source: AnsiString; Ch: ANSIChar; Sub: AnsiString ): AnsiString;
  function UCase(const S: AnsiString): AnsiString;
  function LCase(const S: AnsiString): AnsiString;

{$ifndef UNICODE}
  function UnicodeChar ( Text: string; Charset: Integer ): string;
{$else}
  function UnicodeChar( Text:string):AnsiString;
{$endif}

  function PrepareFileSpec ( FileName: TFileName ): AnsiString;

  function GMTNow: TDateTime;
  function LocaleToGMT(const Value: TDateTime): TDateTime;

  function InvertPDFColor(Color:TPDFColor):TPDFColor;

  function PDFColorToStr(Color:TPDFColor):AnsiString;
  function PosText ( const FindString, SourceString: AnsiString; StartPos: Integer ): Integer;

  function GetRef(ID: Integer): AnsiString;

  function RectToStr( Left, Bottom, Right, Top: Integer): AnsiString;overload;
  function RectToStr( Rect: TRect): AnsiString;overload;
  function IStr( I: Integer): AnsiString;

  function WideStringToUTF8(const S: WideString): AnsiString;
  function UTF8ToWideString(const S: UTF8String): WideString;
  function MakeWideString(P:Pointer;Len:Integer):WideString;

  function ByteSwap ( Value: Cardinal ): Cardinal; overload;
  function ByteSwap ( Value: Integer ): Cardinal; overload;
  function ByteSwap (Value: Int64): Int64; overload;

  function ROL (x: LongWord; n: LongWord): LongWord;

  function DataToHex(Buffer:Pointer;Len:Cardinal):AnsiString;

  procedure StrAddTruncAt(Source:AnsiString; var Destination: AnsiString; APos: Integer; IncVal: Byte = 0);

type
{$ifdef UNICODE}
  PAnsiStringItem = ^TAnsiStringItem;
  TAnsiStringItem = record
    FString: AnsiString;
  end;
  PAnsiStringItemList = ^TAnsiStringItemList;
  TAnsiStringItemList = array[0..MLS] of TAnsiStringItem;

  TAnsiStringList = class
  private
    FList: PAnsiStringItemList;
    FCount: Integer;
    FCapacity: Integer;
    FLineBreak: AnsiString;
    procedure Grow;
    procedure Error(const Msg: string; Data: Integer); overload;
    procedure Error(Msg: PResStringRec; Data: Integer); overload;
    procedure InsertItem(Index: Integer; const S: AnsiString);
    function GetTextStr: AnsiString;
    procedure SetTextStr(const Value: AnsiString);
  protected
    function Get(Index: Integer): AnsiString;
    function GetCapacity: Integer;
    function GetCount: Integer;
    procedure Put(Index: Integer; const S: AnsiString);
    procedure SetCapacity(NewCapacity: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const S: AnsiString): Integer;
    procedure Clear;
    procedure Insert(Index: Integer; const S: AnsiString);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    property Strings[Index: Integer]: AnsiString read Get write Put; default;
    property Count: Integer read GetCount;
    property Text: AnsiString read GetTextStr write SetTextStr;
    property LineBreak: AnsiString read FLineBreak write FLineBreak;
   end;
{$else}
  TAnsiStringList = TStringList;
{$endif}


  TBitStream = class
  private
    FStream: TStream;
    FBuffer: Cardinal;
    FCurrentBit: Integer;
  public
    constructor Create(AStream:TStream);
    destructor Destroy;override;
    procedure Put(Value: Cardinal; Count: Integer); overload;
    procedure Put(Value: Int64; Count: Integer); overload;
    procedure Write(Buffer: Pointer; Count: Integer);
    procedure FlushBits;
  end;


  TObjList = class(TList)
  private
    FOwnsObjects: Boolean;
  protected
    function GetItem(Index: Integer): TObject;
  public

    procedure Clear;override;
    property Items[Index: Integer]: TObject read GetItem; default;
    constructor Create(AOwnsObjects: Boolean=True);
  end;


function log32(x: Cardinal): Integer;
function flp2(x:Cardinal):Cardinal;


implementation

uses
  llPDFDocument,
  llPDFResources
{$ifdef RTLINC}
{$ifndef W3264}
  ,RTLConsts
{$else}
  ,System.RTLConsts
{$endif}
{$endif }
;

const
  HEX: array [ 0..15 ] of ANSIChar= ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');


function RectToStr( Left, Bottom, Right, Top: Integer): AnsiString;
begin
{$ifdef UNICODE}
  Result := AnsiString( Format('%d %d %d %d',[Left, Bottom, Right, Top]));
{$else}
  Result := Format('%d %d %d %d',[Left, Bottom, Right, Top]);
{$endif}
end;

function RectToStr( Rect: TRect): AnsiString;
begin
  result := RectToStr(Rect.left,Rect.Bottom,Rect.right,Rect.Top)
end;

function IStr( I: Integer): AnsiString;
begin
{$ifdef UNICODE}
  Result := AnsiString( Format('%d',[i]));
{$else}
  Result := Format('%d',[i]);
{$endif}
end;


function MakeWideString(P:Pointer;Len:Integer):WideString;
begin
  if len = 0 then
  begin
    Result :='';
    exit;
  end;
  SetLength(Result,Len);
  move(P^,Result[1],Len shl 1);
end;


function ones32(x: Cardinal): Integer;
begin
  x := x - ((x shr 1) and $55555555);
  x := (((x shr 2) and $33333333) + (x and $33333333));
  x := (((x shr 4) + x) and $0f0f0f0f);
  x := x + (x shr 8);
  x := x + (x shr 16);
  result := x and $0000003f;
end;


function log32(x: Cardinal): Integer;
begin
  x  := x or (x shr 1);
  x  := x or (x shr 2);
  x  := x or (x shr 4);
  x  := x or (x shr 8);
  x  := x or (x shr 16);
  result := Ones32(x) - 1;
end;

function flp2(x:Cardinal):Cardinal;
var
  i,S: Cardinal;
begin
  i := 0;
  s := 1;
  while s <= x do
  begin
    i := s;
    s := s shl 1;
  end;
  result :=  i;
end;





function PosText ( const FindString, SourceString: AnsiString; StartPos: Integer ): Integer;
var
  S:AnsiString;
  p:Integer;
begin
  if StartPos= 1 then
    Result := Pos(FindString,SourceString)
  else
  begin
    S := Copy(SourceString,StartPos, Length(SourceString));
    p := Pos(FindString,s);
    if p = 0 then
      Result := 0
    else
      Result := p+StartPos-1;
  end;
end;



procedure StrAddTruncAt(Source:AnsiString; var Destination: AnsiString; APos: Integer; IncVal: Byte = 0);
var
  I: Integer;
  W: Word;
  D, S: PByteArray;
  DL, SL: Integer;
begin
  if Source <> '' then
  begin
    DL := Length(Destination);
    SL := Length(Source);
    if IncVal = 0 then
    begin
      if DL > APos then
      begin
        if DL >= SL + APos then
          Move(Source[1],Destination[1+APos],SL)
        else
          Move(Source[1],Destination[1+APos],DL - APos)
      end;
    end else
    begin
      if (APos < 0) or (DL < SL + APos) then
        raise Exception.Create('Invalid parameters. Access Violation');
      D := @Destination[APos+1];
      S := @Source[1];
      W := IncVal;
      for I :=  SL - 1 downto 0 do
      begin
        W := D^[I] + S^[I] + W;
        D^[I] := Lo(W);
        W := Hi(W);
      end;
    end;
  end;
end;


function ByteToHex ( B: Byte ): AnsiString;
begin
  Result := HEX [ b shr 4 ] + HEX [ b and $F ];
end;

function DataToHex(Buffer:Pointer;Len:Cardinal):AnsiString;
var
  I: Integer;
  B:PByte;
begin
  SetLength(Result,Len shl 1);
  B := Buffer;
  for i:= 0 to Len - 1 do
  begin
    Result[(i shl 1)+1] := Hex[B^ shr 4];
    Result[(i shl 1)+2] := Hex[B^ and $f];
    inc(B);
  end;

end;
function ROL (x: LongWord; n: LongWord): LongWord;
begin
  Result:= (x Shl n) Or (x Shr (32-n))
end;

function ByteSwap ( Value: Integer): Cardinal; overload;
begin
  Result := ByteSwap(Cardinal(Value));
end;


{$ifdef CPUX64}
function ByteSwap ( Value: Cardinal ): Cardinal; overload;
begin
  Result:= ((Value and $FF) shl 24) or ((Value and $FF00) shl 8)
    or ((Value and $FF0000) shr 8) or ((Value and $FF000000) shr 24);
end;

function ByteSwap (Value: Int64): Int64; overload;
begin
  Result := (Int64(byteSwap(LongWord(Value and $FFFFFFFF))) shl 32) or
    byteSwap(LongWord(Value shr 32));
end;
{$else}
function ByteSwap(Value: LongWord): Longword;overload;
asm
  bswap EAX
end;

function ByteSwap(Value: Int64): Int64;overload;
asm
  mov EAX,dword ptr [Value + 4]
  mov EDX,dword ptr [Value]
  bswap EAX
  bswap EDX
end;
{$endif}


function InvertPDFColor(Color:TPDFColor):TPDFColor;
begin
  Result.ColorSpace := Color.ColorSpace;
  Result.Cyan := 1 - Color.Cyan;
  Result.Magenta := 1 - Color.Magenta;
  Result.Yellow := 1 - Color.Yellow;
  Result.Key := 1 - Result.Key;
end;

function PDFColorToStr(Color:TPDFColor):AnsiString;
begin
  case Color.ColorSpace of
    csGray: Result := FormatFloat(Color.Gray);
    csRGB: Result := FormatFloat(Color.Red)+' '+FormatFloat(Color.Green)+' '+FormatFloat(Color.Blue);
  else
    Result := FormatFloat(Color.Cyan)+' '+FormatFloat(Color.Magenta)+' '+FormatFloat(Color.Yellow)+' '+FormatFloat(Color.Key);
  end;
end;

function PrepareFileSpec ( FileName: TFileName ): AnsiString;
var
  S: AnsiString;
  WS: AnsiString;
  FF: AnsiString;

  function RepS ( Source, Rep, RP: AnsiString ): AnsiString;
  var
    I, L: Integer;
    RS, S: AnsiString;
  begin
    S := Source;
    RS := '';
    L := Length ( Rep );
    I := Pos ( Rep, S );
    while I <> 0 do
    begin
      RS := RS + Copy ( S, 1, I - 1 ) + RP;
      Delete ( S, 1, L + I - 1 );
      I := Pos ( Rep, S );
    end; ;
    RS := RS + S;
    Result := RS;
  end;
begin
  WS := AnsiString(ExtractFilePath ( FileName ));
  if WS = '' then
  begin
    Result := AnsiString(FileName);
    Exit;
  end;
  FF := AnsiString(ExtractFileDrive ( FileName ));
  if FF = '' then
  begin
    S := RepS ( AnsiString(FileName), '\', '/' );
    if S [ 1 ] = '/' then
      S := '/' + S;
    Result := S;
    Exit;
  end;
  S := RepS ( AnsiString(FileName), '\\', '/' );
  S := RepS ( S, ':\', '/' );
  S := RepS ( S, '\', '/' );
  S := RepS ( S, ':', '/' );
  if S [ 1 ] <> '/' then
    S := '/' + S;
  Result := S;
end;


function GetGMTBias: Integer;
var
  info: TTimeZoneInformation;
  Mode: DWord;
begin
  Mode := GetTimeZoneInformation(info);
  Result := info.Bias;
  case Mode of
    TIME_ZONE_ID_STANDARD:
      Result := Result + info.StandardBias;
    TIME_ZONE_ID_DAYLIGHT:
      Result := Result + info.DaylightBias;
  end;
end;


function LocaleToGMT(const Value: TDateTime): TDateTime;
const
  MinsPerDay = 24 * 60;
begin
  Result := Value + (GetGMTBias / MinsPerDay);
end;

function GMTNow: TDateTime;
begin
  Result := LocaleToGMT(Now);
end;


{$ifndef UNICODE}
function UnicodeChar ( Text: string; Charset: Integer ): string;
var
  A: array of Word;
  W: PWideChar;
  CodePage: Integer;
  OS, i : Integer;
begin
  Result := '';
  case Charset of
    EASTEUROPE_CHARSET: CodePage := 1250;
    RUSSIAN_CHARSET: CodePage := 1251;
    GREEK_CHARSET: CodePage := 1253;
    TURKISH_CHARSET: CodePage := 1254;
    BALTIC_CHARSET: CodePage := 1257;
    SHIFTJIS_CHARSET: CodePage := 932;
    129: CodePage := 949;
    CHINESEBIG5_CHARSET: CodePage := 950;
    GB2312_CHARSET: CodePage := 936;
  else
    CodePage := 1252;
  end;
  OS := MultiByteToWideChar ( CodePage, 0, PChar ( Text ), Length ( Text ), nil, 0 );
  if OS = 0 then
    Exit;
  SetLength ( A, OS );
  W := @a [ 0 ];
  if MultiByteToWideChar ( CodePage, 0, PChar ( Text ), Length ( Text ), W, OS ) <> 0 then
  begin
    SetLength(Result,(OS + 1) shl 1);
    Result[1] := chr($FE);
    Result[2] := chr($FF);
    for i:= 0 to OS -1 do
    begin
      Result[3+i shl 1] := char(a[i] shr 8);
      Result[4+i shl 1] := char(a[i] and $FF);
    end;
  end;
end;
{$endif}

{$ifdef UNICODE}
function UnicodeChar( Text:string):AnsiString;
var
  i, L: integer;
begin
  L := Length( Text );
  SetLength(Result,(L + 1) shl 1);
  Result[1] := AnsiChar($FE);
  Result[2] := AnsiChar($FF);
  for i:= 1 to L  do
  begin
    Result[1+i shl 1] := AnsiChar(Word(Text[i]) shr 8);
    Result[2+i shl 1] := AnsiChar(Word(Text[i]) and $FF);
  end;
end;
{$endif}


function ReplStr ( Source: AnsiString; Ch: ANSIChar; Sub: AnsiString ): AnsiString;
var
  I: Integer;
begin
  Result := '';
  for i := 1 to Length ( Source ) do
    if Source [ I ] <> Ch then
      Result := Result + Source [ i ]
    else
      Result := Result + Sub;
end;


function UCase(const S: AnsiString): AnsiString;
var
  Ch: ANSIChar;
  L: Integer;
  Source, Dest: PANSIChar;
begin
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'a') and (Ch <= 'z') then Dec(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  end;
end;

function LCase (const S: AnsiString): AnsiString;
var
  Ch: ANSIChar;
  L: Integer;
  Source, Dest: PANSIChar;
begin
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'A') and (Ch <= 'Z') then inc(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  end;
end;


procedure QuickSortArray ( var Arr: array of Word );

  procedure QuickSort ( var A: array of Word; iLo, iHi: Integer );
  var
    Lo, Hi, Mid, T: Integer;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A [ ( Lo + Hi ) div 2 ];
    repeat
      while A [ Lo ] < Mid do
        Inc ( Lo );
      while A [ Hi ] > Mid do
        Dec ( Hi );
      if Lo <= Hi then
      begin
        T := A [ Lo ];
        A [ Lo ] := A [ Hi ];
        A [ Hi ] := T;
        Inc ( Lo );
        Dec ( Hi );
      end;
    until Lo > Hi;
    if Hi > iLo then
      QuickSort ( A, iLo, Hi );
    if Lo < iHi then
      QuickSort ( A, Lo, iHi );
  end;
begin
  QuickSort ( Arr, Low ( Arr ), High ( Arr ) );
end;


function WordToHex ( W: Word ): AnsiString;
begin
  Result := HEX [ (w shr 12) and $F ] + HEX [ (w shr 8) and $F ] + HEX [ (w shr 4) and $F ] + HEX [ w and $F ];
end;

function StringToHex(TextStr:AnsiString;WithPrefix:Boolean):AnsiString;
var
  i,sz: Integer;
begin
  if WithPrefix then
  begin
  sz:=(Length(TextStr)+1) shl 1;
  SetLength(Result, sz);
  Result[1]:='<';
  Result[sz]:='>';
  for i := 1  to Length(TextStr) do
  begin
    Result[ i shl 1] := HEX [  Byte(TextStr[i]) shr 4 ];
    Result[ i shl 1 + 1 ] := HEX [ Byte(TextStr[i]) and $F ];
  end;
  end else
  begin
    sz:=(Length(TextStr)) shl 1;
    SetLength(Result, sz);
    for i := 1  to Length(TextStr) do
    begin
      Result[ i shl 1 - 1] := HEX [  Byte(TextStr[i]) shr 4 ];
      Result[ i shl 1 ] := HEX [ Byte(TextStr[i]) and $F ];
    end;
  end;
end;


function ByteToOct ( B: Byte ): string;
begin
  Result := '';
  while B > 7 do
  begin
    Result := IntToStr ( B mod 8 ) + Result;
    b := b div 8;
  end;
  Result := IntToStr ( b ) + Result;
end;

function StrToOctet ( st: string ): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length ( st ) do
    Result := Result + '\' + ByteToOct ( Ord ( st [ i ] ) );
end;


function IsANSICode ( UNICODE: Word ): Boolean;
begin
  if UNICODE < 128 then
    Result := True
  else if ( UNICODE < 255 ) and ( UNICODE > 159 ) then
    Result := True
  else if ( UNICODE = 8364 ) or ( UNICODE = 129 ) or ( UNICODE = 8218 ) or ( UNICODE = 402 )
    or ( UNICODE = 8222 ) or ( UNICODE = 8230 ) or ( UNICODE = 8224 ) or ( UNICODE = 8225 )
    or ( UNICODE = 710 ) or ( UNICODE = 8240 ) or ( UNICODE = 352 ) or ( UNICODE = 8249 )
    or ( UNICODE = 338 ) or ( UNICODE = 141 ) or ( UNICODE = 381 ) or ( UNICODE = 143 )
    or ( UNICODE = 144 ) or ( UNICODE = 8216 ) or ( UNICODE = 8217 ) or ( UNICODE = 8220 )
    or ( UNICODE = 8221 ) or ( UNICODE = 8226 ) or ( UNICODE = 8211 ) or ( UNICODE = 8212 )
    or ( UNICODE = 732 ) or ( UNICODE = 8482 ) or ( UNICODE = 353 ) or ( UNICODE = 8250 )
    or ( UNICODE = 339 ) or ( UNICODE = 157 ) or ( UNICODE = 382 ) or ( UNICODE = 376 )
    then
    Result := True
  else
    Result := False;
end;

function ANSIUNICODEToByte ( Unicode: Word ): Byte;
begin
  if ( Unicode < 128 ) or ( ( UNICODE < 255 ) and ( UNICODE > 159 ) ) then
    Result := Byte ( Unicode )
  else if UNICODE = 8364 then
    Result := 128
  else if UNICODE = 129 then
    Result := 129
  else if UNICODE = 8218 then
    Result := 130
  else if UNICODE = 402 then
    Result := 131
  else if UNICODE = 8222 then
    Result := 132
  else if UNICODE = 8230 then
    Result := 133
  else if UNICODE = 8224 then
    Result := 134
  else if UNICODE = 8225 then
    Result := 135
  else if UNICODE = 710 then
    Result := 136
  else if UNICODE = 8240 then
    Result := 137
  else if UNICODE = 352 then
    Result := 138
  else if UNICODE = 8249 then
    Result := 139
  else if UNICODE = 338 then
    Result := 140
  else if UNICODE = 141 then
    Result := 141
  else if UNICODE = 381 then
    Result := 142
  else if UNICODE = 143 then
    Result := 143
  else if UNICODE = 144 then
    Result := 144
  else if UNICODE = 8216 then
    Result := 145
  else if UNICODE = 8217 then
    Result := 146
  else if UNICODE = 8220 then
    Result := 147
  else if UNICODE = 8221 then
    Result := 148
  else if UNICODE = 8226 then
    Result := 149
  else if UNICODE = 8211 then
    Result := 150
  else if UNICODE = 8212 then
    Result := 151
  else if UNICODE = 732 then
    Result := 152
  else if UNICODE = 8482 then
    Result := 153
  else if UNICODE = 353 then
    Result := 154
  else if UNICODE = 8250 then
    Result := 155
  else if UNICODE = 339 then
    Result := 156
  else if UNICODE = 157 then
    Result := 157
  else if UNICODE = 382 then
    Result := 158
  else if UNICODE = 376 then
    Result := 159
  else
    Result := 0;
end;

function ByteToANSIUNICODE ( B: Byte ): Word;
const
  UVAL: array [ 128..159 ] of word =
  ( 8364, 129, 8218, 402, 8222, 8230, 8224, 8225, 710, 8240, 352, 8249, 338, 141, 381, 143,
    144, 8216, 8217, 8220, 8221, 8226, 8211, 8212, 732, 8482, 353, 8250, 339, 157, 382, 376 );
begin
  if ( B < 128 ) or ( B > 159 ) then
    Result := B
  else
    Result := UVAL [ B ];
end;

type
  FND = record
    TT: Boolean;
    FontName: array [ 0..LF_FACESIZE - 1 ] of ANSIChar;
  end;
  Z = record
    Charset: Byte;
    Valid: boolean;
  end;

function Check1 ( const Enum: ENUMLOGFONTEX; Noop: Pointer; FT: DWORD; var F: Z ): Integer; stdcall;
begin
  if Enum.elfLogFont.lfCharSet = F.Charset then
  begin
    f.Valid := true;
    Result := 0;
  end
  else
    result := 1;
end;

function Check ( const Enum: ENUMLOGFONTEX; Noop: Pointer; FT: DWORD; var F: FND ): Integer; stdcall;
var
  LF: TLogFont;
  DC: HDC;
  ZZ: Z;
begin
  if FT = TRUETYPE_FONTTYPE then
  begin
    ZZ.Valid := False;
    ZZ.Charset := Enum.elfLogFont.lfCharSet;
    FillChar ( LF, SizeOf ( LF ), 0 );
    LF.lfCharSet := 1;
    LF.lfFaceName := Enum.elfLogFont.lfFaceName;
    ZZ.CharSet := Enum.elfLogFont.lfCharSet;
    DC := GetDC ( 0 );
    try
      EnumFontFamiliesEx ( DC, LF, @Check1, FInt( @ZZ ), 0 );
    finally
      ReleaseDC ( 0, DC );
    end;
    if ZZ.Valid then
    begin
      Move ( Enum.elfLogFont.lfFaceName, F.FontName, LF_FACESIZE - 1 );
      F.TT := True;
      Result := 0;
    end
    else
      result := 1;
  end
  else
    result := 1;
end;


function GetFontByCharset ( Charset: Byte ): AnsiString;
var
  LF: TLogFont;
  DC: HDC;
  F: FND;
begin
  if Charset = 1 then
    Charset := GetDefFontCharSet;
  FillChar ( LF, SizeOf ( LF ), 0 );
  FillChar ( F, SizeOf ( F ), 0 );
  F.TT := False;
  LF.lfCharSet := Charset;
  DC := GetDC ( 0 );
  try
    EnumFontFamiliesEx ( DC, LF, @Check, FInt ( @F ), 0 );
  finally
    ReleaseDC ( 0, DC );
  end;
  if F.TT then
    Result := F.FontName
  else
    Result := '';
end;


function IsTTCheck ( const Enum: ENUMLOGFONTEX; Noop: Pointer; FT: DWORD; var TT: Boolean ): Integer; stdcall;
begin
  TT := ( FT = TRUETYPE_FONTTYPE );
  Result := 0;
end;

function IsTrueType ( FontName: String; Charset: Byte ): Boolean;
var
  LF: TLogFont;
  TT: Boolean;
  DC: HDC;

begin
  if FontName = '' then
  begin
    Result := False;
    Exit;
  end;
  FillChar ( LF, SizeOf ( LF ), 0 );
  LF.lfCharSet := CHARSET;
  StrPCopy(LF.lfFaceName,FontName);
  DC := GetDC ( 0 );
  try
    EnumFontFamiliesEx ( DC, LF, @IsTTCheck, FInt ( @TT ), 0 );
  finally
    ReleaseDC ( 0, DC );
  end;
  Result := tt;
end;



procedure FlipBMP(BMP:TBitmap;FlipX, FlipY:Boolean);
begin
  if FlipX and FlipY then
  begin
    BMP.Canvas.StretchDraw(Rect(BMP.Width,BMP.Height,0, 0),BMP);
  end else
  if FlipX then
  begin
    BMP.Canvas.StretchDraw(Rect(BMP.Width,0,0, BMP.Height),BMP);
  end else
  if FlipY  then
  begin
    BMP.Canvas.StretchDraw(Rect(0,BMP.Height,BMP.Width, 0),BMP);
  end
end;



function EscapeSpecialChar ( TextStr: AnsiString ): AnsiString;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length ( TextStr ) do
    case TextStr [ I ] of
      '(': Result := Result + '\(';
      ')': Result := Result + '\)';
      '\': Result := Result + '\\';
      #13: Result := result + '\r';
      #10: Result := result + '\n';
    else
      Result := Result + textstr [ i ] ;
    end;
end;


function CharSetToCodePage ( Charset: Byte ): Integer;
begin
  if Charset = Default_Charset then
    Charset := GetDefFontCharSet;
  case Charset of
    ANSI_CHARSET: Result := 1252;
    RUSSIAN_CHARSET: Result := 1251;
    TURKISH_CHARSET: Result := 1254;
    SHIFTJIS_CHARSET: Result := 932;
    HANGEUL_CHARSET: Result := 949;
    CHINESEBIG5_CHARSET: Result := 950;
    GB2312_CHARSET: Result := 936;
    JOHAB_CHARSET: Result := 1361;
    HEBREW_CHARSET: Result := 1255;
    ARABIC_CHARSET: Result := 1256;
    GREEK_CHARSET: Result := 1253;
    THAI_CHARSET: Result := 874;
    EASTEUROPE_CHARSET: Result := 1250;
    MAC_CHARSET: Result := 10000;
    BALTIC_CHARSET: Result := 1257;
    VIETNAMESE_CHARSET: Result := 1258;
  else
    Result := 1252;
  end;
end;


procedure swp ( var A, B: Integer ); overload;
var
  C: Integer;
begin
  C := A;
  A := B;
  B := C;
end;

procedure swp ( var A, B: Extended ); overload;
var
  C: Extended;
begin
  C := A;
  A := B;
  B := C;
end;



procedure NormalizeRect ( var Rect: TRect ); overload;
begin
  if Rect.Left > Rect.Right then
    swp ( Rect.Left, Rect.Right );
  if Rect.Top > Rect.Bottom then
    swp ( Rect.Top, Rect.Bottom );
end;

procedure NormalizeRect ( var x1, y1, x2, y2: integer ); overload;
begin
  if x1 > x2 then
    swp ( x2, x1 );
  if y1 > y2 then
    swp ( y2, y1 );
end;

procedure NormalizeRect ( var x1, y1, x2, y2: Extended ); overload;
begin
  if x1 > x2 then
    swp ( x2, x1 );
  if y1 > y2 then
    swp ( y2, y1 );
end;


function FormatFloat ( Value: Extended; Quality:Boolean = false): AnsiString;
var
  c: Char;
begin
{$ifndef XE}
  c := DecimalSeparator;
  DecimalSeparator := '.';
{$ifndef UNICODE}
  if Quality then
    Result := SysUtils.FormatFloat ( '0.#####', Value )
  else
    Result := SysUtils.FormatFloat ( '0.##', Value );
{$else}
  if Quality then
    Result := AnsiString(SysUtils.FormatFloat ( '0.#####', Value ))
  else
    Result := AnsiString(SysUtils.FormatFloat ( '0.##', Value ));
{$endif}
  DecimalSeparator := c;
{$else}
  c := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
{$ifndef UNICODE}
  if Quality then
    Result := System.SysUtils.FormatFloat ( '0.#####', Value )
  else
    Result := System.SysUtils.FormatFloat ( '0.##', Value );
{$else}
  if Quality then
{$ifdef W3264}
    Result := AnsiString(System.SysUtils.FormatFloat ( '0.#####', Value ))
  else
    Result := AnsiString(System.SysUtils.FormatFloat ( '0.##', Value ));
{$else}
    Result := AnsiString(SysUtils.FormatFloat ( '0.#####', Value ))
  else
    Result := AnsiString(SysUtils.FormatFloat ( '0.##', Value ));
{$endif}
{$endif}
  FormatSettings.DecimalSeparator := c;

{$endif}

end;

procedure RotateCoordinate ( X, Y, Angle: Extended; var XO, YO: Extended );
var
  rcos, rsin: Extended;
begin
  Angle := Angle * ( PI / 180 );
  rcos := cos ( angle );
  rsin := sin ( angle );
  XO := rcos * x - rsin * y;
  YO := rsin * x + rcos * y;
end;

function Utf8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal; Source: PAnsiChar; SourceBytes: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Byte;
  wc: Cardinal;
begin
  if Source = nil then
  begin
    Result := 0;
    Exit;
  end;
  Result := Cardinal(-1);
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceBytes) and (count < MaxDestChars) do
    begin
      wc := Cardinal(Source[i]);
      Inc(i);
      if (wc and $80) <> 0 then
      begin
        if i >= SourceBytes then Exit;          // incomplete multibyte char
        wc := wc and $3F;
        if (wc and $20) <> 0 then
        begin
          c := Byte(Source[i]);
          Inc(i);
          if (c and $C0) <> $80 then Exit;      // malformed trail byte or out of range char
          if i >= SourceBytes then Exit;        // incomplete multibyte char
          wc := (wc shl 6) or (c and $3F);
        end;
        c := Byte(Source[i]);
        Inc(i);
        if (c and $C0) <> $80 then Exit;       // malformed trail byte

        Dest[count] := WideChar((wc shl 6) or (c and $3F));
      end
      else
        Dest[count] := WideChar(wc);
      Inc(count);
    end;
    if count >= MaxDestChars then count := MaxDestChars-1;
    Dest[count] := #0;
  end
  else
  begin
    while (i < SourceBytes) do
    begin
      c := Byte(Source[i]);
      Inc(i);
      if (c and $80) <> 0 then
      begin
        if i >= SourceBytes then Exit;          // incomplete multibyte char
        c := c and $3F;
        if (c and $20) <> 0 then
        begin
          c := Byte(Source[i]);
          Inc(i);
          if (c and $C0) <> $80 then Exit;      // malformed trail byte or out of range char
          if i >= SourceBytes then Exit;        // incomplete multibyte char
        end;
        c := Byte(Source[i]);
        Inc(i);
        if (c and $C0) <> $80 then Exit;       // malformed trail byte
      end;
      Inc(count);
    end;
  end;
  Result := count+1;
end;



function UTF8ToWideString(const S: UTF8String): WideString;
var
  L: Integer;
  Temp: WideString;
begin
  Result := '';
  if S = '' then Exit;
  SetLength(Temp, Length(S));

  L := Utf8ToUnicode(PWideChar(Temp), Length(Temp)+1, PAnsiChar(S), Length(S));
  if L > 0 then
    SetLength(Temp, L-1)
  else
    Temp := '';
  Result := Temp;
end;


function WideStringToUTF8(const S: WideString): AnsiString;
var
  SrcLength, DestIndex: Integer;
  Code: Word;
  i: Integer;
begin
  if S = '' then
  begin
    Result := '';
    Exit;
  end;
  SrcLength := Length(S);
  SetLength(Result, SrcLength * 3);
  DestIndex := 1;
  for i := 1 to SrcLength do
  begin
    Code := Word(S[i]);
    if Code <= $7F then
    begin
      Result[DestIndex] := AnsiChar(Code);
      Inc(DestIndex);
      Continue;
    end;
    if Code <= $7FF then
    begin
      Result[DestIndex] := AnsiChar($C0 or (Code shr 6));
      Result[DestIndex + 1] := AnsiChar((Code and $3F) or $80);
      Inc(DestIndex, 2);
      Continue;
    end;
    Result[DestIndex] := AnsiChar($E0 or (Code shr 12));
    Result[DestIndex + 1] := AnsiChar(((Code shr 6) and $3F) or $80);
    Result[DestIndex + 2] := AnsiChar((Code and $3F) or $80);
    Inc(DestIndex, 3);
  end;
  SetLength(Result, DestIndex - 1);
end;


function DPoint ( x, y: Extended ): TDoublePoint;
begin
  Result.x := x;
  Result.y := y;
end;

function IntToStrWithZero ( ID, Count: Integer ): AnsiString;
var
  s, d: AnsiString;
  I: Integer;
begin
  {$ifndef UNICODE}
  s := IntToStr ( ID );
  {$else}
  s := AnsiString(IntToStr ( ID ));
  {$endif}
  I := Count - Length ( s );
  d := '';
  for I := 0 to I - 1 do
    d := d + '0';
  Result := d + s;
end;

function GetRef(ID: Integer): AnsiString;
begin
  {$ifndef UNICODE}
  Result := Format('%d 0 R', [ID]);
  {$else}
  Result := AnsiString(Format('%d 0 R', [ID]));
  {$endif}
end;

{$ifdef UNICODE}

{ TAnsiStringList }

function TAnsiStringList.Add(const S: AnsiString): Integer;
begin
  Result := FCount;
  InsertItem(Result, S);
end;

procedure TAnsiStringList.Clear;
begin
  if FCount <> 0 then
  begin
    Finalize(FList^[0], FCount);
    FCount := 0;
    SetCapacity(0);
  end;
end;

constructor TAnsiStringList.Create;
begin
  FCount := 0;
  FCapacity := 0;
  FList := nil;
  FLineBreak := #13#10;
end;

destructor TAnsiStringList.Destroy;
begin
  if FCount <> 0 then Finalize(FList^[0], FCount);
  FCount := 0;
  SetCapacity(0);
  inherited;
end;

function TAnsiStringList.Get(Index: Integer): AnsiString;
begin
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);
  Result := FList^[Index].FString;
end;

function TAnsiStringList.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TAnsiStringList.GetCount: Integer;
begin
  Result := FCount;
end;


function TAnsiStringList.GetTextStr: AnsiString;
var
  I, L, Size, Count: Integer;
  P: PANSIChar;
  S, LB: AnsiString;
begin
  Count := GetCount;
  Size := 0;
  LB := LineBreak;
  for I := 0 to Count - 1 do Inc(Size, Length(Get(I)) + Length(LB));
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to Count - 1 do
  begin
    S := Get(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L * SizeOf(ANSIChar));
      Inc(P, L);
    end;
    L := Length(LB);
    if L <> 0 then
    begin
      System.Move(Pointer(LB)^, P^, L * SizeOf(ANSIChar));
      Inc(P, L);
    end;
  end;
end;

procedure TAnsiStringList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

procedure TAnsiStringList.Insert(Index: Integer; const S: AnsiString);
begin
  if (Index < 0) or (Index > FCount) then Error(@SListIndexError, Index);
    InsertItem(Index, S);
end;

procedure TAnsiStringList.Put(Index: Integer; const S: AnsiString);
begin
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);
  FList^[Index].FString := S;
end;

procedure TAnsiStringList.SaveToStream(Stream: TStream);
var
  S: AnsiString;
begin
  S := GetTextStr;
  Stream.WriteBuffer(s[1], Length(s));
end;

procedure TAnsiStringList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MLS) then
    Error(@SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(TAnsiStringItem));
    FCapacity := NewCapacity;
  end;
end;

procedure TAnsiStringList.SetTextStr(const Value: AnsiString);
var
  P, Start: PANSIChar;
  S: AnsiString;
begin
  Clear;
  P := Pointer(Value);
  if P <> nil then
    while P^ <> #0 do
    begin
      Start := P;
      while not (P^ in [#0, #10, #13]) do Inc(P);
      SetString(S, Start, P - Start);
      Add(S);
      if P^ = #13 then Inc(P);
      if P^ = #10 then Inc(P);
    end;
end;

procedure TAnsiStringList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EStringListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

procedure TAnsiStringList.Error(Msg: PResStringRec; Data: Integer);
begin
  Error(LoadResString(Msg), Data);
end;

procedure TAnsiStringList.InsertItem(Index: Integer; const S: AnsiString);
begin
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(TStringItem));
  with FList^[Index] do
  begin
    Pointer(FString) := nil;
    FString := S;
  end;
  Inc(FCount);
end;

procedure TAnsiStringList.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;


{$endif}


{ TBitStream }

constructor TBitStream.Create(AStream: TStream);
begin
  FStream := AStream;
  FBuffer := 0;
  FCurrentBit := 32;
end;

destructor TBitStream.Destroy;
begin
  if FCurrentBit <> 32 then
    FlushBits;
  inherited;
end;

procedure TBitStream.FlushBits;
begin
  FBuffer := ByteSwap(FBuffer);
  FCurrentBit := 32 - FCurrentBit;
  FStream.Write(FBuffer,(FCurrentBit +7) shr 3);
  FCurrentBit := 32;
  FBuffer := 0;
end;

procedure TBitStream.Put(Value: Cardinal; Count: Integer);
begin
  Value := Value and ($FFFFFFFF shr (32-Count));
  if FCurrentBit < Count then
  begin
    FBuffer := FBuffer or (Value shr (Count - FCurrentBit));
    Dec(Count,FCurrentBit);
    FCurrentBit := 0;
    FlushBits;
  end;
  FBuffer := FBuffer or (Value shl (FCurrentBit- Count));
  Dec(FCurrentBit, Count);
  if FCurrentBit = 0 then
    FlushBits;
end;

procedure TBitStream.Put(Value: Int64; Count: Integer);
begin
  if Count <= 32 then
  begin
    Put(Int64Rec(Value).Lo,Count);
  end else
  begin
    Put(Int64Rec(Value).Lo,32);
    Put(Int64Rec(Value).Hi,Count-32);
  end;
end;


procedure TBitStream.Write( Buffer: Pointer; Count: Integer);
var
  i: Integer;
  PB:PByte;
begin
  if FCurrentBit = 32 then
  begin
    FStream.Write(Buffer^,Count);
  end else
  begin
    PB := Buffer;
    for i := 0 to Count -1 do
    begin
      Put(PB^,8);
      inc(PB);
    end;
  end;
end;


{ TObjList }

function TObjList.GetItem(Index: Integer): TObject;
begin
  Result := inherited Items[Index];
end;

procedure TObjList.Clear;
var
  i: Integer;
begin
  if FOwnsObjects then
    for i := 0 to Count - 1 do
      TObject(Items[i]).Free;
  inherited Clear;
end;

constructor TObjList.Create(AOwnsObjects: Boolean);
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
end;



end.
