{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFDocument;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, ShellAPI,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, WinAPI.ShellAPI,
{$endif}
{$ifdef WIN64}
  System.ZLib, System.ZLibConst,
{$else}
  llPDFFlate,
{$endif}
  llPDFSecurity, llPDFEMF, llPDFEngine,
  llPDFCanvas, llPDFImage, llPDFFont, llPDFTypes, llPDFOutline,
  llPDFAction, llPDFAnnotation, llPDFNames;
type


  /// <summary>
  ///   A PDF document may include a document information containing general information such as the
  ///   document's title, author, and creation and modification dates. <br />Such global information about
  ///   the document itself (as opposed to its content or structure) is called metadata, and is intended to
  ///   assist in cataloguing and searching for documents in external databases. <br />You can set this
  ///   information with help of the TPDFDocInfo object.
  /// </summary>
  TPDFDocInfo = class(TPersistent)
  private
    FAuthor: string;
    FCreationDate: TDateTime;
    FCreator: string;
    FKeywords: string;
    FProducer: string;
    FSubject: string;
    FTitle: string;
  protected
    procedure  Save(ID: Integer;PDFEngine: TPDFEngine);
  public
    /// <summary>
    ///   Specifies creation date of the document
    /// </summary>
  property CreationDate: TDateTime read FCreationDate write FCreationDate;
    /// <summary>
    ///   Specifies producer name of the generated file.
    /// </summary>
    /// <remarks>
    ///   This property can not be changed because of restrictions in the license agreement
    /// </remarks>
    property Producer: string read FProducer;
  published
    /// <summary>
    ///   Specifies author name of the generated file.
    /// </summary>
    property Author: string read FAuthor write FAuthor;
    /// <summary>
    ///   Specifies application name where generated file was created
    /// </summary>
    property Creator: string read FCreator write FCreator;
    /// <summary>
    ///   Specifies keywords in the generated document
    /// </summary>
    property Keywords: string read FKeywords write FKeywords;
    /// <summary>
    ///   Specifies description of the generated document
    /// </summary>
    property Subject: string read FSubject write FSubject;
    /// <summary>
    ///   Specifies title of the generated document
    /// </summary>
    property Title: string read FTitle write FTitle;
  end;


  TPDFDocument = class;

  /// <summary>
  ///   The main class of library which is used to make all manipulations with the generated PDF document.
  /// </summary>
  TPDFDocument = class(TComponent)
  private
    FAborted: Boolean;
    FAcroForms: TPDFAcroForms;
    FActions: TPDFActions;
    FACURL: Boolean;
    FAutoLaunch: Boolean;
    FCompression: TCompressionType;
    FDocumentInfo: TPDFDocInfo;
    FEngine: TPDFEngine;
    FFileName: string;
    FImages: TPDFImages;
    FFonts: TPDFFonts;
    FForms: TPDFListManager;
    FPatterns: TPDFListManager;
    FGStates: TPDFListManager;
    FOptionalContents: TOptionalContents;
    FJPEGQuality: Integer;
    FNames: TPDFNames;
    FOnePass: Boolean;
    FOpenDocumentAction: TPDFAction;
    FOutlines: TPDFOutlines;
    FOutputStream: TStream;
    FPageLayout: TPageLayout;
    FPageMode: TPageMode;
    FPages: TPDFPages;
    FPrinting: Boolean;
    FResolution: Integer;
    FSecurity: TPDFSecurityOptions;
    FStream: TStream;
    FViewerPreferences: TViewerPreferences;
    FPDFACompatible: Boolean;
    FCMYKICCStream: TStream;
    FRGBICCStream: TStream;
    FDigSignature:TPDFSignature;
    procedure ClearAll;
    function GetAutoCreateURL: Boolean;
    function GetCanvas: TCanvas;
    function GetCount: Integer;
    function GetCurrentPage: TPDFPage;
    function GetCurrentPageIndex: Integer;
    function GetEMFOptions: TPDFEMFParseOptions;
    function GetImages: TPDFImages;
    function GetNonEmbeddedFonts: TStringList;
    function GetPage(Index: Integer): TPDFPage;
    function GetPageNumber: Integer;
    procedure SaveCryptDictionary(ID: Integer);
    procedure SetAutoCreateURL(const Value: Boolean);
    procedure SetCurrentPageIndex(Index: Integer);
    procedure SetDocumentInfo(const Value: TPDFDocInfo);
    procedure SetFileName(const Value: string);
    procedure SetJPEGQuality(const Value: Integer);
    procedure SetOnePass(const Value: Boolean);
    procedure SetOutputStream(const Value: TStream);
    procedure SetSecurity(const Value: TPDFSecurityOptions);
    procedure StoreDocument;
    procedure SetCompression(const Value: TCompressionType);
    procedure SetNonEmbeddedFonts(const Value: TStringList);
    procedure SetResolution(const Value: Integer);
    procedure SetOpenDocumentAction(const Value: TPDFAction);
    procedure SetPDFACompatible(const Value: Boolean);
    procedure SetCMYKICCStream(const Value: TStream);
    procedure SetRGBICCStream(const Value: TStream);
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFDocument
    /// </summary>
    /// <param name="AOwner">
    ///   Establishes the relationship of a component and its Owner
    /// </param>
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    /// <summary>
    ///   It stops the creation of PDF document. All data that are sent to a file will be lost
    /// </summary>
    procedure Abort;
    /// <summary>
    ///   Adds new extanded graphical state to PDF document
    /// </summary>
    /// <returns>
    ///   Returns new, just created, extended graphical state.
    /// </returns>
    function AppendExtGState: TPDFGState;
    /// <summary>
    ///   Procedure adds a new form in the document
    /// </summary>
    /// <param name="OptionalContent">
    ///   Optional content, at start of which this form will be seen. If the value 
    ///    is nil, the form will be seen everywhere, where it will be depicted.
    /// </param>
    /// <returns>
    ///   Returns created and initialized form
    /// </returns>
    function AppendForm(OptionalContent:TOptionalContent= nil): TPDFForm;
    /// <summary>
    ///   Adds a new pattern to the PDF document.
    /// </summary>
    function AppendPattern: TPDFPattern;
    /// <summary>
    ///   Adds new optional content  to the PDF document
    /// </summary>
    /// <param name="LayerName">
    ///   Name of new optional content
    /// </param>
    /// <param name="StartVisible">
    ///  Specifies, whether this content will be visible when opening the document
    /// </param>
    /// <param name="CanExchange">
    ///   Specifies the possibility to change this content by the user
    /// </param>
    function AppendOptionalContent(LayerName:AnsiString;StartVisible:Boolean;CanExchange:Boolean=True):TOptionalContent;
    /// <summary>
    ///   Begins a new PDF document. Adds the first page in the created document.
    /// </summary>
    procedure BeginDoc;
    /// <summary>
    ///   Ends creation work of PDF document. Resets to the output stream all unsaved data.
    /// </summary>
    procedure EndDoc;
    /// <summary>
    ///   Adds a new page in  PDF document and transfers Canvas to this page.
    /// </summary>
    procedure NewPage;
    /// <summary>
    ///   Adds the digital signature to the generated document.
    /// </summary>
    /// <param name="APFXStream">
    ///   Stream with PFX structure inside
    /// </param>
    /// <param name="Password">
    ///   Password to decode PFX of the document
    /// </param>
    procedure AppendDigitalSignatureKeys(APFXStream:TStream;Password:string);overload;
    /// <summary>
    ///   Adds the digital signature to the generated document.
    /// </summary>
    /// <param name="APFXFile">
    ///   File name with PFX structure inside
    /// </param>
    /// <param name="Password">
    ///   Password to decode PFX of the document
    /// </param>
    procedure AppendDigitalSignatureKeys(APFXFile:string;Password:string);overload;
    /// <summary>
    ///   Parameter that specifies the digital signature of the generated document
    /// </summary>
    /// <remarks>
    ///   This parameter will be available only after valid request of AppendDigitalSignatureKeys
    /// </remarks>
    property DigitalSignature:TPDFSignature read FDigSignature;
    /// <summary>
    ///   Defines whether Abort was performed after beginning of creation of PDF document.
    /// </summary>
    property Aborted: Boolean read FAborted;
    /// <summary>
    ///   Acroforms manager. Necessary at creating new acroform controls
    /// </summary>
    property AcroForms: TPDFAcroForms read FAcroForms;
    /// <summary>
    ///   Actions manager, which is used when creating all actions in object.
    /// </summary>
    property Actions: TPDFActions read FActions;
    /// <summary>
    ///   Images manager, allowing to add new images to the document
    /// </summary>
    property Images: TPDFImages read GetImages;
    /// <summary>
    ///   Names manager, allowing to add named objects, such as files, destinations, 
    ///   javascripts
    /// </summary>
    property Names: TPDFNames read FNames;
    /// <summary>
    ///   outlines manager, allowing to manipulate this objects in the generated file
    /// </summary>
    property Outlines: TPDFOutlines read FOutlines;
    /// <summary>
    ///   Standard TCanvas, which you can manipulate as standard HDC
    /// </summary>
    property Canvas: TCanvas read GetCanvas;
    /// <summary>
    ///   The current page in the document, which can be manipulate with drawing
    /// </summary>
    property CurrentPage: TPDFPage read GetCurrentPage;
    /// <summary>
    ///   Determines the index of the current page in the document. It starts from zero for the first page.
    /// </summary>
    property CurrentPageIndex: Integer read GetCurrentPageIndex write SetCurrentPageIndex;
    /// <summary>
    ///   Defines a list of TTF fonts that will not be introduced into the document.
    /// </summary>
    property NonEmbeddedFonts: TStringList read GetNonEmbeddedFonts write SetNonEmbeddedFonts;

    /// <summary>
    ///   If this property is set, then the output of the generated document is active in
     /// stream and not in a file.
    /// </summary>
    property OutputStream: TStream read FOutputStream write SetOutputStream;
    /// <summary>
    ///   It provides direct access to all pages of the document
    /// </summary>
    /// <remarks>
    ///   When you try to access directly to the pages that One Pass is set as true, 
    ///   an exception will be called
    /// </remarks>
    property Page[Index: Integer]: TPDFPage read GetPage; default;
    /// <summary>
    ///   Number of created pages in the document.
    /// </summary>
    property PageCount: Integer read GetCount;
    /// <summary>
    ///   Determines the index of the current page in the document. It starts with one for the first page. Is made
     /// for compatibility with TPrinter.
    /// </summary>
    property PageNumber: Integer read GetPageNumber;
    /// <summary>
    ///   Determines whether the component is in the process of creating a new document.   
    /// </summary>
    property Printing: Boolean read FPrinting;
    /// <summary>
    ///   It determines the action to be performed when you open a document in PDF viewer.    
    /// </summary>
    property OpenDocumentAction: TPDFAction write SetOpenDocumentAction;
    /// <summary>
    ///   Specifies the stream from which to read CMYK ICC data during the creation of PDF / A compliant
     /// document.
    /// </summary>
    /// <remarks>
    ///   If the stream is not set, and the document uses CMYK colors, the exception will be called.
    /// </remarks>
    property CMYKICCStream: TStream read FCMYKICCStream write SetCMYKICCStream;
    /// <summary>
    ///   Specifies the stream from which to read RGB ICC data during the creation of PDF / A compliant
     /// document.
    /// </summary>
    /// <remarks>
    ///   If the stream is not specified in the document, RGB color is used in the document 
    /// standard RGB ICC file will be used
    /// </remarks>
    property RGBICCStream: TStream read FRGBICCStream write SetRGBICCStream;
  published
    /// <summary>
    ///   It determines need to create a URL when you create a document and add it to the outputted page.
    /// </summary>
    property AutoCreateURL: Boolean read GetAutoCreateURL write SetAutoCreateURL;
    /// <summary>
    ///   Specifies whether to open the generated PDF file after it is created in default PDF 
   ///   viewer
    /// </summary>
    property AutoLaunch: Boolean read FAutoLaunch write FAutoLaunch;
    /// <summary>
    ///   Specifies whether to use compression for the content of the canvas in the PDF document.
    /// </summary>
    property Compression: TCompressionType read FCompression write SetCompression;
    /// <summary>
    ///   Property defines information about a PDF document.
    /// </summary>
    property DocumentInfo: TPDFDocInfo read FDocumentInfo write SetDocumentInfo;
    /// <summary>
    ///   Defines a list of parameters to be taken into account when parsing an EMF document.
    /// </summary>
    property EMFOptions: TPDFEMFParseOptions read GetEMFOptions;
    /// <summary>
    ///   Name of created PDF document. If OutputStream specified, this value is ignored.
    /// </summary>
    property FileName: string read FFileName write SetFileName;
    /// <summary>
    ///   Specifies the compression level for images to be stored in JPEG.
    /// </summary>
    property JPEGQuality: Integer read FJPEGQuality write SetJPEGQuality;
    /// <summary>
    ///   Document creation in one pass.
    /// </summary>
    /// <remarks>
    ///   This property is recommended when creating large documents. When newly created
     /// The contents of the canvas will be directly written to the output stream, while creating the next page. In connection with
     /// this can not be changed CurrentPageIndex. 
    /// </remarks>
    property OnePass: Boolean read FOnePass write SetOnePass;
    /// <summary>
    ///   It determines the layout of the page at the time of opening
    /// </summary>
    property PageLayout: TPageLayout read FPageLayout write FPageLayout;
    /// <summary>
    ///   It determines how the document should be displayed at the opening of the document
    /// </summary>
    property PageMode: TPageMode read FPageMode write FPageMode;
    /// <summary>
    ///   Specifies the resolution, which is used in the newly created pages.
    /// </summary>
    property Resolution: Integer read FResolution write SetResolution;
    /// <summary>
    ///   It defines the properties associated with the document encryption.
    /// </summary>
    property Security: TPDFSecurityOptions read FSecurity write SetSecurity;
    /// <summary>
    ///   It specifies the properties of PDF viewer at the opening of the document
    /// </summary>
    property ViewerPreferences: TViewerPreferences read FViewerPreferences write FViewerPreferences;
    /// <summary>
    ///   Specifies whether to create a document that is compatible with PDF / A standard.
    /// </summary>
    property PDFACompatible: Boolean read FPDFACompatible write SetPDFACompatible;
  end;


implementation

uses llPDFResources, llPDFMisc, llPDFPFX, llPDFJBIG2, llPDFCrypt;

{
********************************* TPDFDocument *********************************
}
constructor TPDFDocument.Create(AOwner: TComponent);
begin
  inherited Create ( AOwner );
  FOutputStream := nil;
  FJPEGQuality := 80;
  FAborted := False;
  FPrinting := False;
  FOnePass := False;
  FACURL := True;
  FAutoLaunch := False;
  FPDFACompatible := False;

  FSecurity := TPDFSecurityOptions.Create;

  FEngine := TPDFEngine.Create;


  Resolution := 72;
  FEngine.Resolution := 72;
  Compression := ctFlate;
  FFonts := TPDFFonts.Create( FEngine );
  FPages := TPDFPages.Create(Self, FEngine, FFonts);
  FImages := TPDFImages.Create(FEngine);
  FActions := TPDFActions.Create(FEngine, FPages);
  FOutlines := TPDFOutlines.Create(FEngine);
  FAcroForms := TPDFAcroForms.Create(FEngine,FFonts);
  FForms := TPDFListManager.Create(FEngine);
  FPatterns := TPDFListManager.Create(FEngine);
  FGStates := TPDFListManager.Create( FEngine);
  FNames := TPDFNames.Create(FEngine, FPages);
  FOptionalContents := TOptionalContents.Create( FEngine);

  FPages.Patterns := FPatterns;
  FPages.Images := FImages;
  FPages.Actions := FActions;

  FDocumentInfo := TPDFDocInfo.Create;
  FDocumentInfo.Creator := 'llPDFLib Application';
  FDocumentInfo.Keywords := 'llPDFLib';
  FDocumentInfo.FProducer := 'llPDFLib 6.x (http://www.sybrex.com)';
  FDocumentInfo.Author := 'Windows User';
  FDocumentInfo.Title := 'No Title';
  FDocumentInfo.Subject := 'None';

  FSecurity.CryptMetadata := True;
  FDocumentInfo.CreationDate := Now;
  FSecurity.State := ssNone;
end;

destructor TPDFDocument.Destroy;
begin
  ClearAll;
  FNames.Free;
  FPatterns.Free;
  FPages.Free;
  FDocumentInfo.Free;
  FSecurity.Free;
  FFonts.Free;
  FImages.Free;
  FOutlines.Free;
  FForms.Free;
  FAcroForms.Free;
  FGStates.Free;
  FOptionalContents.Free;
  FEngine.Free;
  FActions.Free;
  inherited;
end;

procedure TPDFDocument.Abort;
begin
  ClearAll;
  if FOutputStream = nil then
    DeleteFile ( FileName );
  FAborted := True;
  FPrinting := False;
end;

function TPDFDocument.AppendPattern: TPDFPattern;
begin
  Result := TPDFPattern.Create(FEngine,FFonts);
  FPatterns.Add(Result);
end;

function TPDFDocument.AppendExtGState: TPDFGState;
begin
  Result := TPDFGState.Create(FEngine);
  FGStates.Add(Result);
end;


procedure TPDFDocument.BeginDoc;
begin
  ClearAll;
  if FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileInProgress );
  FEngine.InitSecurity ( FSecurity.State, FSecurity.Permissions,
    FSecurity.UserPassword, FSecurity.OwnerPassword, AnsiString(FileName), FSecurity.CryptMetadata);
  if FOutputStream = nil then
    FStream := TFileStream.Create ( FileName, fmCreate )
  else
    FStream := TMemoryStream.Create;
  FEngine.Stream := FStream;
  if FEngine.SecurityInfo.State >= ss128AES then
    Randomize;
  FPrinting := True;
  FAborted := False;
  FPages.Add;
  FImages.JPEGQuality := FJPEGQuality;
  FEngine.PDFACompatibile := FPDFACompatible;
  FEngine.RGBICCStream := FRGBICCStream;
  FEngine.CMYKICCStream := FCMYKICCStream;
  if FSecurity.State >= ss128AES then FEngine.SaveHeader( pdfver17)
    else if FSecurity.State = ss128RC4 then FEngine.SaveHeader( pdfver15)
      else FEngine.SaveHeader( pdfver14);
end;

procedure TPDFDocument.ClearAll;
begin
  FEngine.ClearManager(FForms);
  FEngine.ClearManager(FPatterns);
  FEngine.ClearManager(FPages);
  FEngine.ClearManager(FImages);
  FEngine.ClearManager(FFonts);
  FEngine.ClearManager(FActions);
  FEngine.ClearManager(FOutlines);
  FEngine.ClearManager(FAcroForms);
  FEngine.ClearManager(FGStates);
  FEngine.ClearManager(FOptionalContents);
  FEngine.ClearManager(FNames);
  FDigSignature.Free;
  FDigSignature := nil;
  if FStream <> nil then
  begin
    FStream.Free;
    FStream := nil;
  end;
  FEngine.Reset;
end;

procedure TPDFDocument.EndDoc;
begin
  try
    StoreDocument;
  except
    on Exception do
    begin
      Abort;
      raise;
    end;
  end;
  if FOutputStream <> nil then
  begin
    FStream.Position := 0;
    FOutputStream.CopyFrom ( FStream, FStream.Size );
  end;
  ClearAll;
  FPrinting := False;
  FAborted := False;
  if ( FOutputStream = nil ) and ( AutoLaunch ) then
  try
    ShellExecute ( GetActiveWindow, 'open', PChar ( FFileName ), nil, nil, SW_NORMAL );
  except
  end;
end;

function TPDFDocument.GetAutoCreateURL: Boolean;
begin
  Result := FPages.AutoURLCreate;
end;

function TPDFDocument.GetCanvas: TCanvas;
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  Result := FPages.CurrentPage.Canvas;
  FPages.RequestCanvas;
end;

function TPDFDocument.GetCount: Integer;
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  Result := FPages.Count;
end;

function TPDFDocument.GetCurrentPage: TPDFPage;
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  Result := FPages.CurrentPage;
end;

function TPDFDocument.GetCurrentPageIndex: Integer;
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  Result := FPages.CurrentPageIndex;
end;

function TPDFDocument.GetEMFOptions: TPDFEMFParseOptions;
begin
  Result := TPDFEMFParseOptions(FPages.EMFOptions);
end;

function TPDFDocument.GetImages: TPDFImages;
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  Result := FImages;
end;

function TPDFDocument.GetNonEmbeddedFonts: TStringList;
begin
  Result := FFonts.NonEmbeddedFonts;
end;

function TPDFDocument.GetPage(Index: Integer): TPDFPage;
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  if FOnePass then
    raise EPDFException.Create ( SCannotAccessToPageInOnePassMode );
  if ( Index < 0 ) or ( Index > FPages.Count - 1 ) then
    raise EPDFException.Create ( SOutOfRange );
  Result := FPages [ Index ];
end;

function TPDFDocument.GetPageNumber: Integer;
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  Result := FPages.CurrentPageIndex + 1;
end;

procedure TPDFDocument.NewPage;
var
  I:Integer;
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  I := FPages.CurrentPageIndex;
  FPages.Add;
  if FOnePass then
  begin
    FPages.SaveIndex(i);
  end;

end;

procedure TPDFDocument.SaveCryptDictionary(ID: Integer);
begin
  FEngine.StartObj ( ID );
  FEngine.SaveToStream ( '/Filter /Standard' );
  case FEngine.SecurityInfo.State of
    ss40RC4:
      begin
        FEngine.SaveToStream ( '/V 1' );
        FEngine.SaveToStream ( '/R 2' );
      end;
    ss128RC4:
      begin
        FEngine.SaveToStream ( '/V 2' );
        FEngine.SaveToStream ( '/R 3' );
        FEngine.SaveToStream ( '/Length 128' );
      end;
    ss128AES:
      begin
        FEngine.SaveToStream ( '/V 4' );
        FEngine.SaveToStream ( '/R 4' );
        FEngine.SaveToStream ( '/Length 128' );
        FEngine.SaveToStream ( '/CF<</StdCF<</CFM/AESV2/Length 16/AuthEvent/DocOpen>>>>/StmF/StdCF/StrF/StdCF' );
      end;
    ss256AES:
      begin
        FEngine.SaveToStream ( '/V 5' );
        FEngine.SaveToStream ( '/R 5' );
        FEngine.SaveToStream ( '/Length 256' );
        FEngine.SaveToStream ( '/CF<</StdCF<</CFM/AESV3/Length 32/AuthEvent/DocOpen>>>>/StmF/StdCF/StrF/StdCF' );
        FEngine.SaveToStream ( '/OE (' + EscapeSpecialChar ( FEngine.SecurityInfo.OE ) + ')' );
        FEngine.SaveToStream ( '/UE (' + EscapeSpecialChar ( FEngine.SecurityInfo.UE ) + ')' );
        FEngine.SaveToStream ( '/Perms (' + EscapeSpecialChar ( FEngine.SecurityInfo.Perm ) + ')' );
      end;
  end;

  FEngine.SaveToStream ( '/P ' + IStr ( FEngine.SecurityInfo.Permission ) );
  FEngine.SaveToStream ( '/O (' + EscapeSpecialChar ( FEngine.SecurityInfo.Owner ) + ')' );
  FEngine.SaveToStream ( '/U (' + EscapeSpecialChar ( FEngine.SecurityInfo.User ) + ')' );
  if FEngine.SecurityInfo.State = ss256AES then
  begin
  end;
  FEngine.CloseObj;
end;

procedure TPDFDocument.SetAutoCreateURL(const Value: Boolean);
begin
  FPages.AutoURLCreate := Value;
end;

procedure TPDFDocument.SetCurrentPageIndex(Index: Integer);
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  if FOnePass then
    raise EPDFException.Create ( SCannotChangePageInOnePassMode );
  if (Index >= FPages.Count) or (Index < 0 ) then
    raise EPDFException.Create( SOutOfRange);
  FPages.SetCurrentPage( Index );
end;

procedure TPDFDocument.SetDocumentInfo(const Value: TPDFDocInfo);
begin
  FDocumentInfo.Creator := Value.Creator;
  FDocumentInfo.CreationDate := Value.CreationDate;
  FDocumentInfo.Author := Value.Author;
  FDocumentInfo.Title := Value.Title;
  FDocumentInfo.Subject := Value.Subject;
  FDocumentInfo.Keywords := Value.Keywords;
end;

procedure TPDFDocument.SetFileName(const Value: string);
begin
  if FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileInProgress );
    FFileName := Value;
end;

procedure TPDFDocument.SetJPEGQuality(const Value: Integer);
begin
  FJPEGQuality := Value;
  if FPrinting then
    FImages.JPEGQuality := FJPEGQuality;
end;

procedure TPDFDocument.SetOnePass(const Value: Boolean);
begin
  if FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileInProgress );
  FOnePass := Value;
end;

procedure TPDFDocument.SetOutputStream(const Value: TStream);
begin
  if FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileInProgress );
  FOutputStream := Value;
end;

procedure TPDFDocument.SetSecurity(const Value: TPDFSecurityOptions);
begin
  if FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileInProgress );
  if FPDFACompatible and ( Value.State <> ssNone ) then
    raise EPDFException.Create( SPDFACompatible );
  FSecurity.State := Value.State;
  FSecurity.OwnerPassword := Value.OwnerPassword;
  FSecurity.UserPassword := Value.UserPassword;
  FSecurity.Permissions := Value.Permissions;
  FSecurity.CryptMetadata := Value.CryptMetadata;
end;

procedure TPDFDocument.StoreDocument;
var
  i: Integer;
  CatalogID, InfoID, EncryptID, MetaID: Integer;
begin
  InfoID := FEngine.GetNextID;
  FDocumentInfo.Save(InfoID, FEngine);
  FPages.CloseCanvas;

  if not FOnePass then
  begin
    for i := 0 to FPages.Count - 1  do
      FPages.SaveIndex(i);
  end else
    FPages.SaveIndex(FPages.Count - 1);
  if FEngine.SecurityInfo.State <> ssNone then
  begin
    EncryptID := FEngine.GetNextID;
    SaveCryptDictionary( EncryptID);
  end else
  begin
    EncryptID := 0;
  end;


  FEngine.SaveManager(FPages);
  FEngine.SaveManager(FFonts);
  FEngine.SaveManager(FOutlines);
  FEngine.SaveManager(FNames);
  FEngine.SaveManager(FAcroForms);
  FEngine.SaveManager(FActions);
  FEngine.SaveManager(FGStates);
  FEngine.SaveManager(FOptionalContents);
  FEngine.SaveManager(FForms);
  FEngine.SaveManager(FImages);
  FEngine.SaveManager(FPatterns);
  FEngine.SavePDFAFeatures;

  MetaID := FEngine.CreateMetadata(FDocumentInfo, Security.CryptMetadata);

  CatalogID := FEngine.GetNextID;
  FEngine.StartObj( CatalogID);
  FEngine.SaveToStream ( '/Type /Catalog' );
  if Security.State = ss256AES then
    FEngine.SaveToStream ( '/Extensions<</ADBE<</BaseVersion/1.7/ExtensionLevel 3>>>>');
  FEngine.SaveToStream ( '/Pages ' +  FPages.RefID );
  case PageLayout of
    plSinglePage: FEngine.SaveToStream ( '/PageLayout /SinglePage' );
    plOneColumn: FEngine.SaveToStream ( '/PageLayout /OneColumn' );
    plTwoColumnLeft: FEngine.SaveToStream ( '/Pagelayout /TwoColumnLeft' );
    plTwoColumnRight: FEngine.SaveToStream ( '/PageLayout /TwoColumnRight' );
  end;
  if ViewerPreferences <> [ ] then
  begin
    FEngine.SaveToStream ( '/ViewerPreferences <<' );
    if vpHideToolBar in ViewerPreferences then
      FEngine.SaveToStream ( '/HideToolbar true' );
    if vpHideMenuBar in ViewerPreferences then
      FEngine.SaveToStream ( '/HideMenubar true' );
    if vpHideWindowUI in ViewerPreferences then
      FEngine.SaveToStream ( '/HideWindowUI true' );
    if vpFitWindow in ViewerPreferences then
      FEngine.SaveToStream ( '/FitWindow true' );
    if vpCenterWindow in ViewerPreferences then
      FEngine.SaveToStream ( '/CenterWindow true' );
    FEngine.SaveToStream ( '>>' );
  end;
  case PageMode of
    pmUseNone: FEngine.SaveToStream ( '/PageMode /UseNone' );
    pmUseOutlines: FEngine.SaveToStream ( '/PageMode /UseOutlines' );
    pmUseThumbs: FEngine.SaveToStream ( '/PageMode /UseThumbs' );
    pmFullScreen: FEngine.SaveToStream ( '/PageMode /FullScreen' );
  end;
  if FOutlines.Count <> 0 then
    FEngine.SaveToStream ( '/Outlines ' + FOutlines.RefID );
  if FNames.Count <> 0 then
    FEngine.SaveToStream ( '/Names ' + FNames.RefID );
  if FAcroForms.Count >0 then
    FEngine.SaveToStream ( '/AcroForm ' + FAcroForms.RefID );
  if FOptionalContents.Count >0 then
    FEngine.SaveToStream ( '/OCProperties ' + FOptionalContents.RefID );

  if FOpenDocumentAction <> nil then
    FEngine.SaveToStream ( '/OpenAction ' + FOpenDocumentAction.RefID);

  FEngine.SaveToStream('/Metadata '+GetRef ( MetaID ));

  FEngine.CloseObj;
  FEngine.SaveXREFAndTrailer( CatalogID, InfoID, EncryptID, FEngine.FileID);
  if Assigned(FDigSignature) then
    FEngine.SaveAdditional(FDigSignature);
end;

procedure TPDFDocument.SetCompression(const Value: TCompressionType);
begin
  FCompression := Value;
  FEngine.Compression := Value;
end;


procedure TPDFDocument.SetNonEmbeddedFonts(const Value: TStringList);
begin
  FFonts.NonEmbeddedFonts :=Value;
end;

procedure TPDFDocument.SetResolution(const Value: Integer);
begin
  FResolution := Value;
  FEngine.Resolution := Value;
end;

procedure TPDFDocument.SetOpenDocumentAction(const Value: TPDFAction);
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  FOpenDocumentAction := Value
end;


procedure TPDFDocument.SetPDFACompatible(const Value: Boolean);
begin
  if FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileInProgress );
  if FSecurity.State <> ssNone then
    raise EPDFException.Create ( SSecutityCompatible );
  FPDFACompatible := Value;
  FEngine.PDFACompatibile := Value;
end;


procedure TPDFDocument.SetCMYKICCStream(const Value: TStream);
begin
  if FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileInProgress );
  FCMYKICCStream := Value;
  FEngine.CMYKICCStream := Value;
end;

procedure TPDFDocument.SetRGBICCStream(const Value: TStream);
begin
  if FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileInProgress );
  FRGBICCStream := Value;
  FEngine.RGBICCStream := Value;
end;

function TPDFDocument.AppendForm( OptionalContent: TOptionalContent): TPDFForm;
begin
  Result := TPDFForm.Create(FEngine,FFonts, OptionalContent);
  FForms.Add(Result);
end;

function TPDFDocument.AppendOptionalContent(LayerName: AnsiString; StartVisible,
  CanExchange: Boolean): TOptionalContent;
begin
  Result := TOptionalContent.Create(FEngine,LayerName,StartVisible,CanExchange);
  FOptionalContents.Add(Result);
end;



{ TPDFDocInfo }

procedure TPDFDocInfo.Save(ID: Integer;PDFEngine: TPDFEngine);
begin
  PDFEngine.StartObj( ID );
{$ifdef UNICODE}
  PDFEngine.SaveToStream ( '/Creator ' + CryptString( PDFEngine.SecurityInfo, UnicodeChar(FCreator), ID ) );
  PDFEngine.SaveToStream ( '/CreationDate ' + CryptString ( PDFEngine.SecurityInfo,'D:' + AnsiString(FormatDateTime ( 'yyyymmddhhnnss', FCreationDate ))+'Z' , ID) );
  PDFEngine.SaveToStream ( '/ModDate ' + CryptString ( PDFEngine.SecurityInfo,'D:' + AnsiString(FormatDateTime ( 'yyyymmddhhnnss', Now ))+'Z' , ID) );
  PDFEngine.SaveToStream ( '/Producer ' + CryptString (PDFEngine.SecurityInfo, UnicodeChar(FProducer) , ID) );
  PDFEngine.SaveToStream ( '/Author ' + CryptString ( PDFEngine.SecurityInfo,UnicodeChar(FAuthor) , ID) );
  PDFEngine.SaveToStream ( '/Title ' + CryptString ( PDFEngine.SecurityInfo,UnicodeChar(FTitle) , ID) );
  PDFEngine.SaveToStream ( '/Subject ' + CryptString (PDFEngine.SecurityInfo, UnicodeChar(FSubject) , ID) );
  PDFEngine.SaveToStream ( '/Keywords ' + CryptString (PDFEngine.SecurityInfo, UnicodeChar(FKeywords) , ID) );
{$else}
  PDFEngine.SaveToStream ( '/Creator ' + CryptString( PDFEngine.SecurityInfo, FCreator, ID ) );
  PDFEngine.SaveToStream ( '/CreationDate ' + CryptString ( PDFEngine.SecurityInfo,'D:' + FormatDateTime ( 'yyyymmddhhnnss', FCreationDate )+'Z' , ID) );
  PDFEngine.SaveToStream ( '/ModDate ' + CryptString ( PDFEngine.SecurityInfo,'D:' + AnsiString(FormatDateTime ( 'yyyymmddhhnnss', Now ))+'Z' , ID) );
  PDFEngine.SaveToStream ( '/Producer ' + CryptString (PDFEngine.SecurityInfo, FProducer , ID) );
  PDFEngine.SaveToStream ( '/Author ' + CryptString ( PDFEngine.SecurityInfo,FAuthor , ID) );
  PDFEngine.SaveToStream ( '/Title ' + CryptString ( PDFEngine.SecurityInfo,FTitle , ID) );
  PDFEngine.SaveToStream ( '/Subject ' + CryptString (PDFEngine.SecurityInfo, FSubject , ID) );
  PDFEngine.SaveToStream ( '/Keywords ' + CryptString (PDFEngine.SecurityInfo, FKeywords , ID) );
{$endif}
  PDFEngine.CloseObj;
end;

procedure TPDFDocument.AppendDigitalSignatureKeys(APFXStream: TStream;  Password: string);
var
  PFX: TPKCS12Document;
begin
  if not FPrinting then
    raise EPDFException.Create ( SGenerationPDFFileNotActivated );
  if FDigSignature <> nil then
    raise EPDFException.Create( SOnlyOneDigitalSignatureAvaiable);

  PFX := TPKCS12Document.Create;
  try
    PFX.LoadFromStream(APFXStream);
{$IFDEF UNICODE}
    PFX.CheckPassword(UTF8encode(Password));
{$else}
    PFX.CheckPassword(Password);
{$ENDIF}
    PFX.Parse;
    FDigSignature := TPDFSignature.Create(Self,PFX);
    PFX := nil;
  finally
    PFX.Free;
  end;
end;

procedure TPDFDocument.AppendDigitalSignatureKeys(APFXFile, Password: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(APFXFile,fmOpenRead);
  try
    AppendDigitalSignatureKeys(FS,Password);
  finally
    FS.Free;
  end;
end;

end.

