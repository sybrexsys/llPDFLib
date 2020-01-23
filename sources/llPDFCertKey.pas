{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFCertKey;
{$i pdf.inc}
interface
uses 
{$ifndef USENAMESPACE}
  Windows,SysUtils,Classes,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif}
  llPDFTypes, llPDFMisc, llPDFASN1;


type

  TPrivateKey = class
  private
    FKey :TASN1Container;
    FVersion: Integer;
    FAlgorithm: TOIDs;
    function GetExponent1: TASN1Integer;
    function GetExponent2: TASN1Integer;
    function GetModulus: TASN1Integer;
    function GetPrime1: TASN1Integer;
    function GetPrime2: TASN1Integer;
    function GetPrivateExponent: TASN1Integer;
    function GetPublicExponent: TASN1Integer;
    function GetCoeficient: TASN1Integer;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Read(ASN:TASN1Container;Attributes:TASN1Container);
    procedure ReadCrypted(ASNCrypted, Attributes:TASN1Container;Password: AnsiString);
    property Version:Integer read FVersion;
    property Algorithm:TOIDs read FAlgorithm;
    property Modulus : TASN1Integer read GetModulus;
    property PublicExponent: TASN1Integer read GetPublicExponent;
    property PrivateExponent: TASN1Integer read GetPrivateExponent;
    property Prime1: TASN1Integer read GetPrime1;
    property Prime2: TASN1Integer read GetPrime2;
    property Exponent1: TASN1Integer read GetExponent1;
    property Exponent2: TASN1Integer read GetExponent2;
    property Coeficient: TASN1Integer read GetCoeficient;
  end;


  TX509Name = class
  private
    FKeys: array of TOIDs;
    FValues: TObjList;
    function GetCount: Integer;
    function GetKey(Index: Integer): TOIDs;
    function GetValue(Index: Integer): TASN1BaseObject;
    function GetValueByKey(Key: TOIDs): TASN1BaseObject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(Key:TOIDs; Value: TASN1BaseObject): Integer;
    property Count: Integer read GetCount;
    property KeyByIndex[Index: Integer]: TOIDs read GetKey;
    property ValueByIndex[Index:Integer]: TASN1BaseObject read GetValue;
    property ValueByKey[Key: TOIDs]: TASN1BaseObject read GetValueByKey;
  end;

  TX509Certificate = class
  private
    FPrivateKey: TPrivateKey;
    FIssuer: TX509Name;
    FSubject: TX509Name;
    FPublicKey: TASN1Container;
    FObject: TASN1Container;
    FValidTo: TDateTime;
    FValidFrom: TDateTime;
    FOwner: TX509Certificate;
    procedure LoadValidity(Node: TASN1BaseObject);
    procedure LoadSubjectPublicKey(Node: TASN1BaseObject);
    procedure LoadName(Node: TASN1BaseObject; Name:TX509Name);
  public
    constructor Create;
    destructor Destroy;override;
    procedure  Load(Container: TASN1Container);
    function CheckPrivateKey(PrivateKey: TPrivateKey):Boolean;
    function CheckOwner(Owner: TX509Certificate): Boolean;
    property PrivateKey: TPrivateKey read FPrivateKey;
    property Owner: TX509Certificate read FOwner;
    property ValidFrom: TDateTime read FValidFrom;
    property ValidTo: TDateTime read FValidTo;
    property ASN1Object: TASN1Container read FObject;
    property Issuer: TX509Name read FIssuer;
  end;

implementation

uses llPDFCrypt,llPDFPFX, llPDFResources;

function ProcessEncryptedData(Info:TASN1Container;Password: UTF8String):AnsiString;
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

  if not (Info[1] is TASN1Data) then
    raise EPDFSignatureException.Create(SInvalidEncryptedData);
  CryptedData := TASN1Data(Info[1]).Data;

  Obj := Info[0];
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


{ TPrivateKey }

constructor TPrivateKey.Create;
begin
  FKey := nil;
end;

destructor TPrivateKey.Destroy;
begin
  FKey.Free;
  FKey := nil;
  inherited;
end;



function TPrivateKey.GetCoeficient: TASN1Integer;
begin
  Result := FKey[8] as TASN1Integer;
end;

function TPrivateKey.GetExponent1: TASN1Integer;
begin
  Result := FKey[6] as TASN1Integer;
end;

function TPrivateKey.GetExponent2: TASN1Integer;
begin
  Result := FKey[7] as TASN1Integer;
end;

function TPrivateKey.GetModulus: TASN1Integer;
begin
  Result := FKey[1] as TASN1Integer;
end;

function TPrivateKey.GetPrime1: TASN1Integer;
begin
  Result := FKey[4] as TASN1Integer;
end;

function TPrivateKey.GetPrime2: TASN1Integer;
begin
  Result := FKey[5] as TASN1Integer;
end;

function TPrivateKey.GetPrivateExponent: TASN1Integer;
begin
  Result := FKey[3] as TASN1Integer;
end;

function TPrivateKey.GetPublicExponent: TASN1Integer;
begin
  Result := FKey[2] as TASN1Integer;
end;

procedure TPrivateKey.Read(ASN, Attributes: TASN1Container);
var
  Key: AnsiString;
  ObjKey: TASN1BaseObject;
  I: Integer;
begin
  if ASN.Count < 3 then
    raise EPDFSignatureException.Create(SInvalidPrivateKey);
  if Not (ASN[0].Tag = ASN1_TAG_INTEGER) then
    raise EPDFSignatureException.Create(SInvalidPrivateKey);
  FVersion := TASN1Integer(ASN[0]).Value;
  if not (ASN[1].Tag = ASN1_TAG_SEQUENCE) then
    raise EPDFSignatureException.Create(SInvalidPrivateKey);
  if TASN1Container(ASN[1]).Count < 1 then
    raise EPDFSignatureException.Create(SInvalidPrivateKey);
  if not (TASN1Container(ASN[1])[0].Tag = ASN1_TAG_OBJECT_ID) then
    raise EPDFSignatureException.Create(SInvalidPrivateKey);
  FAlgorithm := TASN1ObjectID(TASN1Container(ASN[1])[0]).ID;
  if FAlgorithm  <> OID_rsaEncryption then
    raise EPDFSignatureException.Create(SUnsupportedAlgorithm);
  if not (ASN[2].Tag = ASN1_TAG_OCTET_STRING) then
    raise EPDFSignatureException.Create(SInvalidPrivateKey);
  Key :=  TASN1Data(ASN[2]).Data;
  if Key = '' then
    raise EPDFSignatureException.Create(SInvalidPrivateKey);
  ObjKey := TASN1Document.ReadASN1Object(@Key[1],Length(Key));
  try
    if not (ObjKey is TASN1Container) then
      raise EPDFSignatureException.Create(SInvalidPrivateKey);
    if TASN1Container(ObjKey).Count < 8 then
      raise EPDFSignatureException.Create(SInvalidPrivateKey);;
    for I := 0 to 7 do
     if not (TASN1Container(ObjKey)[i] is TASN1Integer) then
       raise EPDFSignatureException.Create(SInvalidPrivateKey);
   except
     on Exception do
     begin
       ObjKey.Free;
       raise;
     end;
   end;
  FKey := TASN1Container(ObjKey);
end;

procedure TPrivateKey.ReadCrypted(ASNCrypted, Attributes: TASN1Container;Password: AnsiString);
var
  Obj: TASN1BaseObject;
  Data: AnsiString;
begin
  Data := ProcessEncryptedData(ASNCrypted,Password);
  Obj :=  TASN1Document.ReadASN1Object(@Data[1], Length(Data));
  if not (Obj is TASN1Container) then
    raise EPDFSignatureException.Create(SInvalidPrivateKey);
  Read(Obj as TASN1Container,Attributes);
end;



{ TX509Certificate }

function TX509Certificate.CheckOwner(Owner: TX509Certificate): Boolean;
var
  i: Integer;
begin
  Result := False;
  if FIssuer.Count <> Owner.FSubject.Count then
    Exit;
  for i := 0 to FIssuer.Count - 1 do
  begin
    if FIssuer.FKeys[i] <> Owner.FSubject.FKeys[i] then
      Exit;
    if not TASN1BaseObject(FIssuer.FValues[i]).IsEqual(TASN1BaseObject(Owner.FSubject.FValues[i])) then Exit;
  end;
  Result := True;
  FOwner := Owner;
end;

function TX509Certificate.CheckPrivateKey(PrivateKey: TPrivateKey): Boolean;
var
  Obj: TASN1BaseObject;
  Data1,Data2: AnsiString;
begin
  Result := False;
  if FPublicKey = nil then
    Exit;
  obj := FPublicKey[0];
  if not (Obj is TASN1Data) then
    Exit;
  Data1 := PrivateKey.Modulus.Data;
  Data2 := TASN1Data(Obj).Data;
  if Length(Data1) <> Length(Data2) then
    Exit;
  Result :=  CompareMem(@Data1[1],@Data2[1],Length(Data1));
  if Result then
    FPrivateKey := PrivateKey;
end;

constructor TX509Certificate.Create;
begin
  FIssuer := TX509Name.Create;
  FSubject := TX509Name.Create;
  FObject := nil;
  FPublicKey := nil;
  FOwner := nil;
  FPrivateKey := nil;
end;

destructor TX509Certificate.Destroy;
begin
  FPublicKey.Free;
  FObject.Free;
  FIssuer.Free;
  FSubject.Free;
  inherited;
end;

procedure TX509Certificate.Load(Container: TASN1Container);
var
  CertificateInfo:TASN1Container;
begin
  FObject := TASN1Container(Container.Copy);
  CertificateInfo := FObject[0] as TASN1Container;
  if CertificateInfo.Count < 7 then
    raise EPDFSignatureException.Create(SInvalidCertificate);
  if not (CertificateInfo[1] is TASN1Integer) then
    raise EPDFSignatureException.Create(SInvalidSerialNumberOfCertificate);
  LoadName(CertificateInfo[3],FIssuer);
  LoadValidity(CertificateInfo[4]);
  LoadName(CertificateInfo[5],FSubject);
  LoadSubjectPublicKey(CertificateInfo[6]);
end;

procedure TX509Certificate.LoadName(Node: TASN1BaseObject; Name: TX509Name);
var
  I, J: Integer;
  RelativeDistinguishedName, AttributeTypeValue: TASN1Container;
begin
  if not (Node is TASN1Container) then
    raise EPDFSignatureException.Create(SInvalidNameOfCertificate);
  Name.Clear;
  for i:= 0 to TASN1Container(Node).Count - 1 do
  begin
    if not (TASN1Container(Node)[i] is TASN1Container) then
      Continue;
    RelativeDistinguishedName := TASN1Container(Node)[i] as TASN1Container;
    for j:= 0 to RelativeDistinguishedName.Count - 1 do
    begin
      if  not (RelativeDistinguishedName[j] is TASN1Container) then
        Continue;
      AttributeTypeValue := RelativeDistinguishedName[j] as TASN1Container;
      if AttributeTypeValue.Count < 2 then
        Continue;
      if not (AttributeTypeValue[0] is TASN1ObjectID) then
        Continue;
      Name.Add((AttributeTypeValue[0] as TASN1ObjectID).ID, AttributeTypeValue[1] );
    end;
  end;
end;


procedure TX509Certificate.LoadSubjectPublicKey(Node: TASN1BaseObject);
var
  Obj, Key: TASN1BaseObject;
  Data: AnsiString;
begin
  if not (Node is TASN1Container) then
    raise EPDFSignatureException.Create(SInvalidNameOfCertificate);
  //Check RSA encryption
  if TASN1Container(Node).Count <2 then
    raise EPDFSignatureException.Create(SInvalidNameOfCertificate);
  Obj := TASN1Container(Node)[0];
  if not (Obj is TASN1Container) then
    raise EPDFSignatureException.Create(SInvalidNameOfCertificate);
  Obj := TASN1Container(Obj)[0];
  if not (Obj is TASN1ObjectID) then
    raise EPDFSignatureException.Create(SInvalidNameOfCertificate);
  if TASN1ObjectID(Obj).ID <> OID_rsaEncryption then
    raise EPDFSignatureException.Create(SUnsupportedAlgorithm);
  Obj := TASN1Container(Node)[1];
  if not (Obj is TASN1Data) then
    raise EPDFSignatureException.Create(SInvalidNameOfCertificate);
  Data := TASN1Data(Obj).Data;
  if Length(Data) < 1 then
    raise EPDFSignatureException.Create(SInvalidNameOfCertificate);
  Key := TASN1Document.ReadASN1Object(@Data[2],Length(Data) -1);
  try
    if not (Key is TASN1Container) then
      raise EPDFSignatureException.Create(SInvalidNameOfCertificate);
    FPublicKey := TASN1Container(Key.Copy);
  finally
    Key.Free;
  end;
end;

procedure TX509Certificate.LoadValidity(Node: TASN1BaseObject);
begin
//TODO: Append support of the validity of the certificate
end;


{ TX509Name }

function TX509Name.Add(Key: TOIDs; Value: TASN1BaseObject): Integer;
var
  I: Integer;
begin
  I := Length(FKeys);
  SetLength(FKeys,I+1);
  FKeys[i] := Key;
  FValues.Add(Value);
  Result := i;
end;

procedure TX509Name.Clear;
begin
  FKeys := nil;
  FValues.Clear;
end;

constructor TX509Name.Create;
begin
  FKeys := nil;
  FValues := TObjList.Create(False);
end;

destructor TX509Name.Destroy;
begin
  FKeys := nil;
  FValues.Free;
  inherited;
end;

function TX509Name.GetCount: Integer;
begin
  Result := Length(FKeys);
end;

function TX509Name.GetKey(Index: Integer): TOIDs;
begin
  if (Index < 0) or (Index >= Length(FKeys)) then
    raise EPDFSignatureException.Create(SOutOfBounds);
  Result := FKeys[index];
end;

function TX509Name.GetValue(Index: Integer): TASN1BaseObject;
begin
  if (Index < 0) or (Index >= Length(FKeys)) then
    raise EPDFSignatureException.Create(SOutOfBounds);
  Result :=TASN1BaseObject(FValues[index]);
end;

function TX509Name.GetValueByKey(Key: TOIDs): TASN1BaseObject;
var
  I: Integer;
begin
  for i:= 0 to Length(FKeys) -1 do
    if FKeys[i] = Key then
    begin
      Result := TASN1BaseObject(FValues[i]);
      Exit;
    end;
  Result := nil;
end;
end.
