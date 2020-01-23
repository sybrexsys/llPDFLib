{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFJBIG2;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif}
  llPDFTypes, llPDFEngine, llPDFImage, llPDFCCITT, llPDFMisc;

type
  TreeItem = record
    Parent: integer;
    Index: integer;
    Value: integer;
    Branch: boolean;
  end;

  IndexedItem = record
    Index: integer;
    Value: integer;
  end;


  TSymbol = record
    x: Integer;
    y: Integer;
    Picture: integer;
  end;

  TDict = record
    Code: Cardinal;
    CodeLen: Byte;
  end;


  TSymbolDictionaryItem = record
    Image: TBWImage;
    Index: Integer;
    DW: Integer;
  end;


  TJBig2SymbolDictionary = class (TPDFObject)
  private
    FJBIG2Options: TJBIG2Options;
    FMaxH: Integer;
    FTotalWidth: Integer;
    FDictionaryWidth: Integer;
    FDictionarySize:Cardinal;
    FDictionary:array of TSymbolDictionaryItem;
    function AddDictionary:Integer;
    procedure SaveSymbolDictionary(Stream:TStream);
    function GeneratePicture:TBitmap;
    function PlaceNewSymbol(Symbol: TBWImage): Integer;
    function GetItem(Index:Integer): TSymbolDictionaryItem;
  protected
    procedure Save;override;
  public
    constructor Create(Engine: TPDFEngine;JBIG2Options: TJBIG2Options);
    destructor Destroy;override;
    procedure Clear;
    procedure ClearDictionary;
    function FindTemplate(Symbol: TBWImage): Integer;
    property Count:Cardinal read FDictionarySize;
    property Item[Index:Integer]:TSymbolDictionaryItem read GetItem;default;
    property TotalWidth: Integer read FTotalWidth;
  end;


  TJBIG2Compression = class
  private
    { Private declarations }
    FUseGlobalSD: Boolean;
    FSymbolDictionary: TJBig2SymbolDictionary;
    FJBIG2Options:TJBIG2Options;
    FSymbolsSize: Cardinal;
    FSymbols: array of TSymbol;

    SymbTemplates: array of TDict;
    UseTime: array of IndexedItem;
    PrefLen: array of integer;
    Codes: array of integer;
    PictRestrict: TImgPoint;
    function AddSymbol:Integer;
    procedure AssignPrefCodes(NTemp: integer);
    procedure GenerateStream(AStream: TStream);
    procedure ProcessSymbol(Symbol: TBWImage; x, y: Integer);
    procedure SavePage(Stream:TStream; SegmentNumber:Cardinal);
    procedure CodeAndAdd(Bits: TBitStream; Number: integer; First: boolean);
    procedure SaveTextRegion(Stream:TStream; SegmentNumber:Cardinal);
  public
    { Public declarations }
    procedure Execute(OutStream: TMemoryStream; CompImage: TBitmap);
    constructor Create(GlobalSymbolDictionary: TJBig2SymbolDictionary;JBIG2Options:TJBIG2Options);
    destructor Destroy;override;
  end;

implementation

uses llPDFCrypt;

const
  PHeader: array [0 .. 6] of Byte = ( $30, $00, $01, $00, $00, $00, $13);
  TRHeader: array [0 .. 3] of Byte = ( $06, $20, $00, $01);
  BlHeader: array [0 .. 1] of Byte = ($00, $11);
  TRFlags: array [0 .. 3] of Byte = ($0C, $19, $00, $10);

  b1: array [0 .. 3, 0 .. 4] of {$ifndef CONDITIONALEXPRESSIONS}Int64 {$else} Cardinal {$endif} = (
    (0, 16, 272, 65808, $FFFFFFFF),
    (0, 0, 2, 6, 7),
    (0, 4, 8, $10, $20),
    (0, 1, 2, 3, 3)
  );

  b3: array [0 .. 3, 0 .. 7] of integer = (
    (-257, -1, 0, 1, 2, 10, 74, $FFFF),
    ($FF, $FE, 0, 2, 6, $E, $1E, $7E),
    ($20, 8, 0, 0, 0, 3, 6, $20),
    (8, 8, 1, 2, 3, 4, 5, 7)
  );

  b4: array [0 .. 3, 0 .. 5] of integer = (
    (1, 2, 3, $B, $4B, $FFFF),
    (0, 2, 6, $E, $1E, $1F),
    (0, 0, 0, 3, 6, $20),
    (1, 2, 3, 4, 5, 5)
  );

  b6: array [0 .. 3, 0 .. 13] of integer = (
    (-2048, -1024, -512, -256, -128, -64, -32, 0, 128, 256, 512, 1024, -2049, 2048),
    (10, 9, 8, 7, 6, 5, 5, 7, 7, 8, 9, 10, 32, 32),
    ($1C, 8, 9, $A, $1D, $1E, $B, 0, 2, 3, $C, $D, $3E, $3F),
    (5, 4, 4, 4, 5, 5, 4, 2, 3, 3, 4, 4, 6, 6)
  );

  b8: array [0 .. 3, 0 .. 19] of integer = (
    (-15, -7, -5, -3, -2, -1, 0, 2, 3, 4, 20, 22, 38, 70, 134, 262, 390, 646, -16, 1670),
    (3, 1, 1, 0, 0, 0, 1, 0, 0, 4, 1, 4, 5, 6, 7, 7, 8, 10, 32, 32),
    ($FC, $1FC, $FD, $1FD, $7C, $A, 0, $1A, $3A, 4, $3B, $B, $C, $1B, $1C, $3C, $7D, $3D, $1FE, $1FF),
    (8, 9, 8, 9, 7, 4, 2, 5, 6, 3, 6, 4, 4, 5, 5, 6, 7, 6, 9, 9)
  );

  b12: array [0 .. 3, 0 .. 13] of integer = (
    (1, 2, 3, 5, 6, 8, 10, 11, 13, 17, 25, 41, 73, $FFFF),
    (0, 0, 1, 0, 1, 1, 0, 1, 2, 3, 4, 5, 32, 0),
    (0, 2, 6, $1C, $1D, $3C, $7A, $7B, $7C, $7D, $7E, $FE, $FF, 0),
    (1, 2, 3, 5, 5, 6, 7, 7, 7, 7, 7, 8, 8, 0)
  );


{ TJBIG2Compression }

procedure TJBIG2Compression.AssignPrefCodes(NTemp: integer);
var
  i: integer;
  Curtemp, CurCode, CurLen, Lenmax: integer;
  LenCount: array of integer;
  FirstCode: array of integer;

begin
  Lenmax := 0;
  for i := 0 to NTemp - 1 do
  begin
    if PrefLen[i] > Lenmax then
      Lenmax := PrefLen[i];
  end;
  SetLength(LenCount, Lenmax + 1);
  for i := 0 to NTemp - 1 do
  begin
    Inc(LenCount[PrefLen[i]]);
  end;
  SetLength(FirstCode, Lenmax + 1);
  SetLength(Codes, NTemp);
  CurLen := 1;
  FirstCode[0] := 0;
  LenCount[0] := 0;
  while CurLen <= Lenmax do
  begin
    FirstCode[CurLen] := (FirstCode[CurLen - 1] + LenCount[CurLen - 1]) * 2;
    CurCode := FirstCode[CurLen];
    Curtemp := 0;
    while Curtemp < NTemp do
    begin
      if PrefLen[Curtemp] = CurLen then
      begin
        Codes[Curtemp] := CurCode;
        Inc(CurCode);
      end;
      Inc(Curtemp);
    end;
    CurLen := CurLen + 1;
  end;
end;


procedure TJBIG2Compression.SavePage(Stream:TStream; SegmentNumber:Cardinal);
var
  BitStrm: TBitStream;
begin
  BitStrm := TBitStream.Create(Stream);
  try
    BitStrm.Put(SegmentNumber,32);
    BitStrm.Write(@PHeader,7);
    BitStrm.put(PictRestrict.x,32);
    BitStrm.put(PictRestrict.y,32);
    BitStrm.put(0,32);
    BitStrm.put(0,32);
    BitStrm.put($40,8);
    BitStrm.put(0,16);
  finally
    BitStrm.Free;
  end;
end;

procedure TJBIG2Compression.CodeAndAdd(Bits:TBitStream; Number: integer; First: boolean);
var
  s, len: integer;
begin
  len := 17;
  if First then
    len := 11;
  for s := len downto 0 do
  begin
    if First then
    begin
      if (Number <= b6[0, 12]) then
      begin
        Bits.Put(b6[2, 12], b6[3, 12]);
        Bits.Put(b6[0, 12]- Number, b6[1, 12]);
        Break;
      end;
      if (Number >= b6[0, 13]) then
      begin
        Bits.Put(b6[2, 13], b6[3, 13]);
        Bits.Put((Number - b6[0, 13]), b6[1, 13]);
        Break;
      end;
      if (Number >= b6[0, 11]) and (Number < b6[0, 13]) then
      begin
        Bits.Put(b6[2, 11], b6[3, 11]);
        Bits.Put((Number - b6[0, 11]), b6[1, 11]);
        Break;
      end;
      if (Number < b6[0, s + 1]) and (Number >= b6[0, s]) then
      begin
        Bits.Put(b6[2, s], b6[3, s]);
        Bits.Put(Number - b6[0, s], b6[1, s]);
        Break;
      end;
    end else
    begin
      if (Number <= b8[0, 18]) then
      begin
        Bits.Put(b8[2, 18], b8[3, 18]);
        Bits.Put( b8[0, 18] - Number, b8[1, 18]);
        Break;
      end;
      if (Number >= b8[0, 19]) then
      begin
        Bits.Put(b8[2, 19], b8[3, 19]);
        Bits.Put((Number - b8[0, 19]), b8[1, 19]);
        Break;
      end;
      if (Number >= b8[0, 17]) and (Number < b8[0, 19]) then
      begin
        Bits.Put(b8[2, 17], b8[3, 17]);
        Bits.Put((Number - b8[0, 17]), b8[1, 17]);
        Break;
      end;
      if (Number < b8[0, s + 1]) and (Number >= b8[0, s]) then
      begin
        Bits.Put(b8[2, s], b8[3, s]);
        Bits.Put(Number - b8[0, s], b8[1, s]);
        Break;
      end;
    end;
  end;
end;

procedure TJBIG2Compression.SaveTextRegion(Stream:TStream; SegmentNumber:Cardinal);

var
  DT, Q: integer;
  h: Cardinal;
  Tc: Integer;
  Rc: array of IndexedItem;
  HuffTree: array of TreeItem;
  Code, IDS, CurS, SBStripsInd, StripT, SBDSOffset, SBStrips, Firsts, CurrInd,
    CurrRun, LenCurrRun: integer;
  RCodes: array of integer;
  Runs: array of integer;
  First, EofStrips: boolean;
  BitStrm:TBitStream;
  NodeParent: integer;
  ALens: array of integer;


  procedure Sort(ByIndex: boolean);
  var
    i, h, g: integer;
    CurLen: integer;
    tmp: IndexedItem;
    TrTmp: TreeItem;
    IsSort: boolean;
  begin
    i := 4;
    while i >= 1 do
    begin
      h := 0;
      if ByIndex then
        CurLen := length(HuffTree) - i
      else
        CurLen := length(Rc) - i;
      while h < i do
      begin
        IsSort := true;
        while IsSort do
        begin
          IsSort := false;
          g := h;
          while g < CurLen do
          begin
            if ByIndex then
            begin
              if HuffTree[g].Index > HuffTree[g + i].Index then
              begin
                IsSort := true;
                TrTmp := HuffTree[g + i];
                HuffTree[g + i] := HuffTree[g];
                HuffTree[g] := TrTmp;
              end;
            end  else
            begin
              if Rc[g].Value > Rc[g + i].Value then
              begin
                IsSort := true;
                tmp := Rc[g + i];
                Rc[g + i] := Rc[g];
                Rc[g] := tmp;
              end;
            end;
            Inc(g, i);
          end;
        end;
        Inc(h);
      end;
      i := i shr 1;
    end;
  end;

  procedure AddRun(CloseStream: boolean);
  var
    V, c: integer;
  begin
    if (CurrInd = CurrRun) and (not(CloseStream)) then
      Inc(LenCurrRun)
    else
    begin
      if CurrRun = 0 then
      begin
        if LenCurrRun < 3 then
          for V := 1 to LenCurrRun do
          begin
            SetLength(Runs, length(Runs) + 1);
            Runs[length(Runs) - 1] := 0;
            Inc(RCodes[CurrRun]);
          end
        else if LenCurrRun < 11 then
        begin
          Inc(RCodes[33]);
          SetLength(Runs, length(Runs) + 2);
          Runs[length(Runs) - 2] := 33;
          Runs[length(Runs) - 1] := LenCurrRun - 3;
        end else
        begin
          Inc(RCodes[34]);
          SetLength(Runs, length(Runs) + 2);
          Runs[length(Runs) - 2] := 34;
          Runs[length(Runs) - 1] := LenCurrRun - 11;
        end;
      end else
      begin
        if LenCurrRun < 4 then
          for c := 1 to LenCurrRun do
          begin
            SetLength(Runs, length(Runs) + 1);
            Runs[length(Runs) - 1] := CurrRun;
            Inc(RCodes[CurrRun]);
          end
        else if LenCurrRun < 8 then
        begin
          Inc(RCodes[CurrRun]);
          SetLength(Runs, length(Runs) + 1);
          Runs[length(Runs) - 1] := CurrRun;
          SetLength(Runs, length(Runs) + 2);
          Runs[length(Runs) - 2] := 32;
          Runs[length(Runs) - 1] := LenCurrRun - 4;
          Inc(RCodes[32]);
        end else
        begin
          for c := 1 to (LenCurrRun div 7) do
          begin
            Inc(RCodes[CurrRun]);
            SetLength(Runs, length(Runs) + 1);
            Runs[length(Runs) - 1] := CurrRun;
            SetLength(Runs, length(Runs) + 2);
            Runs[length(Runs) - 2] := 32;
            Runs[length(Runs) - 1] := 3;
            Inc(RCodes[32]);
            LenCurrRun := (LenCurrRun - ((LenCurrRun div 7) * 7));
          end;
          if (LenCurrRun - ((LenCurrRun div 7) * 7)) > 3 then
          begin
            Inc(RCodes[CurrRun]);
            SetLength(Runs, length(Runs) + 1);
            Runs[length(Runs) - 1] := CurrRun;
            Inc(RCodes[CurrRun]);
            SetLength(Runs, length(Runs) + 2);
            Runs[length(Runs) - 2] := 32;
            Runs[length(Runs) - 1] := LenCurrRun - 4;
            Inc(RCodes[32]);
          end else
          begin
            for c := 1 to LenCurrRun do
            begin
              SetLength(Runs, length(Runs) + 1);
              Runs[length(Runs) - 1] := CurrRun;
              Inc(RCodes[CurrRun]);
            end;
          end;
        end;
      end;
      LenCurrRun := 1;
      CurrRun := CurrInd;
    end;
  end;

  procedure InitRC;
  var
    i: integer;
    len: Integer;
  begin
    SetLength(Rc, 0);
    len := 0;
    for i := 0 to length(UseTime) - 1 do
      if UseTime[i].Value > 0 then
        inc(len);
    SetLength(Rc, len);
    Len := 0;
    for i := 0 to length(UseTime) - 1 do
    begin
      if UseTime[i].Value > 0 then
      begin
        Rc[len].Value := UseTime[i].Value;
        Rc[len].Index := len;
        UseTime[i].Index := len;
        inc(len);
      end;
    end;
  end;

  procedure ReCompose(SubRoot, StIndex, ParID, SortFlag: integer);
  var
    u, i: integer;
  begin
    if ((StIndex + 1) < length(Rc)) and (Rc[StIndex + 1].Value <= SubRoot) then
    begin
      u := StIndex + 1;
      while (u < length(Rc)) and
        ((Rc[u].Value < SubRoot) or ((Rc[u].Value = SubRoot) and
        (Rc[u].Index > SortFlag))) do
        Inc(u);
      for i := StIndex + 1 to (u - 1) do
      begin
        Rc[i - 1].Value := Rc[i].Value;
        Rc[i - 1].Index := Rc[i].Index;
      end;
      Rc[u - 1].Value := SubRoot;
      Rc[u - 1].Index := ParID;
    end;
  end;

  function GetWayLength(ind: integer): integer;
  var
    par: integer;
  begin
    Result := 1;
    if length(HuffTree) > 1 then
    begin
      par := HuffTree[ind].Parent;
      while HuffTree[par - 1].Parent > 0 do
      begin
        Inc(Result);
        par := HuffTree[par - 1].Parent;
      end;
    end;
  end;

  procedure BuildTree;
  var
    rind, ParentInd, j, len, idx : integer;
  begin
    j := 0;
    rind := 1;
    len := length(Rc);
    SetLength(HuffTree, (len-1) shl 1);
    while j < (length(Rc) - 1) do
    begin
      ParentInd := rind + len;
      idx := (rind shl 1) - 2;
      HuffTree[idx].Value := Rc[j].Value;
      HuffTree[idx].Index := Rc[j].Index;
      HuffTree[idx].Parent := ParentInd;
      HuffTree[idx].Branch := false;
      HuffTree[idx + 1].Value := Rc[j + 1].Value;
      HuffTree[idx + 1].Index := Rc[j + 1].Index;
      HuffTree[idx + 1].Parent := ParentInd;
      HuffTree[idx + 1].Branch := true;
      Rc[j + 1].Value := HuffTree[idx].Value +
        HuffTree[idx + 1].Value;
      Rc[j + 1].Index := ParentInd;
      ReCompose(Rc[j + 1].Value, (j + 1), ParentInd, len);
      Inc(rind);
      Inc(j);
    end;
    j := length(HuffTree) + 1;
    SetLength(HuffTree, j);
    if j = 1 then
    begin
      HuffTree[0].Value := Rc[0].Value;
      HuffTree[0].Index := 0;
      HuffTree[0].Parent := 0;
    end else
    begin
      HuffTree[j - 1].Value := HuffTree[j - 2].Value + HuffTree[j - 3].Value;
      HuffTree[j - 1].Index := HuffTree[j - 2].Parent;
      HuffTree[j - 1].Parent := 0;
    end;
    Sort(true);
  end;

var
  Content: TMemoryStream;
  i,len: Integer;
  Bits: TBitStream;
begin
  BitStrm := TBitStream.Create(Stream);
  try
    Content := TMemoryStream.Create;
    try
      Bits := TBitStream.Create(Content);
      try
        Bits.Put(PictRestrict.x,32);  //Width
        Bits.Put(PictRestrict.y,32);  //Height
        Bits.Put(0,32);               //X offset
        Bits.Put(0,32);               //Y offset
        Bits.Put(0,8);                // Region segment flag
        Bits.Write(@TRFlags, 4);
        Bits.Put(FSymbolsSize,32);
        InitRC;

        Sort(false);
        BuildTree;
        for i := 0 to length(UseTime) - 1 do
        begin
          NodeParent := HuffTree[i].Parent;
          SymbTemplates[i].Code := 0;
          if HuffTree[i].Branch then
            SymbTemplates[i].Code := 1;
          SymbTemplates[i].CodeLen := 1;
          if NodeParent = 0 then
          begin
            SymbTemplates[i].Code := 1;
            SymbTemplates[i].CodeLen := 1;
          end
          else
            while HuffTree[NodeParent - 1].Parent > 0 do
            begin
              if HuffTree[NodeParent - 1].Branch then
                SymbTemplates[i].Code := SymbTemplates[i].Code or (1 shl SymbTemplates[i].CodeLen);
              Inc(SymbTemplates[i].CodeLen);
              NodeParent := HuffTree[NodeParent - 1].Parent;
            end;
        end;
        CurrRun := 0;
        LenCurrRun := 0;
        SetLength(RCodes, 35);
        len := length(UseTime);
        SetLength(ALens, len);

        for i := 0 to len do
        begin
          if i = len then
            AddRun(true)
          else
          begin
            if UseTime[i].Value = 0 then
              CurrInd := 0
            else
              CurrInd := GetWayLength(UseTime[i].Index);
            ALens[i] := CurrInd;
            AddRun(false);
          end;
        end;
        len := length(RCodes);
        SetLength(UseTime, len);
        for i := 0 to len - 1 do
          UseTime[i].Value := RCodes[i];
        InitRC;
        SetLength(HuffTree, 0);
        Sort(false);
        CurrInd := 1;
        BuildTree;
        SetLength(PrefLen, 35);
        for i := 0 to len - 1 do
        begin
          if UseTime[i].Value = 0 then
          begin
            PrefLen[i] := 0;
          end else
          begin
            Q := GetWayLength(UseTime[i].Index);
            PrefLen[i] := Q;
          end;
        end;
        AssignPrefCodes(35);
        for i := 0 to 34 do
          Bits.Put(PrefLen[i], 4);
        i := 0;
        len := length(Runs);
        while i < len do
        begin
          case Runs[i] of
            32:
              begin
                Bits.Put(Codes[32], PrefLen[32]);
                Bits.Put(Runs[i + 1], 2);
                Inc(i);
              end;
            33:
              begin
                Bits.Put(Codes[33], PrefLen[33]);
                Bits.Put(Runs[i + 1], 3);
                Inc(i);
              end;
            34:
              begin
                Bits.Put(Codes[34], PrefLen[34]);
                Bits.Put(Runs[i + 1], 7);
                Inc(i);
              end;
          else
            Bits.Put(Codes[Runs[i]], PrefLen[Runs[i]]);
          end;
          Inc(i);
        end;
        Bits.FlushBits;
        PrefLen := nil;
        len := length(ALens);
        SetLength(PrefLen, len);
        for i := 0 to len - 1 do
          PrefLen[i] := ALens[i];
        AssignPrefCodes(len);
        for i := 0 to len - 1 do
        begin
          SymbTemplates[i].Code := Codes[i];
          SymbTemplates[i].CodeLen := PrefLen[i];
        end;
        SBStrips := 4;
        EofStrips := false;
        SBDSOffset := 3;
        Bits.Put(0, 1);
        StripT := -4;
        Firsts := 0;
        h := 0;
        while not(EofStrips) do
        begin
          Tc := FSymbols[h].y;
          DT := (Tc - StripT);
          Code := (DT div SBStrips);
          StripT := StripT + (SBStrips * Code);
          for i := 12 downto 0 do
          begin
            if (Code < b12[0, i + 1]) and (Code >= b12[0, i]) then
            begin
              Bits.Put(b12[2, i], b12[3, i]);
              Bits.Put(Code - b12[0, i], b12[1, i]);
              Break;
            end;
          end;
          SBStripsInd := (FSymbols[h].y div SBStrips);
          First := true;
          IDS := FSymbols[h].x - Firsts;
          Firsts := Firsts + IDS;
          CurS := Firsts;
          len := (SBStripsInd + 1) * SBStrips - 1;
          while FSymbols[h].y <= len do
          begin
            if not First then
            begin
              CurS := CurS - SBDSOffset;
              IDS := FSymbols[h].x - CurS - SBDSOffset;
              CurS := FSymbols[h].x;
            end;
            CodeAndAdd(Bits,IDS, First);
            First := false;
            Bits.Put(FSymbols[h].y - StripT, log32(SBStrips));
            CurS := CurS + SBDSOffset + FSymbolDictionary[FSymbols[h].Picture].Image.Width - 1;
            Bits.Put(SymbTemplates[FSymbols[h].Picture].Code, SymbTemplates[FSymbols[h].Picture].CodeLen);
            Inc(h);
            if h = FSymbolsSize then
            begin
              EofStrips := true;
              Break;
            end;
          end;
          Bits.Put(1, 2);
        end;
      finally
        Bits.Free
      end;
      BitStrm.Put(SegmentNumber,32);
      BitStrm.Write(@TRHeader,4);
      BitStrm.Put(Content.Size, 32);
      BitStrm.FlushBits;
      Content.Position := 0;
      Stream.CopyFrom(Content,Content.Size);
    finally
      Content.Free;
    end;
  finally
    BitStrm.Free;
  end;
end;

procedure TJBIG2Compression.GenerateStream(AStream: TStream);
begin
  SetLength(SymbTemplates,Length(UseTime));
  if (AStream = nil) then
    raise Exception.Create('Not set output JBIG2 stream.');
  if FSymbolsSize > 0 then
  begin
    if not FUseGlobalSD then
      FSymbolDictionary.SaveSymbolDictionary(AStream);
    SavePage(AStream,1);
     SaveTextRegion(AStream, 2);
  end else
  begin
    if FUseGlobalSD then
      SavePage(AStream,1)
    else
      SavePage(AStream,0);
  end;                        
end;


procedure TJBIG2Compression.Execute(OutStream: TMemoryStream; CompImage: TBitmap);
var
  Source, Symbol: TBWImage;
  FF: TImgPoint;
  Rect:TImgBorder;
  W,H: Integer;
begin
  Source := TBWImage.Create(CompImage);
  try
    PictRestrict.x := Source.Width;
    PictRestrict.y := Source.Height;

    Source.InitBlackPoint(FF);
    while Source.GetBlackPoint(FF) do
    begin
      Rect := Source.GetBorder(FF);
      W := Rect.RightBottom.x - Rect.LeftTop.x+1;
      H := Rect.RightBottom.y - Rect.LeftTop.y+1;
      if FJBIG2Options.SkipBlackDots and (W < FJBIG2Options.BlackDotSize) and (H < FJBIG2Options.BlackDotSize) then
      begin
          Source.ClearRectangle(Rect.LeftTop.x, Rect.LeftTop.y,W,H);
          Continue;
      end;
      Symbol := TBWImage.Create(W, H);
      try
        if FJBIG2Options.SymbolExtract = icImageOnly then
          Source.MoveAndClear(Symbol,FF,Rect)
        else
        begin
          Source.CopyRectangleTo(Symbol,Rect.LeftTop.x, Rect.LeftTop.y,0,0,W,H );
          Source.ClearRectangle(Rect.LeftTop.x, Rect.LeftTop.y,W,H);
        end;
        ProcessSymbol(Symbol,Rect.LeftTop.x, Rect.LeftTop.y);
      finally
        Symbol.Free;
      end;
    end;
  finally
    Source.Free;
  end;
  GenerateStream(OutStream);
end;

constructor TJBIG2Compression.Create(GlobalSymbolDictionary: TJBig2SymbolDictionary;JBIG2Options:TJBIG2Options);
begin
  if GlobalSymbolDictionary = nil then
  begin
    FUseGlobalSD := False;
    FSymbolDictionary := TJBig2SymbolDictionary.Create(nil,JBIG2Options);
  end else
  begin
    FUseGlobalSD := True;
    FSymbolDictionary := GlobalSymbolDictionary;
  end;
  FJBIG2Options := JBIG2Options;
  SymbTemplates := nil;
  UseTime:=nil;
end;

destructor TJBIG2Compression.Destroy;
begin
  if not FUseGlobalSD then
    FSymbolDictionary.Free;
  inherited;
end;

procedure TJBIG2Compression.ProcessSymbol(Symbol: TBWImage; x, y: Integer);
var
  I:Integer;
  idx:Integer;
  OldSize:Integer;
begin
  i := AddSymbol;
  FSymbols[i].x := x;
  FSymbols[i].y := y;
  idx := FSymbolDictionary.FindTemplate(Symbol);
  FSymbols[i].Picture := idx;
  OldSize := Length(UseTime);
  if idx < OldSize then
    Exit;
  SetLength(UseTime,idx+1);
  for i := OldSize to idx do
  begin
    UseTime[i].Index := i;
    UseTime[i].Value := 0;
  end;
  Inc(UseTime[idx].Value);
end;

