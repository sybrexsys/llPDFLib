{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFNames;
{$i pdf.inc}
interface
uses 
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$endif} 
  llPDFTypes, llPDFEngine, llPDFCanvas;

type


  TPDFJavaScriptFunction = record
    ID: Integer;
    Body: AnsiString;
    Name: AnsiString;
    Params: AnsiString;
  end;

  TPDFNamedDestination = record
    Dest: AnsiString;
    Page: Integer;
    TopOffset: Integer;
    ID: Integer;
  end;

  TPDFEmbeddedFile = record
    Title: string;
    FileName: string;
    ID:Integer;
  end;



  /// <summary>
  ///   This class is designed to add to the document files, named destinations and Javascript functions
  /// </summary>
  TPDFNames = class( TPDFManager)
  private
    FPages: TPDFPages;
    FJavaScripts: array of TPDFJavaScriptFunction;
    FNamedDestinations:  array of TPDFNamedDestination;
    FEmbeddedFiles: array of TPDFEmbeddedFile;
    function SaveNamedDestination: Integer;
    function SaveEmbeddedFiles:Integer;
    function SaveJavaScriptFunctions: Integer;
  protected
    procedure Clear;override;
    function GetCount:Integer;override;
    procedure Save;override;
  public
    constructor Create ( PDFEngine: TPDFEngine;Pages: TPDFPages);
    destructor Destroy;override;
    /// <summary>
    ///   Procedure is to implement a file in the generated document
    /// </summary>
    /// <param name="FileName">
    ///   Name of the file that will be implemented
    /// </param>
    /// <param name="Title">
    ///   Title of the file, displayed in the reader
    /// </param>
    procedure AppendEmbeddedFile(FileName: string; Title:string);
    /// <summary>
    ///   Adds named destinations to the generated document
    /// </summary>
    /// <param name="Dest">
    ///   Destination name
    /// </param>
    /// <param name="Page">
    ///   Index of the page, which destination is need to be done to
    /// </param>
    /// <param name="TopOffset">
    ///   Page offset
    /// </param>
    procedure AppendNamedDestination ( Dest: AnsiString; Page: Integer; TopOffset: Integer );
    /// <summary>
    ///   Add named JavaScript function to the generated document
    /// </summary>
    /// <param name="AName">
    ///   Name of the function
    /// </param>
    /// <param name="AParams">
    ///   Parameters of the function
    /// </param>
    /// <param name="ABody">
    ///   Body of the function
    /// </param>
    procedure AddJavaScriptFunction ( AName, AParams, ABody: AnsiString );
  end;


implementation


uses
{$ifdef WIN64}
  System.ZLib, System.ZLibConst,
{$else}
  llPDFFlate,
{$endif}
llPDFMisc, llPDFResources, llPDFSecurity, llPDFCrypt;




{ TPDFNames }

procedure TPDFNames.AddJavaScriptFunction(AName, AParams, ABody: AnsiString);
var
  i:Integer;
begin
  i := Length ( FJavaScripts );
  SetLength ( FJavaScripts, i+1);
  FJavaScripts[i].Name := AName;
  FJavaScripts[i].Params := AParams;
  FJavaScripts[i].Body := ABody;
end;

procedure TPDFNames.AppendEmbeddedFile(FileName, Title: string);
var
  i:Integer;
begin
  i := Length ( FEmbeddedFiles );
  SetLength ( FEmbeddedFiles, i+1);
  FEmbeddedFiles[i].Title := Title;
  FEmbeddedFiles[i].FileName := FileName;
end;

procedure TPDFNames.AppendNamedDestination(Dest: AnsiString; Page,
  TopOffset: Integer);
var
  i: Integer;
begin
  if ( Page < 0 ) or ( Page >= FPages.Count ) then
    raise EPDFException.Create ( SOutOfRange );
  if TopOffset < 0 then
    raise EPDFException.Create ( STopOffsetCannotBeNegative );
  i := Length ( FNamedDestinations );
  SetLength ( FNamedDestinations, i + 1 );
  FNamedDestinations [ i ].Dest := Dest;
  FNamedDestinations [ i ].Page := Page;
  FNamedDestinations [ i ].TopOffset := TopOffset;
end;

procedure TPDFNames.Clear;
begin
  FEmbeddedFiles := nil;
  FJavaScripts := nil;
  FNamedDestinations := nil;
  inherited;
end;

constructor TPDFNames.Create(PDFEngine: TPDFEngine;Pages: TPDFPages);
begin
  inherited Create( PDFEngine );
  FPages := Pages;
end;

destructor TPDFNames.Destroy;
begin
  Clear;
  inherited;
end;

function TPDFNames.GetCount: Integer;
begin
  if ( Length (FJavaScripts) >0 ) or ( Length (FNamedDestinations) >0 )
    or ( Length (FEmbeddedFiles) > 0) then
    Result := 1
  else Result := 0;
end;

procedure TPDFNames.Save;
var
  NID, EID, JID: Integer;
begin
  if Count = 0 then
    Exit;
  NID := SaveNamedDestination;
  JID := SaveJavaScriptFunctions;
  EID := SaveEmbeddedFiles;

  FEngine.StartObj ( NID );
  if NID <> 0 then
    FEngine.SaveToStream ( '/Dests ' + GetRef ( NID )  );
  if  JID <> 0 then
    FEngine.SaveToStream ( '/JavaScript ' + GetRef ( EID ) );
  if EID <> 0  then
    FEngine.SaveToStream ( '/EmbeddedFiles ' + GetRef ( EID ) );
  FEngine.CloseObj;
end;

function TPDFNames.SaveEmbeddedFiles: Integer;
var
  i, Len:Integer;
  MS:TMemoryStream;
  CS:TCompressionStream;
  FS:TFileStream;
  TID, RS:Integer;
  S:string;
  procedure QuickSort ( var A: array of TPDFEmbeddedFile; iLo, iHi: Integer );
  var
    Lo, Hi: Integer;
    ap: TPDFEmbeddedFile;
    Mid: string;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A [ ( Lo + Hi ) div 2 ].Title;
    repeat
      while A [ Lo ].Title < Mid do
        Inc ( Lo );
      while A [ Hi ].Title > Mid do
        Dec ( Hi );
      if Lo <= Hi then
      begin
        ap := A [ Lo ];
        A [ Lo ] := A [ Hi ];
        A [ Hi ] := ap;
        Inc ( Lo );
        Dec ( Hi );
      end;
    until Lo > Hi;
    if Hi > iLo then
      QuickSort ( A, iLo, Hi );
    if Lo < iHi then
      QuickSort ( A, Lo, iHi );
  end;
begin
  Len := Length( FEmbeddedFiles );
  if  Len = 0 then
  begin
    Result:= 0;
    Exit;
  end;
  if Len > 1 then
    QuickSort ( FEmbeddedFiles, low ( FEmbeddedFiles ), High ( FEmbeddedFiles ) );
  Result := FEngine.GetNextID;
  FEngine.StartObj ( Result );
  FEngine.SaveToStream ( '/Names [', False );
  for i := 0 to Len - 1 do
  begin
    FEmbeddedFiles [ i ].ID := FEngine.GetNextID;
{$ifdef UNICODE}
    FEngine.SaveToStream ( CryptString(FEngine.SecurityInfo, UnicodeChar(FEmbeddedFiles [ 0 ].Title),Result)  +
      GetRef(FEmbeddedFiles [ i ].ID), False );
{$else}
    FEngine.SaveToStream ( CryptString(FEngine.SecurityInfo, FEmbeddedFiles [ 0 ].Title,Result)  +
      GetRef(FEmbeddedFiles [ i ].ID), False );
{$endif}
  end;
  FEngine.SaveToStream ( ']' );
  FEngine.CloseObj;
  for i := 0 to Len - 1 do
  begin
    FS := TFileStream.Create(FEmbeddedFiles[i].FileName, fmOpenRead )	;
    try
      RS := FS.Size;
      FS.Position := 0;
      MS := TMemoryStream.Create;
      try
        CS := TCompressionStream.Create ( clMax, MS );
        try
          CS.CopyFrom ( FS, FS.Size );
        finally
          CS.Free;
        end;
        TID := FEngine.GetNextID;
        FEngine.StartObj ( TID );
        FEngine.SaveToStream ( '/Filter /FlateDecode /Length ' + IStr ( CalcAESSize( FEngine.SecurityInfo.State,MS.Size ) ) );
        FEngine.SaveToStream ( '/Params <</Size '+IStr ( RS )+'>>');
        FEngine.StartStream;
        ms.Position := 0;
        CryptStreamToStream(FEngine.SecurityInfo, MS, FEngine.Stream, TID);
        FEngine.CloseStream;
      finally
        MS.Free;
      end;
    finally
      FS.Free;
    end;
    FEngine.StartObj ( FEmbeddedFiles [ i ].ID );
    FEngine.SaveToStream ( '/Type /Filespec /F ', False );
    S := ExtractFileName(FEmbeddedFiles [ i ].FileName );
{$ifdef UNICODE}
    FEngine.SaveToStream ( CryptString(FEngine.SecurityInfo, UnicodeChar(S),FEmbeddedFiles [ i ].ID), False );
{$else}
    FEngine.SaveToStream ( CryptString(FEngine.SecurityInfo, S,FEmbeddedFiles [ i ].ID), False );
{$endif}
    FEngine.SaveToStream ( '/EF <</F '+GetRef( TID )+'>>' );
    FEngine.CloseObj;
  end;
end;

function TPDFNames.SaveJavaScriptFunctions: Integer;
var
  I, K: Integer;
begin
  if Length (FJavaScripts) = 0 then
  begin
    Result := 0;
    Exit;
  end;
  for i := 0 to Length (FJavaScripts) - 1 do
    FJavaScripts [ i ].ID := FEngine.GetNextID;
  Result := FEngine.GetNextID;
  FEngine.StartObj ( Result );
  FEngine.SaveToStream ( '/Names [', False );
  for i := 0 to Length (FJavaScripts) - 1 do
    FEngine.SaveToStream (CryptString(FEngine.SecurityInfo, FJavaScripts [ 0 ].Name,Result) +' '+GetRef(FJavaScripts[I].ID));
  FEngine.SaveToStream ( ']' );
  FEngine.CloseObj;
  for i := 0 to Length (FJavaScripts) - 1 do
  begin
    K := FJavaScripts [ i ].ID;
    FEngine.StartObj ( K );
    FEngine.SaveToStream ( '/S /JavaScript /JS ' +
      CryptString(FEngine.SecurityInfo,'function ' + FJavaScripts [ i ].Name + '(' + FJavaScripts [ i ].Params + ')' +
      '{' + FJavaScripts [ i ].Body + '}',FJavaScripts[I].ID ) );
    FEngine.CloseObj;
  end;
end;

function TPDFNames.SaveNamedDestination: Integer;
var
  i, k: Integer;

  procedure QuickSort ( A: array of TPDFNamedDestination; iLo, iHi: Integer );
  var
    Lo, Hi: Integer;
    ap: TPDFNamedDestination;
    Mid: AnsiString;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A [ ( Lo + Hi ) div 2 ].Dest;
    repeat
      while A [ Lo ].Dest < Mid do
        Inc ( Lo );
      while A [ Hi ].Dest > Mid do
        Dec ( Hi );
      if Lo <= Hi then
      begin
        ap := A [ Lo ];
        A [ Lo ] := A [ Hi ];
        A [ Hi ] := ap;
        Inc ( Lo );
        Dec ( Hi );
      end;
    until Lo > Hi;
    if Hi > iLo then
      QuickSort ( A, iLo, Hi );
    if Lo < iHi then
      QuickSort ( A, Lo, iHi );
  end;

begin
  k := Length ( FNamedDestinations );
  if k = 0 then
  begin
    Result := 0;
    Exit;
  end;
  if k > 1 then
    QuickSort ( FNamedDestinations, low ( FNamedDestinations ), High ( FNamedDestinations ) );
  Result := FEngine.GetNextID;
  FEngine.StartObj ( Result );
  FEngine.SaveToStream ( '/Limits [' + CryptString(FEngine.SecurityInfo, FNamedDestinations [ 0 ].Dest,Result)+
    CryptString(FEngine.SecurityInfo, FNamedDestinations [ k - 1 ].Dest,Result) +']');
  FEngine.SaveToStream ( '/Names [', False );
  for i := 0 to k - 1 do
  begin
    FNamedDestinations [ i ].ID := FEngine.GetNextID;
    FEngine.SaveToStream ( CryptString(FEngine.SecurityInfo, FNamedDestinations [ 0 ].Dest,Result) +' '+ GetRef(FNamedDestinations [ i ].ID), False );
  end;
  FEngine.SaveToStream ( ']' );
  FEngine.CloseObj;
  for i := 0 to k - 1 do
  begin
    FEngine.StartObj ( FNamedDestinations [ i ].ID );
    FEngine.SaveToStream ( '/D [' + FPages [ FNamedDestinations [ i ].Page ].RefID +
      '/FitH ' + IStr ( Round ( FPages [ FNamedDestinations [ i ].Page ].ExtToIntY ( FNamedDestinations [ i ].TopOffset ) ) ) + ']' );
    FEngine.CloseObj;
  end;

end;

end.

