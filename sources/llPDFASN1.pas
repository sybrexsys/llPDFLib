{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFASN1;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows,SysUtils,Classes, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif}
  llPDFTypes, llPDFMisc;

type
  TOIDs = (
    OID_undef,
    OID_rsaEncryption,
    OID_md2WithRSAEncryption,
    OID_md5WithRSAEncryption,
    OID_pbeWithMD2AndDES_CBC,
    OID_pbeWithMD5AndDES_CBC,
    OID_pbeWithMD2AndRC2_CBC,
    OID_pbeWithMD5AndRC2_CBC,
    OID_pbeWithSHA1AndDES_CBC,
    OID_pbeWithSHA1AndRC2_CBC,
    OID_id_pbkdf2,
    OID_pbes2,
    OID_pbmac1,
    OID_pkcs7_data,
    OID_pkcs7_signed,
    OID_pkcs7_enveloped,
    OID_pkcs7_signedAndEnveloped,
    OID_pkcs7_digest,
    OID_pkcs7_encrypted,
    OID_pkcs9_emailAddress,
    OID_pkcs9_unstructuredName,
    OID_pkcs9_contentType,
    OID_pkcs9_messageDigest,
    OID_pkcs9_signingTime,
    OID_pkcs9_countersignature,
    OID_pkcs9_challengePassword,
    OID_pkcs9_unstructuredAddress,
    OID_pkcs9_extCertAttributes,
    OID_SigningDescription,
    OID_ext_req,
    OID_SMIMECapabilities,
    OID_friendlyName,
    OID_localKeyID,
    OID_x509Certificate,
    OID_sdsiCertificate,
    OID_pkcs12CRLTypeX509,
    OID_pbe_WithSHA1And128BitRC4,
    OID_pbe_WithSHA1And40BitRC4,
    OID_pbe_WithSHA1And3_Key_TripleDES_CBC,
    OID_pbe_WithSHA1And2_Key_TripleDES_CBC,
    OID_pbe_WithSHA1And128BitRC2_CBC,
    OID_pbe_WithSHA1And40BitRC2_CBC,
    OID_keyBag,
    OID_pkcs8ShroudedKeyBag,
    OID_certBag,
    OID_crlBag,
    OID_secretBag,
    OID_safeContentsBag,
    OID_md2,
    OID_md4,
    OID_md5,
    OID_md5WithRSA,
    OID_des_ecb,
    OID_des_cbc,
    OID_des_ofb64,
    OID_des_cfb64,
    OID_rsaSignature,
    OID_dsa_2,
    OID_dsaWithSHA,
    OID_shaWithRSAEncryption,
    OID_sha,
    OID_des_ede_ecb,
    OID_sha1,
    OID_sha224,
    OID_sha256,
    OID_sha384,
    OID_sha512,
    OID_ripedm160,
    OID_dsaWithSHA1_2,
    OID_sha1WithRSA,
    OID_commonName,
    OID_surName,
    OID_serialNumber,
    OID_countryName,
    OID_localityName,
    OID_stateOrProvinceName,
    OID_organizationName,
    OID_organizationalUnitName,
    OID_title,
    OID_description,
    OID_searchGuide,
    OID_businessCategory,
    OID_postalAddress,
    OID_postOfficeBox,
    OID_physicalDeliveryOfficeName,
    OID_telephoneNumber,
    OID_telexNumber,
    OID_teletexTerminalIdentifier,
    OID_facsimileTelephoneNumber,
    OID_x121Address,
    OID_internationaliSDNNumber,
    OID_registeredAddress,
    OID_destinationIndicator,
    OID_preferredDeliveryMethod,
    OID_presentationAddress,
    OID_supportedApplicationContext,
    OID_member,
    OID_owner,
    OID_roleOccupant,
    OID_seeAlso,
    OID_userPassword,
    OID_userCertificate,
    OID_cACertificate,
    OID_authorityRevocationList,
    OID_certificateRevocationList,
    OID_crossCertificatePair,
    OID_name,
    OID_givenName,
    OID_initials,
    OID_dnQualifier,
    OID_enhancedSearchGuide,
    OID_protocolInformation,
    OID_distinguishedName,
    OID_uniqueMember,
    OID_houseIdentifier,
    OID_supportedAlgorithms,
    OID_deltaRevocationList,
    OID_dmdName,
    OID_notChecked
     );

  TOIDInfo = record
    OIDDigital: AnsiString ;
    ID: TOIDs;
  end;


  TASN1BaseObject = class
  private
    FTag: Cardinal;
    FClass: Byte;
    function GetSize: Integer;
  protected
    function GetTagSize:Cardinal;
    function GetLenSize:Cardinal;
    function GetDataSize:Cardinal;virtual;
    function WriteHeader:AnsiString;
    function WriteLength:AnsiString;
    function WriteData:AnsiString;virtual;
  public
    constructor Create(ATag:Cardinal;AClass:Byte);
    function WriteToString:AnsiString;
    function Copy:TASN1BaseObject;virtual; abstract;
    function IsEqual(ASN1Object:TASN1BaseObject): Boolean; virtual;
    property Size:Integer read GetSize;
    property Tag: Cardinal read FTag;
    property ASN1Class:Byte read FClass;
  end;

  TASN1Null = class( TASN1BaseObject)
  protected
  public
    constructor Create;
    function Copy:TASN1BaseObject;override;
  end;

  TASN1Boolean = class( TASN1BaseObject)
  private
    FValue: Boolean;
  protected
    function GetDataSize:Cardinal;override;
    function WriteData:AnsiString;override;
  public
    constructor Create(AValue:Boolean);
    function IsEqual(ASN1Object:TASN1BaseObject): Boolean; override;
    function Copy:TASN1BaseObject;override;
    property Value: Boolean read FValue;
  end;

  TASN1Data = class( TASN1BaseObject)
  private
    function GetData: Pointer;
    function GetSize: Cardinal;
    procedure SetData(const Value: AnsiString);
  protected
    FData: AnsiString;
    function GetDataSize:Cardinal;override;
    function WriteData:AnsiString;override;
  public
    constructor Create(ATag:Cardinal;AClass:Byte;AValue: AnsiString);
    function Copy:TASN1BaseObject;override;
    function IsEqual(ASN1Object:TASN1BaseObject): Boolean; override;
    property Data: AnsiString read FData write SetData;
    property Buffer:Pointer read GetData;
    property Size: Cardinal read GetSize;
  end;

  TASN1Integer = class( TASN1Data)
  private
    FValue: Int64;
    FIsLargest: Boolean;
  public
    constructor Create(AValue:Int64;IsSigned:Boolean);overload;
    constructor Create(AData: AnsiString);overload;
    function Copy:TASN1BaseObject;override;
    property Value: Int64 read FValue;
    property IsLargest:Boolean read FIsLargest;
  end;

  TASN1ObjectID = class( TASN1Data)
  private
    FID: TOIDs;
    FOID: AnsiString;
    function GetID: TOIDs;
  public
    constructor Create(AData: AnsiString;IsOID:Boolean);
    constructor CreateFromID(AID: TOIDs);
    function Copy:TASN1BaseObject;override;
    property OID:AnsiString read FOID;
    property ID:TOIDs read GetID;
  end;

  TASN1BitString = class( TASN1Data)
  private
  public
    constructor Create(AData: AnsiString);
    function Copy:TASN1BaseObject;override;
  end;

  TASN1Container = class( TASN1BaseObject)
  private
    FList: TObjList;
    FUnknowLength:Boolean;
    function GetItems(Index: Integer): TASN1BaseObject;
    function GetCount: Integer;
  protected
    function GetDataSize:Cardinal;override;
    function WriteData:AnsiString;override;
  public
    constructor Create(ATag:Cardinal;AClass:Byte);
    destructor Destroy;override;
    function Add(AObject:TASN1BaseObject):Integer;
    function Copy:TASN1BaseObject;override;
    function IsEqual(ASN1Object:TASN1BaseObject): Boolean; override;
    property Items[Index:Integer]:TASN1BaseObject read GetItems; default;
    property Count: Integer read GetCount;
  end;

  TASN1Document = class (TObject)
  private
    FList: TObjList;
    procedure LoadFromBuffer(Buffer:Pointer; Size: Cardinal);
    function GetCount: Integer;
    function GetItems(Index: Integer): TASN1BaseObject;
    class function ReadItem(List:TObjList; Buffer:Pointer;Offset, Size:Cardinal; IsUnknowRealSize:Boolean;StartBuffer:Pointer):Cardinal;
    class function CreateObject(Tag: Cardinal;AClass:Byte; Data:AnsiString):TASN1BaseObject;
  public
    constructor Create;
    destructor Destroy;override;
    class function ReadASN1Object(Buffer:Pointer;Size:Cardinal):TASN1BaseObject;
    procedure LoadFromFile(AFileName:string);
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream:TStream);
    procedure SaveToFile(AFileName:string);
    function Add(AObject:TASN1BaseObject):Integer;
    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TASN1BaseObject read GetItems; default;
  end;

const

  LEN_MASK                = $7F;	// Bits 7 - 1
  TAG_MASK                =	$1F;	// Bits 5 - 1
  INCAPSULED_MASK         = $20;  // Bit 6
  LEN_XTND                = $80;	// Indefinite or long length

  OID_UNKNOWN = -1;

  ASN1_TAG_UNDEF                        = -1;
  ASN1_TAG_EOC                          = 0;
  ASN1_TAG_BOOLEAN                      = 1;
  ASN1_TAG_INTEGER                      = 2;
  ASN1_TAG_BIT_STRING                   = 3;
  ASN1_TAG_OCTET_STRING                 = 4;
  ASN1_TAG_NULL                         = 5;
  ASN1_TAG_OBJECT_ID                    = 6;
  ASN1_TAG_OBJECT_DESCRIPTOR            = 7;
  ASN1_TAG_EXTERNAL                     = 8;
  ASN1_TAG_REAL                         = 9;
  ASN1_TAG_ENUMERATED                   = 10;
  ASN1_TAG_SEQUENCE                     = 16;
  ASN1_TAG_UTF8STRING                   = 12;
  ASN1_TAG_SET                          = 17;
  ASN1_TAG_NUMERICSTRING                = 18;
  ASN1_TAG_PRINTABLESTRING              = 19;
  ASN1_TAG_T61STRING                    = 20;
  ASN1_TAG_TELETEXSTRING                = 20;
  ASN1_TAG_VIDEOTEXSTRING               = 21;
  ASN1_TAG_IA5STRING                    = 22;
  ASN1_TAG_UTCTIME                      = 23;
  ASN1_TAG_GENERALIZEDTIME              = 24;
  ASN1_TAG_GRAPHICSTRING                = 25;
  ASN1_TAG_ISO64STRING                  = 26;
  ASN1_TAG_VISIBLESTRING                = 26;
  ASN1_TAG_GENERALSTRING                = 27;
  ASN1_TAG_UNIVERSALSTRING              = 28;
  ASN1_TAG_BMPSTRING                    = 30;

  ASN1_CLASS_UNIVERSAL                  = 0;
  ASN1_CLASS_APPLICATION                = 1;
  ASN1_CLASS_CONTEXT                    = 2;
  ASN1_CLASS_PRIVATE                    = 3;


  OIDs_Count = 118;

  OIDs:array[0..OIDs_Count - 1] of TOIDInfo = (
    (OIDDigital: #$00;ID: OID_undef),
     // pkcs1
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$01#$01;ID: OID_rsaEncryption),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$01#$02;ID: OID_md2WithRSAEncryption),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$01#$04;ID: OID_md5WithRSAEncryption),
     // pkcs5
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$05#$01;ID: OID_pbeWithMD2AndDES_CBC),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$05#$03;ID: OID_pbeWithMD5AndDES_CBC),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$05#$04;ID: OID_pbeWithMD2AndRC2_CBC),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$05#$06;ID: OID_pbeWithMD5AndRC2_CBC),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$05#$0A;ID: OID_pbeWithSHA1AndDES_CBC),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$05#$0B;ID: OID_pbeWithSHA1AndRC2_CBC),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$05#$0C;ID: OID_id_pbkdf2),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$05#$0D;ID: OID_pbes2),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$05#$0E;ID: OID_pbmac1),

     // pkcs7
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$07#$01;ID: OID_pkcs7_data),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$07#$02;ID: OID_pkcs7_signed),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$07#$03;ID: OID_pkcs7_enveloped),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$07#$04;ID: OID_pkcs7_signedAndEnveloped),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$07#$05;ID: OID_pkcs7_digest),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$07#$06;ID: OID_pkcs7_encrypted),

     // pkcs9
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$01;ID: OID_pkcs9_emailAddress),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$02;ID: OID_pkcs9_unstructuredName),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$03;ID: OID_pkcs9_contentType),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$04;ID: OID_pkcs9_messageDigest),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$05;ID: OID_pkcs9_signingTime),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$06;ID: OID_pkcs9_countersignature),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$07;ID: OID_pkcs9_challengePassword),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$08;ID: OID_pkcs9_unstructuredAddress),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$09;ID: OID_pkcs9_extCertAttributes),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$0D;ID: OID_SigningDescription),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$0E;ID: OID_ext_req),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$0F;ID: OID_SMIMECapabilities),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$14;ID: OID_friendlyName),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$15;ID: OID_localKeyID),

     // Certificate Type
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$16#$01;ID: OID_x509Certificate),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$16#$02;ID: OID_sdsiCertificate),

     // CRLTypeX509
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$09#$17#$01;ID: OID_pkcs12CRLTypeX509),
     // PBE
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$01#$01;ID: OID_pbe_WithSHA1And128BitRC4),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$01#$02;ID: OID_pbe_WithSHA1And40BitRC4),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$01#$03;ID: OID_pbe_WithSHA1And3_Key_TripleDES_CBC),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$01#$04;ID: OID_pbe_WithSHA1And2_Key_TripleDES_CBC),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$01#$05;ID: OID_pbe_WithSHA1And128BitRC2_CBC),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$01#$06;ID: OID_pbe_WithSHA1And40BitRC2_CBC),
     // KeyBag
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$0A#$01#$01;ID: OID_keyBag),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$0A#$01#$02;ID: OID_pkcs8ShroudedKeyBag),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$0A#$01#$03;ID: OID_certBag),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$0A#$01#$04;ID: OID_crlBag),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$0A#$01#$05;ID: OID_secretBag),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$01#$0C#$0A#$01#$06;ID: OID_safeContentsBag),
     // Digest
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$02#$02;ID: OID_md2),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$02#$04;ID: OID_md4),
    (OIDDigital: #$2A#$86#$48#$86#$F7#$0D#$02#$05;ID: OID_md5),
     // algorithm
    (OIDDigital: #$2B#$0E#$03#$02#$03;ID: OID_md5WithRSA),
    (OIDDigital: #$2B#$0E#$03#$02#$06;ID: OID_des_ecb),
    (OIDDigital: #$2B#$0E#$03#$02#$07;ID: OID_des_cbc),
    (OIDDigital: #$2B#$0E#$03#$02#$08;ID: OID_des_ofb64),
    (OIDDigital: #$2B#$0E#$03#$02#$09;ID: OID_des_cfb64),
    (OIDDigital: #$2B#$0E#$03#$02#$0B;ID: OID_rsaSignature),
    (OIDDigital: #$2B#$0E#$03#$02#$0C;ID: OID_dsa_2),
    (OIDDigital: #$2B#$0E#$03#$02#$0D;ID: OID_dsaWithSHA),
    (OIDDigital: #$2B#$0E#$03#$02#$0F;ID: OID_shaWithRSAEncryption),
    (OIDDigital: #$2B#$0E#$03#$02#$12;ID: OID_sha),
    (OIDDigital: #$2B#$0E#$03#$02#$11;ID: OID_des_ede_ecb),
    (OIDDigital: #$2B#$0E#$03#$02#$1A;ID: OID_sha1),
    (OIDDigital: #$2B#$0E#$03#$02#$1B;ID: OID_dsaWithSHA1_2),
    (OIDDigital: #$2B#$0E#$03#$02#$1D;ID: OID_sha1WithRSA),
    (OIDDigital: #$2B#$24#$03#$02#$01;ID: OID_ripedm160),

    (OIDDigital: #$55#$04#$03;ID: OID_commonName),
    (OIDDigital: #$55#$04#$04;ID: OID_surName),
    (OIDDigital: #$55#$04#$05;ID: OID_serialNumber),
    (OIDDigital: #$55#$04#$06;ID: OID_countryName),
    (OIDDigital: #$55#$04#$07;ID: OID_localityName),
    (OIDDigital: #$55#$04#$08;ID: OID_stateOrProvinceName),
    (OIDDigital: #$55#$04#$0A;ID: OID_organizationName),
    (OIDDigital: #$55#$04#$0B;ID: OID_organizationalUnitName),
    (OIDDigital: #$55#$04#$0C;ID: OID_title),
    (OIDDigital: #$55#$04#$0D;ID: OID_description),
    (OIDDigital: #$55#$04#$0E;ID: OID_searchGuide),
    (OIDDigital: #$55#$04#$0F;ID: OID_businessCategory),
    (OIDDigital: #$55#$04#$10;ID: OID_postalAddress),
    (OIDDigital: #$55#$04#$12;ID: OID_postOfficeBox),
    (OIDDigital: #$55#$04#$13;ID: OID_physicalDeliveryOfficeName),
    (OIDDigital: #$55#$04#$14;ID: OID_telephoneNumber),
    (OIDDigital: #$55#$04#$15;ID: OID_telexNumber),
    (OIDDigital: #$55#$04#$16;ID: OID_teletexTerminalIdentifier),
    (OIDDigital: #$55#$04#$17;ID: OID_facsimileTelephoneNumber),
    (OIDDigital: #$55#$04#$18;ID: OID_x121Address),
    (OIDDigital: #$55#$04#$19;ID: OID_internationaliSDNNumber),
    (OIDDigital: #$55#$04#$1A;ID: OID_registeredAddress),
    (OIDDigital: #$55#$04#$1B;ID: OID_destinationIndicator),
    (OIDDigital: #$55#$04#$1C;ID: OID_preferredDeliveryMethod),
    (OIDDigital: #$55#$04#$1D;ID: OID_presentationAddress),
    (OIDDigital: #$55#$04#$1E;ID: OID_supportedApplicationContext),
    (OIDDigital: #$55#$04#$1F;ID: OID_member),
    (OIDDigital: #$55#$04#$20;ID: OID_owner),
    (OIDDigital: #$55#$04#$21;ID: OID_roleOccupant),
    (OIDDigital: #$55#$04#$22;ID: OID_seeAlso),
    (OIDDigital: #$55#$04#$23;ID: OID_userPassword),
    (OIDDigital: #$55#$04#$24;ID: OID_userCertificate),
    (OIDDigital: #$55#$04#$25;ID: OID_cACertificate),
    (OIDDigital: #$55#$04#$26;ID: OID_authorityRevocationList),
    (OIDDigital: #$55#$04#$27;ID: OID_certificateRevocationList),
    (OIDDigital: #$55#$04#$28;ID: OID_crossCertificatePair),
    (OIDDigital: #$55#$04#$29;ID: OID_name),
    (OIDDigital: #$55#$04#$2A;ID: OID_givenName),
    (OIDDigital: #$55#$04#$2B;ID: OID_initials),
    (OIDDigital: #$55#$04#$2E;ID: OID_dnQualifier),
    (OIDDigital: #$55#$04#$2F;ID: OID_enhancedSearchGuide),
    (OIDDigital: #$55#$04#$30;ID: OID_protocolInformation),
    (OIDDigital: #$55#$04#$31;ID: OID_distinguishedName),
    (OIDDigital: #$55#$04#$32;ID: OID_uniqueMember),
    (OIDDigital: #$55#$04#$33;ID: OID_houseIdentifier),
    (OIDDigital: #$55#$04#$34;ID: OID_supportedAlgorithms),
    (OIDDigital: #$55#$04#$35;ID: OID_deltaRevocationList),
    (OIDDigital: #$55#$04#$36;ID: OID_dmdName),
    (OIDDigital: #$60#$86#$48#$01#$65#$03#$04#$02#$01;ID: OID_SHA256),
    (OIDDigital: #$60#$86#$48#$01#$65#$03#$04#$02#$02;ID:  OID_SHA384),
    (OIDDigital: #$60#$86#$48#$01#$65#$03#$04#$02#$03;ID: OID_SHA512),
    (OIDDigital: #$60#$86#$48#$01#$65#$03#$04#$02#$04;ID:  OID_SHA224)
  );


implementation
uses  llPDFResources;


{ TASN1BaseObject }

constructor TASN1BaseObject.Create(ATag:Cardinal;AClass:Byte);
begin
  FTag := ATag;
  FClass := AClass;
end;

function TASN1BaseObject.GetDataSize: Cardinal;
begin
  Result := 0;
end;

function TASN1BaseObject.GetLenSize: Cardinal;
var
  l: Cardinal;
begin
  Result := 1;
  L := GetDataSize;
  if (Self is TASN1Container) and TASN1Container(Self).FUnknowLength then
    Exit;
  if l < 128 then
    Exit;
  while l >0 do
  begin
    inc(Result);
    l := l shr 8
  end;
end;

function TASN1BaseObject.GetSize: Integer;
begin
  Result := GetTagSize+GetLenSize+GetDataSize;
end;

function TASN1BaseObject.GetTagSize: Cardinal;
var
  wrk: Cardinal;
begin
  Result := 1;
  if FTag > 30 then
  begin
    wrk := FTag;
    while wrk <> 0 do
    begin
      wrk := wrk shr 7;
      inc( Result);
    end;
  end;
end;


function TASN1BaseObject.IsEqual(ASN1Object: TASN1BaseObject): Boolean;
begin
  Result := False;
  if Self.ClassType <> ASN1Object.ClassType then Exit;
  if FTag <> ASN1Object.FTag then Exit;
  if FClass <> ASN1Object.FClass then Exit;
  Result := True;
end;

function TASN1BaseObject.WriteData:AnsiString;
begin
  result := '';
end;

function TASN1BaseObject.WriteHeader: AnsiString;
var
  B, T: Byte;
  WRK: Cardinal;
  frst:boolean;
begin
  if FTag < 31 then
  begin
    B := FClass shl 6;
    if self is TASN1Container then
      B := B or INCAPSULED_MASK;
    B := B or FTag;
    Result := AnsiChar(B);
  end else
  begin
    B := FClass shl 6;
    if self is TASN1Container then
      B := B or INCAPSULED_MASK;
    B := B or TAG_MASK;
    WRK := FTag;
    frst := true;
    Result := '';
    while WRK <> 0 do
    begin
      T := WRK and $7F;
      if not frst then
        T := T or $80
      else
        frst := false;
      Result := AnsiChar(T)+Result;
      WRK := WRK shr 7;
    end;
    Result := AnsiChar(B)+Result;
  end;
end;

function TASN1BaseObject.WriteLength: AnsiString;
var
  L,cnt:Cardinal;
begin
  L := GetDataSize;
  if (Self is TASN1Container) and TASN1Container(Self).FUnknowLength then
  begin
    Result := #128;
  end else
  begin
    if L< 128 then
      Result:= AnsiChar(L)
    else
    begin
      result :='';
      cnt := 0;
      while L > 0 do
      begin
        Result := AnsiChar(L and $FF) + result;
        L := L shr 8;
        inc(cnt);
      end;
      cnt := cnt or $80;
      Result := AnsiChar(cnt) + Result;
    end;
  end;
end;

function TASN1BaseObject.WriteToString: AnsiString;
begin
  Result := WriteHeader+WriteLength+WriteData;
end;

{ TASN1Container }

function TASN1Container.Add(AObject: TASN1BaseObject): Integer;
begin
  Result := FList.Add(AObject);
end;

function TASN1Container.Copy: TASN1BaseObject;
var
  I: Integer;
  R : TASN1Container;
  Item: TASN1BaseObject;
begin
  R := TASN1Container.Create(FTag,FClass);
  for i:= 0 to FList.Count - 1 do
  begin
    Item := FList[i] as TASN1BaseObject;
    R.Add(Item.Copy);
  end;
  R.FUnknowLength := FUnknowLength;
  Result := R;
end;

constructor TASN1Container.Create(ATag:Cardinal;AClass:Byte);
begin
  inherited Create(ATag, AClass);
  FList := TObjList.Create(true);
  FUnknowLength := False;
end;

destructor TASN1Container.Destroy;
begin
  FList.Free;
  inherited;
end;

function TASN1Container.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TASN1Container.GetDataSize: Cardinal;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FList.Count - 1 do
  begin
    Result := Result + TASN1BaseObject(FList[i]).GetTagSize+TASN1BaseObject(FList[i]).GetLenSize+TASN1BaseObject(FList[i]).GetDataSize;
  end;
  if FUnknowLength then
    Inc(Result,2);
end;

function TASN1Container.GetItems(Index: Integer): TASN1BaseObject;
begin
  Result := TASN1BaseObject(FList[Index]);
end;

function TASN1Container.IsEqual(ASN1Object: TASN1BaseObject): Boolean;
var
  i: Integer;
begin
  Result := inherited IsEqual(ASN1Object);
  if Result then
  begin
    Result := false;
    if FList.Count <>  TASN1Container(ASN1Object).Count then
      Exit;
    for i:= 0 to FList.Count - 1 do
      if not TASN1BaseObject(FList[i]).IsEqual(TASN1BaseObject(TASN1Container(ASN1Object)[i])) then Exit;
      Result := True;
  end;
end;

function TASN1Container.WriteData: AnsiString;
var
  I: Integer;
begin
  Result := '';
  for i := 0 to FList.Count - 1 do
  begin
    Result := Result + TASN1BaseObject(FList[i]).WriteToString;
  end;
  if FUnknowLength then
    Result := Result +#0#0;
end;

{ TASN1Null }

function TASN1Null.Copy: TASN1BaseObject;
begin
  result := TASN1Null.Create;
end;

constructor TASN1Null.Create;
begin
  inherited Create(ASN1_TAG_NULL, ASN1_CLASS_UNIVERSAL);
end;

{ TASN1Boolean }

function TASN1Boolean.Copy: TASN1BaseObject;
begin
  Result := TASN1Boolean.Create(FValue);
end;

constructor TASN1Boolean.Create(AValue: Boolean);
begin
  inherited Create(ASN1_TAG_BOOLEAN, ASN1_CLASS_UNIVERSAL);
  FValue := AValue;
end;

function TASN1Boolean.GetDataSize: Cardinal;
begin
  Result := 1;
end;

function TASN1Boolean.IsEqual(ASN1Object: TASN1BaseObject): Boolean;
begin
  Result := inherited IsEqual(ASN1Object);
  if Result then
    Result := (FValue = TASN1Boolean(ASN1Object).FValue);
end;

function TASN1Boolean.WriteData: AnsiString;
begin
  if FValue then
    Result := #$FF
  else
    Result := #$0;
end;

{ TASN1Integer }

constructor TASN1Integer.Create(AValue:Int64;IsSigned:Boolean);
var
  X: Int64;
  Str: AnsiString;
begin
  X := AValue;
  X := ByteSwap(X);
  System.SetLength(Str,SizeOf(X));
  Move(X,Str[1],SizeOf(X));
  if IsSigned then
    while (Str <> #0) and (Str[1] = #0) do
      Delete(Str,1,1)
  else
    while ((Str <> #0) and (Str[1] = #0) and (Byte(Str[2]) and $80 = 0)) or
          (((Str <> #$FF) and (Str[1] = #$FF) and (Byte(Str[2]) and $80 = $80))) do
      Delete(Str,1,1);
  inherited Create(ASN1_TAG_INTEGER, ASN1_CLASS_UNIVERSAL ,str);
  FValue := AValue;
  FIsLargest := False;
end;

function TASN1Integer.Copy: TASN1BaseObject;
begin
  Result := TASN1Integer.Create(FData);
end;

constructor TASN1Integer.Create(AData: AnsiString);
var
  Str: AnsiString;
  X: Int64;
  Len: Cardinal;
begin
  inherited Create(ASN1_TAG_INTEGER, ASN1_CLASS_UNIVERSAL ,AData);
  Len := Length(AData);
  if Len = 0 then
  begin
    FValue := 0;
    Exit;
  end;
  if Len <= SizeOf(Int64) then
  begin
    if Byte(AData[1]) and $80 = 0 then
      Str := AnsiString(StringOfChar(#0,SizeOf(Int64)))
    else
      Str := AnsiString(StringOfChar(#$FF,SizeOf(Int64)));
    Move(AData[1],Str[1 + SizeOf(Int64) - Len],Len);
    Move(Str[1],X,SizeOf(Int64));
    FValue := ByteSwap(X);
    FIsLargest := False;
  end else
  begin
    FIsLargest := True;
    FValue := -1;
  end;
end;



{ TASN1Document }

function TASN1Document.Add(AObject: TASN1BaseObject): Integer;
begin
  Result := FList.Add(AObject);
end;

procedure TASN1Document.Clear;
begin
  FList.Clear;
end;

constructor TASN1Document.Create;
begin
  FList := TObjList.Create(true);
end;

class function TASN1Document.CreateObject(Tag: Cardinal; AClass:Byte; Data: AnsiString): TASN1BaseObject;
var
  Len:Integer;
begin
  Len := Length(Data);
  if AClass = ASN1_CLASS_UNIVERSAL then
  begin
    case Tag of
      ASN1_TAG_BOOLEAN:
        begin
          if Len<> 1 then
            raise EPDFSignatureException.Create(SInvalidASN1DocumentTagBooleanLen);
          Result := TASN1Boolean.Create(Data[1]<>#0);
        end;
      ASN1_TAG_NULL:
        Result := TASN1Null.Create;
      ASN1_TAG_INTEGER:
        Result := TASN1Integer.Create(Data);
      ASN1_TAG_OBJECT_ID:
        Result := TASN1ObjectID.Create(Data,False);
      ASN1_TAG_BIT_STRING:
          Result := TASN1BitString.Create(Data);
      else
        Result := TASN1Data.Create(Tag,AClass,Data);
     end;
   end else
   begin
     Result := TASN1Data.Create(Tag,AClass,Data);
   end;
end;

destructor TASN1Document.Destroy;
begin
  FList.Free;
  inherited;
end;

function TASN1Document.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TASN1Document.GetItems(Index: Integer): TASN1BaseObject;
begin
  Result := TASN1BaseObject(FList[Index]);
end;

procedure TASN1Document.LoadFromBuffer(Buffer: Pointer; Size: Cardinal);
var
  Off: Cardinal;
  ItemSize:Cardinal;
begin
  FList.Clear;
  Off := 0;
  ItemSize:= ReadItem(FList,Buffer,Off,Size,False,Buffer);
  while ItemSize <>0 do
  begin
    Off := Off + ItemSize;
    ItemSize:= ReadItem(FList,Buffer,Off,Size, False, buffer);
  end
end;

procedure TASN1Document.LoadFromFile(AFileName: string);
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

procedure TASN1Document.LoadFromStream(AStream: TStream);
var
  Buffer:Pointer;
  Size, P: Cardinal;
begin
  Size := AStream.Size - AStream.Position;
  Buffer := GetMemory(Size);
  try
    P := AStream.Position;
    AStream.Read(Buffer^,Size);
    AStream.Position := P;
    LoadFromBuffer(Buffer,Size);
  finally
    FreeMemory(Buffer);
  end;
end;

class function TASN1Document.ReadASN1Object(Buffer: Pointer; Size: Cardinal): TASN1BaseObject;
var
  Objs: TObjList;
begin
  Objs := TObjList.Create(false);
  try
    ReadItem(Objs,Buffer,0,Size,False, Buffer);
    if Objs.Count = 0 then
      Result := nil
    else
      Result := TASN1BaseObject(Objs[0]);
  finally
    Objs.Free;
  end;
end;

class function TASN1Document.ReadItem(List: TObjList; Buffer: Pointer; Offset, Size: Cardinal;IsUnknowRealSize:Boolean;StartBuffer:Pointer): Cardinal;
var
  PB: PByteArray;
  wrk, TagSRC,LenSRC: Byte;
  Tag, Len, HeaderSize, cnt, ItemSize: Cardinal;
  NewBuffer: Pointer;
  ID: byte;
  Incapsuled:Boolean;
  I: Cardinal;
  Item:TASN1BaseObject;
  UnknowLen:Boolean;
  Data:AnsiString;
begin
  Result := 0;
  if Offset >= Size then
    Exit;
  UnknowLen := False;
  PB := Pointer(FarInteger(Buffer) + Offset);
  wrk :=PB[Result];
  TagSRC := wrk;
  Inc(Result);
  ID :=  (wrk and (not TAG_MASK)) shr 6;
  Incapsuled := wrk and INCAPSULED_MASK <> 0;
  wrk  := wrk and TAG_MASK;
  if wrk = TAG_MASK then
  begin
    cnt:= 0;
    Tag := 0;
    if Offset+Result >= Size then
      raise EPDFSignatureException.Create(SInvalidASN1DocumentCannotCalcula);
    repeat
      wrk :=PB[Result];
      Inc(Result);
      Tag := ( tag shl 7 ) or (wrk and $7F);
    until  (Offset+Result >= Size) or (cnt>=4) or (wrk<127);
    if (cnt>=4) then
      raise EPDFSignatureException.Create(SInvalidASN1DocumentVeryLargeTag);
    if (Offset+Result >= Size) then
      raise EPDFSignatureException.Create(SInvalidASN1DocumentCannotCalcula);
  end else
  begin
    Tag := wrk;
  end;
  if Offset+Result >= Size then
    raise EPDFSignatureException.Create(SInvalidASN1DocumentCannotCalcula);
  wrk := PB[Result];
  Inc(Result);
  LenSRC := wrk;
  if (wrk and LEN_XTND ) = 0 then
  begin
    Len := wrk;
  end else
  begin
    Len := 0;
    wrk := wrk and LEN_MASK;
    if wrk = 0 then
    begin
      UnknowLen := True;
    end else
    begin
      if wrk > 4 then
        raise EPDFSignatureException.Create(SInvalidASN1DocumentVeryLargeLeng);
      for i := 0 to  wrk -1 do
      begin
        if Offset+Result >= Size then
          raise EPDFSignatureException.Create(SInvalidASN1DocumentCannotCalcula);
        wrk := PB[Result];
        Inc(Result);
        Len := (Len shl 8) or wrk;
      end;
    end;
  end;
  HeaderSize := Result;
  if (TagSRC = 0) and (LenSRC = 0) then
  begin
    if IsUnknowRealSize then
    begin
      Result := $FFFFFFF0;
      Exit;
    end else
    begin
      raise EPDFSignatureException.Create(SInvalidASN1DocumentInvalidTagWas);
    end;
  end;
  if not UnknowLen then
    if Offset+Result+ Len > Size then
    begin
      Exit;
    end;
  if Incapsuled then
  begin
    if ((ID = 0) and ((Tag = ASN1_TAG_SEQUENCE) or (Tag = ASN1_TAG_SET))) or (ID > 0) then
    begin
      Item := TASN1Container.Create(Tag,ID);
      if UnknowLen then
        Len := Size - Offset - HeaderSize;
      try
        TASN1Container(Item).FUnknowLength := UnknowLen;
        NewBuffer := Pointer(FarInteger(Buffer) + Offset+ HeaderSize);
        Offset := 0;
        ItemSize:= ReadItem(TASN1Container(Item).FList,NewBuffer,Offset,Len, UnknowLen, StartBuffer);
        while ItemSize <>0 do
        begin
          Offset := Offset + ItemSize;
          ItemSize:= ReadItem(TASN1Container(Item).FList,NewBuffer,Offset,Len, UnknowLen, StartBuffer);
          if UnknowLen and (ItemSize = $FFFFFFF0) then
          begin
            Inc(Offset,2);
            Break;
          end;
        end;
        if UnknowLen then
          Len := Offset;
      except
        on Exception do
        begin
          Item.Free;
          raise;
        end;
      end;
      List.Add(Item);
    end
  end else
  begin
    if UnknowLen then
      raise EPDFSignatureException.Create(SInvalidASN1DocumentCannotCalcula);
    SetLength(Data, Len);
    move(PB[Result],Data[1], Len);
    Item := CreateObject(Tag, ID, Data);
    if Item <> nil then
      List.Add(Item);
  end;
  Result := Result + Len;
end;

procedure TASN1Document.SaveToFile(AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName,fmCreate);
  try
    SaveToStream(FS);
  finally
    FS.Free;
  end;
end;

procedure TASN1Document.SaveToStream(AStream: TStream);
var
  S: AnsiString;
  I: Integer;
begin
  S := '';
  for i := 0 to FList.Count - 1 do
    S := S + TASN1BaseObject(FList[I]).WriteToString;
  AStream.Write(S[1],Length(S)) ;
end;


{ TASN1Data }

function TASN1Data.Copy: TASN1BaseObject;
begin
  Result := TASN1Data.Create(FTag,FClass,FData);
end;

constructor TASN1Data.Create(ATag: Cardinal; AClass: Byte; AValue: AnsiString);
begin
  inherited Create(ATag,AClass);
  FData := AValue;
end;

function TASN1Data.GetData: Pointer;
begin
  Result := @(FData[1]);
end;

function TASN1Data.GetDataSize: Cardinal;
begin
  Result := Length(FData);
end;

function TASN1Data.GetSize: Cardinal;
begin
  Result := Length(FData);
end;

function TASN1Data.IsEqual(ASN1Object: TASN1BaseObject): Boolean;
begin
  Result := inherited IsEqual(ASN1Object);
  if Result then
    Result := (FData = TASN1Data(ASN1Object).FData);
end;

procedure TASN1Data.SetData(const Value: AnsiString);
begin
  if (Self is TASN1Integer) or (Self is TASN1ObjectID) then
    raise EPDFSignatureException.Create(SCannotChangeValue);
  FData := Value;
end;

function TASN1Data.WriteData: AnsiString;
begin
  Result := FData;
end;

{ TASN1ObjectID }

function TASN1ObjectID.Copy: TASN1BaseObject;
begin
  Result := TASN1ObjectID.Create(FData, False);
end;

constructor TASN1ObjectID.Create(AData: AnsiString;IsOID:Boolean);
  function DataToOID(Str:AnsiString):AnsiString;
  var
    B: Byte;
    I, L: Integer;
    C: Int64;
  begin
    if str = '' then
    begin
      Result := '';
      Exit;
    end;
    B := Byte(Str[1]);
    Result := IStr(B div 40)+'.'+IStr(B mod 40);
    I:= 2;
    L := Length(Str);
    while  I <= L do
    begin
      B := Byte(Str[I]);
      if B < 128 then
      begin
        Result := Result+'.'+IStr(B);
        inc(I);
      end else
      begin
        C := 0;
        while I < L do
        begin
          c:= c shl 7 + b and $7f;
          Inc(I);
          if b < 128 then
            break;
          B := Byte(Str[I]);
          if I = L then
          begin
            c:= c shl 7 + b and $7f;
            break;
          end;
        end;
        Result := Result+'.'+IStr(C);
        if I = L then
          break;
      end;
    end;
  end;
  function ExtractSubIden(const S: AnsiString; var StartPos: Integer): Int64;
  var
    V: AnsiString;
  begin
    V := '';
    repeat
      V := V + S[StartPos];
      Inc(StartPos);
    until (StartPos > Length(S)) or (S[StartPos] = '.');
    if StartPos < Length(S) then Inc(StartPos);
    Result := StrToInt64Def(string(V),0);
  end;
  function EncodeSubIden(Value: Int64): AnsiString;
  var
    T: Byte;
  begin
    T := Value and $7F;
    Result := AnsiChar(T);
    Value := Value shr 7;
    while Value > 0 do
    begin
      T := (Value and $7F) or $80;
      Result := AnsiChar(T) + Result;
      Value := Value shr 7;
    end;
  end;
  function OIDToStr(val: AnsiString): AnsiString;
  var
    I: Integer;
    X, Y: Int64;
  begin
    I := 1;
    Y := ExtractSubIden(OID,I);
    if I >= Length(OID) then
    begin
      Result := '';
      while Y > 0 do
      begin
        Result := AnsiChar(Y and $FF) + Result;
        Y := Y shr 8;
      end;
      if Result = '' then
        Result := #0
      else if Byte(Result[1]) and $80 > 0 then
        Result := #0 + Result;
    end else
    begin
      X := ExtractSubIden(OID,I);
      X := X + Y*40;
      Result := '';
      repeat
        Result := Result + EncodeSubIden(X);
        X := ExtractSubIden(OID,I);
      until I > Length(OID);
      Result := Result + EncodeSubIden(X);
    end;
  end;
begin
  FID := OID_notChecked;
  if IsOID then
  begin
    FOID := AData;
    inherited Create(ASN1_TAG_OBJECT_ID, ASN1_CLASS_UNIVERSAL,OIDToStr(AData));
  end else
  begin
    inherited Create(ASN1_TAG_OBJECT_ID, ASN1_CLASS_UNIVERSAL,AData);
    FOID := DataToOID(AData);
  end;
end;

constructor TASN1ObjectID.CreateFromID(AID: TOIDs);
var
  I: Integer;
  S:AnsiString;
begin
  S := #0;
  for i := 0 to OIDs_Count - 1 do
    if  OIDs[i].ID = AID then
    begin
      S := OIDs[i].OIDDigital;
      Break;
    end;
  Create(S,false);
end;

function TASN1ObjectID.GetID: TOIDs;
var
  L, H, I, C: Integer;
  function StrCmp(A,B:AnsiString):Integer;
  var
    AL,BL, I, M: Cardinal;
  begin
    AL := Length(A);
    BL := Length(B);
    M := min(AL, BL);
    for i := 1 to M do
    begin
      if A[i] < B[i] then
      begin
        Result := -1;
        Exit;
      end;
      if A[i] > B[i] then
      begin
        Result := 1;
        Exit;
      end;
    end;
    if AL < BL then
      Result := -1
    else if AL > BL then
      Result := 1
    else Result := 0;
  end;
begin
  if FID = OID_notChecked then
  begin
    FID := OID_Undef;
    L := 0;
    H := OIDs_Count - 1;
    while L <= H do
    begin
      I := (L + H) shr 1;
      C := StrCmp(OIDs[I].OIDDigital,FData);
      if C < 0 then L := I + 1 else
      begin
        H := I - 1;
        if C = 0 then
        begin
          FID := OIDs[I].ID;
          break
        end;
      end;
    end;
  end;
  result := FID;
end;

{ TASN1BitString }

function TASN1BitString.Copy: TASN1BaseObject;
begin
  Result := TASN1BitString.Create(FData);
end;

constructor TASN1BitString.Create(AData: AnsiString);
begin
  inherited Create(ASN1_TAG_BIT_STRING,0, AData);
end;
end.
