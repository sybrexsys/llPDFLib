{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFSecurity;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, System.Math, Vcl.Graphics,
{$endif}
  llPDFTypes;

type

  TPDFEncryptKey = array [ 0..31] of Byte;

  TRC4Data = record
    Key: array[0..255] of byte; { current key }
  end;



  TPDFSecurity = record
    State               : TPDFSecurityState;
    Key                 : TPDFEncryptKey;
    Permission          : Integer;
    FileID              : AnsiString;
    Revision            : Integer;
    Version             : Integer;
    Owner               : AnsiString;
    User                : AnsiString;
    Perm                : AnsiString;
    OE                  : AnsiString;
    UE                  : AnsiString;
  end;


  procedure InitDocumentSecurity(var DocSec: TPDFSecurity; KeyLength: TPDFSecurityState;
    Options: TPDFSecurityPermissions; UserPassword, OwnerPassword, FileName :AnsiString; CryptMetadata:Boolean);
  procedure CryptStringToStream(DocSec: TPDFSecurity; AStream:TStream; St:AnsiString;ID: Integer);
  procedure CryptStreamToStream(DocSec: TPDFSecurity; FromStream:TMemoryStream; ToStream : TStream; ID: Integer);
  function CryptString( DocSec: TPDFSecurity; St:AnsiString;ID: Integer;Wrap:Boolean = true ):AnsiString;




implementation

uses llPDFResources, llPDFMisc, llPDFCrypt;


const

  PassKey: array [ 1..32 ] of Byte = ( $28, $BF, $4E, $5E, $4E, $75, $8A, $41, $64, $00, $4E,
    $56, $FF, $FA, $01, $08, $2E, $2E, $00, $B6, $D0, $68,
    $3E, $80, $2F, $0C, $A9, $FE, $64, $53, $69, $7A );

procedure InitDocumentSecurity(var DocSec: TPDFSecurity; KeyLength: TPDFSecurityState;
      Options: TPDFSecurityPermissions; UserPassword, OwnerPassword, FileName :AnsiString; CryptMetadata:Boolean);
var
  S, W: AnsiString;
  Pass: array [ 1..32 ] of byte;
  I, J: Byte;
  Digest, DG1: array [0.. 15] of Byte ;
  L:Integer;
  Z, C: AnsiString;
  Op: array [ 1..32 ] of char;
  K2: TPDFEncryptKey;
  BK:array [0.. 8] of dword;
  UVS, UKS, OVS, OKS: array[0..7] of Byte;
  ZV, zz: array[0..15] of Byte;
  AES: TAESCipher;
  Dig: array[0..31] of Byte;
  Hash: THash;
  FileID: array [0..15] of Byte;
  RC4:TRC4Cipher;
begin
  s := FileName + AnsiString(FormatDateTime ( 'ddd dd-mm-yyyy hh:nn:ss.zzz', Now ));
  DataToHash(TMD5Hash,@s[1],Length(s),FileID);
  DocSec.FileID := DataToHex(@FileID, SizeOf(FileID)) ;
  DocSec.State := KeyLength;
  if KeyLength = ssNone then
    Exit;
  if KeyLength = ss40RC4 then
  begin
    DocSec.Permission := $7FFFFFE0;
    DocSec.Permission := DocSec.Permission shl 1;
    if coPrint in Options then
      DocSec.Permission := DocSec.Permission or 4;
    if coModifyStructure in Options then
      DocSec.Permission := DocSec.Permission or 8;
    if coCopyInformation in Options then
      DocSec.Permission := DocSec.Permission or 16;
    if coModifyAnnotation in Options then
      DocSec.Permission := DocSec.Permission or 32;
  end else
  begin
    DocSec.Permission := $7FFFF860 shl 1;
    Inc(DocSec.Permission, 1024);
    if coPrint in Options then
      DocSec.Permission := DocSec.Permission or 4;
    if coModifyStructure in Options then
      DocSec.Permission := DocSec.Permission or 8;
    if coCopyInformation in Options then
      DocSec.Permission := DocSec.Permission or 16;
    if coModifyAnnotation in Options then
      DocSec.Permission := DocSec.Permission or 32;
    if coFillAnnotation in Options then
      DocSec.Permission := DocSec.Permission or 256;
    if coPrintHi in Options then
      DocSec.Permission := DocSec.Permission or 2048;
    if coAssemble in Options then
      DocSec.Permission := DocSec.Permission or 1024;
    if coExtractInfo in Options then
      DocSec.Permission := DocSec.Permission or 512;
  end;

  if KeyLength <ss256AES then
  begin
  // Owner
    L := Length ( OwnerPassword );
    if L > 0 then
      Move ( OwnerPassword [ 1 ], Pass, min( L, 32) );
    if L < 32 then
      Move ( PassKey, Pass [ L + 1 ], 32 - L );
    DataToHash( TMD5Hash, @Pass [ 1 ], 32, Digest );
    if KeyLength <> ss40RC4 then
      for I := 1 to 50 do
        DataToHash( TMD5Hash, @Digest, 16, Digest );
    L := Length ( UserPassword );
    if L > 0 then
      Move ( UserPassword [ 1 ], Pass, min( L, 32) );
    if L < 32 then
      Move ( PassKey, Pass [ L + 1 ], 32 - L );
    SetLength ( DocSec.Owner, 32 );
    if KeyLength <> ss40RC4 then
      RC4 := TRC4Cipher.Create(@Digest,16,nil)
    else
      RC4 := TRC4Cipher.Create(@Digest,5,nil);
    try
      RC4.DecodeTo(@Pass, @DocSec.Owner [ 1 ], 32 );
    finally
      RC4.Free
    end;
    if KeyLength <> ss40RC4 then
      for i := 1 to 19 do
      begin
        for J := 0 to 15 do
          DG1 [ j ] := Digest [ j ] xor I;
        RC4 := TRC4Cipher.Create(@DG1, 16, nil);
        try
          RC4.Encode(@DocSec.Owner [ 1 ], 32 );
        finally
          RC4.Free;
        end;
      end;
    z := DocSec.Owner;
    W := Copy ( UserPassword, 1, L );
    SetLength ( W, 32 );
    if L < 32 then
      Move ( PassKey, W [ L + 1 ], 32 - L );
    C := '';
    Hash := TMD5Hash.Create;
    try
      Hash.Update ( w [ 1 ], 32 );
      Hash.Update ( z [ 1 ], 32 );
      Hash.Update ( DocSec.Permission, 4 );
      Hash.Update ( FileID, 16 );
      Hash.Finish (@Digest);
    finally
      Hash.Free;
    end;
    if KeyLength <> ss40RC4 then
    begin
      for i := 1 to 50 do
        DataToHash(TMD5Hash, @Digest, 16, Digest );
      Move ( Digest, DocSec.Key, 16 );
    end
    else
      Move ( Digest, DocSec.Key, 5 );

  //User
    if KeyLength = ss40RC4 then
    begin
      RC4 := TRC4Cipher.Create(@DocSec.Key, 5,nil );
      try
        RC4.EncodeTo(@PassKey, @op, 32 );
      finally
        RC4.Free;
      end;
      SetLength (DocSec.User,32 );
      Move(Op,DocSec.User[1],32);
    end else
    begin
      Hash := TMD5Hash.Create;
      try
        Hash.Update( PassKey, 32 );
        Hash.Update ( FileID, 16 );
        Hash.Finish ( @Digest);
      finally
        Hash.Free;
      end;
      for I := 0 to 19 do
      begin
        for J := 1 to 16 do
          K2 [ J-1 ] := DocSec.Key [ J-1 ] xor I;
        RC4 := TRC4Cipher.Create(@k2, 16, nil);
        try
          RC4.Encode ( @Digest, 16 );
        finally
          RC4.Free;
        end;
      end;
      SetLength ( DocSec.User, 32 );
      Move ( Digest, DocSec.User [ 1 ], 16 );
      Randomize;
      for I := 17 to 32 do
        DocSec.User [ i ] := ANSIChar ( Random ( 200 ) + 32 );
    end
  end else
  begin
    Hash := TSHA256Hash.Create;
    try
      Randomize;
      for I := 0 to 7 do
      begin
        BK[I]:= Random($7FFFFFFF)+Random($7FFFFFFF);
        UVS[I]:= Byte(Random($FFFF));
        UKS[I]:= Byte(Random($FFFF));
        OVS[I]:= Byte(Random($FFFF));
        OKS[I]:= Byte(Random($FFFF));
      end;

      Hash.Init;
      Hash.Update(UserPassword[1], Min(127,Length(UserPassword)));
      Hash.Update(UVS,8);
      Hash.Finish(@Dig);

      SetLength(DocSec.User,48);
      Move(Dig,DocSec.User[1],32);
      Move(UVS,DocSec.User[33],8);
      Move(UKS,DocSec.User[41],8);

      Hash.Init;
      Hash.Update(UserPassword[1], Min(127,Length(UserPassword)));
      Hash.Update(UKS,8);
      Hash.Finish(@Dig);

      FillChar(ZV,16,0);
      SetLength(DocSec.UE,32);
      AES := TAESCipher.Create(@Dig[0],256, @ZV[0]);
      try
        AES.EncodeTo(@BK[0], @DocSec.UE[1], 32, true);
      finally
        AES.Free;
      end;

      Hash.Init;
      Hash.Update(OwnerPassword[1], Min(127,Length(OwnerPassword)));
      Hash.Update(OVS,8);
      Hash.Update(DocSec.User[1],48);
      Hash.Finish(@Dig);

      SetLength(DocSec.Owner,48);
      Move(Dig,DocSec.Owner[1],32);
      Move(OVS,DocSec.Owner[33],8);
      Move(OKS,DocSec.Owner[41],8);


      Hash.Init;
      Hash.Update(OwnerPassword[1], Min(127,Length(OwnerPassword)));
      Hash.Update(OKS,8);
      Hash.Update(DocSec.User[1],48);
      Hash.Finish(@Dig);

      FillChar(ZV,16,0);
      SetLength(DocSec.OE,32);
      AES := TAESCipher.Create(@Dig[0],256,@ZV[0]);
      try
        AES.EncodeTo(@BK[0], @DocSec.OE[1], 32, true);
      finally
        AES.Free;
      end;
      SetLength( DocSec.Perm, 16);
      FillChar(ZV,16,0);
      zz[0] := Byte(DocSec.Permission);
      zz[1] := Byte(DocSec.Permission shr 8);
      zz[2] := Byte(DocSec.Permission shr 16);
      zz[3] := Byte(DocSec.Permission shr 24);
      zz[4] := $ff;
      zz[5] := $ff;
      zz[6] := $ff;
      zz[7] := $ff;
      if CryptMetadata then
        zz[8] := Byte('T')
      else
        zz[8] := Byte('F');
      zz[9] := Byte('a');
      zz[10] := Byte('d');
      zz[11] := Byte('b');
      zz[12] := 0;
      zz[13] := 0;
      zz[14] := 0;
      zz[15] := 0;

      AES := TAESCipher.Create(@BK[0],256,@ZV[0]);
      try
        AES.EncodeTo(@zz[0], @DocSec.Perm[1], 16,True);
      finally
        AES.Free;
      end;
      Move(BK,DocSec.Key, 32);
    finally
      Hash.Free;
    end;
  end;
end;

procedure CryptStringToStream(DocSec: TPDFSecurity; AStream:TStream; St:AnsiString;ID: Integer);
var
  S: AnsiString;
begin
  S := CryptString(DocSec,St,ID,False);
  AStream.Write ( s[1], Length ( S ) );
end;

function CryptString( DocSec: TPDFSecurity; St:AnsiString;ID: Integer;Wrap:Boolean = true ):AnsiString;
var
  I, L, K:Integer;
  AES: TAESCipher;
  ib: array [0..15] of Byte;
  P, T: Pointer;
  W: ^Word;
  FullKey: array [ 1..25 ] of Byte;
  Digest: array[0..15] of byte;
  S: AnsiString;
  RC4 : TRC4Cipher;
begin
  case DocSec.State of
    ssNone:
        Result := St;
    ss40RC4:
      begin
        S := St;
        FillChar ( FullKey, 21, 0 );
        Move ( DocSec.Key, FullKey, 5 );
        Move ( ID, FullKey [ 6 ], 3 );
        DataToHash(TMD5Hash, @FullKey, 10, Digest );
        RC4 := TRC4Cipher.Create( @Digest, 10, nil );
        try
          RC4.Encode ( @S [ 1 ], Length ( S ) );
        finally
          RC4.Free;
        end;
        Result := S;
      end;
    ss128RC4:
      begin
        S := St;
        FillChar ( FullKey, 21, 0 );
        Move ( DocSec.Key, FullKey, 16 );
        Move ( ID, FullKey [ 17 ], 3 );
        DataToHash(TMD5Hash, @FullKey, 21, Digest );
        RC4 := TRC4Cipher.Create( @Digest, 16, nil );
        try
          RC4.Encode ( @S [ 1 ], Length ( S ) );
        finally
          RC4.Free;
        end;
        Result := S;
      end;
  else
    begin
      I := Length(st);
      s := st;
      K :=  I and $f;
      if K > 0 then
        K := 16 - K
      else
        K := 16;
      L := I + 16 + K;
      SetLength(s, L);
      P := @st[1];
      FillChar(S[I + 17],K , K);
      Move(P^,s[17], Length(ST));
      if DocSec.State = ss128AES then
      begin
        Move ( DocSec.Key, FullKey, 16 );
        FullKey[17] := Byte( ID );
        FullKey[18] := Byte( ID shr 8 );
        FullKey[19] := Byte( ID shr 16);
        FullKey[20] := 0;
        FullKey[21] := 0;
        FullKey[22] := $73;
        FullKey[23] := $41;
        FullKey[24] := $6C;
        FullKey[25] := $54;
        DataToHash(TMD5Hash, @FullKey, 25, Digest );
      end;
      W := @IB[0];
      for I := 1 to 8 do
      begin
        W^ := Random($FFFF);
        Inc(W);
      end;
      T := @s[1];
      P := @IB[0];
      Move(P^,s[1],16);
      if DocSec.State = ss128AES then
        AES := TAESCipher.Create(@Digest, 128, T)
      else
        AES := TAESCipher.Create(@DocSec.Key, 256, T);
      try
        AES.Encode( @S[17], L - 16 );
      finally
        AES.Free;
      end;
      Move(P^,s[1],16);
      Result := S;
    end;
  end;
  if Wrap then
    Result := '(' + EscapeSpecialChar( Result ) +')';
end;

procedure CryptStreamToStream(DocSec: TPDFSecurity; FromStream:TMemoryStream; ToStream : TStream; ID: Integer);
var
  I, L, K:Integer;
  ib: array [0..15] of Byte;
  AES: TAESCipher;
  T: Pointer;
  W: ^Word;
  P: ^Byte;
  S:AnsiString;
  FullKey: array [ 1..25 ] of Byte;
  Digest: array [0..15] of Byte;
  RC4: TRC4Cipher;
begin
  case DocSec.State of
    ssNone:
      begin
        FromStream.Position := 0;
        ToStream.CopyFrom(FromStream, FromStream.Size);
      end;
    ss40RC4:
      begin
        FillChar ( FullKey, 21, 0 );
        Move ( DocSec.Key, FullKey, 5 );
        Move ( ID, FullKey [ 6 ], 3 );
        DataToHash(TMD5Hash, @FullKey, 10, Digest );
        RC4 := TRC4Cipher.Create( @Digest, 10, nil );
        try
          RC4.Encode ( FromStream.Memory, FromStream.Size );
        finally
          RC4.Free;
        end;
        FromStream.Position := 0;
        ToStream.CopyFrom(FromStream, FromStream.Size);
      end;
    ss128RC4:
      begin
        FillChar ( FullKey, 21, 0 );
        Move ( DocSec.Key, FullKey, 16 );
        Move ( ID, FullKey [ 17 ], 3 );
        DataToHash(TMD5Hash, @FullKey, 21, Digest );
        RC4 := TRC4Cipher.Create( @Digest, 16, nil );
        try
          RC4.Encode ( FromStream.Memory, FromStream.Size );
        finally
          RC4.Free;
        end;
        FromStream.Position := 0;
        ToStream.CopyFrom(FromStream, FromStream.Size);
      end;
  else
    begin
      I := FromStream.Size;
      K :=  I and $f;
      if K > 0 then
        K := 16 - K
      else
        K := 16;
      L := I + 16 + K;
      SetLength(S,L);
      FillChar(S[I + 17],K , K);
      Move(FromStream.Memory^,s[17], i);
      if DocSec.State = ss128AES then
      begin
        Move ( DocSec.Key, FullKey, 16 );
        FullKey[17] := Byte( ID );
        FullKey[18] := Byte( ID shr 8 );
        FullKey[19] := Byte( ID shr 16);
        FullKey[20] := 0;
        FullKey[21] := 0;
        FullKey[22] := $73;
        FullKey[23] := $41;
        FullKey[24] := $6C;
        FullKey[25] := $54;
        DataToHash(TMD5Hash, @FullKey, 25, Digest );
      end;
      W := @IB[0];
      for I := 1 to 8 do
      begin
        W^ := Random($FFFF);
        Inc(W);
      end;
      T := @s[1];
      P := @IB[0];
      Move(P^,s[1],16);
      if DocSec.State = ss128AES then
        AES := TAESCipher.Create(@Digest, 128, T)
      else
        AES := TAESCipher.Create(@DocSec.Key, 256, T);
      try
        AES.Encode( @S[17], L - 16 );
      finally
        AES.Free;
      end;
      Move(P^,s[1],16);
      ToStream.Write(s[1],L);
    end;
  end;
end;

end.

