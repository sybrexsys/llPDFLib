{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFCrypt;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif}
  llPDFASN1,
  llPDFTypes;

type
  TCipher = class
  private
    FKeyLen: Cardinal;
    procedure Init(Key:Pointer;Len: Cardinal;InitVector:Pointer);virtual;abstract;
  public
    constructor Create(Key:Pointer;Len: Cardinal;InitVector:Pointer);
    procedure Decode(Buf:Pointer;Len:Cardinal);virtual;abstract;
    procedure Encode(Buf:Pointer;Len:Cardinal);virtual;abstract;
    function DecodeToStr(Buf:Pointer;Len:Cardinal):AnsiString;
    procedure DecodeTo(Source, Destination: Pointer; Len:Cardinal;SaveSource:Boolean=true);
    procedure EncodeTo(Source, Destination: Pointer; Len:Cardinal;SaveSource:Boolean=true);
  end;

  TBlockCipher = class(TCipher)
  private
    FInitVector:array[0..63] of byte;
    function GetBlockSize:Cardinal;virtual;abstract;
    function GetIVSize:Cardinal;virtual;abstract;
    procedure XORBuffer(const Buffer1, Buffer2: Pointer; const BufferSize: Integer);
    procedure DecodeBlock(Buf:Pointer);virtual;abstract;
    procedure EncodeBlock(Buf:Pointer);virtual;abstract;
    procedure Init(Key:Pointer;Len: Cardinal;InitVector:Pointer);override;
  public
    procedure Decode(Buf:Pointer;Len:Cardinal);override;
    procedure Encode(Buf:Pointer;Len:Cardinal);override;
  end;

  TCipherClass = class of TCipher;

  TRC4Cipher = class(TCipher)
  private
    FKey: array[0..255] of byte; { current key }
    FOrgKey: array[0..255] of byte; { original key }
    procedure Init(Key:Pointer;Len: Cardinal;InitVector:Pointer); override;
  public
    procedure Decode(Buf:Pointer;Len:Cardinal);override;
    procedure Encode(Buf:Pointer;Len:Cardinal);override;
  end;

  TRC2CipherKey = packed record
    case Integer of
      0 : (Bytes: array[0..127] of Byte);
      1 : (Words: array[0..63] of Word);
  end;


  TRC2Cipher = class(TBlockCipher)
  private
    FKey:TRC2CipherKey;
    function GetBlockSize:Cardinal;override;
    function GetIVSize:Cardinal;override;
    procedure Init(Key:Pointer;Len: Cardinal;InitVector:Pointer);override;
    procedure DecodeBlock(Buf:Pointer);override;
    procedure EncodeBlock(Buf:Pointer);override;
  public
 end;

  TDESCipher = class(TBlockCipher)
  private
    FUserInfo:array[0..32 * 4 * 2 * 3 - 1] of byte;
    procedure MakeKey(const Data: array of Byte; Key: PInteger; Reverse: Boolean);
    function GetBlockSize:Cardinal;override;
    function GetIVSize:Cardinal;override;
    procedure Init(Key:Pointer;Len: Cardinal;InitVector:Pointer);override;
    procedure DecodeBlock(Buf:Pointer);override;
    procedure EncodeBlock(Buf:Pointer);override;
  public
  end;

  TAESCipher = class(TBlockCipher)
  private
    nr:DWORD;
    erk:array[0..63] of DWord;
    FIV:Pointer;
    function GetBlockSize:Cardinal;override;
    function GetIVSize:Cardinal;override;
    procedure Init(Key:Pointer;Len: Cardinal;InitVector:Pointer);override;
    procedure EncodeBlock(Buf:Pointer);override;
    procedure DecodeBlock(Buf:Pointer);override;    
  public
    procedure Encode(Buf:Pointer;Len:Cardinal);override;
    procedure Decode(Buf:Pointer;Len:Cardinal);override;
  end;



   THash = class
  private
    function GetDigest:PByteArray;virtual;abstract;
    function GetHashString: AnsiString;
  public
    constructor Create;
    procedure Init; virtual;abstract;
    procedure Update(const ChkBuf; Len: Cardinal); virtual;abstract;
    procedure Final; virtual;abstract;
    procedure Finish(P:Pointer);
    procedure HashIteration( const ChkBuf; Len, Iterations: Cardinal);
    class function HashSize:Cardinal;virtual;
    property Digest:PByteArray read GetDigest;
    property HashString:AnsiString read GetHashString;
  end;

  THashClass = class of THash;

  TMD2Hash = class(THash)
  private
    FD: array[0..47] of Byte;
    FC: array[0..15] of Byte;
    Fi: Byte;
    FL: Byte;
    FDigest:  array[0..15] of Byte;
    function GetDigest:PByteArray;override;
    procedure UpdateB(c: Byte);
  public
    procedure Init; override;
    procedure Update(const ChkBuf; Len: Cardinal); override;
    procedure Final; override;
    class function HashSize:Cardinal;override;
  end;

  TMD4Hash = class(THash)
  private
    FState: array[0..3] of DWORD;
    FCount: array[0..1] of DWORD;
    FBuffer: array[0..63] of Byte;
    FBLen: DWORD;
    FDigest:  array[0..15] of Byte;
    function GetDigest:PByteArray;override;
    procedure Transform(var Accu; const Buf);
  public
    procedure Init; override;
    procedure Update(const ChkBuf; Len: Cardinal); override;
    procedure Final; override;
    class function HashSize:Cardinal;override;
  end;

  TMD5Hash = class(THash)
  private
    FState: array[0..3] of DWORD;
    FCount: array[0..1] of DWORD;
    FBuffer: array[0..63] of Byte;
    FBLen: DWORD;

    FDigest: array[0..15] of Byte;
    function GetDigest:PByteArray;override;
    procedure Transform(var Accu; const Buf);
  public
    procedure Init; override;
    procedure Update(const ChkBuf; Len: Cardinal); override;
    procedure Final; override;
    class function HashSize:Cardinal;override;
  end;

  TSHA1Hash = class(THash)
  private
    Size: int64;//cardinal;
    CA, CB, CC, CD, CE: DWORD;
    Buffer: array [0..63] of byte;
    W: array [0..79] of DWORD;
    BufSize: cardinal;
    FDigest: array[0..19] of Byte;
    function GetDigest:PByteArray;override;
    procedure Transform(Chunk:Pointer);
  public
    procedure Init; override;
    procedure Update(const ChkBuf; Len: Cardinal); override;
    procedure Final; override;
    class function HashSize:Cardinal;override;
  end;

  TSHA256Hash = class(THash)
  private
    FLenHi, FLenLo: DWORD;
    FIndex: Cardinal;
    FHash: array[0..7] of DWORD;
    FBuffer: array[0..63] of Byte;
    FDigest: array[0..31] of Byte;
    function GetDigest:PByteArray;override;
    procedure Transform;
  public
    procedure Init; override;
    procedure Update(const ChkBuf; Len: Cardinal); override;
    procedure Final; override;
    class function HashSize:Cardinal;override;
  end;


function OIDtoHashClass(OID:TOIDs):THashClass;

function StringToHash(HashClass:THashClass;Str:AnsiString):AnsiString;
procedure DataToHash(HashClass:THashClass;Input: Pointer; InputLen: Integer; const Digest);

function CalcAESSize(Encryption:TPDFSecurityState;Size: Integer): Integer;




implementation

uses llPDFMisc, llPDFResources;

const
  MaxCipherBlockSize = 4096;
  SHA_HASH_BUFFER_SIZE = 64;

const

  FSb: array[0..255] of DWORD = (
    $63, $7C, $77, $7B, $F2, $6B, $6F, $C5, $30, $01, $67, $2B, $FE, $D7, $AB, $76,
    $CA, $82, $C9, $7D, $FA, $59, $47, $F0, $AD, $D4, $A2, $AF, $9C, $A4, $72, $C0,
    $B7, $FD, $93, $26, $36, $3F, $F7, $CC, $34, $A5, $E5, $F1, $71, $D8, $31, $15,
    $04, $C7, $23, $C3, $18, $96, $05, $9A, $07, $12, $80, $E2, $EB, $27, $B2, $75,
    $09, $83, $2C, $1A, $1B, $6E, $5A, $A0, $52, $3B, $D6, $B3, $29, $E3, $2F, $84,
    $53, $D1, $00, $ED, $20, $FC, $B1, $5B, $6A, $CB, $BE, $39, $4A, $4C, $58, $CF,
    $D0, $EF, $AA, $FB, $43, $4D, $33, $85, $45, $F9, $02, $7F, $50, $3C, $9F, $A8,
    $51, $A3, $40, $8F, $92, $9D, $38, $F5, $BC, $B6, $DA, $21, $10, $FF, $F3, $D2,
    $CD, $0C, $13, $EC, $5F, $97, $44, $17, $C4, $A7, $7E, $3D, $64, $5D, $19, $73,
    $60, $81, $4F, $DC, $22, $2A, $90, $88, $46, $EE, $B8, $14, $DE, $5E, $0B, $DB,
    $E0, $32, $3A, $0A, $49, $06, $24, $5C, $C2, $D3, $AC, $62, $91, $95, $E4, $79,
    $E7, $C8, $37, $6D, $8D, $D5, $4E, $A9, $6C, $56, $F4, $EA, $65, $7A, $AE, $08,
    $BA, $78, $25, $2E, $1C, $A6, $B4, $C6, $E8, $DD, $74, $1F, $4B, $BD, $8B, $8A,
    $70, $3E, $B5, $66, $48, $03, $F6, $0E, $61, $35, $57, $B9, $86, $C1, $1D, $9E,
    $E1, $F8, $98, $11, $69, $D9, $8E, $94, $9B, $1E, $87, $E9, $CE, $55, $28, $DF,
    $8C, $A1, $89, $0D, $BF, $E6, $42, $68, $41, $99, $2D, $0F, $B0, $54, $BB, $16 );

  RSb: array[0..255] of DWORD = (
    $52, $09, $6A, $D5, $30, $36, $A5, $38, $BF, $40, $A3, $9E, $81, $F3, $D7, $FB,
    $7C, $E3, $39, $82, $9B, $2F, $FF, $87, $34, $8E, $43, $44, $C4, $DE, $E9, $CB,
    $54, $7B, $94, $32, $A6, $C2, $23, $3D, $EE, $4C, $95, $0B, $42, $FA, $C3, $4E,
    $08, $2E, $A1, $66, $28, $D9, $24, $B2, $76, $5B, $A2, $49, $6D, $8B, $D1, $25,
    $72, $F8, $F6, $64, $86, $68, $98, $16, $D4, $A4, $5C, $CC, $5D, $65, $B6, $92,
    $6C, $70, $48, $50, $FD, $ED, $B9, $DA, $5E, $15, $46, $57, $A7, $8D, $9D, $84,
    $90, $D8, $AB, $00, $8C, $BC, $D3, $0A, $F7, $E4, $58, $05, $B8, $B3, $45, $06,
    $D0, $2C, $1E, $8F, $CA, $3F, $0F, $02, $C1, $AF, $BD, $03, $01, $13, $8A, $6B,
    $3A, $91, $11, $41, $4F, $67, $DC, $EA, $97, $F2, $CF, $CE, $F0, $B4, $E6, $73,
    $96, $AC, $74, $22, $E7, $AD, $35, $85, $E2, $F9, $37, $E8, $1C, $75, $DF, $6E,
    $47, $F1, $1A, $71, $1D, $29, $C5, $89, $6F, $B7, $62, $0E, $AA, $18, $BE, $1B,
    $FC, $56, $3E, $4B, $C6, $D2, $79, $20, $9A, $DB, $C0, $FE, $78, $CD, $5A, $F4,
    $1F, $DD, $A8, $33, $88, $07, $C7, $31, $B1, $12, $10, $59, $27, $80, $EC, $5F,
    $60, $51, $7F, $A9, $19, $B5, $4A, $0D, $2D, $E5, $7A, $9F, $93, $C9, $9C, $EF,
    $A0, $E0, $3B, $4D, $AE, $2A, $F5, $B0, $C8, $EB, $BB, $3C, $83, $53, $99, $61,
    $17, $2B, $04, $7E, $BA, $77, $D6, $26, $E1, $69, $14, $63, $55, $21, $0C, $7D);

  RCON:array [0..9] of DWORD= (
    $01000000, $02000000, $04000000, $08000000, $10000000, $20000000, $40000000, $80000000, $1B000000, $36000000 );

  FT0: array[0..255] of DWORD = (
    $C66363A5, $F87C7C84, $EE777799, $F67B7B8D, $FFF2F20D, $D66B6BBD, $DE6F6FB1, $91C5C554,
    $60303050, $02010103, $CE6767A9, $562B2B7D, $E7FEFE19, $B5D7D762, $4DABABE6, $EC76769A,
    $8FCACA45, $1F82829D, $89C9C940, $FA7D7D87, $EFFAFA15, $B25959EB, $8E4747C9, $FBF0F00B,
    $41ADADEC, $B3D4D467, $5FA2A2FD, $45AFAFEA, $239C9CBF, $53A4A4F7, $E4727296, $9BC0C05B,
    $75B7B7C2, $E1FDFD1C, $3D9393AE, $4C26266A, $6C36365A, $7E3F3F41, $F5F7F702, $83CCCC4F,
    $6834345C, $51A5A5F4, $D1E5E534, $F9F1F108, $E2717193, $ABD8D873, $62313153, $2A15153F,
    $0804040C, $95C7C752, $46232365, $9DC3C35E, $30181828, $379696A1, $0A05050F, $2F9A9AB5,
    $0E070709, $24121236, $1B80809B, $DFE2E23D, $CDEBEB26, $4E272769, $7FB2B2CD, $EA75759F,
    $1209091B, $1D83839E, $582C2C74, $341A1A2E, $361B1B2D, $DC6E6EB2, $B45A5AEE, $5BA0A0FB,
    $A45252F6, $763B3B4D, $B7D6D661, $7DB3B3CE, $5229297B, $DDE3E33E, $5E2F2F71, $13848497,
    $A65353F5, $B9D1D168, $00000000, $C1EDED2C, $40202060, $E3FCFC1F, $79B1B1C8, $B65B5BED,
    $D46A6ABE, $8DCBCB46, $67BEBED9, $7239394B, $944A4ADE, $984C4CD4, $B05858E8, $85CFCF4A,
    $BBD0D06B, $C5EFEF2A, $4FAAAAE5, $EDFBFB16, $864343C5, $9A4D4DD7, $66333355, $11858594,
    $8A4545CF, $E9F9F910, $04020206, $FE7F7F81, $A05050F0, $783C3C44, $259F9FBA, $4BA8A8E3,
    $A25151F3, $5DA3A3FE, $804040C0, $058F8F8A, $3F9292AD, $219D9DBC, $70383848, $F1F5F504,
    $63BCBCDF, $77B6B6C1, $AFDADA75, $42212163, $20101030, $E5FFFF1A, $FDF3F30E, $BFD2D26D,
    $81CDCD4C, $180C0C14, $26131335, $C3ECEC2F, $BE5F5FE1, $359797A2, $884444CC, $2E171739,
    $93C4C457, $55A7A7F2, $FC7E7E82, $7A3D3D47, $C86464AC, $BA5D5DE7, $3219192B, $E6737395,
    $C06060A0, $19818198, $9E4F4FD1, $A3DCDC7F, $44222266, $542A2A7E, $3B9090AB, $0B888883,
    $8C4646CA, $C7EEEE29, $6BB8B8D3, $2814143C, $A7DEDE79, $BC5E5EE2, $160B0B1D, $ADDBDB76,
    $DBE0E03B, $64323256, $743A3A4E, $140A0A1E, $924949DB, $0C06060A, $4824246C, $B85C5CE4,
    $9FC2C25D, $BDD3D36E, $43ACACEF, $C46262A6, $399191A8, $319595A4, $D3E4E437, $F279798B,
    $D5E7E732, $8BC8C843, $6E373759, $DA6D6DB7, $018D8D8C, $B1D5D564, $9C4E4ED2, $49A9A9E0,
    $D86C6CB4, $AC5656FA, $F3F4F407, $CFEAEA25, $CA6565AF, $F47A7A8E, $47AEAEE9, $10080818,
    $6FBABAD5, $F0787888, $4A25256F, $5C2E2E72, $381C1C24, $57A6A6F1, $73B4B4C7, $97C6C651,
    $CBE8E823, $A1DDDD7C, $E874749C, $3E1F1F21, $964B4BDD, $61BDBDDC, $0D8B8B86, $0F8A8A85,
    $E0707090, $7C3E3E42, $71B5B5C4, $CC6666AA, $904848D8, $06030305, $F7F6F601, $1C0E0E12,
    $C26161A3, $6A35355F, $AE5757F9, $69B9B9D0, $17868691, $99C1C158, $3A1D1D27, $279E9EB9,
    $D9E1E138, $EBF8F813, $2B9898B3, $22111133, $D26969BB, $A9D9D970, $078E8E89, $339494A7,
    $2D9B9BB6, $3C1E1E22, $15878792, $C9E9E920, $87CECE49, $AA5555FF, $50282878, $A5DFDF7A,
    $038C8C8F, $59A1A1F8, $09898980, $1A0D0D17, $65BFBFDA, $D7E6E631, $844242C6, $D06868B8,
    $824141C3, $299999B0, $5A2D2D77, $1E0F0F11, $7BB0B0CB, $A85454FC, $6DBBBBD6, $2C16163A );

  FT1: array[0..255] of DWORD = (
    $A5C66363, $84F87C7C, $99EE7777, $8DF67B7B, $0DFFF2F2, $BDD66B6B, $B1DE6F6F, $5491C5C5,
    $50603030, $03020101, $A9CE6767, $7D562B2B, $19E7FEFE, $62B5D7D7, $E64DABAB, $9AEC7676,
    $458FCACA, $9D1F8282, $4089C9C9, $87FA7D7D, $15EFFAFA, $EBB25959, $C98E4747, $0BFBF0F0,
    $EC41ADAD, $67B3D4D4, $FD5FA2A2, $EA45AFAF, $BF239C9C, $F753A4A4, $96E47272, $5B9BC0C0,
    $C275B7B7, $1CE1FDFD, $AE3D9393, $6A4C2626, $5A6C3636, $417E3F3F, $02F5F7F7, $4F83CCCC,
    $5C683434, $F451A5A5, $34D1E5E5, $08F9F1F1, $93E27171, $73ABD8D8, $53623131, $3F2A1515,
    $0C080404, $5295C7C7, $65462323, $5E9DC3C3, $28301818, $A1379696, $0F0A0505, $B52F9A9A,
    $090E0707, $36241212, $9B1B8080, $3DDFE2E2, $26CDEBEB, $694E2727, $CD7FB2B2, $9FEA7575,
    $1B120909, $9E1D8383, $74582C2C, $2E341A1A, $2D361B1B, $B2DC6E6E, $EEB45A5A, $FB5BA0A0,
    $F6A45252, $4D763B3B, $61B7D6D6, $CE7DB3B3, $7B522929, $3EDDE3E3, $715E2F2F, $97138484,
    $F5A65353, $68B9D1D1, $00000000, $2CC1EDED, $60402020, $1FE3FCFC, $C879B1B1, $EDB65B5B,
    $BED46A6A, $468DCBCB, $D967BEBE, $4B723939, $DE944A4A, $D4984C4C, $E8B05858, $4A85CFCF,
    $6BBBD0D0, $2AC5EFEF, $E54FAAAA, $16EDFBFB, $C5864343, $D79A4D4D, $55663333, $94118585,
    $CF8A4545, $10E9F9F9, $06040202, $81FE7F7F, $F0A05050, $44783C3C, $BA259F9F, $E34BA8A8,
    $F3A25151, $FE5DA3A3, $C0804040, $8A058F8F, $AD3F9292, $BC219D9D, $48703838, $04F1F5F5,
    $DF63BCBC, $C177B6B6, $75AFDADA, $63422121, $30201010, $1AE5FFFF, $0EFDF3F3, $6DBFD2D2,
    $4C81CDCD, $14180C0C, $35261313, $2FC3ECEC, $E1BE5F5F, $A2359797, $CC884444, $392E1717,
    $5793C4C4, $F255A7A7, $82FC7E7E, $477A3D3D, $ACC86464, $E7BA5D5D, $2B321919, $95E67373,
    $A0C06060, $98198181, $D19E4F4F, $7FA3DCDC, $66442222, $7E542A2A, $AB3B9090, $830B8888,
    $CA8C4646, $29C7EEEE, $D36BB8B8, $3C281414, $79A7DEDE, $E2BC5E5E, $1D160B0B, $76ADDBDB,
    $3BDBE0E0, $56643232, $4E743A3A, $1E140A0A, $DB924949, $0A0C0606, $6C482424, $E4B85C5C,
    $5D9FC2C2, $6EBDD3D3, $EF43ACAC, $A6C46262, $A8399191, $A4319595, $37D3E4E4, $8BF27979,
    $32D5E7E7, $438BC8C8, $596E3737, $B7DA6D6D, $8C018D8D, $64B1D5D5, $D29C4E4E, $E049A9A9,
    $B4D86C6C, $FAAC5656, $07F3F4F4, $25CFEAEA, $AFCA6565, $8EF47A7A, $E947AEAE, $18100808,
    $D56FBABA, $88F07878, $6F4A2525, $725C2E2E, $24381C1C, $F157A6A6, $C773B4B4, $5197C6C6,
    $23CBE8E8, $7CA1DDDD, $9CE87474, $213E1F1F, $DD964B4B, $DC61BDBD, $860D8B8B, $850F8A8A,
    $90E07070, $427C3E3E, $C471B5B5, $AACC6666, $D8904848, $05060303, $01F7F6F6, $121C0E0E,
    $A3C26161, $5F6A3535, $F9AE5757, $D069B9B9, $91178686, $5899C1C1, $273A1D1D, $B9279E9E,
    $38D9E1E1, $13EBF8F8, $B32B9898, $33221111, $BBD26969, $70A9D9D9, $89078E8E, $A7339494,
    $B62D9B9B, $223C1E1E, $92158787, $20C9E9E9, $4987CECE, $FFAA5555, $78502828, $7AA5DFDF,
    $8F038C8C, $F859A1A1, $80098989, $171A0D0D, $DA65BFBF, $31D7E6E6, $C6844242, $B8D06868,
    $C3824141, $B0299999, $775A2D2D, $111E0F0F, $CB7BB0B0, $FCA85454, $D66DBBBB, $3A2C1616 );

  FT2: array[0..255] of DWORD = (
    $63A5C663, $7C84F87C, $7799EE77, $7B8DF67B, $F20DFFF2, $6BBDD66B, $6FB1DE6F, $C55491C5,
    $30506030, $01030201, $67A9CE67, $2B7D562B, $FE19E7FE, $D762B5D7, $ABE64DAB, $769AEC76,
    $CA458FCA, $829D1F82, $C94089C9, $7D87FA7D, $FA15EFFA, $59EBB259, $47C98E47, $F00BFBF0,
    $ADEC41AD, $D467B3D4, $A2FD5FA2, $AFEA45AF, $9CBF239C, $A4F753A4, $7296E472, $C05B9BC0,
    $B7C275B7, $FD1CE1FD, $93AE3D93, $266A4C26, $365A6C36, $3F417E3F, $F702F5F7, $CC4F83CC,
    $345C6834, $A5F451A5, $E534D1E5, $F108F9F1, $7193E271, $D873ABD8, $31536231, $153F2A15,
    $040C0804, $C75295C7, $23654623, $C35E9DC3, $18283018, $96A13796, $050F0A05, $9AB52F9A,
    $07090E07, $12362412, $809B1B80, $E23DDFE2, $EB26CDEB, $27694E27, $B2CD7FB2, $759FEA75,
    $091B1209, $839E1D83, $2C74582C, $1A2E341A, $1B2D361B, $6EB2DC6E, $5AEEB45A, $A0FB5BA0,
    $52F6A452, $3B4D763B, $D661B7D6, $B3CE7DB3, $297B5229, $E33EDDE3, $2F715E2F, $84971384,
    $53F5A653, $D168B9D1, $00000000, $ED2CC1ED, $20604020, $FC1FE3FC, $B1C879B1, $5BEDB65B,
    $6ABED46A, $CB468DCB, $BED967BE, $394B7239, $4ADE944A, $4CD4984C, $58E8B058, $CF4A85CF,
    $D06BBBD0, $EF2AC5EF, $AAE54FAA, $FB16EDFB, $43C58643, $4DD79A4D, $33556633, $85941185,
    $45CF8A45, $F910E9F9, $02060402, $7F81FE7F, $50F0A050, $3C44783C, $9FBA259F, $A8E34BA8,
    $51F3A251, $A3FE5DA3, $40C08040, $8F8A058F, $92AD3F92, $9DBC219D, $38487038, $F504F1F5,
    $BCDF63BC, $B6C177B6, $DA75AFDA, $21634221, $10302010, $FF1AE5FF, $F30EFDF3, $D26DBFD2,
    $CD4C81CD, $0C14180C, $13352613, $EC2FC3EC, $5FE1BE5F, $97A23597, $44CC8844, $17392E17,
    $C45793C4, $A7F255A7, $7E82FC7E, $3D477A3D, $64ACC864, $5DE7BA5D, $192B3219, $7395E673,
    $60A0C060, $81981981, $4FD19E4F, $DC7FA3DC, $22664422, $2A7E542A, $90AB3B90, $88830B88,
    $46CA8C46, $EE29C7EE, $B8D36BB8, $143C2814, $DE79A7DE, $5EE2BC5E, $0B1D160B, $DB76ADDB,
    $E03BDBE0, $32566432, $3A4E743A, $0A1E140A, $49DB9249, $060A0C06, $246C4824, $5CE4B85C,
    $C25D9FC2, $D36EBDD3, $ACEF43AC, $62A6C462, $91A83991, $95A43195, $E437D3E4, $798BF279,
    $E732D5E7, $C8438BC8, $37596E37, $6DB7DA6D, $8D8C018D, $D564B1D5, $4ED29C4E, $A9E049A9,
    $6CB4D86C, $56FAAC56, $F407F3F4, $EA25CFEA, $65AFCA65, $7A8EF47A, $AEE947AE, $08181008,
    $BAD56FBA, $7888F078, $256F4A25, $2E725C2E, $1C24381C, $A6F157A6, $B4C773B4, $C65197C6,
    $E823CBE8, $DD7CA1DD, $749CE874, $1F213E1F, $4BDD964B, $BDDC61BD, $8B860D8B, $8A850F8A,
    $7090E070, $3E427C3E, $B5C471B5, $66AACC66, $48D89048, $03050603, $F601F7F6, $0E121C0E,
    $61A3C261, $355F6A35, $57F9AE57, $B9D069B9, $86911786, $C15899C1, $1D273A1D, $9EB9279E,
    $E138D9E1, $F813EBF8, $98B32B98, $11332211, $69BBD269, $D970A9D9, $8E89078E, $94A73394,
    $9BB62D9B, $1E223C1E, $87921587, $E920C9E9, $CE4987CE, $55FFAA55, $28785028, $DF7AA5DF,
    $8C8F038C, $A1F859A1, $89800989, $0D171A0D, $BFDA65BF, $E631D7E6, $42C68442, $68B8D068,
    $41C38241, $99B02999, $2D775A2D, $0F111E0F, $B0CB7BB0, $54FCA854, $BBD66DBB, $163A2C16 );


  FT3: array[0..255] of DWORD = (
    $6363A5C6, $7C7C84F8, $777799EE, $7B7B8DF6, $F2F20DFF, $6B6BBDD6, $6F6FB1DE, $C5C55491, 
    $30305060, $01010302, $6767A9CE, $2B2B7D56, $FEFE19E7, $D7D762B5, $ABABE64D, $76769AEC,
    $CACA458F, $82829D1F, $C9C94089, $7D7D87FA, $FAFA15EF, $5959EBB2, $4747C98E, $F0F00BFB, 
    $ADADEC41, $D4D467B3, $A2A2FD5F, $AFAFEA45, $9C9CBF23, $A4A4F753, $727296E4, $C0C05B9B, 
    $B7B7C275, $FDFD1CE1, $9393AE3D, $26266A4C, $36365A6C, $3F3F417E, $F7F702F5, $CCCC4F83, 
    $34345C68, $A5A5F451, $E5E534D1, $F1F108F9, $717193E2, $D8D873AB, $31315362, $15153F2A, 
    $04040C08, $C7C75295, $23236546, $C3C35E9D, $18182830, $9696A137, $05050F0A, $9A9AB52F, 
    $0707090E, $12123624, $80809B1B, $E2E23DDF, $EBEB26CD, $2727694E, $B2B2CD7F, $75759FEA, 
    $09091B12, $83839E1D, $2C2C7458, $1A1A2E34, $1B1B2D36, $6E6EB2DC, $5A5AEEB4, $A0A0FB5B,
    $5252F6A4, $3B3B4D76, $D6D661B7, $B3B3CE7D, $29297B52, $E3E33EDD, $2F2F715E, $84849713, 
    $5353F5A6, $D1D168B9, $00000000, $EDED2CC1, $20206040, $FCFC1FE3, $B1B1C879, $5B5BEDB6, 
    $6A6ABED4, $CBCB468D, $BEBED967, $39394B72, $4A4ADE94, $4C4CD498, $5858E8B0, $CFCF4A85, 
    $D0D06BBB, $EFEF2AC5, $AAAAE54F, $FBFB16ED, $4343C586, $4D4DD79A, $33335566, $85859411,
    $4545CF8A, $F9F910E9, $02020604, $7F7F81FE, $5050F0A0, $3C3C4478, $9F9FBA25, $A8A8E34B, 
    $5151F3A2, $A3A3FE5D, $4040C080, $8F8F8A05, $9292AD3F, $9D9DBC21, $38384870, $F5F504F1, 
    $BCBCDF63, $B6B6C177, $DADA75AF, $21216342, $10103020, $FFFF1AE5, $F3F30EFD, $D2D26DBF, 
    $CDCD4C81, $0C0C1418, $13133526, $ECEC2FC3, $5F5FE1BE, $9797A235, $4444CC88, $1717392E, 
    $C4C45793, $A7A7F255, $7E7E82FC, $3D3D477A, $6464ACC8, $5D5DE7BA, $19192B32, $737395E6, 
    $6060A0C0, $81819819, $4F4FD19E, $DCDC7FA3, $22226644, $2A2A7E54, $9090AB3B, $8888830B,
    $4646CA8C, $EEEE29C7, $B8B8D36B, $14143C28, $DEDE79A7, $5E5EE2BC, $0B0B1D16, $DBDB76AD, 
    $E0E03BDB, $32325664, $3A3A4E74, $0A0A1E14, $4949DB92, $06060A0C, $24246C48, $5C5CE4B8, 
    $C2C25D9F, $D3D36EBD, $ACACEF43, $6262A6C4, $9191A839, $9595A431, $E4E437D3, $79798BF2, 
    $E7E732D5, $C8C8438B, $3737596E, $6D6DB7DA, $8D8D8C01, $D5D564B1, $4E4ED29C, $A9A9E049,
    $6C6CB4D8, $5656FAAC, $F4F407F3, $EAEA25CF, $6565AFCA, $7A7A8EF4, $AEAEE947, $08081810, 
    $BABAD56F, $787888F0, $25256F4A, $2E2E725C, $1C1C2438, $A6A6F157, $B4B4C773, $C6C65197, 
    $E8E823CB, $DDDD7CA1, $74749CE8, $1F1F213E, $4B4BDD96, $BDBDDC61, $8B8B860D, $8A8A850F,
    $707090E0, $3E3E427C, $B5B5C471, $6666AACC, $4848D890, $03030506, $F6F601F7, $0E0E121C,
    $6161A3C2, $35355F6A, $5757F9AE, $B9B9D069, $86869117, $C1C15899, $1D1D273A, $9E9EB927,
    $E1E138D9, $F8F813EB, $9898B32B, $11113322, $6969BBD2, $D9D970A9, $8E8E8907, $9494A733,
    $9B9BB62D, $1E1E223C, $87879215, $E9E920C9, $CECE4987, $5555FFAA, $28287850, $DFDF7AA5,
    $8C8C8F03, $A1A1F859, $89898009, $0D0D171A, $BFBFDA65, $E6E631D7, $4242C684, $6868B8D0,
    $4141C382, $9999B029, $2D2D775A, $0F0F111E, $B0B0CB7B, $5454FCA8, $BBBBD66D, $16163A2C );


  RT0: array[0..255] of DWORD = (
    $51F4A750, $7E416553, $1A17A4C3, $3A275E96, $3BAB6BCB, $1F9D45F1, $ACFA58AB, $4BE30393,
    $2030FA55, $AD766DF6, $88CC7691, $F5024C25, $4FE5D7FC, $C52ACBD7, $26354480, $B562A38F,
    $DEB15A49, $25BA1B67, $45EA0E98, $5DFEC0E1, $C32F7502, $814CF012, $8D4697A3, $6BD3F9C6,
    $038F5FE7, $15929C95, $BF6D7AEB, $955259DA, $D4BE832D, $587421D3, $49E06929, $8EC9C844,
    $75C2896A, $F48E7978, $99583E6B, $27B971DD, $BEE14FB6, $F088AD17, $C920AC66, $7DCE3AB4,
    $63DF4A18, $E51A3182, $97513360, $62537F45, $B16477E0, $BB6BAE84, $FE81A01C, $F9082B94,
    $70486858, $8F45FD19, $94DE6C87, $527BF8B7, $AB73D323, $724B02E2, $E31F8F57, $6655AB2A,
    $B2EB2807, $2FB5C203, $86C57B9A, $D33708A5, $302887F2, $23BFA5B2, $02036ABA, $ED16825C,
    $8ACF1C2B, $A779B492, $F307F2F0, $4E69E2A1, $65DAF4CD, $0605BED5, $D134621F, $C4A6FE8A,
    $342E539D, $A2F355A0, $058AE132, $A4F6EB75, $0B83EC39, $4060EFAA, $5E719F06, $BD6E1051,
    $3E218AF9, $96DD063D, $DD3E05AE, $4DE6BD46, $91548DB5, $71C45D05, $0406D46F, $605015FF,
    $1998FB24, $D6BDE997, $894043CC, $67D99E77, $B0E842BD, $07898B88, $E7195B38, $79C8EEDB,
    $A17C0A47, $7C420FE9, $F8841EC9, $00000000, $09808683, $322BED48, $1E1170AC, $6C5A724E,
    $FD0EFFFB, $0F853856, $3DAED51E, $362D3927, $0A0FD964, $685CA621, $9B5B54D1, $24362E3A,
    $0C0A67B1, $9357E70F, $B4EE96D2, $1B9B919E, $80C0C54F, $61DC20A2, $5A774B69, $1C121A16,
    $E293BA0A, $C0A02AE5, $3C22E043, $121B171D, $0E090D0B, $F28BC7AD, $2DB6A8B9, $141EA9C8,
    $57F11985, $AF75074C, $EE99DDBB, $A37F60FD, $F701269F, $5C72F5BC, $44663BC5, $5BFB7E34,
    $8B432976, $CB23C6DC, $B6EDFC68, $B8E4F163, $D731DCCA, $42638510, $13972240, $84C61120,
    $854A247D, $D2BB3DF8, $AEF93211, $C729A16D, $1D9E2F4B, $DCB230F3, $0D8652EC, $77C1E3D0,
    $2BB3166C, $A970B999, $119448FA, $47E96422, $A8FC8CC4, $A0F03F1A, $567D2CD8, $223390EF,
    $87494EC7, $D938D1C1, $8CCAA2FE, $98D40B36, $A6F581CF, $A57ADE28, $DAB78E26, $3FADBFA4,
    $2C3A9DE4, $5078920D, $6A5FCC9B, $547E4662, $F68D13C2, $90D8B8E8, $2E39F75E, $82C3AFF5,
    $9F5D80BE, $69D0937C, $6FD52DA9, $CF2512B3, $C8AC993B, $10187DA7, $E89C636E, $DB3BBB7B,
    $CD267809, $6E5918F4, $EC9AB701, $834F9AA8, $E6956E65, $AAFFE67E, $21BCCF08, $EF15E8E6,
    $BAE79BD9, $4A6F36CE, $EA9F09D4, $29B07CD6, $31A4B2AF, $2A3F2331, $C6A59430, $35A266C0,
    $744EBC37, $FC82CAA6, $E090D0B0, $33A7D815, $F104984A, $41ECDAF7, $7FCD500E, $1791F62F,
    $764DD68D, $43EFB04D, $CCAA4D54, $E49604DF, $9ED1B5E3, $4C6A881B, $C12C1FB8, $4665517F,
    $9D5EEA04, $018C355D, $FA877473, $FB0B412E, $B3671D5A, $92DBD252, $E9105633, $6DD64713,
    $9AD7618C, $37A10C7A, $59F8148E, $EB133C89, $CEA927EE, $B761C935, $E11CE5ED, $7A47B13C,
    $9CD2DF59, $55F2733F, $1814CE79, $73C737BF, $53F7CDEA, $5FFDAA5B, $DF3D6F14, $7844DB86,
    $CAAFF381, $B968C43E, $3824342C, $C2A3405F, $161DC372, $BCE2250C, $283C498B, $FF0D9541,
    $39A80171, $080CB3DE, $D8B4E49C, $6456C190, $7BCB8461, $D532B670, $486C5C74, $D0B85742 );


  RT1: array[0..255] of DWORD = (
    $5051F4A7, $537E4165, $C31A17A4, $963A275E, $CB3BAB6B, $F11F9D45, $ABACFA58, $934BE303,
    $552030FA, $F6AD766D, $9188CC76, $25F5024C, $FC4FE5D7, $D7C52ACB, $80263544, $8FB562A3, 
    $49DEB15A, $6725BA1B, $9845EA0E, $E15DFEC0, $02C32F75, $12814CF0, $A38D4697, $C66BD3F9,
    $E7038F5F, $9515929C, $EBBF6D7A, $DA955259, $2DD4BE83, $D3587421, $2949E069, $448EC9C8, 
    $6A75C289, $78F48E79, $6B99583E, $DD27B971, $B6BEE14F, $17F088AD, $66C920AC, $B47DCE3A,
    $1863DF4A, $82E51A31, $60975133, $4562537F, $E0B16477, $84BB6BAE, $1CFE81A0, $94F9082B, 
    $58704868, $198F45FD, $8794DE6C, $B7527BF8, $23AB73D3, $E2724B02, $57E31F8F, $2A6655AB, 
    $07B2EB28, $032FB5C2, $9A86C57B, $A5D33708, $F2302887, $B223BFA5, $BA02036A, $5CED1682, 
    $2B8ACF1C, $92A779B4, $F0F307F2, $A14E69E2, $CD65DAF4, $D50605BE, $1FD13462, $8AC4A6FE, 
    $9D342E53, $A0A2F355, $32058AE1, $75A4F6EB, $390B83EC, $AA4060EF, $065E719F, $51BD6E10, 
    $F93E218A, $3D96DD06, $AEDD3E05, $464DE6BD, $B591548D, $0571C45D, $6F0406D4, $FF605015, 
    $241998FB, $97D6BDE9, $CC894043, $7767D99E, $BDB0E842, $8807898B, $38E7195B, $DB79C8EE, 
    $47A17C0A, $E97C420F, $C9F8841E, $00000000, $83098086, $48322BED, $AC1E1170, $4E6C5A72, 
    $FBFD0EFF, $560F8538, $1E3DAED5, $27362D39, $640A0FD9, $21685CA6, $D19B5B54, $3A24362E, 
    $B10C0A67, $0F9357E7, $D2B4EE96, $9E1B9B91, $4F80C0C5, $A261DC20, $695A774B, $161C121A, 
    $0AE293BA, $E5C0A02A, $433C22E0, $1D121B17, $0B0E090D, $ADF28BC7, $B92DB6A8, $C8141EA9, 
    $8557F119, $4CAF7507, $BBEE99DD, $FDA37F60, $9FF70126, $BC5C72F5, $C544663B, $345BFB7E, 
    $768B4329, $DCCB23C6, $68B6EDFC, $63B8E4F1, $CAD731DC, $10426385, $40139722, $2084C611, 
    $7D854A24, $F8D2BB3D, $11AEF932, $6DC729A1, $4B1D9E2F, $F3DCB230, $EC0D8652, $D077C1E3,
    $6C2BB316, $99A970B9, $FA119448, $2247E964, $C4A8FC8C, $1AA0F03F, $D8567D2C, $EF223390, 
    $C787494E, $C1D938D1, $FE8CCAA2, $3698D40B, $CFA6F581, $28A57ADE, $26DAB78E, $A43FADBF, 
    $E42C3A9D, $0D507892, $9B6A5FCC, $62547E46, $C2F68D13, $E890D8B8, $5E2E39F7, $F582C3AF, 
    $BE9F5D80, $7C69D093, $A96FD52D, $B3CF2512, $3BC8AC99, $A710187D, $6EE89C63, $7BDB3BBB, 
    $09CD2678, $F46E5918, $01EC9AB7, $A8834F9A, $65E6956E, $7EAAFFE6, $0821BCCF, $E6EF15E8,
    $D9BAE79B, $CE4A6F36, $D4EA9F09, $D629B07C, $AF31A4B2, $312A3F23, $30C6A594, $C035A266,
    $37744EBC, $A6FC82CA, $B0E090D0, $1533A7D8, $4AF10498, $F741ECDA, $0E7FCD50, $2F1791F6,
    $8D764DD6, $4D43EFB0, $54CCAA4D, $DFE49604, $E39ED1B5, $1B4C6A88, $B8C12C1F, $7F466551,
    $049D5EEA, $5D018C35, $73FA8774, $2EFB0B41, $5AB3671D, $5292DBD2, $33E91056, $136DD647,
    $8C9AD761, $7A37A10C, $8E59F814, $89EB133C, $EECEA927, $35B761C9, $EDE11CE5, $3C7A47B1,
    $599CD2DF, $3F55F273, $791814CE, $BF73C737, $EA53F7CD, $5B5FFDAA, $14DF3D6F, $867844DB,
    $81CAAFF3, $3EB968C4, $2C382434, $5FC2A340, $72161DC3, $0CBCE225, $8B283C49, $41FF0D95,
    $7139A801, $DE080CB3, $9CD8B4E4, $906456C1, $617BCB84, $70D532B6, $74486C5C, $42D0B857 );




  RT2: array[0..255] of DWORD =(
    $A75051F4, $65537E41, $A4C31A17, $5E963A27, $6BCB3BAB, $45F11F9D, $58ABACFA, $03934BE3,
    $FA552030, $6DF6AD76, $769188CC, $4C25F502, $D7FC4FE5, $CBD7C52A, $44802635, $A38FB562,
    $5A49DEB1, $1B6725BA, $0E9845EA, $C0E15DFE, $7502C32F, $F012814C, $97A38D46, $F9C66BD3,
    $5FE7038F, $9C951592, $7AEBBF6D, $59DA9552, $832DD4BE, $21D35874, $692949E0, $C8448EC9,
    $896A75C2, $7978F48E, $3E6B9958, $71DD27B9, $4FB6BEE1, $AD17F088, $AC66C920, $3AB47DCE,
    $4A1863DF, $3182E51A, $33609751, $7F456253, $77E0B164, $AE84BB6B, $A01CFE81, $2B94F908,
    $68587048, $FD198F45, $6C8794DE, $F8B7527B, $D323AB73, $02E2724B, $8F57E31F, $AB2A6655,
    $2807B2EB, $C2032FB5, $7B9A86C5, $08A5D337, $87F23028, $A5B223BF, $6ABA0203, $825CED16,
    $1C2B8ACF, $B492A779, $F2F0F307, $E2A14E69, $F4CD65DA, $BED50605, $621FD134, $FE8AC4A6,
    $539D342E, $55A0A2F3, $E132058A, $EB75A4F6, $EC390B83, $EFAA4060, $9F065E71, $1051BD6E,
    $8AF93E21, $063D96DD, $05AEDD3E, $BD464DE6, $8DB59154, $5D0571C4, $D46F0406, $15FF6050,
    $FB241998, $E997D6BD, $43CC8940, $9E7767D9, $42BDB0E8, $8B880789, $5B38E719, $EEDB79C8,
    $0A47A17C, $0FE97C42, $1EC9F884, $00000000, $86830980, $ED48322B, $70AC1E11, $724E6C5A,
    $FFFBFD0E, $38560F85, $D51E3DAE, $3927362D, $D9640A0F, $A621685C, $54D19B5B, $2E3A2436,
    $67B10C0A, $E70F9357, $96D2B4EE, $919E1B9B, $C54F80C0, $20A261DC, $4B695A77, $1A161C12,
    $BA0AE293, $2AE5C0A0, $E0433C22, $171D121B, $0D0B0E09, $C7ADF28B, $A8B92DB6, $A9C8141E,
    $198557F1, $074CAF75, $DDBBEE99, $60FDA37F, $269FF701, $F5BC5C72, $3BC54466, $7E345BFB,
    $29768B43, $C6DCCB23, $FC68B6ED, $F163B8E4, $DCCAD731, $85104263, $22401397, $112084C6,
    $247D854A, $3DF8D2BB, $3211AEF9, $A16DC729, $2F4B1D9E, $30F3DCB2, $52EC0D86, $E3D077C1,
    $166C2BB3, $B999A970, $48FA1194, $642247E9, $8CC4A8FC, $3F1AA0F0, $2CD8567D, $90EF2233,
    $4EC78749, $D1C1D938, $A2FE8CCA, $0B3698D4, $81CFA6F5, $DE28A57A, $8E26DAB7, $BFA43FAD,
    $9DE42C3A, $920D5078, $CC9B6A5F, $4662547E, $13C2F68D, $B8E890D8, $F75E2E39, $AFF582C3,
    $80BE9F5D, $937C69D0, $2DA96FD5, $12B3CF25, $993BC8AC, $7DA71018, $636EE89C, $BB7BDB3B,
    $7809CD26, $18F46E59, $B701EC9A, $9AA8834F, $6E65E695, $E67EAAFF, $CF0821BC, $E8E6EF15,
    $9BD9BAE7, $36CE4A6F, $09D4EA9F, $7CD629B0, $B2AF31A4, $23312A3F, $9430C6A5, $66C035A2,
    $BC37744E, $CAA6FC82, $D0B0E090, $D81533A7, $984AF104, $DAF741EC, $500E7FCD, $F62F1791,
    $D68D764D, $B04D43EF, $4D54CCAA, $04DFE496, $B5E39ED1, $881B4C6A, $1FB8C12C, $517F4665,
    $EA049D5E, $355D018C, $7473FA87, $412EFB0B, $1D5AB367, $D25292DB, $5633E910, $47136DD6,
    $618C9AD7, $0C7A37A1, $148E59F8, $3C89EB13, $27EECEA9, $C935B761, $E5EDE11C, $B13C7A47,
    $DF599CD2, $733F55F2, $CE791814, $37BF73C7, $CDEA53F7, $AA5B5FFD, $6F14DF3D, $DB867844,
    $F381CAAF, $C43EB968, $342C3824, $405FC2A3, $C372161D, $250CBCE2, $498B283C, $9541FF0D,
    $017139A8, $B3DE080C, $E49CD8B4, $C1906456, $84617BCB, $B670D532, $5C74486C, $5742D0B8 );




  RT3: array[0..255] of DWORD = (
    $F4A75051, $4165537E, $17A4C31A, $275E963A, $AB6BCB3B, $9D45F11F, $FA58ABAC, $E303934B,
    $30FA5520, $766DF6AD, $CC769188, $024C25F5, $E5D7FC4F, $2ACBD7C5, $35448026, $62A38FB5, 
    $B15A49DE, $BA1B6725, $EA0E9845, $FEC0E15D, $2F7502C3, $4CF01281, $4697A38D, $D3F9C66B,
    $8F5FE703, $929C9515, $6D7AEBBF, $5259DA95, $BE832DD4, $7421D358, $E0692949, $C9C8448E,
    $C2896A75, $8E7978F4, $583E6B99, $B971DD27, $E14FB6BE, $88AD17F0, $20AC66C9, $CE3AB47D, 
    $DF4A1863, $1A3182E5, $51336097, $537F4562, $6477E0B1, $6BAE84BB, $81A01CFE, $082B94F9, 
    $48685870, $45FD198F, $DE6C8794, $7BF8B752, $73D323AB, $4B02E272, $1F8F57E3, $55AB2A66, 
    $EB2807B2, $B5C2032F, $C57B9A86, $3708A5D3, $2887F230, $BFA5B223, $036ABA02, $16825CED, 
    $CF1C2B8A, $79B492A7, $07F2F0F3, $69E2A14E, $DAF4CD65, $05BED506, $34621FD1, $A6FE8AC4, 
    $2E539D34, $F355A0A2, $8AE13205, $F6EB75A4, $83EC390B, $60EFAA40, $719F065E, $6E1051BD,
    $218AF93E, $DD063D96, $3E05AEDD, $E6BD464D, $548DB591, $C45D0571, $06D46F04, $5015FF60, 
    $98FB2419, $BDE997D6, $4043CC89, $D99E7767, $E842BDB0, $898B8807, $195B38E7, $C8EEDB79, 
    $7C0A47A1, $420FE97C, $841EC9F8, $00000000, $80868309, $2BED4832, $1170AC1E, $5A724E6C,
    $0EFFFBFD, $8538560F, $AED51E3D, $2D392736, $0FD9640A, $5CA62168, $5B54D19B, $362E3A24,
    $0A67B10C, $57E70F93, $EE96D2B4, $9B919E1B, $C0C54F80, $DC20A261, $774B695A, $121A161C, 
    $93BA0AE2, $A02AE5C0, $22E0433C, $1B171D12, $090D0B0E, $8BC7ADF2, $B6A8B92D, $1EA9C814, 
    $F1198557, $75074CAF, $99DDBBEE, $7F60FDA3, $01269FF7, $72F5BC5C, $663BC544, $FB7E345B, 
    $4329768B, $23C6DCCB, $EDFC68B6, $E4F163B8, $31DCCAD7, $63851042, $97224013, $C6112084,
    $4A247D85, $BB3DF8D2, $F93211AE, $29A16DC7, $9E2F4B1D, $B230F3DC, $8652EC0D, $C1E3D077, 
    $B3166C2B, $70B999A9, $9448FA11, $E9642247, $FC8CC4A8, $F03F1AA0, $7D2CD856, $3390EF22, 
    $494EC787, $38D1C1D9, $CAA2FE8C, $D40B3698, $F581CFA6, $7ADE28A5, $B78E26DA, $ADBFA43F,
    $3A9DE42C, $78920D50, $5FCC9B6A, $7E466254, $8D13C2F6, $D8B8E890, $39F75E2E, $C3AFF582, 
    $5D80BE9F, $D0937C69, $D52DA96F, $2512B3CF, $AC993BC8, $187DA710, $9C636EE8, $3BBB7BDB, 
    $267809CD, $5918F46E, $9AB701EC, $4F9AA883, $956E65E6, $FFE67EAA, $BCCF0821, $15E8E6EF, 
    $E79BD9BA, $6F36CE4A, $9F09D4EA, $B07CD629, $A4B2AF31, $3F23312A, $A59430C6, $A266C035,
    $4EBC3774, $82CAA6FC, $90D0B0E0, $A7D81533, $04984AF1, $ECDAF741, $CD500E7F, $91F62F17,
    $4DD68D76, $EFB04D43, $AA4D54CC, $9604DFE4, $D1B5E39E, $6A881B4C, $2C1FB8C1, $65517F46,
    $5EEA049D, $8C355D01, $877473FA, $0B412EFB, $671D5AB3, $DBD25292, $105633E9, $D647136D,
    $D7618C9A, $A10C7A37, $F8148E59, $133C89EB, $A927EECE, $61C935B7, $1CE5EDE1, $47B13C7A,
    $D2DF599C, $F2733F55, $14CE7918, $C737BF73, $F7CDEA53, $FDAA5B5F, $3D6F14DF, $44DB8678,
    $AFF381CA, $68C43EB9, $24342C38, $A3405FC2, $1DC37216, $E2250CBC, $3C498B28, $0D9541FF,
    $A8017139, $0CB3DE08, $B4E49CD8, $56C19064, $CB84617B, $32B670D5, $6C5C7448, $B85742D0 );





type
  TMD5Int16 = array[0..15] of DWORD;



function CalcAESSize ( Encryption:TPDFSecurityState;Size: Integer): Integer;
var
  K:Integer;
begin
  if Encryption < ss128AES then
    result := Size
  else
  begin
    K :=  Size and $f;
    if K > 0 then
      K := 16 - K
    else
      K := 16;
    Result := Size + 16 + K;
  end;
end;

function StringToHash(HashClass:THashClass;Str:AnsiString):AnsiString;
var
  Hash: THash;
begin
  Hash := HashClass.Create;
  try
    if Str <> '' then
      Hash.Update(Str[1],Length(Str));
    Hash.Final;
    Result := DataToHex(Hash.Digest,Hash.HashSize);
  finally
    Hash.Free;
  end;
end;


procedure DataToHash(HashClass:THashClass;Input: Pointer; InputLen: Integer; const Digest);
var
  Hash:TMD5Hash;
begin
  Hash := TMD5Hash.Create;
  try
    Hash.Update(Input^, InputLen);
    Hash.Finish(@Digest);
  finally
    Hash.Free;
  end;
end;

function OIDtoHashClass(OID:TOIDs):THashClass;
begin
  case OID of
    OID_md2: Result := TMD2Hash;
    OID_md4: Result := TMD4Hash;
    OID_md5: Result := TMD5Hash;
    OID_sha1: Result := TSHA1Hash;
    OID_sha256: Result := TSHA256Hash;
  else
    Result := nil;
  end;
end;

{ TMD2Hash }

const
  PI_SUBST: array[0..255] of Byte = (
    41, 46, 67, 201, 162, 216, 124, 1, 61, 54, 84, 161, 236, 240, 6,
    19, 98, 167, 5, 243, 192, 199, 115, 140, 152, 147, 43, 217, 188,
    76, 130, 202, 30, 155, 87, 60, 253, 212, 224, 22, 103, 66, 111, 24,
    138, 23, 229, 18, 190, 78, 196, 214, 218, 158, 222, 73, 160, 251,
    245, 142, 187, 47, 238, 122, 169, 104, 121, 145, 21, 178, 7, 63,
    148, 194, 16, 137, 11, 34, 95, 33, 128, 127, 93, 154, 90, 144, 50,
    39, 53, 62, 204, 231, 191, 247, 151, 3, 255, 25, 48, 179, 72, 165,
    181, 209, 215, 94, 146, 42, 172, 86, 170, 198, 79, 184, 56, 210,
    150, 164, 125, 182, 118, 252, 107, 226, 156, 116, 4, 241, 69, 157,
    112, 89, 100, 113, 135, 32, 134, 91, 207, 101, 230, 45, 168, 2, 27,
    96, 37, 173, 174, 176, 185, 246, 28, 70, 97, 105, 52, 64, 126, 15,
    85, 71, 163, 35, 221, 81, 175, 58, 195, 92, 249, 206, 186, 197,
    234, 38, 44, 83, 13, 110, 133, 40, 132, 9, 211, 223, 205, 244, 65,
    129, 77, 82, 106, 220, 55, 200, 108, 193, 171, 250, 36, 225, 123,
    8, 12, 189, 177, 74, 120, 136, 149, 139, 227, 99, 232, 109, 233,
    203, 213, 254, 59, 0, 29, 57, 242, 239, 183, 14, 102, 88, 208, 228,
    166, 119, 114, 248, 235, 117, 75, 10, 49, 68, 80, 180, 143, 237,
    31, 26, 219, 153, 141, 51, 159, 17, 131, 20
  );

procedure TMD2Hash.Final;
var
  i, padlen: LongWord;
begin
  padlen  := 16 - Fi;
  for i := 0 to padlen - 1 do
    UpdateB(padlen);
  for i := 0 to 15 do
    UpdateB(FC[i]);
  move(FD,FDigest,16);
end;

function TMD2Hash.GetDigest: PByteArray;
begin
  Result := @FDigest;
end;

class function TMD2Hash.HashSize: Cardinal;
begin
  Result := 64;
end;

procedure TMD2Hash.Init;
begin
  FillChar(FD, 16, 0);
  FillChar(FC, 16, 0);
  Fi := 0;
  FL := 0;
end;

procedure TMD2Hash.Update(const ChkBuf; Len: Cardinal);
var
  i: Cardinal;
  Src: PByteArray;
begin
  Src := @ChkBuf;
  for i := 0 to Len - 1 do
    UpdateB(Src[i]);
end;

procedure TMD2Hash.UpdateB(c: Byte);
var
  i, j, t: Byte;
  p: PByte;
begin
  i := Fi;
  FD[16 + i] := c;
  FD[32 + i] := c xor FD[i];
  FC[i] := FC[i] xor PI_SUBST[$ff and (c xor FL)];
  FL := FC[i];
  Fi := (i + 1) and 15;
  i := Fi;
  if (i = 0) then
  begin
    t := 0;
    for j := 0 to 17 do
    begin
      p := @FD;
      for i := 0 to 7 do
      begin
        p^ := p^ xor PI_SUBST[t]; t := p^; Inc(p);
        p^ := p^ xor PI_SUBST[t]; t := p^; Inc(p);
        p^ := p^ xor PI_SUBST[t]; t := p^; Inc(p);
        p^ := p^ xor PI_SUBST[t]; t := p^; Inc(p);
        p^ := p^ xor PI_SUBST[t]; t := p^; Inc(p);
        p^ := p^ xor PI_SUBST[t]; t := p^; Inc(p);
      end;
      t := t + j;
    end;
  end;
end;

{ TSHA1Hash }


function TSHA1Hash.GetDigest: PByteArray;
begin
  Result := @FDigest;
end;

class function TSHA1Hash.HashSize: Cardinal;
begin
  Result := 20;
end;

procedure TSHA1Hash.Init;
begin
  CA := $67452301;
  CB := $efcdab89;
  CC := $98badcfe;
  CD := $10325476;
  CE := $c3d2e1f0;
  Size := 0;
  BufSize := 0;
  FillChar(Buffer,sizeOf(Buffer),0);
end;

procedure TSHA1Hash.Transform(Chunk:Pointer);
const
  K1 = $5A827999;
  K2 = $6ED9EBA1;
  K3 = $8F1BBCDC;
  K4 = $CA62C1D6;
var
  I: Integer;
  temp, A, B, C, D, E: DWORD;
  PD:^DWORD;
begin
  A := CA;
  B := CB;
  C := CC;
  D := CD;
  E := CE;

  PD := Chunk;
  for I := 0 to 15 do
  begin
    W[I] := byteSwap(PD^);
    inc(PD);
  end;
  for I := 16 to 79 do
  begin
    temp := W[I - 3] xor W[I - 8] xor W[I - 14]
      xor W[I - 16];
    W[I] := (temp shl 1) xor (temp shr 31);
  end;

  for I := 0 to 19 do
  begin
    temp := ((A shl 5) or (A shr 27)) + E + W[I] + ((B and C) or (not B and D)) + K1;
    E := D;
    D := C;
    C := (B shl 30) or (B shr 2);
    B := A;
    A := temp;
  end;

  for I := 20 to 39 do
  begin
    temp := ((A shl 5) or (A shr 27)) + E + W[I] + (B xor C xor D) + K2;
    E := D;
    D := C;
    C := (B shl 30) or (B shr 2);
    B := A;
    A := temp;
  end;

  for I := 40 to 59 do
  begin
    temp := ((A shl 5) or (A shr 27)) + E + W[I] + ((B and C) or (B and D) or (C and D)) + K3;
    E := D;
    D := C;
    C := (B shl 30) or (B shr 2);
    B := A;
    A := temp;
  end;

  for I := 60 to 79 do
  begin
    temp := ((A shl 5) or (A shr 27)) + E + W[I] + (B xor C xor D) + K4;
    E := D;
    D := C;
    C := (B shl 30) or (B shr 2);
    B := A;
    A := temp;
  end;

  Inc(CA, A);
  Inc(CB, B);
  Inc(CC, C);
  Inc(CD, D);
  Inc(CE, E);
end;

procedure TSHA1Hash.Update(const ChkBuf; Len: Cardinal);
var
  Left, I: cardinal;
  Block: Pointer;
begin
  if Len = 0 then
    Exit;
  Block := @ChkBuf;
  Inc(Size, Len);
  if BufSize > 0 then
  begin
    Left := 64 - BufSize;
    if Left > Len then
    begin
      Move(Block^, Buffer[BufSize], Len);
      Inc(BufSize, Len);
      Exit;
    end else
    begin
      Move(Block^, Buffer[BufSize], Left);
      Block := Pointer(FarInteger(Block)+Left);
      Dec(Len, Left);
      Transform(@Buffer);
      BufSize := 0;
    end;
  end;
  I := 0;
  while Len >= 64 do
  begin
    Transform(Pointer(FarInteger(Block) + I));
    Inc(I, 64);
    Dec(Len, 64);
  end;
  if Len > 0 then
  begin
    Move(Pointer(FarInteger(Block) + I)^, Buffer[0], Len);
    BufSize := Len;
  end;
end;

procedure TSHA1Hash.Final;
type
 TDig = Array [0..5] of DWORD;
var
  Tail: array[0..127] of byte;
  ToAdd: cardinal;
  Count: int64;
  Temp: DWord;
  PDig: ^TDig;
  PD: ^Dword;
begin
  FillChar(Tail[0], SizeOf(Tail), 0);
  Count := Size shl 3;
  if BufSize >= 56  then
    ToAdd := 120 - BufSize
  else
    ToAdd := 56 - BufSize;
  if BufSize > 0 then
  begin
    Move(Buffer[0], Tail[0], BufSize);
  end;
  Tail[BufSize] := $80;

  Temp := Count shr 32;
  PD := Pointer(@Tail[ToAdd + BufSize]);
  PD^ := ByteSwap(Temp);
  Temp := DWord(Count);
  inc(PD);
  PD^ := ByteSwap(Temp);
  if BufSize + ToAdd + 8 > 64 then
  begin
    Transform(@Tail[0]);
    Transform(@Tail[64]);
  end
  else
   Transform(@Tail[0]);
  PDig := Pointer(@FDigest);
  PDig^[0] := ByteSwap(CA);
  PDig^[1] := ByteSwap(CB);
  PDig^[2] := ByteSwap(CC);
  PDig^[3] := ByteSwap(CD);
  PDig^[4] := ByteSwap(CE);
end;


{ TMD4Hash }

procedure TMD4Hash.Final;
var
  WorkBuf: array [0..63] of Byte;
  WorkLen: Cardinal;
begin
  Move(FState,FDigest,16);
  Move(FBuffer, WorkBuf, FbLen);
  WorkBuf[FbLen] := $80;
  WorkLen := FbLen + 1;
  if WorkLen > 56 then
  begin
    FillChar(WorkBuf[WorkLen], 64 - WorkLen, 0);
    TransForm(FDigest, WorkBuf);
    WorkLen := 0
  end;
  FillChar(WorkBuf[WorkLen], 56 - WorkLen, 0);
  TMD5Int16(WorkBuf)[14] := FCount[0];
  TMD5Int16(WorkBuf)[15] := FCount[1];
  Transform(FDigest, WorkBuf);
end;

function TMD4Hash.GetDigest: PByteArray;
begin
  Result := @FDigest;
end;

class function TMD4Hash.HashSize: Cardinal;
begin
  Result := 16;
end;

procedure TMD4Hash.Init;
begin
  FBLen := 0;
  FCount[0] := 0;
  FCount[1] := 0;
  FState[0] := $67452301;
  FState[1] := $EFCDAB89;
  FState[2] := $98BADCFE;
  FState[3] := $10325476;
end;

procedure TMD4Hash.Transform(var Accu; const Buf);
Var
  a, b, c, d: LongWord;
  lBuf: Array[0..15] Of LongWord Absolute Buf;
  lAccu: Array[0..3] Of Longword Absolute Accu;

procedure FF(var a: LongWord; b, c, d, x, s: LongWord);
begin
  a := a +  (((b and c) or ((not b) and (d)))  + x);
  a := rol(a, s);
end;

procedure GG(var a: LongWord; b, c, d, x, s: LongWord);
begin
  a := a + (b and c) or (b and d) or (c and d)  + x + $5a827999;
  a := rol(a, s);
end;

procedure HH(var a: LongWord; b, c, d, x, s: LongWord);
begin
  a := a + b xor c xor d + x + $6ed9eba1;
  a := rol(a, s);
end;
begin
  a:= lAccu[0];
  b:= lAccu[1];
  c:= lAccu[2];
  d:= lAccu[3];
  FF (a, b, c, d, lBuf[ 0],  3); //* 1 */
  FF (d, a, b, c, lBuf[ 1],  7); //* 2 */
  FF (c, d, a, b, lBuf[ 2], 11); //* 3 */
  FF (b, c, d, a, lBuf[ 3], 19); //* 4 */
  FF (a, b, c, d, lBuf[ 4],  3); //* 5 */
  FF (d, a, b, c, lBuf[ 5],  7); //* 6 */
  FF (c, d, a, b, lBuf[ 6], 11); //* 7 */
  FF (b, c, d, a, lBuf[ 7], 19); //* 8 */
  FF (a, b, c, d, lBuf[ 8],  3); //* 9 */
  FF (d, a, b, c, lBuf[ 9],  7); //* 10 */
  FF (c, d, a, b, lBuf[10], 11); //* 11 */
  FF (b, c, d, a, lBuf[11], 19); //* 12 */
  FF (a, b, c, d, lBuf[12],  3); //* 13 */
  FF (d, a, b, c, lBuf[13],  7); //* 14 */
  FF (c, d, a, b, lBuf[14], 11); //* 15 */
  FF (b, c, d, a, lBuf[15], 19); //* 16 */

  //* Round 2 */
  GG (a, b, c, d, lBuf[ 0],  3); //* 17 */
  GG (d, a, b, c, lBuf[ 4],  5); //* 18 */
  GG (c, d, a, b, lBuf[ 8],  9); //* 19 */
  GG (b, c, d, a, lBuf[12], 13); //* 20 */
  GG (a, b, c, d, lBuf[ 1],  3); //* 21 */
  GG (d, a, b, c, lBuf[ 5],  5); //* 22 */
  GG (c, d, a, b, lBuf[ 9],  9); //* 23 */
  GG (b, c, d, a, lBuf[13], 13); //* 24 */
  GG (a, b, c, d, lBuf[ 2],  3); //* 25 */
  GG (d, a, b, c, lBuf[ 6],  5); //* 26 */
  GG (c, d, a, b, lBuf[10],  9); //* 27 */
  GG (b, c, d, a, lBuf[14], 13); //* 28 */
  GG (a, b, c, d, lBuf[ 3],  3); //* 29 */
  GG (d, a, b, c, lBuf[ 7],  5); //* 30 */
  GG (c, d, a, b, lBuf[11],  9); //* 31 */
  GG (b, c, d, a, lBuf[15], 13); //* 32 */

  //* Round 3 */
  HH (a, b, c, d, lBuf[ 0],  3); //* 33 */
  HH (d, a, b, c, lBuf[ 8],  9); //* 34 */
  HH (c, d, a, b, lBuf[ 4], 11); //* 35 */
  HH (b, c, d, a, lBuf[12], 15); //* 36 */
  HH (a, b, c, d, lBuf[ 2],  3); //* 37 */
  HH (d, a, b, c, lBuf[10],  9); //* 38 */
  HH (c, d, a, b, lBuf[ 6], 11); //* 39 */
  HH (b, c, d, a, lBuf[14], 15); //* 40 */
  HH (a, b, c, d, lBuf[ 1],  3); //* 41 */
  HH (d, a, b, c, lBuf[ 9],  9); //* 42 */
  HH (c, d, a, b, lBuf[ 5], 11); //* 43 */
  HH (b, c, d, a, lBuf[13], 15); //* 44 */
  HH (a, b, c, d, lBuf[ 3],  3); //* 45 */
  HH (d, a, b, c, lBuf[11],  9); //* 46 */
  HH (c, d, a, b, lBuf[ 7], 11); //* 47 */
  HH (b, c, d, a, lBuf[15], 15); //* 48 */

  Inc(lAccu[0], a);
  Inc(lAccu[1], b);
  Inc(lAccu[2], c);
  Inc(lAccu[3], d);
end;


procedure TMD4Hash.Update(const ChkBuf; Len: Cardinal);
var
  BufPtr: ^Byte;
  Left: Cardinal;
begin
  if FCount[0] + DWORD(Integer(Len) shl 3) < FCount[0] then Inc(FCount[1]);
  Inc(FCount[0], Integer(Len) shl 3);
  Inc(FCount[1], Integer(Len) shr 29);

  BufPtr := @ChkBuf;
  if FbLen > 0 then
  begin
    Left := 64 - FbLen; if Left > Len then Left := Len;
    Move(BufPtr^, FBuffer[FbLen], Left);
    Inc(FbLen, Left); Inc(BufPtr, Left);
    if FbLen < 64 then Exit;
    Transform(FState, FBuffer);
    FbLen := 0;
    Dec(Len, Left)
  end;
  while Len >= 64 do
  begin
    Transform(FState, BufPtr^);
    Inc(BufPtr, 64);
    Dec(Len, 64)
  end;
  if Len > 0 then
  begin
    FbLen := Len;
    Move(BufPtr^, FBuffer[0], FbLen)
  end
end;


{ TMD5Hash }

procedure TMD5Hash.Final;
var
  WorkBuf: array [0..63] of Byte;
  WorkLen: Cardinal;
begin
  Move(FState,FDigest,16);
  Move(FBuffer, WorkBuf, FbLen);
  WorkBuf[FbLen] := $80;
  WorkLen := FbLen + 1;
  if WorkLen > 56 then begin
    FillChar(WorkBuf[WorkLen], 64 - WorkLen, 0);
    TransForm(FDigest, WorkBuf);
    WorkLen := 0
  end;
  FillChar(WorkBuf[WorkLen], 56 - WorkLen, 0);
  TMD5Int16(WorkBuf)[14] := FCount[0];
  TMD5Int16(WorkBuf)[15] := FCount[1];
  Transform(FDigest, WorkBuf);
end;

function TMD5Hash.GetDigest: PByteArray;
begin
  Result := @FDigest;
end;

class function TMD5Hash.HashSize: Cardinal;
begin
  Result := 16;
end;

procedure TMD5Hash.Init;
begin
  FBLen := 0;
  FCount[0] := 0;
  FCount[1] := 0;
  FState[0] := $67452301;
  FState[1] := $EFCDAB89;
  FState[2] := $98BADCFE;
  FState[3] := $10325476;
end;

procedure TMD5Hash.Transform(var Accu; const Buf);
Var
  a, b, c, d: LongWord;
  lBuf: Array[0..15] Of LongWord Absolute Buf;
  lAccu: Array[0..3] Of Longword Absolute Accu;

  Function FF (a,b,c,d,x,s,ac: LongWord): LongWord;
  Begin Result:= ROL (a+x+ac + (b And c Or Not b And d), s) + b End;

  Function GG (a,b,c,d,x,s,ac: LongWord): LongWord;
  Begin Result:= ROL (a+x+ac + (b And d Or c And Not d), s) + b End;

  Function HH (a,b,c,d,x,s,ac: LongWord): LongWord;
  Begin Result:= ROL (a+x+ac + (b Xor c Xor d), s) + b End;

  Function II (a,b,c,d,x,s,ac: LongWord): LongWord;
  Begin Result:= ROL (a+x+ac + (c Xor (b Or Not d)), s) + b End;

Begin
  a:= lAccu[0];
  b:= lAccu[1];
  c:= lAccu[2];
  d:= lAccu[3];

  a:= FF(a,b,c,d, lBuf[ 0],  7, $d76aa478);
  d:= FF(d,a,b,c, lBuf[ 1], 12, $e8c7b756);
  c:= FF(c,d,a,b, lBuf[ 2], 17, $242070db);
  b:= FF(b,c,d,a, lBuf[ 3], 22, $c1bdceee);
  a:= FF(a,b,c,d, lBuf[ 4],  7, $f57c0faf);
  d:= FF(d,a,b,c, lBuf[ 5], 12, $4787c62a);
  c:= FF(c,d,a,b, lBuf[ 6], 17, $a8304613);
  b:= FF(b,c,d,a, lBuf[ 7], 22, $fd469501);
  a:= FF(a,b,c,d, lBuf[ 8],  7, $698098d8);
  d:= FF(d,a,b,c, lBuf[ 9], 12, $8b44f7af);
  c:= FF(c,d,a,b, lBuf[10], 17, $ffff5bb1);
  b:= FF(b,c,d,a, lBuf[11], 22, $895cd7be);
  a:= FF(a,b,c,d, lBuf[12],  7, $6b901122);
  d:= FF(d,a,b,c, lBuf[13], 12, $fd987193);
  c:= FF(c,d,a,b, lBuf[14], 17, $a679438e);
  b:= FF(b,c,d,a, lBuf[15], 22, $49b40821);

  a:= GG(a,b,c,d, lBuf[ 1],  5, $f61e2562);
  d:= GG(d,a,b,c, lBuf[ 6],  9, $c040b340);
  c:= GG(c,d,a,b, lBuf[11], 14, $265e5a51);
  b:= GG(b,c,d,a, lBuf[ 0], 20, $e9b6c7aa);
  a:= GG(a,b,c,d, lBuf[ 5],  5, $d62f105d);
  d:= GG(d,a,b,c, lBuf[10],  9, $02441453);
  c:= GG(c,d,a,b, lBuf[15], 14, $d8a1e681);
  b:= GG(b,c,d,a, lBuf[ 4], 20, $e7d3fbc8);
  a:= GG(a,b,c,d, lBuf[ 9],  5, $21e1cde6);
  d:= GG(d,a,b,c, lBuf[14],  9, $c33707d6);
  c:= GG(c,d,a,b, lBuf[ 3], 14, $f4d50d87);
  b:= GG(b,c,d,a, lBuf[ 8], 20, $455a14ed);
  a:= GG(a,b,c,d, lBuf[13],  5, $a9e3e905);
  d:= GG(d,a,b,c, lBuf[ 2],  9, $fcefa3f8);
  c:= GG(c,d,a,b, lBuf[ 7], 14, $676f02d9);
  b:= GG(b,c,d,a, lBuf[12], 20, $8d2a4c8a);

  a:= HH(a,b,c,d, lBuf[ 5],  4, $fffa3942);
  d:= HH(d,a,b,c, lBuf[ 8], 11, $8771f681);
  c:= HH(c,d,a,b, lBuf[11], 16, $6d9d6122);
  b:= HH(b,c,d,a, lBuf[14], 23, $fde5380c);
  a:= HH(a,b,c,d, lBuf[ 1],  4, $a4beea44);
  d:= HH(d,a,b,c, lBuf[ 4], 11, $4bdecfa9);
  c:= HH(c,d,a,b, lBuf[ 7], 16, $f6bb4b60);
  b:= HH(b,c,d,a, lBuf[10], 23, $bebfbc70);
  a:= HH(a,b,c,d, lBuf[13],  4, $289b7ec6);
  d:= HH(d,a,b,c, lBuf[ 0], 11, $eaa127fa);
  c:= HH(c,d,a,b, lBuf[ 3], 16, $d4ef3085);
  b:= HH(b,c,d,a, lBuf[ 6], 23, $04881d05);
  a:= HH(a,b,c,d, lBuf[ 9],  4, $d9d4d039);
  d:= HH(d,a,b,c, lBuf[12], 11, $e6db99e5);
  c:= HH(c,d,a,b, lBuf[15], 16, $1fa27cf8);
  b:= HH(b,c,d,a, lBuf[ 2], 23, $c4ac5665);

  a:= II(a,b,c,d, lBuf[ 0],  6, $f4292244);
  d:= II(d,a,b,c, lBuf[ 7], 10, $432aff97);
  c:= II(c,d,a,b, lBuf[14], 15, $ab9423a7);
  b:= II(b,c,d,a, lBuf[ 5], 21, $fc93a039);
  a:= II(a,b,c,d, lBuf[12],  6, $655b59c3);
  d:= II(d,a,b,c, lBuf[ 3], 10, $8f0ccc92);
  c:= II(c,d,a,b, lBuf[10], 15, $ffeff47d);
  b:= II(b,c,d,a, lBuf[ 1], 21, $85845dd1);
  a:= II(a,b,c,d, lBuf[ 8],  6, $6fa87e4f);
  d:= II(d,a,b,c, lBuf[15], 10, $fe2ce6e0);
  c:= II(c,d,a,b, lBuf[ 6], 15, $a3014314);
  b:= II(b,c,d,a, lBuf[13], 21, $4e0811a1);
  a:= II(a,b,c,d, lBuf[ 4],  6, $f7537e82);
  d:= II(d,a,b,c, lBuf[11], 10, $bd3af235);
  c:= II(c,d,a,b, lBuf[ 2], 15, $2ad7d2bb);
  b:= II(b,c,d,a, lBuf[ 9], 21, $eb86d391);

  Inc(lAccu[0], a);
  Inc(lAccu[1], b);
  Inc(lAccu[2], c);
  Inc(lAccu[3], d);
end;

procedure TMD5Hash.Update(const ChkBuf; Len: Cardinal);
var
  BufPtr: ^Byte;
  Left: Cardinal;
begin
  if FCount[0] + DWORD(Integer(Len) shl 3) < FCount[0] then Inc(FCount[1]);
  Inc(FCount[0], Integer(Len) shl 3);
  Inc(FCount[1], Integer(Len) shr 29);

  BufPtr := @ChkBuf;
  if FbLen > 0 then
  begin
    Left := 64 - FbLen;
    if Left > Len then Left := Len;
    Move(BufPtr^, FBuffer[FbLen], Left);
    Inc(FbLen, Left);
    Inc(BufPtr, Left);
    if FbLen < 64 then Exit;
    Transform(FState, FBuffer);
    FbLen := 0;
    Dec(Len, Left)
  end;
  while Len >= 64 do
  begin
    Transform(FState, BufPtr^);
    Inc(BufPtr, 64);
    Dec(Len, 64)
  end;
  if Len > 0 then
  begin
    FbLen := Len;
    Move(BufPtr^, FBuffer[0], FbLen)
  end
end;

{ TSHA256Hash }

procedure TSHA256Hash.Final;
var
  I: Integer;
begin
  FBuffer[FIndex]:= $80;
  if FIndex>= 56 then
    Transform;
  PDWORD(@FBuffer[56])^:= ByteSwap(FLenHi);
  PDWord(@FBuffer[60])^:= ByteSwap(FLenLo);
  Transform;
  for I:= 0 to 7 do
    FHash[i]:= ByteSwap(FHash[i]);
  move(FHash,FDigest,32);
end;

function TSHA256Hash.GetDigest: PByteArray;
begin
  Result := @FDigest;
end;

class function TSHA256Hash.HashSize: Cardinal;
begin
  Result := 32;
end;

procedure TSHA256Hash.Init;
begin
  fillchar(FBuffer,SizeOf(FBuffer),0);
  FLenHi:= 0;
  FLenLo:= 0;
  FIndex:= 0;
  FHash[0]:= $6a09e667;
  FHash[1]:= $bb67ae85;
  FHash[2]:= $3c6ef372;
  FHash[3]:= $a54ff53a;
  FHash[4]:= $510e527f;
  FHash[5]:= $9b05688c;
  FHash[6]:= $1f83d9ab;
  FHash[7]:= $5be0cd19;
end;

procedure TSHA256Hash.Transform;
var
  A, B, C, D, E, F, G, H: DWORD;
  T1,T2: DWORD;
  W: array[0..63] of DWORD;
  i: Integer;
const
  K: array[0..63] of DWORD = (
       $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5,
       $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5,
       $d807aa98, $12835b01, $243185be, $550c7dc3,
       $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174,
       $e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc,
       $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
       $983e5152, $a831c66d, $b00327c8, $bf597fc7,
       $c6e00bf3, $d5a79147, $06ca6351, $14292967,
       $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13,
       $650a7354, $766a0abb, $81c2c92e, $92722c85,
       $a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3,
       $d192e819, $d6990624, $f40e3585, $106aa070,
       $19a4c116, $1e376c08, $2748774c, $34b0bcb5,
       $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3,
       $748f82ee, $78a5636f, $84c87814, $8cc70208,
       $90befffa, $a4506ceb, $bef9a3f7, $c67178f2
     );
begin
  A := FHash[0];
  B := FHash[1];
  C := FHash[2];
  D := FHash[3];
  E := FHash[4];
  F := FHash[5];
  G := FHash[6];
  H := FHash[7];
  FIndex:= 0;

  Move(FBuffer,W,SHA_HASH_BUFFER_SIZE);
  for i:= 0 to 15 do
    W[i]:= ByteSwap(W[i]);
  for i:= 16 to 63 do
    W[i]:= (((W[i-2] shr 17) or (W[i-2] shl 15)) xor ((W[i-2] shr 19) or (W[i-2] shl 13)) xor
      (W[i-2] shr 10)) + W[i-7] + (((W[i-15] shr 7) or (W[i-15] shl 25)) xor
      ((W[i-15] shr 18) or (W[i-15] shl 14)) xor (W[i-15] shr 3)) + W[i-16];

  for i := 0 to 7 do
  begin
    t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + K[i*8] + W[i*8];
    t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
    h:= t1 + t2; d:= d + t1;
    t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + K[i*8+1] + W[i*8+1];
    t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
    g:= t1 + t2; c:= c + t1;
    t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + K[i*8+2] + W[i*8+2];
    t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19))
      xor ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
    f:= t1 + t2; b:= b + t1;
    t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + K[i*8+3] + W[i*8+3];
    t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
    e:= t1 + t2; a:= a + t1;
    t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + K[i*8+4] + W[i*8+4];
    t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
       ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
    d:= t1 + t2; h:= h + t1;
    t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + K[i*8+5] + W[i*8+5];
    t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
    c:= t1 + t2; g:= g + t1;
    t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + K[i*8+6] + W[i*8+6];
    t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
    b:= t1 + t2; f:= f + t1;
    t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + K[i*8+7] + W[i*8+7];
    t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
    a:= t1 + t2; e:= e + t1;
  end;
  inc(FHash[0],A);
  inc(FHash[1],B);
  inc(FHash[2],C);
  inc(FHash[3],D);
  inc(FHash[4],E);
  inc(FHash[5],F);
  inc(FHash[6],G);
  inc(FHash[7],H);
  FillChar(FBuffer,SHA_HASH_BUFFER_SIZE,0);
end;

procedure TSHA256Hash.Update(const ChkBuf; Len: Cardinal);
var
  BufPtr: ^byte;
begin
  Inc(FLenHi,Len shr 29);
  Inc(FLenLo,Len*8);
  if FLenLo< (Len*8) then
    Inc(FLenHi);
  BufPtr:= @ChkBuf;
  while Len> 0 do
  begin
    if (SHA_HASH_BUFFER_SIZE-FIndex)<= Len then
    begin
      Move(BufPtr^,FBuffer[FIndex],SHA_HASH_BUFFER_SIZE-FIndex);
      Dec(Len,SHA_HASH_BUFFER_SIZE-FIndex);
      Inc(BufPtr,SHA_HASH_BUFFER_SIZE-FIndex);
      Transform;
    end else
    begin
      Move(BufPtr^,FBuffer[FIndex],Len);
      Inc(FIndex,Len);
      Len:= 0;
    end;
  end;
end;

{ THash }

constructor THash.Create;
begin
  Init;
end;

procedure THash.Finish(P: Pointer);
begin
  Final;
  move(Digest^,P^,HashSize);
end;

function THash.GetHashString: AnsiString;
begin
  Result := DataToHex(Digest,HashSize);
end;

procedure THash.HashIteration(const ChkBuf; Len, Iterations: Cardinal);
var
  P: Pointer;
  I, HS: Integer;
begin
  HS := HashSize;
  P := GetMemory(HS);
  try
    Init;
    Update(ChkBuf,Len);
    Final;
    for i := 1 to Iterations - 1 do
    begin
      move(Digest^,P^,HS);
      Init;
      Update(P^,HS);
      Final;
    end;
  finally
    FreeMemory(P);
  end;
end;

class function THash.HashSize: Cardinal;
begin
  Result := 0;
end;


{ TBlockCipher }

procedure TBlockCipher.XORBuffer(const Buffer1, Buffer2: Pointer; const BufferSize: Integer);
var I    : Integer;
    P, Q : PByte;
begin
  Assert(Assigned(Buffer1));
  Assert(Assigned(Buffer2));
  P := Buffer1;
  Q := Buffer2;
  for I := 0 to BufferSize - 1 do
  begin
    P^ := P^ xor Q^;
    Inc(P);
    Inc(Q);
  end;
end;

procedure TBlockCipher.Decode(Buf: Pointer; Len: Cardinal);
var P : PByte;
    L : Cardinal;
    B : array[0..MaxCipherBlockSize - 1] of Byte;
    C : array[0..MaxCipherBlockSize - 1] of Byte;
    BS: Cardinal;
begin
  P := Buf;
  L := Len;
  BS := GetBlockSize;
  Move(FInitVector, B[0], BS);
  while L >= BS do
    begin
      Move(P^, C[0], BS);
      DecodeBlock( P);
      XORBuffer(P, @B[0], BS);
      Move(C[0], B[0], BS);
      Dec(L, BS);
      Inc(P, BS);
    end;
  if L > 0 then
    begin
      Move(P^, C[0], L);
      FillChar(C[L], BS - L, 0);
      DecodeBlock(@C[0]);
      XORBuffer(@C[0], @B[0], BS);
      Move(C[0], P^, L);
    end;

end;

procedure TBlockCipher.Encode(Buf: Pointer; Len: Cardinal);
var P, F : PByte;
    L : Cardinal;
    B : array[0..MaxCipherBlockSize - 1] of Byte;
    BS:Cardinal;
begin
  P := Buf;
  L := Len;
  F := @FInitVector;
  BS := GetBlockSize;
  while L >= BS do
    begin
      XORBuffer(P, F, BS);
      EncodeBlock(P);
      F := P;
      Dec(L, BS);
      Inc(P, BS);
    end;
  if L > 0 then
    begin
      Move(P^, B[0], L);
      FillChar(B[L], BS - L, 0);
      XORBuffer(@B[0], F, BS);
      EncodeBlock(@B[0]);
      Move(B[0], P^, L);
    end;
end;

procedure TBlockCipher.Init(Key: Pointer; Len: Cardinal; InitVector: Pointer);
begin
  move(InitVector^, FInitVector,GetIVSize);
end;

{ TCipher }

constructor TCipher.Create(Key:Pointer;Len: Cardinal;InitVector:Pointer);
begin
  FKeyLen := Len;
  Init(Key,Len,InitVector);
end;

procedure TCipher.DecodeTo(Source, Destination: Pointer; Len: Cardinal; SaveSource: Boolean);
var
  Store: Pointer;
begin
  Store := nil;
  if SaveSource then
    Store := GetMemory(Len);
  try
    if SaveSource then
      Move(Source^,Store^,Len);
    Decode(Source,Len);
    move(Source^, Destination^,Len);
    if SaveSource then
      Move(Store^,Source^,Len);
  finally
    if SaveSource then
      FreeMemory(Store);
  end;
end;

function TCipher.DecodeToStr(Buf: Pointer; Len: Cardinal): AnsiString;
var
  PadLen:Cardinal;
  I: Integer;
begin
  if Len = 0 then
    Exit;
  SetLength(Result,Len);
  Decode(Buf,Len);
  Move(Buf^,Result[1],Len);
  if self is TBlockCipher then
  begin
    PadLen := Byte(Result[Len]);
    if (PadLen > 0) and (PadLen <= TBlockCipher(Self).GetBlockSize) then
    begin
      for I := Len downto Len - PadLen + 1 do
        if Byte(Result[i]) <> PadLen then
        begin
          PadLen := 0;
          Break;
        end
    end else
      PadLen := 0;
    if PadLen <> 0 then
      SetLength(Result,Len - PadLen);
  end
end;

procedure TCipher.EncodeTo(Source, Destination: Pointer; Len: Cardinal; SaveSource: Boolean);
var
  Store: Pointer;
begin
  Store := nil;
  if SaveSource then
    Store := GetMemory(Len);
  try
    if SaveSource then
      Move(Source^,Store^,Len);
    Encode(Source,Len);
    move(Source^, Destination^,Len);
    if SaveSource then
      Move(Store^,Source^,Len);
  finally
    if SaveSource then
      FreeMemory(Store);
  end;
end;

{ TDESCipher }
const

  DES_PC1: array[0..55] of Byte =
   (56, 48, 40, 32, 24, 16,  8,  0, 57, 49, 41, 33, 25, 17,
     9,  1, 58, 50, 42, 34, 26,	18, 10,  2, 59, 51, 43, 35,
    62, 54, 46, 38, 30, 22, 14,	 6, 61, 53, 45, 37, 29, 21,
    13,  5, 60, 52, 44, 36, 28,	20, 12,  4, 27, 19, 11,  3);

  DES_PC2: array[0..47] of Byte =
   (13, 16, 10, 23,  0,  4,  2, 27, 14,  5, 20,  9,
    22, 18, 11,  3, 25,  7, 15,  6, 26, 19, 12,  1,
    40, 51, 30, 36, 46, 54, 29, 39, 50, 44, 32, 47,
    43, 48, 38, 55, 33, 52, 45, 41, 49, 35, 28, 31);

  DES_Data: array[0..7, 0..63] of LongWord = (
   ($00200000,$04200002,$04000802,$00000000,$00000800,$04000802,$00200802,$04200800,
    $04200802,$00200000,$00000000,$04000002,$00000002,$04000000,$04200002,$00000802,
    $04000800,$00200802,$00200002,$04000800,$04000002,$04200000,$04200800,$00200002,
    $04200000,$00000800,$00000802,$04200802,$00200800,$00000002,$04000000,$00200800,
    $04000000,$00200800,$00200000,$04000802,$04000802,$04200002,$04200002,$00000002,
    $00200002,$04000000,$04000800,$00200000,$04200800,$00000802,$00200802,$04200800,
    $00000802,$04000002,$04200802,$04200000,$00200800,$00000000,$00000002,$04200802,
    $00000000,$00200802,$04200000,$00000800,$04000002,$04000800,$00000800,$00200002),
   ($00000100,$02080100,$02080000,$42000100,$00080000,$00000100,$40000000,$02080000,
    $40080100,$00080000,$02000100,$40080100,$42000100,$42080000,$00080100,$40000000,
    $02000000,$40080000,$40080000,$00000000,$40000100,$42080100,$42080100,$02000100,
    $42080000,$40000100,$00000000,$42000000,$02080100,$02000000,$42000000,$00080100,
    $00080000,$42000100,$00000100,$02000000,$40000000,$02080000,$42000100,$40080100,
    $02000100,$40000000,$42080000,$02080100,$40080100,$00000100,$02000000,$42080000,
    $42080100,$00080100,$42000000,$42080100,$02080000,$00000000,$40080000,$42000000,
    $00080100,$02000100,$40000100,$00080000,$00000000,$40080000,$02080100,$40000100),
   ($00000208,$08020200,$00000000,$08020008,$08000200,$00000000,$00020208,$08000200,
    $00020008,$08000008,$08000008,$00020000,$08020208,$00020008,$08020000,$00000208,
    $08000000,$00000008,$08020200,$00000200,$00020200,$08020000,$08020008,$00020208,
    $08000208,$00020200,$00020000,$08000208,$00000008,$08020208,$00000200,$08000000,
    $08020200,$08000000,$00020008,$00000208,$00020000,$08020200,$08000200,$00000000,
    $00000200,$00020008,$08020208,$08000200,$08000008,$00000200,$00000000,$08020008,
    $08000208,$00020000,$08000000,$08020208,$00000008,$00020208,$00020200,$08000008,
    $08020000,$08000208,$00000208,$08020000,$00020208,$00000008,$08020008,$00020200),
   ($01010400,$00000000,$00010000,$01010404,$01010004,$00010404,$00000004,$00010000,
    $00000400,$01010400,$01010404,$00000400,$01000404,$01010004,$01000000,$00000004,
    $00000404,$01000400,$01000400,$00010400,$00010400,$01010000,$01010000,$01000404,
    $00010004,$01000004,$01000004,$00010004,$00000000,$00000404,$00010404,$01000000,
    $00010000,$01010404,$00000004,$01010000,$01010400,$01000000,$01000000,$00000400,
    $01010004,$00010000,$00010400,$01000004,$00000400,$00000004,$01000404,$00010404,
    $01010404,$00010004,$01010000,$01000404,$01000004,$00000404,$00010404,$01010400,
    $00000404,$01000400,$01000400,$00000000,$00010004,$00010400,$00000000,$01010004),
   ($10001040,$00001000,$00040000,$10041040,$10000000,$10001040,$00000040,$10000000,
    $00040040,$10040000,$10041040,$00041000,$10041000,$00041040,$00001000,$00000040,
    $10040000,$10000040,$10001000,$00001040,$00041000,$00040040,$10040040,$10041000,
    $00001040,$00000000,$00000000,$10040040,$10000040,$10001000,$00041040,$00040000,
    $00041040,$00040000,$10041000,$00001000,$00000040,$10040040,$00001000,$00041040,
    $10001000,$00000040,$10000040,$10040000,$10040040,$10000000,$00040000,$10001040,
    $00000000,$10041040,$00040040,$10000040,$10040000,$10001000,$10001040,$00000000,
    $10041040,$00041000,$00041000,$00001040,$00001040,$00040040,$10000000,$10041000),
   ($20000010,$20400000,$00004000,$20404010,$20400000,$00000010,$20404010,$00400000,
    $20004000,$00404010,$00400000,$20000010,$00400010,$20004000,$20000000,$00004010,
    $00000000,$00400010,$20004010,$00004000,$00404000,$20004010,$00000010,$20400010,
    $20400010,$00000000,$00404010,$20404000,$00004010,$00404000,$20404000,$20000000,
    $20004000,$00000010,$20400010,$00404000,$20404010,$00400000,$00004010,$20000010,
    $00400000,$20004000,$20000000,$00004010,$20000010,$20404010,$00404000,$20400000,
    $00404010,$20404000,$00000000,$20400010,$00000010,$00004000,$20400000,$00404010,
    $00004000,$00400010,$20004010,$00000000,$20404000,$20000000,$00400010,$20004010),
   ($00802001,$00002081,$00002081,$00000080,$00802080,$00800081,$00800001,$00002001,
    $00000000,$00802000,$00802000,$00802081,$00000081,$00000000,$00800080,$00800001,
    $00000001,$00002000,$00800000,$00802001,$00000080,$00800000,$00002001,$00002080,
    $00800081,$00000001,$00002080,$00800080,$00002000,$00802080,$00802081,$00000081,
    $00800080,$00800001,$00802000,$00802081,$00000081,$00000000,$00000000,$00802000,
    $00002080,$00800080,$00800081,$00000001,$00802001,$00002081,$00002081,$00000080,
    $00802081,$00000081,$00000001,$00002000,$00800001,$00002001,$00802080,$00800081,
    $00002001,$00002080,$00800000,$00802001,$00000080,$00800000,$00002000,$00802080),
   ($80108020,$80008000,$00008000,$00108020,$00100000,$00000020,$80100020,$80008020,
    $80000020,$80108020,$80108000,$80000000,$80008000,$00100000,$00000020,$80100020,
    $00108000,$00100020,$80008020,$00000000,$80000000,$00008000,$00108020,$80100000,
    $00100020,$80000020,$00000000,$00108000,$00008020,$80108000,$80100000,$00008020,
    $00000000,$00108020,$80100020,$00100000,$80008020,$80100000,$80108000,$00008000,
    $80100000,$80008000,$00000020,$80108020,$00108020,$00000020,$00008000,$80000000,
    $00008020,$80108000,$00100000,$80000020,$00100020,$80008020,$80000020,$00100020,
    $00108000,$00000000,$80008000,$00008020,$80000000,$80100020,$80108020,$00108000));


type

  TRC2Block = packed record
    case Integer of
      0 : (Bytes: array[0..7] of Byte);
      1 : (Words: array[0..3] of Word);
      2 : (A, B, C, D: Word);
  end;
  PRC2Block = ^TRC2Block;
  IntArray = array[0..64000] of LongWord;
  PIntArray = ^IntArray;

procedure DES_Func(Data: PIntArray; Key: PDWord); register;
var
  L,R,X,Y,I: LongWord;
begin
  L := ByteSwap(Data[0]);
  R := ByteSwap(Data[1]);

  X := (L shr  4 xor R) and $0F0F0F0F; R := R xor X; L := L xor X shl  4;
  X := (L shr 16 xor R) and $0000FFFF; R := R xor X; L := L xor X shl 16;
  X := (R shr  2 xor L) and $33333333; L := L xor X; R := R xor X shl  2;
  X := (R shr  8 xor L) and $00FF00FF; L := L xor X; R := R xor X shl  8;

  R := R shl 1 or R shr 31;
  X := (L xor R) and $AAAAAAAA;
  R := R xor X;
  L := L xor X;
  L := L shl 1 or L shr 31;

  for I := 0 to 7 do
  begin
    X := (R shl 28 or R shr 4) xor Key^; Inc(Key);
    Y := R xor Key^;                     Inc(Key);
    L := L xor (DES_Data[0, X        and $3F] or DES_Data[1, X shr  8 and $3F] or
                DES_Data[2, X shr 16 and $3F] or DES_Data[3, X shr 24 and $3F] or
                DES_Data[4, Y        and $3F] or DES_Data[5, Y shr  8 and $3F] or
                DES_Data[6, Y shr 16 and $3F] or DES_Data[7, Y shr 24 and $3F]);

    X := (L shl 28 or L shr 4) xor Key^; Inc(Key);
    Y := L xor Key^;                     Inc(Key);
    R := R xor (DES_Data[0, X        and $3F] or DES_Data[1, X shr  8 and $3F] or
                DES_Data[2, X shr 16 and $3F] or DES_Data[3, X shr 24 and $3F] or
                DES_Data[4, Y        and $3F] or DES_Data[5, Y shr  8 and $3F] or
                DES_Data[6, Y shr 16 and $3F] or DES_Data[7, Y shr 24 and $3F]);
  end;

  R := R shl 31 or R shr 1;
  X := (L xor R) and $AAAAAAAA;
  R := R xor X;
  L := L xor X;
  L := L shl 31 or L shr 1;

  X := (L shr  8 xor R) and $00FF00FF; R := R xor X; L := L xor X shl  8;
  X := (L shr  2 xor R) and $33333333; R := R xor X; L := L xor X shl  2;
  X := (R shr 16 xor L) and $0000FFFF; L := L xor X; R := R xor X shl 16;
  X := (R shr  4 xor L) and $0F0F0F0F; L := L xor X; R := R xor X shl  4;

  Data[0] := ByteSwap(R);
  Data[1] := ByteSwap(L);
end;


function TDESCipher.GetBlockSize: Cardinal;
begin
  Result := 8;
end;

function TDESCipher.GetIVSize: Cardinal;
begin
  Result := 8;
end;

procedure TDESCipher.Init(Key: Pointer; Len: Cardinal; InitVector: Pointer);
var
  K: array[0..23] of Byte;
  P: PInteger;
begin
  FillChar(K, SizeOf(K), 0);
  Move(Key^, K, Len);
  P := Pointer(@FUserInfo);
  if Len = 24 then
  begin
    MakeKey(K[ 0], P, False); Inc(P, 32);
    MakeKey(K[ 8], P, True);  Inc(P, 32);
    MakeKey(K[16], P, False); Inc(P, 32);
    MakeKey(K[16], P, True);  Inc(P, 32);
    MakeKey(K[ 8], P, False); Inc(P, 32);
    MakeKey(K[ 0], P, True);
  end else
  begin
    MakeKey(K[0], P, False); Inc(P, 32);
    MakeKey(K[8], P, True);  Inc(P, 32);
    MakeKey(K[0], P, True);  Inc(P, 32);
    MakeKey(K[8], P, False);
  end;
  FillChar(K, SizeOf(K), 0);
  inherited;
end;


procedure TDESCipher.DecodeBlock(Buf: Pointer);
begin
  if FKeyLen = 16 then
  begin
    DES_Func(Buf, @PIntArray(@FUserInfo)[64]);
    DES_Func(Buf, @PIntArray(@FUserInfo)[96]);
    DES_Func(Buf, @PIntArray(@FUserInfo)[64]);
  end else
  begin
    DES_Func(Buf, @PIntArray(@FUserInfo)[96]);
    DES_Func(Buf, @PIntArray(@FUserInfo)[128]);
    DES_Func(Buf, @PIntArray(@FUserInfo)[160]);
  end;
end;

procedure TDESCipher.EncodeBlock(Buf: Pointer);
begin
  if FKeyLen = 16 then
  begin
    DES_Func(Buf, @FUserInfo);
    DES_Func(Buf, @PIntArray(@FUserInfo)[32]);
    DES_Func(Buf, @FUserInfo);
  end else
  begin
    DES_Func(Buf, @FUserInfo);
    DES_Func(Buf, @PIntArray(@FUserInfo)[32]);
    DES_Func(Buf, @PIntArray(@FUserInfo)[64]);
  end;
end;


procedure TDESCipher.MakeKey(const Data: array of Byte; Key: PInteger; Reverse: Boolean);
const
  ROT: array[0..15] of Byte = (1,2,4,6,8,10,12,14,15,17,19,21,23,25,27,28);
var
  I,J,L,M,N: LongWord;
  PC_M, PC_R: array[0..55] of Byte;
  K: array[0..31] of LongWord;
begin
  FillChar(K, SizeOf(K), 0);
  for I := 0 to 55 do
    if Data[DES_PC1[I] shr 3] and ($80 shr (DES_PC1[I] and $07)) <> 0 then PC_M[I] := 1
      else PC_M[I] := 0;
  for I := 0 to 15 do
  begin
    if Reverse then M := (15 - I) shl 1 else M := I shl 1;
    N := M + 1;
    for J := 0 to 27 do
    begin
      L := J + ROT[I];
      if L < 28 then PC_R[J] := PC_M[L] else PC_R[J] := PC_M[L - 28];
    end;
    for J := 28 to 55 do
    begin
      L := J + ROT[I];
      if L < 56 then PC_R[J] := PC_M[L] else PC_R[J] := PC_M[L - 28];
    end;
    L := $1000000;
    for J := 0 to 23 do
    begin
      L := L shr 1;
      if PC_R[DES_PC2[J     ]] <> 0 then K[M] := K[M] or L;
      if PC_R[DES_PC2[J + 24]] <> 0 then K[N] := K[N] or L;
    end;
  end;
  for I := 0 to 15 do
  begin
    M := I shl 1; N := M + 1;
    Key^ := K[M] and $00FC0000 shl  6 or
            K[M] and $00000FC0 shl 10 or
            K[N] and $00FC0000 shr 10 or
            K[N] and $00000FC0 shr  6;
    Inc(Key);
    Key^ := K[M] and $0003F000 shl 12 or
            K[M] and $0000003F shl 16 or
            K[N] and $0003F000 shr  4 or
            K[N] and $0000003F;
    Inc(Key);
  end;
end;

{ TRC2Cipher }

procedure TRC2Cipher.DecodeBlock(Buf: Pointer);
{$ifndef W64}
function RC2ROR(const Value: Word; const Bits: Byte): Word;
asm
  MOV     CL, DL
  ROR     AX, CL
end;
{$else}
function RC2ROR(const Value: Word; const Bits: Byte): Word;
var I : Integer;
begin
  Result := Value;
  for I := 1 to Bits do
    if Result and 1 = 0 then
      Result := Result shr 1
    else
      Result := (Result shr 1) or $8000;
end;
{$endif}
var J : PWord;
    I : Integer;
    Block:PRC2Block;
begin
  J := @FKey.Words[63];
  Block := Buf;
  with Block^ do
  begin
    for I := 1 to 5 do
    begin
      D := Word(RC2ROR(D, 5) - J^ - (C and B) - (not C and A)); Dec(J);
      C := Word(RC2ROR(C, 3) - J^ - (B and A) - (not B and D)); Dec(J);
      B := Word(RC2ROR(B, 2) - J^ - (A and D) - (not A and C)); Dec(J);
      A := Word(RC2ROR(A, 1) - J^ - (D and C) - (not D and B)); Dec(J);
    end;
    D := Word(D - FKey.Words[C and $3F]);
    C := Word(C - FKey.Words[B and $3F]);
    B := Word(B - FKey.Words[A and $3F]);
    A := Word(A - FKey.Words[D and $3F]);
    for I := 1 to 6 do
    begin
      D := Word(RC2ROR(D, 5) - J^ - (C and B) - (not C and A)); Dec(J);
      C := Word(RC2ROR(C, 3) - J^ - (B and A) - (not B and D)); Dec(J);
      B := Word(RC2ROR(B, 2) - J^ - (A and D) - (not A and C)); Dec(J);
      A := Word(RC2ROR(A, 1) - J^ - (D and C) - (not D and B)); Dec(J);
    end;
    D := Word(D - FKey.Words[C and $3F]);
    C := Word(C - FKey.Words[B and $3F]);
    B := Word(B - FKey.Words[A and $3F]);
    A := Word(A - FKey.Words[D and $3F]);
    for I := 1 to 5 do
    begin
      D := Word(RC2ROR(D, 5) - J^ - (C and B) - (not C and A)); Dec(J);
      C := Word(RC2ROR(C, 3) - J^ - (B and A) - (not B and D)); Dec(J);
      B := Word(RC2ROR(B, 2) - J^ - (A and D) - (not A and C)); Dec(J);
      A := Word(RC2ROR(A, 1) - J^ - (D and C) - (not D and B)); Dec(J);
    end;
  end;
end;

procedure TRC2Cipher.EncodeBlock(Buf: Pointer);
{$ifndef W64}
function RC2ROL(const Value: Word; const Bits: Byte): Word;
asm
  MOV     CL, DL
  ROL     AX, CL
end;
{$else}
function RC2ROL(const Value: Word; const Bits: Byte): Word;
var I : Integer;
begin
  Result := Value;
  for I := 1 to Bits do
    if Result and $8000 = 0 then
      Result := Result shl 1
    else
      Result := Word(Result shl 1) or 1;
end;
{$endif}
var J : PWord;
    I : Integer;
    Block:PRC2Block;
begin
  J := @FKey.Words[0];
  Block := Buf;
  with Block^ do
  begin
    for I := 1 to 5 do
    begin
      A := RC2ROL(Word(A + J^ + (D and C) + (not D and B)), 1); Inc(J);
      B := RC2ROL(Word(B + J^ + (A and D) + (not A and C)), 2); Inc(J);
      C := RC2ROL(Word(C + J^ + (B and A) + (not B and D)), 3); Inc(J);
      D := RC2ROL(Word(D + J^ + (C and B) + (not C and A)), 5); Inc(J);
    end;
    A := Word(A + FKey.Words[D and $3F]);
    B := Word(B + FKey.Words[A and $3F]);
    C := Word(C + FKey.Words[B and $3F]);
    D := Word(D + FKey.Words[C and $3F]);
    for I := 1 to 6 do
    begin
      A := RC2ROL(Word(A + J^ + (D and C) + (not D and B)), 1); Inc(J);
      B := RC2ROL(Word(B + J^ + (A and D) + (not A and C)), 2); Inc(J);
      C := RC2ROL(Word(C + J^ + (B and A) + (not B and D)), 3); Inc(J);
      D := RC2ROL(Word(D + J^ + (C and B) + (not C and A)), 5); Inc(J);
    end;
    A := Word(A + FKey.Words[D and $3F]);
    B := Word(B + FKey.Words[A and $3F]);
    C := Word(C + FKey.Words[B and $3F]);
    D := Word(D + FKey.Words[C and $3F]);
    for I := 1 to 5 do
    begin
      A := RC2ROL(Word(A + J^ + (D and C) + (not D and B)), 1); Inc(J);
      B := RC2ROL(Word(B + J^ + (A and D) + (not A and C)), 2); Inc(J);
      C := RC2ROL(Word(C + J^ + (B and A) + (not B and D)), 3); Inc(J);
      D := RC2ROL(Word(D + J^ + (C and B) + (not C and A)), 5); Inc(J);
    end;
  end;
end;

function TRC2Cipher.GetBlockSize: Cardinal;
begin
  Result := 8;
end;

function TRC2Cipher.GetIVSize: Cardinal;
begin
  Result := 8;
end;

procedure TRC2Cipher.Init(Key: Pointer; Len: Cardinal; InitVector: Pointer);
const
  RC2_Data: array[0..255] of Byte =
   ($D9,$78,$F9,$C4,$19,$DD,$B5,$ED,$28,$E9,$FD,$79,$4A,$A0,$D8,$9D,
    $C6,$7E,$37,$83,$2B,$76,$53,$8E,$62,$4C,$64,$88,$44,$8B,$FB,$A2,
    $17,$9A,$59,$F5,$87,$B3,$4F,$13,$61,$45,$6D,$8D,$09,$81,$7D,$32,
    $BD,$8F,$40,$EB,$86,$B7,$7B,$0B,$F0,$95,$21,$22,$5C,$6B,$4E,$82,
    $54,$D6,$65,$93,$CE,$60,$B2,$1C,$73,$56,$C0,$14,$A7,$8C,$F1,$DC,
    $12,$75,$CA,$1F,$3B,$BE,$E4,$D1,$42,$3D,$D4,$30,$A3,$3C,$B6,$26,
    $6F,$BF,$0E,$DA,$46,$69,$07,$57,$27,$F2,$1D,$9B,$BC,$94,$43,$03,
    $F8,$11,$C7,$F6,$90,$EF,$3E,$E7,$06,$C3,$D5,$2F,$C8,$66,$1E,$D7,
    $08,$E8,$EA,$DE,$80,$52,$EE,$F7,$84,$AA,$72,$AC,$35,$4D,$6A,$2A,
    $96,$1A,$D2,$71,$5A,$15,$49,$74,$4B,$9F,$D0,$5E,$04,$18,$A4,$EC,
    $C2,$E0,$41,$6E,$0F,$51,$CB,$CC,$24,$91,$AF,$50,$A1,$F4,$70,$39,
    $99,$7C,$3A,$85,$23,$B8,$B4,$7A,$FC,$02,$36,$5B,$25,$55,$97,$31,
    $2D,$5D,$FA,$98,$E3,$8A,$92,$AE,$05,$DF,$29,$10,$67,$6C,$BA,$C9,
    $D3,$00,$E6,$CF,$E1,$9E,$A8,$2C,$63,$16,$01,$3F,$58,$E2,$89,$A9,
    $0D,$38,$34,$1B,$AB,$33,$FF,$B0,$BB,$48,$0C,$5F,$B9,$B1,$CD,$2E,
    $C5,$F3,$DB,$47,$E5,$A5,$9C,$77,$0A,$A6,$20,$68,$FE,$7F,$C1,$AD);

var
  I: Cardinal;
  KeyBits: Cardinal;
  T8: Cardinal;
  TM: byte;
begin
  KeyBits := Len shl 3;
  T8 := (KeyBits + 7) shr 3;
  TM := (1 shl (KeyBits and $7)) - 1;
  if TM = 0 then
    TM := $FF;
  Move(Key^, FKey, Len);
  with FKey do
    begin
      for I := Len to 127 do
        Bytes[I] := RC2_Data[Byte(Bytes[I - 1] + Bytes[I - Len])];
      Bytes[128 - T8] := RC2_Data[Bytes[128 - T8] and TM];
      for I := 127 - T8 downto 0 do
        Bytes[I] := RC2_Data[Bytes[I + 1] xor Bytes[I + T8]];
    end;
  inherited;
end;

{ TRC4Cipher }

procedure TRC4Cipher.Decode(Buf: Pointer; Len: Cardinal);
begin
  Encode(Buf,Len);
end;

procedure TRC4Cipher.Encode(Buf: Pointer; Len: Cardinal);
var
  t, i, j: byte;
  k: integer;
  Ind, Ou: PByteArray;
begin
  ind := Buf;
  Ou := Buf;
  i := 0;
  j := 0;
  for k := 0 to Len - 1 do
  begin
    i := Byte(i + 1);
    j := Byte(j + FKey[i]);
    t := FKey[i];
    FKey[i] := FKey[j];
    FKey[j] := t;
    t := Byte(FKey[i] + FKey[j]);
    Ou[k] := Ind[k] xor FKey[t];
  end;
  Move(FOrgKey, FKey, 256);
end;

procedure TRC4Cipher.Init(Key: Pointer; Len: Cardinal; InitVector: Pointer);
var
  xKey: array[0..255] of byte;
  i, j: Cardinal;
  t: byte;
begin
  if (Len <= 0) or (Len > 256) then
    raise Exception.Create(SRC4InvalidKeyLength);
  for i := 0 to 255 do
  begin
    FKey[i] := i;
    xKey[i] := PByte(FarInteger(Key) + (i mod Len))^;
  end;
  j := 0;
  for i := 0 to 255 do
  begin
    j := (j + FKey[i] + xKey[i]) and $FF;
    t := FKey[i];
    FKey[i] := FKey[j];
    FKey[j] := t;
  end;
end;


{ TAESCipher }

procedure TAESCipher.Decode(Buf: Pointer; Len: Cardinal);
begin
end;

procedure TAESCipher.DecodeBlock(Buf: Pointer);
begin
end;

procedure TAESCipher.Encode(Buf: Pointer; Len: Cardinal);
var
  I, A: Integer;
  IB,OB,IVB: PByteArray;
  T:array [0..15] of Byte;
begin
  IB := buf;
  OB := buf;
  IVB := FIV;
  A := 0;
  while Len >= 16 do
  begin
    for i:= 0 to 15 do
      OB[i+A] := IB[i+A] xor IVB[i];
    EncodeBlock( @OB[A] );
    for i:= 0 to 15 do
      IVB[I] := OB[i+A];
    Inc(A,16);
    Dec(Len,16);
  end;
  if len > 16 then
  begin
    move(IB[A],T[0], Len);
    for i:= 0 to 15 do
      T[i] := T[i] xor IVB[i];
    DecodeBlock(@T[0]);
    for i:= 0 to 15 do
      IVB[I] := T[i];
    Move(T[0],OB[A],Len);
  end;
end;

procedure TAESCipher.EncodeBlock(Buf: Pointer);
var
  IA,OA: PByteArray;
  X0, X1, X2, X3, Y0, Y1, Y2, Y3, R: Cardinal;
begin
  IA := Buf;
  OA := Buf;
  R := 0;
  X0 := (IA[0] shl 24) or (IA[1] shl 16) or (IA[2] shl 8) or (IA[3] );
  X0 := X0 xor erk[0];
  X1 := (IA[4] shl 24) or (IA[5] shl 16) or (IA[6] shl 8) or (IA[7] );
  X1 := X1 xor erk[1];
  X2 := (IA[8] shl 24) or (IA[9] shl 16) or (IA[10] shl 8) or (IA[11] );
  X2 := X2 xor erk[2];
  X3 := (IA[12] shl 24) or (IA[13] shl 16) or (IA[14] shl 8) or (IA[15] );
  X3 := X3 xor erk[3];


  Inc(R,4);
  Y0 := erk[R+0] xor FT0[Byte( X0 shr 24 ) ] xor FT1[Byte( X1 shr 16 ) ] xor FT2[Byte( X2 shr 8 ) ] xor FT3[Byte( X3 ) ];
  Y1 := erk[R+1] xor FT0[Byte( X1 shr 24 ) ] xor FT1[Byte( X2 shr 16 ) ] xor FT2[Byte( X3 shr 8 ) ] xor FT3[Byte( X0 ) ];
  Y2 := erk[R+2] xor FT0[Byte( X2 shr 24 ) ] xor FT1[Byte( X3 shr 16 ) ] xor FT2[Byte( X0 shr 8 ) ] xor FT3[Byte( X1 ) ];
  Y3 := erk[R+3] xor FT0[Byte( X3 shr 24 ) ] xor FT1[Byte( X0 shr 16 ) ] xor FT2[Byte( X1 shr 8 ) ] xor FT3[Byte( X2 ) ];

  Inc(R,4);
  X0 := erk[R+0] xor FT0[Byte( Y0 shr 24 ) ] xor FT1[Byte( Y1 shr 16 ) ] xor FT2[Byte( Y2 shr 8 ) ] xor FT3[Byte( Y3 ) ];
  X1 := erk[R+1] xor FT0[Byte( Y1 shr 24 ) ] xor FT1[Byte( Y2 shr 16 ) ] xor FT2[Byte( Y3 shr 8 ) ] xor FT3[Byte( Y0 ) ];
  X2 := erk[R+2] xor FT0[Byte( Y2 shr 24 ) ] xor FT1[Byte( Y3 shr 16 ) ] xor FT2[Byte( Y0 shr 8 ) ] xor FT3[Byte( Y1 ) ];
  X3 := erk[R+3] xor FT0[Byte( Y3 shr 24 ) ] xor FT1[Byte( Y0 shr 16 ) ] xor FT2[Byte( Y1 shr 8 ) ] xor FT3[Byte( Y2 ) ];
  Inc(R,4);
  Y0 := erk[R+0] xor FT0[Byte( X0 shr 24 ) ] xor FT1[Byte( X1 shr 16 ) ] xor FT2[Byte( X2 shr 8 ) ] xor FT3[Byte( X3 ) ];
  Y1 := erk[R+1] xor FT0[Byte( X1 shr 24 ) ] xor FT1[Byte( X2 shr 16 ) ] xor FT2[Byte( X3 shr 8 ) ] xor FT3[Byte( X0 ) ];
  Y2 := erk[R+2] xor FT0[Byte( X2 shr 24 ) ] xor FT1[Byte( X3 shr 16 ) ] xor FT2[Byte( X0 shr 8 ) ] xor FT3[Byte( X1 ) ];
  Y3 := erk[R+3] xor FT0[Byte( X3 shr 24 ) ] xor FT1[Byte( X0 shr 16 ) ] xor FT2[Byte( X1 shr 8 ) ] xor FT3[Byte( X2 ) ];
  Inc(R,4);
  X0 := erk[R+0] xor FT0[Byte( Y0 shr 24 ) ] xor FT1[Byte( Y1 shr 16 ) ] xor FT2[Byte( Y2 shr 8 ) ] xor FT3[Byte( Y3 ) ];
  X1 := erk[R+1] xor FT0[Byte( Y1 shr 24 ) ] xor FT1[Byte( Y2 shr 16 ) ] xor FT2[Byte( Y3 shr 8 ) ] xor FT3[Byte( Y0 ) ];
  X2 := erk[R+2] xor FT0[Byte( Y2 shr 24 ) ] xor FT1[Byte( Y3 shr 16 ) ] xor FT2[Byte( Y0 shr 8 ) ] xor FT3[Byte( Y1 ) ];
  X3 := erk[R+3] xor FT0[Byte( Y3 shr 24 ) ] xor FT1[Byte( Y0 shr 16 ) ] xor FT2[Byte( Y1 shr 8 ) ] xor FT3[Byte( Y2 ) ];
  Inc(R,4);
  Y0 := erk[R+0] xor FT0[Byte( X0 shr 24 ) ] xor FT1[Byte( X1 shr 16 ) ] xor FT2[Byte( X2 shr 8 ) ] xor FT3[Byte( X3 ) ];
  Y1 := erk[R+1] xor FT0[Byte( X1 shr 24 ) ] xor FT1[Byte( X2 shr 16 ) ] xor FT2[Byte( X3 shr 8 ) ] xor FT3[Byte( X0 ) ];
  Y2 := erk[R+2] xor FT0[Byte( X2 shr 24 ) ] xor FT1[Byte( X3 shr 16 ) ] xor FT2[Byte( X0 shr 8 ) ] xor FT3[Byte( X1 ) ];
  Y3 := erk[R+3] xor FT0[Byte( X3 shr 24 ) ] xor FT1[Byte( X0 shr 16 ) ] xor FT2[Byte( X1 shr 8 ) ] xor FT3[Byte( X2 ) ];
  Inc(R,4);
  X0 := erk[R+0] xor FT0[Byte( Y0 shr 24 ) ] xor FT1[Byte( Y1 shr 16 ) ] xor FT2[Byte( Y2 shr 8 ) ] xor FT3[Byte( Y3 ) ];
  X1 := erk[R+1] xor FT0[Byte( Y1 shr 24 ) ] xor FT1[Byte( Y2 shr 16 ) ] xor FT2[Byte( Y3 shr 8 ) ] xor FT3[Byte( Y0 ) ];
  X2 := erk[R+2] xor FT0[Byte( Y2 shr 24 ) ] xor FT1[Byte( Y3 shr 16 ) ] xor FT2[Byte( Y0 shr 8 ) ] xor FT3[Byte( Y1 ) ];
  X3 := erk[R+3] xor FT0[Byte( Y3 shr 24 ) ] xor FT1[Byte( Y0 shr 16 ) ] xor FT2[Byte( Y1 shr 8 ) ] xor FT3[Byte( Y2 ) ];
  Inc(R,4);
  Y0 := erk[R+0] xor FT0[Byte( X0 shr 24 ) ] xor FT1[Byte( X1 shr 16 ) ] xor FT2[Byte( X2 shr 8 ) ] xor FT3[Byte( X3 ) ];
  Y1 := erk[R+1] xor FT0[Byte( X1 shr 24 ) ] xor FT1[Byte( X2 shr 16 ) ] xor FT2[Byte( X3 shr 8 ) ] xor FT3[Byte( X0 ) ];
  Y2 := erk[R+2] xor FT0[Byte( X2 shr 24 ) ] xor FT1[Byte( X3 shr 16 ) ] xor FT2[Byte( X0 shr 8 ) ] xor FT3[Byte( X1 ) ];
  Y3 := erk[R+3] xor FT0[Byte( X3 shr 24 ) ] xor FT1[Byte( X0 shr 16 ) ] xor FT2[Byte( X1 shr 8 ) ] xor FT3[Byte( X2 ) ];
  Inc(R,4);
  X0 := erk[R+0] xor FT0[Byte( Y0 shr 24 ) ] xor FT1[Byte( Y1 shr 16 ) ] xor FT2[Byte( Y2 shr 8 ) ] xor FT3[Byte( Y3 ) ];
  X1 := erk[R+1] xor FT0[Byte( Y1 shr 24 ) ] xor FT1[Byte( Y2 shr 16 ) ] xor FT2[Byte( Y3 shr 8 ) ] xor FT3[Byte( Y0 ) ];
  X2 := erk[R+2] xor FT0[Byte( Y2 shr 24 ) ] xor FT1[Byte( Y3 shr 16 ) ] xor FT2[Byte( Y0 shr 8 ) ] xor FT3[Byte( Y1 ) ];
  X3 := erk[R+3] xor FT0[Byte( Y3 shr 24 ) ] xor FT1[Byte( Y0 shr 16 ) ] xor FT2[Byte( Y1 shr 8 ) ] xor FT3[Byte( Y2 ) ];
  Inc(R,4);
  Y0 := erk[R+0] xor FT0[Byte( X0 shr 24 ) ] xor FT1[Byte( X1 shr 16 ) ] xor FT2[Byte( X2 shr 8 ) ] xor FT3[Byte( X3 ) ];
  Y1 := erk[R+1] xor FT0[Byte( X1 shr 24 ) ] xor FT1[Byte( X2 shr 16 ) ] xor FT2[Byte( X3 shr 8 ) ] xor FT3[Byte( X0 ) ];
  Y2 := erk[R+2] xor FT0[Byte( X2 shr 24 ) ] xor FT1[Byte( X3 shr 16 ) ] xor FT2[Byte( X0 shr 8 ) ] xor FT3[Byte( X1 ) ];
  Y3 := erk[R+3] xor FT0[Byte( X3 shr 24 ) ] xor FT1[Byte( X0 shr 16 ) ] xor FT2[Byte( X1 shr 8 ) ] xor FT3[Byte( X2 ) ];

  if nr > 10 then
  begin
    Inc(R,4);
    X0 := erk[R+0] xor FT0[Byte( Y0 shr 24 ) ] xor FT1[Byte( Y1 shr 16 ) ] xor FT2[Byte( Y2 shr 8 ) ] xor FT3[Byte( Y3 ) ];
    X1 := erk[R+1] xor FT0[Byte( Y1 shr 24 ) ] xor FT1[Byte( Y2 shr 16 ) ] xor FT2[Byte( Y3 shr 8 ) ] xor FT3[Byte( Y0 ) ];
    X2 := erk[R+2] xor FT0[Byte( Y2 shr 24 ) ] xor FT1[Byte( Y3 shr 16 ) ] xor FT2[Byte( Y0 shr 8 ) ] xor FT3[Byte( Y1 ) ];
    X3 := erk[R+3] xor FT0[Byte( Y3 shr 24 ) ] xor FT1[Byte( Y0 shr 16 ) ] xor FT2[Byte( Y1 shr 8 ) ] xor FT3[Byte( Y2 ) ];
    Inc(R,4);
    Y0 := erk[R+0] xor FT0[Byte( X0 shr 24 ) ] xor FT1[Byte( X1 shr 16 ) ] xor FT2[Byte( X2 shr 8 ) ] xor FT3[Byte( X3 ) ];
    Y1 := erk[R+1] xor FT0[Byte( X1 shr 24 ) ] xor FT1[Byte( X2 shr 16 ) ] xor FT2[Byte( X3 shr 8 ) ] xor FT3[Byte( X0 ) ];
    Y2 := erk[R+2] xor FT0[Byte( X2 shr 24 ) ] xor FT1[Byte( X3 shr 16 ) ] xor FT2[Byte( X0 shr 8 ) ] xor FT3[Byte( X1 ) ];
    Y3 := erk[R+3] xor FT0[Byte( X3 shr 24 ) ] xor FT1[Byte( X0 shr 16 ) ] xor FT2[Byte( X1 shr 8 ) ] xor FT3[Byte( X2 ) ];
  end;
  if nr > 12 then
  begin
    Inc(R,4);
    X0 := erk[R+0] xor FT0[Byte( Y0 shr 24 ) ] xor FT1[Byte( Y1 shr 16 ) ] xor FT2[Byte( Y2 shr 8 ) ] xor FT3[Byte( Y3 ) ];
    X1 := erk[R+1] xor FT0[Byte( Y1 shr 24 ) ] xor FT1[Byte( Y2 shr 16 ) ] xor FT2[Byte( Y3 shr 8 ) ] xor FT3[Byte( Y0 ) ];
    X2 := erk[R+2] xor FT0[Byte( Y2 shr 24 ) ] xor FT1[Byte( Y3 shr 16 ) ] xor FT2[Byte( Y0 shr 8 ) ] xor FT3[Byte( Y1 ) ];
    X3 := erk[R+3] xor FT0[Byte( Y3 shr 24 ) ] xor FT1[Byte( Y0 shr 16 ) ] xor FT2[Byte( Y1 shr 8 ) ] xor FT3[Byte( Y2 ) ];
    Inc(R,4);
    Y0 := erk[R+0] xor FT0[Byte( X0 shr 24 ) ] xor FT1[Byte( X1 shr 16 ) ] xor FT2[Byte( X2 shr 8 ) ] xor FT3[Byte( X3 ) ];
    Y1 := erk[R+1] xor FT0[Byte( X1 shr 24 ) ] xor FT1[Byte( X2 shr 16 ) ] xor FT2[Byte( X3 shr 8 ) ] xor FT3[Byte( X0 ) ];
    Y2 := erk[R+2] xor FT0[Byte( X2 shr 24 ) ] xor FT1[Byte( X3 shr 16 ) ] xor FT2[Byte( X0 shr 8 ) ] xor FT3[Byte( X1 ) ];
    Y3 := erk[R+3] xor FT0[Byte( X3 shr 24 ) ] xor FT1[Byte( X0 shr 16 ) ] xor FT2[Byte( X1 shr 8 ) ] xor FT3[Byte( X2 ) ];
  end;

  Inc(R,4);


  X0 := erk[R+0] xor ( FSb[Byte( Y0 shr 24 ) ] shl 24 ) xor ( FSb[Byte( Y1 shr 16 ) ] shl 16 ) xor
    ( FSb[Byte( Y2 shr  8 ) ] shl  8 ) xor ( FSb[Byte( Y3 ) ] );

  X1 := erk[R+1] xor ( FSb[Byte( Y1 shr 24 ) ] shl 24 ) xor ( FSb[Byte( Y2 shr 16 ) ] shl 16 ) xor
    ( FSb[Byte( Y3 shr  8 ) ] shl  8 ) xor ( FSb[Byte( Y0 ) ] );

  X2 := erk[R+2] xor ( FSb[Byte( Y2 shr 24 ) ] shl 24 ) xor ( FSb[Byte( Y3 shr 16 ) ] shl 16 ) xor
    ( FSb[Byte( Y0 shr  8 ) ] shl  8 ) xor ( FSb[Byte( Y1 ) ] );

  X3 := erk[R+3] xor ( FSb[Byte( Y3 shr 24 ) ] shl 24 ) xor ( FSb[Byte( Y0 shr 16 ) ] shl 16 ) xor
    ( FSb[Byte( Y1 shr  8 ) ] shl  8 ) xor ( FSb[Byte( Y2 ) ] );

  OA[0] := X0 shr 24 ; OA[1] := X0 shr 16 ; OA[2] := X0 shr 8; OA[3] := X0;
  OA[4] := X1 shr 24 ; OA[5] := X1 shr 16 ; OA[6] := X1 shr 8; OA[7] := X1;
  OA[8] := X2 shr 24 ; OA[9] := X2 shr 16 ; OA[10] := X2 shr 8; OA[11] := X2;
  OA[12] := X3 shr 24 ; OA[13] := X3 shr 16 ; OA[14] := X3 shr 8; OA[15] := X3;

end;

function TAESCipher.GetBlockSize: Cardinal;
begin
  Result := 16;
end;

function TAESCipher.GetIVSize: Cardinal;
begin
  Result := 16;
end;

procedure TAESCipher.Init(Key: Pointer; Len: Cardinal;  InitVector: Pointer);
var
  I: Integer;
  R: Cardinal;
  PKey: PByteArray;
begin
  FIV := InitVector;
  PKey := Key;
  case Len of
    256: nr := 14;
    192: nr := 12;
  else
    nr := 10;
  end;
  for i := 0 to (Len shr 5) - 1 do
    erk[I] := (PKey[I*4] shl 24 ) or (PKey[I*4+1] shl 16 ) or (PKey[I*4+2] shl 8 ) or (PKey[I*4+3] );
  R := 0;
  case nr of
    10:
      begin
        for I := 0  to 9 do
        begin
          erk[R+4] :=  erk[R] xor RCON[I] xor
            (FSb[Byte(erk[R+3] shr 16)] shl 24) xor
            (FSb[Byte(erk[R+3] shr  8)] shl 16) xor
            (FSb[Byte(erk[R+3]       )] shl  8) xor
            (FSb[Byte(erk[R+3] shr 24)]       );
          erk[R+5] := erk[R+1] xor erk[R+4];
          erk[R+6] := erk[R+2] xor erk[R+5];
          erk[R+7] := erk[R+3] xor erk[R+6];
          inc(R,4);
        end;
      end;
    14:
      begin
        for i := 0 to 6 do
        begin
          erk[R+8] :=  erk[R] xor RCON[I] xor
            (FSb[Byte(erk[R+7] shr 16)] shl 24) xor
            (FSb[Byte(erk[R+7] shr  8)] shl 16) xor
            (FSb[Byte(erk[R+7]       )] shl  8) xor
            (FSb[Byte(erk[R+7] shr 24)]       );
          erk[R+9] := erk[R+1] xor erk[R+8];
          erk[R+10] := erk[R+2] xor erk[R+9];
          erk[R+11] := erk[R+3] xor erk[R+10];

          erk[R+12] :=  erk[R+4] xor
            (FSb[Byte(erk[R+11] shr 24)] shl 24) xor
            (FSb[Byte(erk[R+11] shr 16)] shl 16) xor
            (FSb[Byte(erk[R+11] shr  8)] shl  8) xor
            (FSb[Byte(erk[R+11]       )]       );
          erk[R+13] := erk[R+5] xor erk[R+12];
          erk[R+14] := erk[R+6] xor erk[R+13];
          erk[R+15] := erk[R+7] xor erk[R+14];
        Inc(R, 8);
        end;
      end;
  end;
end;



end.
