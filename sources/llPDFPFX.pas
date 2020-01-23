{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFPFX;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows,SysUtils,Classes,Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math, 
{$endif}
  llPDFTypes, llPDFASN1, llPDFCertKey, llPDFMisc;
type

  TMacData = record
    Salt:AnsiString;
    Algorithm: TOIDs;
    Digest:AnsiString;
    Iterations: Integer;
  end;

  TPKCS12Document = class
  private
    FASN1Doc : TASN1Document;
    FContentInfo: AnsiString;
    FMacData: TMacData;
    FPasswordChecked:Boolean;
    FValidPassword:UTF8String;
    FPrivateKeys:TObjList;
    FCertificates: TObjList;
    FChain: TX509Certificate;
    FChainLen: Integer;
    procedure Clear;
    procedure LoadMacData(MacData: TASN1Container);
    procedure ProcessSafeBag(Bag: TASN1Container);
  public
    constructor Create;
    destructor Destroy;override;
    procedure LoadFromFile(AFileName:string);
    procedure LoadFromStream(AStream: TStream);
    function CheckPassword(Password:UTF8String):Boolean;
    property Chain:TX509Certificate read FChain;
    property ChainLen:Integer read FChainLen ;
    procedure Parse;
    class function DerivingKey(Password:UTF8String;Salt:AnsiString;ID: Byte; Algorithm:TOIDs; Iteration: Integer;Len: Cardinal):AnsiString;
  end;

function ExtractPKCS7Info(ASNObject: TASN1Container;Password:UTF8String):AnsiString;
function PKCS7ProcessEncryptedData(Info:TASN1Container;Password: UTF8String):AnsiString;

implementation

uses  llPDFCrypt, llPDFResources;

procedure HMAC(const Key; KeyLen: Integer; const Message; MessageLen: Integer; HashAlgorithm: TOIDs; var Mac; MacLen: Cardinal);
var
  HC: THashClass;
  H: THash;
  PAD,WrkPAD:array [0..63] of byte;
  Hash: array[0..19] of byte;
  I: Integer;
begin
  HC := OIDtoHashClass(HashAlgorithm);
  if HC = nil then
    raise EPDFSignatureException.Create(SAlgorithmNotSupported);
  H := HC.Create;
  try
    FillChar(Pad,SizeOf(PAD),0);
    if KeyLen <= 64 then
      move(Key,PAD,KeyLen)
    else
    begin
      H.Init;
      H.Update(Key,KeyLen);
      H.Finish(@PAD);
    end;
    for i:= 0 to 63 do
      WrkPAD[i] := PAD[i] xor $36;
    H.Init;
    H.Update(wrkPad,64);
    H.Update(Message,MessageLen);
    H.Finish(@Hash);
    for i:= 0 to 63 do
      WrkPAD[i] := PAD[i] xor $5c;
    H.Init;
    H.Update(wrkPad,64);
    H.Update(Hash,HC.HashSize);
    H.Final;
    if MacLen < H.HashSize then
    begin
      Move(H.Digest^,Mac,MacLen)
    end else
    begin
      FillChar(Mac,MacLen,0);
      Move(H.Digest^,Mac,H.HashSize);
    end;
  finally
    H.Free;
  end;
end;



{ TPKCS12Document }

function TPKCS12Document.CheckPassword(Password: UTF8String): Boolean;
var
  Wrk: AnsiString;
  Mac:AnsiString;
  HS: Cardinal;
begin
  HS := OIDtoHashClass(FMacData.Algorithm).HashSize;
  Wrk := DerivingKey(Password,FMacData.Salt,3,FMacData.Algorithm,FMacData.Iterations,HS);
  SetLength(Mac,HS);
  HMAC(WRK[1],Length(wrk),FContentInfo[1],length(FContentInfo),FMacData.Algorithm,Mac[1],HS);
  result := CompareMem(@FMacData.Digest[1],PAnsiChar(Mac),HS);
  if Result then
  begin
    FValidPassword := Password;
    FPasswordChecked := true;
  end;
end;

procedure TPKCS12Document.Clear;
begin
  FValidPassword := '';
  FPasswordChecked := False;
  FMacData.Salt := '';
  FMacData.Algorithm := OID_Undef;
  FMacData.Digest := '';
  FContentInfo := '';
  FCertificates.Clear;
  FPrivateKeys.Clear;
end;

constructor TPKCS12Document.Create;
begin
  FASN1Doc := TASN1Document.Create;
  FCertificates := TObjList.Create;
  FPrivateKeys := TObjList.Create;
end;

class function TPKCS12Document.DerivingKey(Password: UTF8String; Salt: AnsiString; ID: Byte;
  Algorithm:TOIDs;Iteration: Integer; Len: Cardinal): AnsiString;
var
  NormalizedPassword: AnsiString;
  Pass:WideString;
  J, SLen, PLen: Integer;
  WL,wrk, I: Cardinal;
  WCh: Word;
  U,V:Integer;
  D, S, P, WW, A, B:AnsiString;
  H: THash;
  HC: THashClass;
  Dig: Pointer;
  WrkChar:PAnsiChar;
begin
  Result := '';
  HC := OIDtoHashClass(Algorithm);
  Pass := UTF8ToWideString(Password);
  WL := Length(Pass) shl 1 + 2;
  SetLength(NormalizedPassword, WL);
  for i := 1 to Length(Pass) do
  begin
    WCh := Word(Pass[i]);
    NormalizedPassword[i shl 1 - 1] := AnsiChar(byte(Wch shr 8));
    NormalizedPassword[i shl 1 ] := AnsiChar(Byte(WCh and $FF));
  end;
  NormalizedPassword[WL -1] := #0;
  NormalizedPassword[WL] := #0;
  V := 64;
  if Algorithm = OID_SHA1 then
  begin
    U := 20;
  end else
  if Algorithm = OID_MD5 then
  begin
    U := 16;
  end else Exit;

  SetLength(D,V);
  FillChar(D[1],V,ID);
  wrk := Length(Salt);
  if wrk and $3f = 0 then
  begin
    SLen := wrk;
    S := Salt;
  end else
  begin
    SLen := ((wrk shr 6) +1) shl 6;
    SetLength(S,SLen);
    WrkChar := PAnsiChar(S);
    for i:= 0 to SLen - 1 do
    begin
      WrkChar^ :=Salt[(i mod wrk) +1];
      Inc(WrkChar);
    end;
  end;
  if WL and $3f = 0 then
  begin
    PLen := WL;
    P := NormalizedPassword;
  end else
  begin
    PLen := ((WL shr 6) +1) shl 6;
    SetLength(P,PLen);
    WrkChar := PAnsiChar(P);
    for i:= 0 to PLen - 1 do
    begin
      WrkChar^ :=NormalizedPassword[(i mod WL) +1];
      Inc(WrkChar);
    end;
  end;
  SetLength(A,U);
  SetLength(B,V);
  SetLength(Result,Len);
  H := HC.Create;
  try
    I := 0;
    while true do
    begin
      WW := D+S+P;
      H.Init;
      H.HashIteration(WW[1],Length(WW),Iteration);
      Dig := H.Digest;
      move(Dig^,A[1],U);
      StrAddTruncAt(A,Result,I);
      Inc(I,H.HashSize);
      if I >= Len then
        Break;
      J := 0;
      while J < V do
      begin
        StrAddTruncAt(A,B,J);
        Inc(J,U);
      end;
      J := 0;
      while J < SLen do
      begin
        StrAddTruncAt(B,S,J,1);
        Inc(J,V);
      end;
      J := 0;
      while J < PLen do
      begin
        StrAddTruncAt(B,P,J,1);
        Inc(J,V);
      end;
    end;
  finally
    H.Free;
  end;
end;

destructor TPKCS12Document.Destroy;
begin
  FASN1Doc.Free;
  FPrivateKeys.Free;
  FCertificates.Free;
  inherited;
end;

procedure TPKCS12Document.LoadFromFile(AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName,fmOpenRead);
  try
    LoadFromStream(FS);
  finally
    FS.Free;
  end;
end;

procedure TPKCS12Document.LoadFromStream(AStream: TStream);
var
  Sequence : TASN1Container;
  Obj: TASN1BaseObject;
begin
  Clear;
  FASN1Doc.LoadFromStream(AStream);
  if FASN1Doc.Count = 0 then
    raise EPDFSignatureException.Create(SASN1SequenceNotFound);
  if FASN1Doc.Items[0].Tag <> ASN1_TAG_SEQUENCE then
    raise EPDFSignatureException.Create(SASN1SequenceNotFound);
  Sequence := FASN1Doc.Items[0] as TASN1Container;
  if Sequence.Count < 2 then
    raise EPDFSignatureException.Create(SUnknownStructure);
  Obj :=Sequence[0];
  if (Obj.Tag <> ASN1_TAG_INTEGER) or (TASN1Integer(Obj).Value <> 3) then
    raise EPDFSignatureException.Create(SInvalidVersionOfDocument);
  Obj :=Sequence[1];
  if Obj.Tag <> ASN1_TAG_SEQUENCE then
    raise EPDFSignatureException.Create(SPKCS7InformationNotFound);
  FContentInfo :=  ExtractPKCS7Info(Obj as TASN1Container,'');
  if Sequence.Count > 2 then
  Obj :=Sequence[2];
  if Obj.Tag <> ASN1_TAG_SEQUENCE then
    raise EPDFSignatureException.Create(SMacDataInformationNotFound);
  LoadMacData(Obj as TASN1Container);
end;

procedure TPKCS12Document.LoadMacData(MacData: TASN1Container);
var
  Obj, Salt, Iterations: TASN1BaseObject;
  Digest, AlgorithmIdentifier: TASN1Container;
begin
  // MacData
  FMacData.Salt := '';
  FMacData.Algorithm := OID_Undef;
  FMacData.Digest := '';
  if MacData.Count < 3 then
    raise EPDFSignatureException.Create(SUnknownMacDataStructure);
  // Digest Info
  Obj := MacData[0];
  if (Obj.Tag <> ASN1_TAG_SEQUENCE)then
    raise EPDFSignatureException.Create(SUnknownMacDataStructure);
  Digest := TASN1Container(Obj);
  if Digest.Count <> 2 then
    raise EPDFSignatureException.Create(SUnknownDigestStructure);
  Obj := Digest[1];
  if (Obj.Tag <> ASN1_TAG_OCTET_STRING)then
    raise EPDFSignatureException.Create(SUnknownDigestStructure);
  FMacData.Digest := TASN1Data(Obj).Data;

  if Digest[0].Tag <> ASN1_TAG_SEQUENCE then
    raise EPDFSignatureException.Create(SUnknownDigestStructure);
  // Algorithm indentifier
  AlgorithmIdentifier := TASN1Container(Digest[0]);
  if AlgorithmIdentifier.Count <1 then
    raise EPDFSignatureException.Create(SUnknownDigestStructure);
  if AlgorithmIdentifier[0].Tag <> ASN1_TAG_Object_ID then
    raise EPDFSignatureException.Create(SUnknownDigestStructure);
  FMacData.Algorithm := TASN1ObjectID(AlgorithmIdentifier[0]).ID;
  if FMacData.Algorithm <> OID_sha1 then
    raise EPDFSignatureException.Create(SUnsupportedDigestAlgorithm);
  Salt := MacData[1];
  if (Salt.Tag <> ASN1_TAG_OCTET_STRING)then
    raise EPDFSignatureException.Create(SUnknownMacDataStructure);
  FMacData.Salt := TASN1Data(Salt).Data;
  Iterations := MacData[2];
  if (Iterations.Tag <> ASN1_TAG_INTEGER) or (TASN1Integer(Iterations).IsLargest) then
    raise EPDFSignatureException.Create(SUnknownMacDataStructure);
  FMacData.Iterations := TASN1Integer(Iterations).Value;
end;

procedure TPKCS12Document.Parse;
var
  I, J, K: Integer;
  ASafe, Item: TASN1BaseObject;
  ASafeList:TObjList;
  BAG:AnsiString;
  Seq: TASN1Container;
  TmpCert: TX509Certificate;
begin
  if not FPasswordChecked then
    raise EPDFSignatureException.Create(SEncryptedDocument);
  try
    ASafe := TASN1Document.ReadASN1Object(@FContentInfo[1],Length(FContentInfo));
  except
    on EPDFSignatureException do
      raise EPDFSignatureException.Create(SAuthenticatedSafeCannotLoaded);
  end;
  FChain := nil;
  FChainLen := 0;
  try
    if ASafe.Tag <> ASN1_TAG_SEQUENCE then
      raise EPDFSignatureException.Create(SAuthenticatedSafeCannotLoaded);
    ASafeList := TObjList.Create;
    try
      for i := 0 to TASN1Container(ASafe).Count - 1 do
      begin
        Item := TASN1Container(ASafe)[i];                                     
        if Item.Tag = ASN1_TAG_SEQUENCE then
        begin
          BAG := ExtractPKCS7Info(Item as TASN1Container,FValidPassword);
          Item := TASN1Document.ReadASN1Object(@BAG[1],Length(BAG));
          try
            if Item.Tag = ASN1_TAG_SEQUENCE then
            begin
              Seq := Item as TASN1Container;
              for K := 0 to Seq.Count - 1 do
                if Seq[K].Tag = ASN1_TAG_SEQUENCE then
                begin
                  ProcessSafeBag(Seq[K] as TASN1Container);
                end;
            end;
          finally
            Item.Free;
          end;
        end;
      end;
      if FPrivateKeys.Count = 0 then
        raise EPDFSignatureException.Create(SPrivateKeyNotFoundInPfxDocument);
      if FCertificates.Count = 0 then
        raise EPDFSignatureException.Create(SCertificatesNotFoundInPfxDocumen);
      for i := 0 to FPrivateKeys.Count - 1 do
      begin
        for j := 0 to FCertificates.Count - 1 do
          if TX509Certificate(FCertificates[j]).CheckPrivateKey(TPrivateKey(FPrivateKeys[i])) then
          begin
            FChain := TX509Certificate(FCertificates[j]);
            break;
          end;
        if FChain <> nil then
          break;
      end;
      if FChain = nil then
        raise EPDFSignatureException.Create(SNotFoundPairCertificateAndPrivat);
      for i := 0 to FCertificates.Count - 1 do
        for j := 0 to FCertificates.Count - 1 do
        begin
          if i = j then Continue;
            if TX509Certificate(FCertificates[i]).CheckOwner(TX509Certificate(FCertificates[j]))then break;
        end;
      TmpCert := FChain;
      while TmpCert <> nil do
      begin
        TmpCert := TmpCert.Owner;
        Inc(FChainLen);
      end;
    finally
      ASafeList.Free;
    end;
  finally
    ASafe.Free;
  end;
end;

function PKCS7ProcessData(Info:TASN1Container):AnsiString;
begin
  if Info[0].Tag <> ASN1_TAG_OCTET_STRING then
    raise EPDFSignatureException.Create(SUnknownStructure);
  Result := TASN1Data(Info[0]).Data;
end;

function PKCS7ProcessEncryptedData(Info:TASN1Container;Password: UTF8String):AnsiString;
var
  Obj: TASN1BaseObject;
  Seq, Params: TASN1Container;
  ID: TOIDs;
  CryptedData: AnsiString;
  IVLen, KeyLen: Integer;
  ChClass: TCipherClass;
  IV, Key: AnsiString;
  Iterations: Cardinal;
  Salt:AnsiString;
  Chipher: TCipher;
begin
  if Info[0].Tag <> ASN1_TAG_SEQUENCE then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  Info := Info[0] as TASN1Container;
  if Info.Count < 2 then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  Obj := Info[0];
  if not (Obj is TASN1Integer) then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  if TASN1Integer(Obj).Value <> 0 then
    raise EPDFSignatureException.Create(SInvalidEncryptionAlgorithmVersio);

  Info := Info[1] as TASN1Container;

  if Info.Count <3 then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);

  if not (Info[2] is TASN1Data) then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  CryptedData := TASN1Data(Info[2]).Data;

  Obj := Info[1];
  if Obj.Tag <>  ASN1_TAG_SEQUENCE then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);

  Seq := Obj as TASN1Container;
  if Seq.Count < 1 then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  Obj := Seq[0];
  if Obj.Tag <> ASN1_TAG_OBJECT_ID then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  ID := TASN1ObjectID(Obj).ID;
  if Seq.Count < 2 then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  if Seq[1].Tag <> ASN1_TAG_SEQUENCE then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  Params := Seq[1] as TASN1Container;
  if Params.Count = 0 then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  if Params[0].Tag <> ASN1_TAG_OCTET_STRING then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  Salt := TASN1Data(Params[0]).Data;
  if Params.Count = 1 then
    Iterations := 1 else
  begin
    if Params[1].Tag <> ASN1_TAG_INTEGER then
      Iterations := 1
    else
      Iterations := TASN1Integer(Params[1]).Value;
  end;
  case ID of
    OID_pbe_WithSHA1And128BitRC4:
      begin
        IVLen := 0;
        KeyLen := 16;
        ChClass := TRC4Cipher;
      end;
    OID_pbe_WithSHA1And40BitRC4:
      begin
        IVLen := 0;
        KeyLen := 5;
        ChClass := TRC4Cipher
      end;
    OID_pbe_WithSHA1And3_Key_TripleDES_CBC:
      begin
        IVLen := 8;
        KeyLen := 24;
        ChClass := TDESCipher;
      end;
    OID_pbe_WithSHA1And2_Key_TripleDES_CBC:
      begin
        IVLen := 8;
        KeyLen := 16;
        ChClass := TDESCipher;
      end;
    OID_pbe_WithSHA1And128BitRC2_CBC:
      begin
        IVLen := 8;
        KeyLen := 16;
        ChClass := TRC2Cipher;
      end;
    OID_pbe_WithSHA1And40BitRC2_CBC:
      begin
        IVLen := 8;
        KeyLen := 5;
        ChClass := TRC2Cipher;
      end;
    else
      raise EPDFSignatureException.Create(SInvalidEncryptionAlgorithm);
  end;
  if IVLen <> 0 then
    IV := TPKCS12Document.DerivingKey(Password,Salt,2,OID_sha1,Iterations,IVLen)
  else
    IV := '';
  Key := TPKCS12Document.DerivingKey(Password,Salt,1,OID_sha1,Iterations,KeyLen);
  Chipher:= ChClass.Create(PAnsiChar(Key),KeyLen,PAnsiChar(IV));
  try
    Result := Chipher.DecodeToStr(@CryptedData[1],Length(CryptedData));
  finally
    Chipher.Free;
  end;
end;


function ExtractPKCS7Info(ASNObject: TASN1Container;Password:UTF8String):AnsiString;
var
  Obj, PKCS7ID: TASN1BaseObject;
  Container: TASN1Container;
begin
  if ASNObject.Count < 1 then
    raise EPDFSignatureException.Create(SUnknownStructure);
  PKCS7ID := ASNObject[0];
  if PKCS7ID.Tag <> ASN1_TAG_OBJECT_ID then
    raise EPDFSignatureException.Create(SUnknownStructure);
  if ASNObject.Count >= 2 then
  begin
    Obj := ASNObject[1];
    if (Obj.Tag = 0) and (Obj.ASN1Class = ASN1_CLASS_CONTEXT) and
      (obj is TASN1Container) and (TASN1Container(obj).Count <> 0 ) then
      Container := Obj as TASN1Container
    else
      raise EPDFSignatureException.Create(SUnknownStructure);
  end else
    Container := nil;

  if (TASN1ObjectID(PKCS7ID).ID <> OID_pkcs7_data)
    and (Password = '') then
    raise EPDFSignatureException.Create(SUnsupportedDocument);
  case TASN1ObjectID(PKCS7ID).ID of
    OID_pkcs7_data: Result := PKCS7ProcessData(Container);
//    OID_pkcs7_signed: Result := PKCS7ProcessSignedData(Container);
//    OID_pkcs7_enveloped: Result := PKCS7ProcessEnvelopedData(Container);
//    OID_pkcs7_signedAndEnveloped:Result := PKCS7ProcessSignedAndEnvelopedData(Container);
//    OID_pkcs7_digest: Result := PKCS7ProcessDigestedData(Container);
    OID_pkcs7_encrypted: Result := PKCS7ProcessEncryptedData(Container, Password);
    else
      raise EPDFSignatureException.Create(SUnsupportedDocument);
  end;
end;


procedure TPKCS12Document.ProcessSafeBag(Bag: TASN1Container);
var
  i:Integer;
  ID: TOIDs;
  PK: TPrivateKey;
  Cert: TX509Certificate;
  Attributes: TASN1Container;
  FriendlyName,LocalID: AnsiString;
  Obj: TASN1BaseObject;
  Data: AnsiString;
  function CheckAttributes(Item: TASN1Container):Boolean;
  var
    ID: TOIDs;
    Attributes: TASN1Container;
    I: Integer;
    Attr:TASN1Container;
  begin
    Result := False;
    if not (Item[2] is TASN1Container) then
      Exit;
    Attributes := Item[2] as TASN1Container;
    FriendlyName := '';
    LocalID := '';
    for i := 0 to Attributes.Count  - 1 do
    begin
      if not ( Attributes[i] is TASN1Container) then
        Continue;
      Attr :=  Attributes[i] as TASN1Container;
      if Attr.Count < 2 then
        Continue;
      if not (Attr[0] is TASN1ObjectID) then
        Continue;
      ID := TASN1ObjectID(Attr[0]).ID;
      if not  (ID in [ OID_friendlyName, OID_localKeyID] ) then
        Continue;
      if not (Attr[1] is TASN1Container) then
        Continue;
      if TASN1Container(Attr[1]).Count <1 then
        Continue;
      if not (TASN1Container(Attr[1])[0] is TASN1Data) then
        Continue;
      if ID = OID_friendlyName then
        FriendlyName := (TASN1Container(Attr[1])[0] as TASN1Data).Data
      else
        LocalID := (TASN1Container(Attr[1])[0] as TASN1Data).Data;
    end;
    Result := True;
  end;
begin
  if Bag.Count < 3 then
    Exit;
  if Bag[0].Tag <> ASN1_TAG_OBJECT_ID then
    Exit;
  ID := TASN1ObjectID(Bag[0]).ID;
  if not (Bag[1] is TASN1Container) then
    Exit;
  Attributes := nil;
  if Bag.Count >2 then
    if Bag[2] is TASN1Container then
      Attributes := Bag[2] as TASN1Container;
  case ID of
    OID_keyBag:
      begin
        PK := TPrivateKey.Create;
        try
          PK.Read(Bag[1] as TASN1Container, Attributes);
        except
          on EPDFSignatureException do
          begin
            PK.Free;
            PK := nil;
          end;
        end;
        if PK <> nil then
        begin
          FPrivateKeys.Add(PK);
        end;
      end;
    OID_pkcs8ShroudedKeyBag:
      begin
        PK := TPrivateKey.Create;
        try
          PK.ReadCrypted(Bag[1] as TASN1Container, Attributes,FValidPassword);
        except
          on EPDFSignatureException do
          begin
            PK.Free;
            PK := nil;
          end;
        end;
        if PK <> nil then
        begin
          FPrivateKeys.Add(PK);
        end;
      end;
    OID_certBag:
      begin
        if TASN1Container(Bag[1]).Count < 1 then
          Exit;
        Obj := TASN1Container(Bag[1])[0];
        if not (Obj is TASN1Container) then
          Exit;
        if TASN1Container(Obj).Count <2 then
          Exit;
        if not ( TASN1Container(Obj)[0] is TASN1ObjectID) then
          Exit;
        if TASN1ObjectID(TASN1Container(Obj)[0]).ID <> OID_x509Certificate then
          Exit;
        if not ( TASN1Container(Obj)[1] is TASN1Container) then
          Exit;
        if TASN1Container(TASN1Container(Obj)[1]).Count <1 then
          Exit;
        Obj :=TASN1Container(TASN1Container(Obj)[1])[0];
        if Obj.Tag <> ASN1_TAG_OCTET_STRING then
          Exit;
        Data := TASN1Data(Obj).Data;
        if Data = '' then
          Exit;
        try
          Obj := TASN1Document.ReadASN1Object(@Data[1],Length(Data));
        except
          on Exception do
            Obj := nil;
        end;
        if Obj = nil then
          Exit;
        try
          if not (Obj is TASN1Container) then
            Exit;
          if (Obj as TASN1Container).Count < 1 then
            Exit;
          if not ((Obj as TASN1Container)[0] is TASN1Container) then
            Exit;

          Cert := TX509Certificate.Create;
          try
            Cert.Load(Obj as TASN1Container);
          except
            on Exception do
            begin
              Cert.Free;
              Cert := nil;
            end;
          end;
          if Cert <> nil then
            FCertificates.Add(Cert);
        finally
          Obj.Free;
        end;
      end;
    OID_crlBag:
      begin
      end;
    OID_secretBag:
      begin
      end;
    OID_safeContentsBag:
       for i := 0 to TASN1Container(Bag[1]).Count - 1 do
        if TASN1Container(Bag[1])[i] is TASN1Container then
          ProcessSafeBag(TASN1Container(Bag[1])[i] as TASN1Container);
  end;
end;
end.
