{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFEngine;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif}
{$ifdef WIN64}
  System.ZLib, System.ZLibConst,
{$else}
  llPDFFlate,
{$endif}
  llPDFSecurity, llPDFPFX,
  llPDFTypes ;

{#int}  
type


  TPDFObject = class;
  TPDFEngine = class;

  TPDFResources = record
    Fonts: array of TPDFObject;
    Images: array of TPDFObject;
    LastFont:TPDFObject;
  end;


    ///  <summary> 
    /// The base class for the control and manipulation of PDF objects. All descendants of this class which are 
    /// used in the library to be created in TPDFDocument by themselves.
    ///  </summary> 
  TPDFManager = class (TObject)
  private
    function GetRefID: AnsiString;
  protected
    FEngine: TPDFEngine;
    FID: Integer;
    function GetID: Integer;
    procedure Clear;virtual;
    function GetCount:Integer;virtual; abstract;
    procedure Save;virtual; abstract;
  public
    constructor Create(PDFEngine: TPDFEngine);
    property Count: Integer read GetCount;
    property ID: Integer read GetID;
    property RefID:AnsiString read GetRefID;
  end;


  ///  <summary>
  /// The base class for the control and manipulation of of list of PDF objects
  ///  </summary>
  TPDFListManager = class (TPDFManager)
  private
  protected
    FList: TList;
    procedure Clear;override;
    function GetCount:Integer;override;
    procedure Save;override;
  public
    constructor Create(PDFEngine: TPDFEngine);
    destructor Destroy;override;
    procedure Add(PDFObject: TPDFObject);
{#int}    
  end;



  TPDFEngine = class(TObject)
  private
    FCapacity: Integer;
    FCurrentID: Integer;
    FIDOffset: array of Integer;
    FStream: TStream;
    FCompression: TCompressionType;
    FResolution: Integer;
    FGrayID: Integer;
    FRGBID: Integer;
    FCMYKID: Integer;
    FCurrentSaveID: Integer;
    procedure SetStream(const Value: TStream);
    function GetFileID: AnsiString;
    function GetGrayICCObject: Integer;
    function GetCMYKICCObject: Integer;
    function GetRGBICCObject: Integer;

  public
    Resources: TPDFResources;
    SecurityInfo: TPDFSecurity;
    RGBICCStream: TStream;
    CMYKICCStream: TStream;
    PDFACompatibile: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure CloseObj(IsDictionary:Boolean = True);
    procedure CloseStream;
    function GetNextID: Integer;
    function CreateMetadata(Data:Pointer; CryptData: Boolean): Integer;
    procedure InitSecurity(KeyLength: TPDFSecurityState;Options: TPDFSecurityPermissions;
      UserPassword, OwnerPassword, FileName :AnsiString; CryptMetadata:Boolean);
    procedure SaveHeader(MinVersion:TPDFMinVersion);
    procedure SaveToStream(st: AnsiString; CR: Boolean = True);
    procedure SaveXREFAndTrailer(CatalogID,InfoID, EncryptID:Integer; FileID:AnsiString);
    procedure StartObj(ID: Integer; IsDictionary:Boolean = true);
    procedure Reset;
    procedure StartStream;
    procedure SaveObject(PDFObject: TPDFObject);
    procedure SaveAdditional(PDFObject: TPDFObject);
    procedure SaveManager(Manager:TPDFManager);
    procedure ClearManager(Manager:TPDFManager);
    procedure SavePDFAFeatures;
    property Stream: TStream read FStream write SetStream;
    property FileID:AnsiString read GetFileID;
    property Compression: TCompressionType read FCompression write FCompression;
    property Resolution: Integer read FResolution write FResolution;
    property GrayICCObject:Integer read GetGrayICCObject;
    property RGBICCObject:Integer read GetRGBICCObject;
    property CMYKICCObject:Integer read GetCMYKICCObject;
  end;

   ///  <summary> 
   ///  The base class for the most primitive objects in the PDF document such as Images, forms and etc
   ///  </summary> 
  TPDFObject = class(TObject)
  private
    FID: Integer;
    FEngine: TPDFEngine;
    function GetID: Integer;
    function GetRefID: AnsiString;
  protected
    property Eng: TPDFEngine read FEngine;
    procedure CryptStream( AStream: TMemoryStream);
    function CryptString( Str:AnsiString):AnsiString;
    procedure Save; virtual; abstract;
    procedure SaveAdditional;virtual;
    procedure RegenerateID;
  public
    constructor Create(Engine:TPDFEngine);
    property ID: Integer read GetID;
    property RefID:AnsiString read GetRefID;
  end;


implementation


uses llPDFResources, llPDFMisc, llPDFDocument, llPDFCrypt;


const

   RGBICCDef : array [1..560 ] of Byte = (
      $00,$00,$02,$30,$41,$44,$42,$45,$02,$10,$00,$00,$6D,$6E,$74,$72,
      $52,$47,$42,$20,$58,$59,$5A,$20,$07,$D0,$00,$08,$00,$0B,$00,$13,
      $00,$33,$00,$3B,$61,$63,$73,$70,$41,$50,$50,$4C,$00,$00,$00,$00,
      $6E,$6F,$6E,$65,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $00,$00,$00,$00,$00,$00,$F6,$D6,$00,$01,$00,$00,$00,$00,$D3,$2D,
      $41,$44,$42,$45,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $00,$00,$00,$0A,$63,$70,$72,$74,$00,$00,$00,$FC,$00,$00,$00,$32,
      $64,$65,$73,$63,$00,$00,$01,$30,$00,$00,$00,$6B,$77,$74,$70,$74,
      $00,$00,$01,$9C,$00,$00,$00,$14,$62,$6B,$70,$74,$00,$00,$01,$B0,
      $00,$00,$00,$14,$72,$54,$52,$43,$00,$00,$01,$C4,$00,$00,$00,$0E,
      $67,$54,$52,$43,$00,$00,$01,$D4,$00,$00,$00,$0E,$62,$54,$52,$43,
      $00,$00,$01,$E4,$00,$00,$00,$0E,$72,$58,$59,$5A,$00,$00,$01,$F4,
      $00,$00,$00,$14,$67,$58,$59,$5A,$00,$00,$02,$08,$00,$00,$00,$14,
      $62,$58,$59,$5A,$00,$00,$02,$1C,$00,$00,$00,$14,$74,$65,$78,$74,
      $00,$00,$00,$00,$43,$6F,$70,$79,$72,$69,$67,$68,$74,$20,$32,$30,
      $30,$30,$20,$41,$64,$6F,$62,$65,$20,$53,$79,$73,$74,$65,$6D,$73,
      $20,$49,$6E,$63,$6F,$72,$70,$6F,$72,$61,$74,$65,$64,$00,$00,$00,
      $64,$65,$73,$63,$00,$00,$00,$00,$00,$00,$00,$11,$41,$64,$6F,$62,
      $65,$20,$52,$47,$42,$20,$28,$31,$39,$39,$38,$29,$00,$00,$00,$00,
      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$58,$59,$5A,$20,
      $00,$00,$00,$00,$00,$00,$F3,$51,$00,$01,$00,$00,$00,$01,$16,$CC,
      $58,$59,$5A,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $00,$00,$00,$00,$63,$75,$72,$76,$00,$00,$00,$00,$00,$00,$00,$01,
      $02,$33,$00,$00,$63,$75,$72,$76,$00,$00,$00,$00,$00,$00,$00,$01,
      $02,$33,$00,$00,$63,$75,$72,$76,$00,$00,$00,$00,$00,$00,$00,$01,
      $02,$33,$00,$00,$58,$59,$5A,$20,$00,$00,$00,$00,$00,$00,$9C,$18,
      $00,$00,$4F,$A5,$00,$00,$04,$FC,$58,$59,$5A,$20,$00,$00,$00,$00,
      $00,$00,$34,$8D,$00,$00,$A0,$2C,$00,$00,$0F,$95,$58,$59,$5A,$20,
      $00,$00,$00,$00,$00,$00,$26,$31,$00,$00,$10,$2F,$00,$00,$BE,$9C );


{ TPDFEngine }

{
********************************** TPDFEngine **********************************
}
constructor TPDFEngine.Create;
begin
  FCurrentID := 0;
  FCapacity := 0;
  FIDOffset := nil;
  FGrayID := 0 ;
  FRGBID := 0 ;
  FCMYKID := 0;
end;

destructor TPDFEngine.Destroy;
begin
  FIDOffset := nil;
  inherited;
end;

procedure TPDFEngine.CloseObj(IsDictionary:Boolean = True);
begin
  if IsDictionary then
    SaveToStream('>>'#10'endobj')
  else
    SaveToStream(#10'endobj');
  FCurrentSaveID := -1;
end;

procedure TPDFEngine.CloseStream;
begin
  SaveToStream(#10'endstream'#10'endobj');
  FCurrentSaveID := -1;
end;

function TPDFEngine.GetNextID: Integer;
var
  Delta: Integer;
begin
   if FCurrentID >= FCapacity then
   begin
     if FCapacity > 64 then
       Delta := FCapacity div 4
     else
       if FCapacity > 8 then
         Delta := 16
       else
         Delta := 4;
     FCapacity := FCapacity + Delta;
     SetLength(FIDOffset, FCapacity);
  end;
  Inc(FCurrentID);
  Result := FCurrentID;
end;


procedure TPDFEngine.InitSecurity( KeyLength: TPDFSecurityState;
      Options: TPDFSecurityPermissions; UserPassword, OwnerPassword, FileName :AnsiString; CryptMetadata:Boolean);
begin
  InitDocumentSecurity( SecurityInfo, KeyLength, Options, UserPassword, OwnerPassword, FileName, CryptMetadata);
end;

procedure TPDFEngine.SaveHeader(MinVersion:TPDFMinVersion);
begin
  case MinVersion of
    pdfver15:SaveToStream('%PDF-1.5');
    pdfver17:SaveToStream('%PDF-1.7');
  else
    SaveToStream('%PDF-1.4')
  end;
  SaveToStream ( AnsiString('%“Â—Ú') );
end;

procedure TPDFEngine.SaveToStream(st: AnsiString; CR: Boolean = True);
var
  WS: AnsiString;
  Ad: Pointer;
begin
  WS := st;
  if CR then
    WS := WS + #13#10;
  Ad := @WS [ 1 ];
  FStream.Write ( ad^, Length ( WS ) );
end;

procedure TPDFEngine.SaveXREFAndTrailer(CatalogID,InfoID, EncryptID:Integer;
        FileID:AnsiString);
var
  I, XREFOffset: Integer;
begin
  XREFOffset := FStream.Position;
  SaveToStream ( 'xref' );
  SaveToStream ( '0 ' + IStr ( FCurrentID + 1 ) );
  SaveToStream ( IntToStrWithZero ( 0, 10 ) + ' ' + IStr ( $FFFF ) + ' f' );
  for I := 0 to FCurrentID - 1 do
    SaveToStream ( IntToStrWithZero ( FIDOffset [ I ], 10 ) + ' 00000 n' );
  SaveToStream ( 'trailer' );
  SaveToStream ( '<<' );
  SaveToStream ( '/Size ' + IStr ( FCurrentID + 1 ) );
  SaveToStream ( '/Root ' + GetRef( CatalogID ));
  SaveToStream ( '/Info ' + GetRef( InfoID ));
  if EncryptID >0 then
    SaveToStream ( '/Encrypt ' + GetRef(EncryptID ) );
  SaveToStream ( '/ID [<' + FileID + '><' + FileID + '>]' );
  SaveToStream ( '>>' );
  SaveToStream ( 'startxref' );
  SaveToStream ( IStr ( XREFOffset ) );
  SaveToStream ( '%%EOF' );
end;

procedure TPDFEngine.SetStream(const Value: TStream);
begin
  FStream := Value;
end;

procedure TPDFEngine.StartObj(ID: Integer; IsDictionary:Boolean = true);
var
  Offset: Integer;
begin
  Offset := FStream.Position;
  if ID > FCurrentID then
    raise EPDFException.Create ( SOutOfRange );
  FIDOffset [ ID - 1 ] := Offset;
  FCurrentSaveID := ID;
  if IsDictionary then
    SaveToStream ( IStr ( ID ) + ' 0 obj'#13#10'<<',False )
  else
    SaveToStream ( IStr ( ID ) + ' 0 obj' );
end;

procedure TPDFEngine.StartStream;
begin
  SaveToStream('>>'#10'stream');
end;

function TPDFEngine.GetFileID: AnsiString;
begin
  Result := SecurityInfo.FileID;
end;


procedure TPDFEngine.SaveObject(PDFObject: TPDFObject);
begin
  PDFObject.Save;
end;

function TPDFEngine.GetGrayICCObject: Integer;
begin
  if FGrayID = 0 then
  begin
    FGrayID := GetNextID;
  end;
  Result := FGrayID;
end;

function TPDFEngine.GetRGBICCObject: Integer;
begin
  if FRGBID = 0 then
  begin
    FRGBID := GetNextID;
  end;
  Result := FRGBID;
end;

function TPDFEngine.GetCMYKICCObject: Integer;
begin
  if FCMYKID = 0 then
  begin
    FCMYKID := GetNextID;
  end;
  Result := FCMYKID;
end;


procedure TPDFEngine.ClearManager(Manager: TPDFManager);
begin
  Manager.Clear;
end;

procedure TPDFEngine.SaveManager(Manager: TPDFManager);
begin
  Manager.Save;
end;

procedure TPDFEngine.SavePDFAFeatures;
var
  MS: TMemoryStream;
  CS: TCompressionStream;
  ID: Integer;
begin
  if FGrayID > 0 then
  begin
    StartObj(FGrayID, false);
    SaveToStream('[/CalGray <</WhitePoint [0.9505 1 1.089]>>]');
    CloseObj(False);
  end;
  if FRGBID > 0 then
  begin
    ID := GetNextID;
    startObj(ID);
    MS := TMemoryStream.Create;
    try
      CS := TCompressionStream.Create(clDefault,MS);
      try
       if RGBICCStream = nil then
         cs.Write(RGBICCDef,560)
       else
         CS.CopyFrom(RGBICCStream, RGBICCStream.Size);
      finally
        CS.Free;
      end;
      SaveToStream ( '/Length ' + IStr ( CalcAESSize( SecurityInfo.State, MS.size ) ) );
      SaveToStream ( '/Filter /FlateDecode/N 3' );
      StartStream;
      MS.Position := 0;
      CryptStreamToStream ( SecurityInfo,MS, Stream, ID );
    finally
      MS.Free;
    end;
    CloseStream;
    startObj(FRGBID, False);
    SaveToStream('[/ICCBased '+GetRef(ID)+']');
    Closeobj(False);
  end;

  if FCMYKID > 0 then
  begin
    ID := GetNextID;
    startObj(ID);
    MS := TMemoryStream.Create;
    try
      CS := TCompressionStream.Create(clDefault,MS);
      try
         CS.CopyFrom(CMYKICCStream, CMYKICCStream.Size);
      finally
        CS.Free;
      end;
      SaveToStream ( '/Length ' + IStr ( CalcAESSize( SecurityInfo.State,MS.size ) ) );
      SaveToStream ( '/Filter /FlateDecode/N 3' );
      StartStream;
      MS.Position := 0;
      CryptStreamToStream ( SecurityInfo,MS, Stream, ID );
    finally
      MS.Free;
    end;
    CloseStream;
    startObj(FCMYKID, False);
    SaveToStream('[/ICCBased '+GetRef(ID)+']');
    CloseObj(False);
  end;

end;

procedure TPDFEngine.Reset;
begin
  FCurrentID := 0;
  FCapacity := 0;
  FIDOffset := nil;
  FGrayID := 0 ;
  FRGBID := 0 ;
  FCMYKID := 0;
  FCurrentSaveID := -1;
end;

procedure TPDFEngine.SaveAdditional(PDFObject: TPDFObject);
begin
  PDFObject.SaveAdditional;
end;

function TPDFEngine.CreateMetadata(Data:Pointer; CryptData: Boolean): Integer;
var
  ID: Integer;
  St: TAnsiStringList;
  D: TPDFDocInfo;
  s: AnsiString;
begin
  D := TPDFDocInfo(Data);
  St := TAnsiStringList.Create;
  try
    St.Add(AnsiString('<?xpacket begin="'#239#187#191'" id="W5M0MpCehiHzreSzNTczkc9d"?>'));
    St.Add('<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="llPDFLib">');
    St.Add('   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">');
    St.Add('  <rdf:Description rdf:about=""');
    St.Add('        xmlns:xmp="http://ns.adobe.com/xap/1.0/">');
    St.Add('     <xmp:CreateDate>'+AnsiString(FormatDateTime('yyyy-mm-dd',D.CreationDate))+'T'
    +AnsiString(FormatDateTime('hh:nn:ss',D.CreationDate))+'Z</xmp:CreateDate>');
    St.Add('     <xmp:ModifyDate>'+AnsiString(FormatDateTime('yyyy-mm-dd',D.CreationDate))+'T'
    +AnsiString(FormatDateTime('hh:nn:ss',D.CreationDate))+'Z</xmp:ModifyDate>');
    St.Add('     <xmp:CreatorTool>'+
{$ifdef UNICODE}
      WideStringToUTF8(D.Creator)
{$else}
      D.Creator
{$endif}
    +'</xmp:CreatorTool>');
    St.Add('  </rdf:Description>');
    St.Add('  <rdf:Description rdf:about=""');
    St.Add('        xmlns:dc="http://purl.org/dc/elements/1.1/">');
    St.Add('     <dc:title>');
    St.Add('        <rdf:Alt>');
    St.Add('           <rdf:li xml:lang="x-default">'+
{$ifdef UNICODE}
      WideStringToUTF8(D.Title)
{$else}
      D.Title
{$endif}
    +'</rdf:li>');
    St.Add('        </rdf:Alt>');
    St.Add('     </dc:title>');
    St.Add('     <dc:creator>');
    St.Add('        <rdf:Seq>');
    St.Add('           <rdf:li>'+
{$ifdef UNICODE}
      WideStringToUTF8(D.Author)
{$else}
      D.Author
{$endif}
    +'</rdf:li>');
    St.Add('        </rdf:Seq>');
    St.Add('     </dc:creator>');
    St.Add('     <dc:description>');
    St.Add('        <rdf:Alt>');
    St.Add('           <rdf:li xml:lang="x-default">'+
{$ifdef UNICODE}
      WideStringToUTF8(D.Subject)
{$else}
      D.Subject
{$endif}
    +'</rdf:li>');
    St.Add('        </rdf:Alt>');
    St.Add('     </dc:description>');
    St.Add('  </rdf:Description>');
    St.Add('  <rdf:Description rdf:about=""');
    St.Add('        xmlns:pdf="http://ns.adobe.com/pdf/1.3/">');
    St.Add('     <pdf:Keywords>'+
{$ifdef UNICODE}
      WideStringToUTF8(D.Keywords)
{$else}
      D.Keywords
{$endif}
    +'</pdf:Keywords>');
    St.Add('     <pdf:Producer>llPDFLib 6.x (http://www.sybrex.com)</pdf:Producer>');
    St.Add('  </rdf:Description>');
    if PDFACompatibile then
    begin
      St.Add('  <rdf:Description rdf:about=""');
      St.Add('        xmlns:pdfaid="http://www.aiim.org/pdfa/ns/id/">');
      St.Add('     <pdfaid:part>1</pdfaid:part>');
      St.Add('     <pdfaid:conformance>B</pdfaid:conformance>');
      St.Add('  </rdf:Description>');
    end;
    St.Add('   </rdf:RDF>');
    St.Add('</x:xmpmeta>');
    St.Add('<?xpacket end="w"?>');

    s := St.Text;
    ID := GetNextID;
    StartObj(ID,true);
    SaveToStream('/Subtype/XML/Type/Metadata');
    if not CryptData then
    begin
      SaveToStream ( '/Length ' + IStr ( Length(S) ) );
      StartStream;
      Stream.Write ( s[1], Length ( S ) );
      CloseStream;
    end else
    begin
      SaveToStream ( '/Length ' + IStr ( CalcAESSize(SecurityInfo.State, Length( S ) ) ) );
      StartStream;
      CryptStringToStream(SecurityInfo,Stream, S,ID );
      CloseStream;
    end;
  finally
    St.Free;
  end;
  Result := ID;
end;

{
********************************** TPDFObject **********************************
}
constructor TPDFObject.Create(Engine:TPDFEngine);
begin
  FEngine := Engine;
  FID := 0;
end;

procedure TPDFObject.CryptStream(AStream: TMemoryStream);
begin
  CryptStreamToStream(FEngine.SecurityInfo, AStream, FEngine.FStream, FID);
end;

function TPDFObject.CryptString(Str: AnsiString): AnsiString;
begin
  Result := llPDFSecurity.CryptString(FEngine.SecurityInfo, str, ID );
end;



function TPDFObject.GetID: Integer;
begin
  if FID = 0 then
    FID := FEngine.GetNextID;
  Result := FID;
end;


function TPDFObject.GetRefID: AnsiString;
begin
  Result := IStr(ID)+' 0 R';
end;

procedure TPDFObject.RegenerateID;
begin
  FID := 0;
end;

procedure TPDFObject.SaveAdditional;
begin

end;


{ TPDFManager }

procedure TPDFManager.Clear;
begin
  FID := 0;
end;

constructor TPDFManager.Create(PDFEngine: TPDFEngine);
begin
  FEngine := PDFEngine;
end;



function TPDFManager.GetID: Integer;
begin
  if FID = 0 then
    FID := FEngine.GetNextID;
  Result := FID;
end;

function TPDFManager.GetRefID: AnsiString;
begin
  Result := IStr(FID)+' 0 R';
end;

{ TPDFListManager }

procedure TPDFListManager.Add(PDFObject: TPDFObject);
begin
  FList.Add(PDFObject);
end;

procedure TPDFListManager.Clear;
var
  i:Integer;
begin
  inherited;
  if not Assigned(FList) then
    exit;
  for i:= 0 to FList.Count -1 do
    TPDFObject(FList[i]).Free;
  FList.Clear;
end;

constructor TPDFListManager.Create(PDFEngine: TPDFEngine);
begin
  inherited Create( PDFEngine);
  FList := TList.Create;
end;

destructor TPDFListManager.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TPDFListManager.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TPDFListManager.Save;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    TPDFObject(FList[i]).Save;
end;

end.

