{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFTrueType;
{$i pdf.inc}
interface
uses
{$IFNDEF USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$ELSE}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$ENDIF}
  llPDFTypes, llPDFMisc;

type

  ETTFException = class(Exception);

  TActionDC = procedure(DC:HDC) of object;

  TIdxRec = record
    First: Word;
    Second: Word;
  end;

  TIdxRecArray = array of TIdxRec;

  TNewCharInfo = record
    Width: Integer;
    NewCharacter: AnsiChar;
    FontIndex: Integer;
  end;
  PNewCharInfo = ^TNewCharInfo; 


  TGlyphInfo = record
    CharInfo:TNewCharInfo;
    Unicode: Word;
    BaseWidth: Integer;
    AddWidth: Integer;
    DataOffset:Integer;
    Size: Integer;
    NewIndex: Integer;
    Used: Boolean;
    ExtUsed: Boolean;
  end;
  PGlyphInfo = ^TGlyphInfo;

  TGlyphInfoArray = array of TGlyphInfo;

  TUnicodeArray = array  of Word;

  
  TTrueTypeTable = record
    Size: Cardinal;
    Table: Pointer;
    Offset:Cardinal;
  end;

  TTrueTypeTables= record
    Head:TTrueTypeTable;
    Hhea:TTrueTypeTable;
    Loca:TTrueTypeTable;
    Maxp:TTrueTypeTable;
    Cvt: TTrueTypeTable;
    Prep: TTrueTypeTable;
    Glyf:TTrueTypeTable;
    Hmtx:TTrueTypeTable;
    Fpgm:TTrueTypeTable;
    Cmap:TTrueTypeTable;
    Name:TTrueTypeTable;
    Post:TTrueTypeTable;
  end;




  TUnicodeToIndex = record
    Unicode: Word;
    Index: Integer;
  end;


  TTrueTypeManager = class
  private
    FTables:TTrueTypeTables;
    FUnicodeMap: array of TUnicodeToIndex;
    FGlyphsList: array of TGlyphInfo;
    FIsMono: Boolean;
    FDescent: Integer;
    FAscent:Integer;
    FUnitsPerEm: Integer;
    FLast: Integer;
    FGlyphsLoaded: Boolean;
    OTM: OUTLINETEXTMETRIC;
    FFontName: String;
    FFontStyle: TFontStyles;
    Idxes: array[32..127] of integer;
    FFontPostScriptName:AnsiString;

    function CalculateCheckSum(Buffer: Pointer; Size: Cardinal): Cardinal;
    procedure CopyTable(Src: TTrueTypeTable; var Dest: TTrueTypeTable);
    procedure ExtractNameTable(Src: TTrueTypeTable; var Dest: TTrueTypeTable);
    procedure ExtractPostTable(Src: TTrueTypeTable; var Dest: TTrueTypeTable);
    procedure LoadFontInfo(DC: HDC);
    procedure LoadGlyphsInfo(DC: HDC);
    procedure LoadOneTable(DC: HDC; TableName: String;  var Table: TTrueTypeTable; CanIgnore: Boolean = False);
    procedure ProcessCMAP(Buffer: Pointer);
    function GetAscent: Integer;
    function GetDescent: Integer;
    function GetGlyphCount: Integer;
    function GetGlyph(Index: Integer): PGlyphInfo;
    function GetFontBox: TRect;
    function GetItalicAngle: Integer;
    function GetGlyphByUnicode(Index: Word): PGlyphInfo;
    procedure CreateFont(AStream: TStream; Tables: TTrueTypeTables);
    procedure FreeTables(Tables: TTrueTypeTables);
    procedure ClearUsedGlyphs;
    procedure MarkGlyphAsReaded(Glyph: PGlyphInfo);
    procedure WorkWithDC(Action: TActionDC);
    procedure QuickSortIdxRec(var Arr: TIdxRecArray; L, R: Integer);
    procedure CheckTables(Tables: TTrueTypeTables; var Count: Integer);
    procedure SaveTableToStream(Name: AnsiString; MainStream, AStream: TStream; var Table: TTrueTypeTable; Delta: Cardinal);
    procedure SaveAllInfo(Stream:TStream; MaxIdx:Integer);
  public
    constructor Create(FontName:String;FontStyle:TFontStyles);
    destructor Destroy;override;
    function GetIdxByUnicode(Unicode: Word): Integer;
    procedure PrepareASCIIFont(Used:PByteArray;Stream:TStream);
    procedure PrepareFont(UsedUnicodes:TUnicodeArray;Stream: TStream);overload;
    procedure PrepareFont(Indexes:PInteger;Len: Integer;Stream: TStream);overload;
    property Ascent: Integer read GetAscent;
    property Descent: Integer read GetDescent;
    property FontBox : TRect read GetFontBox;
    property ItalicAngle: Integer read GetItalicAngle;
    property GlyphCount: Integer read GetGlyphCount;
    property Glyphs[Index: Integer]: PGlyphInfo read GetGlyph;
    property GlyphByUnicode[Index:Word]: PGlyphInfo read GetGlyphByUnicode;
    property PostScriptName:AnsiString read FFontPostScriptName;
  end;

implementation

uses llPDFResources;
const
  TTF_TABLES_COUNT = 12;
  LIBRARY_PREFIX = 'llPDFLib subset of ';

type
  TCMapSegment = record
    StartCode:Word;
    EndCode:Word;
    idDelta:SmallInt;
    idRangeOffset:Word;
  end;

  // True Type Section

  THeadRec = packed record
    version_number: FIXED;
    fontRevision: FIXED;
    checkSum: Cardinal;
    magicNumber: Cardinal;
    flags: Word;
    unitsPerEm: Word;
    two_date: array [ 1..16 ] of byte;
    xMin: SmallInt;
    yMin: SmallInt;
    xMax: SmallInt;
    yMax: SmallInt;
    macStyle: Word;
    lowestRec: Word;
    fontDirection: SmallInt;
    indexToLocFormat: SmallInt;
    glyphDataFormat: SmallInt
  end;
  PHeadRec = ^THeadRec;

  TFileHeaderRec = packed record
    ScalarType: Cardinal;
    NumTables: Word;
    SearchRange: Word;
    EntrySelector: Word;
    RangeShift: Word;
  end;

  TTableInfoRec = packed record
    Tag: Cardinal;
    Checksum: Cardinal;
    Offset: Cardinal;
    Length: Cardinal;
  end;

// Maxp Section

  TMAXP_Table_Header = packed record
    version: fixed;
    numGlyphs: Word;
    maxPoints: Word;
    maxContours: Word;
    maxCompositePoints: Word;
    maxCompositeContours: Word;
    maxZones: Word;
    maxTwilightPoints: Word;
    maxStorage: Word;
    maxFunctionDefs: Word;
    maxInstructionDefs: Word;
    maxStackElements: Word;
    maxSizeOfInstructions: Word;
    maxComponentElements: Word;
    maxComponentDepth: Word;
  end;
  PMAXP_Table_Header = ^TMAXP_Table_Header;


//hhea section
  THHEA_Table_Header = packed record
    TablVer: Longint;
    Ascender: Word;
    Descender: Word;
    LineGap: Word;
    advanceWidthMax: Word;
    minLeftSideBearing: Word;
    minRightSideBearing: Word;
    xMaxExtent: Word;
    caretSlopeRise: SmallInt;
    caretSlopeRun: SmallInt;
    caretOffset: SmallInt;
    res1: SmallInt;
    res2: SmallInt;
    res3: SmallInt;
    res4: SmallInt;
    metricDataFormat: SmallInt;
    numberOfHMetrics: Word;
  end;
  PHHEA_Table_Header = ^ THHEA_Table_Header;


  TNAME_Table_Header= packed record
    FormatSelector: WORD;
    NumRecords: WORD;
    StringsOffset: WORD;
  end;
  PNAME_Table_Header = ^TNAME_Table_Header;


  TNAME_Record_Info = packed record
    PlatformID: WORD;        // $0003 for Windows
    EncodingID: WORD;        // $0001 for Windows/Unicode
    LanguageID: WORD;        // $0409 for Windows/English
    NameID: WORD;            // see nameXXX constants
    StringLength: WORD;      // ...in bytes
    StringOffset: WORD;      // ...from start of storage
  end;
  PNAME_Record_Info = ^TNAME_Record_Info;

  TPOST_Table_Header = packed record
    Format: FIXED;
    ItalicAngle: FIXED;
    UnderlinePosition: Smallint;
    UnderlineThickness:SmallInt;
    IsFixedPitch:Cardinal;
    MinMemType42:Cardinal;
    MaxMemTYpe42:Cardinal;
    MinMemType1:Cardinal;
    MaxMemTYpe1:Cardinal;
  end;




// cmap section

  TCMAP_Table_Header = packed record
    Version: Word;
    NumTables: Word;
  end;
  PCMAP_Table_Header = ^TCMAP_Table_Header;

  TCMAP_Record_Info = packed record
    Platform_ID: Word;
    Encoding_ID: Word;
    Offset: Cardinal;
  end;
  PCMAP_Record_Info = ^TCMAP_Record_Info;

  TCMAP_0_Record = packed record
    Format: Word;
    Length: Word;
    Languauge: Word;
    Index:array[0..255] of Byte;
  end;

  PCMAP_0_Record = ^TCMAP_0_Record;

  TCMAP_4_Record = packed record
    Format: Word;
    Length: Word;
    Version: Word;
    SegCountX2: Word;
    SearchRange: Word;
    EntrySelector: Word;
    RangeShift: Word;
  end;
  PCMAP_4_Record = ^TCMAP_4_Record;


  TGlyphHeader = packed record
    ContourCount: SmallInt;
    XMin: Word;
    YMix: Word;
    XMax: Word;
    YMax: Word;
  end;
  PGlyphHeader = ^TGlyphHeader;

  TCompoundGlyphInfo = packed record
    Flags: Word;
    GlyphIndex:Word;
  end;
  PCompoundGlyphInfo = ^TCompoundGlyphInfo;







function TTrueTypeManager.CalculateCheckSum(Buffer: Pointer; Size: Cardinal): Cardinal;
var
  i:integer;
  Ar: PCardinalArray;
begin
  Ar := Buffer;
  Result := 0;
  for i := 0 to (Size+3) shr 2 - 1 do
    result := result + ByteSwap(Ar^[i]);
end;

procedure TTrueTypeManager.CopyTable(Src: TTrueTypeTable; var Dest: TTrueTypeTable);
begin
  if Src.Size > 0 then
  begin
    Dest.Table := GetMemory(Src.Size);
    Dest.Size := Src.Size;
    MoveMemory(Dest.Table,Src.Table,Src.Size);
  end else
  begin
    Dest.Size := 0;
    Dest.Table := nil;
  end;
end;

procedure TTrueTypeManager.WorkWithDC(Action:TActionDC);
var
  DC: HDC;
  Font: TLogFont;
  Obj: THandle;
begin
  DC := CreateCompatibleDC(0);
  try
    FillChar(Font,sizeof(Font),0);
    with Font do
    begin
      lfHeight := -1000;
      lfWidth := 0;
      lfEscapement := 0;
      lfOrientation := 0;
      if fsBold in FFontStyle then
        lfWeight := FW_BOLD
      else
        lfWeight := FW_NORMAL;
      lfItalic := Byte ( fsItalic in FFontStyle );
      lfUnderline := Byte ( fsUnderline in FFontStyle );
      lfStrikeOut := Byte ( fsStrikeOut in FFontStyle );
      lfCharSet := DEFAULT_CHARSET;
      StrPCopy(lfFaceName, FFontName);
      lfQuality := DEFAULT_QUALITY;
      lfOutPrecision := OUT_DEFAULT_PRECIS;
      lfClipPrecision := CLIP_DEFAULT_PRECIS;
      lfPitchAndFamily := DEFAULT_PITCH;
    end;
    obj := CreateFontIndirect ( Font );
    try
      SelectObject ( DC, Obj );
      Action(DC);
    finally
      DeleteObject(Obj);
    end;
  finally
    DeleteDC(DC);
  end;
end;


constructor TTrueTypeManager.Create(FontName: String; FontStyle: TFontStyles);
begin
  FFontName := FontName;
  FFontStyle := FontStyle;
  WorkWithDC(LoadFontInfo);
  FGlyphsLoaded := False;
end;

procedure TTrueTypeManager.SaveTableToStream(Name:AnsiString;MainStream,AStream:TStream; var Table: TTrueTypeTable;Delta:Cardinal);
var
  TableIndex:TTableInfoRec;
  i: Integer;
begin
  if Table.Table = nil then
    Exit;
  TableIndex.Tag := 0;
  for i:= 4 downto 1 do
    TableIndex.Tag := TableIndex.Tag shl 8 + byte(Name[i]);
  TableIndex.Offset := ByteSwap(Delta +Cardinal(AStream.Position));
  TableIndex.Length := ByteSwap(Table.Size);
  TableIndex.Checksum := ByteSwap(CalculateCheckSum(Table.Table,Table.Size));
  MainStream.Write(TableIndex,sizeof(TableIndex));
  AStream.Write(Table.Table^,Table.Size);
end;

procedure TTrueTypeManager.CheckTables(Tables:TTrueTypeTables; var Count: Integer);
begin
  if Tables.Head.Table = nil then Dec(Count);
  if Tables.Hhea.Table = nil then Dec(Count);
  if Tables.Loca.Table = nil then Dec(Count);
  if Tables.Maxp.Table = nil then Dec(Count);
  if Tables.Cvt.Table = nil then Dec(Count);
  if Tables.Prep.Table = nil then Dec(Count);
  if Tables.Glyf.Table = nil then Dec(Count);
  if Tables.Hmtx.Table = nil then Dec(Count);
  if Tables.Fpgm.Table = nil then Dec(Count);
  if Tables.Cmap.Table = nil then Dec(Count);
  if Tables.Name.Table = nil then Dec(Count);
  if Tables.Post.Table = nil then Dec(Count);
end;

procedure TTrueTypeManager.CreateFont(AStream: TStream; Tables: TTrueTypeTables);
var
  MS,OutMS: TMemoryStream;
  FullOffset: Integer;
  Header: TFileHeaderRec;
  Head: PHeadRec;
  Cnt:Integer;
begin
  cnt := TTF_TABLES_COUNT;
  CheckTables(Tables,Cnt);
  Header.ScalarType := ByteSwap(Cardinal($00010000)); //Identify TTF file
  Header.NumTables := swap(Cnt);
  Header.SearchRange := flp2(Cnt)*16;
  Header.EntrySelector := swap(Log32(flp2(Cnt)));
  Header.RangeShift := swap(Cnt*16-Header.SearchRange);
  Header.SearchRange := swap(Header.SearchRange);
  PHeadRec(Tables.Head.Table)^.checkSum := 0;
  OutMS := TMemoryStream.Create;
  try
    MS := TMemoryStream.Create;
    try
      OutMS.Write(Header,SizeOf(Header));
      FullOffset := SizeOf(TFileHeaderRec)+ Cnt * sizeof(TTableInfoRec);
      SaveTableToStream('head',OutMS,MS,Tables.Head,FullOffset);
      SaveTableToStream('hhea',OutMS,MS,Tables.Hhea,FullOffset);
      SaveTableToStream('loca',OutMS,MS,Tables.Loca,FullOffset);
      SaveTableToStream('maxp',OutMS,MS,Tables.Maxp,FullOffset);
      SaveTableToStream('cvt ',OutMS,MS,Tables.Cvt,FullOffset);
      SaveTableToStream('prep',OutMS,MS,Tables.Prep,FullOffset);
      SaveTableToStream('glyf',OutMS,MS,Tables.Glyf,FullOffset);
      SaveTableToStream('hmtx',OutMS,MS,Tables.Hmtx,FullOffset);
      SaveTableToStream('fpgm',OutMS,MS,Tables.Fpgm,FullOffset);
      SaveTableToStream('cmap',OutMS,MS,Tables.Cmap,FullOffset);
      SaveTableToStream('name',OutMS,MS,Tables.Name,FullOffset);
      SaveTableToStream('post',OutMS,MS,Tables.Post,FullOffset);
      MS.SaveToStream(OutMS);
    finally
      MS.Free;
    end;
    Head := Pointer(FarInteger(OutMS.Memory)+Cardinal(FullOffset));
    Head^.checkSum := ByteSwap($B1B0AFBA-CalculateCheckSum(OutMS.Memory,OutMS.Size));
    OutMS.SaveToStream(AStream);
  finally
    OutMS.Free;
  end;

end;

destructor TTrueTypeManager.Destroy;
begin
  FreeTables(FTables);
  FGlyphsList := nil;
  inherited;
end;

procedure TTrueTypeManager.ClearUsedGlyphs;
var
  I: integer;
begin
  for i := 0 to Length(FGlyphsList) - 1 do
  begin
    FGlyphsList[i].NewIndex := -1;
    FGlyphsList[i].Used := False;
  end;
  FGlyphsList[0].Used := True;
  FGlyphsList[1].Used := True;
  FGlyphsList[0].NewIndex := 0;
  FGlyphsList[1].NewIndex := 1;
end;

procedure TTrueTypeManager.ExtractNameTable(Src: TTrueTypeTable; var Dest: TTrueTypeTable);
var
  SrcHead: PNAME_Table_Header;
  DestHead: TNAME_Table_Header;
  SrcTable, DestTable, Current: PNAME_Record_Info;
  cnt : Integer;
  Names:PByteArray;
  DestNames:AnsiString;
  i, offset,len: integer;
  MacName:AnsiString;
  WindowsName:WideString;
  PlatformID,EncodingID,LanguageID,NameID:Word;
  P:Pointer;
  Saved:Boolean;

  procedure SaveName(APlatformID,AEncodingID,ALanguageID,ANameID:Word;Name:Pointer;NameLen:Integer);
  var
    off:integer;
  begin
    inc(DestHead.NumRecords);
    Current^.PlatformID := swap(APlatformID);
    Current^.EncodingID := swap(AEncodingID);
    Current^.LanguageID := swap(ALanguageID);
    Current^.NameID := swap(ANameID);
    Current^.StringLength := swap(NameLen);
    off := Length(DestNames);
    current^.StringOffset := swap(off);
    SetLength(DestNames,off+NameLen);
    MoveMemory(@DestNames[off+1],Name,NameLen);
    inc(Current);
  end;

begin
  SrcHead := Src.Table;
  DestHead.FormatSelector := 0;
  DestHead.NumRecords := 0;
  DestHead.StringsOffset := 0;
  Saved := false;

  cnt := swap(SrcHead^.NumRecords);
  SrcTable := Pointer(FarInteger(Src.Table)+Sizeof(TNAME_Table_Header));
  Names := Pointer(FarInteger(Src.Table)+Sizeof(TNAME_Table_Header)+Cardinal(cnt)*sizeof(TNAME_Record_Info));

  DestTable := GetMemory(cnt*sizeof(TNAME_Record_Info));
  try
    Current := DestTable;
    for i := 0 to cnt - 1 do
    begin
      PlatformID := swap(SrcTable^.PlatformID);
      EncodingID := swap(SrcTable^.EncodingID);
      LanguageID := swap(SrcTable^.LanguageID);
      NameID := swap(SrcTable^.NameID);
      Offset := swap(SrcTable^.StringOffset);
      len := swap(SrcTable^.StringLength);

      if (PlatformID = 1) and (EncodingID = 0) and (LanguageID = 0) then
      begin
        if NameID in [1,2,4,6] then
        begin
          SaveName(1,0,0,NameID,@Names[Offset],Len);
          if NameID = 1 then
          begin
            SetLength(MacName,Len);
            Move(Names[Offset],MacName[1],Len);
          end;
          if NameID = 6 then
          begin
            SetLength(FFontPostScriptName,Len);
            Move(Names[Offset],FFontPostScriptName[1],Len);
          end;
        end;
      end;
      if (PlatformID > 1) and (not Saved) then
      begin
        MacName:= LIBRARY_PREFIX +MacName;
        SaveName(1,0,0,3,@MacName[1],Length(MacName));
        Saved := True;
      end;
      if (PlatformID = 3) and (EncodingID = 1) and (LanguageID = $409) then
      begin
        if NameID in [1,2,4,6] then
        begin
          SaveName(3,1,$409,NameID,@Names[Offset],Len);
          if NameID = 1 then
          begin
            SetLength(WindowsName,Len shr 1);
            Move(Names[Offset],WindowsName[1],Len);
          end;
        end;
      end;
      inc(SrcTable);
    end;

    WindowsName:= LIBRARY_PREFIX+WindowsName;
    for i:= 1 to Length(LIBRARY_PREFIX) do
      WindowsName[i] := WideChar(swap(WORD(WindowsName[i])));

    SaveName(3,1,$409,3,@WindowsName[1],Length(WindowsName) shl 1);
    cnt := sizeof(DestHead) + DestHead.NumRecords * sizeof(TNAME_Record_Info) + Length(DestNames);
    cnt := (cnt + 3) and -4;
    len := DestHead.NumRecords;
    DestHead.StringsOffset := swap(len*sizeof(TNAME_Record_Info)+sizeof(DestHead));
    DestHead.NumRecords := swap(len);
    Dest.Table := GetMemory(cnt);
    Dest.Size := cnt;
    P := Dest.Table;
    MoveMemory(P,@DestHead,sizeof(DestHead));
    P := Pointer(FarInteger(P)+sizeof(DestHead));
    len := len * sizeof(TNAME_Record_Info);
    MoveMemory(P,DestTable,len);
    P := Pointer(FarInteger(P)+Cardinal(len));
    MoveMemory(P,@DestNames[1],length(DestNames));
  finally
    FreeMemory(DestTable);
  end;
end;

procedure TTrueTypeManager.ExtractPostTable(Src: TTrueTypeTable; var Dest:TTrueTypeTable);
const
  PostTable: array [ 1..4 ] of byte = ( 00, 00, 00, 00);
begin
  Dest.Size := SizeOf(TPOST_Table_Header)+SizeOf(PostTable);
  Dest.Table := GetMemory(Dest.Size);
  MoveMemory(Dest.Table,Src.Table,SizeOf(TPOST_Table_Header));
  MoveMemory(Pointer(FarInteger(Dest.Table)+SizeOf(TPOST_Table_Header)),@PostTable,SizeOf(PostTable));
end;

procedure TTrueTypeManager.FreeTables(Tables: TTrueTypeTables);
begin
  if Tables.Head.Table <> nil then
    FreeMemory(Tables.Head.Table);
  if Tables.Hhea.Table <> nil then
    FreeMemory(Tables.Hhea.Table);
  if Tables.Loca.Table <> nil then
    FreeMemory(Tables.Loca.Table);
  if Tables.Maxp.Table <> nil then
    FreeMemory(Tables.Maxp.Table);
  if Tables.Cvt.Table <> nil then
    FreeMemory(Tables.Cvt.Table);
  if Tables.Prep.Table <> nil then
    FreeMemory(Tables.Prep.Table);
  if Tables.Glyf.Table <> nil then
    FreeMemory(Tables.Glyf.Table);
  if Tables.Hmtx.Table <> nil then
    FreeMemory(Tables.Hmtx.Table);
  if Tables.Fpgm.Table <> nil then
    FreeMemory(Tables.Fpgm.Table);
  if Tables.Cmap.Table <> nil then
    FreeMemory(Tables.Cmap.Table);
  if Tables.Name.Table <> nil then
    FreeMemory(Tables.Name.Table);
  if Tables.Post.Table <> nil then
    FreeMemory(Tables.Post.Table);
end;

procedure TTrueTypeManager.QuickSortIdxRec(var Arr: TIdxRecArray;L, R: Integer);
var
  I, J, P: Integer;
  CH: TIdxRec;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while arr[i].First < arr[p].First do Inc(I);
      while arr[j].First > arr[p].First do Dec(J);
      if I <= J then
      begin
        CH := arr[i];
        arr[i] := arr[j];
        arr[j] := CH;
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSortIdxRec(Arr,L, J);
    L := I;
  until I >= R;
end;


procedure TTrueTypeManager.PrepareASCIIFont(Used:PByteArray;Stream:TStream);
var
  i, idx, MaxIdx: integer;
begin
  if not FGlyphsLoaded then
    WorkWithDC(LoadGlyphsInfo);
  ClearUsedGlyphs;
  MaxIdx := 2;

  for i := 32 to 127 do
    if Used[i] > 0 then
    begin
      Idx := GetIdxByUnicode(i);
      if idx <> 0 then
      begin
        FGlyphsList[idx].NewIndex  := MaxIdx;
        Idxes[i] := MaxIdx;
        inc(MaxIdx);
        MarkGLyphAsReaded(@FGlyphsList[Idx]);
      end else
      begin
        FGlyphsList[idx].NewIndex  := idx;
        Idxes[i] := 0;
      end;
    end else
      Idxes[i] := 0;

  for i:= 0 to Length(FGlyphsList) -1 do
  begin
    if FGlyphsList[i].Used and (FGlyphsList[i].NewIndex <0) then
    begin
      FGlyphsList[i].NewIndex := MaxIdx;
      Inc(MaxIdx);
    end;
  end;
  SaveAllInfo(Stream, MaxIdx);
end;

procedure TTrueTypeManager.PrepareFont(UsedUnicodes:TUnicodeArray;Stream: TStream);
var
  i, idx, MaxIdx: integer;
begin
  if not FGlyphsLoaded then
    WorkWithDC(LoadGlyphsInfo);
  ClearUsedGlyphs;
  MaxIdx := 2;
  for i:=32 to 127 do
    Idxes[i] := 0;
  for i := 0 to Length(UsedUnicodes) - 1 do
  begin
    Idx := GetIdxByUnicode(UsedUnicodes[i]);
    if idx <> 0 then
    begin
      FGlyphsList[idx].NewIndex  := MaxIdx;
      Idxes[i+32] := MaxIdx;
      inc(MaxIdx);
      MarkGLyphAsReaded(@FGlyphsList[Idx]);
    end else
      FGlyphsList[idx].NewIndex  := 0;
  end;

  for i:= 0 to Length(FGlyphsList) -1 do
  begin
    if FGlyphsList[i].Used and (FGlyphsList[i].NewIndex <0) then
    begin
      FGlyphsList[i].NewIndex := MaxIdx;
      Inc(MaxIdx);
    end;
  end;
  SaveAllInfo(Stream,MaxIdx);
end;


procedure TTrueTypeManager.ProcessCMAP(Buffer: Pointer);
var
  IsUnicodeCMAP: Boolean;
  CmapSegments: array of TCMapSegment;
//  CMAP0Have: Boolean;
  CMAP0:array [0..255] of Byte;
  GlyphIndexArray: array of Word;
  TabCnt:Integer;
  Off, SegmentsCount: Integer;
  i,PID,SID, GlyphCount: Integer;
  OffCMAP0:Integer;
  CMapEnc:PCMAP_Record_Info;
  Cmap4:PCMAP_4_Record;
  PW: PWordArray;
  P: Pointer;
  f, Idx: Word;
  Cnt: Integer;

begin
  TabCnt := Swap(PCmap_Table_Header(Buffer)^.NumTables);
  Off := 0;
  OffCMAP0 := 0;
  SegmentsCount := 0;
  CMapEnc := Pointer(FarInteger(Buffer)+SizeOf(TCMAP_TABLE_Header));
  for i:= 0 to TabCnt - 1 do
  begin
    PID := swap(CMapEnc^.Platform_ID);
    SID := swap(CMapEnc^.Encoding_ID);
    if (PID = 1) and (SID = 1) then
      OffCMAP0 := ByteSwap(CMapEnc^.Offset);
    if (PID = 3) and ((SID = 1)or(SID = 0)) then
    begin
      off := ByteSwap(CMapEnc^.Offset);
      IsUnicodeCMAP := SID = 1;
      if IsUnicodeCMAP then Break;
    end;
    inc(CMapEnc);
  end;
  if (off = 0) and (OffCMAP0 = 0) then
    raise ETTFException.Create('Cannot find compatible cmap table');
  if off <> 0 then
  begin
    Cmap4 := Pointer(FarInteger(Buffer)+Cardinal(off));
    if swap(Cmap4^.Format) <> 4 then
      raise ETTFException.Create('Cannot find cmap 4 table');
    SegmentsCount := swap(CMap4^.segCountX2) shr 1;
    SetLength(CmapSegments,SegmentsCount);
    PW := Pointer(FarInteger(Buffer)+Cardinal(off)+ sizeof(TCMAP_4_Record));
    for i := 0 to SegmentsCount - 1 do
      CmapSegments[i].EndCode := swap(PW[i]);
    PW := Pointer(FarInteger(Buffer)+Cardinal(off)+
      sizeof(TCMAP_4_Record)+Cardinal(SegmentsCount)*sizeof(Word)+2);
    for i := 0 to SegmentsCount - 1 do
      CmapSegments[i].StartCode := swap(PW[i]);

    PW := Pointer(FarInteger(Buffer)+Cardinal(off)+ sizeof(TCMAP_4_Record)+
      Cardinal(SegmentsCount)*sizeof(Word)*2+2);
    for i := 0 to SegmentsCount - 1 do
      CmapSegments[i].idDelta := swap(PW[i]);
    PW := Pointer(FarInteger(Buffer)+Cardinal(off)+ sizeof(TCMAP_4_Record)+
      Cardinal(SegmentsCount)*sizeof(Word)*3+2);
    for i := 0 to SegmentsCount - 1 do
      CmapSegments[i].idRangeOffset := swap(PW[i]);
    GlyphCount := (Swap(CMap4^.length) - (sizeof(TCMAP_4_Record)+
      Cardinal(SegmentsCount)*sizeof(Word)*4+2) ) shr 1;
    SetLength(GlyphIndexArray,GlyphCount);
    PW := Pointer(FarInteger(Buffer)+Cardinal(off)+ sizeof(TCMAP_4_Record)+
      Cardinal(SegmentsCount)*sizeof(Word)*4+2);
    for i:= 0 to GlyphCount - 1 do
      GlyphIndexArray[i] := swap(PW[i]);
  end;
  if OffCMAP0 <> 0 then
  begin
//    CMAP0Have := true;
    P := Pointer(FarInteger(Buffer)+Cardinal(OffCMAP0)+6);
    MoveMemory(@CMAP0,P,256);
  end;
  GlyphCount := Length(FGlyphsList);
  Cnt := 0;
  for i := 0 to  SegmentsCount - 2 do
    inc(Cnt, CmapSegments[i].EndCode - CmapSegments[i].StartCode +1);
  SetLength(FUnicodeMap,Cnt);
  Cnt := 0;

  for i := 0 to  SegmentsCount - 2 do
    with CmapSegments[i] do
    begin
      for f := StartCode to EndCode do
      begin
        if idRangeOffset = 0 then
          Idx := f + idDelta
        else
        begin
          off := i + idRangeOffset shr 1 - SegmentsCount + f - StartCode;
          Idx := Word ( GlyphIndexArray [ off ] ) + idDelta;
        end;
        if Idx <= GlyphCount then
        begin
          if FGlyphsList[Idx].Unicode = 0 then
            FGlyphsList[Idx].Unicode := F
          else
            FGlyphsList[Idx].Unicode := $FFFF;
          FUnicodeMap[Cnt].Unicode := F;
          FUnicodeMap[Cnt].Index := Idx;
          inc(Cnt);
        end;
      end;
    end;
end;

procedure TTrueTypeManager.LoadFontInfo(DC:HDC);
var
  M: TTextMetric;
  i: Word;
  P: PWordArray;
  GlyphCount: Integer;
  Name: TTrueTypeTable;
begin
  GetTextMetrics(DC,M);
  FIsMono := ( M.tmPitchAndFamily and TMPF_FIXED_PITCH ) = 0;
  FAscent := M.tmAscent;
  FDescent := M.tmDescent;
  LoadOneTable(DC,'cmap',FTables.Cmap);
  LoadOneTable(DC,'hmtx',FTables.hmtx);
  LoadOneTable(DC,'maxp',FTables.Maxp);
  LoadOneTable(DC,'hhea',FTables.Hhea);
  LoadOneTable(DC,'head',FTables.Head);
  LoadOneTable(DC,'name',FTables.Name);
  FillChar(Name,SizeOf(Name),0);
  ExtractNameTable(FTables.Name, Name);
  FreeMemory(FTables.Name.Table);
  FTables.Name := Name;
  if FFontPostScriptName = '' then
  begin
    FFontPostScriptName := ReplStr (AnsiString(FFontName), ' ', '#20' );
    if fsBold in FFontStyle then
      FFontPostScriptName := FFontPostScriptName + '#20Bold';
    if fsItalic in FFontStyle then
      FFontPostScriptName := FFontPostScriptName + '#20Italic';
  end;

  FillChar ( OTM, SizeOf ( OTM ), 0 );
  OTM.otmSize := SizeOf ( OTM );
  GetOutlineTextMetrics ( DC, SizeOf ( OTM ), @OTM );
  GlyphCount := Swap(PMaxp_Table_Header(FTables.Maxp.Table).numGlyphs);
  FUnitsPerEm :=Swap(PHeadRec(FTables.Head.Table)^.unitsPerEm);
  SetLength(FGlyphsList,GlyphCount);
  ProcessCMAP(FTables.Cmap.Table);
  P := FTables.Hmtx.Table;
  if FIsMono then
    for i := 0 to GlyphCount - 1 do
    begin
      FGlyphsList[i].CharInfo.Width := Trunc(Swap(P[0]) / FUnitsPerEm * 1000);
      FGlyphsList[i].BaseWidth := P[0];
      FGlyphsList[i].AddWidth :=P[1];
    end
  else
    for i := 0 to GlyphCount - 1 do
    begin
      FGlyphsList[i].CharInfo.Width := Trunc(Swap(P[i shl 1]) / FUnitsPerEm * 1000);
      FGlyphsList[i].BaseWidth := P[i shl 1];
      FGlyphsList[i].AddWidth :=P[i shl 1 + 1];
    end;
end;

procedure TTrueTypeManager.LoadGlyphsInfo(DC:HDC);
var
  i, GlyphCount: integer;
begin
  GlyphCount :=  Length(FGlyphsList);
  LoadOneTable(DC,'loca',FTables.Loca);
  LoadOneTable(DC,'glyf',FTables.Glyf);
  LoadOneTable(DC,'cvt ',FTables.Cvt, true);
  LoadOneTable(DC,'fpgm',FTables.Fpgm, true);
  LoadOneTable(DC,'prep',FTables.Prep, true);
  LoadOneTable(DC,'post',FTables.Post);

   if Swap(PHeadRec(FTables.Head.Table)^.indexToLocFormat) = 1 then //  Long FormatOffset
  begin
    for i := 0 to GlyphCount - 1 do
    begin
      FGlyphsList[i].DataOffset := ByteSwap(PCardinalArray(FTables.Loca.Table)[i]);
      FGlyphsList[i].Size := ByteSwap(PCardinalArray(FTables.Loca.Table)[i+1]) -
        ByteSwap(PCardinalArray(FTables.Loca.Table)[i]);
    end;
  end else
  begin
    for i := 0 to GlyphCount - 1 do
    begin
      FGlyphsList[i].DataOffset := Swap(PWordArray(FTables.Loca.Table)[i]) shl 1;
      FGlyphsList[i].size := (Swap(PWordArray(FTables.Loca.Table)[i+1]) - swap(PWordArray(FTables.Loca.Table)[i])) shl 1;
    end;
  end;
  FGlyphsLoaded := true;
end;

procedure TTrueTypeManager.LoadOneTable(DC: HDC; TableName: String; var Table: TTrueTypeTable; CanIgnore: Boolean);
var
  TN:DWORD;
  i: integer;
  SZ: DWORD;
begin
  TN := 0;
  for i:= 4 downto 1 do
    TN := TN shl 8 + byte(TableName[i]);
  SZ := GetFontData(DC,TN,0,nil,0);
  if SZ = GDI_ERROR then
  begin
    Table.Size := 0;
    Table.Table := nil;
    if CanIgnore then
      Exit;
    raise ETTFException.Create('Cannot receive TTF info');
  end;
  Table.Table := GetMemory(SZ);
  SZ := GetFontData(DC,TN,0,Table.Table,SZ);
  if SZ = GDI_ERROR then
  begin
    FreeMemory(Table.Table);
    Table.Table:= nil;
    Table.Size := 0;
    if CanIgnore then
      Exit;
    raise ETTFException.Create('Cannot receive TTF info');
  end;
  Table.Size := sz;
end;


function TTrueTypeManager.GetAscent: Integer;
begin
  Result := FAscent;
end;

function TTrueTypeManager.GetDescent: Integer;
begin
  Result := FDescent;
end;

function TTrueTypeManager.GetGlyphCount: Integer;
begin
  Result := Length(FGlyphsList);
end;

function TTrueTypeManager.GetGlyph(Index: Integer): PGlyphInfo;
begin
  if (index < 0) or (Index >= Length(FGlyphsList)) then
    Raise EPDFException.Create(SOutOfBounds);
  result := @FGlyphsList[Index];
end;


function TTrueTypeManager.GetFontBox: TRect;
begin
  Result := OTM.otmrcFontBox;
end;

function TTrueTypeManager.GetItalicAngle: Integer;
begin
  Result := OTM.otmItalicAngle;
end;

function TTrueTypeManager.GetGlyphByUnicode(Index: Word): PGlyphInfo;
var
  Idx: Integer;
begin
  Idx := GetIdxByUnicode(Index);
  result := @FGlyphsList[Idx];
  FLast := Idx;
end;

function TTrueTypeManager.GetIdxByUnicode(Unicode: Word): Integer;
var
  Mid,Start,Finish, Idx: Integer;
begin
  if (Unicode <> $FFFF) and (FGlyphsList[FLast].Unicode = Unicode) then
  begin
    Result := FLast;
    Exit;
  end;
  Start := 0;
  Idx:= -1;
  Finish := Length(FUnicodeMap) - 1;
  while Start < Finish do
  begin
    Mid := Start + (Finish - Start) shr 1;
    if FUnicodeMap[Mid].Unicode = Unicode then
    begin
      Idx := FUnicodeMap[Mid].Index;
      Break;
    end;
    if FUnicodeMap[Mid].Unicode < Unicode then
      Start := Mid + 1
    else
      Finish := Mid - 1;
  end;
  if idx < 0 then
    if FUnicodeMap[Start].Unicode = Unicode then
      idx := FUnicodeMap[Start].Index;
  if idx < 0 then
    Result := 0
  else
    Result := idx;
end;


procedure TTrueTypeManager.MarkGlyphAsReaded(Glyph: PGlyphInfo);
  var
  p: PGlyphHeader;
  Compound: PCompoundGlyphInfo;
  Off: Integer;
  Flag: Word;
  GIdx: Word;
begin
  if Glyph^.Used then
    Exit;
  Glyph^.Used := True;
  P := Pointer(FarInteger(FTables.Glyf.Table)+Cardinal(Glyph^.DataOffset));
  if swap(P^.ContourCount) >= 0 then
    Exit;
  Off := sizeof(TGlyphHeader);
  while true do
  begin
    Compound := Pointer(FarInteger(P)+Cardinal(off));
    GIdx := Swap(Compound^.GlyphIndex);
    if GIdx < Length(FGlyphsList) then
      MarkGLyphAsReaded(@FGlyphsList[GIdx]);
    Flag := swap(Compound^.Flags);
    if Flag and $20 = 0 then
      Exit;
    Inc(off,sizeof(TCompoundGlyphInfo));
    if Flag and 1 = 1 then
      inc(off,4)
    else
      inc(off,2);
    if off>= Glyph^.Size then
      Exit;
  end;

end;

procedure TTrueTypeManager.SaveAllInfo(Stream:TStream; MaxIdx:Integer);
var
  NumGlyphs : Integer;
  GlyphsSize:Integer;
  Widths: PWordArray;
  LocaBig:PCardinalArray;
  LocaSmall:PWordArray;
  Off,Noff, MaxSize, Size: Integer;
  i, idx: integer;
  WrkGlyph: Pointer;
  p: PGlyphHeader;
  Flag: Word;
  Compound: PCompoundGlyphInfo;
  CMapHandle:PCMAP_Table_Header;
  CMapFirstTable:PCMAP_Record_Info;
  CMAP0:PCMAP_0_Record;
  arr: TIdxRecArray;
  Tables: TTrueTypeTables;
begin
  GlyphsSize := 0;
  NumGlyphs := MaxIdx;
  SetLength(Arr,NumGlyphs);
  NumGlyphs := 0;
  for i := 0 to Length(FGlyphsList) - 1 do
    if FGlyphsList[i].Used then
    begin
      arr[NumGlyphs].First := FGlyphsList[i].NewIndex;
      arr[NumGlyphs].Second := i;
      Inc(NumGlyphs);
    end;
  QuickSortIdxRec(arr,0,NumGlyphs - 1);

  FillChar(Tables,sizeof(Tables),0);
  try
    CopyTable(FTables.Cvt,Tables.Cvt);    //Not changed
    CopyTable(FTables.Prep,Tables.Prep);  //Not changed
    CopyTable(FTables.Fpgm,Tables.Fpgm);  //Not changed
    CopyTable(FTables.Name,Tables.Name);  //Not changed
    ExtractPostTable(FTables.Post,Tables.Post); // Remove unused past of the post table

    CopyTable(FTables.Hhea,Tables.Hhea); // change only count of records

    Tables.Hmtx.Table := GetMemory(NumGlyphs shl 2);
    Tables.Hmtx.Size := NumGlyphs shl 2;
    Widths := Tables.Hmtx.Table;
    for i := 0 to NumGlyphs - 1 do
    begin
      idx := arr[i].Second;
      Widths[i shl 1] := FGlyphsList[idx].BaseWidth;
      Widths[i shl 1 + 1] := FGlyphsList[idx].AddWidth;
    end;
    PHHEA_Table_Header(Tables.Hhea.Table)^.numberOfHMetrics := swap(NumGlyphs);

    CopyTable(FTables.Maxp,Tables.Maxp); // Set number of glyphs
    PMAXP_Table_Header(Tables.Maxp.Table)^.numGlyphs := Swap(NumGlyphs);

    CopyTable(FTables.Head,Tables.Head);
    MaxSize := 0;
    if GlyphsSize > $1FFFE then
    begin
      PHeadRec(Tables.Head.Table)^.indexToLocFormat := 1;
      Tables.Loca.Table := GetMemory((NumGlyphs+1) shl 2);
      Tables.Loca.Size := (NumGlyphs+1) shl 2;
      LocaBig := Tables.Loca.Table;
      Off := 0;
      for i := 0 to NumGlyphs - 1 do
      begin
        LocaBig[i] := ByteSwap(off);
        idx := arr[i].Second;
        inc(off,FGlyphsList[idx].Size);
        if MaxSize < FGlyphsList[idx].Size then
          MaxSize := FGlyphsList[idx].Size;
      end;
      LocaBig[NumGlyphs] := ByteSwap(off);
    end else
    begin
      PHeadRec(Tables.Head.Table)^.indexToLocFormat := 0;
      Tables.Loca.Table := GetMemory((NumGlyphs+1) shl 1);
      Tables.Loca.Size := (NumGlyphs+1) shl 1;
      LocaSmall := Tables.Loca.Table;
      Off := 0;
      for i := 0 to NumGlyphs - 1 do
      begin
        LocaSmall[i] := Swap(Word(off shr 1));
        idx := arr[i].Second;
        inc(off,FGlyphsList[idx].Size);
        if MaxSize < FGlyphsList[idx].Size then
          MaxSize := FGlyphsList[idx].Size;
      end;
      LocaSmall[NumGlyphs] := Swap(Word(off shr 1));
    end;
    Tables.Glyf.Table := GetMemory(Off);
    Tables.Glyf.Size := Off;

    WrkGlyph := GetMemory(MaxSize);
    try
      NOff := 0;
      for i := 0 to NumGlyphs - 1 do
      begin
        idx := arr[i].Second;
        Size := FGlyphsList[idx].Size;
        P := Pointer(FarInteger(FTables.Glyf.Table)+Cardinal(FGlyphsList[idx].DataOffset));
        MoveMemory(WrkGlyph,P,Size);
        P := WrkGlyph;
        if swap(P^.ContourCount) < 0 then
        begin
          Off := SizeOf(TGlyphHeader);
          while true do
          begin
            Compound := Pointer(FarInteger(P)+Cardinal(Off));
            Idx := Swap(Compound^.GlyphIndex);
            Compound^.GlyphIndex := Swap(FGlyphsList[Idx].NewIndex);
            Flag := swap(Compound^.Flags);
            if Flag and $20 = 0 then
              Break;
            Inc(Off,sizeof(TCompoundGlyphInfo));
            if Flag and 1 = 1 then
              inc(Off,4)
            else
              inc(Off,2);
            if Off >= Size then
              Break;
          end;
        end;
        MoveMemory(Pointer(FarInteger(Tables.Glyf.Table)+Cardinal(NOff)),WrkGlyph,Size);
        Inc(Noff,Size);
      end;
    finally
      FreeMemory(WrkGlyph);
    end;
    Tables.Cmap.Table := GetMemory(276);
    Tables.Cmap.Size := 276;
    FillChar(Tables.Cmap.Table^,276,0);
    CMapHandle := Tables.Cmap.Table;
    CMapHandle^.NumTables := Swap(Word(1));
    CMapFirstTable := Pointer(FarInteger(Tables.Cmap.Table)+SizeOf(TCMAP_Table_Header));
    CMapFirstTable^.Platform_ID:= Swap(Word(1));
    CMapFirstTable^.Offset := ByteSwap(Cardinal(sizeof(TCMAP_Table_Header)+sizeof(TCMAP_Record_Info)));
    CMAP0 := Pointer(FarInteger(Tables.Cmap.Table)+SizeOf(TCMAP_Table_Header)+sizeof(TCMAP_Record_Info));
    CMAP0^.Length := swap(word(262));
    for i := 32 to 127 do
        CMAP0^.Index[i] := Idxes[i];
    CreateFont(Stream,Tables);
  finally
    FreeTables(Tables)
  end;
end;

procedure TTrueTypeManager.PrepareFont(Indexes: PInteger; Len: Integer; Stream: TStream);
var
  i, idx, MaxIdx: integer;
begin
  if not FGlyphsLoaded then
    WorkWithDC(LoadGlyphsInfo);
  ClearUsedGlyphs;
  MaxIdx := 2;
  for i:=32 to 127 do
    Idxes[i] := 0;
  for i := 0 to Len - 1 do
  begin
    Idx := Indexes^;
    if idx <> 0 then
    begin
      FGlyphsList[idx].NewIndex  := MaxIdx;
      Idxes[i+32] := MaxIdx;
      inc(MaxIdx);
      MarkGLyphAsReaded(@FGlyphsList[Idx]);
    end else
      FGlyphsList[idx].NewIndex  := 0;
    inc(Indexes);
  end;

  for i:= 0 to Length(FGlyphsList) -1 do
  begin
    if FGlyphsList[i].Used and (FGlyphsList[i].NewIndex <0) then
    begin
      FGlyphsList[i].NewIndex := MaxIdx;
      Inc(MaxIdx);
    end;
  end;
  SaveAllInfo(Stream,MaxIdx);
end;

end.
