{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

{#int}
unit llPDFTypes;
{#int}
{$i pdf.inc}
{#int}
interface
{#int}
uses
{$ifndef W3264}
  Windows, SysUtils, Classes;
{$else}
  WinApi.Windows, System.Classes, System.SysUtils;
{$endif}

{#int}
type

{#int}

{$ifdef win64}
  FInt = System.IntPtr;
  FarInteger = UInt64;
{$else}
  FInt = Integer;
  FarInteger = Cardinal;
{$endif}


{$ifndef PCardinal}
  PCardinal = ^Cardinal;
{$endif}

{$ifndef UTF8String}
  UTF8String = AnsiString;
{$endif}

  TCardinalArray = array[0..0] of Cardinal;
  PCardinalArray = ^TCardinalArray;

{#int}


  /// <summary>
  ///   Specifies page content compression
  /// </summary>
  TCompressionType = (
    /// <summary>
    ///   Do not compress
    /// </summary>
    ctNone,
    /// <summary>
    ///   Compress with flate compression
    /// </summary>
    ctFlate
  );


  /// <summary>
  ///   determines the method for characters from the original image to JBIG2 format symbol dictionary
  /// </summary>

  TImgCopyType = (
    /// <summary>
    ///   Cut rectangle area
    /// </summary>
    icRectangle,
    /// <summary>
    ///   Cut image symbols only
    /// </summary>
    icImageOnly
  );



  /// <summary>
  ///   Specifies the type of storage of images in a PDF document
  /// </summary>
  TImageCompressionType = (
    /// <summary>
    ///   Flate compression (Possible for black and white and color images)
    /// </summary>
    itcFlate,
    /// <summary>
    ///   Jpeg compression (Possible for black and white and color images)
    /// </summary>
    itcJpeg,
    /// <summary>
    ///   CCITT3 (for black and white images only)
    /// </summary>
    itcCCITT3,
    /// <summary>
    ///   CCITT32d (for black and white images only)
    /// </summary>
    itcCCITT32d,
    /// <summary>
    ///   CCITT4 (for black and white images only)
    /// </summary>
    itcCCITT4,
    /// <summary>
    ///   JBIG2 (for black and white images of scanned pages)
    /// </summary>
    itcJBIG2
  );

  /// <summary>
  ///   The line join style specifies the shape to be used at the corners of paths that are stroked.
  /// </summary>
  TPDFLineJoin = (
    /// <summary>
    ///   The outer edges of the strokes for the two segments are extended until they meet at an angle. If
    ///   the segments meet at too sharp an angle a bevel join is used instead.
    /// </summary>
    ljMiter,

    /// <summary>
    ///   A circle with a diameter equal to the line width is drawn around the point where the two segments
    ///   meet and is filled in, producing a rounded corner.
    /// </summary>
    ljRound,

    /// <summary>
    ///   The two segments are finished with butt caps (see TPDFLineCap ) and the resulting notch beyond the
    ///   ends of the segments is filled with a triangle
    /// </summary>
    ljBevel
  );

  /// <summary>
  ///   The line cap style specifies the shape to be used at the ends of open subpaths (and dashes, if any)
  ///   when they are stroked.
  /// </summary>
  TPDFLineCap = (
    /// <summary>
    ///   The stroke is squared off at the endpoint of the path. There is no projection beyond the end of the
    ///   path.
    /// </summary>
    lcButtEnd,
    /// <summary>
    ///   A semicircular arc with a diameter equal to the line width is drawn around the endpoint and filled
    ///   in.
    /// </summary>
    lcRound,
    /// <summary>
    ///   The stroke continues beyond the endpoint of the path for a distance equal to half the line width
    ///   and is then squared off.
    /// </summary>
    lcProjectingSquare
  );

  /// <summary>
  ///   Specified rotate page in PDF document viewer.
  /// </summary>
  TPDFPageRotate = (
    /// <summary>
    ///   0 Degree
    /// </summary>
    pr0,
    /// <summary>
    ///   90 Degree
    /// </summary>
    pr90,
    /// <summary>
    ///   180 Degree
    /// </summary>
    pr180,
    /// <summary>
    ///   270 Degree
    /// </summary>
    pr270
  );

  /// <summary>
  ///   Specified Type of submit of Control names and values
  /// </summary>
  TPDFSubmitType = (
    /// <summary>
    ///   will submited using an HTTP GET request.
    /// </summary>
    stGet,
    /// <summary>
    ///   will submited using an HTTP POST request.
    /// </summary>
    stPost,
    /// <summary>
    ///   Control names and values will submited in Forms Data Format (FDF).
    /// </summary>
    stFDF
  );

  /// <summary>
  ///   Determinate horizontal align of the text
  /// </summary>
  THorJust = (
    /// <summary>
    ///   Aling text relatively left of the box
    /// </summary>
    hjLeft,
    /// <summary>
    ///   Aling text relatively center of the box
    /// </summary>
    hjCenter,
    /// <summary>
    ///   Aling text relatively right of the box
    /// </summary>
    hjRight
  );

  /// <summary>
  ///   Determinate vertical align of the text.
  /// </summary>
  TVertJust = (
    /// <summary>
    ///   Aling text relatively top of the box
    /// </summary>
    vjUp,
    /// <summary>
    ///   Aling text relatively center of the box
    /// </summary>
    vjCenter,
    /// <summary>
    ///   Aling text relatively bottom of the box
    /// </summary>
    vjDown
  );

  /// <summary>
  ///   The flags specifying how the document is presented on the screen.
  /// </summary>
  TViewerPreference = (
    /// <summary>
    ///   A flag specifying whether to hide the viewer application's tool bars when the document is active.
    /// </summary>
    vpHideToolBar,
    /// <summary>
    ///   A flag specifying whether to hide the viewer application's menu bar when the document is active.
    /// </summary>
    vpHideMenuBar,
    /// <summary>
    ///   A flag specifying whether to hide user interface elements in the document's window (such as scroll
    ///   bars and navigation controls), leaving only the document's contents displayed.
    /// </summary>
    vpHideWindowUI,

    /// <summary>
    ///   A flag specifying whether to resize the document's window to fit the size of the first displayed
    ///   page.
    /// </summary>
    vpFitWindow,
    /// <summary>
    ///   A flag specifying whether to position the document's window in the center of the screen.
    /// </summary>
    vpCenterWindow
  );

  /// <summary>
  ///   A set of flags specifying how the document is presented on the screen.
  /// </summary>
  TViewerPreferences = set of TViewerPreference;

  /// <summary>
  ///   Specifying the page layout to be used when the document is opened
  /// </summary>
  TPageLayout = (
    /// <summary>
    ///   Display one page at a time.
    /// </summary>
    plSinglePage,
    /// <summary>
    ///   Display the pages in one column
    /// </summary>
    plOneColumn,
    /// <summary>
    ///   Display the pages in two columns, with odd-numbered pages on the left.
    /// </summary>
    plTwoColumnLeft,
    /// <summary>
    ///   Display the pages in two columns, with odd-numbered pages on the right.
    /// </summary>
    plTwoColumnRight
  );

  /// <summary>
  ///   Specifying how the document should be displayed when opened.
  /// </summary>
  TPageMode = (
    /// <summary>
    ///   Neither document outline nor thumbnail images visible
    /// </summary>
    pmUseNone,
    /// <summary>
    ///   Document outline visible
    /// </summary>
    pmUseOutlines,
    /// <summary>
    ///   Thumbnail images visible
    /// </summary>
    pmUseThumbs,
    /// <summary>
    ///   Full-screen mode, with no menu bar, window controls, or any other window visible
    /// </summary>
    pmFullScreen
  );

  /// <summary>
  ///   Determinate size of the pages.
  /// </summary>
  TPDFPageSize = (
    /// <summary>
    ///   216 x 279 mm/8.5 x 11 in
    /// </summary>
    psLetter,
    /// <summary>
    ///   210 x 297 mm/8.3 x 11.7 in
    /// </summary>
    psA4,
    /// <summary>
    ///   297 x 420 mm/11.7 x 16.5 in
    /// </summary>
    psA3,
    /// <summary>
    ///   216 x 356 mm/8.5 x 14 in
    /// </summary>
    psLegal,
    /// <summary>
    ///   176 x 250 mm/6.9 x 9.8 in
    /// </summary>
    psB5,
    /// <summary>
    ///   162 x 229 mm/6.4 x 9.0 in
    /// </summary>
    psC5,
    /// <summary>
    ///   8 x 11 in
    /// </summary>
    ps8x11,
    /// <summary>
    ///   250 x 353 mm/9.8 x 13.9 in
    /// </summary>
    psB4,
    /// <summary>
    ///   148 x 210 mm/5.8 x 8.3 in
    /// </summary>
    psA5,
    /// <summary>
    ///   210 x 330 mm/8.27 x 13 in
    /// </summary>
    psFolio,
    /// <summary>
    ///   184 x 267 mm/7.25 x 10.5 in
    /// </summary>
    psExecutive,
    /// <summary>
    ///   250 x 353 mm/9.8 x 13.9 in
    /// </summary>
    psEnvB4,
    /// <summary>
    ///   176 x 250 mm/6.9 x 9.8 in
    /// </summary>
    psEnvB5,
    /// <summary>
    ///   114 x 162 mm/4.5 x 6.4 in
    /// </summary>
    psEnvC6,
    /// <summary>
    ///   110 x 220 mm/4.4 x 8.8 in
    /// </summary>
    psEnvDL,
    /// <summary>
    ///   190.5 x 98.4 mm/7.5 x 3.875 in
    /// </summary>
    psEnvMonarch,
    /// <summary>
    ///   225.4 x 98.4 mm/8.875 x 3.875 in
    /// </summary>
    psEnv9,
    /// <summary>
    ///   241.3 x 104.8 mm/9.5 x 4.125 in
    /// </summary>
    psEnv10,
    /// <summary>
    ///   263.5 x 114.3 mm/10.375 x 4.5 in
    /// </summary>
    psEnv11
  );

  /// <summary>
  ///   Determinate orientation of the page.
  /// </summary>
  TPDFPageOrientation = (
    /// <summary>
    ///   Portrait Orientation
    /// </summary>
    poPagePortrait,
    /// <summary>
    ///   Landscape Orientation
    /// </summary>
    poPageLandscape
  );

{#int}
  TPDFMinVersion = (
    pdfver14,                     //
    pdfver15,                     //
    pdfver17,                     //
    pdfver19                      //
  );
{#int}

  /// <summary>
  ///   The flags specifying various characteristics of the annotation
  /// </summary>
  TPDFAnnotationFlag = (
    /// <summary>
    ///   If set, do not display the annotation if it does not belong to one of the standard annotation types
    ///   and no annotation handler is available.
    /// </summary>
    afInvisible,
    /// <summary>
    ///   If set, do not display or print the annotation or allow it to interact with the user, regardless of
    ///   its annotation type or whether an annotation handler is available.
    /// </summary>
    afHidden,
    /// <summary>
    ///   If set, print the annotation when the page is printed. If clear, never print the annotation,
    ///   regardless of whether it is displayed on the screen. This can be useful, for example, for
    ///   annotations representing interactive pushbuttons, which would serve no meaningful purpose on the
    ///   printed page.
    /// </summary>
    afPrint,
    /// <summary>
    ///   If set, do not scale the annotation's appearance to match the magnification of the page. The
    ///   location of the annotation on the page (defined by the upper-left corner of its bounding box)
    ///   remains fixed, regardless of the page magnification
    /// </summary>
    afNoZoom,
    /// <summary>
    ///   If set, do not rotate the annotation's appearance to match the rotation of the page. The upper-left
    ///   corner of the annotation's bounding box remains in a fixed location on the page, regardless of the
    ///   page rotation.
    /// </summary>
    afNoRotate,
    /// <summary>
    ///   If set, do not display the annotation on the screen or allow it to interact with the user. The
    ///   annotation may be printed (depending on the setting of the afPrint flag), but should be considered
    ///   hidden for purposes of on-screen display and user interaction.
    /// </summary>
    afNoView,
    /// <summary>
    ///   If set, do not allow the annotation to interact with the user. The annotation may be displayed or
    ///   printed (depending on the settings of the afNoView and afPrint flags), but should not respond to
    ///   mouse clicks or change its appearance in response to mouse motions.
    /// </summary>
    afReadOnly
  );

  /// <summary>
  ///   A set of flags specifying various characteristics of the annotation
  /// </summary>
  TPDFAnnotationFlags = set of TPDFAnnotationFlag;

  /// <summary>
  ///   The name of an icon to be used in displaying the annotation.
  /// </summary>
  TTextAnnotationIcon = (
    /// <summary>
    ///   Comment
    /// </summary>
    taiComment,
    /// <summary>
    ///   Key
    /// </summary>
    taiKey,
    /// <summary>
    ///   Note
    /// </summary>
    taiNote,
    /// <summary>
    ///   Help
    /// </summary>
    taiHelp,
    /// <summary>
    ///   New paragraph
    /// </summary>
    taiNewParagraph,
    /// <summary>
    ///   Paragraph
    /// </summary>
    taiParagraph,
    /// <summary>
    ///   Insert
    /// </summary>
    taiInsert
  );

  /// <summary>
  ///   The annotation’s highlighting mode, the visual effect to be used when the mouse button is pressed or
  ///   held down inside its active area
  /// </summary>
  TActionAnnotationHilightMode = (
    /// <summary>
    ///   No highlighting
    /// </summary>
    aahlNone,
    /// <summary>
    ///   Invert the contents of the annotation rectangle.
    /// </summary>
    aahlInvert,
    /// <summary>
    ///   Invert the annotation’s border.
    /// </summary>
    aalhOutline,
    /// <summary>
    ///   Display the annotation as if it were being pushed below the surface of the page
    /// </summary>
    aahlPush
  );

  /// <summary>
  ///   Standard Base1 fonts included in any pdf reader
  /// </summary>
  TPDFStdFont  = (
    /// <summary>
    ///   Helvetica font
    /// </summary>
    stdfHelvetica,
    /// <summary>
    ///   Helvetica Bold font
    /// </summary>
    stdfHelveticaBold,
    /// <summary>
    ///   Helvetica Oblique font
    /// </summary>
    stdfHelveticaOblique,
    /// <summary>
    ///   Helvetica Bold Oblique font
    /// </summary>
    stdfHelveticaBoldOblique,
    /// <summary>
    ///   Times Roman font
    /// </summary>
    stdfTimesRoman,
    /// <summary>
    ///   Times Bold font
    /// </summary>
    stdfTimesBold,
    /// <summary>
    ///   Times Italic font
    /// </summary>
    stdfTimesItalic,
    /// <summary>
    ///   Times Bold Italic font
    /// </summary>
    stdfTimesBoldItalic,
    /// <summary>
    ///   Courier font
    /// </summary>
    stdfCourier,
    /// <summary>
    ///   Courier Bold font
    /// </summary>
    stdfCourierBold,
    /// <summary>
    ///   Courier Oblique font
    /// </summary>
    stdfCourierOblique,
    /// <summary>
    ///   Courier BoldOblique font
    /// </summary>
    stdfCourierBoldOblique,
    /// <summary>
    ///   Symbol font
    /// </summary>
    stdfSymbol,
    /// <summary>
    ///   Zapf Dingbats font
    /// </summary>
    stdfZapfDingbats
   );

   /// <summary>
   ///   The PDF format offers various methods for specifying the colors of graphics objects to be painted on
   ///   the current page. Colors can be described in any of a variety of color systems, or color spaces.
   ///   Some color spaces are related to device color representation (grayscale, RGB, CMYK)
   /// </summary>
   TPDFColorSpace = (
     /// <summary>
     ///   Gray ColorSpace
     /// </summary>
     csGray,
     /// <summary>
     ///   RGB ColorSpace
     /// </summary>
     csRGB,
     /// <summary>
     ///   CMYK ColorSpace
     /// </summary>
     csCMYK
   );

   /// <summary>
   ///   Determines which colorspace and color to use when drawing graphical primitives
   /// </summary>
   TPDFColor = record
     /// <summary>
     ///   ColorSpace of this color
     /// </summary>
     case ColorSpace : TPDFColorSpace of
       csGray:(
         /// <summary>
         ///   Gray part of the color
         /// </summary>
         Gray:Extended;
       );
       csRGB:(
         //
         /// <summary>
         ///   Blue part of the color
         /// </summary>
         Red: Extended;
         /// <summary>
         ///   Green part of the color
         /// </summary>
         Green:Extended;
         /// <summary>
         ///   Blue part of the color
         /// </summary>
         Blue:Extended;
       );
       csCMYK:(
         /// <summary>
         ///   Cyan part of the color
         /// </summary>
         Cyan: Extended;
         /// <summary>
         ///  Magenta part of the color
         /// </summary>
         Magenta:Extended;
         /// <summary>
         ///  Yellow part of the color
         /// </summary>
         Yellow:Extended;
         /// <summary>
         ///   Key part of the color
         /// </summary>
         Key:Extended;
       );
   end;


  /// <summary>
  ///   Encryption state for PDF Document
  /// </summary>
  TPDFSecurityState = (
    /// <summary>
    ///   Not encrypted document
    /// </summary>
    ssNone,
    /// <summary>
    ///   Encrypted document with RC4 encryption (40 bits key length)
    /// </summary>
    ss40RC4,
    /// <summary>
    ///   Encrypted document with RC4 encryption (128 bits key length)
    /// </summary>
    ss128RC4,
    /// <summary>
    ///   Encrypted document with AES encryption (128 bits key length)
    /// </summary>
    ss128AES,
    /// <summary>
    ///   Encrypted document with AES encryption (256 bits key length)
    /// </summary>
    ss256AES
  );


  /// <summary>
  ///   The flag defined enabled operation for encrypted document.
  /// </summary>
  TPDFSecurityPermission = (
    /// <summary>
    ///   Print the document
    /// </summary>
    coPrint,
    /// <summary>
    ///   Modify the contents of the document
    /// </summary>
    coModifyStructure,
    /// <summary>
    ///   Copy or otherwise extract text and graphics from the document, including extracting text and
    ///   graphics (in support of accessibility to disabled users or for other purposes).
    /// </summary>
    coCopyInformation,

    /// <summary>
    ///   Add or modify text annotations, fill in interactive form fields.
    /// </summary>
    coModifyAnnotation,
    /// <summary>
    ///   Print the document with high quality
    /// </summary>
    coPrintHi,
    /// <summary>
    ///   Fill in existing interactive form fields (including signature fields)
    /// </summary>
    coFillAnnotation,
    /// <summary>
    ///   Extract text and graphics
    /// </summary>
    coExtractInfo,
    /// <summary>
    ///   Assemble the document (insert, rotate, or delete pages and create bookmarks or thumbnail images)
    /// </summary>
    coAssemble
  );

  /// <summary>
  ///   Set of the flag defined enabled operations for encrypted document.
  /// </summary>
  TPDFSecurityPermissions = set of TPDFSecurityPermission;

  /// <summary>
  ///   Set of options specifying the way of coding of the PDF document
  /// </summary>
  TPDFSecurityOptions = class (TPersistent)
{#int}
  private
    FOwnerPassword: AnsiString;
    FPermissions: TPDFSecurityPermissions;
    FState: TPDFSecurityState;
    FUserPassword: AnsiString;
    FCryptMetadata: Boolean;
{#int}
  published
    /// <summary>
    ///   Enabled permissions for encrypted document
    /// </summary>
    property Permissions: TPDFSecurityPermissions read FPermissions write FPermissions;
    /// <summary>
    ///   Encryption method of the PDF document
    /// </summary>
    property State: TPDFSecurityState read FState write FState;
    /// <summary>
    ///   User password for current PDF document. This is the password which will be used to encrypt the
    ///   file.
    /// </summary>
    property UserPassword: AnsiString read FUserPassword write FUserPassword;
    /// <summary>
    ///   Owner's password for current PDF document. The password is required to edit an encrypted PDF file.
    /// </summary>
    property OwnerPassword: AnsiString read FOwnerPassword write FOwnerPassword;
    /// <summary>
    ///   Defines crypt metadata of encrypted document or not
    /// </summary>
    /// <remarks>
    ///   Files without crypted metadata can be indexed by search engines of various types
    /// </remarks>
    property CryptMetadata: Boolean read FCryptMetadata write FCryptMetadata;
  end;

  /// <summary>
  ///   Set of options determining behavior of library when parsing EMF files
  /// </summary>
  TPDFEMFParseOptions = class (TPersistent)
{#int}
  private
    FCanvasOver: Boolean;
    FRedraw: Boolean;
    FJPEG: Boolean;
    FLineCap: TPDFLineCap;
    FLineJoin: TPDFLineJoin;
    FUsedDC:HDC;
    FUseScreen: Boolean;
    FUseFrame: Boolean;
    FShowNullPen: Boolean;
    procedure SetUsedDC(const Value: HDC);
{#int}
  public
{#int}
    constructor Create;
    destructor Destroy;override;
{#int}
    /// <summary>
    ///   Device Content handle for receive initial resolution of the TPDFDocument.Canvas File.
    /// </summary>
    property UsedDC:HDC read FUsedDC write SetUsedDC;
    /// <summary>
    ///   Indicates use screen DC as default for create EMF files
    /// </summary>
    property UseScreen:Boolean  read FUseScreen;
  published
    /// <summary>
    ///   Determines location of standard canvas parcing. Should it be above what
    ///   is made manually at output to TPDFCanvas or beyond
    /// </summary>
    property CanvasOver: Boolean read FCanvasOver write FCanvasOver;
    /// <summary>
    ///   Specifies whether to redraw the EMF file to the current resolution
    /// </summary>
    property Redraw:Boolean read FRedraw write FRedraw;
    /// <summary>
    ///   Property determine store images from parsed EMF files as JPEG or as bitmap
    /// </summary>
    property ColorImagesAsJPEG:Boolean read FJPEG write FJPEG;
    /// <summary>
    ///   Defines kind of the line join for EMF primitives
    /// </summary>
    property LineJoin:TPDFLineJoin read FLineJoin write FLineJoin;
    /// <summary>
    ///   Defines kind of the line cap for EMF primitives
    /// </summary>
    property LineCap:TPDFLineCap read FLineCap write FLineCap;
    /// <summary>
    ///   The property defines whether to create a bounding box when drawing EMF file.
    /// </summary>
    property UseFrame: Boolean read FUseFrame write FUseFrame;
    /// <summary>
    ///   Sometimes it is necessary to draw NullPen. We don’t understand when such cases occur and want to ask you:)
    /// </summary>
    property ShowNullPen: Boolean read FShowNullPen write FShowNullPen;
  end;

{#int}
{#int}

  /// <summary>
  ///   EPDFSignatureException is the exception that is generated when an error occurs with using digital
  ///   signatures
  /// </summary>
  EPDFSignatureException = class(Exception);
  /// <summary>
  ///   EPDFException is the exception class for errors that occur when creating PDF document
  /// </summary>
  EPDFException = class(Exception);




{#int}



{#int}
implementation

{#int}

{ TPDFEMFParseOptions }

constructor TPDFEMFParseOptions.Create;
begin
  FUseScreen := True;
  FUsedDC := GetDC ( 0 );
  FJPEG := False;
  FRedraw := True;
  FLineCap := lcProjectingSquare;
  FLineJoin := ljBevel;
end;

destructor TPDFEMFParseOptions.Destroy;
begin
  if FUseScreen then
    ReleaseDC(0, FUsedDC)
  else
    DeleteDC (FUsedDC);
  inherited;
end;

procedure TPDFEMFParseOptions.SetUsedDC(const Value: HDC);
begin
  if FUseScreen then
    ReleaseDC(0, FUsedDC)
  else
    DeleteDC (FUsedDC);
  if Value = 0 then
  begin
    FUsedDC := GetDC ( 0 );
  end else FUsedDC := CreateCompatibleDC ( Value );
  FUseScreen := (Value = 0);
end;

{#int}
end.
