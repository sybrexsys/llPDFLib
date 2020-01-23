{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFEMF;
{$i pdf.inc}
interface
{$ifndef BASE}
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math, 
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math, System.Types,
{$endif} 
{$ifdef USEANSISTRINGS}
  System.AnsiStrings,
{$endif}
  llPDFTypes, llPDFCanvas, llPDFImage, llPDFMisc,
  llPDFFont, llPDFEngine;


const
  SMALLTEXT_TYPE_ANSI = $200;
      // if set use ANSI version else UNICODE
  SMALLTEXT_TYPE_WITHOUT_CLIP = $100;
      // if set use EMR_SMALLTEXTOUT else use EMR_SMALLTEXTOUTCLIP
  SMALLTEXT_TYPE_IS_GLYPHS = $10;




type

{$IFDEF V7ABOVE}
  {$IFDEF VER170}
    PDFGLY = LongBool;
  {$ELSE}
    PDFGLY = Integer;
  {$ENDIF}
{$ELSE}
  PDFGLY = LongBool;
{$ENDIF}

  TPDFPen = record
    lopnStyle: UINT;
    lopnWidth: Extended;
    lopnColor: COLORREF;
  end;

  TExtRect = record
    Left, Top, Right, Bottom: Extended;
  end;

  PEMRSMALLTEXTOUTClipA = ^EMRSMALLTEXTOUTClipA;
  EMRSMALLTEXTOUTClipA = packed record
    emr: EMR;
    ptlReference: TPoint;
    nChars: DWORD;
    fOptions: DWORD;
    iGraphicsMode: DWORD;
    exScale: Single;
    eyScale: Single;
    rclClip: TRect;
    cString: array [ 0..0 ] of char;
  end;

  TEMRSmallTextOutA = packed record
    emr: TEMR;
    ptlReference: TPointL;
    nChars: DWORD;
    fOptions: DWORD;
    iGraphicsMode: DWORD;
    exScale: Single;
    eyScale: Single;
    cString: array [ 1..1 ] of Char;
  end;

  PEMRSmallTextOutA = ^TEMRSmalltextOutA;


  TEMFPattern = record
    idx: TPDFPattern;
    IsBMP: Boolean;
    BMI: Pointer;
    BM: TBitmap;
    Hatch: Integer;
    BGColor: TColor;
    Color: TColor;
  end;
  TEMFHatchedPattern = record
    idx: TPDFPattern;
    Hatch: Integer;
    BGColor: Cardinal;
    Color: Cardinal;
  end;

  TEMWParser = class
  private
    FEngine:TPDFEngine;
    FFontManager:TPDFFonts;
    FContent: TAnsiStringList;
    FPatterns: TPDFListManager;
    FPat: array of TEMFPattern;
    FHatchedPatterns: array of TEMFHatchedPattern;
    MapMode: Integer;
    FCanvas: TPDFCanvas;
    CalX, CalY: Extended;
    FontScale: Extended;
    Meta: TMetafile;
    MetaCanvas: TMetafileCanvas;
    DC: HDC;
    CurVal: TPoint;
    PolyFIllMode: Boolean;
    BGMode: Boolean;
    TextColor: Cardinal;
    BGColor: Cardinal;
    VertMode: TVertJust;
    HorMode: THorJust;
    UpdatePos: Boolean;
    Clipping: Boolean;
    CCW: Boolean;
    CPen: TPDFPen;
    CBrush: TLogBrush;
    CFont: TLogFontA;
    CurFill: Cardinal;
    ClipRect: TExtRect;
    isCR: Boolean;
    FInText: Boolean;
    FInPath: Boolean;
    MFH: THandle;
    SBM: Integer;
    com: Integer;
    IsNullBrush: Boolean;
    CWPS: TSize;
    CurRec: Integer;
    FCha: Boolean;
    FEX: Boolean;
    NT: Boolean;
    XF: TXForm;
    TransfStack: array of TXForm;
    StackSize: Integer;
    XOff, YOff, XScale, YScale: Extended;
    WOX, VOX, WEX, VEX, WOY, VOY, WEY, VEY: Integer;
    VXNum,VYNum,VXDenom,VYDenom,WXNum,WYNum,WXDenom,WYDenom: Integer;
    HandlesCount: DWORD;
    WNG: Boolean;
    HandleTable: array of HGDIOBJ;
    ViewPortScaleUsed:Boolean;
    WindowScaleUsed:Boolean;
    FIsPattern: Boolean;
    FEMFOptions: TPDFEMFParseOptions;
    FImages:TPDFImages;
    ROP2:Integer;
{$IFDEF CANVASDBG}
    LastRecordInContents: Integer;
    TXTStr: AnsiString;
    Debug: TAnsiStringList;
    procedure SaveToLog ( Data: PEnhMetaRecord );
{$ENDIF}
    function AddBitmap(BM:TBitmap):Integer ;
    procedure PStroke;
    procedure PFillAndStroke;
    procedure CheckFill;
    procedure CheckFillAndStroke;
    procedure CheckBrushToHatched;
    function MapX ( Value: Extended ): Extended;
    function MapY ( Value: Extended ): Extended;
    function FX: Extended;
    function FY: Extended;
    function GX ( Value: Extended; Map: Boolean = True ): Extended;
    function GY ( Value: Extended; Map: Boolean = True ): Extended;

    procedure SetCurFont;

    // Work with map mode , windows and view ports
    procedure DoSetWindowExtEx ( Data: PEMRSetViewportExtEx );
    procedure DoSetWindowOrgEx ( Data: PEMRSetViewportOrgEx );
    procedure DoSetViewPortExtEx ( Data: PEMRSetViewportExtEx );
    procedure DoSetViewPortOrgEx ( Data: PEMRSetViewportOrgEx );
    procedure DoSetMapMode ( Data: PEMRSetMapMode );
    procedure DoScaleWindowEx ( Data: PEMRScaleWindowExtEx );
    procedure DoScaleViewPortEx ( Data: PEMRScaleViewportExtEx );

    procedure DoPolyBezier ( PL: PEMRPolyline ); //
    procedure DoPolygon ( PL: PEMRPolyline ); //
    procedure DoPolyLine ( PL: PEMRPolyline ); //
    procedure DoPolyBezierTo ( PL: PEMRPolyline ); //
    procedure DoPolyLineTo ( PL: PEMRPolyline ); //
    procedure DoPolyPolyLine ( PPL: PEMRPolyPolyline ); //
    procedure DoPolyPolyGon ( PPL: PEMRPolyPolyline ); //
    procedure DoSetBKMode ( PMode: PEMRSelectclippath ); //
    procedure DoSetPolyFillMode ( PMode: PEMRSelectclippath ); //
    procedure DoSetTextAlign ( PMode: PEMRSelectclippath ); //
    procedure DoSetTextColor ( PColor: PEMRSetTextColor ); //
    procedure DoSetBKColor ( PColor: PEMRSetTextColor ); //
    procedure DoMoveToEx ( PMove: PEMRLineTo ); //
    procedure DoSetPixelV ( Data: PEMRSetPixelV ); //
    procedure DoInterSectClipRect ( Data: PEMRIntersectClipRect ); //
    procedure DoSaveDC; //
    procedure DoRestoreDC ( Data: PEMRRestoreDC ); //
    procedure DoFillRGN ( Data: PEMRFillRgn );


    // World transform
    procedure DoSetWorldTransform ( PWorldTransf: PEMRSetWorldTransform ); //
    procedure DoModifyWorldTransform ( PWorldTransf: PEMRModifyWorldTransform );

    // Work with HDI objects
    procedure DoSelectObject ( Data: PEMRSelectObject ); //
    procedure DoDeleteObject ( Data: PEMRDeleteObject ); //

    procedure DoAngleArc ( Data: PEMRAngleArc ); //
    procedure DoEllipse ( Data: PEMREllipse ); //
    procedure DoRectangle ( Data: PEMREllipse ); //
    procedure DoRoundRect ( Data: PEMRRoundRect ); //
    procedure DoArc ( Data: PEMRArc ); //
    procedure DoChord ( Data: PEMRChord ); //
    procedure DoPie ( Data: PEMRPie ); //
    procedure DoLineTo ( Data: PEMRLineTo ); //
    procedure DoArcTo ( Data: PEMRArc ); //
    procedure DoPolyDraw ( Data: PEMRPolyDraw ); //
    procedure DoSetArcDirection ( Data: PEMRSetArcDirection ); //
    procedure DoSetMiterLimit ( Data: PEMRSetMiterLimit ); //

    // Path operators
    procedure DoBeginPath; //
    procedure DoEndPath; //
    procedure DoCloseFigure; //
    procedure DoFillPath; //
    procedure DoStrokeAndFillPath; //
    procedure DoStrokePath; //
    procedure DoSelectClipPath; //
    procedure DoAbortPath; //

    // Images procedures
    procedure DoSetDibitsToDevice ( Data: PEMRSetDIBitsToDevice );
    procedure DoStretchDiBits ( Data: PEMRStretchDIBits );
    procedure DoBitBlt ( Data: PEMRBitBlt );
    procedure DoStretchBlt ( Data: PEMRStretchBlt );
    procedure DoAlphaBlend ( Data: PEMRAlphaBlend );
    procedure DoMaskBlt ( Data: PEMRMaskBlt );
    procedure DoTransparentBLT ( Data: PEMRTransparentBLT );

    // Create Indirect objects
    procedure DoCreateFontInDirectW ( Data: PEMRExtCreateFontIndirect ); //
    procedure DoExtCreatePen ( Data: PEMRExtCreatePen ); //
    procedure DoCreatePen ( Data: PEMRCreatePen ); //
    procedure DoCreateBrushInDirect ( Data: PEMRCreateBrushIndirect ); //
    procedure DoCreateBrushBitmap( Data: PEMRCreateDIBPatternBrushPt );

    // Work with text
    procedure DoExtTextOut(Data: PEMRExtTextOut);
    procedure DoSmallTextOut ( Data: PEMRSMALLTEXTOUTA );

    procedure DoPolyBezier16 ( PL16: PEMRPolyline16 ); //
    procedure DoPolygon16 ( PL16: PEMRPolyline16 ); //
    procedure DoPolyLine16 ( PL16: PEMRPolyline16 ); //
    procedure DoPolyBezierTo16 ( PL16: PEMRPolyline16 ); //
    procedure DoPolyLineTo16 ( PL16: PEMRPolyline16 ); //
    procedure DoPolyPolyLine16 ( PPL16: PEMRPolyPolyline16 ); //
    procedure DoPolyPolygon16 ( PPL16: PEMRPolyPolyline16 ); //
    procedure DoPolyDraw16 ( Data: PEMRPolyDraw16 ); //

    procedure DoSetROP2 (Data: PEMRSetROP2);

    procedure DoSetTextJustification ( Data: PEMRLineTo ); //

    procedure DoExcludeClipRect ( Data: PEMRExcludeClipRect );
    procedure DoExtSelectClipRGN ( Data: PEMRExtSelectClipRgn );
    procedure DoSetStretchBltMode ( Data: PEMRSetStretchBltMode );
    procedure SetInPath ( const Value: Boolean );
    procedure SetInText ( const Value: Boolean );
    procedure SetBrushColor ( Check: Boolean = True );
    procedure SetPenColor;
    procedure SetFontColor;
    procedure SetBGColor;
    procedure SetPenStyle(OldStyle:Cardinal);
    procedure ExecuteRecord ( Data: PEnhMetaRecord );
    procedure InitExecute;
  protected
    property InText: Boolean read FInText write SetInText;
    property InPath: Boolean read FInPath write SetInPath;
  public
    constructor Create ( Engine:TPDFEngine; FontManager:TPDFFonts;ACanvas: TPDFCanvas; EMFOptions: TPDFEMFParseOptions;
      Images:TPDFImages; Patterns: TPDFListManager; Resolution: Integer; Content: TAnsiStringList );
    procedure LoadMetaFile ( MF: TMetafile );
    procedure Execute;
    function GetMax: TSize;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifndef BASE}
type
  TSmallPointArray = array [ 0..MaxInt div SizeOf ( TSmallPoint ) - 1 ] of TSmallPoint;
  PSmallPointArray = ^TSmallPointArray;
  TPointArray = array [ 0..MaxInt div SizeOf ( TPoint ) - 1 ] of TPoint;
  PPointArray = ^TPointArray;




{ TEMWParser }

function IP ( Old: Pointer; sz: Integer ): Pointer;
var
  v: PByte;
begin
  v := Old;
  Inc ( v, sz );
  Result := Pointer ( v );
end;


{$IFDEF CANVASDBG}
var
  iii: Integer = 0;
{$ENDIF}


constructor TEMWParser.Create ( Engine:TPDFEngine; FontManager:TPDFFonts;ACanvas: TPDFCanvas; EMFOptions: TPDFEMFParseOptions;
  Images:TPDFImages; Patterns: TPDFListManager; Resolution: Integer; Content: TAnsiStringList );
begin
  FEngine:=Engine;
  FFontManager:=FontManager;
  FContent := Content;
  FCanvas := ACanvas;
  FEMFOptions:= EMFOptions;
  FImages := Images;
  FPatterns:= Patterns;
{$IFDEF CANVASDBG}
  Debug := TAnsiStringList.Create;
{$ENDIF}
  Meta := TMetafile.Create;
  MetaCanvas := TMetafileCanvas.Create ( Meta, FEMFOptions.UsedDC );
  CalX := Resolution / GetDeviceCaps ( FEMFOptions.UsedDC, LOGPIXELSX );
  CalY := Resolution / GetDeviceCaps ( FEMFOptions.UsedDC, LOGPIXELSY );
end;



destructor TEMWParser.Destroy;
begin
  MetaCanvas.Free;
  Meta.Free;
{$IFDEF CANVASDBG}
  Debug.Free;
{$ENDIF}
  inherited;
end;

procedure TEMWParser.CheckFill;
begin
  CheckBrushToHatched;
  FCanvas.Fill;
end;

procedure TEMWParser.CheckFillAndStroke;
begin
  CheckBrushToHatched;
  FCanvas.FillAndStroke;
end;

procedure TEMWParser.CheckBrushToHatched;
var
  I, Len: Integer;
  Pattern: TPDFPattern;
begin
  if CBrush.lbStyle <> BS_HATCHED then
    Exit;
  Pattern := nil;
  Len :=  Length( FHatchedPatterns);
  for I:= 0 to Len -1 do
  begin
    if (FHatchedPatterns[I].Hatch = CBrush.lbHatch)
      and (FHatchedPatterns[I].BGColor = BGColor)
      and (FHatchedPatterns[i].Color = CBrush.lbColor) then
    begin
      Pattern := FHatchedPatterns[I].idx;
      Break;
    end;
  end;
  if Pattern = nil then
  begin
    SetLength(FHatchedPatterns, Len + 1);
    FHatchedPatterns[Len].idx := TPDFPattern.Create(FEngine,FFontManager);
    FHatchedPatterns[Len].Hatch := CBrush.lbHatch;
    FHatchedPatterns[Len].BGColor := BGColor;
    FHatchedPatterns[Len].Color := CBrush.lbColor;
    Pattern := FHatchedPatterns[Len].idx;
    FPatterns.Add(Pattern);
    Pattern.Width := 4;
    Pattern.Height := 4;
    Pattern.XStep := 4;
    Pattern.YStep := 4;
    with Pattern do
    begin
      NewPath;
      Rectangle(0,0,4,4);
      SetColorFill(ColorToPDFColor(BGColor));
      Fill;
      NewPath;
      SetColorStroke(ColorToPDFColor(CBrush.lbColor));
      SetLineWidth(0.3);
      case CBrush.lbHatch of
        HS_VERTICAL:
          begin
            MoveTo(2,0);
            LineTo(2,4);
          end;
        HS_HORIZONTAL:
          begin
            MoveTo(0,2);
            LineTo(4,2);
          end;
        HS_FDIAGONAL:
          begin
            MoveTo(0,0);
            LineTo(4,4);
          end;
        HS_BDIAGONAL:
          begin
            MoveTo(4,0);
            LineTo(0,4);
          end;
        HS_CROSS:
          begin
            MoveTo(2,0);
            LineTo(2,4);
            MoveTo(0,2);
            LineTo(4,2);
          end;
        else
          begin
            MoveTo(0,0);
            LineTo(4,4);
            MoveTo(4,0);
            LineTo(0,4);
          end;
      end;
      Stroke;
    end;
  end;
  if FCanvas is TPDFPage then
  begin
    TPDFPage(FCanvas).SetPattern(Pattern);
  end;
  if FCanvas is TPDFForm  then
  begin
    TPDFForm(FCanvas).SetPattern(Pattern);
  end;
end;


procedure TEMWParser.DoAbortPath;
begin
  FCanvas.NewPath;
  InPath := False;
end;

procedure TEMWParser.DoAngleArc ( Data: PEMRAngleArc );
begin
  FCanvas.MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
  FCanvas.LineTo ( GX ( Data^.ptlCenter.x + cos ( Data^.eStartAngle * Pi / 180 ) * Data^.nRadius ), GY ( Data^.ptlCenter.y -
    sin ( Data^.eStartAngle * Pi / 180 ) * Data^.nRadius ) );
  if Abs ( Data^.eSweepAngle ) >= 360 then
    FCanvas.Ellipse ( GX ( data^.ptlCenter.x - Integer ( Data^.nRadius ) ), GY ( data^.ptlCenter.y - Integer ( Data^.nRadius ) ),
      GX ( data^.ptlCenter.x + Integer ( Data^.nRadius ) ), GY ( data^.ptlCenter.y + Integer ( Data^.nRadius ) ) )
  else
    FCanvas.Arc ( GX ( data^.ptlCenter.x - Integer ( Data^.nRadius ) ), GY ( data^.ptlCenter.y - Integer ( Data^.nRadius ) ),
      GX ( data^.ptlCenter.x + Integer ( Data^.nRadius ) ), GY ( data^.ptlCenter.y + Integer ( Data^.nRadius ) ),
      data^.eStartAngle, data^.eStartAngle + data^.eSweepAngle );
  CurVal := Point ( Round ( Data^.ptlCenter.x + cos ( ( Data^.eStartAngle + Data^.eSweepAngle ) * Pi / 180 ) * Data^.nRadius ),
    Round ( Data^.ptlCenter.y - sin ( ( Data^.eStartAngle + Data^.eSweepAngle ) * Pi / 180 ) * Data^.nRadius ) );
  if not InPath then
    PStroke;
end;

procedure TEMWParser.DoArc ( Data: PEMRArc );
begin
  if ( CCW ) then
    FCanvas.Arc ( GX ( Data^.rclBox.Left ), GY ( Data^.rclBox.Top ), GX ( Data^.rclBox.Right ), GY ( Data^.rclBox.Bottom ),
      GX ( Data^.ptlStart.x ), GY ( Data^.ptlStart.y ), GX ( Data^.ptlEnd.x ), GY ( Data^.ptlEnd.y ) )
  else
    FCanvas.Arc ( GX ( Data^.rclBox.Left ), GY ( Data^.rclBox.Top ), GX ( Data^.rclBox.Right ), GY ( Data^.rclBox.Bottom ),
      GX ( Data^.ptlEnd.x ), GY ( Data^.ptlEnd.y ), GX ( Data^.ptlStart.x ), GY ( Data^.ptlStart.y ) );
  if not InPath then
    PStroke;
end;

procedure TEMWParser.DoArcTo ( Data: PEMRArc );
var
  CenterX, CenterY: Extended;
  RadiusX, RadiusY: Extended;
  StartAngle, EndAngle: Extended;
begin
  FCanvas.MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
  if not CCW then
  begin
    swp ( Data^.ptlStart.x, Data^.ptlEnd.x );
    swp ( Data^.ptlStart.y, Data^.ptlEnd.y );
  end;
  CenterX := ( Data^.rclBox.Left + Data^.rclBox.Right ) / 2;
  CenterY := ( Data^.rclBox.Top + Data^.rclBox.Bottom ) / 2;
  RadiusX := abs ( Data^.rclBox.Left - Data^.rclBox.Right ) / 2;
  RadiusY := abs ( Data^.rclBox.Top - Data^.rclBox.Bottom ) / 2;
  if RadiusX < 0 then
    RadiusX := 0;
  if RadiusY < 0 then
    RadiusY := 0;
  StartAngle := ArcTan2 ( - ( Data^.ptlStart.y - CenterY ) * RadiusX,
    ( Data^.ptlStart.x - CenterX ) * RadiusY );
  EndAngle := ArcTan2 ( - ( Data^.ptlEnd.y - CenterY ) * RadiusX,
    ( Data^.ptlEnd.x - CenterX ) * RadiusY );
  FCanvas.LineTo ( GX ( CenterX + RadiusX * cos ( StartAngle ) ), GY ( CenterY - RadiusY * sin ( StartAngle ) ) );
  FCanvas.Arc ( GX ( Data^.rclBox.Left ), GY ( Data^.rclBox.Top ), GX ( Data^.rclBox.Right ), GY ( Data^.rclBox.Bottom ),
    GX ( Data^.ptlStart.x ), GY ( Data^.ptlStart.y ), GX ( Data^.ptlEnd.x ), GY ( Data^.ptlEnd.y ) );
  CurVal := Point ( round ( CenterX + RadiusX * cos ( EndAngle ) ), Round ( CenterY - RadiusY * sin ( StartAngle ) ) );
  if not InPath then
    PStroke;
end;

procedure TEMWParser.DoBeginPath;
begin
  InPath := True;
  FCanvas.NewPath;
  FCanvas.MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
end;

procedure TEMWParser.DoBitBlt ( Data: PEMRBitBlt );
var
  it: Boolean;
  B: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
  I: Integer;
  C: Cardinal;
begin
  C := Data^.dwRop;
  if not ( ( C = SRCCOPY ) or ( C = BLACKNESS ) or ( C = DSTINVERT ) or ( C = MERGECOPY ) or ( C = MERGEPAINT ) or
    ( C = NOTSRCCOPY ) or ( C = NOTSRCERASE ) or ( C = PATCOPY ) or //( C = PATINVERT ) or
    ( C = PATPAINT ) or ( C = SRCAND ) or ( C = SRCERASE ) or ( C = SRCINVERT ) or ( C = SRCPAINT ) or ( C = WHITENESS ) ) then
    Exit; ;
  if (Data^.rclBounds.Left >=0 ) and  (Data^.rclBounds.Top >=0 ) then
  if (Data^.rclBounds.Right <0 ) or (Data^.rclBounds.Bottom <0 ) then Exit;
  if InText then
  begin
    InText := False;
    it := True;
  end
  else
    it := False;

  if not ( ( data^.cxDest = 0 ) or ( data^.cyDest = 0 ) ) then
  begin
    if ( Data^.cbBmiSrc = 0 ) or ( Data^.cbBitsSrc = 0 ) then
    begin
      SetBrushColor ( not Fcha );
      FCanvas.Rectangle ( gX ( data^.xDest ), gY ( Data^.yDest ), gX ( Data^.xDest + Data^.cxDest ), gY ( Data^.yDest + Data^.cyDest ) );
      CheckFill;
    end else
    begin
      P := IP ( Data, Data^.offBmiSrc );
      O := IP ( Data, Data^.offBitsSrc );
      B := TBitmap.Create;
      try
        if ( P^.bmiHeader.biBitCount = 1 ) then
          B.Monochrome := True;
        B.Width := Data^.cxDest;
        B.Height := Data^.cyDest;
        StretchDIBits ( B.Canvas.Handle, 0, 0, B.Width, B.Height, Data^.xSrc, Data^.ySrc,
          B.Width, B.Height, O, p^, Data^.iUsageSrc, Data^.dwRop );
        I := AddBitmap( B );
        FCanvas.ShowImage ( I, GX ( Data^.rclBounds.Left, False ), GY ( Data^.rclBounds.Top, False ),
          GX ( Data^.rclBounds.Right - Data^.rclBounds.Left + 1, False ), GY ( Data^.rclBounds.Bottom - Data^.rclBounds.Top + 1, False ), 0 );
      finally
        B.Free;
      end;
    end;
  end;
  if it then
    InText := True;
end;


procedure TEMWParser.DoTransparentBLT ( Data: PEMRTransparentBlt );
var
  it: Boolean;
  B: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
  I: Integer;
begin
  if InText then
  begin
    InText := False;
    it := True;
  end
  else
    it := False;
  if not ( ( data^.cxDest = 0 ) or ( data^.cyDest = 0 ) ) then
  begin
    if ( Data^.cbBmiSrc = 0 ) or ( Data^.cbBitsSrc = 0 ) then
    begin
      SetBrushColor ( not Fcha );
      FCanvas.Rectangle ( gX ( data^.xDest ), gY ( Data^.yDest ), gX ( Data^.xDest + Data^.cxDest ), gY ( Data^.yDest + Data^.cyDest ) );
      CheckFill;
    end else
    begin
      P := IP ( Data, Data^.offBmiSrc );
      O := IP ( Data, Data^.offBitsSrc );
      B := TBitmap.Create;
      try
        if ( P^.bmiHeader.biBitCount = 1 ) then
          B.Monochrome := True;
        B.Width := Data^.cxDest;
        B.Height := Data^.cyDest;
        StretchDIBits ( B.Canvas.Handle, 0, 0, B.Width, B.Height, Data^.xSrc, Data^.ySrc,
          B.Width, B.Height, O, p^, Data^.iUsageSrc, SRCCOPY );
        I := AddBitmap( B );
        FCanvas.ShowImage ( I, GX ( Data^.rclBounds.Left, False ), GY ( Data^.rclBounds.Top, False ),
          GX ( Data^.rclBounds.Right - Data^.rclBounds.Left + 1, False ), GY ( Data^.rclBounds.Bottom - Data^.rclBounds.Top + 1, False ), 0 );
      finally
        B.Free;
      end;
    end;
  end;
  if it then
    InText := True;
end;


procedure TEMWParser.DoChord ( Data: PEMRChord );
var
  DP: TDoublePoint;
begin
  if CCW then
    DP := FCanvas.Arc ( GX ( Data^.rclBox.Left ), GY ( Data^.rclBox.Top ), GX ( Data^.rclBox.Right ), GY ( Data^.rclBox.Bottom ),
      GX ( Data^.ptlStart.x ), GY ( Data^.ptlStart.y ), GX ( Data^.ptlEnd.x ), GY ( Data^.ptlEnd.y ) )
  else
    DP := FCanvas.Arc ( GX ( Data^.rclBox.Left ), GY ( Data^.rclBox.Top ), GX ( Data^.rclBox.Right ), GY ( Data^.rclBox.Bottom ),
      GX ( Data^.ptlEnd.x ), GY ( Data^.ptlEnd.y ), GX ( Data^.ptlStart.x ), GY ( Data^.ptlStart.y ) );
  FCanvas.LineTo ( GX ( DP.x ), GY ( DP.y ) );
  if not InPath then
    PFillAndStroke;
end;

procedure TEMWParser.DoCloseFigure;
begin
  FCanvas.ClosePath;
end;

procedure TEMWParser.DoCreateBrushInDirect ( Data: PEMRCreateBrushIndirect );
{$ifdef Win64}
var
  LB: TagLogBrush;
{$endif}
begin
  if Data^.ihBrush >= HandlesCount then
    Exit;
  if HandleTable [ Data^.ihBrush ] <> $FFFFFFFF then
    DeleteObject ( HandleTable [ Data^.ihBrush ] );
  if Data^.lb.lbStyle = BS_SOLID then
    HandleTable [ Data^.ihBrush ] := CreateSolidBrush ( Data^.lb.lbColor )
  else
{$ifdef win64}
    begin
      LB.lbStyle := Data^.lb.lbStyle;
      LB.lbColor := Data^.lb.lbColor;
      LB.lbHatch := Data^.lb.lbHatch;
      HandleTable [ Data^.ihBrush ] := CreateBrushIndirect ( LB );
    end;
{$else}
    HandleTable [ Data^.ihBrush ] := CreateBrushIndirect ( TagLogBrush(Data^.lb) );
{$endif}
end;


procedure TEMWParser.DoCreateBrushBitmap ( Data: PEMRCreateDIBPatternBrushPt );
var
  Size: DWORD;
  P, BMI2: ^BITMAPINFO;
  BM: TBitmap;
  i: Integer;
  Width, Height :Integer;
  IsMonochrome: Boolean;
  O: Pointer;
begin
  if Data^.ihBrush >= HandlesCount then
    Exit;
  if HandleTable [ Data^.ihBrush ] <> $FFFFFFFF then
    DeleteObject ( HandleTable [ Data^.ihBrush ] );
  P := IP ( Data, Data^.offBmi );
  O := IP ( Data, Data^.offBits );
  IsMonochrome := P^.bmiHeader.biBitCount = 1;
  Width := P^.bmiHeader.biWidth;
  Height := P^.bmiHeader.biHeight;

  BM :=TBitmap.Create;
  BM.Monochrome := IsMonochrome;
  BM.Width := Width;
  BM.Height := Height;
  StretchDIBits ( BM.Canvas.Handle, 0, 0, Width, Height, 0, 0,
    Width, Height, O, p^, Data^.iUsage, SRCCOPY );

  Size := Data^.cbBmi +Data^.cbBits;
  GetMem(BMI2,Size);
  Move(P^,BMI2^,Size);
  i := Length( FPat);
  SetLength(FPat, i+1);
  FPat[i].IsBMP := True;
  FPat[i].BMI := BMI2;
  FPat[i].idx := nil;
  FPat[i].BM := BM;


  HandleTable [ Data^.ihBrush ] := CreateDIBPatternBrushPt(BMI2, Data^.iUsage);
end;

procedure TEMWParser.DoCreateFontInDirectW ( Data: PEMRExtCreateFontIndirect );
var
  F: TLogFontA;
begin
  if Data^.ihFont >= HandlesCount then
    Exit;
  if HandleTable [ Data^.ihFont ] <> $FFFFFFFF then
    DeleteObject ( HandleTable [ Data^.ihFont ] );

    HandleTable [ Data^.ihFont ] := CreateFontIndirectW ( Data^.elfw.elfLogFont );
    if HandleTable [ Data^.ihFont ] = 0 then
    begin
      Move ( data^.elfw.elfLogFont, F, SizeOf ( F ) );
      WideCharToMultiByte ( CP_ACP, 0, Data^.elfw.elfLogFont.lfFaceName, LF_FACESIZE,
        F.lfFaceName, LF_FACESIZE, nil, nil );
      HandleTable [ Data^.ihFont ] := CreateFontIndirectA ( F );
    end;
  {$IFDEF CANVASDBG}
      Debug.Add ( 'Font: ' + AnsiString(Data^.elfw.elfLogFont.lfFaceName ));
  {$ENDIF}
end;

procedure TEMWParser.DoCreatePen ( Data: PEMRCreatePen );
begin
  if Data^.ihPen >= HandlesCount then
    Exit;
  if HandleTable [ Data^.ihPen ] <> $FFFFFFFF then
    DeleteObject ( HandleTable [ Data^.ihPen ] );
  HandleTable [ Data^.ihPen ] := CreatePen ( Data^.lopn.lopnStyle, Data^.lopn.lopnWidth.x, Data^.lopn.lopnColor );
end;

procedure TEMWParser.DoDeleteObject ( Data: PEMRDeleteObject );
begin
  if Data^.ihObject >= HandlesCount then
    Exit;
  DeleteObject ( HandleTable [ data^.ihObject ] );
  HandleTable [ data^.ihObject ] := $FFFFFFFF;
end;

procedure TEMWParser.DoEllipse ( Data: PEMREllipse );
begin
  FCanvas.Ellipse ( GX ( data^.rclBox.Left ), GY ( Data^.rclBox.Top ), GX ( Data^.rclBox.Right ), GY ( Data^.rclBox.Bottom ) );
  if not InPath then
    if ( CPen.lopnWidth <> 0 ) and ( CPen.lopnStyle <> ps_null ) then
      if not IsNullBrush then
        CheckFillAndStroke
      else
        FCanvas.Stroke
    else if not IsNullBrush then
      CheckFill
    else
      FCanvas.NewPath;
end;

procedure TEMWParser.DoEndPath;
begin
  InPath := False;
end;

procedure TEMWParser.DoExcludeClipRect ( Data: PEMRExcludeClipRect );
begin
  Exit;
//  if Clipping then
//  begin
//    Clipping := False;
//    FCanvas.GStateRestore;
//    FCanvas.SetLineWidth(CalX * CPen.lopnWidth);
//    SetPenColor;
//    SetBrushColor(False);
//    FCha := True;
//  end;
end;

procedure TEMWParser.DoExtCreatePen ( Data: PEMRExtCreatePen );
begin
  if Data^.ihPen >= HandlesCount then
    Exit;
  if HandleTable [ Data^.ihPen ] <> $FFFFFFFF then
    DeleteObject ( HandleTable [ Data^.ihPen ] );
  HandleTable [ Data^.ihPen ] := CreatePen ( Data^.elp.elpPenStyle and PS_STYLE_MASK, Data^.elp.elpWidth, Data^.elp.elpColor );
end;

procedure TEMWParser.DoSetROP2 ( Data: PEMRSetROP2);
begin
  SetROP2(DC, Data^.iMode);
  ROP2 := Data^.iMode;
end;

procedure TEMWParser.SetPenStyle(OldStyle:Cardinal) ;
begin
  case ( CPen.lopnStyle and $F ) of
    ps_Dash: FCanvas.SetDash ( '[4 4] 0' );
    ps_Dot: FCanvas.SetDash ( '[1 1] 0' );
    ps_DashDot: FCanvas.SetDash ( '[4 1 1 1] 0' );
    ps_DashDotDot: FCanvas.SetDash ( '[4 1 1 1 1 1] 0' );
    else
      FCanvas.NoDash;
  end;
  if CPen.lopnStyle and PS_GEOMETRIC = 0 then
  begin
    CPen.lopnWidth := 1;
  end;


  if  (CPen.lopnStyle or $FFF0) = (OldStyle or $FFF0) then
    Exit;
  if CPen.lopnStyle and PS_ENDCAP_SQUARE <> 0 then FCanvas.SetLineCap( lcProjectingSquare )
  else if CPen.lopnStyle and PS_ENDCAP_FLAT <> 0 then FCanvas.SetLineCap( lcButtEnd )
  else FCanvas.SetLineCap( lcRound );

  if CPen.lopnStyle and PS_JOIN_BEVEL <> 0 then FCanvas.SetLineJoin( ljBevel )
  else if CPen.lopnStyle and PS_JOIN_MITER <> 0 then FCanvas.SetLineJoin( ljMiter )
  else FCanvas.SetLineJoin( ljRound );

end;


procedure TEMWParser.DoExtTextOut ( Data: PEMRExtTextOut );
var
  S: AnsiString;
  o: Pointer;
  I: Integer;
  RSZ: Extended;
  PIN: PINT;
  Clr:Dword;
  X, Y: Extended;
  DX, DY: Extended;
  AN: Extended;
  L: Extended;
  RestoreClip: Boolean;
  chk: Boolean;
  ChkBG: Boolean;
  Ext: array of Single;
  Len: Integer;
  UK: PWordArray;
  GL: array of Word;
  GLD: array of Integer;
  Combined: boolean;
  IsGlyphs: Boolean;
  RSW
  {$ifdef V2Y}
  : tagGCP_RESULTSW;
  {$else}
   ,
  {$endif}
  RS: tagGCP_RESULTSA;
  CodePage: Integer;
  CHS: TFontCharset;
  YRotate:Integer;
{$IFDEF CANVASDBG}
  sd: PByteArray;
  UNIs: PWordArray;
{$ENDIF}
  function CheckIndian(P:PWordArray;Len:Integer):boolean;
  var
    i: integer;
  begin
    for I := 0 to Len - 1 do
    begin
      if (P[i] >$0900) and (P[i] <=$09FF) then
      begin
        result := true;
        Exit;
      end;
    end;
    Result := False;
  end;
  procedure SetClipAndOpaque ( IsStart: Boolean );
  begin
    if InPath then
      Exit;
    if IsStart then
    begin
      if ( Data^.emrtext.fOptions and ETO_CLIPPED <> 0 ) or ( Data^.emrtext.fOptions and ETO_OPAQUE <> 0 ) or BGMode then
      begin
        Clr := CurFill;
        chk := True;
        chkbg := True;
        if ( Data^.emrtext.fOptions and ETO_Clipped <> 0 ) and ( Data^.emrtext.nChars <> 0 ) then
        begin
          if Clipping then
          begin
            RestoreClip := True;
            FCanvas.GStateRestore;
          end;
          FCanvas.GStateSave;
          FCanvas.NewPath;
          if ( ( Data^.emrtext.fOptions and ETO_OPAQUE <> 0 ) or BGMode ) and
            ( Data^.emrtext.rcl.Right - Data^.emrtext.rcl.Left > 0 ) and
            ( Data^.emrtext.rcl.Bottom - Data^.emrtext.rcl.Top > 0 ) then
            chk := False;
          if not chk then
            SetBGColor;
          FCanvas.Rectangle ( GX ( Data^.emrtext.rcl.Left ), GY ( Data^.emrtext.rcl.Top ),
            GX ( Data^.emrtext.rcl.Right ), GY ( Data^.emrtext.rcl.Bottom ) );
          FCanvas.Clip;
          if not chk then
            FCanvas.Fill
          else
            FCanvas.NewPath;
          chkbg := False;
        end;
        if chk and ( ( Data^.emrtext.fOptions and ETO_OPAQUE <> 0 ) or BGMode ) and
          ( Data^.emrtext.rcl.Right - Data^.emrtext.rcl.Left > 0 ) and
          ( Data^.emrtext.rcl.Bottom - Data^.emrtext.rcl.Top > 0 ) then
        begin
          SetBGColor;
          FCanvas.NewPath;
          FCanvas.Rectangle ( GX ( Data^.emrtext.rcl.Left ), GY ( Data^.emrtext.rcl.Top ),
            GX ( Data^.emrtext.rcl.Right ), GY ( Data^.emrtext.rcl.Bottom ) );
          FCanvas.Fill;
          chkbg := False;
        end;
      end;
    end else
    begin
      if ( Data^.emrtext.fOptions and ETO_Clipped <> 0 ) then
      begin
        FCanvas.GStateRestore;
        FCha := True;
        CurFill := Clr;
        if RestoreClip then
          if isCR then
          begin
            FCanvas.GStateSave;
            FCanvas.Rectangle ( ClipRect.Left, ClipRect.Top, ClipRect.Right, ClipRect.Bottom );
            FCanvas.Clip;
            FCanvas.NewPath;
          end else
            Clipping := False;
      end;
    end;
  end;

procedure CalcPosition;
  var
    TM:TEXTMETRIC;
  begin
    if UpdatePos then
    begin
      X := CurVal.X;
      Y := CurVal.Y;
      if HorMode = hjLeft then
      begin
        if CFont.lfEscapement <> 0 then
        begin
          CurVal.X := CurVal.X + round ( RSZ * cos ( CFont.lfEscapement * Pi / 1800 ) );
          CurVal.Y := CurVal.Y - round ( RSZ * sin ( CFont.lfEscapement * Pi / 1800 ) );
        end else
          CurVal.X := CurVal.X + round ( RSZ );
      end;
      if HorMode = hjRight then
      begin
        if CFont.lfEscapement <> 0 then
        begin
          CurVal.X := CurVal.X - round ( RSZ * cos ( CFont.lfEscapement * Pi / 1800 ) );
          CurVal.Y := CurVal.Y + round ( RSZ * sin ( CFont.lfEscapement * Pi / 1800 ) );
        end else
          CurVal.X := CurVal.X - round ( RSZ );
      end;
    end else
    begin
      X := Data^.emrtext.ptlReference.X;
      Y := Data^.emrtext.ptlReference.Y;
    end;
    if CFont.lfEscapement = 0 then
    begin
      case VertMode of
        vjCenter:
          begin
            Y := Y;
            FCanvas.TextFromBaseLine ( True );
          end;
        vjDown: Y := Y - MetaCanvas.TextHeight ( 'Wg' );
      else
        Y := Y;
      end;
      case HorMode of
        hjRight: x := X - RSZ;
        hjCenter: x := X - RSZ / 2;
      else
        X := X;
      end;
    end else
    begin
      if ( VertMode = vjUp ) and ( HorMode = hjLeft ) then
      begin
        Y := Y;
        X := X;
      end else
      begin
        if VertMode = vjUp then
        begin
          DY := 0;
        end else
        begin
          GetTextMetrics ( MetaCanvas.Handle, TM );
          if VertMode = vjCenter then
          begin
            DY := TM.tmAscent;
          end else
          begin
            DY := TM.tmHeight;
          end;
        end;
        case HorMode of
          hjRight: DX := RSZ;
          hjCenter: DX := RSZ / 2;
        else
          DX := 0;
        end;
        AN := CFont.lfEscapement * Pi / 1800*YRotate;
        if DY = 0 then
        begin
          X := X - DX * cos ( AN );
          Y := Y + DX * sin ( AN );
        end else
        begin
          L := sqrt ( sqr ( DX ) + sqr ( DY ) );
          X := X - L * cos ( AN - ArcSin ( DY / L ) );
          Y := Y + L * sin ( AN - ArcSin ( DY / L ) );
        end;
      end;
    end;
    if (not IsGlyphs) and (not InPath) and BGMode and ChkBG then
    begin
      SetBGColor;
      FCanvas.NewPath;
      if CFont.lfEscapement = 0 then
      begin
      FCanvas.Rectangle ( GX ( X ), GY ( Y ),
        GX ( X+RSZ ), GY ( Y + MetaCanvas.TextHeight ( 'Wg' ) ) );
      end else
      begin

      end;
      FCanvas.Fill;
    end;
    Y := GY ( Y, true );
    X := GX ( X, true );
  end;

{$IFDEF CANVASDBG}

  procedure DoReadableText;
  var
    i: Integer;
    Uni: AnsiString;
  begin
    if not IsGlyphs then
    begin
      case CFont.lfCharSet of
        EASTEUROPE_CHARSET: CodePage := 1250;
        RUSSIAN_CHARSET: CodePage := 1251;
        GREEK_CHARSET: CodePage := 1253;
        TURKISH_CHARSET: CodePage := 1254;
        BALTIC_CHARSET: CodePage := 1257;
        VIETNAMESE_CHARSET: CodePage := 1258;
        SHIFTJIS_CHARSET: CodePage := 932;
        129: CodePage := 949;
        CHINESEBIG5_CHARSET: CodePage := 950;
        GB2312_CHARSET: CodePage := 936;
        Symbol_charset: CodePage := -1;
      else
        CodePage := 1252;
      end;
      if ( CodePage <> -1 ) and ( not WNG ) then
      begin
        o := IP ( Data, Data^.emrtext.offString );
        S := '';
        I := WideCharToMultiByte ( CodePage, 0, o, Data^.emrtext.nChars, nil, 0, nil, nil );
        if I <> 0 then
        begin
          SetLength ( S, I );
          WideCharToMultiByte ( CodePage, 0, o, Data^.emrtext.nChars, @s [ 1 ], I, nil, nil )
        end;
      end else
      begin
        SetLength ( S, Data^.emrtext.nChars );
        SD := IP ( Data, Data^.emrtext.offString );
        for i := 1 to Data^.emrtext.nChars do
          s [ i ] := ANSIChar ( sd [ ( ( i - 1 ) shl 1 ) ] );
      end;
      Unis := IP ( Data, Data^.emrtext.offString );
      Uni := '';
      for i:= 0 to Data^.emrtext.nChars - 1 do
        Uni := Uni+'#'+AnsiString(IntToHex(UNIs[i],4));
      TXTStr := TXTStr + #13#10 + 'Text: ' + S + #13#10 + 'Unicode: ' +Uni;

    end;

  end;

{$ENDIF}

  procedure CheckCombine;
  var
    I: Integer;
  begin
    Combined := False;
    if IsGlyphs then
      Exit;
    for i := 0 to Data^.emrtext.nChars - 1 do
      if (( UK [ i ] >= $0300 ) and ( UK [ i ] <= $036F )) //or
//        (( UK [ i ] >= $0900 ) and ( UK [ i ] <= $0FFF ))
      then
      begin
        Combined := true;
        break;
      end;
    if not Combined then
      Exit;
    if NT then
    begin
      FillChar ( RSW, SizeOf ( RSW ), 0 );
      RSW.lStructSize := SizeOf ( RSW );
      RSW.nGlyphs := Len;
      RSW.nMaxFit := Len;
      SetLength ( GL, Len );
      SetLength ( GLD, Len );
      RSW.lpGlyphs := @GL [ 0 ];
      RSW.lpDx := @GLD [ 0 ];
      if GetCharacterPlacementW ( DC, @UK [ 0 ], PDFGLY ( Len ), PDFGLY ( 0 ),
        RSW,  GCP_DIACRITIC or GCP_GLYPHSHAPE or GCP_REORDER ) <> 0 then
      begin
        if Len <> Integer ( RSW.nGlyphs ) then
        begin
          Len := RSW.nGlyphs;
          UK := PWORDArray ( RSW.lpGlyphs );
          PIN := RSW.lpDx;
          IsGlyphs := True;
        end;
      end;
    end else
    begin
      if CFont.lfCharSet = DEFAULT_CHARSET then
        CHS := GetDefFontCharSet
      else
        CHS := CFont.lfCharSet;
      case CHS of
        EASTEUROPE_CHARSET: CodePage := 1250;
        RUSSIAN_CHARSET: CodePage := 1251;
        GREEK_CHARSET: CodePage := 1253;
        TURKISH_CHARSET: CodePage := 1254;
        BALTIC_CHARSET: CodePage := 1257;
        VIETNAMESE_CHARSET: CodePage := 1258;
        SHIFTJIS_CHARSET: CodePage := 932;
        129: CodePage := 949;
        CHINESEBIG5_CHARSET: CodePage := 950;
        GB2312_CHARSET: CodePage := 936;
      else
        CodePage := 1252;
      end;
      I := WideCharToMultiByte ( CodePage, 0, @UK [ 0 ], Len, nil, 0, nil, nil );
      if I = 0 then
        Exit;
      SetLength ( S, I );
      I := WideCharToMultiByte ( CodePage, 0, @UK [ 0 ], Len, @s [ 1 ], I, nil, nil );
      if I = 0 then
        Exit;
      FillChar ( RSW, SizeOf ( RS ), 0 );
      RS.lStructSize := SizeOf ( RSW );
      RS.nGlyphs := I;
      RS.nMaxFit := I;
      SetLength ( GL, I );
      RS.lpGlyphs := @GL [ 0 ];
      RS.lpDx := @GLD [ 0 ];
      if GetCharacterPlacementA ( DC, PANSIChar ( S ), PDFGLY ( I ), PDFGLY ( 0 ),
        RS, GCP_DIACRITIC or GCP_GLYPHSHAPE or GCP_REORDER ) <> 0 then
      begin
        if I <> Integer ( RSW.nGlyphs ) then
        begin
          Len := RS.nGlyphs;
          PIN := RS.lpDx;
          UK := PWORDArray ( RS.lpGlyphs );
          IsGlyphs := True;
        end;
      end;
    end;

  end;
begin
  RestoreClip := False;
  Chkbg := False;
  FCanvas.TextFromBaseLine ( False );
  IsGlyphs := ( Data^.emrtext.fOptions and ETO_GLYPH_INDEX  )<> 0;
{$IFDEF CANVASDBG}
  TXTStr := #13#10 + AnsiString(Format ( 'Angle = %d Bounds = (%d %d %d %d) Opaque = %d Clipped= %d',
    [ CFont.lfEscapement div 10, Data^.rclBounds.Left, Data^.rclBounds.Top, Data^.rclBounds.Right, Data^.rclBounds.Bottom, Data^.emrtext.fOptions and ETO_CLIPPED, Data^.emrtext.fOptions and ETO_OPAQUE ] ));
  TXTStr := TXTStr + #13#10 + AnsiString(Format ( 'XScale = %f YScale = %f Reference = (%d %d)', [ Data^.exScale, Data^.eyScale, Data^.emrText.ptlReference.x, Data^.emrText.ptlReference.y ] ));
  TXTStr := TXTStr + #13#10 + AnsiString(Format ( 'RTL = (%d %d %d %d)', [ Data^.emrText.rcl.Left, Data^.emrText.rcl.Top, Data^.emrText.rcl.Right, Data^.emrText.rcl.bottom ] ));
  if IsGlyphs then
    TXTStr := TXTStr + #13#10 + 'Used glyph indexes';
{$ENDIF}
   if (VOY >0) and (VEY < 0 ) then
     YRotate := -1 else YRotate := 1;

  SetClipAndOpaque ( True );
  Len := Data^.emrtext.nChars;
  UK := IP ( Data, Data^.emrtext.offString );
  if Len <> 0 then
  begin

    if Data^.emrtext.offDx <> 0 then
      PIN := IP ( Data, Data^.emrtext.offDx )
    else
      PIN := nil;
    if Data^.emr.iType = EMR_EXTTEXTOUTW then
    begin
      CheckCombine;
      if CheckIndian(UK,Len) then
        Pin := nil;
    end else
    begin
      SetLength ( S, Data^.emrtext.nChars );
      o := IP ( Data, Data^.emrtext.offString );
      Move ( o^, S [ 1 ], Data^.emrtext.nChars );
    end;

    SetLength ( Ext, Len );
    if PIN <> nil then
    begin
      RSZ := 0;
      for i := 0 to Len - 1 do
      begin
        if ( pin^ = 0 ) and IsGlyphs then
        begin
          Inc ( PIN );
        end;
        RSZ := RSZ + pin^;
        Ext [ i ] := pin^ * FX * CalX * abs ( YScale );
        Inc ( PIN );
      end;
      RSZ := RSZ * FX;
    end else
      RSZ := Data^.emrtext.rcl.Right - Data^.emrtext.rcl.Left;

    CalcPosition;
    if Len <> 0 then
    begin
      SetFontColor;
      SetCurFont;
    end;
{$IFDEF CANVASDBG}
    TXTStr := TXTStr + #13#10 + AnsiString(Format ( 'X = %f Y = %f ', [ X, Y ] ));
{$ENDIF}

    if Data^.emr.iType = EMR_EXTTEXTOUTW then
    begin

{$IFDEF CANVASDBG}
      DoReadableText;
{$ENDIF}
      if not IsGlyphs then
      begin
        if PIN <> nil then
          FCanvas.ExtWideTextOut ( X, Y, CFont.lfEscapement / 10 * YRotate,
            makeWideString(@UK [ 0 ], Len), @Ext [ 0 ] )
        else
          FCanvas.WideTextOut ( X, Y, CFont.lfEscapement / 10 * YRotate,
            MakeWideString(@UK [ 0 ], Len ));
      end else
      begin
        if (PIN <> nil) {and (not ZeroGlyph) }then
        begin
          FCanvas.ExtGlyphTextOut ( X, Y, CFont.lfEscapement / 10 * YRotate,
            @UK [ 0 ], Len, @Ext [ 0 ] );
        end else
        begin
          FCanvas.ExtGlyphTextOut ( X, Y, CFont.lfEscapement / 10 * YRotate,
            @UK [ 0 ], Len, nil );
        end;
      end;
    end else
    begin
{$IFDEF CANVASDBG}
      TXTStr := TXTStr + #13#10 + 'Text: ' + s;
{$ENDIF}
      if PIN <> nil then
        FCanvas.ExtTextOut ( X, Y, CFont.lfEscapement / 10 * YRotate, S, @Ext [ 0 ] )
{$IFNDEF CB}
      else
        FCanvas.TextOut ( X, Y, CFont.lfEscapement / 10 * YRotate, S );
{$ELSE}
      else
        FCanvas.TextOut ( X, Y, CFont.lfEscapement / 10 * YRotate, S );
{$ENDIF}
    end;
    Ext := nil;
  end;
  SetClipAndOpaque ( False );
end;

procedure TEMWParser.DoFillPath;
begin
  InPath := False;
  if not IsNullBrush then
    CheckFill;
  FCanvas.NewPath;
end;

procedure TEMWParser.DoInterSectClipRect ( Data: PEMRIntersectClipRect );
begin
  if Clipping then
  begin
    FCanvas.GStateRestore;
    FCha := True;
    SetPenColor;
    SetBrushColor ( False );
    FCanvas.SetLineWidth ( CalX * CPen.lopnWidth );
  end;
  FCanvas.GStateSave;
  Clipping := True;
  FCanvas.NewPath;
  FCanvas.Rectangle ( GX ( Data^.rclClip.Left ), GY ( Data^.rclClip.Top ), GX ( Data^.rclClip.Right ), GY ( Data^.rclClip.Bottom ) );
  isCR := True;
  ClipRect.Left := GX ( Data^.rclClip.Left );
  ClipRect.Top := GY ( Data^.rclClip.Top );
  ClipRect.Right := GX ( Data^.rclClip.Right );
  ClipRect.Bottom := GY ( Data^.rclClip.Bottom );
  FCanvas.Clip;
  FCanvas.NewPath;
end;

procedure TEMWParser.DoLineTo ( Data: PEMRLineTo );
begin
  if not InPath then
    FCanvas.MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
  FCanvas.LineTo ( GX ( Data^.ptl.x ), GY ( Data^.ptl.y ) );
  CurVal := Data^.ptl;
  if not InPath then
    PStroke;
end;

procedure TEMWParser.DoMoveToEx ( PMove: PEMRLineTo );
begin
  CurVal.x := pmove^.ptl.x;
  CurVal.y := pmove^.ptl.y;
  if InPath then
  begin
    if InText then
      InText := False;
    FCanvas.MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
  end;
end;

procedure TEMWParser.DoPie ( Data: PEMRPie );
begin
  FCanvas.Pie ( GX ( Data^.rclBox.Left ), gY ( Data^.rclBox.Top ), GX ( Data^.rclBox.Right ), GY ( Data^.rclBox.Bottom ),
    GX ( Data^.ptlStart.x ), GY ( Data^.ptlStart.y ), GX ( Data^.ptlEnd.x ), GY ( Data^.ptlEnd.y ) );
  if not InPath then
    PFillAndStroke;
end;

procedure TEMWParser.DoPolyBezier ( PL: PEMRPolyline );
var
  i: Integer;
begin
  with FCanvas do
  begin
    if PL^.cptl >= 4 then
    begin
      MoveTo ( GX ( PL^.aptl [ 0 ].x ), GY ( PL^.aptl [ 0 ].y ) );
      for i := 1 to ( PL^.cptl - 1 ) div 3 do
        Curveto ( GX ( PL^.aptl [ 1 + ( i - 1 ) * 3 ].x ), GY ( PL^.aptl [ 1 + ( i - 1 ) * 3 ].y ),
          GX ( PL^.aptl [ 1 + ( i - 1 ) * 3 + 1 ].x ), GY ( PL^.aptl [ 1 + ( i - 1 ) * 3 + 1 ].y ),
          GX ( PL^.aptl [ 1 + ( i - 1 ) * 3 + 2 ].x ), GY ( PL^.aptl [ 1 + ( i - 1 ) * 3 + 2 ].y ) );
      if not InPath then
        PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyBezier16 ( PL16: PEMRPolyline16 );
var
  i: Integer;
begin
  with FCanvas do
  begin
    if PL16^.cpts >= 4 then
    begin
      MoveTo ( GX ( PL16^.apts [ 0 ].x ), GY ( PL16^.apts [ 0 ].y ) );
      for i := 1 to ( PL16^.cpts - 1 ) div 3 do
        Curveto ( GX ( PL16^.apts [ 1 + ( i - 1 ) * 3 ].x ), GY ( PL16^.apts [ 1 + ( i - 1 ) * 3 ].y ),
          GX ( PL16^.apts [ 1 + ( i - 1 ) * 3 + 1 ].x ), GY ( PL16^.apts [ 1 + ( i - 1 ) * 3 + 1 ].y ),
          GX ( PL16^.apts [ 1 + ( i - 1 ) * 3 + 2 ].x ), GY ( PL16^.apts [ 1 + ( i - 1 ) * 3 + 2 ].y ) );
      if not InPath then
        PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyBezierTo ( PL: PEMRPolyline );
var
  i: Integer;

begin
  with FCanvas do
  begin
    if PL^.cptl >= 3 then
    begin
      if not InPath then
        MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
      for i := 1 to ( PL^.cptl ) div 3 do
      begin
        Curveto ( GX ( PL^.aptl [ ( i - 1 ) * 3 ].x ), GY ( PL^.aptl [ ( i - 1 ) * 3 ].y ),
          GX ( PL^.aptl [ ( i - 1 ) * 3 + 1 ].x ), GY ( PL^.aptl [ ( i - 1 ) * 3 + 1 ].y ),
          GX ( PL^.aptl [ ( i - 1 ) * 3 + 2 ].x ), GY ( PL^.aptl [ ( i - 1 ) * 3 + 2 ].y ) );
        CurVal := Point ( PL^.aptl [ ( i - 1 ) * 3 + 2 ].x, PL^.aptl [ ( i - 1 ) * 3 + 2 ].y );
      end;
      if not InPath then
        PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyBezierTo16 ( PL16: PEMRPolyline16 );
var
  i: Integer;
begin
  with FCanvas do
  begin
    if PL16^.cpts >= 3 then
    begin
      if not InPath then
        MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
      for i := 1 to PL16^.cpts div 3 do
      begin
        Curveto ( GX ( PL16^.apts [ ( i - 1 ) * 3 ].x ), GY ( PL16^.apts [ ( i - 1 ) * 3 ].y ),
          GX ( PL16^.apts [ ( i - 1 ) * 3 + 1 ].x ), GY ( PL16^.apts [ ( i - 1 ) * 3 + 1 ].y ),
          GX ( PL16^.apts [ ( i - 1 ) * 3 + 2 ].x ), GY ( PL16^.apts [ ( i - 1 ) * 3 + 2 ].y ) );
        CurVal := Point ( PL16^.apts [ ( i - 1 ) * 3 + 2 ].x, PL16^.apts [ ( i - 1 ) * 3 + 2 ].y );
      end;
      if not InPath then
        PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyDraw ( Data: PEMRPolyDraw );
var
  K: Cardinal;
  Types: PByteArray;
  TV: TPoint;
begin
  with FCanvas do
  begin
    if not InPath then
      NewPath;
    MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
    TV := CurVal;
    Types := @ ( Data^.aptl [ Data^.cptl ] );
    K := 0;
    while K < Data^.cptl do
    begin
      if Types [ K ] = PT_MOVETO then
      begin
        TV.x := Data^.aPTL [ K ].x;
        TV.y := Data^.aPTL [ K ].y;
        MoveTo ( GX ( TV.x ), GY ( TV.y ) );
        Inc ( K );
        CurVal := TV;
      end else if ( Types [ K ] and PT_LINETO ) <> 0 then
      begin
        LineTo ( GX ( Data^.aPTL [ K ].x ), GY ( Data^.aPTL [ K ].y ) );
        CurVal := Point ( Data^.aPTL [ K ].x, Data^.aPTL [ K ].y );
        if ( Types [ K ] and PT_ClOSEFIGURE ) <> 0 then
        begin
          LineTo ( GX ( TV.x ), GY ( TV.y ) );
          CurVal := TV;
        end;
        Inc ( K );
      end else if ( Types [ K ] and PT_BEZIERTO ) <> 0 then
      begin
        Curveto ( GX ( Data^.aPTL [ K ].x ), GY ( Data^.aPTL [ K ].y ),
          GX ( Data^.aPTL [ K + 1 ].x ), GY ( Data^.aPTL [ K + 1 ].y ),
          GX ( Data^.aPTL [ K + 2 ].x ), GY ( Data^.aPTL [ K + 2 ].y ) );
        CurVal := Point ( Data^.aPTL [ K + 2 ].x, Data^.aPTL [ K + 2 ].y );
        if ( Types [ K ] and PT_ClOSEFIGURE ) <> 0 then
        begin
          LineTo ( GX ( TV.x ), GY ( TV.y ) );
          CurVal := TV;
        end;
        Inc ( K, 3 );
      end
    end;
    if not InPath then
      PStroke;
  end;
end;

procedure TEMWParser.DoPolyDraw16 ( Data: PEMRPolyDraw16 );
var
  K: Cardinal;
  Types: PByteArray;
  TV: TPoint;
begin
  with FCanvas do
  begin
    if not InPath then
      NewPath;
    MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
    TV := CurVal;
    Types := @ ( Data^.apts [ Data^.cpts ] );
    K := 0;
    while K < Data^.cpts do
    begin
      if Types [ K ] = PT_MOVETO then
      begin
        TV.x := Data^.aPTs [ K ].x;
        TV.y := Data^.aPTs [ K ].y;
        MoveTo ( GX ( TV.X ), GY ( TV.Y ) );
        Inc ( K );
        CurVal := TV;
      end else if ( Types [ K ] and PT_LINETO ) <> 0 then
      begin
        LineTo ( GX ( Data^.aPTs [ K ].x ), GY ( Data^.aPTs [ K ].y  ) );
        CurVal := Point ( Data^.aPTS [ K ].x, Data^.aPTs [ K ].y );
        if ( Types [ K ] and PT_ClOSEFIGURE ) <> 0 then
        begin
          LineTo ( GX ( TV.x ), GY ( TV.y ) );
          CurVal := TV;
        end;
        Inc ( K );
      end else if ( Types [ K ] and PT_BEZIERTO ) <> 0 then
      begin
        Curveto ( GX ( Data^.aPTs [ K ].x ), GY ( Data^.aPTs [ K ].y ),
          GX ( Data^.aPTs [ K + 1 ].x ), GY ( Data^.aPTs [ K + 1 ].y ),
          GX ( Data^.aPTs [ K + 2 ].x ), GY ( Data^.aPTs [ K + 2 ].y ) );
        CurVal := Point ( Data^.aPTs [ K + 2 ].x, Data^.aPTs [ K + 2 ].y );
        if ( Types [ K ] and PT_ClOSEFIGURE ) <> 0 then
        begin
          LineTo ( GX ( TV.x ), GY ( TV.y ) );
          CurVal := TV;
        end;
        Inc ( K, 3 );
      end ;
    end;
    if not InPath then
      PStroke;
    SetLineCap(lcRound);
  end;
end;

procedure TEMWParser.DoPolygon ( PL: PEMRPolyline );
var
  i: Integer;
begin
  with FCanvas do
  begin
    if PL^.cptl > 0 then
    begin
      NewPath;
      MoveTo ( GX ( pl^.aptl [ 0 ].x ), GY ( PL^.aptl [ 0 ].y ) );
      for I := 1 to pl^.cptl - 1 do
        LineTo ( GX ( pl^.aptl [ i ].x ), GY ( pl^.aptl [ i ].y ) );
      if not InPath then
      begin
        ClosePath;
        PFillAndStroke;
      end;
    end;
  end;
end;

procedure TEMWParser.DoPolygon16 ( PL16: PEMRPolyline16 );
var
  i: Integer;
begin
  with FCanvas do
  begin
    if PL16^.cpts > 0 then
    begin
      NewPath;
      MoveTo ( GX ( pl16^.apts [ 0 ].x ), GY ( PL16^.apts [ 0 ].y ) );
      for I := 1 to pl16^.cpts - 1 do
        LineTo ( GX ( pl16^.apts [ i ].x ), GY ( pl16^.apts [ i ].y ) );
      if not InPath then
      begin
        ClosePath;
        PFillAndStroke;
      end;
    end;
  end;
end;

procedure TEMWParser.DoPolyLine ( PL: PEMRPolyline );
var
  i: Integer;
begin
  if CPen.lopnStyle = PS_NULL then
    Exit;
  with FCanvas do
  begin
    if PL^.cptl > 0 then
    begin
      NewPath;
      MoveTo ( GX ( pl^.aptl [ 0 ].x ), GY ( PL^.aptl [ 0 ].y ) );
      for I := 1 to pl^.cptl - 1 do
        LineTo ( GX ( pl^.aptl [ i ].x ), GY ( pl^.aptl [ i ].y ) );
      if not InPath then
        PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyLine16 ( PL16: PEMRPolyline16 );
var
  i: Integer;
begin
  with FCanvas do
  begin
    if PL16^.cpts > 0 then
    begin
      NewPath;
      MoveTo ( GX ( pl16^.apts [ 0 ].x ), GY ( PL16^.apts [ 0 ].y ) );
      for I := 1 to pl16^.cpts - 1 do
        LineTo ( GX ( pl16^.apts [ i ].x ), GY ( pl16^.apts [ i ].y ) );
      if not InPath then
        PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyLineTo ( PL: PEMRPolyline );
var
  i: Integer;
begin
  with FCanvas do
  begin
    if PL^.cptl > 0 then
    begin
      if not InPath then
      begin
        NewPath;
        MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
      end;
      for I := 0 to pl^.cptl - 1 do
        LineTo ( GX ( pl^.aptl [ i ].x ), GY ( pl^.aptl [ i ].y ) );
      if not InPath then
        PStroke;
      CurVal := Point ( pl^.aptl [ pl^.cptl - 1 ].x, pl^.aptl [ pl^.cptl - 1 ].y );
    end;
  end;
end;

procedure TEMWParser.DoPolyLineTo16 ( PL16: PEMRPolyline16 );
var
  i: Integer;
begin
  with FCanvas do
  begin
    if PL16^.cpts > 0 then
    begin
      if not InPath then
      begin
        NewPath;
        MoveTo ( GX ( CurVal.x ), GY ( CurVal.y ) );
      end;
      for I := 0 to pl16^.cpts - 1 do
        LineTo ( GX ( pl16^.apts [ i ].x ), GY ( pl16^.apts [ i ].y ) );
      if not InPath then
        PStroke;
      CurVal := Point ( pl16^.apts [ pl16^.cpts - 1 ].x, pl16^.apts [ pl16^.cpts - 1 ].y );
    end;
  end;
end;

procedure TEMWParser.DoPolyPolyGon ( PPL: PEMRPolyPolyline );
var
  I, J, K, L: Integer;
  PPPAL: PPointArray;
begin
  with FCanvas do
  begin
    K := SizeOf ( TEMRPolyPolyline ) - SizeOf ( TPoint ) + SizeOf ( dword ) * ( ppl^.nPolys - 1 );
    PPPAL := IP ( PPL, K );
    K := 0;
    for j := 0 to ppl^.nPolys - 1 do
    begin
      NewPath;
      MoveTo ( GX ( PPPAL [ K ].x ), GY ( PPPAL [ K ].y ) );
      L := K;
      Inc ( K );
      for I := 1 to ppl^.aPolyCounts [ J ] - 1 do
      begin
        LineTo ( GX ( PPPAL [ K ].x ), GY ( PPPAL [ K ].y ) );
        Inc ( K );
      end;
      LineTo ( GX ( PPPAL [ L ].x ), GY ( PPPAL [ L ].y ) );
      PFillAndStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyPolygon16 ( PPL16: PEMRPolyPolyline16 );
var
  I, J, K, L: Integer;
  PPPA: PSmallPointArray;
begin
  with FCanvas do
  begin
    NewPath;
    K := SizeOf ( TEMRPolyPolyline16 ) - SizeOf ( TSmallPoint ) + SizeOf ( dword ) * ( ppl16^.nPolys - 1 );
    PPPA := IP ( PPL16, K );
    K := 0;
    for j := 0 to ppl16^.nPolys - 1 do
    begin
      MoveTo ( GX ( PPPA [ K ].x ), GY ( PPPA [ K ].y ) );
      L := K;
      Inc ( K );
      for I := 1 to ppl16^.aPolyCounts [ J ] - 1 do
      begin
        LineTo ( GX ( PPPA [ K ].x ), GY ( PPPA [ K ].y ) );
        Inc ( K );
      end;
      LineTo ( GX ( PPPA [ L ].x ), GY ( PPPA [ L ].y ) );
    end;
    PFillAndStroke;
  end;
end;

procedure TEMWParser.DoPolyPolyLine ( PPL: PEMRPolyPolyline );
var
  I, J, K: Integer;
  PPPAL: PPointArray;
begin
  with FCanvas do
  begin
    NewPath;
    K := SizeOf ( TEMRPolyPolyline ) - SizeOf ( TPoint ) + SizeOf ( dword ) * ( ppl^.nPolys - 1 );
    PPPAL := IP ( PPL, K );
    K := 0;
    for j := 0 to ppl^.nPolys - 1 do
    begin
      MoveTo ( GX ( PPPAL [ K ].x ), GY ( PPPAL [ K ].y ) );
      Inc ( K );
      for I := 1 to ppl^.aPolyCounts [ J ] - 1 do
      begin
        LineTo ( GX ( PPPAL [ K ].x ), GY ( PPPAL [ K ].y ) );
        Inc ( K );
      end;
    end;
    if not InPath then
      PStroke;
  end;
end;

procedure TEMWParser.DoPolyPolyLine16 ( PPL16: PEMRPolyPolyline16 );
var
  I, J, K: Integer;
  PPPA: PSmallPointArray;
begin
  with FCanvas do
  begin
    NewPath;
    K := SizeOf ( TEMRPolyPolyline16 ) - SizeOf ( TSmallPoint ) + SizeOf ( dword ) * ( ppl16^.nPolys - 1 );
    PPPA := IP ( PPL16, K );
    K := 0;
    for j := 0 to ppl16^.nPolys - 1 do
    begin
      MoveTo ( GX ( PPPA [ K ].x ), GY ( PPPA [ K ].y ) );
      Inc ( K );
      for I := 1 to ppl16^.aPolyCounts [ J ] - 1 do
      begin
        LineTo ( GX ( PPPA [ K ].x ), GY ( PPPA [ K ].y ) );
        Inc ( K );
      end;
    end;
    if not InPath then
      PStroke;
  end;
end;

procedure TEMWParser.DoRectangle ( Data: PEMREllipse );
begin
  if ( data^.rclBox.Left = data^.rclBox.Right ) or ( data^.rclBox.Top = data^.rclBox.Bottom ) then
  begin
    FCanvas.NewPath;
    Exit;
  end;
  FCanvas.Rectangle ( GX ( data^.rclBox.Left ), GY ( data^.rclBox.Top ), GX ( Data^.rclBox.Right ), GY ( Data^.rclBox.Bottom ) );
  if not InPath then
    if ( CPen.lopnWidth <> 0 ) and ( CPen.lopnStyle <> ps_null ) then
      if not IsNullBrush then
        CheckFillAndStroke
      else
        FCanvas.Stroke
    else if not IsNullBrush then
      CheckFill
    else
      FCanvas.NewPath;
end;


procedure TEMWParser.DoRestoreDC ( Data: PEMRRestoreDC );
var
  TR: TXForm;
  H: HGDIOBJ;
  NPen: TLogPen;
  NBrush: TLogBrush;
  NFont: TLogFontA;
  I: DWORD;
  S: TSize;
  P: TPoint;				
  ImgIdx: Integer;
  Pat: TPDFPattern;
begin
  RestoreDC ( DC, Data^.iRelative );
  if Clipping then
  begin
    InText := False;
    FCanvas.GStateRestore;
    Clipping := False;
  end;

// CheckTransform
  if NT then
  begin
    GetWorldTransform ( DC, TR );
    XOff := TR.eDx * CalX;
    YOff := TR.eDy * CalY;
    XScale := TR.eM11;
    YScale := TR.eM22;
    if XScale/YScale>1 then
      FCanvas.SetFontWidthScale(1)
    else
      FCanvas.SetFontWidthScale(XScale/YScale);
  end else
  begin
    if Data^.iRelative < 0 then
      if StackSize + Data^.iRelative >= 0 then
      begin
        XF := Transfstack [ StackSize + Data^.iRelative ];
        XScale := XF.eM11;
        YScale := XF.eM22;
        XOff := XF.eDx * CalX;
        YOff := XF.eDy * CalY;
        StackSize := StackSize + Data^.iRelative;
        SetLength ( TransfStack, StackSize );
      end else
        TransfStack := nil
    else if StackSize > Data^.iRelative then
    begin
      XF := Transfstack [ Data^.iRelative - 1 ];
      XScale := XF.eM11;
      YScale := XF.eM22;
      XOff := XF.eDx * CalX;
      YOff := XF.eDy * CalY;
      StackSize := Data^.iRelative - 1;
      SetLength ( TransfStack, StackSize );
    end;
  end;
  if XScale/YScale>1 then
    FCanvas.SetFontWidthScale(1)
  else
    FCanvas.SetFontWidthScale(XScale/YScale);
  MapMode := GetMapMode ( DC );
  SBM := GetStretchBltMode(DC);
  BGMode := not ( GetBkMode ( DC ) = TRANSPARENT );
  TextColor := GetTextColor ( DC );
  ROP2 := GetROP2(DC);
  if InText then
    SetFontColor;
  BGColor := GetBkColor ( DC );
  PolyFIllMode := ( GetPolyFillMode ( DC ) = ALTERNATE );
  GetViewportExtEx ( DC, S );
  VEX := S.cx;
  VEY := S.cy;
  GetWindowExtEx ( DC, S );
  WEX := S.cx;
  WEY := S.cy;
  GetViewportOrgEx ( DC, P );
  VOX := P.x;
  VOY := P.y;
  GetWindowOrgEx ( dc, P );
  WOX := P.x;
  WOY := P.y;
  if Clipping then
  begin
    Clipping := False;
    FCha := True;
    if InText then
    begin
      FCanvas.GStateRestore;
    end else
      FCanvas.GStateRestore;
  end;

// Check Pen
  H := GetCurrentObject ( DC, OBJ_PEN );
  GetObject ( H, SizeOf ( NPen ), @NPen );
  if NPen.lopnColor <> CPen.lopnColor then
  begin
    CPen.lopnColor := NPen.lopnColor;
    SetPenColor;
  end;
  if Npen.lopnWidth.x > 1 then
    NPen.lopnStyle := ps_Solid;
  if NPen.lopnStyle <> CPen.lopnStyle then
  begin
    CPen.lopnStyle := NPen.lopnStyle;
    SetPenStyle(NPen.lopnStyle);
  end;
  if NPen.lopnWidth.x * XScale * FX <> CPen.lopnWidth then
  begin
    if NPen.lopnWidth.x = 0 then
      CPen.lopnWidth := FX * xscale
    else
      CPen.lopnWidth := NPen.lopnWidth.x * XScale * FX;
    FCanvas.SetLineWidth ( CalX * CPen.lopnWidth );
  end;

//Chech Brush
  H := GetCurrentObject ( DC, OBJ_BRUSH );
  GetObject ( H, SizeOf ( NBrush ), @NBrush );

  if ( NBrush.lbStyle = BS_DIBPATTERN ) or ( NBrush.lbStyle = BS_DIBPATTERN8x8) then
  begin
    for I:= 0 to Length( FPat) -1 do
      if (FPat[I].IsBMP) and (Pointer(NBrush.lbHatch) = FPat[I].BMI) then
      begin
        if FPat[I].idx = nil then
        begin
          FPat[I].idx := TPDFPattern.Create(FEngine,FFontManager);
          FPatterns.Add(FPat[I].idx);
          with FPat[I].idx do
          begin
            Width := FPat[I].BM.Width;
            Height := FPat[I].BM.Height;
            XStep := Width;
            YStep := Height;
            ImgIdx:=AddBitmap(FPat[I].BM);
            ShowImage(ImgIdx,0,0,Width,Height,0);
          end;
          FPat[I].BM.Free;
          FPat[I].BM := nil;
        end;
        Pat := FPat[i].idx;
        if FCanvas is TPDFPage then
        begin
          TPDFPage(FCanvas).SetPattern(Pat);
          FIsPattern := True;
        end;
        if FCanvas is TPDFForm  then
        begin
          FIsPattern := True;
          TPDFForm(FCanvas).SetPattern(Pat);
        end;
        Break;
      end;
  end else
  begin
    FIsPattern := False;
    if NBrush.lbColor <> CBrush.lbColor then
    begin
      CBrush.lbColor := NBrush.lbColor;
      if not InText then
        SetBrushColor;
    end;
  end;
  if NBrush.lbStyle = 1 then
    IsNullBrush := True;
  if NBrush.lbStyle = BS_HATCHED then
  begin
    CBrush.lbStyle := BS_HATCHED;
    CBrush.lbHatch := NBrush.lbHatch;
  end;

//Check Font
  H := GetCurrentObject ( DC, OBJ_FONT );
  GetObjectA ( H, SizeOf ( NFont ), @NFont );
  if ( CFont.lfFaceName <> NFont.lfFaceName ) or ( CFont.lfWeight <> NFont.lfWeight ) or
    ( CFont.lfItalic <> NFont.lfItalic ) or ( CFont.lfUnderline <> NFont.lfUnderline ) or
    ( CFont.lfStrikeOut <> NFont.lfStrikeOut ) or ( CFont.lfCharSet <> NFont.lfCharSet ) or
    ( CFont.lfHeight <> NFont.lfHeight ) then
  begin
    Move ( NFont, CFont, SizeOf ( CFont ) );
    Fcha := True;
  end;
  I := GetTextAlign ( DC );
  case I and ( TA_LEFT or ta_Right or ta_center ) of
    ta_left: HorMode := hjLeft;
    ta_right: HorMode := hjRight;
    ta_center: HorMode := hjCenter;
  end;
//Vertical Detect
  case I and ( TA_Top or ta_BaseLine or ta_Bottom ) of
    TA_Top: VertMode := vjUp;
    ta_Bottom: VertMode := vjDown;
    TA_BASELINE: VertMode := vjCenter;
  end;
  UpdatePos := ( I and TA_UPDATECP = TA_UPDATECP );
  if GetArcDirection( DC ) = AD_CLOCKWISE then
  CCW := false else CCW :=true;
end;

procedure TEMWParser.DoRoundRect ( Data: PEMRRoundRect );
begin
  FCanvas.RoundRect ( Round ( GX ( Data^.rclBox.Left ) ), Round ( GY ( Data^.rclBox.Top ) ),
    Round ( GX ( Data^.rclBox.Right ) ), Round ( GY ( Data^.rclBox.Bottom ) ),
    Round ( GX ( Data^.szlCorner.cx, False ) ), Round ( GY ( Data^.szlCorner.cy, False ) ) );
  if not InPath then
    if ( CPen.lopnWidth <> 0 ) and ( CPen.lopnStyle <> ps_null ) then
      if not IsNullBrush then
        CheckFillAndStroke
      else
        FCanvas.Stroke
    else if not IsNullBrush then
      CheckFill
    else
      FCanvas.NewPath;
end;

procedure TEMWParser.DoSaveDC;
begin
  SaveDC ( DC );
  if not NT then
  begin
    Inc ( StackSize );
    if StackSize >= 1 then
    begin
      SetLength ( TransfStack, StackSize );
      TransfStack [ StackSize - 1 ] := XF;
    end;
  end;
end;

procedure TEMWParser.DoSelectClipPath;
begin
  if Clipping then
  begin
    FCanvas.GStateRestore;
    FCanvas.SetLineWidth ( CalX * CPen.lopnWidth );
    SetPenColor;
    SetBrushColor ( False );
    FCha := True;
  end;
  FCanvas.GStateSave;
  Clipping := True;
  FCanvas.Clip;
  isCR := False;
  FCanvas.NewPath;
  InPath := False;
end;

procedure TEMWParser.DoSelectObject ( Data: PEMRSelectObject );
var
  I: DWORD;
  NPen: TLogPen;
  NBrush: TLogBrush;
  NFont: TLogFontA;
  Pat: TPDFPattern;
  ImgIdx: Integer;
begin
  if ( Data^.ihObject and $80000000 ) = 0 then
  begin
    if Data^.ihObject >= HandlesCount then
      Exit;
    SelectObject ( DC, HandleTable [ Data^.ihObject ] );
    I := GetObjectType ( HandleTable [ Data^.ihObject ] );
    case I of
      OBJ_PEN:
        begin
          GetObject ( HandleTable [ Data^.ihObject ], SizeOf ( NPen ), @NPen );
          if NPen.lopnColor <> CPen.lopnColor then
          begin
            CPen.lopnColor := NPen.lopnColor;
            SetPenColor;
          end;
          if Npen.lopnWidth.X > 1 then
            NPen.lopnStyle := ps_Solid;

          if NPen.lopnStyle <> CPen.lopnStyle then
          begin
            CPen.lopnStyle := NPen.lopnStyle;
            SetPenStyle(NPen.lopnStyle);
          end;
          if NPen.lopnWidth.x * XScale * FX <> CPen.lopnWidth then
          begin
            if NPen.lopnWidth.x = 0 then
              CPen.lopnWidth := XScale * FX
            else
              CPen.lopnWidth := NPen.lopnWidth.x * XScale * FX;
            FCanvas.SetLineWidth ( CalX * CPen.lopnWidth );
          end;
        end;
      OBJ_BRUSH:
        begin
          IsNullBrush := False;
          GetObject ( HandleTable [ Data^.ihObject ], SizeOf ( NBrush ), @NBrush );
          if ( NBrush.lbStyle = BS_DIBPATTERN ) or ( NBrush.lbStyle = BS_DIBPATTERN8x8) then
          begin
            for I:= 0 to Length( FPat) -1 do
              if (FPat[I].IsBMP) and (Pointer(NBrush.lbHatch) = FPat[I].BMI) then
              begin
                if FPat[I].idx = nil then
                begin
                  FPat[I].idx := TPDFPattern.Create(FEngine,FFontManager);
                  FPatterns.Add(FPat[I].idx);
                  with FPat[I].idx do
                  begin
                    Width := FPat[I].BM.Width;
                    Height := FPat[I].BM.Height;
                    XStep := Width;
                    YStep := Height;
                    ImgIdx:=AddBitmap(FPat[I].BM);
                    ShowImage(ImgIdx,0,0,Width,Height,0);
                  end;
                  FPat[I].BM.Free;
                  FPat[I].BM := nil;
                end;
                Pat := FPat[i].idx;
                if FCanvas is TPDFPage then
                begin
                  TPDFPage(FCanvas).SetPattern(Pat);
                  FIsPattern := True;
                end;
                if FCanvas is TPDFForm  then
                begin
                  TPDFForm(FCanvas).SetPattern(Pat);
                  FIsPattern := True;
                end;
                Break;
              end;
          end else
          begin
            FIsPattern := False;
            if NBrush.lbColor <> CBrush.lbColor then
            begin
              CBrush.lbColor := NBrush.lbColor;
              if not InText then
                SetBrushColor;
            end;
            if NBrush.lbStyle = 1 then
              IsNullBrush := True;
            if NBrush.lbStyle = BS_HATCHED then
            begin
              CBrush.lbStyle := BS_HATCHED;
              CBrush.lbHatch := NBrush.lbHatch;
            end;
          end;
        end;
      OBJ_FONT:
        begin
          GetObjectA ( HandleTable [ Data^.ihObject ], SizeOf ( NFont ), @NFont );
          for  I:= 1 to {$ifdef USEANSISTRINGS}system.ansistrings.StrLen{$else}StrLen{$endif}(PAnsiChar(@NFont.lfFaceName[0]))  do
            if NFont.lfFaceName[I] = '?' then
            begin
              GetTextFaceA(DC,32, @NFont.lfFaceName[0]);
              Break;
            end;
          if ( CFont.lfFaceName <> NFont.lfFaceName ) or ( CFont.lfWeight <> NFont.lfWeight ) or
            ( CFont.lfItalic <> NFont.lfItalic ) or ( CFont.lfUnderline <> NFont.lfUnderline ) or
            ( CFont.lfStrikeOut <> NFont.lfStrikeOut ) or ( CFont.lfCharSet <> NFont.lfCharSet ) or
            ( CFont.lfHeight <> NFont.lfHeight ) then
          begin
            Move ( NFont, CFont, SizeOf ( CFont ) );
            Fcha := True;
          end
          else if ( CFont.lfEscapement <> NFont.lfEscapement ) or ( CFont.lfOrientation <> NFont.lfOrientation ) then
            Move ( NFont, CFont, SizeOf ( CFont ) );
        end;
    end;
  end
  else
  begin
    I := Data^.ihObject and $7FFFFFFF;
    SelectObject ( DC, GetStockObject ( I ) );
    case I of
      WHITE_BRUSH:
        begin
          IsNullBrush := False;
          FIsPattern := False;
          CBrush.lbColor := clWhite;
          if not InText then
            SetBrushColor;
        end;
      LTGRAY_BRUSH:
        begin
          IsNullBrush := False;
          FIsPattern := False;
          CBrush.lbColor := $AAAAAA;
          if not InText then
            SetBrushColor;
        end;
      GRAY_BRUSH:
        begin
          IsNullBrush := False;
          FIsPattern := False;
          CBrush.lbColor := $808080;
          if not InText then
            SetBrushColor;
        end;
      DKGRAY_BRUSH:
        begin
          IsNullBrush := False;
          FIsPattern := False;
          CBrush.lbColor := $666666;
          if not InText then
            SetBrushColor;
        end;
      BLACK_BRUSH:
        begin
          IsNullBrush := False;
          FIsPattern := False;
          CBrush.lbColor := 0;
          if not InText then
            SetBrushColor;
        end;
      Null_BRUSH:
        begin
          CBrush.lbColor := clWhite;
          FIsPattern := False;
          IsNullBrush := True;
          if not InText then
            SetBrushColor;
        end;
      WHITE_PEN:
        begin
          CPen.lopnColor := clWhite;
          if CPen.lopnStyle <> PS_SOLID then
          begin
          CPen.lopnStyle := PS_SOLID;
            FCanvas.NoDash;
          end;
          FCanvas.SetColorStroke ( GrayToPDFColor(1)) ;
          CPen.lopnWidth := XScale * FX;
          FCanvas.SetLineWidth ( CalX * CPen.lopnWidth );
        end;
      BLACK_PEN:
        begin
          CPen.lopnColor := clBlack;
          if CPen.lopnStyle <> PS_SOLID then
          begin
          CPen.lopnStyle := PS_SOLID;
            FCanvas.NoDash;
          end;
          FCanvas.SetColorStroke ( GrayToPDFColor(0)) ;
          CPen.lopnWidth := XScale * FX;
          FCanvas.SetLineWidth ( CalX * CPen.lopnWidth );
        end;
      Null_PEN:
        begin
          if CPen.lopnStyle in[ PS_DASH, PS_DOT, PS_DASHDOT, PS_DASHDOTDOT] then
          begin
            FCanvas.NoDash;
          end;
          CPen.lopnStyle := PS_NULL;
        end;
      OEM_FIXED_FONT, ANSI_FIXED_FONT, ANSI_VAR_FONT, SYSTEM_FONT:
        begin
          CFont.lfFaceName := 'Arial';
          Fcha := True;
//          if InText then SetCurFont;
        end;
    end;
  end;
end;


procedure TEMWParser.DoSetArcDirection ( Data: PEMRSetArcDirection );
begin
  CCW := Data^.iArcDirection = AD_COUNTERCLOCKWISE;
end;

procedure TEMWParser.DoSetBKColor ( PColor: PEMRSetTextColor );
begin
  BGColor := PColor^.crColor;
  SetBkColor ( DC, PColor^.crColor );
end;

procedure TEMWParser.DoSetBKMode ( PMode: PEMRSelectclippath );
begin
  BGMode := not ( PMode^.iMode = TRANSPARENT );
  SetBkMode ( DC, pmode^.iMode );
end;

procedure TEMWParser.DoSetDibitsToDevice ( Data: PEMRSetDIBitsToDevice );
var
  B: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
  I: Integer;
begin
  P := IP ( Data, Data^.offBmiSrc );
  O := IP ( Data, Data^.offBitsSrc );
  B := TBitmap.Create;
  try
    if ( P^.bmiHeader.biBitCount = 1 ) then
          B.Monochrome := True;
    B.Width := Data^.cxSrc;
    B.Height := Data^.cySrc;
    SetDIBitsToDevice ( B.Canvas.Handle, 0, 0, B.Width, B.Height, Data^.xSrc, Data^.ySrc,
      Data^.iStartScan, Data^.cScans, O, p^, Data^.iUsageSrc );
    I := AddBitmap( B );
    FCanvas.ShowImage ( I, GX ( Data^.rclBounds.Left, false ), GY ( Data^.rclBounds.Top, False ),
      CalX * FX * XScale * data^.cxSrc, CalY * FY * YScale * Data^.cySrc, 0 );
  finally
    B.Free;
  end;
end;

procedure TEMWParser.DoSetMiterLimit ( Data: PEMRSetMiterLimit );
begin
//  Data := CV;
//  FCanvas.SetMiterLimit(Data^.eMiterLimit);
end;

procedure TEMWParser.DoSetPixelV ( Data: PEMRSetPixelV );
begin
  FCanvas.NewPath;
  if Data^.crColor <> CPen.lopnColor then
    FCanvas.SetColorStroke ( ColorToPDFColor ( Data^.crColor ) );

  if CPen.lopnWidth <> 1 then
    FCanvas.SetLineWidth ( 1 );
  FCanvas.MoveTo ( GX ( Data^.ptlPixel.x ), GY ( Data^.ptlPixel.y ) );
  FCanvas.LineTo ( GX ( Data^.ptlPixel.x ) + 0.01, GY ( Data^.ptlPixel.y ) + 0.01 );
  PStroke;
  if CPen.lopnWidth <> 1 then
    FCanvas.SetLineWidth ( CalX * CPen.lopnWidth );
  if Data^.crColor <> CPen.lopnColor then
    FCanvas.SetColorStroke ( ColorToPDFColor ( CPen.lopnColor ) );
end;

procedure TEMWParser.DoSetPolyFillMode ( PMode: PEMRSelectclippath );
begin
  PolyFIllMode := ( PMode^.iMode = ALTERNATE );
  SetPolyFillMode ( DC, pmode^.iMode );
end;

procedure TEMWParser.DoSetStretchBltMode ( Data: PEMRSetStretchBltMode );
begin
  SBM := Data^.iMode;
  SetStretchBltMode ( DC, data^.iMode );
end;

procedure TEMWParser.DoSetTextAlign ( PMode: PEMRSelectclippath );
begin
  SetTextAlign ( DC, PMode^.iMode );
// Horisontal Detect
  case PMode^.iMode and ( TA_LEFT or ta_Right or ta_center ) of
    ta_left: HorMode := hjLeft;
    ta_right: HorMode := hjRight;
    ta_center: HorMode := hjCenter;
  end;
//Vertical Detect
  case PMode^.iMode and ( TA_Top or ta_BaseLine or ta_Bottom ) of
    TA_Top: VertMode := vjUp;
    ta_Bottom: VertMode := vjDown;
    TA_BASELINE: VertMode := vjCenter;
  end;
  UpdatePos := ( PMode^.iMode and TA_UPDATECP = TA_UPDATECP );
end;

procedure TEMWParser.DoSetTextColor ( PColor: PEMRSetTextColor );
begin
  TextColor := PColor^.crColor;
  SetTextColor ( DC, pcolor^.crColor );
  if InText then
    SetFontColor;
end;

procedure TEMWParser.DoSetTextJustification ( Data: PEMRLineTo );
begin
//  Data := CV;
//  if (Data^.ptl.x = 0) or (Data^.ptl.y = 0) then
//    FCanvas.SetWordSpacing(0) else FCanvas.SetWordSpacing(G(Data^.ptl.x / Data^.ptl.y));
end;

procedure TEMWParser.DoSetViewPortExtEx ( Data: PEMRSetViewportExtEx );
begin
  VEX := Data^.szlExtent.cx;
  VEY := Data^.szlExtent.cy;
  SetViewportExtEx ( DC, Data^.szlExtent.cx, data^.szlExtent.cy, nil );
end;

procedure TEMWParser.DoSetViewPortOrgEx ( Data: PEMRSetViewportOrgEx );
begin
  VOX := Data^.ptlOrigin.X;
  VOY := Data^.ptlOrigin.Y;
  SetViewportOrgEx ( DC, data^.ptlOrigin.X, data^.ptlOrigin.Y, nil );
end;

procedure TEMWParser.DoSetWindowExtEx ( Data: PEMRSetViewportExtEx );
begin
  WEX := data^.szlExtent.cx;
  WEY := Data^.szlExtent.cy;
  SetWindowExtEx ( DC, data^.szlExtent.cx, Data^.szlExtent.cy, nil );
end;

procedure TEMWParser.DoSetWindowOrgEx ( Data: PEMRSetViewportOrgEx );
begin
  WOX := Data^.ptlOrigin.X;
  WOY := Data^.ptlOrigin.Y;
  SetWindowOrgEx ( DC, Data^.ptlOrigin.X, Data^.ptlOrigin.Y, nil );
end;

procedure TEMWParser.DoScaleWindowEx ( Data: PEMRScaleWindowExtEx );
begin
  WindowScaleUsed := True;
  WXNum := Data^.xNum;
  WXDenom := Data^.xDenom;
  WYNum := Data^.yNum;
  WYDenom := Data^.yDenom;
  ScaleWindowExtEx( DC, Data^.xNum, Data^.xDenom, Data^.yNum, Data^.yDenom, nil );
end;

procedure TEMWParser.DoScaleViewPortEx ( Data: PEMRScaleViewportExtEx );
begin
  ViewPortScaleUsed := True;
  VXNum := Data^.xNum;
  VXDenom := Data^.xDenom;
  VYNum := Data^.yNum;
  VYDenom := Data^.yDenom;
  ScaleViewportExtEx( DC, Data^.xNum, Data^.xDenom, Data^.yNum, Data^.yDenom, nil  );
end;


procedure TEMWParser.DoSetWorldTransform ( PWorldTransf: PEMRSetWorldTransform );
begin
  XScale := PWorldTransf^.xform.eM11;
  YScale := PWorldTransf^.xform.eM22;
  XOff := PWorldTransf^.xform.eDx * CalX;
  YOff := PWorldTransf^.xform.eDy * CalY;
  if XScale/YScale>1 then
    FCanvas.SetFontWidthScale(1)
  else
    FCanvas.SetFontWidthScale(XScale/YScale);
  if NT then
    SetWorldTransform ( DC, PWorldTransf^.xform )
  else
    Move ( PWorldTransf^.xform, XF, SizeOf ( XF ) );
end;

procedure TEMWParser.DoStretchBlt ( Data: PEMRStretchBlt );
var
  B, B1, BR: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
  I: Integer;
  BBB:HBITMAP;
  Width, Height :Integer;
  IsMonochrome: Boolean;
begin
  if ( Data^.offBmiSrc > 0 ) and ( Data^.offBitsSrc > 0 ) then
  begin
    P := IP ( Data, Data^.offBmiSrc );
    O := IP ( Data, Data^.offBitsSrc );
    IsMonochrome := P^.bmiHeader.biBitCount = 1;
    Width := P^.bmiHeader.biWidth;
    Height := P^.bmiHeader.biHeight;
    B := TBitmap.Create;
    try
      B.Monochrome := IsMonochrome;
      B.Width := Width;
      B.Height := Height;
      StretchDIBits ( B.Canvas.Handle, 0, 0, Width, Height, 0, 0,
        Width, Height, O, p^, Data^.iUsageSrc, SRCCOPY );
      if Data^.dwRop <> SRCCOPY then
      begin
          B1 := TBitmap.Create;
          try
            if IsMonochrome then
                BBB:= CreateBitmap(Width, Height, 1, 1, nil)
            else
                BBB := CreateCompatibleBitmap( DC, Width, Height );
            if BBB <> 0 then
            begin
                B1.Handle := BBB;
                BR := B1;
                StretchBlt ( B1.Canvas.Handle, 0, 0, Width, Height,
                    B.Canvas.Handle, 0, 0, Width, Height, Data^.dwRop );
            end else
                BR := B;
            I := AddBitmap( BR);
            FCanvas.ShowImage ( I, GX ( Data^.rclBounds.Left, False ),
              GY ( Data^.rclBounds.Top, False ),
              GX ( Data^.rclBounds.Right - Data^.rclBounds.Left + 1, False ),
              GY ( Data^.rclBounds.Bottom - Data^.rclBounds.Top + 1, False ), 0 );
          finally
            B1.Free;
          end;
      end else
      begin
        I := AddBitmap( B );
        FCanvas.ShowImage ( I, GX ( Data^.rclBounds.Left, False ),
          GY ( Data^.rclBounds.Top, False ),
          GX ( Data^.rclBounds.Right - Data^.rclBounds.Left + 1, False ),
          GY ( Data^.rclBounds.Bottom - Data^.rclBounds.Top + 1, False ), 0 );
      end;
    finally
      B.Free;
    end;
  end
  else
  begin
    if ( data^.cxDest = 0 ) or ( data^.cyDest = 0 ) then
      FCanvas.NewPath
    else
    begin
      FCanvas.Rectangle ( gX ( data^.xDest ), gY ( Data^.yDest ),
        gX ( Data^.xDest + Data^.cxDest ), gY ( Data^.yDest + Data^.cyDest ) );
      CheckFill;
    end;
  end;
end;

{$ifdef CANVASDBG}
const
  ADAR:Integer = 0;
{$endif}
procedure TEMWParser.DoStretchDiBits ( Data: PEMRStretchDiBits );
var
  B: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
  I: Integer;
  W, H: Integer;
  Rop:Cardinal;
begin
  P := IP ( Data, Data^.offBmiSrc );
  O := IP ( Data, Data^.offBitsSrc );
  W := Data^.rclBounds.Right - Data^.rclBounds.Left + 1;
  H := Data^.rclBounds.Bottom - Data^.rclBounds.Top + 1;
  if ( W <= 0 ) or ( H <= 0 ) then
  begin
    if ( CalX * FX * XScale * data^.cxDest < 0.01 ) or (CalY * FY * YScale * Data^.cyDest < 0.01) then
     Exit;
  end;
  B := TBitmap.Create;
  try
    if Data^.dwRop = 12060490 then
      Rop := SRCCOPY
    else
      Rop := Data^.dwRop;
    if ( P^.bmiHeader.biBitCount = 1 ) then
          B.Monochrome := True;
    B.Width := Data^.cxSrc;
    B.Height := Data^.cySrc;
    SetStretchBltMode(B.Canvas.Handle, SBM);
    StretchDIBits ( B.Canvas.Handle, 0, 0, B.Width, B.Height, Data^.xSrc, Data^.ySrc,
      B.Width, B.Height, O, p^, Data^.iUsageSrc, Rop )  ;
    if SBM <> 4 then
      FlipBMP(B, Data^.cxDest < 0, Data^.cyDest < 0 );
    if B.Monochrome then
    begin
      B.PixelFormat := pf1bit;
    end;
    I := AddBitmap( B);
    FCanvas.ShowImage ( I, GX ( Data^.xDest ), GY ( Data^.yDest ), abs(CalX * FX * XScale * data^.cxDest),
      abs(CalY * FY * YScale * Data^.cyDest), 0 );
  finally
    B.Free;
  end;
end;

procedure TEMWParser.DoStrokeAndFillPath;
begin
  InPath := False;
  PFillAndStroke;
  InPath := False;
  FCanvas.NewPath;
end;

procedure TEMWParser.DoStrokePath;
begin
  InPath := False;
  PStroke;
  FCanvas.NewPath;
end;


function EnumEMFRecordsProc ( DC: HDC; HandleTable: PHandleTable;
  EMFRecord: PEnhMetaRecord; nObj: Integer; Parser:TEMWParser): Bool; stdcall;
begin
  Result := True;
  Inc ( Parser.CurRec );
  try
    Parser.ExecuteRecord ( EMFRecord );
{$IFDEF CANVASDBG}
    Parser.SaveToLog ( EMFRecord );
{$ENDIF}
  except
    on Exception do
      ;
  end;
end;


procedure TEMWParser.Execute;
var
  Header: EnhMetaHeader;
  I: Integer;
  H: HGDIOBJ;
  PixelsX, PixelsY, MMX, MMY: Extended;
  R:TRect;
begin
  GetEnhMetaFileHeader ( MFH, SizeOf ( Header ), @Header );
  HandlesCount := Header.nHandles;
  SetLength ( HandleTable, HandlesCount );
  for I := 0 to HandlesCount - 1 do
    HandleTable [ i ] := $FFFFFFFF;
  Meta.Clear;
  DC := MetaCanvas.Handle;
  SetGraphicsMode ( DC, GM_ADVANCED );
  FIsPattern := False;
  XF.eM11 := 1;
  XF.eM12 := 0;
  XF.eM21 := 0;
  XF.eM22 := 1;
  XF.eDx := 0;
  XF.eDy := 0;
  NT := SetWorldTransform ( DC, XF );
  H := GetCurrentObject ( DC, OBJ_FONT );
  GetObject ( H, sizeof ( CFont ), @CFONT );
  FCanvas.SetFontWidthScale(1);
  XScale := 1;
  YScale := 1;
  XOff := 0;
  YOff := 0;
  StackSize := 0;
  TransfStack := nil;
  FCanvas.SetHorizontalScaling ( 100 );
  FCanvas.SetCharacterSpacing ( 0 );
  FCanvas.SetWordSpacing ( 0 );
  CPen.lopnStyle := 0;
  FCanvas.SetLineCap( FEMFOptions.LineCap );
  FCanvas.SetLineJoin( FEMFOptions.LineJoin );
  if FEMFOptions.UseFrame then
  begin
    PixelsX := Header.szlDevice.cx;
    PixelsY := Header.szlDevice.cy;
    MMX := Header.szlMillimeters.cx;
    MMY := Header.szlMillimeters.cy;;

    R.top := Round( Header.rclFrame.top * PixelsY /(MMY*100.0));
    R.left := Round( Header.rclFrame.left * PixelsX / (MMX*100.0));
    R.right := Round( Header.rclFrame.right * PixelsX / (MMX*100.0));
    R.bottom := Round( Header.rclFrame.bottom * PixelsY / (MMY*100.0));
    FCanvas.NewPath;
    FCanvas.Rectangle( Header.rclFrame.top * PixelsY /(MMY*100.0) * CalX,
      Header.rclFrame.left * PixelsX / (MMX*100.0) * CalY,
      Header.rclFrame.right * PixelsX / (MMX*100.0) * CalX,
      Header.rclFrame.bottom * PixelsY / (MMY*100.0) * CalY);
    FCanvas.Clip;
    FCanvas.NewPath;
  end;
  InitExecute;
  R := Rect ( 0, 0, 0, 0 );
  EnumEnhMetafile ( 0,mfh, @EnumEMFRecordsProc, self, R );
{$IFDEF CANVASDBG}
  DeleteEnhMetaFile ( CopyEnhMetaFile ( MFH, PChar ( 'HDCDebug\' + IntToStr ( iii ) + '.emf' ) ) );
  Debug.SaveToFile ( 'HDCDebug\' + IntToStr ( iii ) + '.txt' );
  Inc ( iii );
{$ENDIF}

  for I:= 0 to Length( FPat) -1 do
    if FPat[I].IsBMP then
    begin
      if FPat[I].BM <> nil then
        FPat[I].BM.Free;
      FreeMem( FPat[I].BMI);
    end;
  for I := 1 to HandlesCount - 1 do
    DeleteObject ( HandleTable [ I ] );
  HandleTable := nil;
  TransfStack := nil;
  FCanvas.TextFromBaseLine ( False );
  FCanvas.SetHorizontalScaling ( 100 );
  FCanvas.SetCharacterSpacing ( 0 );
  FCanvas.SetWordSpacing ( 0 );
  FCanvas.SetFontWidthScale(1);
end;

function TEMWParser.GX ( Value: Extended; Map: Boolean = True ): Extended;
begin
  if Map then
    Result := XOff + XScale * Mapx ( Value ) * CalX
  else
    Result := Value * CalX
end;

function TEMWParser.GY ( Value: Extended; Map: Boolean = True ): Extended;
begin
  if Map then
    Result := YOff + YScale * Mapy ( Value ) * CalY
  else
    Result := Value * CalY;
end;

function TEMWParser.GetMax: TSize;
var
  Header: EnhMetaHeader;
begin
  GetEnhMetaFileHeader ( MFH, SizeOf ( Header ), @Header );
  Result.cx := Round ( CalX * header.rclBounds.Right ) + 1;
  Result.cy := Round ( CalY * header.rclBounds.Bottom ) + 1;
end;

procedure TEMWParser.LoadMetaFile ( MF: TMetafile );
begin
  MFH := MF.Handle;
end;

procedure TEMWParser.SetCurFont;
var
  Rp: Boolean;
  St: TFontStyles;
  FS: Extended;
  S: AnsiString;
  RS: AnsiString;
  r1, r2: Extended;
  BM: TBitmap;
  NF: TLogFontA;
  F: THandle;
  TM: TEXTMETRIC;
begin
  if not Fcha then
    Exit;
  Fcha := False;
  St := [ ];
  if CFont.lfWeight >= 600 then
    St := St + [ fsBold ];
  if CFont.lfItalic <> 0 then
    St := St + [ fsItalic ];
  if CFont.lfStrikeOut <> 0 then
    St := St + [ fsStrikeOut ];
  if CFont.lfUnderline <> 0 then
    St := St + [ fsUnderline ];
  Rp := False;
  S := UCase ( CFont.lfFaceName );
  if S = 'ZAPFDINGBATS' then
    Rp := False;
  if ( S = 'HELVETICA' ) and ( CFont.lfCharSet <> 0 ) then
    Rp := True;
  if S = 'SYMBOL' then
    Rp := False;
  if S = 'WINGDINGS' then
  begin
    WNG := True;
    CFont.lfCharset := 2;
  end
  else
    WNG := False;
  if not IsTrueType ( String(CFont.lfFaceName), CFont.lfCharset ) then
  begin
    if ( CFont.lfCharSet = GetDefFontCharSet ) then
    begin
      if not IsTrueType ( String(CFont.lfFaceName), DEFAULT_CHARSET ) then
      begin
        RP := True;
        RS := GetFontByCharset ( CFont.lfCharSet );
      end
      else
        CFont.lfCharSet := DEFAULT_CHARSET;
    end
    else
    begin
      RP := True;
      RS := GetFontByCharset ( CFont.lfCharSet );
    end;
  end;		   
  if CFont.lfHeight < 0 then
    FS := MulDiv ( abs ( CFont.lfHeight ), 72,
      GetDeviceCaps ( FEMFOptions.UsedDC, LOGPIXELSY ) ) * abs ( YScale )
  else
  begin
    GetTextMetrics ( DC, TM );
    FS := MulDiv ( TM.tmHeight - TM.tmInternalLeading, 72,
      GetDeviceCaps ( FEMFOptions.UsedDC, LOGPIXELSY ) ) * abs ( YScale )
  end;
  if not Rp then
    FCanvas.SetActiveFont ( String(CFont.lfFaceName), St, FS * FY, 0 )
  else
  begin
    if S = 'COURIER' then
      FCanvas.SetActiveFont ( 'Courier New', St, FS * FY, CFont.lfCharSet )
    else if S = 'TIMES' then
      FCanvas.SetActiveFont ( 'Times New Roman', St, FS * FY, CFont.lfCharSet )
    else if RS <> '' then
      FCanvas.SetActiveFont ( String(RS), St, FS * FY, CFont.lfCharSet )
    else
      FCanvas.SetActiveFont ( 'Arial', St, FS * FY, 0 );
  end;
  if CFont.lfWidth = 0 then
    FCanvas.SetHorizontalScaling ( 100 )
  else
  begin
    BM := TBitmap.Create;
    try
      Move ( CFont, NF, SizeOf ( NF ) );
      F := CreateFontIndirectA ( NF );
      SelectObject ( BM.Canvas.Handle, F );
      r1 := BM.Canvas.TextWidth ( 'A' );
      DeleteObject ( F );
      NF.lfWidth := 0;
      F := CreateFontIndirectA ( NF );
      SelectObject ( BM.Canvas.Handle, F );
      r2 := BM.Canvas.TextWidth ( 'A' );
      DeleteObject ( F );
      FCanvas.SetHorizontalScaling ( r1 / r2 * 100 );
    finally
      BM.Free;
    end;
  end;
end;

procedure TEMWParser.SetInPath ( const Value: Boolean );
begin
  FInPath := Value;
end;

procedure TEMWParser.PFillAndStroke;
begin
  if IsNullBrush and ( CPen.lopnStyle = ps_null ) then
  begin
    FCanvas.NewPath;
    Exit;
  end;
  if not IsNullBrush then
  begin
    CheckBrushToHatched;
    if CPen.lopnStyle <> ps_null then
      if PolyFillMode then
        FCanvas.EoFillAndStroke
      else
        FCanvas.FillAndStroke
    else if PolyFillMode then
      FCanvas.EoFill
    else
      FCanvas.Fill
  end else
    PStroke;
end;

procedure TEMWParser.PStroke;
begin
  if (CPen.lopnStyle and $f) <> ps_null then
    FCanvas.Stroke
  else
  begin
    if (ROP2 = R2_COPYPEN) and FEMFOptions.ShowNullPen then
    begin
      FCanvas.SetLineWidth(0.0001);
      FCanvas.Stroke;
    end else
      FCanvas.NewPath;
  end;
end;

procedure TEMWParser.SetInText ( const Value: Boolean );
begin
  if FInText = Value then
    Exit;
  FInText := Value;
  if not Value then
  begin
    SetBrushColor;
  end;
end;

procedure TEMWParser.SetBrushColor ( Check: Boolean = True );
var
  e: array [ 0..19 ] of TPALETTEENTRY;
  b: Byte;
  c: Integer;
  h: HGDIOBJ;
begin
  if FIsPattern then
    Exit;
  if ( CBrush.lbColor > $FFFFFF ) and ( CBrush.lbColor - $FFFFFF < 21 ) then
  begin
    h := GetStockObject ( DEFAULT_PALETTE );
    c := GetPaletteEntries ( h, 0, 20, e );
    b := CBrush.lbColor and $FF;
    if c <> 0 then
      CBrush.lbColor := RGB ( e [ b ].peRed, e [ b ].peGreen, e [ b ].peBlue )
  end;
  if ( CurFill <> CBrush.lbColor ) or ( not Check ) then
  begin
    CurFill := CBrush.lbColor;
    FCanvas.SetColorFill ( ColorToPDFColor ( CBrush.lbColor ) );
  end;
end;

procedure TEMWParser.SetFontColor;
begin
  if ( CurFill <> TextColor ) or ( FCha ) then
  begin
    CurFill := TextColor;
    FCanvas.SetColorFill ( ColorToPDFColor ( TextColor ) );
  end;
end;

procedure TEMWParser.SetPenColor;
var
  e: array [ 0..19 ] of TPALETTEENTRY;
  b: Byte;
  c: Integer;
  h: HGDIOBJ;
begin
  if ( CPen.lopnColor > $FFFFFF ) and ( CPen.lopnColor - $FFFFFF < 21 ) then
  begin
    h := GetStockObject ( DEFAULT_PALETTE );
    c := GetPaletteEntries ( h, 0, 20, e );
    b := CPen.lopnColor and $FF;
    if c <> 0 then
      CPen.lopnColor := RGB ( e [ b ].peRed, e [ b ].peGreen, e [ b ].peBlue )
  end;
  FCanvas.SetColorStroke ( ColorToPDFColor ( CPen.lopnColor ) );
end;

procedure TEMWParser.SetBGColor;
begin
  if CurFill <> BGColor then
  begin
    CurFill := BGColor;
    FCanvas.SetColorFill ( ColorToPDFColor ( BGColor ) );
  end;
end;

procedure TEMWParser.DoModifyWorldTransform ( PWorldTransf: PEMRModifyWorldTransform );
var
  TR: TXForm;
  function MultiplyXForm ( S, T: TXForm ): TXForm;
  begin
    Result.eM11 := S.eM11 * T.eM11 + S.eM12 * T.eM21;
    Result.eM12 := S.eM11 * T.eM12 + S.eM12 * T.eM22;
    Result.eM21 := S.eM21 * T.eM11 + S.eM22 * T.eM21;
    Result.eM22 := S.eM21 * T.eM12 + S.eM22 * T.eM22;
    Result.eDx := S.eDx * T.eM11 + S.eDy * T.eM21 + T.eDx;
    Result.eDy := S.eDy * T.eM12 + S.eDy * T.eM22 + T.eDy;
  end;
begin
  if NT then
  begin
    ModifyWorldTransform ( DC, PWorldTransf^.xform, pworldTransf^.iMode );
    GetWorldTransform ( DC, TR );
    XOff := TR.eDx * CalX;
    YOff := TR.eDy * CalY;
    XScale := TR.eM11;
    YScale := TR.eM22;
    if XScale/YScale>1 then
      FCanvas.SetFontWidthScale(1)
    else
      FCanvas.SetFontWidthScale(XScale/YScale);
  end else
  begin
    case PWorldTransf^.iMode of
      MWT_LEFTMULTIPLY:
        begin
          XF := MultiplyXForm ( pworldTransf^.xform, XF );
          XScale := XF.eM11;
          YScale := XF.eM22;
          XOff := XF.eDx * CalX;
          YOff := XF.eDy * CalY;
        end;
      MWT_RIGHTMULTIPLY:
        begin
          XF := MultiplyXForm ( XF, pworldTransf^.xform );
          XScale := XF.eM11;
          YScale := XF.eM22;
          XOff := XF.eDx * CalX;
          YOff := XF.eDy * CalY;
        end;
      4:
        begin
          XScale := PWorldTransf^.xform.eM11;
          YScale := PWorldTransf^.xform.eM22;
          XOff := PWorldTransf^.xform.eDx * CalX;
          YOff := PWorldTransf^.xform.eDy * CalY;
          Move ( PWorldTransf^.xform, XF, SizeOf ( XF ) );
        end;
    end;
  if XScale/YScale>1 then
    FCanvas.SetFontWidthScale(1)
  else
    FCanvas.SetFontWidthScale(XScale/YScale);
  end;
end;


procedure TEMWParser.DoSetMapMode ( Data: PEMRSetMapMode );
begin
  MapMode := data^.iMode;
  SetMapMode ( DC, data^.iMode );
  FCha := True;
end;

{$IFDEF CANVASDBG}

procedure TEMWParser.SaveToLog ( Data: PEnhMetaRecord );
var
  S: AnsiString;
  NDW: Integer;
  Pin: ^Integer;
  I: Integer;
begin
  case Data^.iType of
    EMR_HEADER: S := 'HEADER';
    EMR_POLYBEZIER: S := 'POLYBEZIER';
    EMR_POLYGON: S := 'POLYGON';
    EMR_POLYLINE: S := 'POLYLINE';
    EMR_POLYBEZIERTO: S := 'POLYBEZIERTO';
    EMR_POLYLINETO: S := 'POLYLINETO';
    EMR_POLYPOLYLINE: S := 'POLYPOLYLINE';
    EMR_POLYPOLYGON: S := 'POLYPOLYGON';
    EMR_SETWINDOWEXTEX: S := 'SETWINDOWEXTEX';
    EMR_SETWINDOWORGEX: S := 'SETWINDOWORGEX';
    EMR_SETVIEWPORTEXTEX: S := 'SETVIEWPORTEXTEX';
    EMR_SETVIEWPORTORGEX: S := 'SETVIEWPORTORGEX';
    EMR_SETBRUSHORGEX: S := 'SETBRUSHORGEX';
    EMR_EOF:
      begin
        S := 'EOF'; FEX := True;
      end;
    EMR_SETPIXELV: S := 'SETPIXELV';
    EMR_SETMAPPERFLAGS: S := 'SETMAPPERFLAGS';
    EMR_SETMAPMODE: S := 'SETMAPMODE';
    EMR_SETBKMODE: S := 'SETBKMODE';
    EMR_SETPOLYFILLMODE: S := 'SETPOLYFILLMODE';
    EMR_SETROP2: S := 'SETROP2';
    EMR_SETSTRETCHBLTMODE: S := 'SETSTRETCHBLTMODE';
    EMR_SETTEXTALIGN: S := 'SETTEXTALIGN';
    EMR_SETCOLORADJUSTMENT: S := 'SETCOLORADJUSTMENT';
    EMR_SETTEXTCOLOR: S := 'SETTEXTCOLOR';
    EMR_SETBKCOLOR: S := 'SETBKCOLOR';
    EMR_OFFSETCLIPRGN: S := 'OFFSETCLIPRGN';
    EMR_MOVETOEX: S := 'MOVETOEX';
    EMR_SETMETARGN: S := 'SETMETARGN';
    EMR_EXCLUDECLIPRECT: S := 'EXCLUDECLIPRECT';
    EMR_INTERSECTCLIPRECT: S := 'INTERSECTCLIPRECT';
    EMR_SCALEVIEWPORTEXTEX: S := 'SCALEVIEWPORTEXTEX';
    EMR_SCALEWINDOWEXTEX: S := 'SCALEWINDOWEXTEX';
    EMR_SAVEDC: S := 'SAVEDC';
    EMR_RESTOREDC: S := 'RESTOREDC';
    EMR_SETWORLDTRANSFORM: S := 'SETWORLDTRANSFORM';
    EMR_MODIFYWORLDTRANSFORM: S := 'MODIFYWORLDTRANSFORM';
    EMR_SELECTOBJECT: S := 'SELECTOBJECT';
    EMR_CREATEPEN: S := 'CREATEPEN';
    EMR_CREATEBRUSHINDIRECT: S := 'CREATEBRUSHINDIRECT';
    EMR_DELETEOBJECT: S := 'DELETEOBJECT';
    EMR_ANGLEARC: S := 'ANGLEARC';
    EMR_ELLIPSE: S := 'ELLIPSE';
    EMR_RECTANGLE: S := 'RECTANGLE';
    EMR_ROUNDRECT: S := 'ROUNDRECT';
    EMR_ARC: S := 'ARC';
    EMR_CHORD: S := 'CHORD';
    EMR_PIE: S := 'PIE';
    EMR_SELECTPALETTE: S := 'SELECTPALETTE';
    EMR_CREATEPALETTE: S := 'CREATEPALETTE';
    EMR_SETPALETTEENTRIES: S := 'SETPALETTEENTRIES';
    EMR_RESIZEPALETTE: S := 'RESIZEPALETTE';
    EMR_REALIZEPALETTE: S := 'REALIZEPALETTE';
    EMR_EXTFLOODFILL: S := 'EXTFLOODFILL';
    EMR_LINETO: S := 'LINETO';
    EMR_ARCTO: S := 'ARCTO';
    EMR_POLYDRAW: S := 'POLYDRAW';
    EMR_SETARCDIRECTION: S := 'SETARCDIRECTION';
    EMR_SETMITERLIMIT: S := 'SETMITERLIMIT';
    EMR_BEGINPATH: S := 'BEGINPATH';
    EMR_ENDPATH: S := 'ENDPATH';
    EMR_CLOSEFIGURE: S := 'CLOSEFIGURE';
    EMR_FILLPATH: S := 'FILLPATH';
    EMR_STROKEANDFILLPATH: S := 'STROKEANDFILLPATH';
    EMR_STROKEPATH: S := 'STROKEPATH';
    EMR_FLATTENPATH: S := 'FLATTENPATH';
    EMR_WIDENPATH: S := 'WIDENPATH';
    EMR_SELECTCLIPPATH: S := 'SELECTCLIPPATH';
    EMR_ABORTPATH: S := 'ABORTPATH';
    EMR_GDICOMMENT: S := 'GDICOMMENT';
    EMR_FILLRGN: S := 'FILLRGN';
    EMR_FRAMERGN: S := 'FRAMERGN';
    EMR_INVERTRGN: S := 'INVERTRGN';
    EMR_PAINTRGN: S := 'PAINTRGN';
    EMR_EXTSELECTCLIPRGN: S := 'EXTSELECTCLIPRGN';
    EMR_BITBLT: S := 'BITBLT';
    EMR_STRETCHBLT: S := 'STRETCHBLT';
    EMR_MASKBLT: S := 'MASKBLT';
    EMR_PLGBLT: S := 'PLGBLT';
    EMR_SETDIBITSTODEVICE: S := 'SETDIBITSTODEVICE';
    EMR_STRETCHDIBITS: S := 'STRETCHDIBITS';
    EMR_EXTCREATEFONTINDIRECTW: S := 'EXTCREATEFONTINDIRECTW';
    EMR_EXTTEXTOUTA: S := 'EXTTEXTOUTA';
    EMR_EXTTEXTOUTW: S := 'EXTTEXTOUTW';
    EMR_POLYBEZIER16: S := 'POLYBEZIER16';
    EMR_POLYGON16: S := 'POLYGON16';
    EMR_POLYLINE16: S := 'POLYLINE16';
    EMR_POLYBEZIERTO16: S := 'POLYBEZIERTO16';
    EMR_POLYLINETO16: S := 'POLYLINETO16';
    EMR_POLYPOLYLINE16: S := 'POLYPOLYLINE16';
    EMR_POLYPOLYGON16: S := 'POLYPOLYGON16';
    EMR_POLYDRAW16: S := 'POLYDRAW16';
    EMR_CREATEMONOBRUSH: S := 'CREATEMONOBRUSH';
    EMR_CREATEDIBPATTERNBRUSHPT: S := 'CREATEDIBPATTERNBRUSHPT';
    EMR_EXTCREATEPEN: S := 'EXTCREATEPEN';
    EMR_POLYTEXTOUTA: S := 'POLYTEXTOUTA';
    EMR_POLYTEXTOUTW: S := 'POLYTEXTOUTW';
    EMR_SETICMMODE: S := 'SETICMMODE';
    EMR_CREATECOLORSPACE: S := 'CREATECOLORSPACE';
    EMR_SETCOLORSPACE: S := 'SETCOLORSPACE';
    EMR_DELETECOLORSPACE: S := 'DELETECOLORSPACE';
    EMR_GLSRECORD: S := 'GLSRECORD';
    EMR_GLSBOUNDEDRECORD: S := 'GLSBOUNDEDRECORD';
    EMR_PIXELFORMAT: S := 'PIXELFORMAT';
    EMR_DRAWESCAPE: S := 'DRAWESCAPE';
    EMR_EXTESCAPE: S := 'EXTESCAPE';
    EMR_STARTDOC: S := 'STARTDOC';
    EMR_SMALLTEXTOUT: S := 'SMALLTEXTOUT';
    EMR_FORCEUFIMAPPING: S := 'FORCEUFIMAPPING';
    EMR_NAMEDESCAPE: S := 'NAMEDESCAPE';
    EMR_COLORCORRECTPALETTE: S := 'COLORCORRECTPALETTE';
    EMR_SETICMPROFILEA: S := 'SETICMPROFILEA';
    EMR_SETICMPROFILEW: S := 'SETICMPROFILEW';
    EMR_ALPHABLEND: S := 'ALPHABLEND';
    EMR_ALPHADIBBLEND: S := 'ALPHADIBBLEND';
    EMR_TRANSPARENTBLT: S := 'TRANSPARENTBLT';
    EMR_TRANSPARENTDIB: S := 'TRANSPARENTDIB';
    EMR_GRADIENTFILL: S := 'GRADIENTFILL';
    EMR_SETLINKEDUFIS: S := 'SETLINKEDUFIS';
    EMR_SETTEXTJUSTIFICATION: S := 'SETTEXTJUSTIFICATION';
  end;
  NDW := ( Data^.nSize - 8 ) div 4;
  Pin := Pointer ( Data );
  Inc ( Pin );	   
  for i := 0 to NDW - 1 do
  begin
    Inc ( Pin );
    S := S + ' ' + IStr ( Pin^ );
    if i > 16 then
      Break;
  end;
  if Data^.iType = EMR_EXTTEXTOUTW then
    S := S + TXTStr;
  Debug.Add ( IStr ( CurRec ) + '   ' + S );
  if LastRecordInContents <> FContent.Count then
  begin
    Debug.Add ( '' );
    Debug.Add ( '-----------------------------------' );
    for i := LastRecordInContents to FContent.Count - 1 do
      Debug.Add ( '     ' + FContent [ i ] );
    Debug.Add ( '-----------------------------------' );
    Debug.Add ( '' );
    LastRecordInContents := FContent.Count;
  end;
end;
{$ENDIF}

procedure TEMWParser.ExecuteRecord ( Data: PEnhMetaRecord );
begin
  if InPath and ( Data^.iType in [ EMR_EXTTEXTOUTA, EMR_EXTTEXTOUTW, EMR_SMALLTEXTOUT ] ) then
    Exit;
  if InText then
    if not ( Data^.iType in
      [ EMR_EXTTEXTOUTA, EMR_EXTTEXTOUTW, EMR_SELECTOBJECT, EMR_BITBLT,
      EMR_CREATEBRUSHINDIRECT, EMR_CREATEPEN, EMR_SAVEDC, EMR_RESTOREDC,
        EMR_SETTEXTALIGN, EMR_SETBKMODE, EMR_EXTCREATEFONTINDIRECTW, EMR_SMALLTEXTOUT,
        EMR_DELETEOBJECT, EMR_SETTEXTCOLOR, EMR_MOVETOEX, EMR_SETBKCOLOR ] ) then
      InText := False;
  if ( Data^.iType in [ EMR_EXTTEXTOUTA, EMR_EXTTEXTOUTW, EMR_SMALLTEXTOUT ] ) then
    if not InText then
      InText := True;
  case Data^.iType of
    EMR_SETWINDOWEXTEX: DoSetWindowExtEx ( PEMRSetViewportExtEx ( Data ) );
    EMR_SETWINDOWORGEX: DoSetWindowOrgEx ( PEMRSetViewportOrgEx ( Data ) );
    EMR_SETVIEWPORTEXTEX: DoSetViewPortExtEx ( PEMRSetViewportExtEx ( Data ) );
    EMR_SETVIEWPORTORGEX: DoSetViewPortOrgEx ( PEMRSetViewportOrgEx ( Data ) );
    EMR_SCALEVIEWPORTEXTEX: DoScaleViewPortEx ( PEMRScaleViewportExtEx( Data ) );
    EMR_SCALEWINDOWEXTEX: DoScaleWindowEx( PEMRScaleWindowExtEx ( Data ) );
    EMR_SETMAPMODE: DoSetMapMode ( PEMRSetMapMode ( Data ) );
    EMR_POLYBEZIER: DoPolyBezier ( PEMRPolyline ( Data ) );
    EMR_POLYGON: DoPolygon ( PEMRPolyline ( Data ) );
    EMR_POLYLINE: DoPolyLine ( PEMRPolyline ( Data ) );
    EMR_POLYBEZIERTO: DoPolyBezierTo ( PEMRPolyline ( Data ) );
    EMR_POLYLINETO: DoPolyLineTo ( PEMRPolyline ( Data ) );
    EMR_POLYPOLYLINE: DoPolyPolyLine ( PEMRPolyPolyline ( Data ) );
    EMR_POLYPOLYGON: DoPolyPolyGon ( PEMRPolyPolyline ( Data ) );
    EMR_SETPIXELV: DoSetPixelV ( PEMRSetPixelV ( Data ) );
    EMR_SETBKMODE: DoSetBKMode ( PEMRSelectclippath ( Data ) );
    EMR_SETPOLYFILLMODE: DoSetPolyFillMode ( PEMRSelectclippath ( Data ) );
    EMR_SETTEXTALIGN: DoSetTextAlign ( PEMRSelectclippath ( Data ) );
    EMR_SETTEXTCOLOR: DoSetTextColor ( PEMRSetTextColor ( Data ) );
    EMR_SETBKCOLOR: DoSetBKColor ( PEMRSetTextColor ( Data ) );
    EMR_MOVETOEX: DoMoveToEx ( PEMRLineTo ( Data ) );
    EMR_INTERSECTCLIPRECT: DoInterSectClipRect ( PEMRIntersectClipRect ( Data ) );
    EMR_EXCLUDECLIPRECT: DoExcludeClipRect ( PEMRExcludeClipRect ( Data ) );
    EMR_EXTSELECTCLIPRGN: DoExtSelectClipRGN ( PEMRExtSelectClipRgn ( Data ) );
    EMR_SAVEDC: DoSaveDC;
    EMR_RESTOREDC: DoRestoreDC ( PEMRRestoreDC ( Data ) );
    EMR_SETWORLDTRANSFORM: DoSetWorldTransform ( PEMRSetWorldTransform ( Data ) );
    EMR_MODIFYWORLDTRANSFORM: DoModifyWorldTransform ( PEMRModifyWorldTransform ( Data ) );
    EMR_SELECTOBJECT: DoSelectObject ( PEMRSelectObject ( Data ) );
    EMR_CREATEPEN: DoCreatePen ( PEMRCreatePen ( Data ) );
    EMR_CREATEBRUSHINDIRECT: DoCreateBrushInDirect ( PEMRCreateBrushIndirect ( Data ) );
    EMR_CREATEDIBPATTERNBRUSHPT: DoCreateBrushBitmap ( PEMRCreateDibPatternbrushpt ( Data ) );
    EMR_DELETEOBJECT: DoDeleteObject ( PEMRDeleteObject ( Data ) );
    EMR_ANGLEARC: DoAngleArc ( PEMRAngleArc ( Data ) );
    EMR_ELLIPSE: DoEllipse ( PEMREllipse ( Data ) );
    EMR_RECTANGLE: DoRectangle ( PEMREllipse ( Data ) );
    EMR_ROUNDRECT: DoRoundRect ( PEMRRoundRect ( Data ) );
    EMR_FILLRGN: DoFillRGN ( PEMRFillRgn ( Data ) );
    EMR_ARC: DoArc ( PEMRArc ( Data ) );
    EMR_CHORD: DoChord ( PEMRChord ( Data ) );
    EMR_PIE: DoPie ( PEMRPie ( Data ) );
    EMR_LINETO: DoLineTo ( PEMRLineTo ( Data ) );
    EMR_ARCTO: DoArcTo ( PEMRArc ( Data ) );
    EMR_POLYDRAW: DoPolyDraw ( PEMRPolyDraw ( Data ) );
    EMR_SETARCDIRECTION: DoSetArcDirection ( PEMRSetArcDirection ( Data ) );
    EMR_SETMITERLIMIT: DoSetMiterLimit ( PEMRSetMiterLimit ( Data ) );
    EMR_BEGINPATH: DoBeginPath;
    EMR_ENDPATH: DoEndPath;
    EMR_CLOSEFIGURE: DoCloseFigure;
    EMR_FILLPATH: DoFillPath;
    EMR_STROKEANDFILLPATH: DoStrokeAndFillPath;
    EMR_STROKEPATH: DoStrokePath;
    EMR_SELECTCLIPPATH: DoSelectClipPath;
    EMR_ABORTPATH: DoAbortPath;
    EMR_SETDIBITSTODEVICE: DoSetDibitsToDevice ( PEMRSetDIBitsToDevice ( Data ) );
    EMR_STRETCHDIBITS: DoStretchDiBits ( PEMRStretchDiBits ( Data ) );
    EMR_EXTCREATEFONTINDIRECTW: DoCreateFontInDirectW ( PEMRExtCreateFontIndirect ( Data ) );
    EMR_EXTTEXTOUTA, EMR_EXTTEXTOUTW: DoExtTextOut ( PEMRExtTextOut ( Data ) );
    EMR_POLYBEZIER16: DoPolyBezier16 ( PEMRPolyline16 ( Data ) );
    EMR_POLYGON16: DoPolygon16 ( PEMRPolyline16 ( Data ) );
    EMR_POLYLINE16: DoPolyLine16 ( PEMRPolyline16 ( Data ) );
    EMR_POLYBEZIERTO16: DoPolyBezierTo16 ( PEMRPolyline16 ( Data ) );
    EMR_POLYLINETO16: DoPolyLineTo16 ( PEMRPolyline16 ( Data ) );
    EMR_POLYPOLYLINE16: DoPolyPolyLine16 ( PEMRPolyPolyline16 ( Data ) );
    EMR_POLYPOLYGON16: DoPolyPolygon16 ( PEMRPolyPolyline16 ( Data ) );
    EMR_POLYDRAW16: DoPolyDraw16 ( PEMRPolyDraw16 ( Data ) );
    EMR_EXTCREATEPEN: DoExtCreatePen ( PEMRExtCreatePen ( Data ) );
    EMR_SETTEXTJUSTIFICATION: DoSetTextJustification ( PEMRLineTo ( Data ) );
    EMR_BITBLT: DoBitBLT ( PEMRBitBlt ( Data ) );
    EMR_SETSTRETCHBLTMODE: DoSetStretchBltMode ( PEMRSetStretchBltMode ( Data ) );
    EMR_STRETCHBLT: DoStretchBlt ( PEMRStretchBlt ( Data ) );
    EMR_SMALLTEXTOUT: DoSmallTextOut ( PEMRSMALLTEXTOUTA ( Data ) );
    EMR_ALPHABLEND: DoAlphaBlend ( PEMRAlphaBlend ( Data ) );
    EMR_MASKBLT: DoMaskBlt ( PEMRMaskBlt ( Data ) );
    EMR_TRANSPARENTBLT: DoTransparentBLT ( PEMRTransparentBlt ( Data ) );
    EMR_SETROP2: DoSetROP2 ( PEMRSetROP2(Data));
  end;
end;



procedure TEMWParser.InitExecute;
var
  DC: HDC;
begin
  BGMode := True;
  PolyFIllMode := True;
  VertMode := vjUp;
  HorMode := hjLeft;
  UpdatePos := False;
  Clipping := False;
  FInPath := False;
  CCW := True;
  com := 72000 div MetaCanvas.Font.PixelsPerInch;
  CWPS.cx := 0;
  CWPS.cy := 0;
  CurRec := 0;
  XScale := 1;
  YScale := 1;
  FontScale := 1;
  Fcha := True;
  MapMode := 1;
  IsNullBrush := False;
  XOff := 0;
  YOff := 0;
  CurVal.X := 0;
  CurVal.Y := 0;
  VEX := 1;
  WEX := 1;
  VEY := 1;
  WEY := 1;
  VXNum := 1;
  VYNum := 1;
  VXDenom := 1;
  VYDenom := 1;
  WXNum := 1;
  WYNum := 1;
  WXDenom := 1;
  WYDenom := 1;
  ViewPortScaleUsed := False;
  WindowScaleUsed := False;
  CurFill := 0;
  DC := GetDC ( 0 );
  BGColor := GetBkColor ( DC );
  ReleaseDC ( 0, DC );
{$IFDEF CANVASDBG}
  LastRecordInContents := FContent.Count;
  CreateDir ( 'HDCDebug' );
//  MS.SaveToFile('HDCDebug\' + IntToStr(iii) + '.emf');
{$ENDIF}
  FEX := False;
end;


function TEMWParser.MapX ( Value: Extended ): Extended;
begin
  if WindowScaleUsed then
//     Value := ( Value * WXNum ) / WXDenom;
      Value := ( Value * WXDenom ) / WXNum;
  case MapMode of
    MM_ISOTROPIC:
        Result := ( ( Value - WOX ) * VEX / WEX ) + VOX;
    MM_ANISOTROPIC:
        Result := ( ( Value - WOX ) * VEX / WEX ) + VOX;
  //  MM_TWIPS:
    //    Result := 0;
  else
    Result := (Value-WOX) + VOX;
  end;
  if ViewPortScaleUsed then
    Result := ( Result * VXNum ) / VXDenom;
end;

function TEMWParser.MapY ( Value: Extended ): Extended;
begin
  if WindowScaleUsed then
    Value := ( Value * WYDenom ) / WYNum;
  case MapMode of
    MM_ISOTROPIC: Result := ( ( Value - WOY ) * VEY / WEY ) + VOY;
    MM_ANISOTROPIC: Result := ( ( Value - WOY ) * VEY / WEY ) + VOY;
  else
    Result := (Value-WOY) + VOY;
  end;
  if ViewPortScaleUsed then
    Result := ( Result * VYNum ) / VYDenom;
end;

function TEMWParser.FX: Extended;
begin
  if MapMode = 1 then
    Result := 1
  else
    Result := abs ( VEX / WEX );
end;

function TEMWParser.FY: Extended;
begin
  if MapMode = 1 then
    Result := 1
  else
    Result := abs ( VEY / WEY );
end;

procedure TEMWParser.DoExtSelectClipRGN ( Data: PEMRExtSelectClipRgn );
var
  RGNs: PRgnData;
  P: Pointer;
  I: Integer;
  RCT: TRect;
begin
  if ViewPortScaleUsed or WindowScaleUsed then
    Exit;
 // if ( Data^.iMode = RGN_COPY ) and ( Data^.cbRgnData = 0 ) then
   // Exit;

  if Clipping then
  begin
    Clipping := False;
    FCanvas.GStateRestore;
    FCanvas.SetLineWidth ( CalX * CPen.lopnWidth );
    SetPenColor;
    SetBrushColor ( False );
    FCha := True;
  end;
  if Data^.cbRgnData <> 0 then
  begin

    GetMem ( P, Data^.cbRgnData );
    try
      Move ( Data^.RgnData, P^, data^.cbRgnData );
      Rgns := P;
      if  RGNs^.rdh.nCount >0 then
      begin
        FCanvas.GStateSave;
        FCanvas.NewPath;
      end;
      RGNs := P;
      for I := 0 to RGNs^.rdh.nCount - 1 do
      begin
        Move ( Rgns^.Buffer [ I * SizeOf ( TRect ) ], RCT, SizeOf ( RCT ) );
        FCanvas.Rectangle ( GX ( RCT.Left, False ), GY ( RCT.Top, False ) ,
          GX ( RCT.Right, False ), GY ( RCT.Bottom, False ) )
      end;
      if  RGNs^.rdh.nCount >0 then
      begin
        FCanvas.Clip;
        FCanvas.NewPath;
        Clipping := True;
        isCR := False;
      end;
    finally
      FreeMem ( P );
    end;
  end;
end;

procedure TEMWParser.DoFillRGN ( Data: PEMRFillRgn );
var
  RGNs: PRgnData;
  P: Pointer;
  I: Integer;
  RCT: TRect;
  NBrush, BBrush: TLogBrush;
begin
  BBrush := CBrush;
  if ( Data^.ihBrush and $80000000 ) = 0 then
  begin
    if Data^.ihBrush >= HandlesCount then
      Exit;
    SelectObject ( DC, HandleTable [ Data^.ihBrush ] );
    I := GetObjectType ( HandleTable [ Data^.ihBrush ] );
    if I <> OBJ_BRUSH then
      Exit;
    IsNullBrush := False;
    GetObject ( HandleTable [ Data^.ihBrush ], SizeOf ( NBrush ), @NBrush );
    if NBrush.lbStyle = BS_HATCHED then
    begin
      NBrush.lbColor := BGColor;
    end;
    if NBrush.lbColor <> CBrush.lbColor then
    begin
      CBrush.lbColor := NBrush.lbColor;
    end;
    if NBrush.lbStyle = 1 then
      IsNullBrush := True;
  end else
  begin
    I := Data^.ihBrush and $7FFFFFFF;
    SelectObject ( DC, GetStockObject ( I ) );
    case I of
      WHITE_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := clWhite;
        end;
      LTGRAY_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := $AAAAAA;
        end;
      GRAY_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := $808080;
        end;
      DKGRAY_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := $666666;
        end;
      BLACK_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := 0;
        end;
      Null_BRUSH:
        begin
          CBrush.lbColor := clWhite;
          IsNullBrush := True;
        end;
      end;
  end;
  if Data^.cbRgnData <> 0 then
  begin
    GetMem ( P, Data^.cbRgnData );
    try
      FCanvas.NewPath;
      SetBrushColor;
      RGNs := P;
      Move ( Data^.RgnData, P^, data^.cbRgnData );
      for I := 0 to RGNs^.rdh.nCount - 1 do
      begin
        Move ( Rgns^.Buffer [ I * SizeOf ( TRect ) ], RCT, SizeOf ( RCT ) );
        FCanvas.Rectangle ( GX ( RCT.Left, True  ), GY ( RCT.Top, True ),
          GX ( RCT.Right, True ), GY ( RCT.Bottom, True ) );
      end;
      if not IsNullBrush then
        FCanvas.Fill;
      FCanvas.NewPath;
    finally
      FreeMem ( P );
    end;
  end;
  if BBrush.lbStyle = 1 then
    IsNullBrush := True;
  CBrush:= BBrush;
  SetBrushColor;
end;

procedure TEMWParser.DoSmallTextOut ( Data: PEMRSMALLTEXTOUTA );
var
  S: AnsiString;
  X, Y: Extended;
  RestoreClip: Boolean;
  D1: PEMRSMALLTEXTOUTClipA;
  SZ: TSize;
  YRotate : Integer;
begin
  RestoreClip := False;
  if Data^.nChars = 0 then
    Exit;
  FCanvas.SetCharacterSpacing ( 0 );
  if (VOY >0) and (VEY < 0 ) then
    YRotate := -1
  else
    YRotate := 1;
  if ( Data^.fOptions and SMALLTEXT_TYPE_IS_GLYPHS <> 0 ) then
  begin
    Y := Data^.ptlReference.y;
    case VertMode of
      vjCenter:
        begin
          Y := GY ( Y );
          FCanvas.TextFromBaseLine ( True );
        end;
      vjDown: Y := GY ( Y - MetaCanvas.TextHeight ( 'Wg' ) );
    else
      Y := GY ( Y );
    end;
    X := GX ( Data^.ptlReference.x );
    SetFontColor;
    SetCurFont;
    FCanvas.ExtGlyphTextOut ( X, Y, CFont.lfEscapement / 10 * YRotate ,
      @ ( Data^.cString ), Data^.nChars, nil );
    Exit;
  end;
  if ( Data^.fOptions and SMALLTEXT_TYPE_WITHOUT_CLIP = 0 ) then
  begin
    if Clipping then
    begin
      RestoreClip := True;
      FCanvas.GStateRestore;
    end;
    D1 := PEMRSMALLTEXTOUTClipA ( Data );
    FCanvas.GStateSave;
    FCanvas.NewPath;
    FCanvas.Rectangle ( GX ( D1^.rclClip.Left ), GY ( D1^.rclClip.Top ),
      GX ( D1^.rclClip.Right ), GY ( D1^.rclClip.Bottom ) );
    FCanvas.Clip;
    FCanvas.NewPath;
    Y := Data^.ptlReference.y;
    case VertMode of
      vjCenter:
        begin
          Y := GY ( Y );
          FCanvas.TextFromBaseLine ( True );
        end;
      vjDown: Y := GY ( Y - MetaCanvas.TextHeight ( 'Wg' ) );
    else
      Y := GY ( Y );
    end;
    SetFontColor;
    SetCurFont;
    if ( Data^.fOptions and SMALLTEXT_TYPE_ANSI <> 0 ) then
    begin
      SetLength ( S, d1^.nChars );
      Move ( D1^.cString, S [ 1 ], D1^.nChars );
      GetTextExtentPoint32A(DC,PANSIChar(S), D1^.nChars,SZ);
      case HorMode of
        hjRight: X :=GX ( Data^.ptlReference.x - SZ.cx );
        hjCenter: X :=GX ( Data^.ptlReference.x - SZ.cx/2 );
      else
        X := GX ( Data^.ptlReference.x );
      end;

{$IFNDEF CB}
      FCanvas.TextOut ( X, Y, CFont.lfEscapement / 10 * YRotate, S );
{$ELSE}
      FCanvas.TextOut ( X, Y, CFont.lfEscapement / 10 * YRotate, S );
{$ENDIF}
    end else
    begin
      GetTextExtentPoint32W(DC,@ ( D1^.cString ), D1^.nChars,SZ);
      case HorMode of
        hjRight: X :=GX ( Data^.ptlReference.x - SZ.cx );
        hjCenter: X :=GX ( Data^.ptlReference.x - SZ.cx/2 );
      else
        X := GX ( Data^.ptlReference.x );
      end;
      FCanvas.WideTextOut ( X, Y, CFont.lfEscapement / 10 * YRotate,makeWideString( @ ( D1^.cString ), D1^.nChars ));
    end;
    FCanvas.GStateRestore;
    FCha := True;
    if RestoreClip then
      if isCR then
      begin
        FCanvas.GStateSave;
        FCanvas.Rectangle ( ClipRect.Left, ClipRect.Top, ClipRect.Right, ClipRect.Bottom );
        FCanvas.Clip;
        FCanvas.NewPath;
      end else
        Clipping := False;
  end else
  begin
    Y := Data^.ptlReference.y;
    case VertMode of
      vjCenter:
        begin
          Y := GY ( Y );
          FCanvas.TextFromBaseLine ( True );
        end;
      vjDown: Y := GY ( Y - MetaCanvas.TextHeight ( 'Wg' ) );
    else
      Y := GY ( Y );
    end;
    SetFontColor;
    SetCurFont;
    if ( Data^.fOptions and SMALLTEXT_TYPE_ANSI <> 0 ) then
    begin
      SetLength ( S, data^.nChars );
      Move ( Data^.cString, S [ 1 ], Data^.nChars );
      GetTextExtentPoint32A(DC,PANSIChar(S), Data^.nChars,SZ);
      case HorMode of
        hjRight: X :=GX ( Data^.ptlReference.x - SZ.cx );
        hjCenter: X :=GX ( Data^.ptlReference.x - SZ.cx/2 );
      else
        X := GX ( Data^.ptlReference.x );
      end;
{$IFNDEF CB}
      FCanvas.TextOut ( X, Y, CFont.lfEscapement / 10 * YRotate, S );
{$ELSE}
      FCanvas.TextOut ( X, Y, CFont.lfEscapement / 10 * YRotate, S );
{$ENDIF}
    end else
    begin
       GetTextExtentPoint32W(DC,@ ( Data^.cString ), Data^.nChars,SZ);
      case HorMode of
        hjRight: X :=GX ( Data^.ptlReference.x - SZ.cx );
        hjCenter: X :=GX ( Data^.ptlReference.x - SZ.cx/2 );
      else
        X := GX ( Data^.ptlReference.x );
      end;
      FCanvas.WideTextOut ( X, Y, CFont.lfEscapement / 10* YRotate,makeWideString( @ ( Data^.cString ), Data^.nChars ));
    end;
  end;
end;

procedure TEMWParser.DoAlphaBlend ( Data: PEMRAlphaBlend );
var
  B, b1: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
  I: Integer;
  A: _BLENDFUNCTION;
  H: THandle;
  Err: Boolean;
  Func: function ( DC: HDC; p2, p3, p4, p5: Integer; DC6: HDC; p7, p8, p9,
    p10: Integer; p11: TBlendFunction ): BOOL; stdcall;
begin
  P := IP ( Data, Data^.offBmiSrc );
  O := IP ( Data, Data^.offBitsSrc );
  I := 0;
  if ( Data^.cySrc > 0 ) and ( Data^.cxSrc > 0 ) then
  begin
    B := TBitmap.Create;
    try
      B.Width := Data^.cxSrc;
      B.Height := Data^.cySrc;
      StretchDIBits ( B.Canvas.Handle, 0, 0, B.Width, B.Height, Data^.xSrc, Data^.ySrc,
        B.Width, B.Height, O, p^, Data^.iUsageSrc, SRCCOPY );
      Err := False;
      H := LoadLibrary ( 'msimg32.dll' );
      if H <> 0 then
      begin
        @Func := GetProcAddress ( H, 'AlphaBlend' );
        if Assigned ( @Func ) then
        begin
          b1 := TBitmap.Create;
          try
            b1.Width := B.Width;
            b1.Height := B.Height;
            Move ( Data^.dwRop, A, sizeof ( A ) );
            Func ( b1.Canvas.Handle, 0, 0, B.Width, B.Height, B.Canvas.Handle, 0, 0, B.Width, B.Height, A );
            I := AddBitmap(b1);
          finally
            b1.Free;
          end;
        end else
        begin
          Err := True;
        end;
      end else
      begin
        Err := True;
      end;
      if Err then
      begin
        I := AddBitmap( B);
      end;
      FCanvas.ShowImage ( I, GX ( Data^.rclBounds.Left, False ),
        GY ( Data^.rclBounds.Top, False ),
        GX ( Data^.rclBounds.Right - Data^.rclBounds.Left, False ),
        GY ( Data^.rclBounds.Bottom - Data^.rclBounds.Top, False ), 0 );
    finally
      B.Free;
    end;
  end
  else
  begin
    if ( data^.cxDest = 0 ) or ( data^.cyDest = 0 ) then
      FCanvas.NewPath
    else
    begin
      FCanvas.Rectangle ( gX ( data^.xDest ), gY ( Data^.yDest ),
        gX ( Data^.xDest + Data^.cxDest ), gY ( Data^.yDest + Data^.cyDest ) );
      FCanvas.Fill;
    end;
  end;
end;


procedure TEMWParser.DoMaskBlt ( Data: PEMRMaskBlt );
var
  it: Boolean;
  B: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
begin
  if InText then
  begin
    InText := False;
    it := True;
  end
  else
    it := False;
  P := IP ( Data, Data^.offBmiSrc );
  O := IP ( Data, Data^.offBitsSrc );
  B := TBitmap.Create;
  try
    if ( P^.bmiHeader.biBitCount = 1 ) then
          B.Monochrome := True;
    B.Width := Data^.cxDest;
    B.Height := Data^.cyDest;
    StretchDIBits ( B.Canvas.Handle, 0, 0, B.Width, B.Height, Data^.xSrc, Data^.ySrc,
      B.Width, B.Height, O, p^, Data^.iUsageSrc, Data^.dwRop );
    FCanvas.ShowImage ( AddBitmap(B), GX ( Data^.rclBounds.Left, False ), GY ( Data^.rclBounds.Top, False ),
      GX ( Data^.rclBounds.Right - Data^.rclBounds.Left + 1, False ), GY ( Data^.rclBounds.Bottom - Data^.rclBounds.Top + 1, False ), 0 );
  finally
    B.Free;
  end;
  if it then
    InText := True;
end;

function TEMWParser.AddBitmap ( BM: TBitmap ): Integer;
begin
  if BM.PixelFormat = pf1bit then
    Result := FImages.AddImage ( BM, itcCCITT4 )
  else if not FEMFOptions.ColorImagesAsJPEG then
    Result := FImages.AddImage ( BM, itcFlate )
  else
    Result := FImages.AddImage ( BM, itcJpeg );
end;
{$endif}
end.

