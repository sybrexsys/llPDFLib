{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFCCITT;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif} 
  llPDFresources, llPDFMisc;

type

  TableEntry = record
    Length: Byte;
    Code: Byte;
    RunLen: SmallInt;
  end;

  TCCITT = ( CCITT31D, CCITT32D, CCITT42D );
  TTag = ( G3_1D, G3_2D );
  Codes = array [ 0..108 ] of TableEntry;
  TCCITTCompression = class ( TObject )
  private
    RowBytes: Integer;
    RowPixels: Integer;
    FStream: TStream;
    FCT: TCCITT;
    Tag: TTag;
    K, MaxK: Integer;
    Refline: PByte;
    FBits: TBitStream;
    procedure PutSpan ( Span: Integer; C: Codes );
    function Find0Span ( BP: PByte; BS, BE: Integer ): Integer;
    function Find1Span ( BP: PByte; BS, BE: Integer ): Integer;
    function FindDiff ( BP: PByte; BS, BE: Integer; Color: Integer ): Integer;
    function FindDiff2 ( BP: PByte; BS, BE: Integer; Color: Integer ): Integer;
    function Encode1DRow ( BP: PByte; Bits: Integer ): Boolean;
    function Encode2DRow ( BP, RP: PByte; Bits: Integer ): Boolean;
    function is2DEncoding: Boolean;
  public
    procedure Execute ( B: TBitmap );
    property Stream: TStream read FStream write FStream;
    property CompressionType: TCCITT read FCT write FCT;
  end;

procedure SaveBMPtoCCITT ( BM: TBitmap; AStream: TStream; CCITT: TCCITT );

implementation

const
  EOL = 1;
  G3CODE_EOL = -1;
  G3CODE_INVALID = -2;
  G3CODE_EOF = -3;
  G3CODE_INCOMP = -4;
  WhiteCodes: Codes =
  ( ( Length: 8; Code: $35; RunLen: 0 ), ( Length: 6; Code: $7; RunLen: 1 ), ( Length: 4; Code: $7; RunLen: 2 ),
    ( Length: 4; Code: $8; RunLen: 3 ), ( Length: 4; Code: $B; RunLen: 4 ), ( Length: 4; Code: $C; RunLen: 5 ),
    ( Length: 4; Code: $E; RunLen: 6 ), ( Length: 4; Code: $F; RunLen: 7 ), ( Length: 5; Code: $13; RunLen: 8 ),
    ( Length: 5; Code: $14; RunLen: 9 ), ( Length: 5; Code: $7; RunLen: 10 ), ( Length: 5; Code: $8; RunLen: 11 ),
    ( Length: 6; Code: $8; RunLen: 12 ), ( Length: 6; Code: $3; RunLen: 13 ), ( Length: 6; Code: $34; RunLen: 14 ),
    ( Length: 6; Code: $35; RunLen: 15 ), ( Length: 6; Code: $2A; RunLen: 16 ), ( Length: 6; Code: $2B; RunLen: 17 ),
    ( Length: 7; Code: $27; RunLen: 18 ), ( Length: 7; Code: $C; RunLen: 19 ), ( Length: 7; Code: $8; RunLen: 20 ),
    ( Length: 7; Code: $17; RunLen: 21 ), ( Length: 7; Code: $3; RunLen: 22 ), ( Length: 7; Code: $4; RunLen: 23 ),
    ( Length: 7; Code: $28; RunLen: 24 ), ( Length: 7; Code: $2B; RunLen: 25 ), ( Length: 7; Code: $13; RunLen: 26 ),
    ( Length: 7; Code: $24; RunLen: 27 ), ( Length: 7; Code: $18; RunLen: 28 ), ( Length: 8; Code: $2; RunLen: 29 ),
    ( Length: 8; Code: $3; RunLen: 30 ), ( Length: 8; Code: $1A; RunLen: 31 ), ( Length: 8; Code: $1B; RunLen: 32 ),
    ( Length: 8; Code: $12; RunLen: 33 ), ( Length: 8; Code: $13; RunLen: 34 ), ( Length: 8; Code: $14; RunLen: 35 ),
    ( Length: 8; Code: $15; RunLen: 36 ), ( Length: 8; Code: $16; RunLen: 37 ), ( Length: 8; Code: $17; RunLen: 38 ),
    ( Length: 8; Code: $28; RunLen: 39 ), ( Length: 8; Code: $29; RunLen: 40 ), ( Length: 8; Code: $2A; RunLen: 41 ),
    ( Length: 8; Code: $2B; RunLen: 42 ), ( Length: 8; Code: $2C; RunLen: 43 ), ( Length: 8; Code: $2D; RunLen: 44 ),
    ( Length: 8; Code: $4; RunLen: 45 ), ( Length: 8; Code: $5; RunLen: 46 ), ( Length: 8; Code: $A; RunLen: 47 ),
    ( Length: 8; Code: $B; RunLen: 48 ), ( Length: 8; Code: $52; RunLen: 49 ), ( Length: 8; Code: $53; RunLen: 50 ),
    ( Length: 8; Code: $54; RunLen: 51 ), ( Length: 8; Code: $55; RunLen: 52 ), ( Length: 8; Code: $24; RunLen: 53 ),
    ( Length: 8; Code: $25; RunLen: 54 ), ( Length: 8; Code: $58; RunLen: 55 ), ( Length: 8; Code: $59; RunLen: 56 ),
    ( Length: 8; Code: $5A; RunLen: 57 ), ( Length: 8; Code: $5B; RunLen: 58 ), ( Length: 8; Code: $4A; RunLen: 59 ),
    ( Length: 8; Code: $4B; RunLen: 60 ), ( Length: 8; Code: $32; RunLen: 61 ), ( Length: 8; Code: $33; RunLen: 62 ),
    ( Length: 8; Code: $34; RunLen: 63 ), ( Length: 5; Code: $1B; RunLen: 64 ), ( Length: 5; Code: $12; RunLen: 128 ),
    ( Length: 6; Code: $17; RunLen: 192 ), ( Length: 7; Code: $37; RunLen: 256 ), ( Length: 8; Code: $36; RunLen: 320 ),
    ( Length: 8; Code: $37; RunLen: 384 ), ( Length: 8; Code: $64; RunLen: 448 ), ( Length: 8; Code: $65; RunLen: 512 ),
    ( Length: 8; Code: $68; RunLen: 576 ), ( Length: 8; Code: $67; RunLen: 640 ), ( Length: 9; Code: $CC; RunLen: 704 ),
    ( Length: 9; Code: $CD; RunLen: 768 ), ( Length: 9; Code: $D2; RunLen: 832 ), ( Length: 9; Code: $D3; RunLen: 896 ),
    ( Length: 9; Code: $D4; RunLen: 960 ), ( Length: 9; Code: $D5; RunLen: 1024 ), ( Length: 9; Code: $D6; RunLen: 1088 ),
    ( Length: 9; Code: $D7; RunLen: 1152 ), ( Length: 9; Code: $D8; RunLen: 1216 ), ( Length: 9; Code: $D9; RunLen: 1280 ),
    ( Length: 9; Code: $DA; RunLen: 1344 ), ( Length: 9; Code: $DB; RunLen: 1408 ), ( Length: 9; Code: $98; RunLen: 1472 ),
    ( Length: 9; Code: $99; RunLen: 1536 ), ( Length: 9; Code: $9A; RunLen: 1600 ), ( Length: 6; Code: $18; RunLen: 1664 ),
    ( Length: 9; Code: $9B; RunLen: 1728 ), ( Length: 11; Code: $8; RunLen: 1792 ), ( Length: 11; Code: $C; RunLen: 1856 ),
    ( Length: 11; Code: $D; RunLen: 1920 ), ( Length: 12; Code: $12; RunLen: 1984 ), ( Length: 12; Code: $13; RunLen: 2048 ),
    ( Length: 12; Code: $14; RunLen: 2112 ), ( Length: 12; Code: $15; RunLen: 2176 ), ( Length: 12; Code: $16; RunLen: 2240 ),
    ( Length: 12; Code: $17; RunLen: 2304 ), ( Length: 12; Code: $1C; RunLen: 2368 ), ( Length: 12; Code: $1D; RunLen: 2432 ),
    ( Length: 12; Code: $1E; RunLen: 2496 ), ( Length: 12; Code: $1F; RunLen: 2560 ), ( Length: 12; Code: $1; RunLen: G3Code_EOL ),
    ( Length: 9; Code: $1; RunLen: G3Code_INVALID ), ( Length: 10; Code: $1; RunLen: G3Code_INVALID ), ( Length: 11; Code: $1; RunLen: G3Code_INVALID ),
    ( Length: 12; Code: $0; RunLen: G3Code_INVALID ) );

  BlackCodes: Codes =
  ( ( Length: 10; Code: $37; RunLen: 0 ), ( Length: 3; Code: $2; RunLen: 1 ), ( Length: 2; Code: $3; RunLen: 2 ),
    ( Length: 2; Code: $2; RunLen: 3 ), ( Length: 3; Code: $3; RunLen: 4 ), ( Length: 4; Code: $3; RunLen: 5 ),
    ( Length: 4; Code: $2; RunLen: 6 ), ( Length: 5; Code: $3; RunLen: 7 ), ( Length: 6; Code: $5; RunLen: 8 ),
    ( Length: 6; Code: $4; RunLen: 9 ), ( Length: 7; Code: $4; RunLen: 10 ), ( Length: 7; Code: $5; RunLen: 11 ),
    ( Length: 7; Code: $7; RunLen: 12 ), ( Length: 8; Code: $4; RunLen: 13 ), ( Length: 8; Code: $7; RunLen: 14 ),
    ( Length: 9; Code: $18; RunLen: 15 ), ( Length: 10; Code: $17; RunLen: 16 ), ( Length: 10; Code: $18; RunLen: 17 ),
    ( Length: 10; Code: $8; RunLen: 18 ), ( Length: 11; Code: $67; RunLen: 19 ), ( Length: 11; Code: $68; RunLen: 20 ),
    ( Length: 11; Code: $6C; RunLen: 21 ), ( Length: 11; Code: $37; RunLen: 22 ), ( Length: 11; Code: $28; RunLen: 23 ),
    ( Length: 11; Code: $17; RunLen: 24 ), ( Length: 11; Code: $18; RunLen: 25 ), ( Length: 12; Code: $CA; RunLen: 26 ),
    ( Length: 12; Code: $CB; RunLen: 27 ), ( Length: 12; Code: $CC; RunLen: 28 ), ( Length: 12; Code: $CD; RunLen: 29 ),
    ( Length: 12; Code: $68; RunLen: 30 ), ( Length: 12; Code: $69; RunLen: 31 ), ( Length: 12; Code: $6A; RunLen: 32 ),
    ( Length: 12; Code: $6B; RunLen: 33 ), ( Length: 12; Code: $D2; RunLen: 34 ), ( Length: 12; Code: $D3; RunLen: 35 ),
    ( Length: 12; Code: $D4; RunLen: 36 ), ( Length: 12; Code: $D5; RunLen: 37 ), ( Length: 12; Code: $D6; RunLen: 38 ),
    ( Length: 12; Code: $D7; RunLen: 39 ), ( Length: 12; Code: $6C; RunLen: 40 ), ( Length: 12; Code: $6D; RunLen: 41 ),
    ( Length: 12; Code: $DA; RunLen: 42 ), ( Length: 12; Code: $DB; RunLen: 43 ), ( Length: 12; Code: $54; RunLen: 44 ),
    ( Length: 12; Code: $55; RunLen: 45 ), ( Length: 12; Code: $56; RunLen: 46 ), ( Length: 12; Code: $57; RunLen: 47 ),
    ( Length: 12; Code: $64; RunLen: 48 ), ( Length: 12; Code: $65; RunLen: 49 ), ( Length: 12; Code: $52; RunLen: 50 ),
    ( Length: 12; Code: $53; RunLen: 51 ), ( Length: 12; Code: $24; RunLen: 52 ), ( Length: 12; Code: $37; RunLen: 53 ),
    ( Length: 12; Code: $38; RunLen: 54 ), ( Length: 12; Code: $27; RunLen: 55 ), ( Length: 12; Code: $28; RunLen: 56 ),
    ( Length: 12; Code: $58; RunLen: 57 ), ( Length: 12; Code: $59; RunLen: 58 ), ( Length: 12; Code: $2B; RunLen: 59 ),
    ( Length: 12; Code: $2C; RunLen: 60 ), ( Length: 12; Code: $5A; RunLen: 61 ), ( Length: 12; Code: $66; RunLen: 62 ),
    ( Length: 12; Code: $67; RunLen: 63 ), ( Length: 10; Code: $F; RunLen: 64 ), ( Length: 12; Code: $C8; RunLen: 128 ),
    ( Length: 12; Code: $C9; RunLen: 192 ), ( Length: 12; Code: $5B; RunLen: 256 ), ( Length: 12; Code: $33; RunLen: 320 ),
    ( Length: 12; Code: $34; RunLen: 384 ), ( Length: 12; Code: $35; RunLen: 448 ), ( Length: 13; Code: $6C; RunLen: 512 ),
    ( Length: 13; Code: $6D; RunLen: 576 ), ( Length: 13; Code: $4A; RunLen: 640 ), ( Length: 13; Code: $4B; RunLen: 704 ),
    ( Length: 13; Code: $4C; RunLen: 768 ), ( Length: 13; Code: $4D; RunLen: 832 ), ( Length: 13; Code: $72; RunLen: 896 ),
    ( Length: 13; Code: $73; RunLen: 960 ), ( Length: 13; Code: $74; RunLen: 1024 ), ( Length: 13; Code: $75; RunLen: 1088 ),
    ( Length: 13; Code: $76; RunLen: 1152 ), ( Length: 13; Code: $77; RunLen: 1216 ), ( Length: 13; Code: $52; RunLen: 1280 ),
    ( Length: 13; Code: $53; RunLen: 1344 ), ( Length: 13; Code: $54; RunLen: 1408 ), ( Length: 13; Code: $55; RunLen: 1472 ),
    ( Length: 13; Code: $5A; RunLen: 1536 ), ( Length: 13; Code: $5B; RunLen: 1600 ), ( Length: 13; Code: $64; RunLen: 1664 ),
    ( Length: 13; Code: $65; RunLen: 1728 ), ( Length: 11; Code: $8; RunLen: 1792 ), ( Length: 11; Code: $C; RunLen: 1856 ),
    ( Length: 11; Code: $D; RunLen: 1920 ), ( Length: 12; Code: $12; RunLen: 1984 ), ( Length: 12; Code: $13; RunLen: 2048 ),
    ( Length: 12; Code: $14; RunLen: 2112 ), ( Length: 12; Code: $15; RunLen: 2176 ), ( Length: 12; Code: $16; RunLen: 2240 ),
    ( Length: 12; Code: $17; RunLen: 2304 ), ( Length: 12; Code: $1C; RunLen: 2368 ), ( Length: 12; Code: $1D; RunLen: 2432 ),
    ( Length: 12; Code: $1E; RunLen: 2496 ), ( Length: 12; Code: $1F; RunLen: 2560 ), ( Length: 12; Code: $1; RunLen: G3Code_EOL ),
    ( Length: 9; Code: $1; RunLen: G3Code_INVALID ), ( Length: 10; Code: $1; RunLen: G3Code_INVALID ), ( Length: 11; Code: $1; RunLen: G3Code_INVALID ),
    ( Length: 12; Code: $0; RunLen: G3Code_INVALID ) );

  horizcode: TableEntry = ( Length: 3; Code: $1 );
  passcode: TableEntry = ( Length: 4; Code: $1 );
  vcodes: array [ 0..6 ] of TableEntry = ( ( Length: 7; Code: $3 ), ( Length: 6; Code: $3 ), ( Length: 3; Code: $3 ),
    ( Length: 1; Code: $1 ), ( Length: 3; Code: $2 ), ( Length: 6; Code: $2 ), ( Length: 7; Code: $2 ) );


  msbmask: array [ 0..8 ] of Byte = ( $0, $01, $03, $07, $0F, $1F, $3F, $7F, $FF );
  zeroruns: array [ 0..255 ] of byte = (
    8, 7, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
  oneruns: array [ 0..255 ] of byte = (
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 7, 8 );


{ TCCITTCompression }


function TCCITTCompression.Encode1DRow ( BP: PByte; Bits: Integer ): Boolean;
var
  Span, BS: Integer;
begin
  BS := 0;
  Result := True;
  repeat
    Span := find0span ( BP, BS, Bits );
    putspan ( Span, WhiteCodes );
    Inc ( BS, Span );
    if bs >= Bits then
      Break;
    Span := find1span ( BP, BS, Bits );
    putspan ( Span, BlackCodes );
    Inc ( BS, Span );
    if bs >= Bits then
      Break;
  until False;
end;

function TCCITTCompression.Encode2DRow ( BP, RP: PByte; Bits: Integer ): Boolean;
var
  a0, a1, b1, a2, b2, d: Integer;

  function Pixel ( P: PByte; ix: Integer ): byte;
  begin
    Inc ( P, ix shr 3 );
    Result := ( p^ shr ( 7 - ( ix and 7 ) ) ) and 1;
  end;
begin
  Result := True;
  a0 := 0;
  if Pixel ( BP, 0 ) <> 0 then
    a1 := 0
  else
    a1 := finddiff ( BP, 0, Bits, 0 );
  if Pixel ( RP, 0 ) <> 0 then
    b1 := 0
  else
    b1 := finddiff ( RP, 0, Bits, 0 );
  repeat
    b2 := finddiff2 ( rp, b1, bits, PIXEL ( rp, b1 ) );
    if b2 >= a1 then
    begin
      d := b1 - a1;
      if not ( ( d >= -1 ) and ( d <= 3 ) ) then
      begin
        a2 := finddiff2 ( bp, a1, bits, PIXEL ( bp, a1 ) );
        FBits.Put ( horizcode.Code, horizcode.Length );
        if ( ( a0 + a1 = 0 ) or ( PIXEL ( bp, a0 ) = 0 ) ) then
        begin
          putspan ( a1 - a0, WhiteCodes );
          putspan ( a2 - a1, BlackCodes );
        end
        else
        begin
          putspan ( a1 - a0, BlackCodes );
          putspan ( a2 - a1, WhiteCodes );
        end;
        a0 := a2;
      end
      else
      begin
        FBits.Put ( vcodes [ d + 3 ].Code, vcodes [ d + 3 ].Length );
        a0 := a1;
      end
    end
    else
    begin
      FBits.Put ( passcode.Code, passcode.Length );
      a0 := b2;
    end;
    if a0 >= Bits then
      Break;
    a1 := finddiff ( bp, a0, bits, PIXEL ( bp, a0 ) );
    b1 := finddiff ( rp, a0, bits, ( not PIXEL ( bp, a0 ) ) and 1 );
    b1 := finddiff ( rp, b1, bits, PIXEL ( bp, a0 ) );
  until False;
end;

procedure TCCITTCompression.Execute ( B: TBitmap );
var
  P, L, M: PByte;
  i, j: Integer;
begin
  if FStream = nil then
    raise Exception.Create ( 'Not set output stream.' );
  if B.PixelFormat <> pf1bit then
    raise Exception.Create ( 'Not b/w image.' );
  if ( B.Width = 0 ) or ( B.Height = 0 ) then
    Exit;
  FBits := TBitStream.Create(FStream);
  try
    RowPixels := B.Width;
    RowBytes := ( B.Width + 7 ) shr 3;
    GetMem ( P, RowBytes );
    try
      if FCT <> ccitt31d then
        GetMem ( Refline, RowBytes )
      else
        Refline := nil;
      try
        Tag := G3_1D;
        if Refline <> nil then
          FillChar ( Refline^, RowBytes, 0 );
        if is2DEncoding then
        begin
          k := 2;
          maxk := 2;
        end
        else
        begin
          k := 0;
          maxk := 0;
        end;
        for i := 0 to B.Height - 1 do
        begin
          L := P;
          M := B.ScanLine [ i ];
          for j := 0 to RowBytes - 1 do
          begin
            L^ := not M^;
            Inc ( L );
            Inc ( M );
          end;
          case FCT of
            CCITT42D:
              begin
                if not Encode2DRow ( P, Refline, RowPixels ) then
                  raise Exception.Create ( 'Error' );
                Move ( P^, refline^, RowBytes );
              end;
            CCITT31D:
              begin
                if not Encode1DRow ( P, RowPixels ) then
                  raise Exception.Create ( 'Error' );
              end;
            CCITT32D:
              begin
                FBits.Put ( 1, 12 );
                FBits.Put ( 0, 1 );
                if not Encode2DRow ( P, Refline, RowPixels ) then
                  raise Exception.Create ( 'Error' );
                Move ( P^, refline^, RowBytes );
              end;
          end;
        end;
      finally
        if Refline <> nil then
          FreeMem ( Refline );
      end;
    finally
      FreeMem ( P );
    end;
  finally
    FBits.Free;
  end;
end;

function TCCITTCompression.Find0Span ( BP: PByte; BS, BE: Integer ): Integer;
var
  Bits: Integer;
  Span, N: Integer;
begin
  Bits := BE - BS;
  Inc ( BP, bs shr 3 );
  n := ( bs and 7 );
  if ( bits > 0 ) and ( Boolean ( N ) ) then
  begin
    span := zeroruns [ ( bp^ shl n ) and $FF ];
    if ( span > 8 - n ) then
      span := 8 - n;
    if ( span > bits ) then
      span := bits;
    if ( n + span < 8 ) then
    begin
      Result := span;
      Exit;
    end;
    Dec ( Bits, Span );
    Inc ( BP );
  end
  else
    span := 0;
  while bits >= 8 do
  begin
    if BP^ <> 0 then
    begin
      Result := span + zeroruns [ bp^ ];
      Exit;
    end;
    Inc ( Span, 8 );
    Dec ( Bits, 8 );
    Inc ( BP );
  end;
  if bits > 0 then
  begin
    n := zeroruns [ bp^ ];
    if N > Bits then
      Inc ( Span, Bits )
    else
      Inc ( Span, N );
  end;
  Result := span;
end;

function TCCITTCompression.Find1Span ( BP: PByte; BS, BE: Integer ): Integer;
var
  Bits: Integer;
  Span, N: Integer;
begin
  Bits := BE - BS;
  Inc ( BP, bs shr 3 );
  n := ( bs and 7 );
  if ( bits > 0 ) and ( Boolean ( N ) ) then
  begin
    span := oneruns [ ( bp^ shl n ) and $FF ];
    if ( span > 8 - n ) then
      span := 8 - n;
    if ( span > bits ) then
      span := bits;
    if ( n + span < 8 ) then
    begin
      Result := span;
      Exit;
    end;
    Dec ( Bits, Span );
    Inc ( BP );
  end
  else
    span := 0;
  while bits >= 8 do
  begin
    if BP^ <> $FF then
    begin
      Result := span + oneruns [ bp^ ];
      Exit;
    end;
    Inc ( Span, 8 );
    Dec ( Bits, 8 );
    Inc ( BP );
  end;
  if bits > 0 then
  begin
    n := oneruns [ bp^ ];
    if N > Bits then
      Inc ( Span, Bits )
    else
      Inc ( Span, N );
  end;
  Result := span;
end;

function TCCITTCompression.FindDiff ( BP: PByte; BS, BE: Integer;
  Color: Integer ): Integer;
begin
  if Color = 0 then
    Result := BS + Find0Span ( BP, BS, BE )
  else
    Result := BS + Find1Span ( BP, BS, BE );
end;

function TCCITTCompression.FindDiff2 ( BP: PByte; BS, BE: Integer;
  Color: Integer ): Integer;
begin
  if BS < BE then
    Result := Finddiff ( BP, BS, BE, Color )
  else
    Result := BE;
end;


function TCCITTCompression.is2DEncoding: Boolean;
begin
  Result := ( FCT = CCITT32D ) or ( FCT = CCITT42D );
end;


procedure TCCITTCompression.PutSpan ( Span: Integer; C: Codes );
var
  Code, Length: Byte;
begin
  while span >= 2624 do
  begin
    Code := C [ 63 + ( 2560 shr 6 ) ].Code;
    Length := C [ 63 + ( 2560 shr 6 ) ].Length;
    FBits.Put ( Code, Length );
    Dec ( Span, C [ 63 + ( 2560 shr 6 ) ].RunLen );
  end;
  if Span >= 64 then
  begin
    Code := C [ 63 + ( Span shr 6 ) ].Code;
    Length := C [ 63 + ( Span shr 6 ) ].Length;
    FBits.Put ( Code, Length );
    Dec ( Span, C [ 63 + ( Span shr 6 ) ].RunLen );
  end;
  Code := C [ Span ].Code;
  Length := C [ Span ].Length;
  FBits.Put ( Code, Length );
end;


procedure SaveBMPtoCCITT ( BM: TBitmap; AStream: TStream; CCITT: TCCITT );
var
  CC: TCCITTCompression;
begin
  CC := TCCITTCompression.Create;
  try
    CC.CompressionType := CCITT;
    CC.Stream := AStream;
    CC.Execute ( BM );
  finally
    CC.Free;
  end;
end;


end.

