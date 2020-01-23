{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFRSA;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows,SysUtils,Classes,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif}
  llPDFCertKey, llPDFCrypt, llPDFASN1;


function SignDigest(PrivateKey: TPrivateKey; Hash: TASN1BaseObject):AnsiString;
implementation
uses llPDFMisc, llPDFResources, llPDFTypes;

type

  TLimb = Cardinal;
  PLimb = ^TLimb;
  TLimbHalf = Word;

const
  LimbSize = SizeOf(TLimb); // 4 bytes
  LimbBits = LimbSize * 8; // 32 bits
  LimbHalfSize = SizeOf(TLimbHalf);
  LimbHalfBits = LimbHalfSize * 8; // 32 bits


type
  TLimbArray = array[0..1] of TLimb;
  PLimbArray = ^TLimbArray;

  TUnsigned = record
    Count  : Cardinal;
    Capacity : Cardinal;
    Limbs  : PLimbArray;
  end;
  PUnsigned = ^TUnsigned;


function UnsCreate: PUnsigned;
begin
  Result := GetMemory(Sizeof(TUnsigned));
  Result.Count := 0;
  Result.Capacity := 0;
  Result.Limbs := nil;
end;


function UnsAlloc(Uns:PUnsigned;Size:Cardinal): PUnsigned;
begin
  if Uns = nil then
  begin
    Result := GetMemory(Sizeof(TUnsigned));
    Result.Count := 0;
    Result.Capacity := Size;
    if Size <> 0 then
      Result.Limbs := GetMemory(Sizeof(Cardinal)*Size)
    else
      Result.Limbs := nil;
  end else
  begin
    Result := Uns;
    if  Result.Capacity > Size then
      Exit;
    Result.Capacity := Size;
    Result.Limbs := ReallocMemory(Result.Limbs,Sizeof(Cardinal)*Size);
  end;
end;


procedure UnsFree(P:PUnsigned);
begin
  Freemem(P.Limbs);
  FreeMem(P);
end;


procedure UnsSetLimb(A:PUnsigned;Value:TLimb);
begin
  if Value <> 0 then
  begin
    UnsAlloc(A,1);
    A.Count := 1;
    A.Limbs[0] := Value;
  end else
  begin
    A.Count := 0;
  end;
end;

procedure UnsNormalize(A: PUnsigned);
begin
  while A.Count <> 0 do
  begin
    if A.Limbs[A.Count-1] <> 0 then
      break;
    dec(A.Count);
  end;
end;

procedure UnsSetSize(A:PUnsigned;NewSize:Cardinal);
var
  I: Cardinal;
begin
  if A.Capacity < NewSize then
    UnsAlloc(A,NewSize);
  if A.Count < NewSize then
  begin
    for i:= A.Count to NewSize -1 do
      A.Limbs[i] := 0;
  end;
  A.Count := NewSize;
end;

function PointerToUns(P:Pointer;Size: Cardinal):PUnsigned;
var
  SZ: Integer;
  MD,i : Integer;
  PB: PByteArray;
begin
  MD := Size and 3;
  SZ := Size shr 2;
  if MD <> 0 then inc(SZ);
  Result :=UnsAlloc(nil,sz);
  Result.Count := SZ;
  if MD <> 0 then
  begin
    PB := P;
    P := Pointer(FarInteger(P)+Cardinal(MD));
    case MD of
      3:
        begin
          Result.Limbs[sz-1] := PB[0] shl 16 + PB[1] shl 8 + PB[2] ;
        end;
      2:
        begin
          Result.Limbs[sz-1] := PB[0] shl 8 + PB[1];
        end;
      else
        begin
          Result.Limbs[sz-1] := PB[0];
        end;
    end;
    Dec(SZ);
  end;
  for i := sz -1 downto 0 do
  begin
    PB := P;
    P := Pointer(FarInteger(P)+4);
    Result.Limbs[i]  := PB[0] shl 24 + PB[1] shl 16 + PB[2] shl 8 + PB[3];
  end;
  UnsNormalize(Result);
end;

function UnsToString(A: PUnsigned):AnsiString;
var
  I, C: Integer;
  D: Cardinal;
begin
  SetLength(Result,A.Count shl 2);
  C := 1;
  for I := A.Count - 1 downto 0 do
  begin
    D := A.Limbs[i];
    Result[C] := AnsiChar((D shr 24) and $ff);
    Result[C+1] := AnsiChar((D shr 16) and $ff);
    Result[C+2] := AnsiChar((D shr 8) and $ff);
    Result[C+3] := AnsiChar(D  and $ff);
    Inc(c,4);
  end;
end;


procedure UnsSwap(var A, B: PUnsigned);
var
  Tmp: PUnsigned;
begin
  Tmp := A;
  A := B;
  B := Tmp;
end;


function UnsIsZero( A: PUnsigned): Boolean;
var
  l: Cardinal;
begin
  l := A.Count;
  while l <> 0 do
  begin
    if A.Limbs[l-1] <> 0 then
    begin
      Result := False;
      Exit;
    end;
    dec(l);
  end;
  Result := True;
end;

function UnsIsLimb( A: PUnsigned;Limb:TLimb): Boolean;
var
  l: Cardinal;
begin
  l := A.Count;
  while l <> 0 do
  begin
    if A.Limbs[l-1] <> 0 then
    begin
      Result :=  (l = 1) and (A.Limbs[0] = Limb);
      Exit;
    end;
    dec(l);
  end;
  Result := False;
end;


function UnsIsOdd(A: PUnsigned): Boolean;
begin
  if A.Count = 0 then
    Result := True
  else
    Result := (A.Limbs[0] and 1) = 1;
end;

function UnsIsEven(A: PUnsigned): Boolean;
begin
  if A.Count = 0 then
    Result := False
  else
    Result := (A.Limbs[0] and 1) = 0;
end;


procedure UnsCopy(A: PUnsigned; B: PUnsigned);
  var I : Cardinal;
begin
  if A = Nil then
    raise Exception.Create('Destination unsigned not inited');
  UnsAlloc(A,B.Count);
  A.Count := B.Count;
  for i := 0 to A.Count - 1 do
    A.Limbs[i] := B.Limbs[i];
end;


function UnsCmp(A, B: PUnsigned): Integer;
var L, M : Cardinal;
begin
  UnsNormalize(A);
  UnsNormalize(B);
  L := A.Count;
  M := B.Count;
  if L > M then
  begin
    Result := 1;
    Exit;
  end;
  if L < M then
  begin
    Result := -1;
    exit;
  end;
  while l <> 0 do
  begin
    m := l - 1;
    if A.Limbs[m] < B.Limbs[m] then
    begin
      result := -1;
      exit;
    end else
    if A.Limbs[m] > B.Limbs[m] then
    begin
      result := 1;
      exit;
    end;
    dec(l);
  end;
  result := 0;
end;


procedure UnsAdd( A,B,C: PUnsigned);
var
  X,Y  : Cardinal;
  I    : Cardinal;
  Carry: TLimb;
  ASize,BSize,CSize:Cardinal;
  BData,CData: PLimbArray;
begin
  if B.Count < C.Count then
  begin
    BSize := C.Count;
    CSize := B.Count;
    BData := C.Limbs;
    CData := B.Limbs;
  end else
  begin
    BSize := B.Count;
    CSize := C.Count;
    BData := B.Limbs;
    CData := C.Limbs;
  end;
  if CSize = 0 then
  begin
    if A.Capacity < BSize then
      UnsAlloc(A,BSize);
    A.Count := BSize;
    for i := 0 to BSize - 1 do
      A.Limbs[i] := BData[i];
    exit;
  end;
  ASize := BSize+1;
  if A.Capacity < ASize then
    UnsAlloc(A,ASize);
  A.Count := ASize;
  Carry := 0;
  for i := 0 to CSize - 1 do
  begin
    X := BData[i];
    Y := CData[i];
    Y := Y + Carry;
    if Y < Carry then
      Carry := 1
    else
      Carry := 0;
    Y := Y + X;
    if Y < X then
      Inc(Carry);
    A.Limbs[i] := Y;
  end;
  for i := CSize to BSize - 1 do
  begin
    X := BData[i];
    X := X + Carry;
    if X < Carry then
      Carry := 1
    else
      Carry := 0;
    A.Limbs[i] := X;
  end;
  if Carry > 0 then
    A.Limbs[ASize - 1 ] := Carry
  else
    Dec(A.Count);
end;

function UnsSub(A,B,C:PUnsigned):Integer;
var
  X,Y  : Cardinal;
  I    : Integer;
  Carry: TLimb;
  ASize,BSize,CSize:Cardinal;
  BData,CData: PLimbArray;
begin
  i := UnsCmp(B,C);
  if i > 0 then
  begin
    BSize := B.Count;
    CSize := C.Count;
    BData := B.Limbs;
    CData := C.Limbs;
    Result := 1;
  end else
  if i <0 then
  begin
    BSize := C.Count;
    CSize := B.Count;
    BData := C.Limbs;
    CData := B.Limbs;
    Result := -1;
  end else
  begin
    A.Count := 0;
    Result := 1;
    Exit;
  end;
  if CSize = 0 then
  begin
    if A.Capacity < BSize then
      UnsAlloc(A,BSize);
    A.Count := BSize;
    for i := 0 to BSize - 1 do
      A.Limbs[i] := BData[i];
    exit;
  end;
  ASize := BSize;
  if A.Capacity < ASize then
    UnsAlloc(A,ASize);
  Carry := 0;
  for i := 0 to CSize - 1 do
  begin
    X := BData[i];
    Y := CData[i];
    Y := Y + Carry;
    if Y < Carry then
      Carry := 1
    else
      Carry := 0;
    Y := X - Y;
    if Y > X then
      Inc(Carry);
    A.Limbs[i] := Y;
  end;
  for i := CSize to BSize - 1 do
  begin
    if Carry >0 then
    begin
      X := BData[i];
      X := X - Carry;
      if X > Carry then
        Carry := 1
      else
        Carry := 0;
      A.Limbs[i] := X;
    end else
      A.Limbs[i] := BData[i];
  end;
  A.Count := ASize;
  UnsNormalize(A);
end;

procedure UnsDec(A: PUnsigned);
var
  i,X:Cardinal;
  Carry: TLimb;
begin
  if UnsIsZero(A) then
    Exit;
  Carry := 1;
  for i := 0 to A.Count - 1 do
  begin
    if Carry >0 then
    begin
      X := A.Limbs[i];
      X := X - Carry;
      if X > Carry then
        Carry := 1
      else
        Carry := 0;
      A.Limbs[i] := X;
    end else
      break;
  end;
end;

procedure UnsInc(A: PUnsigned);
var
  i,X,L: Cardinal;
  Carry: TLimb;
begin
  if UnsIsZero(A) then
    Exit;
  Carry := 0;
  L := A.Count;
  for i:= 0 to L - 1 do
  begin
    if Carry >0 then
    begin
      X := A.Limbs[i];
      X := X + Carry;
      if X < Carry then
        Carry := 1
      else
        Carry := 0;
      A.Limbs[i] := X;
    end else
      break;
  end;
  if Carry >0 then
  begin
    UnsSetSize(A,L+1);
    A.Limbs[L] := 1;
  end;
end;


procedure MulCardinal(AL,AH:PCardinal;B,C:Cardinal);
var
  BL,CL,BH,CH: TLimb;
  T,U: TLimb;
begin
  BL := B and $FFFF;
  BH := B shr 16;
  CL := C and $FFFF;
  CH := C shr 16;
  AL^ := BL * CL;
  T := BL * CH;
  U := BH * CL;
  AH^ := CH * BH;
  Inc(T,U);
  if T < U then
    AH^ := AH^ + $10000;
  U := T Shl 16;
  Inc(AL^,U);
  if AL^ < U then
    inc(AH^);
  Inc(AH^,T shr 16);
end;

function UnsGetBit(A: PUnsigned; Bit: Cardinal): Cardinal;
begin
  Result := (A.Limbs[(Bit - 1) shr 5 ] shr ((Bit - 1) and $1F)) and 1;
end;

function UnsBitCount(A:PUnsigned):Integer;
var
  l: Cardinal;
begin
  l := A.Count;
  while l <> 0 do
  begin
    if A.Limbs[l-1] <> 0 then
    begin
      Result := 32* (l-1);
      l := A.Limbs[l-1];
      while l <> 0 do
      begin
        inc(Result);
        l := l shr 1;
      end;
      Exit;
    end;
    dec(l);
  end;
  Result := 0;
end;

procedure UnsMul(A,B,C: PUnsigned);
var
  I,J,idx: Integer;
  t: PUnsigned;
  BL:Cardinal;
  CL,W, Carry:Cardinal;
  BData:PLimbArray;
  CData:PLimbArray;
  tmp:PLimbArray;
  ML,MH: Cardinal;
begin
  i := UnsCmp(B,C);
  if i < 0 then
  begin
    BL := C.Count;
    CL := B.Count;
    BData := C.Limbs;
    CData := B.Limbs;
  end else
  begin
    BL := B.Count;
    CL := C.Count;
    BData := B.Limbs;
    CData := C.Limbs;
  end;
  i:= BL+CL;
  t := UnsCreate;
  try
    UnsSetSize(t,i);
    tmp := T.Limbs;
    for i := 0 to CL-1 do
    begin
      W := CData[i];
      Carry := 0;
      for J := 0 to BL-1 do
      begin
        MulCardinal(@ML,@MH,W,BData[j]);
        idx := j+i;
        inc(tmp[idx],Carry);
        if tmp[idx] < Carry then
          Carry := 1
        else
          Carry := 0;
        inc(tmp[idx],ML);
        if tmp[idx] < ML then
          inc(Carry);
        inc(idx);
        inc(tmp[idx],Carry);
        if tmp[idx] < Carry then
          Carry := 1
        else
          Carry := 0;
        inc(tmp[idx],MH);
        if tmp[idx] < MH then
          inc(Carry);
        while Carry <> 0 do
        begin
          inc(idx);
          inc(tmp[idx],Carry);
          if tmp[idx] < Carry then
            Carry := 1
          else
            Carry := 0;
        end;
      end;
    end;
    UnsCopy(A,t);
  finally
    UnsFree(t);
  end;
end;


procedure UnsShlOne(A: PUnsigned);
var I, L : Integer;
begin
  L := A.Count;
  if L = 0 then
    exit;
  if (A.Limbs[l-1] and $80000000) <> 0 then
  begin
    UnsSetSize(A, L + 1);
    A.Limbs[l] := 1;
  end;
  for i:= l-1 downto 1 do
    A.Limbs[i] := (A.Limbs[i] shl 1) or (A.Limbs[i-1] shr 31);
  A.Limbs[0] := A.Limbs[0] shl 1;
end;

procedure UnsShrOne(A: PUnsigned);
var I, L : Integer;
begin
  L := A.Count;
  if L = 0 then
    exit;
  for i:= 0 to l - 2 do
    A.Limbs[i] := (A.Limbs[i] shr 1) or (A.Limbs[i+1] shl 31);
  A.Limbs[l - 1] := A.Limbs[l-1] shr 1;
end;


procedure UnsGCD(B, A, C, D: PUnsigned);
var
  G: PUnsigned;
  X, Y: PUnsigned;
  U, V: PUnsigned;
  Ba, Bb, Bc, Bd: PUnsigned;
  Tm: PUnsigned;
  OldC, OldD : PUnsigned;
  cmp: Integer;
  Sa,Sb,Sc,Sd:Boolean;

  function SignAdd(A,B,C:PUnsigned;BSign,CSign:Boolean):Boolean;
  begin
    if CSign = BSign then
    begin
      Result := BSign;
      UnsAdd(A,B,C);
    end else
    begin
      if UnsCmp(B,C) > 0 then
      begin
        UnsSub(A,B,C);
        Result := BSign;
      end else
      begin
        UnsSub(A,C,B);
        Result := CSign;
      end;
    end;
  end;

  function SignSub(A,B,C:PUnsigned;BSign,CSign:Boolean):Boolean;
  begin
    if BSign = CSign then
    begin
      if BSign then
        Result := UnsSub(A,B,C) >=0
      else
        Result := UnsSub(A,C,B) >=0
    end else
    begin
      Result := BSign;
      UnsAdd(a,b,c);
    end;
  end;

begin
  X:=UnsCreate;
  Y:=UnsCreate;
  U := UnsCreate;
  V :=UnsCreate;
  Ba :=UnsCreate;
  Bb :=UnsCreate;
  Bc:=UnsCreate;
  Tm:=UnsCreate;
  OldC:=UnsCreate;
  OldD:=UnsCreate;
  try

    Bd := OldD;
    UnsCopy(X, A);
    UnsCopy(Y, B);

    G := OldC;
    UnsSetLimb(G,1);

    while  UnsIsEven(X) and UnsIsEven(Y) do
    begin
      UnsShrOne(X);
      UnsShrOne(Y);
      UnsShlOne(G);
    end;

    UnsCopy(U, X);
    UnsCopy(V, Y);

    UnsSetLimb(Ba,1);
    Sa := True;
    UnsSetLimb(Bb,0);
    Sb := True;
    UnsSetLimb(Bc,0);
    Sc := True;
    UnsSetLimb(Bd,1);
    Sd := True;
    repeat
      while UnsIsEven(U) do
      begin
        UnsShrOne(U);
        if UnsIsEven(Ba) and UnsIsEven(Bb) then
        begin
          UnsShrOne(Ba);
          UnsShrOne(Bb);
        end else
        begin
          Sa := SignAdd(Tm,Ba,Y,Sa,true);
          UnsSwap(Ba, Tm);
          UnsShrOne(Ba);

          Sb := SignSub(Tm,Bb,X,sb,true);
          UnsSwap(Bb, Tm);
          UnsShrOne(Bb);
        end;
      end;
      while UnsIsEven(V) do
      begin
        UnsShrOne(V);
        if UnsIsEven(Bc) and UnsIsEven(Bd) then
        begin
          UnsShrOne(Bc);
          UnsShrOne(Bd);
        end else
        begin
          Sc := SignAdd(Tm,Bc,Y,Sc,true);
          UnsSwap(Bc, Tm);
          UnsShrOne(Bc);
          Sd := SignSub(Tm,Bd,X,Sd,true);
          UnsSwap(Bd, Tm);
          UnsShrOne(Bd);
        end;
      end;

      cmp := UnsCmp(U,V);
      if Cmp >= 0 then
      begin
        UnsSub(tm, U, V);
        UnsSwap(U, Tm);
        Sa := SignSub(Tm,Ba,Bc,Sa,Sc);
        UnsSwap(Ba, Tm);
        Sb := SignSub(Tm, Bb, Bd,Sb,sd);
        UnsSwap(Bb, Tm);
      end else
      begin
        UnsSub(tm, V, U);
        UnsSwap(V,Tm);
        Sc := SignSub(Tm, Bc, Ba,Sc,sa);
        UnsSwap(Bc, Tm);
        Sd := SignSub(Tm,Bd,Bb,Sd,sb);
        UnsSwap(Bd, Tm);
      end;

    until UnsIsZero(U);

    UnsMul(Tm,G, V);
    UnsSwap(G, Tm);
    if G <> OldC then OldC := G;

    while not sd  do
    begin
      Sd := SignAdd(Tm,Bd, A,Sd,true);
      UnsSwap(Tm, Bd);
    end;

    if OldD <> Bd then OldD := Bd;

    UnsCopy(C, OldC);
    UnsCopy(D, OldD);
  finally
    UnsFree(OldC);
    UnsFree(OldD);
    UnsFree(Y);
    UnsFree(X);
    UnsFree(U);
    UnsFree(V);
    UnsFree(Ba);
    UnsFree(Bb);
    UnsFree(Bc);
    UnsFree(Tm);
  end;
end;


procedure UnsMod(Res, X, N : PUnsigned);
var
  I,cmp : integer;
  Cnt : integer;
  Tmp : PUnsigned;
begin
  Tmp := UnsCreate;
  try
    UnsSetSize(Res,1);
    Res.Limbs[0] := 0;
    cnt := UnsBitCount(X);
    for i := cnt downto 1 do
    begin
      UnsShlOne(Res);
      Res.Limbs[0] := Res.Limbs[0] or UnsGetBit(X,I);
      cmp := UnsCmp(Res,N);
      if cmp >0 then
      begin
        UnsSub(tmp,Res,N);
        UnsCopy(Res,tmp);
      end else
      if cmp = 0 then
      begin
        UnsSetSize(Res,1);
        Res.Limbs[0] := 0;
      end;
    end;
  finally
    UnsFree(Tmp);
  end;
end;

procedure UnsShiftLeftLimb( A: PUnsigned; N: Cardinal);
var
  I: Cardinal;
  OldSize:Cardinal;
begin
  OldSize := A.Count;
  UnsSetSize(A,OldSize + N);
  for i := OldSize - 1 downto 0 do
    A.Limbs[i+N] := A.Limbs[i];
  for I := 0 to N - 1 do
    A.Limbs[i] := 0;
end;

procedure UnsShiftRightLimb( A: PUnsigned; N: Cardinal);
var
  I: Cardinal;
  OldSize:Cardinal;
begin
  OldSize := A.Count;
  for i := 0 to OldSize - N do
    A.Limbs[i] := A.Limbs[i+N];
  UnsSetSize(A,OldSize - N);
end;


procedure UnsAddShort(A : PUnsigned; N : TLimb;   R : PUnsigned);
var
  I : integer;
  Carry : TLimb;
  Len: Cardinal;
begin
  Carry := N;
  Len := A.Count;
  UnsSetSize(R,Len);
  for i:= 0 to Len - 1 do
  begin
    if Carry > 0 then
    begin
      R.Limbs[i] := A.Limbs[i]+Carry;
      if R.Limbs[i] < carry then
        carry := 1
      else
        carry := 0;
    end else
      R.Limbs[i] := A.Limbs[i];
  end;
  if Carry >0 then
  begin
    UnsSetSize(R,len+1);
    R.Limbs[len] := Carry;
  end;
end;

procedure UnsMulShort(A: PUnsigned; B: TLimb;  Res: PUnsigned);
var
  I: Integer;
  Carry : TLimb;
  AH,AL: TLimb;
  Len:Cardinal;
begin
  Carry := 0;
  Len:= A.Count;
  UnsSetSize(Res,Len);
  for I := 0 to Len-1 do
  begin
    MulCardinal(@AL,@AH,A.Limbs[i],B);
    AL := AL+Carry;
    if AL < Carry then
      inc(Ah);
    Carry := Ah;
    Res.Limbs[i] := AL;
  end;
  if Carry <> 0 then
  begin
    UnsSetSize(Res, Len+1);
    Res.Limbs[Len] := Carry;
  end else
  begin
    I := Res.Count;
    while I > 0 do
    begin
      if Res.Limbs[I-1] <> 0 then
        break;
      Dec(I);
    end;
    Res.Count := I;
  end;
end;



procedure UnsShlNum(Src, Dest: PUnsigned; Bits: Integer);
var
  I: Cardinal;
  M, N: LongWord;
  Carry, T: TLimb;
begin
  if UnsIsZero(Src) then
  begin
    UnsSetLimb(Dest,0);
    Exit;
  end;
  M := Bits mod 32;
  N := Bits shr 5;
  UnsSetSize(Dest,0);
  UnsSetSize(Dest,Src.Count + N);
  Carry := 0;
  if M = 0 then
  begin
    for i := 0 to Src.Count - 1 do
      Dest.Limbs[i+N] := Src.Limbs[i];
  end else
  begin
    for i := 0 to Src.Count - 1 do
    begin
      T := Src.Limbs[i];
      Dest.Limbs[i+N] := T shl M or Carry;
      Carry := T shr (32-M);
    end;
    if Carry >0 then
    begin
      M := Dest.Count;
      UnsSetSize(Dest,M+1);
      Dest.Limbs[M]:= Carry;
    end;
  end;
end;

procedure UnsPowerAndMod(Res, A, E, N: PUnsigned);
var
  Tm, Xinv, Yinv: PUnsigned;
  I, Rs, Bitsinr: Integer;
  N0: Cardinal;
  T1, T2, T3 : PUnsigned;

  procedure UnsMMulNExp(A, B, N: PUnsigned; var Res: PUnsigned);
  var
    I: Cardinal;
    AL,AH: TLimb;
    T:PUnsigned;
  begin
    T := Res;
    UnsSetSize(T,1);
    T.Limbs[0] := 0;
    UnsSetSize(A,N.Count);
    for I := 0 to A.Count - 1 do
    begin
      MulCardinal(@AL,@AH,A.Limbs[I], B.Limbs[0]);
      if AH <> 0 then
      begin
        UnsSetSize(T2,2);
        T2.Limbs[0] := AL;
        T2.Limbs[1] := AH;
      end else UnsSetLimb(T2,AL);

      UnsAddShort(T2, T.Limbs[0], T3);
      UnsMulShort(T3, N0, T1);
      UnsMulShort(N, T1.Limbs[0], T2);
      UnsMulShort(B, A.Limbs[I], T1);
      UnsAdd(T3,T, T1);
      UnsAdd(T1, T3, T2);
      UnsShiftRightLimb(T1, 1);
      UnsSwap(T1, T);
    end;
    while UnsCmp(T, N)>0 do
    begin
      UnsSub(T1, T, N);
      UnsSwap(T1, T);
    end;
    Res := T;
  end;

  procedure UnsPowerAndModEven(Res,X, E, N : PUnsigned);
  var
    T1, T2 : PUnsigned;
    Power : integer;
  begin
    t1 := UnsCreate;
    t2 := UnsCreate;
    try
      UnsCopy(T1,E);
      Power := 0;
      while not (UnsIsOdd(T1) or UnsIsZero(T1) ) do
      begin
        inc(Power);
        UnsShrOne(T1);
      end;
      if not UnsIsZero(T1) then
        UnsPowerAndMod(T2,X,T1,N)
      else
        UnsSetLimb(T2,1);

      while Power >0 do
      begin
        UnsMul(T1,T2,T2);
        UnsMod(T2,T1,N);
        Dec(Power);
      end;
      UnsCopy(Res,T2);
    finally
      UnsFree(t1);
      UnsFree(t2);
    end;
  end;


begin
  if not UnsIsOdd(E) then
  begin
    UnsPowerAndModEven(A, E, N, Res);
    Exit;
  end;

  Xinv := UnsCreate;
  Yinv:= UnsCreate;
  Tm:= UnsCreate;
  T1:= UnsCreate;
  T2:= UnsCreate;
  T3:= UnsCreate;
  try
    Rs := UnsBitCount(E);
    UnsSetSize(E,N.Count+1);
    UnsSetSize(E,N.Count);
    Bitsinr := E.Count shl 5;
    UnsSetLimb(t1,N.Limbs[0]);
    UnsSetSize(t2,2);
    t2.Limbs[1] := 1;
    UnsGCD(T1, T2, Tm, T3);
    N0 := $FFFFFFFF - T3.Limbs[0] + 1;

    UnsSetLimb(T1,1);
    UnsSetLimb(T2,1);
    UnsSetLimb(T3,1);
    UnsSetLimb(Yinv,1);
    UnsShlNum(Yinv, Xinv, Bitsinr);
    UnsMod(Yinv, Xinv, N);
    UnsShlNum(A, Tm, Bitsinr);
    UnsMod(Xinv, Tm, N);

    for I := Rs downto 1 do
    begin
      UnsMMulNExp(Yinv, Yinv, N, Tm);
      UnsSwap(Tm, Yinv);
      if UnsGetBit(E, I) = 1 then
      begin
        UnsMMulNExp(Yinv, Xinv, N,Tm);
        UnsSwap(Tm, Yinv);
      end;
    end;

    UnsSetLimb(Xinv,1);
    UnsMMulNExp(Yinv, Xinv, N, Res);
    UnsNormalize(E);
  finally
    UnsFree(Xinv);
    UnsFree(Yinv);
    UnsFree(Tm);
    UnsFree(T1);
    UnsFree(T2);
    UnsFree(T3);
  end;
end;


function SignDigest(PrivateKey: TPrivateKey; Hash: TASN1BaseObject):AnsiString;
var
  C, dP,dQ,n,p,q,qInv,tmp,tmp2: PUnsigned;
  M1,M2: PUnsigned;
  ModulusRealSize, ModulusSize:Integer;
  HashStr:AnsiString;
  HashSize,i: Integer;
  SignBlock: AnsiString;
begin
  HashStr := Hash.WriteToString;
  HashSize := Length(HashStr);

  ModulusSize := Length(PrivateKey.Modulus.Data);
  ModulusRealSize := ModulusSize;
  i := 0;
  while (i < ModulusSize) and (PrivateKey.Modulus.Data[i+1] = #0) do inc (i);
  dec(ModulusRealSize,i);
  if HashSize >ModulusRealSize - 11 then
    raise EPDFSignatureException.Create(SSmallModulusSize);
  SetLength(SignBlock,ModulusRealSize);
  SignBlock[1] := #0;
  SignBlock[2] := #1;
  for i := 3 to ModulusRealSize - HashSize - 1 do SignBlock[i] := #255;
  SignBlock[ ModulusRealSize - HashSize] := #0;
  move(HashStr[1],SignBlock[ModulusRealSize - HashSize + 1],HashSize);

  C := PointerToUns(@SignBlock[1], ModulusRealSize);
  n := PointerToUns(@PrivateKey.Modulus.Data[1], Length(PrivateKey.Modulus.Data));
  p := PointerToUns(@PrivateKey.Prime1.Data[1], Length(PrivateKey.Prime1.Data));
  q := PointerToUns(@PrivateKey.Prime2.Data[1], Length(PrivateKey.Prime2.Data));
  dP := PointerToUns(@PrivateKey.Exponent1.Data[1], Length(PrivateKey.Exponent1.Data));
  dQ := PointerToUns(@PrivateKey.Exponent2.Data[1], Length(PrivateKey.Exponent2.Data));
  qInv := PointerToUns(@PrivateKey.Coeficient.Data[1], Length(PrivateKey.Coeficient.Data));
  try
    if UnsCmp(C,n) >= 0 then
      raise EPDFException.Create(SRSAError);
    tmp:= UnsCreate;
    tmp2:= UnsCreate;
    M1:= UnsCreate;
    M2:= UnsCreate;
    try
      UnsPowerAndMod(M1,c,dp,p);
      UnsPowerAndMod(M2,c,dq,q);
      if UnsCmp(M1,M2)>0 then
      begin
        UnsSub(tmp,M1,M2);
      end else
      begin
        UnsSub(tmp2,M2,M1);
        if UnsCmp(P,tmp2) >0 then
          UnsSub(tmp,P,tmp2)
        else
        begin
          UnsMod(tmp,tmp2,p);
          UnsSub(tmp2,p,tmp);
          UnsSwap(tmp,tmp2);
        end;
      end;

      UnsMul(tmp2,qInv,tmp);
      UnsMod(tmp,tmp2,p);
      UnsMul(tmp2,tmp,q);
      UnsAdd(tmp,M2,tmp2);
      Result := UnsToString(tmp);
    finally
      UnsFree(tmp);
      UnsFree(tmp2);
      UnsFree(M1);
      UnsFree(M2);
    end;
  finally
    UnsFree(c);
    UnsFree(n);
    UnsFree(p);
    UnsFree(q);
    UnsFree(dP);
    UnsFree(dQ);
    UnsFree(qInv);
  end;
end;

end.


