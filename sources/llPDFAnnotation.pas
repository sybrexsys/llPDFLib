{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFAnnotation;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif}
  llPDFTypes, llPDFEngine, llPDFCanvas, llPDFAction,llPDFPFX, llPDFASN1, 
  llPDFMisc, llPDFFont;

type



  /// <summary>
  ///   A text annotation represents a “sticky note” attached to a point in the PDF document. When closed,
  ///   the annotation appears as an icon; when open, it displays a pop-up window containing the text of the
  ///   note, in a font and size chosen by the viewer application.
  /// </summary>

  TPDFTextAnnotation = class(TPDFAnnotation)
  private
    FText: string;
    FCaption: string;
    FTextAnnotationIcon: TTextAnnotationIcon;
    FOpened: Boolean;
{$ifndef UNICODE}
    FCharset: TFontCharset;
{$endif}
  protected
    procedure Save;override;
  public
    constructor Create( Page: TPDFPage;Box: TRect);

    /// <summary>
    ///   Property specify title of the annotation.
    /// </summary>
    property Caption: string write FCaption ;
    /// <summary>
    ///   The text to be displayed in the pop-up window when the annotation is opened. Carriage returns may
    ///   be used to separate the text into paragraphs.
    /// </summary>
    property Text: string write FText ;
    /// <summary>
    ///   The name of an icon to be used in displaying the annotation. Viewer applications should provide
    ///   predefined icon appearances for at least the standard names.
    /// </summary>
    property TextAnnotationIcon: TTextAnnotationIcon write FTextAnnotationIcon ;
    /// <summary>
    ///   A property specifying whether the annotation should initially be displayed open.
    /// </summary>
    property Opened: Boolean write FOpened ;
{$ifndef UNICODE}
    /// <summary>
    ///   Specifies the character set of the text.
    /// </summary>
    property Charset: TFontCharset write FCharset ;
{$endif}
  end;


  /// <summary>
  ///   TPDFActionAnnotation is class create annotation in PDF Document. If user click in PDF Document on
  ///   this annotation will execute annotation linked to this annotation
  /// </summary>
  TPDFActionAnnotation = class(TPDFAnnotation)
  private
    FAction: TPDFAction;
    FHilightMode:TActionAnnotationHilightMode;
  protected
    procedure Save;override;
  public

    /// <summary>
    ///   Creates and initializes an instance of TPDFActionAnnotation
    /// </summary>
    /// <param name="Page">
    ///   Page where will located this object
    /// </param>
    /// <param name="Box">
    ///   Specifies position of the object on the page.
    /// </param>
    /// <param name="Action">
    ///   An action to be performed when the link annotation is activated
    /// </param>
    constructor Create( Page: TPDFPage;Box: TRect; Action: TPDFAction);
    /// Description: Sets annotation’s highlighting mode
    property HiLightMode:TActionAnnotationHilightMode write FHiLightMode;
  end;


  TPDFAcroFormAnnotation = class;
  TPDFRadioGroup = class;

  /// <summary>
  ///   Class for managing Acro form objects of PDF document.
  /// </summary>
  /// <remarks>
  ///   Please not create this object directly. Use property of TPDFDocument.
  /// </remarks>
  TPDFAcroForms = class(TPDFManager)
  private
    FFontManager: TPDFFonts;
    FAcros: array of TPDFAcroFormAnnotation;
    FFonts: array of TPDFFont;
    FRadioGroups: array of TPDFRadioGroup;
    procedure AddFont(StdFnt:TPDFStdFont);overload;
    procedure AddFont(FontName: String; Style: TFontStyles); overload;
  protected
    procedure Clear;override;
    procedure Save;override;
    function GetCount:Integer;override;
  public
    constructor Create(PDFEngine: TPDFEngine;Manager:TPDFFonts);
    destructor Destroy;override;
  end;



  /// <summary>
  ///   TPDFAcroFormAnnotation is base class for all interactive elements such as buttons, checkboxes,
  ///   radiobuttons, comboboxes and edit fields.
  /// </summary>
  TPDFAcroFormAnnotation = class(TPDFAnnotation)
  private
    FAcroForm: TPDFAcroForms;
    FTrueType:Boolean;
    FStdFont:TPDFStdFont;
    FFontName:String;
    FStyle:TFontStyles;
    FSize: Integer;
    FFontColor:TPDFColor;
    FHintCaption:string;
{$ifndef UNICODE}
    FHintCharset:TFontCharset;
{$endif}
    FOnMouseDown: TPDFAction;
    FOnMouseExit: TPDFAction;
    FOnMouseEnter: TPDFAction;
    FOnMouseUp: TPDFAction;
    FOnLostFocus: TPDFAction;
    FOnSetFocus: TPDFAction;
    FColor: TPDFColor;
    FFN: AnsiString;
    function CalcActions: AnsiString;
    function CalcDAString: AnsiString;
  protected
    FName: AnsiString;
  public

    /// <summary>
    ///   Creates and initializes an instance of TPDFAcroFormAnnotation
    /// </summary>
    /// <param name="AcroForm">
    ///   Acroform manager
    /// </param>
    /// <param name="Page">
    ///   Page where will located this object
    /// </param>
    /// <param name="Box">
    ///   Specifies position of the object on the page.
    /// </param>
    /// <remarks>
    ///   Acroform manager must be received via TPDFDocument.Acroforms
    /// </remarks>
    constructor Create ( AcroForm: TPDFAcroForms; Page: TPDFPage; Box: TRect );
    /// <summary>
    ///   Specifies by which font control must be depicted
    /// </summary>
    /// <param name="StdFnt">
    ///   The name of Type1 font, by which information will be represented
    /// </param>
    /// <param name="Size">
    ///   The size of the symbols
    /// </param>
    /// <param name="FontColor">
    ///   The color of the font
    /// </param>
    procedure SetFont( StdFnt:TPDFStdFont;Size: Integer; FontColor:TPDFColor);overload;
    /// <summary>
    ///   Specifies by which font control must be depicted
    /// </summary>
    /// <param name="FontName">
    ///   The name of TrueType font, by which information will be represented
    /// </param>
    /// <param name="FontStyle">
    ///   The style of the font
    /// </param>
    /// <param name="Size">
    ///   The size of the symbols
    /// </param>
    /// <param name="FontColor">
    ///   The color of the font
    /// </param>
    procedure SetFont(FontName: String; FontStyle: TFontStyles; Size: Integer;
        FontColor: TPDFColor); overload;
    /// <summary>
    ///   Adds a hint to the control, which will be displayed in the viewer when mouse pointer is holded over control
    /// </summary>
    /// <param name="Caption">
    ///   Displayed message
    /// </param>
    /// <param name="Charset">
    ///   Charset of the caption
    /// </param>
    procedure AddHint(Caption:string{$ifndef UNICODE};Charset:TFontCharset = 0 {$endif});
    /// <summary>
    ///   The parameter specifies the basic color of the control
    /// </summary>
    property Color: TPDFColor write FColor;
    /// <summary>
    ///   An action to be performed when the mouse button is released inside the PDF control’s active area
    /// </summary>
    property OnMouseUp: TPDFAction write FOnMouseUp;
    /// <summary>
    ///   An action to be performed when the mouse button is pressed inside the PDF control’s active area.
    /// </summary>
    property OnMouseDown: TPDFAction write FOnMouseDown;
    /// <summary>
    ///   An action to be performed when the cursor enters the PDF control’s active area.
    /// </summary>
    property OnMouseEnter: TPDFAction write FOnMouseEnter;
    /// <summary>
    ///   An action to be performed when the cursor exits the PDF control’s active area.
    /// </summary>
    property OnMouseExit: TPDFAction write FOnMouseExit;
    /// <summary>
    ///   An action to be performed when the PDF control receives the input focus.
    /// </summary>
    property OnSetFocus: TPDFAction write FOnSetFocus;
    /// <summary>
    ///   An action to be performed when the PDF control is “blurred” (loses the input focus).
    /// </summary>
    property OnLostFocus: TPDFAction write FOnLostFocus;
  end;


  /// <summary>
  ///   A button represents an interactive control on the screen that the user can manipulate with the mouse.
  ///   TPDFButton create button in PDF document.
  /// </summary>
  TPDFButton = class(TPDFAcroFormAnnotation)
  protected
    FCaption:AnsiString;
    FUp: TPDFForm;
    FDown: TPDFForm;
    procedure Paint; virtual;
    procedure Save; override;
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFButton
    /// </summary>
    /// <param name="AcroForm">
    ///   Acroform manager
    /// </param>
    /// <param name="Page">
    ///   Page where will located this object
    /// </param>
    /// <param name="Name">
    ///   The name to be used for work with javascript.
    /// </param>
    /// <param name="Box">
    ///   Specifies position of the object on the page.
    /// </param>
    /// <param name="Caption">
    ///   Specifies a text string that identifies the control to the user.
    /// </param>
    /// <remarks>
    ///   Acroform manager must be received via TPDFDocument.Acroforms
    /// </remarks>
    constructor Create ( AcroForm: TPDFAcroForms; Page: TPDFPage;Name: AnsiString;  Box: TRect;Caption: AnsiString  );
  end;




  /// <summary>
  ///   TPDFInputAnnotation is base class of the all PDFControls where user can input/change data.
  /// </summary>
  TPDFInputAnnotation = class(TPDFAcroFormAnnotation)
  private
    FOnOtherControlChanged: TPDFJavaScriptAction;
    FOnKeyPress: TPDFJavaScriptAction;
    FOnBeforeFormatting: TPDFJavaScriptAction;
    FOnChange: TPDFJavaScriptAction;
    FRequired: Boolean;
    FReadOnly: Boolean;
    function CalcActions: AnsiString;
  public

    /// <summary>
    ///   Creates and initializes an instance of TPDFButton
    /// </summary>
    /// <param name="AcroForm">
    ///   Acroform manager
    /// </param>
    /// <param name="Page">
    ///   Page where will located this object
    /// </param>
    /// <param name="Name">
    ///   The name to be used when exporting interactive form field data from the document or work with
    ///   javascript.
    /// </param>
    /// <param name="Box">
    ///   Specifies position of the object on the page.
    /// </param>
    /// <remarks>
    ///   Acroform manager must be received via TPDFDocument.Acroforms
    /// </remarks>
    constructor Create ( AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString ; Box: TRect);
    /// <summary>
    ///   If property set to true , the user may not change the value of the field.
    /// </summary>
    property ReadOnly: Boolean  write FReadOnly;
    /// <summary>
    ///   If set, the control must have a value at the time it is exported by a submit-form action
    /// </summary>
    property Required: Boolean write FRequired;
    /// <summary>
    ///   A JavaScript action to be performed when the user types a keystroke into a text or combo box or
    ///   modifies the selection in a scrollable list. This allows the keystroke to be checked for validity
    ///   and rejected or modified.
    /// </summary>
    property OnKeyPress: TPDFJavaScriptAction write FOnKeyPress;
    /// <summary>
    ///   A JavaScript action to be performed before the field is formatted to display its current value.
    ///   This allows the field’s value to be modified before formatting.
    /// </summary>
    property OnBeforeFormatting: TPDFJavaScriptAction write FOnBeforeFormatting;
    /// <summary>
    ///   A JavaScript action to be performed when the field’s value is changed. This allows the new value to
    ///   be checked for validity.
    /// </summary>
    property OnChange: TPDFJavaScriptAction write FOnChange;
    /// <summary>
    ///   A JavaScript action to be performed when the value of another field changes, in order to
    ///   recalculate the value of this field.
    /// </summary>
    property OnOtherControlChanged: TPDFJavaScriptAction write FOnOtherCOntrolChanged;
  end;


  /// <summary>
  ///   TPDFEditBox is similar to TEdit control but serves for data input in PDF document
  /// </summary>
  TPDFEditBox = class(TPDFInputAnnotation)
  private
    FText: AnsiString;
    FIsPassword: Boolean;
    FShowBorder: Boolean;
    FMultiline: Boolean;
    FMaxLength: Integer;
    FJustification: THorJust;
    procedure SetMaxLength ( const Value: Integer );
  protected
    FShow: TPDFForm;
    procedure Paint; virtual;
    procedure Save; override;
  public

    /// <summary>
    ///   Creates and initializes an instance of TPDFEditBox
    /// </summary>
    /// <param name="AcroForm">
    ///   Acroform manager
    /// </param>
    /// <param name="Page">
    ///   Page where will located this object
    /// </param>
    /// <param name="Name">
    ///   The name to be used when exporting interactive form field data from the document or work with
    ///   javascript.
    /// </param>
    /// <param name="Box">
    ///   Specifies position of the object on the page
    /// </param>
    /// <remarks>
    ///   Acroform manager must be received via TPDFDocument.Acroforms
    /// </remarks>
    constructor Create ( AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString; Box: TRect);
    /// <summary>
    ///   Text present in PDF Edit control when file created.
    /// </summary>
    property Text: AnsiString read FText write FText;
    /// <summary>
    ///   If property set to true, the TPDFEdit may contain multiple lines of text; if clear, the field’s
    ///   text is restricted to a single line.
    /// </summary>
    property Multiline: Boolean write FMultiline;
    /// <summary>
    ///   If set, the field is intended for entering a secure password that should not be echoed visibly to
    ///   the screen. Characters typed from the keyboard should instead be echoed in some unreadable form,
    ///   such as asterisks or bullet characters.
    /// </summary>
    property IsPassword: Boolean write FIsPassword;
    /// <summary>
    ///   If property set to false border invisible.
    /// </summary>
    property ShowBorder: Boolean write FShowBorder;
    /// <summary>
    ///   The maximum length of the field’s text, in characters.
    /// </summary>
    property MaxLength: Integer write SetMaxLength;
    /// <summary>
    ///   Property set justification of input text.
    /// </summary>
    property Justification: THorJust write FJustification;
  end;


  /// <summary>
  ///   TPDFCheckBox like to TCheckBox (checkbox toggles between two states, on and off.) but create such
  ///   element in PDF Document.
  /// </summary>
  TPDFCheckBox = class(TPDFInputAnnotation)
  private
    FChecked: Boolean;
    FCaption: AnsiString;
  protected
    FCheck: TPDFForm;
    FUnCheck: TPDFForm;
    procedure Paint; virtual;
    procedure Save;override;
  public
    /// <summary>
    ///   Specifies a text string that identifies the control to the user.
    /// </summary>
    property Caption:AnsiString write FCaption ;
    /// <summary>
    ///   Start state of checkbox.
    /// </summary>
    property Checked: Boolean write FChecked;
  end;


  TPDFRadioButton = class;

  TPDFRadioGroup = class(TPDFObject)
  private
    FItems: array of TPDFRadioButton;
    FName:AnsiString;
  protected
    procedure Save;override;
  public
    constructor Create( Name:AnsiString;PDFEngine:TPDFEngine);
  end;

  /// <summary>
  ///   TPDFRadioButton liked to TRadioButton but create radiobutton in PDF document. For create set of
  ///   radiobuttons programmer must create some TPDFRadiobuttons with equal names and differences export
  ///   values.
  /// </summary>
  TPDFRadioButton = class(TPDFInputAnnotation)
  private
    FRG: TPDFRadioGroup;
    FChecked: Boolean;
    FExportValue: AnsiString;
  protected
    FCheck: TPDFForm;
    FUnCheck: TPDFForm;
    procedure Paint; virtual;
    procedure Save; override;
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFRadioButton
    /// </summary>
    /// <param name="AcroForm">
    ///   Acroform manager
    /// </param>
    /// <param name="Page">
    ///   Page where will located this object
    /// </param>
    /// <param name="Name">
    ///   The name to be used when exporting interactive form field data from the document or work with
    ///   javascript.
    /// </param>
    /// <param name="Box">
    ///   Specifies position of the object on the page
    /// </param>
    /// <param name="ExportValue">
    ///   Value whish will send to URL when PDF document will submited Must have only alphabet and numeric
    ///   characters.
    /// </param>
    /// <param name="Checked">
    ///   Initial state of the control
    /// </param>
    /// <remarks>
    ///   Acroform manager must be received via TPDFDocument.Acroforms
    /// </remarks>
    constructor Create ( AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString;Box: TRect; ExportValue: AnsiString; Checked: Boolean );
  end;


  /// <summary>
  ///   A combo box consisting of a drop list optionally accompanied by an editable text box in which the
  ///   user can type a value other than the predefined choices. TPDFComboBox liked to TComboBox but create
  ///   ComboBox in PDF Document.
  /// </summary>
  TPDFComboBox = class(TPDFInputAnnotation)
  private
    FEditEnabled: Boolean;
    FText: AnsiString;
    FItems: TStringList;
  protected
    FShow: TPDFForm;
    procedure Paint; virtual;
    procedure Save;override;
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFComboBox
    /// </summary>
    /// <param name="AcroForm">
    ///   Acroform manager
    /// </param>
    /// <param name="Page">
    ///   Page where will located this object
    /// </param>
    /// <param name="Name">
    ///   The name to be used when exporting interactive form field data from the document or work with
    ///   javascript.
    /// </param>
    /// <param name="Box">
    ///   Specifies position of the object on the page
    /// </param>
    /// <remarks>
    ///   Acroform manager must be received via TPDFDocument.Acroforms
    /// </remarks>
    constructor Create ( AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString ; Box: TRect );
    destructor Destroy; override;
    /// <summary>
    ///   Provides access to the list of items (strings) in the list portion of the combo box.
    /// </summary>
    property Items: TStringList read FItems;
    /// <summary>
    ///   If property set to true, the combo box includes an editable text box as well as a drop list; if
    ///   false, it includes only a drop list.
    /// </summary>
    property EditEnabled: Boolean write FEditEnabled;
    /// <summary>
    ///   A text string identifying which of the available options is currently selected.
    /// </summary>
    property Text: AnsiString read FText write FText;
  end;


  /// <summary>
  ///   TPDFListBox like to TListBox but mean for select value in PDF documents.
  /// </summary>
  TPDFListBox = class(TPDFInputAnnotation)
  private
    FToff: Integer;
    FItemIndex: integer;
    FItems: TStringList;
  protected
    FShow: TPDFForm;
    procedure Paint; virtual;
    procedure Save;override;
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFListBox
    /// </summary>
    /// <param name="AcroForm">
    ///   Acroform manager
    /// </param>
    /// <param name="Page">
    ///   Page where will located this object
    /// </param>
    /// <param name="Name">
    ///   The name to be used when exporting interactive form field data from the document or work with
    ///   javascript.
    /// </param>
    /// <param name="Box">
    ///   Specifies position of the object on the page
    /// </param>
    /// <remarks>
    ///   Acroform manager must be received via TPDFDocument.Acroforms
    /// </remarks>
    constructor Create ( AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString ; Box: TRect);
    destructor Destroy; override;
    /// <summary>
    ///   This parameter provides access to all the lines of listbox, allows to manipulate them
    /// </summary>
    property Items: TStringList read FItems;
    /// <summary>
    ///   Index of the page, which must be marked at the time of opening the document
    /// </summary>
    property ItemIndex:Integer write FItemIndex ;
  end;


  /// <summary>
  ///  This class creates a place for the digital signature  in the document  and the user by clicking 
  ///  on this place gets an offer from the viewer to make a digital signature.
  /// </summary>
  TPDFDigitalSignatureAnnotation = class (TPDFAcroFormAnnotation)
  private
    FName: AnsiString;
    FSignature: TPDFObject;
    function GetForm: TPDFForm;
  protected
    FForm: TPDFForm;
    procedure Save;override;
    procedure SetPage(Page: TPDFPage; Box: TRect);
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFDigitalSignatureAnnotation
    /// </summary>
    /// <param name="AcroForm">
    ///   Acroform manager
    /// </param>
    /// <param name="Page">
    ///   Page where will located this object
    /// </param>
    /// <param name="Name">
    ///   The name to be used when exporting interactive form field data from the document or work with
    ///   javascript.
    /// </param>
    /// <param name="Box">
    ///   Specifies position of the object on the page
    /// </param>
    /// <remarks>
    ///   Acroform manager must be received via TPDFDocument.Acroforms
    /// </remarks>
    constructor Create ( AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString; Box: TRect);
    destructor Destroy;override;
    /// <summary>
    ///   When you create an object, a form in which you can make any graphical manipulation is created. This parameter provides access to this form
    /// </summary>
    property Form: TPDFForm read GetForm;
  end;


  /// <summary>
  ///   The class specifies a digital signature for generated document
  /// </summary>
  TPDFSignature = class (TPDFObject)
  private
    FAnnotation:TPDFDigitalSignatureAnnotation;
    FPFX:TPKCS12Document;
    FSign:TASN1BaseObject;
    FDigest:TASN1Data;
    FHash: AnsiString;
    FSignedDigest:TASN1Data;
    FOwner: TObject;
    FName: AnsiString;
    FReason: AnsiString;
    FContactInfo: AnsiString;
    FLocation: AnsiString;
    FAuthorName: AnsiString;
    FContentPosition:Integer;
    FContentEndPosition: Integer;
    FSizePosition:Integer;
  protected
    procedure PrepareSign;
    procedure Save;override;
    procedure CalcHash;
    procedure SaveAdditional;override;
  public
    constructor Create(Document:TObject;Keys:TPKCS12Document);
    destructor Destroy;override;
    /// <summary>
    ///   When calling this function, a new TPDFForm is created, where it is possible to draw information related to the signature (the signature image for example)
    /// </summary>
    /// <param name="Page">
    ///   A page on which you need to create a visual representation of the form
    /// </param>
    /// <param name="Box">
    ///   The coordinates of the visual representation of the form on the page.
    /// </param>
    /// <returns>
    ///   New created form.
    /// </returns>
    function CreateVisualForm(Page: TPDFPage; Box: TRect):TPDFForm;
    /// <summary>
    ///   The name of digital signature
    /// </summary>
    property Name:AnsiString read FName write FName;
    /// <summary>
    ///   The name of the author of the generated document
    /// </summary>
    property AuthorName:AnsiString read FAuthorName write FAuthorName;
    /// <summary>
    ///   Location of the author
    /// </summary>
    property Location:AnsiString read FLocation write FLocation;
    /// <summary>
    ///   The reason why the generated document is signed
    /// </summary>
    property Reason: AnsiString read FReason write FReason;
    /// <summary>
    ///   Contact information of the author of the document
    /// </summary>
    property ContactInfo: AnsiString read FContactInfo write FContactInfo;
  end;
 



  /// <summary>
  ///   A reset-form action resets selected PDF controls to their default values. (Default values is values
  ///   set to controls at time of create PDF document)
  /// </summary>

  TPDFResetAction = class(TPDFAction)
  private
    FList:TList;
    FIsResetList:Boolean;
  protected
    procedure Save;override;
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFResetAction
    /// </summary>
    /// <param name="Actions">
    ///   the object which manages all the PDFActions
    /// </param>
    /// <param name="IsResetList">
    ///  If this parameter is set to True, the annotations that will be further added by method Add, at the performance of this 
    ///  action will be reset to the original state, if not, will reset all the remaining annotations
    /// </param>
    /// <remarks>
    ///   Actions must be received via TPDFDocument.Actions
    /// </remarks>
    constructor Create ( Actions: TPDFActions; IsResetList: Boolean);
    destructor Destroy; override;
    /// <summary>
    ///   Adds to the list, which this action will work with, PDF control
    /// </summary>
    /// <remarks>
    ///  To the list may be added only TPDFInputAnnotation object or its descendant
    /// </remarks>
    procedure Add (Annotation:TPDFObject);
  end;


  /// <summary>
  ///   A submit-form action transmits the names and values of selected PDF Controls to a specified uniform
  ///   resource locator (URL), presumably the address of a World Wide Web server that will process them and
  ///   send back a response.
  /// </summary>
  TPDFSubmitAction = class(TPDFAction)
    private
    FList:TList;
    FIsSubmitList: Boolean;
    FSendEmpty: Boolean;
    FURL:AnsiString;
    FSubmitType:TPDFSubmitType;
  protected
    procedure Save;override;
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFSubmitAction
    /// </summary>
    /// <param name="Actions">
    ///   The object which manages all the PDFActions
    /// </param>
    /// <param name="URL">
    ///   URL by which must be passed the values of selected controls
    /// </param>
    /// <param name="IsSubmitList">
    ///   when True then values of all the controls that are added by Add method  are passed by 
    /// the abovementioned Url, otherwise there will be passed all controls that were not added
    /// </param>
    /// <param name="SubmitType">
    ///   Type in which the values will be passed to the specified URL
    /// </param>
    /// <param name="SendEmpty">
    ///   Specifies whether to pass empty values
    /// </param>
    constructor Create ( Actions: TPDFActions; URL:AnsiString; IsSubmitList: Boolean;SubmitType:TPDFSubmitType;SendEmpty:Boolean);
    destructor Destroy; override;
    /// <summary>
    ///   Adds to the list, wich this action will work with, PDF control
    /// </summary>
    /// <remarks>
    ///   To the list may be added only TPDFInputAnnotation object or its descendant 
    /// </remarks>
    procedure Add (Annotation:TPDFObject);
  end;


implementation


uses llPDFResources, llPDFSecurity, llPDFDocument,
 llPDFCertKey, llPDFRSA,
  llPDFCrypt;


function LightColor(Color:TPDFColor):TPDFColor;
begin
  Result.ColorSpace := Color.ColorSpace;
  case Color.ColorSpace of
    csGray:
      begin
        Result.Gray := (1 + Color.Gray ) / 2;
      end;
    csRGB:
      begin
        Result.Red := (1 + Color.Red ) / 2;
        Result.Green := (1 + Color.Green ) / 2;
        Result.Blue := (1 + Color.Blue ) / 2;
      end;
  else
    Result := Color;
  end;
end;

function DarkColor(Color:TPDFColor):TPDFColor;
begin
  Result.ColorSpace := Color.ColorSpace;
  case Color.ColorSpace of
    csGray:
      begin
        Result.Gray := Color.Gray / 2;
      end;
    csRGB:
      begin
        Result.Red := Color.Red / 2;
        Result.Green := Color.Green / 2;
        Result.Blue := Color.Blue / 2;
      end;
  else
    Result := Color;
  end;
end;


{ TPDFTextAnnotation }

constructor TPDFTextAnnotation.Create(Page: TPDFPage; Box: TRect);
begin
  inherited Create( Page, Box);
end;

procedure TPDFTextAnnotation.Save;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /Annot' );
  Eng.SaveToStream ( '/Subtype /Text' );
  Eng.SaveToStream ( '/Border ' + FBorderStyle );
  Eng.SaveToStream ( '/F ' + IStr ( CalcFlags ) );
  Eng.SaveToStream ( '/C [' + PDFColorToStr( FBorderColor )  + ' ]' );
  Eng.SaveToStream ( '/Rect [' + RectToStr( FLeft,FBottom, FRight, FTop ) + ']' );
  {$ifndef UNICODE}
  if FCharset = ANSI_CHARSET then
  begin
    Eng.SaveToStream ( '/T ' + CryptString( FCaption )  );
    Eng.SaveToStream ( '/Contents ' + CryptString ( FText ) );
  end else
  begin
    Eng.SaveToStream ( '/T ' + CryptString(UnicodeChar ( FCaption, FCharset ) ) );
    Eng.SaveToStream ( '/Contents ' + CryptString(UnicodeChar ( FText, FCharset ) ) ) ;
  end;
  {$else}
  Eng.SaveToStream ( '/T ' + CryptString(UnicodeChar ( FCaption ) ) );
  Eng.SaveToStream ( '/Contents ' + CryptString(UnicodeChar ( FText ) ) ) ;

  {$endif}
  case FTextAnnotationIcon of
    taiComment: Eng.SaveToStream ( '/Name /Comment' );
    taiKey: Eng.SaveToStream ( '/Name /Key' );
    taiNote: Eng.SaveToStream ( '/Name /Note' );
    taiHelp: Eng.SaveToStream ( '/Name /Help' );
    taiNewParagraph: Eng.SaveToStream ( '/Name /NewParagraph' );
    taiParagraph: Eng.SaveToStream ( '/Name /Paragraph' );
    taiInsert: Eng.SaveToStream ( '/Name /Insert' );
  end;
  if FOpened then
    Eng.SaveToStream ( '/Open true' )
  else
    Eng.SaveToStream ( '/Open false' );
  Eng.CloseObj;
end;

{ TPDFActionAnnotation }

constructor TPDFActionAnnotation.Create(Page: TPDFPage; Box: TRect;
  Action: TPDFAction);
begin
  inherited Create ( Page, Box );
  FAction := Action;
  FHilightMode := aahlInvert;
end;

procedure TPDFActionAnnotation.Save;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /Annot' );
  Eng.SaveToStream ( '/Subtype /Link' );
  Eng.SaveToStream ( '/Border ' + FBorderStyle );
  case FHilightMode of
    aahlNone: Eng.SaveToStream('/H /N');
    aalhOutline: Eng.SaveToStream('/H /O');
    aahlPush: Eng.SaveToStream('/H /P');
  end;
  Eng.SaveToStream ( '/F ' + IStr ( CalcFlags ) );
  Eng.SaveToStream ( '/C [' + PDFColorToStr ( FBorderColor ) + ' ]' );
  Eng.SaveToStream ( '/Rect [' + RectToStr( FLeft,FBottom, FRight, FTop ) + ']' );
  Eng.SaveToStream ( '/A ' + FAction.RefID );
  Eng.CloseObj;
end;



{ TPDFAcroFormAnnotation }

procedure TPDFAcroFormAnnotation.AddHint(Caption:string{$ifndef UNICODE};Charset:TFontCharset = 0 {$endif});
begin
  FHintCaption:= Caption;
{$ifndef UNICODE}
  FHintCharset:= Charset;
{$endif}
end;

function TPDFAcroFormAnnotation.CalcActions: AnsiString;
begin
  Result := '';
  if FOnMouseUp <> nil then
    Result := '/A ' + FOnMouseUp.RefID;
  Result := Result + '/AA <<';
  if FOnMouseEnter <> nil then
    Result := Result + '/E ' + FOnMouseEnter.RefID;
  if FOnMouseExit <> nil then
    Result := Result + '/X ' + FOnMouseExit.RefID;
  if FOnMouseDown <> nil then
    Result := Result + '/D ' + FOnMouseDown.RefID;
  if FOnLostFocus <> nil then
    Result := Result + '/Bl ' + FOnLostFocus.RefID;
  if FOnSetFocus <> nil then
    Result := Result + '/D ' + FOnSetFocus.RefID;
end;

function TPDFAcroFormAnnotation.CalcDAString: AnsiString;
begin
  case FFontColor.ColorSpace of
    csGray: Result := FormatFloat(FFontColor.Gray)+' g';
    csRGB: Result := FormatFloat(FFontColor.Red)+' '+FormatFloat(FFontColor.Green)+' '+FormatFloat(FFontColor.Blue)+ ' rg';
  else
    Result := FormatFloat(FFontColor.Cyan)+' '+FormatFloat(FFontColor.Magenta)+' '+
      FormatFloat(FFontColor.Yellow)+' '+FormatFloat(FFontColor.Key)+' k';
  end;
  Result := '/'+FFN+' '+FormatFloat(FSize)+' Tf '+ Result;
end;

constructor TPDFAcroFormAnnotation.Create(AcroForm: TPDFAcroForms;Page: TPDFPage; Box: TRect);
begin
  inherited Create( Page, Box);
  FAcroForm := AcroForm;
  FTrueType := False;
  FStdFont :=stdfHelvetica;
  FSize := 8;
  FFontColor := GrayToPDFColor(0);
end;

procedure TPDFAcroFormAnnotation.SetFont(StdFnt: TPDFStdFont;
  Size: Integer; FontColor: TPDFColor);
begin
  FTrueType := False;
  FStdFont :=StdFnt;
  FSize := Size;
  FFontColor := FontColor;
end;

procedure TPDFAcroFormAnnotation.SetFont(FontName: String;
  FontStyle: TFontStyles; Size: Integer; FontColor: TPDFColor);
begin
  FTrueType := True;
  FFontName :=FontName;
  FStyle := FontStyle;
  FSize := Size;
  FFontColor := FontColor;
end;

{ TPDFInputAnnotation }

function TPDFInputAnnotation.CalcActions: AnsiString;
begin
  Result := inherited CalcActions;
  if FOnKeyPress <> nil then
    Result := Result + '/K ' + FOnKeyPress.RefID;
  if FOnBeforeFormatting <> nil then
    Result := Result + '/F ' + FOnBeforeFormatting.RefID;
  if FOnChange <> nil then
    Result := Result + '/V ' + FOnChange.RefID;
  if FOnOtherControlChanged <> nil then
    Result := Result + '/C ' + FOnOtherControlChanged.RefID;
end;

constructor TPDFInputAnnotation.Create(AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString ; Box: TRect);
var
 i: Integer;
begin
  inherited Create( AcroForm,Page,Box);
  FName := Name;
  FColor := GrayToPDFColor(1);
  FBorderColor := GrayToPDFColor(0);
  if Self is TPDFRadioButton then
    Exit;
  I := Length(FAcroForm.FAcros);
  SetLength(FAcroForm.FAcros, i +1 );
  FAcroForm.FAcros[i] := Self;
end;

{ TPDFButton }

constructor TPDFButton.Create(AcroForm: TPDFAcroForms;Page: TPDFPage; Name: AnsiString;Box: TRect;
  Caption: AnsiString);
begin
  inherited Create( AcroForm, Page, Box);
  FCaption := Caption;
  FColor := RGBToPDFColor(0.75,0.75,0.75);
  FName := Name;
end;

procedure TPDFButton.Paint;
begin
  with FUp do
  begin
    Width := abs ( FRight - FLeft );
    Height := abs ( FBottom - FTop );
    SetColorFill ( DarkColor(FColor) );
    MoveTo ( Width - 0.5, 0.5 );
    LineTo ( Width - 0.5, Height - 0.5 );
    LineTo ( 0.5, Height - 0.5 );
    LineTo ( 1.5, Height - 1.5 );
    LineTo ( Width - 1.5, Height - 1.5 );
    LineTo ( Width - 1.5, 1.5 );
    LineTo ( Width - 0.5, 0.5 );
    Fill;
    SetColorFill ( LightColor(FColor) );
    MoveTo ( 0.5, Height - 0.5 );
    LineTo ( 0.5, 0.5 );
    LineTo ( Width - 0.5, 0.5 );
    LineTo ( Width - 1.5, 1.5 );
    LineTo ( 1.5, 1.5 );
    LineTo ( 1.5, Height - 1.5 );
    LineTo ( 0.5, Height - 0.5 );
    Fill;
    SetColorFill ( FColor );
    Rectangle ( 1.5, 1.5, Width - 1.5, Height - 1.5 );
    Fill;
    SetLineWidth ( 1 );
    SetColorStroke ( FBorderColor );
    Rectangle ( 0, 0, Width, Height );
    Stroke;
    if FTrueType then
      SetActiveFont ( FFontName, FStyle, FSize, 0 )
    else
      SetActiveFont(FStdFont,FSize);
    SetCurrentFont ( 0 );
    SetColorFill ( FFontColor );
    TextBox ( Rect ( 0, 0, Width, Height ), FCaption, hjCenter, vjCenter );
    FFN := TPDFFont(Eng.Resources.LastFont).AliasName;
  end;
  with FDown do
  begin
    Width := abs ( FRight - FLeft );
    Height := abs ( FBottom - FTop );
    SetLineWidth ( 1 );
    SetColorFill ( FColor );
    Rectangle ( 0, 0, Width, Height );
    Fill;
    SetColorStroke ( LightColor(FColor) );
    MoveTo ( Width - 0.5, 1 );
    LineTo ( Width - 0.5, Height - 0.5 );
    LineTo ( 1, Height - 0.5 );
    Stroke;
    SetColorStroke ( DarkColor(FColor) );
    MoveTo ( 0.5, Height - 1 );
    LineTo ( 0.5, 0.5 );
    LineTo ( Width - 1, 0.5 );
    Stroke;
    SetColorStroke ( FBorderColor );
    Rectangle ( 0, 0, Width, Height );
    Stroke;
    if FTrueType then
      SetActiveFont ( FFontName, FStyle, FSize, 0 )
    else
      SetActiveFont(FStdFont,FSize);
    SetCurrentFont ( 0 );
    SetColorFill ( FFontColor );
    TextBox ( Rect ( 0, 0, Width, Height - 2 ), FCaption, hjCenter, vjCenter );
  end;
end;

procedure TPDFButton.Save;
var
  i: Integer;
begin
 FUp := TPDFForm.Create ( Eng,FAcroForm.FFontManager );
  try
    FDown := TPDFForm.Create ( Eng,FAcroForm.FFontManager );
    try
      Paint;
      Eng.SaveObject(FUp);
      Eng.SaveObject(FDown);
      if FTrueType then
        FAcroForm.AddFont(FFontName,FStyle)
      else
        FAcroForm.AddFont(FStdFont);
      Eng.StartObj ( ID );
      Eng.SaveToStream ( '/Type /Annot' );
      Eng.SaveToStream ( '/Subtype /Widget' );
      Eng.SaveToStream ( '/T '+  CryptString(FName));

      Eng.SaveToStream ( '/Rect [' + RectToStr(FLeft,FBottom, FRight,FTop ) + ']' );
      Eng.SaveToStream ( '/P ' + FOwner.RefID);
      Eng.SaveToStream ( '/MK <</CA ' +CryptString( FCaption ) , False );
      Eng.SaveToStream ( '/BC [' + PDFColorToStr ( FBorderColor ) + ' ]', False );
      Eng.SaveToStream ( '/BG [' + PDFColorToStr ( FColor ) + ' ]', False );
      Eng.SaveToStream ( '>>' );
      Eng.SaveToStream ( '/DA ' + CryptString(CalcDAString) );
      Eng.SaveToStream ( '/BS <</W 1 /S /B>>' );
      Eng.SaveToStream ( '/FT /Btn' );
      if FHintCaption <> '' then
        {$ifndef UNICODE}
        if ( FHintCharset in [ 0..2 ] ) then
          Eng.SaveToStream ( '/TU ' + CryptString( FHintCaption ) )
        else
          Eng.SaveToStream ( '/TU ' + CryptString( UnicodeChar ( FHintCaption, FHintCharset ) ) );
        {$else}
         Eng.SaveToStream ( '/TU ' + CryptString( UnicodeChar ( FHintCaption ) ) );
        {$endif}
      i := 1 shl 16;
      Eng.SaveToStream ( '/F ' + IStr ( CalcFlags ) );
      Eng.SaveToStream ( '/Ff ' + IStr ( i ) );
      Eng.SaveToStream ( '/H /P' );
      Eng.SaveToStream ( '/AP <</N ' + FUp.RefID, False );
      Eng.SaveToStream ( '/D ' + FDown.RefID, False );
      Eng.SaveToStream ( '>>' );
      Eng.SaveToStream ( CalcActions + '>>' );
      Eng.CloseObj;
    finally
      FDown.Free;
    end;
  finally
    FUp.Free;
  end;
end;

{ TPDFAcroForms }

procedure TPDFAcroForms.AddFont(StdFnt: TPDFStdFont);
var
  i: Integer;
  FNT: TPDFFont;
begin
  FNT := FFontManager.GetFontByInfo(StdFnt);
  for i := 0 to Length( FFonts) -1 do
    if FFonts[i] = FNT then
      Exit;
  i := Length( FFonts);
  SetLength( FFonts, i + 1);
  FFonts[i] := FNT;
end;

procedure TPDFAcroForms.AddFont(FontName: String; Style: TFontStyles);
var
  i: Integer;
  FNT: TPDFFont;
begin
  FNT := FFontManager.GetFontByInfo(FontName, Style);
  for i := 0 to Length( FFonts) -1 do
    if FFonts[i] = FNT then
      Exit;
  i := Length( FFonts);
  SetLength( FFonts, i + 1);
  FFonts[i] := FNT;
end;

procedure TPDFAcroForms.Clear;
var
  I: Integer;
begin
  FFonts := nil;
  FAcros := nil;
  for I := 0 to Length(FRadioGroups) -1 do
    FRadioGroups[I].Free;
  FRadioGroups := nil;
  inherited;
end;

constructor TPDFAcroForms.Create(PDFEngine: TPDFEngine;Manager:TPDFFonts);
begin
  inherited Create(PDFEngine);
  FFontManager := Manager;
end;

destructor TPDFAcroForms.Destroy;
begin
  Clear;
  inherited;
end;

function TPDFAcroForms.GetCount: Integer;
begin
  if ( Length( FAcros)  = 0 ) and ( Length( FRadioGroups ) = 0 ) then
    Result := 0
  else
    Result := 1;
end;

procedure TPDFAcroForms.Save;
var
  I: Integer;
begin
  if ( Length( FAcros)  = 0 ) and ( Length( FRadioGroups ) = 0 ) then
    Exit;
  for I := 0 to Length(FRadioGroups) - 1 do
    FEngine.SaveObject ( FRadioGroups [ I ] );
  FEngine.StartObj(ID);
  FEngine.SaveToStream ( '/Fields [', False );
  for I := 0 to Length(FAcros) - 1 do
    FEngine.SaveToStream ( FAcros [ I ].RefID +' ', False );
  for I := 0 to Length(FRadioGroups) - 1 do
    FEngine.SaveToStream ( FRadioGroups [ I ].RefID, False );
  FEngine.SaveToStream ( ']', False );
  FEngine.SaveToStream ( '/DR <<');
  FEngine.SaveToStream ( '/Font <<', False );
  for I := 0 to Length( FFonts ) - 1 do
    FEngine.SaveToStream ( '/' + FFonts [ I ] .AliasName + ' ' + FFonts [ I ] .RefID , False );
  FEngine.SaveToStream ( '>> >>' );
  FEngine.SaveToStream ( '/CO [', False );
  for I := 0 to Length(FAcros) - 1 do
    if FAcros [ I ] is TPDFInputAnnotation then
      if TPDFInputAnnotation ( FAcros [ I ] ).FOnOtherCOntrolChanged <> nil then
        FEngine.SaveToStream ( FAcros [ I ].RefID+' ', False );
  FEngine.SaveToStream ( ']', False );
  for I := 0 to Length(FAcros) - 1 do
    if (FAcros [ I ] is TPDFDigitalSignatureAnnotation) and ((FAcros [ I ] as TPDFDigitalSignatureAnnotation).FSignature <>nil) then
    begin
      FEngine.SaveToStream('/SigFlags 3 ');
      Break;
    end;
  FEngine.CloseObj;
end;

{ TPDFCheckBox }

procedure TPDFCheckBox.Paint;
begin
  with FCheck do
  begin
    Width := abs ( FRight - FLeft );
    Height := abs ( FBottom - FTop );
    SetLineWidth ( 1 );
    SetColorFill ( FColor );
    Rectangle ( 0, 0, Width, Height );
    Fill;
    SetColor ( FBorderColor );
    Rectangle ( 0.5, 0.5, Height - 0.5, Height - 0.5 );
    Stroke;
    SetActiveFont ( stdfZapfDingbats, Height - 2 );
    TextBox ( Rect ( 2, 2, Height - 2, Height - 4 ), '8', hjCenter, vjCenter );
    SetColorFill ( FFontColor );
    if FTrueType then
      SetActiveFont ( FFontName, FStyle, FSize, 0 )
    else
      SetActiveFont(FStdFont,FSize);
    SetCurrentFont ( 0 );
    TextBox ( Rect ( Height + 4, 0, Width, Height ), FCaption, hjLeft, vjCenter );
  end;
  with FUncheck do
  begin
    Width := abs ( FRight - FLeft );
    Height := abs ( FBottom - FTop );
    SetLineWidth ( 1 );
    SetColorFill ( FColor );
    Rectangle ( 0, 0, Width, Height );
    Fill;
    SetColorStroke ( FBorderColor );
    Rectangle ( 0.5, 0.5, Height - 0.5, Height - 0.5 );
    Stroke;
    SetColorFill ( FFontColor );
    if FTrueType then
      SetActiveFont ( FFontName, FStyle, FSize, 0 )
    else
      SetActiveFont(FStdFont,FSize);
    SetCurrentFont ( 0 );
    TextBox ( Rect ( Height + 4, 0, Width, Height ), FCaption, hjLeft, vjCenter );
  end;
end;

procedure TPDFCheckBox.Save;
var
  i: Integer;
begin
  FCheck := TPDFForm.Create ( Eng, FAcroForm.FFontManager );
  try
    FUnCheck := TPDFForm.Create ( Eng, FAcroForm.FFontManager );
    try
      Paint;
      Eng.SaveObject(FCheck);
      Eng.SaveObject(FUnCheck);
      if FTrueType then
        FAcroForm.AddFont(FFontName,FStyle)
      else
        FAcroForm.AddFont(FStdFont);
      FAcroForm.AddFont(stdfZapfDingbats);
      Eng.StartObj ( ID );
      Eng.SaveToStream ( '/Type /Annot' );
      Eng.SaveToStream ( '/Subtype /Widget' );
      Eng.SaveToStream ( '/H /T' );
      Eng.SaveToStream ( '/Rect [' + RectToStr(FLeft,FBottom,FRight,FTop ) + ']' );
      Eng.SaveToStream ( '/P ' + FOwner.RefID);
      if FChecked then
        Eng.SaveToStream ( '/V /Yes /AS /Yes' )
      else
        Eng.SaveToStream ( '/V /Off /AS /Off' );
      Eng.SaveToStream ( '/T ' + CryptString( FName ) );
      Eng.SaveToStream ( '/FT /Btn' );
      Eng.SaveToStream ( '/F ' + IStr ( CalcFlags ) );
      i := 0;
      if FReadOnly then
        i := i or 1;
      if FRequired then
        i := i or 2;
      Eng.SaveToStream ( '/Ff ' + IStr ( i ) );
      Eng.SaveToStream ( '/AP <</N << /Yes ' + FCheck.RefID, False );
      Eng.SaveToStream ( '/Off  ' + FUnCheck.RefID + '>> ', False );
      Eng.SaveToStream ( '>>' );
      Eng.SaveToStream ( CalcActions + '>>' );
      Eng.CloseObj;
    finally
      FUnCheck.Free;
    end;
  finally
    FCheck.Free;
  end;
end;

{ TPDFComboBox }


constructor TPDFComboBox.Create(AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString; Box: TRect);
begin
  inherited Create ( AcroForm, Page, Name,Box);
  FItems := TStringList.Create;
end;

destructor TPDFComboBox.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TPDFComboBox.Paint;
begin
  with FShow do
  begin
    Width := abs ( FRight - FLeft );
    Height := abs ( FBottom - FTop );
    SetLineWidth ( 1 );
    SetColorFill ( FColor );
    SetColorStroke ( FBorderColor );
    Rectangle ( 0, 0, Width, Height );
    FillAndStroke;
    NewPath;
    Rectangle ( 0, 0, Width, Height );
    Clip;
    NewPath;
    AppendAction ( '/Tx BMC' );
    SetColorFill ( FFontColor );
    if FTrueType then
      SetActiveFont ( FFontName, FStyle, FSize, 0 )
    else
      SetActiveFont(FStdFont,FSize);
    SetCurrentFont ( 0 );
    TPDFFont(Eng.Resources.LastFont).SetAllASCII;
    FFN := TPDFFont(Eng.Resources.LastFont).AliasName;
    if FText <> '' then
      TextBox ( Rect ( 2, 2, Width - 2, Height - 2 ), FText, hjLeft, vjCenter );
    AppendAction ( 'EMC' );
  end;
end;

procedure TPDFComboBox.Save;
var
  i, j: Integer;
begin
  FShow := TPDFForm.Create ( Eng, FAcroForm.FFontManager );
  try
    Paint;
    if FTrueType then
      FAcroForm.AddFont(FFontName,FStyle)
    else
      FAcroForm.AddFont(FStdFont);
    Eng.SaveObject(FShow);
    Eng.StartObj ( ID );
    Eng.SaveToStream ( '/Type /Annot' );
    Eng.SaveToStream ( '/Subtype /Widget' );
        Eng.SaveToStream ( '/Rect [' + RectToStr(FLeft,FBottom,FRight,FTop ) + ']' );
    Eng.SaveToStream ( '/FT /Ch' );
    Eng.SaveToStream ( '/F ' + IStr ( CalcFlags ) );
    Eng.SaveToStream ( '/P ' + FOwner.RefID);
    Eng.SaveToStream ( '/T ' + CryptString( FName ) ) ;
    i := 0;
    if FReadOnly then
      i := i or 1;
    if FRequired then
      i := i or 2;
    j := 1 shl 17;
    i := i or j;
    if FEditEnabled then
    begin
      j := 1 shl 18;
      i := i or j;
    end;
    Eng.SaveToStream ( '/Ff ' + IStr ( i ) );
    Eng.SaveToStream ( '/Opt [', False );
    for i := 0 to Items.Count - 1 do
      Eng.SaveToStream ( CryptString( AnsiString(FItems [ i ] )) );
    Eng.SaveToStream ( ']' );
    if FText <> '' then
      Eng.SaveToStream ( '/V ' + CryptString(FText )  );
    if FText <> '' then
      Eng.SaveToStream ( '/DV ' + CryptString ( FText ) );
    Eng.SaveToStream ( '/DA ' + CryptString ( CalcDAString ) );
    Eng.SaveToStream ( '/AP <</N ' + FShow.RefID + '>> ' );
    Eng.SaveToStream ( CalcActions + '>>' );
    Eng.CloseObj;
  finally
    FShow.Free;
  end;
end;

{ TPDFListBox }

constructor TPDFListBox.Create(AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString ; Box: TRect);
begin
  inherited Create ( AcroForm, Page, Name, Box);
  FItems := TStringList.Create;
  FItemIndex := -1;
  FToff := -1;
end;

destructor TPDFListBox.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TPDFListBox.Paint;
const
  StdH:array[0..13] of Extended =
    (1.588, 1.635, 1.588, 1.635, 1.82, 1.82, 1.794, 1.8, 1.518, 1.566, 1.516, 1.566, 1.303, 0.963);
var
  i, lc, cnt, t: Integer;
  TH, FontHeight, LineHeight: Extended;
begin
  with FShow do
  begin
    Width := abs ( FRight - FLeft );
    Height := abs ( FBottom - FTop );
    SetLineWidth ( 1 );
    SetColorFill ( FColor );
    SetColorStroke ( FBorderColor );
    Rectangle ( 0, 0, Width, Height );
    FillAndStroke;
    NewPath;
    Rectangle ( 0, 0, Width, Height );
    Clip;
    NewPath;
    AppendAction ( '/Tx BMC' );
    GStateSave;
    if FTrueType then
      SetActiveFont ( FFontName, FStyle, FSize, 0 )
    else
      SetActiveFont(FStdFont,FSize);
    FontHeight := TPDFFont(Eng.Resources.LastFont).Ascent * FSize /1000;
    if FTrueType then
      LineHeight := FontHeight * 1.6
    else
      LineHeight := FontHeight * StdH[Ord(FStdFont)];
    TH := LineHeight + FontHeight;
    lc := Floor( Height / TH );
    SetCurrentFont ( 0 );
    if (FItemIndex <0) or (FItemIndex >=FItems.Count) then
    begin
      cnt := Min(FItems.Count,lc);
      SetColorFill ( FFontColor );
      for i := 0 to cnt -1  do
      begin
        TextOut(1, TH*i+LineHeight/2,0, AnsiString(FItems[i]));
      end;
      FToff := -1;
    end else
    begin
      t:=0;
      while FItemIndex >= t +lc do t := t+lc;
      cnt := Min(lc,FItems.Count - t );
      for i := 0 to cnt -1  do
      begin
        if FItemIndex <> i + t then
        begin
          SetColorFill ( FFontColor );
          TextOut(1, TH*i+LineHeight/2,0, AnsiString(FItems[i+t]));
        end else
        begin
          SetColorFill ( FFontColor );
          NewPath;
          Rectangle(0, TH*i, Width, (i+1)* TH+ LineHeight/2);
          Fill;
          SetColorFill ( InvertPDFColor(FFontColor) );
          TextOut(1, TH*i+LineHeight/2, 0, AnsiString(FItems[i+t]));
        end;
      end;
      FToff := t;
    end;
    FFN := TPDFFont(Eng.Resources.LastFont).AliasName;
    GStateRestore;
    AppendAction ( 'EMC' );
  end;
end;

procedure TPDFListBox.Save;
var
  i: Integer;
begin
  FShow := TPDFForm.Create ( Eng, FAcroForm.FFontManager );
  try
    Paint;
    if FTrueType then
      FAcroForm.AddFont(FFontName,FStyle)
    else
      FAcroForm.AddFont(FStdFont);
    Eng.SaveObject(FShow);
    Eng.StartObj ( ID );
    Eng.SaveToStream ( '/Type /Annot' );
    Eng.SaveToStream ( '/Subtype /Widget' );
        Eng.SaveToStream ( '/Rect [' + RectToStr(FLeft,FBottom,FRight,FTop ) + ']' );
    Eng.SaveToStream ( '/FT /Ch' );
    Eng.SaveToStream ( '/F ' + IStr ( CalcFlags ) );
    Eng.SaveToStream ( '/P ' + FOwner.RefID );
    Eng.SaveToStream ( '/T ' + CryptString( FName ) ) ;
    if (FItemIndex >= 0) and (FItemIndex< FItems.Count) then
    begin
      Eng.SaveToStream ( '/V ' + CryptString(AnsiString(FItems[FItemIndex] )));
      Eng.SaveToStream ( '/DV ' + CryptString ( AnsiString(FItems[FItemIndex])));
    end;

    i := 0;
    if FReadOnly then
      i := i or 1;
    if FRequired then
      i := i or 2;
    Eng.SaveToStream ( '/Ff ' + IStr ( i ) );
    Eng.SaveToStream ( '/Opt [', False );
    for i := 0 to Items.Count - 1 do
      Eng.SaveToStream ( CryptString( AnsiString(FItems [ i ] ) ));
    Eng.SaveToStream ( ']' );
    Eng.SaveToStream ( '/Q 0' );
    Eng.SaveToStream ( '/DA ' + CryptString ( CalcDAString ) );
    Eng.SaveToStream ( '/AP <</N ' + FShow.RefID + '>> ' );
    if FToff >=0 then
      Eng.SaveToStream ( '/F '+ IStr(FToff) );
    Eng.SaveToStream ( CalcActions + '>>' );
    Eng.CloseObj;
  finally
    FShow.Free;
  end;
end;

{ TPDFEditBox }

constructor TPDFEditBox.Create(AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString;  Box: TRect);
begin
  inherited Create ( AcroForm, Page, Name, Box );
  FBorderColor := GrayToPDFColor(0);
  FColor := GrayToPDFColor(1);
  FShowBorder := True;
  FMultiline := False;
  FIsPassword := False;
  FMaxLength := 0;
end;

procedure TPDFEditBox.Paint;
var
  s:AnsiString;
  i: Integer;
  HaveCR:Boolean;
begin
  HaveCR := false;
  with FShow do
  begin
    Width := abs ( FRight - FLeft );
    Height := abs ( FBottom - FTop );
    SetLineWidth ( 1 );
    SetColorFill ( FColor );
    SetColorStroke ( FBorderColor );
    Rectangle ( 0, 0, Width, Height );
    if FShowBorder then
      FillAndStroke
    else
      Fill;
    AppendAction ( '/Tx BMC' );
    SetColorFill ( FFontColor );
    if FTrueType then
      SetActiveFont ( FFontName, FStyle, FSize, 0 )
    else
      SetActiveFont(FStdFont,FSize);
    SetCurrentFont ( 0 );
    TPDFFont(Eng.Resources.LastFont).SetAllASCII;
    if FText <> '' then
      if not FIsPassword then
      begin
        s := FText;
        HaveCR := False;
        for i := 1 to Length(FText) do
          if FText[i] = #13 then
          begin
            HaveCR := True;
            Break;
          end;
      end else
      begin
        s := '';
        for i := 1 to Length ( FText ) do
          if not (FText[i] in [#10, #13]) then
            s := s + '*'
          else
          begin
            s := s + FText[i];
            HaveCR := True;
          end;
      end;
    if not (FMultiline and HaveCR ) then
      TextBox ( Rect ( 2, 2, Width - 2, Height - 2 ), s, FJustification, vjCenter )
    else
      TextOutBox(2,2, FSize, Width - 4, Height - 4,s);
    FFN := TPDFFont(Eng.Resources.LastFont).AliasName;
    NewPath;
    AppendAction ( 'EMC' );
  end;
end;

procedure TPDFEditBox.Save;
var
  i, j: Integer;
begin
  FShow := TPDFForm.Create ( Eng, FAcroForm.FFontManager );
  try
    Paint;
    if FTrueType then
      FAcroForm.AddFont(FFontName,FStyle)
    else
      FAcroForm.AddFont(FStdFont);
    Eng.SaveObject( FShow );
    Eng.StartObj ( ID );
    Eng.SaveToStream ( '/Type /Annot' );
    Eng.SaveToStream ( '/Subtype /Widget' );
        Eng.SaveToStream ( '/Rect [' + RectToStr(FLeft,FBottom,FRight,FTop ) + ']' );
    Eng.SaveToStream ( '/FT /Tx' );
    Eng.SaveToStream ( '/F ' + IStr ( CalcFlags ) );
    Eng.SaveToStream ( '/P ' + IStr ( FOwner.ID ) + ' 0 R' );
    Eng.SaveToStream ( '/T ' + CryptString( FName ) ) ;
    i := 0;
    if FReadOnly then
      i := i or 1;
    if FRequired then
      i := i or 2;
    if FMultiline then
    begin
      j := 1 shl 12;
      i := i or j;
    end;
    if FIsPassword then
    begin
      j := 1 shl 13;
      i := i or j;
    end;
    Eng.SaveToStream ( '/Ff ' + IStr ( i ) );
    case FJustification of
      hjCenter: Eng.SaveToStream ( '/Q 1' );
      hjRight: Eng.SaveToStream ( '/Q 2' );
    end;
    if FText <> '' then
    begin
      Eng.SaveToStream ( '/V ' + CryptString( FText ) );
      Eng.SaveToStream ( '/DV ' + CryptString( FText ) );
    end;
    if FMaxLength <> 0 then
      Eng.SaveToStream ( '/MaxLen ' + IStr ( FMaxLength ) );
    Eng.SaveToStream ( '/DA ' + CryptString(CalcDAString));
    Eng.SaveToStream ( '/AP <</N ' + FShow.RefID + '>> ' );
    Eng.SaveToStream ( CalcActions + '>>' );
    Eng.CloseObj;
  finally
    FShow.Free;
  end;
end;

procedure TPDFEditBox.SetMaxLength(const Value: Integer);
begin
  if Value < 0 then
    FMaxLength := 0
  else
    FMaxLength := Value;
end;

{ TPDFRadioButton }

constructor TPDFRadioButton.Create(AcroForm: TPDFAcroForms;
  Page: TPDFPage; Name:AnsiString; Box: TRect;  ExportValue: AnsiString; Checked: Boolean);
var
  I: Integer;
  WS: AnsiString;
  fnd: Boolean;
begin
  inherited Create(AcroForm, Page, Name,Box);
  fnd := False;
  for I := 0 to Length( AcroForm.FRadioGroups) -1 do
    if UCase(Name) = UCase(AcroForm.FRadioGroups[I].FName) then
    begin
      fnd := True;
      FRG := AcroForm.FRadioGroups[I];
      Break;
    end;
  if not fnd then
  begin
    I:= Length( FAcroForm.FRadioGroups);
    FRG := TPDFRadioGroup.Create( Name, Eng );
    SetLength(FAcroForm.FRadioGroups,I+1);
    FAcroForm.FRadioGroups[I] := FRG;
  end;
  WS := ReplStr ( ExportValue, ' ', '_' );
  if WS = '' then
      FExportValue := FName + IStr ( Length( FRG.FItems) );
  for I := 0 to Length( FRG.FItems) - 1 do
    if UCase ( FRG.FItems [ I ] .FExportValue ) = UCase ( WS ) then
        raise EPDFException.Create ( SExportValuePresent );
  FExportValue := WS;
  FChecked := Checked;
  if Checked then
    for I := 0 to Length( FRG.FItems) - 1 do
      FRG.FItems[I].FChecked := False;
  I := Length( FRG.FItems);
  SetLength( FRG.FItems, I + 1);
  FRG.FItems[I] := Self;
end;

procedure TPDFRadioButton.Paint;
begin
  with FCheck do
  begin
    Width := abs ( FRight - FLeft );
    Height := abs ( FBottom - FTop );
    SetLineWidth ( 1 );
    SetColorFill ( FColor );
    SetColorStroke ( FBorderColor );
    Circle ( Width / 2, Height / 2, Height / 2 - 0.5 );
    FillAndStroke;
    SetColorFill ( FFontColor );
    Circle ( Width / 2, Height / 2, Height / 4 - 0.5 );
    Fill;
  end;
  with FUncheck do
  begin
    Width := abs ( FRight - FLeft );
    Height := abs ( FBottom - FTop );
    SetLineWidth ( 1 );
    SetColorFill ( FColor );
    SetColorStroke ( FBorderColor );
    Circle ( Width / 2, Height / 2, Height / 2 - 0.5 );
    FillAndStroke;
  end;
  FFN := 'ZaDb';
  FSize := 0;
end;

procedure TPDFRadioButton.Save;
begin
  FCheck := TPDFForm.Create ( Eng, FAcroForm.FFontManager);
  try
    FUnCheck := TPDFForm.Create ( Eng, FAcroForm.FFontManager );
    try
      Paint;
      Eng.SaveObject(FCheck);
      Eng.SaveObject(FUnCheck);
      Eng.StartObj ( ID );
      Eng.SaveToStream ( '/Type /Annot' );
      Eng.SaveToStream ( '/Subtype /Widget' );
          Eng.SaveToStream ( '/Rect [' + RectToStr(FLeft,FBottom,FRight,FTop ) + ']' );
      Eng.SaveToStream ( '/P ' + FOwner.RefID );
      if FChecked then
        Eng.SaveToStream ( '/AS /' + FExportValue )
      else
        Eng.SaveToStream ( '/AS /Off' );
      Eng.SaveToStream ( '/MK <</CA ' + CryptString( 'l' ) , False );
      Eng.SaveToStream ( '/AC ' + CryptString(AnsiString('þÿ') ) + '/RC ' + CryptString(AnsiString( 'þÿ' )) , False );
      Eng.SaveToStream ( '/BC [' + PDFColorToStr ( FBorderColor )  + ' ]', False );
      Eng.SaveToStream ( '/BG [' + PDFColorToStr ( FColor ) + ' ]', False );
      Eng.SaveToStream ( '>>' );
      Eng.SaveToStream ( '/DA ' + CryptString( CalcDAString ) );
      Eng.SaveToStream ( '/F ' + IStr ( CalcFlags ) );
      Eng.SaveToStream ( '/Parent ' + FRG.RefID );
      Eng.SaveToStream ( '/AP <</N << /' + FExportValue + ' ' + FCheck.RefID, False );
      Eng.SaveToStream ( '/Off  ' + FUnCheck.RefID + '>> ', False );
      Eng.SaveToStream ( '/D << /' + FName + ' ' + FCheck.RefID , False );
      Eng.SaveToStream ( '/Off  ' + FUnCheck.RefID + '>> ', False );
      Eng.SaveToStream ( '>>' );
      Eng.SaveToStream ( '/H /T' );
      Eng.SaveToStream ( CalcActions + '>>' );
      Eng.CloseObj;
    finally
      FUnCheck.Free;
    end;
  finally
    FCheck.Free;
  end;
end;



{ TPDFRadioGroup }

constructor TPDFRadioGroup.Create(Name: AnsiString; PDFEngine: TPDFEngine);
begin
  inherited Create( PDFEngine);
  FName := Name;
end;

procedure TPDFRadioGroup.Save;
var
  I: Integer;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/FT /Btn' );
  Eng.SaveToStream ( '/T ' + CryptString( FName ) );
  for I := 0 to Length (FItems) - 1 do
    if FItems [ I ] .FChecked then
    begin
      Eng.SaveToStream ( '/V /' + FItems[i].FExportValue );
      Eng.SaveToStream ( '/DV /' + FItems[i].FExportValue );
      Break;
    end;
  Eng.SaveToStream ( '/Kids [', False );
  for I := 0 to Length (FItems) - 1 do
    Eng.SaveToStream ( FItems [ I ].RefID + ' ', False );
  Eng.SaveToStream ( ']' );
  I := 0;
  if FItems [ 0 ] .FReadOnly then
    i := i or 1;
  if FItems [ 0 ] .FRequired then
    i := i or 2;
  if Length(FItems) <> 1 then
    I := I or ( 1 shl 14 );
  I := I or ( 1 shl 15 );
  Eng.SaveToStream ( '/Ff ' + IStr ( I ) );
  Eng.CloseObj;
end;


{ TPDFResetAction }

procedure TPDFResetAction.Add(Annotation: TPDFObject);
begin
  if (Annotation is TPDFRadioGroup) or (Annotation is TPDFInputAnnotation) then
  begin
    if Annotation is TPDFRadioButton then
      Annotation := TPDFRadioButton(Annotation).FRG;
    if FList.IndexOf(Annotation) < 0 then
      FList.Add(Annotation);
  end
end;

constructor TPDFResetAction.Create(Actions: TPDFActions;
  IsResetList: Boolean);
begin
  inherited Create(Actions);
  FList :=TList.Create;
end;

destructor TPDFResetAction.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TPDFResetAction.Save;
var
  I: Integer;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/S /ResetForm' );
  if ( FList.Count > 0 )  then
  begin
    Eng.SaveToStream ( '/Fields [', False );
    for I := 0 to FList.Count - 1 do
      Eng.SaveToStream ( TPDFInputAnnotation(FList [ I ]).RefID + ' ', False );
    Eng.SaveToStream ( ']' );
    if not FIsResetList then
      Eng.SaveToStream ( '/Flags 1' );
  end;
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  Eng.CloseObj;
end;

{ TPDFSubmitAction }

procedure TPDFSubmitAction.Add(Annotation: TPDFObject);
begin
  if (Annotation is TPDFRadioGroup) or (Annotation is TPDFInputAnnotation) then
  begin
    if Annotation is TPDFRadioButton then
      Annotation := TPDFRadioButton(Annotation).FRG;
    if FList.IndexOf(Annotation) < 0 then
      FList.Add(Annotation);
  end
end;

constructor TPDFSubmitAction.Create(Actions: TPDFActions; URL: AnsiString;
  IsSubmitList: Boolean; SubmitType: TPDFSubmitType; SendEmpty: Boolean);
begin
  if URL = '' then
    raise EPDFException.Create ( SURLCannotBeEmpty );
  inherited Create(Actions);
  FList := TList.Create;
  FURL := URL;
  FIsSubmitList := IsSubmitList;
  FSubmitType:= SubmitType;
  FSendEmpty := SendEmpty;
end;

destructor TPDFSubmitAction.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TPDFSubmitAction.Save;
var
  Flag, I: Integer;
  S: AnsiString;
begin
  if FIsSubmitList then
    Flag := 0
  else
    Flag := 1;
  if FSubmitType <> StFDF then
  begin
    if FSubmitType <> stPost then
      Flag := Flag or 8;
    Flag := Flag or 4;
    S := '';
  end else
    S := '#FDF';
  if FSendEmpty then
    Flag := Flag or 2;
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/S /SubmitForm' );
  Eng.SaveToStream ( '/F <</FS /URL /F ' + CryptString( FURL + S )  + '>>' );
  if ( FList.Count > 0 ) then
  begin
    Eng.SaveToStream ( '/Fields [', False );
    for I := 0 to FList.Count - 1 do
      Eng.SaveToStream ( TPDFInputAnnotation(FList [ I ]).RefID + ' ', False );
    Eng.SaveToStream ( ']' );
  end;
  Eng.SaveToStream ( '/Flags ' + IStr ( Flag ) );
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  Eng.CloseObj;
end;



{ TPDFDigitalSignatureAnnotation }

constructor TPDFDigitalSignatureAnnotation.Create(AcroForm: TPDFAcroForms; Page: TPDFPage; Name: AnsiString; Box: TRect);
var
  I: Integer;
begin
  inherited Create(AcroForm,Page,Box);
  FName := Name;
  FSignature := nil;
  FForm := nil;
  I := Length(AcroForm.FAcros);
  SetLength(AcroForm.FAcros, i +1 );
  AcroForm.FAcros[i] := Self;
end;


destructor TPDFDigitalSignatureAnnotation.Destroy;
begin
  FForm.Free;
  inherited;
end;

function TPDFDigitalSignatureAnnotation.GetForm: TPDFForm;
begin
  if FForm = nil then
  begin
    FForm := TPDFForm.Create(Eng,FAcroForm.FFontManager);
    with FForm do
    begin
      Width := abs ( FRight - FLeft );
      Height := abs ( FBottom - FTop );
      SetLineWidth ( 1 );
      SetColorFill ( FColor );
      SetColorStroke ( FBorderColor );
    end;
  end;
  Result := FForm;
end;

procedure TPDFDigitalSignatureAnnotation.Save;
begin
  if FForm <> nil then
    Eng.SaveObject(FForm);
  if Assigned (FSignature) then
    Eng.SaveObject(FSignature);
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /Annot' );
  Eng.SaveToStream ( '/Subtype /Widget' );
      Eng.SaveToStream ( '/Rect [' + RectToStr(FLeft,FBottom,FRight,FTop ) + ']' );
  Eng.SaveToStream ( '/FT /Sig' );
  Eng.SaveToStream ( '/F 132');
  Eng.SaveToStream ( '/P ' + FOwner.RefID);
  Eng.SaveToStream ( '/T ' + CryptString( FName ) ) ;
  if Assigned (FSignature) then
    Eng.SaveToStream ( '/V ' + FSignature.RefID );
  if Assigned(FForm) then
    Eng.SaveToStream ( '/AP <</N ' + FForm.RefID + '>> ' );
  Eng.SaveToStream ( CalcActions + '>>' );
  Eng.CloseObj;
end;

procedure TPDFDigitalSignatureAnnotation.SetPage(Page: TPDFPage; Box: TRect);
begin
  ChangePage(Page,Box);
end;


{ TPDFSignature }

procedure TPDFSignature.CalcHash;
const
  BUFFSIZE = 1024*256;
var
  SHA: TSHA1Hash;
  RS: Integer;
  P: Pointer;
  SZ: {$ifndef CONDITIONALEXPRESSIONS}Int64 {$else} Cardinal {$endif} ;
  TStr, s: AnsiString;
  DigestObj,Algorithm, ASet, Attr, Tmp: TASN1Container;
begin
  SZ := Eng.Stream.Size;
  SHA := TSHA1Hash.Create;
  try
    SHA.Init;
    Eng.Stream.Position := 0;
    P := GetMemory(BUFFSIZE);
    try
      while Eng.Stream.Position <> FContentPosition do
      begin
        if Eng.Stream.Position + BUFFSIZE <= FContentPosition then
          RS := BUFFSIZE
        else
          RS := FContentPosition - Eng.Stream.Position;
        Eng.Stream.Read(P^,RS);
        SHA.Update(P^, RS);
      end;
      Eng.Stream.Position := FContentEndPosition;
      while Eng.Stream.Position <> SZ do
      begin
        if Eng.Stream.Position + BUFFSIZE <= SZ then
          RS := BUFFSIZE
        else
          RS := SZ - Eng.Stream.Position;
        Eng.Stream.Read(P^,RS);
        SHA.Update(P^, RS);
      end;
    finally
      FreeMemory(P)
    end;
    SetLength(FHash,SHA.HashSize);
    SHA.Finish(@FHash[1]);
    FDigest.Data := FHash;
    ASet := TASN1Container.Create(ASN1_TAG_SET, ASN1_CLASS_UNIVERSAL);
    try
      Attr := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
      ASet.Add(Attr);
      Attr.Add(TASN1ObjectID.CreateFromID(OID_pkcs9_messageDigest));
      Tmp := TASN1Container.Create(ASN1_TAG_SET,ASN1_CLASS_UNIVERSAL);
      Attr.Add(tmp);
      TMP.Add(TASN1Data.Create(ASN1_TAG_OCTET_STRING,ASN1_CLASS_UNIVERSAL,FHash));

      Attr := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
      ASet.Add(Attr);
      Attr.Add(TASN1ObjectID.CreateFromID(OID_pkcs9_contentType));
      Tmp := TASN1Container.Create(ASN1_TAG_SET,ASN1_CLASS_UNIVERSAL);
      Attr.Add(tmp);
      TMP.Add(TASN1ObjectID.CreateFromID(OID_pkcs7_Data));
      TStr := ASet.WriteToString;
    finally
      ASet.Free;
    end;
    SHA.Init;
    SHA.Update(TStr[1], Length(TStr));
    SetLength(s,20);
    SHA.Finish(@s[1]);
    DigestObj := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    try
      Algorithm :=TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
      DigestObj.Add(Algorithm);
      Algorithm.Add(TASN1ObjectID.CreateFromID(OID_sha1));
      Algorithm.Add(TASN1Null.Create);
      DigestObj.Add(TASN1Data.Create(ASN1_TAG_OCTET_STRING,ASN1_CLASS_UNIVERSAL,S));
      FSignedDigest.Data := SignDigest(FPFX.Chain.PrivateKey,DigestObj);
    finally
      DigestObj.Free;
    end;
  finally
    SHA.Free;
  end;
end;

constructor TPDFSignature.Create(Document:TObject;Keys:TPKCS12Document);
begin
  inherited Create(TPDFDocument(Document).AcroForms.FEngine);
  FName := 'Sign001';
  FPFX := Keys;
  FSign := nil;
  FOwner := Document;
  FAnnotation := TPDFDigitalSignatureAnnotation.Create(TPDFDocument(Document).AcroForms,
    TPDFDocument(Document).Page[0],FName,Rect(0,0,0,0));
  FAnnotation.FSignature := Self;
end;

function TPDFSignature.CreateVisualForm(Page: TPDFPage; Box: TRect): TPDFForm;
begin
  if Assigned(FAnnotation.FForm) then
    raise EPDFException.Create(SFormAlreadyExists);
  FAnnotation.SetPage(Page,Box);
  Result := FAnnotation.Form;
end;

destructor TPDFSignature.Destroy;
begin
  FSign.Free;
  FPFX.Free;
  inherited;
end;

procedure TPDFSignature.PrepareSign;
var
  Cont,WrkSeq,Data:TASN1Container;
  Fill:TASN1Container;
  ASet:TASN1Container;
  SignerInfo, IssuerAndSerialNumber,Algorithm, Digest, Content, AuthenticatedAttributes :TASN1Container;
  Chain: TX509Certificate;
  WorkStr:AnsiString;
  CertificateInfo: TASN1Container;
  SignatureSize:Integer;
begin
  Cont := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
  try
    Cont.Add(TASN1ObjectID.CreateFromID(OID_pkcs7_signed));
    Fill := TASN1Container.Create(0,ASN1_CLASS_CONTEXT);
    Cont.Add(Fill);
    Data := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    Fill.Add(Data);
    //Version
    Data.Add(TASN1Integer.Create(1,false));
    //Algorithm
    ASet := TASN1Container.Create(ASN1_TAG_SET,ASN1_CLASS_UNIVERSAL);
    Data.Add(ASet);
    Algorithm := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    ASet.Add(Algorithm);
    Algorithm.Add(TASN1ObjectID.CreateFromID(OID_sha1));
    Algorithm.Add(TASN1Null.Create);
    //contentInfo
    WrkSeq := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    Data.Add(WrkSeq);
    WrkSeq.Add(TASN1ObjectID.CreateFromID(OID_pkcs7_data));
    //certificates
    Fill := TASN1Container.Create(0,ASN1_CLASS_CONTEXT);
    Data.Add(Fill);
    Chain := FPFX.Chain;
    CertificateInfo := FPFX.Chain.ASN1Object[0] as TASN1Container;
    while Chain <> nil do
    begin
      Fill.Add(Chain.ASN1Object.Copy);
      Chain := Chain.Owner;
    end;
    //signerInfos
    ASet := TASN1Container.Create(ASN1_TAG_SET,ASN1_CLASS_UNIVERSAL);
    Data.Add(ASet);
    SignerInfo := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    ASet.Add(SignerInfo);
    //Version
    SignerInfo.Add(TASN1Integer.Create(1,false));
    // IssuerAndSerialNumber
    IssuerAndSerialNumber :=  TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    SignerInfo.Add(IssuerAndSerialNumber);
    IssuerAndSerialNumber.Add(CertificateInfo[3].Copy);
    IssuerAndSerialNumber.Add(CertificateInfo[1].Copy);
    Algorithm := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    SignerInfo.Add(Algorithm);
    Algorithm.Add(TASN1ObjectID.CreateFromID(OID_sha1));
    Algorithm.Add(TASN1Null.Create);
    AuthenticatedAttributes := TASN1Container.Create(0,ASN1_CLASS_CONTEXT);
    SignerInfo.Add(AuthenticatedAttributes);
    // Digest
    Digest := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    AuthenticatedAttributes.Add(Digest);
    Digest.Add(TASN1ObjectID.CreateFromID(OID_pkcs9_messageDigest));
    ASet := TASN1Container.Create(ASN1_TAG_SET,ASN1_CLASS_UNIVERSAL);
    Digest.Add(ASet);
    WorkStr := AnsiString(StringOfChar(#0,20));
    FDigest := TASN1Data.Create(ASN1_TAG_OCTET_STRING,ASN1_CLASS_UNIVERSAL,WorkStr);
    ASet.Add(FDigest);

    // ContentType
    Content := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    AuthenticatedAttributes.Add(Content);
    Content.Add(TASN1ObjectID.CreateFromID(OID_pkcs9_contentType));
    ASet := TASN1Container.Create(ASN1_TAG_SET,ASN1_CLASS_UNIVERSAL);
    Content.Add(ASet);
    ASet.Add(TASN1ObjectID.CreateFromID(OID_pkcs7_data));

    Algorithm := TASN1Container.Create(ASN1_TAG_SEQUENCE,ASN1_CLASS_UNIVERSAL);
    SignerInfo.Add(Algorithm);
    Algorithm.Add(TASN1ObjectID.CreateFromID(OID_rsaEncryption));
    Algorithm.Add(TASN1Null.Create);
    if FPFX.Chain.PrivateKey.Modulus.Data[1] = #0 then
      SignatureSize := Length(FPFX.Chain.PrivateKey.Modulus.Data) - 1
    else
      SignatureSize := Length(FPFX.Chain.PrivateKey.Modulus.Data);
    inc(SignatureSize,20);
    WorkStr := AnsiString(StringOfChar(#0,SignatureSize));
    FSignedDigest := TASN1Data.Create(ASN1_TAG_OCTET_STRING,ASN1_CLASS_UNIVERSAL,WorkStr);
    SignerInfo.Add(FSignedDigest)
  except
    on Exception do
    begin
      Cont.Free;
      raise;
    end;
  end;
  FSign := Cont;
end;

procedure TPDFSignature.Save;
var
  S:AnsiString;
  L:Integer;
begin
  PrepareSign;
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /Sig' );
  Eng.SaveToStream ( '/SubFilter /adbe.pkcs7.detached');
  Eng.SaveToStream ( '/Filter /Adobe.PPKMS');
  Eng.SaveToStream ( '/Contents ',false);
  FContentPosition := Eng.Stream.Position;
  L := FSign.Size shl 1;
  SetLength(s,L);
  FillChar(S[1],L,'0');
  s := '<'+S;
  Eng.SaveToStream ( S ,false);
  Eng.SaveToStream ( '>',false);
  FContentEndPosition := Eng.Stream.Position;
  Eng.SaveToStream ( #13'/ByteRange [0 '+ IStr(FContentPosition)+' '+IStr(FContentEndPosition )+' ',False);
  FSizePosition := Eng.Stream.Position;
  Eng.SaveToStream ( '          ]');
  Eng.SaveToStream ( '/M ' + CryptString ( 'D:' + AnsiString(FormatDateTime ( 'yyyymmddhhnnss', GMTNow ))+'Z' ));
  Eng.SaveToStream ( '/Name ' + CryptString( FName ) ) ;
  if FLocation <>'' then
    Eng.SaveToStream ( '/Location ' + CryptString( FLocation ) ) ;
  if FReason <>'' then
    Eng.SaveToStream ( '/Reason ' + CryptString( FReason ) ) ;
  if FContactInfo <>'' then
    Eng.SaveToStream ( '/ContactInfo ' + CryptString( FContactInfo ) ) ;
  Eng.CloseObj;
end;

procedure TPDFSignature.SaveAdditional;
var
  EndPos:Integer;
  S:AnsiString;
begin
  EndPos := Eng.Stream.Position - FContentEndPosition;
  Eng.Stream.Position := FSizePosition;
  Eng.SaveToStream(IStr(EndPos),False);
  CalcHash;
  Eng.Stream.Position := FContentPosition+1;
  S := FSign.WriteToString; ;
  Eng.SaveToStream(StringToHex(S,false),False);
end;



end.

