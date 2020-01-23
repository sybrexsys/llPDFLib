{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFOutline;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif}
  llPDFTypes, llPDFEngine, llPDFAction;
type


  TPDFOutlines = class;

  /// <summary>
  ///   TPDFOutlineNode object store destination associated with the outline item.
  /// </summary>
  TPDFOutlineNode = class ( TPDFObject )
  private
    FChild: TList;
    FOwner: TPDFOutlines;
    FParent: TPDFOutlineNode;
    FPrev: TPDFOutlineNode;
    FNext: TPDFOutlineNode;
    FTitle: string;
    FExpanded: Boolean;
{$ifndef UNICODE}
    FCharset: TFontCharset;
    FIsUnicode: Boolean;
    FUnicode: array of Word;
    FLength: Integer;
{$endif}
    FAction: TPDFAction;
    FColor: TColor;
    FStyle: TFontStyles;
    function GetCount: Integer;
    function GetHasChildren: Boolean;
    function GetItem ( Index: Integer ): TPDFOutlineNode;
    procedure SetExpanded ( const Value: Boolean );
  protected
    procedure Save;  override;
  public
    /// <summary>
    ///   Creates and initializes an instance of TPDFGotoRemoteAction
    /// </summary>
    constructor Create ( Engine:TPDFEngine; AOwner: TPDFOutlines );
    destructor Destroy; override;
    /// <summary>
    ///   Destroys the node and all its children. Use the Delete method to delete a node and free all
    ///   associated memory.
    /// </summary>
    procedure Delete;
    /// <summary>
    ///   Procedure delete all children of current node.
    /// </summary>
    procedure DeleteChildren;
    /// <summary>
    ///   Returns the first child node of a node. Call GetFirstChild to access the first child node of the
    ///   view node. If the node has no children, GetFirstChild returns nil.
    /// </summary>
    function GetFirstChild: TPDFOutlineNode;
    /// <summary>
    ///   Returns the last immediate child node of the calling node. Call GetLastChild to find the last
    ///   immediate child of a node. If the calling node has no children, GetLastChild returns nil.
    /// </summary>
    function GetLastChild: TPDFOutlineNode;
    /// <summary>
    ///   Returns the next node after the calling node in the tree of the outline nodes. If the calling
    ///   node is the last node, GetNext returns nil. It will return the next node including child nodes. To
    ///   get the next node at the same level as the calling node, use GetNextSibling
    /// </summary>
    function GetNext: TPDFOutlineNode;
    /// <summary>
    ///   Returns the next child node after Node. Call GetNextChild to locate the next node in the list of
    ///   immediate children of the tree of the outline nodes. If the calling node has no children or there
    ///   is no node after Node, GetNextChild returns nil.
    /// </summary>
    function GetNextChild ( Node: TPDFOutlineNode ): TPDFOutlineNode;
    /// <summary>
    ///   Returns the next node in the tree of the outline nodes at the same level as the calling node. To
    ///   find the next node in the tree including child nodes, use GetNext
    /// </summary>
    function GetNextSibling: TPDFOutlineNode;
    /// <summary>
    ///   Returns the previous node in the tree of the outline nodes before the calling node.
    /// </summary>
    function GetPrev: TPDFOutlineNode;
    /// <summary>
    ///   Returns the previous child node before Node. Call GetPrevChild to locate the previous node in the
    ///   list of immediate children of the tree node. If the calling node has no children or there is no
    ///   node before Node, GetPrevChild returns nil.
    /// </summary>
    function GetPrevChild ( Node: TPDFOutlineNode ): TPDFOutlineNode;
    /// <summary>
    ///   Returns the previous node before the calling node and at the same level.
    /// </summary>
    function GetPrevSibling: TPDFOutlineNode;
    /// <summary>
    ///   Color of the node text.
    /// </summary>
    property Color: TColor read FColor write FColor;
    /// <summary>
    ///   Style of the node text.
    /// </summary>
    property Style: TFontStyles read FStyle write FStyle;
    /// <summary>
    ///   Indicates the number of direct descendants of a node. Count includes only immediate children, and
    ///   not their descendants.
    /// </summary>
    property Count: Integer read GetCount;
    /// <summary>
    ///   Indicates whether a node has any children. HasChildren is True if the node has subnodes, or False
    ///   if the node has no subnodes.
    /// </summary>
    property HasChildren: Boolean read GetHasChildren;
    /// <summary>
    ///   Provides access to a child node by its position in the list of child nodes. Use Item to access a
    ///   child node based on its Index property. The first child node has an index of 0, the second an index
    ///   of 1, and so on.
    /// </summary>
    /// <param name="Index">
    ///   Property number of descendant TPDFOutline that you need to get access to
    /// </param>
    property Item [ Index: Integer ]: TPDFOutlineNode read GetItem;
    /// <summary>
    ///   Determine whether node is expanded when PDF document is opened.
    /// </summary>
    property Expanded: Boolean read FExpanded write SetExpanded;
  end;



  /// <summary>
  ///   TPDFOutlines maintains a list of outline nodes in a tree of the outlines. Nodes can be added,
  ///   deleted, inserted within the tree of the outlines.
  /// </summary>
  /// <remarks>
  ///   This object can not be created independently. It is created when creating TPDFDocument and is available
  ///   through TPDFDocument.Outlines property
  /// </remarks>
  TPDFOutlines = class ( TPDFManager )
  private
    FList: TList;
    function GetItem ( Index: Integer ): TPDFOutlineNode;
    function Add ( Node: TPDFOutlineNode ): TPDFOutlineNode; overload;
    function AddChild ( Node: TPDFOutlineNode ): TPDFOutlineNode; overload;
    function AddChildFirst ( Node: TPDFOutlineNode ): TPDFOutlineNode; overload;
    function AddFirst ( Node: TPDFOutlineNode ): TPDFOutlineNode; overload;
    function Insert ( Node: TPDFOutlineNode ): TPDFOutlineNode; overload;
  protected
    function GetCount: Integer;override;
    procedure Clear; override;
    procedure Save;override;
  public
    constructor Create ( PDFEngine: TPDFEngine );
    destructor Destroy; override;
    /// <summary>
    ///   Removes a node from the tree of the outline items.
    /// </summary>
    procedure Delete ( Node: TPDFOutlineNode );
    /// <summary>
    ///   Returns the first tree node in the tree of the outline items.
    /// </summary>
    function GetFirstNode: TPDFOutlineNode;
    /// <summary>
    ///   Adds a new tree node to a tree of the outline items.Function returns the node that has been added.
    /// </summary>
    /// <param name="Node">
    ///   The node is added as the last sibling of the Node parameter.
    /// </param>
    /// <param name="Title">
    ///   The line, that will be visible in Outlines tree in viewer
    /// </param>
    /// <param name="Action">
    ///   Action, that will be performed after clicking added Outline
    /// </param>
    function Add ( Node: TPDFOutlineNode; Title: string; Action: TPDFAction
      {$ifndef UNICODE}; Charset: TFontCharset = ANSI_CHARSET{$endif} ): TPDFOutlineNode;
      overload;
    /// <summary>
    ///   Adds a new tree node to a tree of the outline items.Function returns the node that has been added.
    /// </summary>
    /// <param name="Node">
    ///   The node is added as a child of the node specified by the Node parameter. It is added to the end of
    ///   Node's list of child nodes.
    /// </param>
    /// <param name="Title">
    ///   The line, that will be visible in Outlines tree in viewer
    /// </param>
    /// <param name="Action">
    ///   Action, that will be performed after clicking added Outline
    /// </param>
    function AddChild ( Node: TPDFOutlineNode; Title: string; Action: TPDFAction
      {$ifndef UNICODE}; Charset: TFontCharset = ANSI_CHARSET{$endif} ): TPDFOutlineNode;
      overload;
    /// <summary>
    ///   Adds a new tree node to a tree of the outline items.Function returns the node that has been added.
    /// </summary>
    /// <param name="Node">
    ///   The node is added as a child of the node specified by the Node parameter. It is added to the top of
    ///   Node's list of child nodes.
    /// </param>
    /// <param name="Title">
    ///   The line, that will be visible in Outlines tree in viewer
    /// </param>
    /// <param name="Action">
    ///   Action, that will be performed after clicking added Outline
    /// </param>
    function AddChildFirst ( Node: TPDFOutlineNode; Title: string; Action: TPDFAction
      {$ifndef UNICODE}; Charset: TFontCharset = ANSI_CHARSET{$endif} ): TPDFOutlineNode;
      overload;
    /// <summary>
    ///   Adds a new tree node to a tree of the outline items.Function returns the node that has been added.
    /// </summary>
    /// <param name="Node">
    ///   The node is added as the first sibling of the node specified by the Node parameter.
    /// </param>
    /// <param name="Title">
    ///   The line, that will be visible in Outlines tree in viewer
    /// </param>
    /// <param name="Action">
    ///   Action, that will be performed after clicking added Outline
    /// </param>
    function AddFirst ( Node: TPDFOutlineNode; Title: string; Action: TPDFAction
      {$ifndef UNICODE}; Charset: TFontCharset = ANSI_CHARSET{$endif} ): TPDFOutlineNode;
      overload;
    /// <summary>
    ///   Adds a new tree node to a tree of the outline items.Function returns the node that has been added.
    /// </summary>
    /// <param name="Node">
    ///   Inserts a tree node into the tree of the outline items before the node specified by the Node
    ///   parameter.
    /// </param>
    /// <param name="Title">
    ///   The line, that will be visible in Outlines tree in viewer
    /// </param>
    /// <param name="Action">
    ///   Action, that will be performed after clicking added Outline
    /// </param>
    function Insert ( Node: TPDFOutlineNode; Title: string; Action: TPDFAction
      {$ifndef UNICODE}; Charset: TFontCharset = ANSI_CHARSET{$endif} ): TPDFOutlineNode;
      overload;
    {$ifndef UNICODE}
    function Add ( Node: TPDFOutlineNode; Text: PWord; Len: Integer; Action: TPDFAction): TPDFOutlineNode; overload;
    function AddChild ( Node: TPDFOutlineNode; Text: PWord; Len: Integer; Action: TPDFAction): TPDFOutlineNode; overload;
    function AddChildFirst ( Node: TPDFOutlineNode; Text: PWord; Len: Integer; Action: TPDFAction): TPDFOutlineNode; overload;
    function AddFirst ( Node: TPDFOutlineNode; Text: PWord; Len: Integer; Action: TPDFAction): TPDFOutlineNode; overload;
    function Insert ( Node: TPDFOutlineNode; Text: PWord; Len: Integer; Action: TPDFAction): TPDFOutlineNode; overload;
    {$endif}
    /// <summary>
    ///   Indicates the number of nodes maintained by the TPDFOutlines object.
    /// </summary>
    property Count: Integer read GetCount;
    /// <summary>
    ///   This propertygives access to all Outline of PDF document.
    /// </summary>
    /// <param name="Index">
    ///   Property number PDF Outline to receive
    /// </param>
    property Item [ Index: Integer ]: TPDFOutlineNode read GetItem; default;
  end;


implementation

uses llPDFMisc, llPDFResources;


{ TPDFOutlines }

function TPDFOutlines.Add ( Node: TPDFOutlineNode ): TPDFOutlineNode;
var
  N, T, M: TPDFOutlineNode;
  I: Integer;
begin
  N := TPDFOutlineNode.Create ( FEngine, Self );
  if Node <> nil then
    T := Node.FParent
  else
    T := nil;
  N.FParent := T;
  N.FNext := nil;
  M := nil;
  for I := 0 to FList.Count - 1 do
    if ( TPDFOutlineNode ( FList [ I ] ).FParent = T ) and ( TPDFOutlineNode ( FList [ I ] ).FNext = nil ) then
    begin
      M := TPDFOutlineNode ( FList [ I ] );
      Break;
    end;
  if M <> nil then
    M.FNext := N;
  N.FPrev := M;
  FList.Add ( Pointer ( N ) );
  if T <> nil then
    T.FChild.Add ( Pointer ( N ) );
  Result := N;
end;

function TPDFOutlines.AddChild ( Node: TPDFOutlineNode ): TPDFOutlineNode;
var
  N, T, M: TPDFOutlineNode;
  I: Integer;
begin
  N := TPDFOutlineNode.Create ( FEngine, Self );
  T := Node;
  N.FParent := T;
  N.FNext := nil;
  M := nil;
  for I := 0 to FList.Count - 1 do
    if ( TPDFOutlineNode ( FList [ I ] ).FParent = T ) and ( TPDFOutlineNode ( FList [ I ] ).FNext = nil ) then
    begin
      M := TPDFOutlineNode ( FList [ I ] );
      Break;
    end;
  if M <> nil then
    M.FNext := N;
  N.FPrev := M;
  FList.Add ( Pointer ( N ) );
  if T <> nil then
    T.FChild.Add ( Pointer ( N ) );
  Result := N;
end;

function TPDFOutlines.AddChildFirst (
  Node: TPDFOutlineNode ): TPDFOutlineNode;
var
  N, T, M: TPDFOutlineNode;
  I: Integer;
begin
  N := TPDFOutlineNode.Create ( FEngine, Self );
  T := Node;
  N.FParent := T;
  N.FPrev := nil;
  M := nil;
  for I := 0 to FList.Count - 1 do
    if ( TPDFOutlineNode ( FList [ I ] ).FParent = T ) and ( TPDFOutlineNode ( FList [ I ] ).FPrev = nil ) then
    begin
      M := TPDFOutlineNode ( FList [ I ] );
      Break;
    end;
  if M <> nil then
    M.FPrev := N;
  N.FNext := M;
  FList.Add ( Pointer ( N ) );
  if T <> nil then
    T.FChild.Add ( Pointer ( N ) );
  Result := N;
end;

function TPDFOutlines.AddFirst ( Node: TPDFOutlineNode ): TPDFOutlineNode;
var
  N, T, M: TPDFOutlineNode;
  I: Integer;
begin
  N := TPDFOutlineNode.Create ( FEngine,Self );
  if Node <> nil then
    T := Node.FParent
  else
    T := nil;
  N.FParent := T;
  N.FPrev := nil;
  M := nil;
  for I := 0 to FList.Count - 1 do
    if ( TPDFOutlineNode ( FList [ I ] ).FParent = T ) and ( TPDFOutlineNode ( FList [ I ] ).FPrev = nil ) then
    begin
      M := TPDFOutlineNode ( FList [ I ] );
      Break;
    end;
  if M <> nil then
    M.FPrev := N;
  N.FNext := M;
  FList.Add ( Pointer ( N ) );
  if T <> nil then
    T.FChild.Add ( Pointer ( N ) );
  Result := N;
end;


procedure TPDFOutlines.Clear;
begin
  while FList.Count <> 0 do
    TPDFOutlineNode ( FList [ 0 ] ).Delete;
  inherited;
end;

constructor TPDFOutlines.Create ( PDFEngine: TPDFEngine );
begin
  inherited Create( PDFEngine);
  FList := TList.Create;
end;

procedure TPDFOutlines.Delete ( Node: TPDFOutlineNode );
begin
  Node.Delete;
end;

destructor TPDFOutlines.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TPDFOutlines.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPDFOutlines.GetFirstNode: TPDFOutlineNode;
begin
  if FList.Count <> 0 then
    Result := TPDFOutlineNode ( FList [ 0 ] )
  else
    Result := nil;
end;

function TPDFOutlines.GetItem ( Index: Integer ): TPDFOutlineNode;
begin
  Result := TPDFOutlineNode ( FList [ Index ] );
end;

function TPDFOutlines.Insert ( Node: TPDFOutlineNode ): TPDFOutlineNode;
var
  N, Ne: TPDFOutlineNode;
begin
  if Node = nil then
  begin
    Result := Add ( nil );
    Exit;
  end;
  N := TPDFOutlineNode.Create ( FEngine, Self );
  Ne := Node.FNext;
  N.FParent := Node.FParent;
  N.FPrev := Node;
  N.FNext := Node.FNext;
  Node.FNext := N;
  if Ne <> nil then
    Ne.FPrev := N;
  FList.Add ( Pointer ( N ) );
  if N.FParent <> nil then
    N.FParent.FChild.Add ( Pointer ( N ) );
  Result := N;
end;

function TPDFOutlines.Add ( Node: TPDFOutlineNode; Title: string; Action: TPDFAction
  {$ifndef UNICODE}; Charset: TFontCharset = ANSI_CHARSET{$endif} ): TPDFOutlineNode;
begin
  Result := Add ( Node );
  Result.FTitle := Title;
  Result.FAction := Action;
  {$ifndef UNICODE}
  Result.FCharset := Charset;
  {$endif}
end;

function TPDFOutlines.AddChild ( Node: TPDFOutlineNode; Title: string;
  Action: TPDFAction{$ifndef UNICODE}; Charset: TFontCharset{$endif} ): TPDFOutlineNode;
begin
  Result := AddChild ( Node );
  Result.FTitle := Title;
  Result.FAction := Action;
  {$ifndef UNICODE}
  Result.FCharset := Charset;
  {$endif}
end;

function TPDFOutlines.AddChildFirst ( Node: TPDFOutlineNode; Title: string;
  Action: TPDFAction{$ifndef UNICODE}; Charset: TFontCharset{$endif} ): TPDFOutlineNode;
begin
  Result := AddChildFirst ( Node );
  Result.FTitle := Title;
  Result.FAction := Action;
  {$ifndef UNICODE}
  Result.FCharset := Charset;
  {$endif}
end;

function TPDFOutlines.AddFirst ( Node: TPDFOutlineNode; Title: string;
  Action: TPDFAction{$ifndef UNICODE}; Charset: TFontCharset{$endif} ): TPDFOutlineNode;
begin
  Result := AddFirst ( Node );
  Result.FTitle := Title;
  Result.FAction := Action;
  {$ifndef UNICODE}
  Result.FCharset := Charset;
  {$endif}
end;

function TPDFOutlines.Insert ( Node: TPDFOutlineNode; Title: string;
  Action: TPDFAction{$ifndef UNICODE}; Charset: TFontCharset{$endif} ): TPDFOutlineNode;
begin
  Result := Insert ( Node );
  Result.FTitle := Title;
  Result.FAction := Action;
  {$ifndef UNICODE}
  Result.FCharset := Charset;
  {$endif}
end;

{$ifndef UNICODE}
function TPDFOutlines.Add(Node: TPDFOutlineNode; Text: PWord; Len: Integer;
  Action: TPDFAction): TPDFOutlineNode;
begin
  Result := Add ( Node );
  Result.FAction := Action;
  Result.FIsUnicode := True;
  SetLength(Result.FUnicode, Len);
  Move(Text^,Result.FUnicode[0],Len*2);
  Result.FLength := Len;
end;

function TPDFOutlines.AddChild(Node: TPDFOutlineNode; Text: PWord;
  Len: Integer; Action: TPDFAction): TPDFOutlineNode;
begin
  Result := AddChild ( Node );
  Result.FAction := Action;
  Result.FIsUnicode := True;
  SetLength(Result.FUnicode, Len);
  Move(Text^,Result.FUnicode[0],Len*2);
  Result.FLength := Len;
end;

function TPDFOutlines.AddChildFirst(Node: TPDFOutlineNode; Text: PWord;
  Len: Integer; Action: TPDFAction): TPDFOutlineNode;
begin
  Result := AddChildFirst ( Node );
  Result.FAction := Action;
  Result.FIsUnicode := True;
  SetLength(Result.FUnicode, Len);
  Move(Text^,Result.FUnicode[0],Len*2);
  Result.FLength := Len;
end;

function TPDFOutlines.AddFirst(Node: TPDFOutlineNode; Text: PWord;
  Len: Integer; Action: TPDFAction): TPDFOutlineNode;
begin
  Result := AddFirst ( Node );
  Result.FAction := Action;
  Result.FIsUnicode := True;
  SetLength(Result.FUnicode, Len);
  Move(Text^,Result.FUnicode[0],Len*2);
  Result.FLength := Len;
end;

function TPDFOutlines.Insert(Node: TPDFOutlineNode; Text: PWord;
  Len: Integer; Action: TPDFAction): TPDFOutlineNode;
begin
  Result := Insert ( Node );
  Result.FAction := Action;
  Result.FIsUnicode := True;
  SetLength(Result.FUnicode, Len);
  Move(Text^,Result.FUnicode[0],Len*2);
  Result.FLength := Len;
end;

{$endif}
procedure TPDFOutlines.Save;
var
  i: Integer;
begin
  if Count = 0 then
    Exit;
  for i := 0 to Count - 1 do
    TPDFOutlineNode(FList [ i ]).Save;
  FEngine.StartObj ( ID );
  FEngine.SaveToStream ( '/Type /Outlines' );
  FEngine.SaveToStream ( '/Count ' + IStr ( Count ) );
  for i := 0 to Count - 1 do
  begin
    if ( TPDFOutlineNode(FList [ i ]).FParent = nil ) and ( TPDFOutlineNode(FList [ i ]).FPrev = nil ) then
      FEngine.SaveToStream ( '/First ' + TPDFOutlineNode(FList [ i ]).RefID );
    if ( TPDFOutlineNode(FList [ i ]).FParent = nil ) and ( TPDFOutlineNode(FList [ i ]).FNext = nil ) then
      FEngine.SaveToStream ( '/Last ' + TPDFOutlineNode(FList [ i ]).RefID );
  end;
  FEngine.CloseObj;
end;

{ TPDFOutlineNode }

constructor TPDFOutlineNode.Create ( Engine:TPDFEngine; AOwner: TPDFOutlines );
begin
  inherited Create (Engine);
  if AOwner = nil then
    raise EPDFException.Create ( SOutlineNodeMustHaveOwner );
  FOwner := AOwner;
  FChild := TList.Create;
 {$ifndef UNICODE}
  FIsUnicode := False;
 {$endif}
end;

procedure TPDFOutlineNode.Delete;
var
  I: Integer;
  P, N: TPDFOutlineNode;
begin
  DeleteChildren;
  P := GetPrev;
  N := GetNext;
  if P <> nil then
    P.FNext := N;
  if N <> nil then
    N.FPrev := P;
  I := FOwner.FList.IndexOf ( Pointer ( Self ) );
  if I <> -1 then
    FOwner.FList.Delete ( I );
  if FParent <> nil then
  begin
    I := FParent.FChild.IndexOf ( Pointer ( Self ) );
    if I <> -1 then
      FParent.FChild.Delete ( I );
  end;
  Free;
end;

procedure TPDFOutlineNode.DeleteChildren;
begin
  while FChild.Count <> 0 do
    TPDFOutlineNode ( FChild [ 0 ] ).Delete;
end;

destructor TPDFOutlineNode.Destroy;
begin
  FChild.Free;
  inherited;
end;


function TPDFOutlineNode.GetCount: Integer;
begin
  Result := FChild.Count;
end;


function TPDFOutlineNode.GetFirstChild: TPDFOutlineNode;
var
  I: Integer;
begin
  Result := nil;
  if Count = 0 then
    Exit;
  for I := 0 to FChild.Count - 1 do
    if TPDFOutlineNode ( FChild [ I ] ).FPrev = nil then
    begin
      Result := TPDFOutlineNode ( FChild [ I ] );
      Exit;
    end;
end;

function TPDFOutlineNode.GetHasChildren: Boolean;
begin
  Result := Count <> 0;
end;

function TPDFOutlineNode.GetItem ( Index: Integer ): TPDFOutlineNode;
begin
  Result := TPDFOutlineNode ( FChild [ Index ] );
end;

function TPDFOutlineNode.GetLastChild: TPDFOutlineNode;
var
  I: Integer;
begin
  Result := nil;
  if Count = 0 then
    Exit;
  for I := 0 to FChild.Count - 1 do
    if TPDFOutlineNode ( FChild [ I ] ).FNext = nil then
    begin
      Result := TPDFOutlineNode ( FChild [ I ] );
      Exit;
    end;
end;

function TPDFOutlineNode.GetNext: TPDFOutlineNode;
var
  I: Integer;
begin
  I := FOwner.FList.IndexOf ( Self );
  if I <> FOwner.FList.Count - 1 then
    Result := FOwner [ i + 1 ]
  else
    Result := nil;
end;

function TPDFOutlineNode.GetNextChild (
  Node: TPDFOutlineNode ): TPDFOutlineNode;
var
  i: Integer;
begin
  i := FChild.IndexOf ( Pointer ( Node ) );
  if ( i = -1 ) or ( i = FChild.Count - 1 ) then
    Result := nil
  else
    Result := TPDFOutlineNode ( FChild [ i + 1 ] );
end;

function TPDFOutlineNode.GetNextSibling: TPDFOutlineNode;
begin
  Result := FNext;
end;

function TPDFOutlineNode.GetPrev: TPDFOutlineNode;
var
  I: Integer;
begin
  I := FOwner.FList.IndexOf ( Self );
  if I <> 0 then
    Result := FOwner [ i - 1 ]
  else
    Result := nil;
end;

function TPDFOutlineNode.GetPrevChild (
  Node: TPDFOutlineNode ): TPDFOutlineNode;
var
  i: Integer;
begin
  i := FChild.IndexOf ( Pointer ( Node ) );
  if ( i = -1 ) or ( i = 0 ) then
    Result := nil
  else
    Result := TPDFOutlineNode ( FChild [ i - 1 ] );
end;

function TPDFOutlineNode.GetPrevSibling: TPDFOutlineNode;
begin
  Result := FPrev;
end;

procedure TPDFOutlineNode.Save;
var
  I: Integer;
{$ifndef UNICODE}
  UTitle:AnsiString;
  C:Pointer;
{$endif}
begin
  Eng.StartObj ( ID );
  {$ifndef UNICODE}
  if not FIsUnicode then
  begin
    if FCharset = ANSI_charset then
      Eng.SaveToStream ( '/Title ' + CryptString( FTitle ) )
    else
      Eng.SaveToStream ( '/Title ' +  CryptString( UnicodeChar ( FTitle, FCharset ) )  );
  end else
  begin
    SetLength(UTitle ,(FLength + 1) shl 1);
    UTitle[1] := chr($FE);
    UTitle[2] := chr($FF);
    C := @FUnicode [ 0 ];
    Move( C, Utitle[2], FLength shl 1);
    Eng.SaveToStream ( '/Title ' + CryptString( UTitle ) );
  end;
  {$else}
    Eng.SaveToStream ( '/Title ' +  CryptString( UnicodeChar ( FTitle ) )  );
  {$endif}
  if Color <> 0 then
    Eng.SaveToStream ( '/C [' + FormatFloat ( GetRValue ( Color ) / 255 ) + ' ' +
      FormatFloat ( GetGValue ( Color ) / 255 ) + ' ' + FormatFloat ( GetBValue ( Color ) / 255 ) + ' ]' );
  I := 0;
  if fsbold in Style then
    I := I or 2;
  if fsItalic in Style then
    I := I or 1;
  if I <> 0 then
    Eng.SaveToStream ( '/F ' + IStr ( I ) );

  if FChild.Count <> 0 then
  begin
    if FExpanded then
      Eng.SaveToStream ( '/Count ' + IStr ( FChild.Count ) )
    else
      Eng.SaveToStream ( '/Count -' + IStr ( FChild.Count ) );
    Eng.SaveToStream ( '/First ' + GetFirstChild.RefID );
    Eng.SaveToStream ( '/Last ' + GetLastChild.RefID );
  end;
  if FParent = nil then
    Eng.SaveToStream ( '/Parent ' + FOwner.RefID )
  else
    Eng.SaveToStream ( '/Parent ' + FParent.RefID );
  if FNext <> nil then
    Eng.SaveToStream ( '/Next ' + FNext.RefID );
  if FPrev <> nil then
    Eng.SaveToStream ( '/Prev ' + FPrev.RefID );
  if FAction <> nil then
    Eng.SaveToStream ( '/A ' + FAction.RefID );
  Eng.CloseObj;
end;

procedure TPDFOutlineNode.SetExpanded ( const Value: Boolean );
begin
  FExpanded := Value;
end;

end.

