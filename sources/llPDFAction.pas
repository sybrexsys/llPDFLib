{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun     
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFAction;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif}
  llPDFEngine, llPDFCanvas, llPDFTypes;

type


  TPDFActions = class;

  /// <summary>
  ///   All interactive operation in PDF documents (jump to page, go to URL,
  ///   change state of the PDF controls) possible create with help of the
  ///   actions. TPDFAction is the base class for all actions.
  /// </summary>
  TPDFAction = class(TPDFObject)
  private
    FOwner:TPDFActions;
  protected                                     
    FNext: TPDFAction;
  public

    /// <summary>
    ///   Description: Creates and initializes an instance of TPDFAction.
    /// </summary>
    /// <param name="Actions">
    ///   The object, which is responsible for managing all PDF Actions.
    /// </param>
    constructor Create(Actions: TPDFActions);

    /// <summary>
    ///   In some cases it is necessary to perform a chain of actions,
    ///   and then we create the chain with this procedure 
    /// </summary>
    /// <param name="Next">
    ///   TPDFAction which must be run after performing of this "action"
    /// </param>
    procedure AddNext(Next:TPDFAction);
  end;



  /// <summary>
  ///   Class for managing action objects of PDF document.
  /// </summary>
  /// <remarks>
  ///   Please not create this object directly. Use property of TPDFDocument.
  /// </remarks>
  TPDFActions = class ( TPDFListManager)
  private
    FPages: TPDFPages;
  public
    constructor Create ( PDFEngine:TPDFEngine; Pages: TPDFPages);
  end;




  /// <summary>
  ///   A uniform resource locator (URL) is a string that identifies (resolves
  ///   to) a resource on the Internet—typically a file that is the destination
  ///   of a hypertext link, although it can also resolve to a query or other
  ///   entity. A URL action causes a URL to be resolved.
  /// </summary>
  TPDFUrlAction = class(TPDFAction)
  private
    FUrl:AnsiString;
  protected
    procedure Save;override;
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFUrlAction
    /// </summary>
    /// <param name="Actions">
    ///   The object, which is responsible for managing all PDFActions.
    /// </param>
    /// <param name="URL">
    ///   URL which will be requested when performing this action
    /// </param>
    constructor Create( Actions: TPDFActions;URL: AnsiString);
  end;



  /// <summary>
  ///   A TPDFGotoPageAction action changes the view to a specified destination (page, location) in current
  ///   PDF document.
  /// </summary>
  TPDFGotoPageAction = class(TPDFAction)
  private
    FPageIndex:Integer;
    FTopOffset:Integer;
    FNoChange:Boolean;
  protected
    procedure Save;override;
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFGotoPageAction
    /// </summary>
    /// <param name="Actions">
    ///   the object, which is responsible for managing all PDFActions.
    /// </param>
    /// <param name="PageIndex">
    ///   Index of the page to go to
    /// </param>
    /// <param name="TopOffset">
    ///   The offset relative to the top of the page which is to be performed during the transition
    /// </param>
    /// <param name="NoChangeZoom">
    ///   Specifies whether to change the zoom of the page which the transition will be made on
    /// </param>
    constructor Create( Actions: TPDFActions;PageIndex,TopOffset:Integer;NoChangeZoom: Boolean);
  end;


  /// <summary>
  ///   A hide action hides or shows one or more PDF controls on the screen by setting or clearing their
  ///   Hidden flags.
  /// </summary>
  TPDFVisibleAction = class(TPDFAction)
  private
    FList:TList;
    FIsHide:Boolean;
  protected
    procedure Save;override;
  public

    /// <summary>
    ///   Creates and initializes an instance of TPDFVisibleAction
    /// </summary>
    /// <param name="Actions">
    ///   the object, which is responsible for managing all PDFActions.
    /// </param>
    /// <param name="IsHide">
    ///   This parameter whether annotations which are relative to this action will be hidden or shown 
    /// </param>
    constructor Create ( Actions: TPDFActions; IsHide: Boolean);
    destructor Destroy; override;

    /// <summary>
    ///   Procedure to add annotations to the list on which activities on visibility will be held 
    /// </summary>
    /// <param name="Annotation">
    ///   Annotation to be added to the list
    /// </param>
    procedure Add (Annotation:TPDFAnnotation);
  end;


  /// <summary>
  ///   TPDFNamedDestinationAction is similar to TPDFGotoPageAction and allows tomake hypertransition, but
  ///   when using this action destination name is used instead of page number
  /// </summary>
  TPDFNamedDestinationAction = class(TPDFAction)
  private
    FDocument: String;
    FDestination: AnsiString;
    FNewWindow: Boolean;
  protected
    procedure Save;override;
  public

    /// <summary>
    ///   Creates and initializes an instance of TPDFNamedDestinationAction
    /// </summary>
    /// <param name="Actions">
    ///   The object, which is responsible for managing all PDFActions.
    /// </param>
    /// <param name="Document">
    ///   the name of the document to which you want to make the transition. If the parameter is blank, then the transition occurs
     /// to the same document, in which this action was performed 
    /// </param>
    /// <param name="Destination">
    ///   Destination name.
    /// </param>
    /// <param name="InNewWindow">
    ///   Defines where to open the document ( in the current window or in a new)
    /// </param>
    /// <remarks>
    ///   Destination can be created with TPDFDocument.Names.AppendNamedDestination
    /// </remarks>
    constructor Create( Actions: TPDFActions;Document:string; Destination:AnsiString;InNewWindow: Boolean);
  end;



  /// <summary>
  ///   A JavaScript action causes a script to be compiled and executed by the JavaScript interpreter.
  ///   Depending on the nature of the script, this can cause various interactive form fields in the document
  ///   to update their values or change their visual appearances. Adobe Technical Note #5186, "Acrobat Forms
  ///   JavaScript Object Specification" give details on the contents and effects of JavaScript scripts.
  /// </summary>
  TPDFJavaScriptAction = class(TPDFAction)
  private
    FJavaScript: AnsiString;
  protected
    procedure Save;override;
  public

    /// <summary>
    ///   Creates and initializes an instance of TPDFJavaScriptAction
    /// </summary>
    /// <param name="Actions">
    ///   The object, which is responsible for managing all PDFActions
    /// </param>
    /// <param name="JavaScript">
    ///   JavaScript when this action is performing
    /// </param>
    constructor Create( Actions: TPDFActions;JavaScript:AnsiString);
  end;



  /// <summary>
  ///   An import-data action imports Forms Data Format (FDF) data into the document’s interactive form from
  ///   a specified file. Structure of this file you can find Adobe PDF Reference.
  /// </summary>
  TPDFImportDataAction = class(TPDFAction)
  private
    FFileName: string;
  protected
    procedure Save; override;
  public

    /// <summary>
    ///   Creates and initializes an instance of TPDFImportDataAction
    /// </summary>
    /// <param name="Actions">
    ///   The object, which is responsible for managing all PDFActions
    /// </param>
    /// <param name="FileName">
    ///   Name of the file from which data will be imported to fill in online forms
    /// </param>
    constructor Create( Actions: TPDFActions;FileName:string);
  end;


  /// <summary>
  ///   TPDFNamedDestinationAction is similar to TPDFGotoPageAction allows to make transition,
  ///   but at using this action there is a possibility to go to another PDF document
  /// </summary>
  TPDFGotoRemoteAction = class(TPDFAction)
  private
    FInNewWindow: Boolean;
    FPageIndex: Integer;
    FDocument: string;
  protected
    procedure Save;override;
  public

    /// <summary>
    ///   Creates and initializes an instance of TPDFGotoRemoteAction
    /// </summary>
    /// <param name="Actions">
    ///   The object, which is responsible for managing all PDFActions
    /// </param>
    /// <param name="Document">
    ///   Name of the document, to which it is necessary to go in case of performance of this action
    /// </param>
    /// <param name="PageIndex">
    ///   Index of the page to go to
    /// </param>
    /// <param name="InNewWindow">
    ///   Specifies, whether to open the document in a new window.
    /// </param>
    constructor Create( Actions: TPDFActions;Document:string;PageIndex:Integer;InNewWindow: Boolean);
  end;



implementation

uses llPDFResources, llPDFMisc, llPDFAnnotation;


{ TPDFActions }

constructor TPDFActions.Create(PDFEngine: TPDFEngine; Pages: TPDFPages);
begin
  inherited Create( PDFEngine );
  FPages := Pages;
end;


{ TPDFAction }

procedure TPDFAction.AddNext(Next: TPDFAction);
begin
  FNext := Next;
end;
constructor TPDFAction.Create(Actions: TPDFActions);

begin
  inherited Create (Actions.FEngine);
  Actions.FList.Add(Self);
  FOwner := Actions;
end;

{ TPDFUrlAction }

constructor TPDFUrlAction.Create(Actions: TPDFActions; URL: AnsiString);
begin
  inherited Create( Actions );
  FUrl := URL;
end;

procedure TPDFUrlAction.Save;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/S /URI /URI ' + CryptString (FURL ) ) ;
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  Eng.CloseObj;
end;

{ TTPDFGotoPageAction }

constructor TPDFGotoPageAction.Create(Actions: TPDFActions; PageIndex,
  TopOffset: Integer;NoChangeZoom: Boolean);
begin
  if PageIndex < 0 then
    raise EPDFException.Create ( SPageIndexCannotBeNegative );
  if TopOffset < 0 then
    raise EPDFException.Create ( STopOffsetCannotBeNegative );
  inherited Create( Actions);
  FPageIndex := PageIndex;
  FTopOffset := TopOffset;
  FNoChange := NoChangeZoom;
end;

procedure TPDFGotoPageAction.Save;
begin
  if FPageIndex >= FOwner.FPages.Count then
    raise EPDFException.Create ( SOutOfRange );
  Eng.StartObj ( ID );
  if FNoChange then
  begin
    Eng.SaveToStream ( '/S /GoTo /D [' + FOwner.FPages [ FPageIndex ].RefID +
      '/FitH ' + IStr ( Round ( FOwner.FPages [ FPageIndex ].ExtToIntY ( FTopOffset ) ) ) + ']' );
  end
  else
  begin
    Eng.SaveToStream ( '/S /GoTo /D [' + FOwner.FPages [ FPageIndex ].RefID +
      '/XYZ null ' + IStr ( Round ( FOwner.FPages [ FPageIndex ].ExtToIntY ( FTopOffset ) ) ) + ' null ]' );
  end;
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  Eng.CloseObj;
end;

{ TPDFNamedDestinationAction }

constructor TPDFNamedDestinationAction.Create(Actions: TPDFActions;
  Document:string; Destination: AnsiString; InNewWindow: Boolean);
begin
  inherited Create( Actions );
  FDocument := Document;
  FDestination := Destination;
  FNewWindow := InNewWindow;
end;

procedure TPDFNamedDestinationAction.Save;
var
  S: AnsiString;
begin
  Eng.StartObj ( ID );
  if FDocument = '' then
  begin
    Eng.SaveToStream ( '/S /GoTo /D ' + CryptString( FDestination ) );
  end else
  begin
    if FNewWindow then
      S := 'true'
    else
      S := 'false';
    Eng.SaveToStream ( '/S /GoToR /D ' + CryptString( FDestination ) +
      '/F <</Type /Filespec /F ' + CryptString ( PrepareFileSpec ( FDocument  ) ) + ' >>/NewWindow ' + s );
  end;
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  Eng.CloseObj;
end;

{ TPDFGotoRemoteAction }

constructor TPDFGotoRemoteAction.Create(Actions: TPDFActions;
  Document: string; PageIndex: Integer; InNewWindow: Boolean);
begin
  if PageIndex < 0 then
    raise EPDFException.Create ( SPageIndexCannotBeNegative );
  inherited Create( Actions);
  FPageIndex := PageIndex;
  FInNewWindow := InNewWindow;
  FDocument := Document;
end;

procedure TPDFGotoRemoteAction.Save;
var
  S: AnsiString;
begin
  if FInNewWindow then
    S := 'true'
  else
    S := 'false';
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/S /GoToR /D [' + IStr ( FPageIndex ) +
    ' /FitB] /F <</Type /Filespec /F ' + CryptString( PrepareFileSpec ( FDocument ) )  + ' >>/NewWindow ' + s );
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  Eng.CloseObj;
end;

{ TPDFJavaScriptAction }

constructor TPDFJavaScriptAction.Create(Actions: TPDFActions;
  JavaScript: AnsiString);
begin
  if JavaScript = '' then
    raise EPDFException.Create ( SJavaScriptCannotBeEmpty );
  inherited Create ( Actions);
  FJavaScript := JavaScript;
end;

procedure TPDFJavaScriptAction.Save;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/S /JavaScript /JS ' +CryptString( FJavaScript ) );
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  Eng.CloseObj;
end;

{ TPDFImportDataAction }

constructor TPDFImportDataAction.Create(Actions: TPDFActions;
  FileName: string);
begin
  if FileName = '' then
    raise EPDFException.Create ( SFileNameCannotBeEmpty );
  inherited Create (Actions);
  FFileName := FileName;
end;

procedure TPDFImportDataAction.Save;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/S /ImportData' );
  Eng.SaveToStream ( '/F <</Type /FileSpec /F ' + CryptString( AnsiString(FFileName  )) + '>>' );
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  Eng.CloseObj;

end;

{ TPDFVisibleAction }

procedure TPDFVisibleAction.Add(Annotation: TPDFAnnotation);
begin
  if FList.IndexOf(Annotation) < 0 then
    FList.Add(Annotation);
end;

constructor TPDFVisibleAction.Create(Actions: TPDFActions;
  IsHide: Boolean);
begin
  inherited Create(Actions);
  FList := TList.Create;
  FIsHide := IsHide;
end;

destructor TPDFVisibleAction.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TPDFVisibleAction.Save;
var
  I: Integer;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/S /Hide /T [', False );
  for I := 0 to FList.Count - 1 do
    Eng.SaveToStream ( TPDFAnnotation(FList [ I ]).RefID + ' ', False );
  Eng.SaveToStream ( ']' );
  if FIsHide then
    Eng.SaveToStream ( '/H true' )
  else
    Eng.SaveToStream ( '/H false' );
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  Eng.CloseObj;
end;

end.
