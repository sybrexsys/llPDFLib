{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFCanvas;

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
  llPDFMisc, llPDFFont, llPDFImage, llPDFEngine,
  llPDFTypes;

{$i pdf.inc}

type

  TStringType = (stASCII,stANSI,stNeedUnicode);

  /// <summary>
  ///   This class is for manipulating "extended graphical state".
  /// </summary>
  TPDFGState = class(TPDFObject)
  private
    FAlphaFill: Extended;
    FAlphaFillInited: Boolean;
    FAlphaStroke: Extended;
    FAlphaStrokeInited: Boolean;
    FLineCap: TPDFLineCap;
    FLineCapInited: Boolean;
    FLineJoin: TPDFLineJoin;
    FLineWidth: Extended;
    FMitterLimit: Extended;
    FLineJoinInited: Boolean;
    FLineWidthInited: Boolean;
    FMitterLimitInited: Boolean;
    procedure SetAlphaFill(const Value: Extended);
    procedure SetAlphaStroke(const Value: Extended);
    procedure SetLineCap(const Value: TPDFLineCap);
    procedure SetLineJoin(const Value: TPDFLineJoin);
    procedure SetLineWidth(const Value: Extended);
    procedure SetMitterLimit(const Value: Extended);
  protected
    procedure Save;override;
  public
    constructor Create( PDFEngine: TPDFEngine);
    /// <summary>
    ///The property that specifies the alpha channel that is used to fill closed areas.
    /// </summary>
    /// <remarks>
    ///   Values from 0 to 1
    /// </remarks>
    property AlphaFill: Extended write SetAlphaFill;
    /// <summary>
    ///   The property that specifies the alpha channel that is used to draw lines.
    /// </summary>
    /// <remarks>
    ///   Values from 0 to 1
    /// </remarks>
    property AlphaStroke: Extended write SetAlphaStroke;
    /// <summary>
    ///   Specifies design of line ends.
    /// </summary>
    property LineCap: TPDFLineCap write SetLineCap;
    /// <summary>
    ///   Specifies design of line joining. 
    /// </summary>
    property LineJoin: TPDFLineJoin write SetLineJoin;
    /// <summary>
    ///   Specifies the width of line.
    /// </summary>
    /// <remarks>
    ///   Value — positive number in pixels.
    /// </remarks>
    property LineWidth: Extended write SetLineWidth;
    /// <summary>
    ///   When joining the lines with the option miter, the ends of the lines are extended to a certain distance to join. 
    ///   This distance will be small for large angles and several-fold bigger for acute angles. <br />
    ///   Property miterLimit sets maximum distance for finishing drawing. If a bigger distance is necessary to join
    ///   lines, then they will be joined as bevel.
    /// </summary>
    property MitterLimit: Extended write SetMitterLimit;
  end;


  /// <summary>
  ///   Optional content refers to sub-clauses of content in a PDF document that can be selectively viewed or
  ///   hidden by document authors or consumers. This capability is useful in items such as CAD drawings,
  ///   layered artwork, maps, and multi-language documents. TOptionalContent is the class for working with this
  ///   functionality
  /// </summary>
  /// <example>
  ///   Class examples must be created with TPDFDocument.AppendOptionalContent
  /// </example>
  TOptionalContent = class(TPDFObject)
  private
    FCAN:Boolean;
    FName: AnsiString;
    FVisible: Boolean;
  protected
    procedure Save;override;
  public
    constructor Create( PDFEngine: TPDFEngine;Name:AnsiString;Visible,CanExchange:Boolean);
  end;


  TOptionalContents = class(TPDFListManager)
  protected
    procedure Save;override;
  public
  end;

  /// <summary>
  ///   This is the base class for appearance of the canvas to be displayed on a raster output device,
  /// </summary>
  TPDFCanvas = class(TPDFObject)
  private
    D2P: Extended;
    FActions: Boolean;
    FBaseLine: Boolean;
    FCharset: TFontCharset;
    FCharSpace: Extended;
    FCurrentDash: AnsiString;
    FCurrentFont: TPDFFont;
    FCurrentFontIndex: Integer;
    FCurrentFontName: String;
    FCurrentFontSize: Extended;
    FCurrentFontStyle: TFontStyles;
    FF: TTextCTM;
    FFontIsChanged: Boolean;
    FGrayUsed: Boolean;
    FColorUsed: Boolean;
    FRGBUsed: Boolean;
    FCMYKUsed: Boolean;
    FHeight: Integer;
    FHorizontalScaling: Extended;
    FLinkedFont: array of TPDFFont;
    FLinkedImages: array of TPDFImage;
    FLinkedExtGState: array of TPDFGState;
    FMatrix: TTextCTM;
    FMF: TMetafile;
    FPathInited: Boolean;
    FRealAngle: Extended;
    FRender: Integer;
    FRes: Integer;
    FRise: Extended;
    FSaveCount: Integer;
    FTextInited: Boolean;
    FTextLeading: Extended;
    FTextUsed: Boolean;
    FItalicEmulated: Boolean;

    FCurrentIndex:Integer;

    FWidth: Integer;
    FWordSpace: Extended;
    FX: Extended;
    FY: Extended;
    TP: TDoublePoint;
    FIsTrueType:Boolean;
    FStdFont: TPDFStdFont;
    FFonts: TPDFFonts;
    FFontScale: Extended;
// Work procedures
    function GetStringType(CheckStr:AnsiString): TStringType;
    procedure BeginText;
    procedure DrawArcWithBezier(CenterX, CenterY, RadiusX, RadiusY, StartAngle, SweepRange: Extended; UseMoveTo: Boolean);
    procedure EndText;
    procedure ExtGlyphTextShow(Text: PWord; Len: Integer; Dx: PExt);
    procedure ExtTextShow(TextStr: AnsiString; Dx: PExt);
    procedure ExtWideTextShow(Text: PWord; Len: Integer; Dx: PExt);
    function GetRawTextHeight: Extended;
    function IntToExtX(AX: Extended): Extended;
    function IntToExtY(AY: Extended): Extended;
    procedure PaintTextLines(Width: Extended);
    function RawArc(X1, Y1, x2, y2, BegAngle,  EndAngle: Extended): TDoublePoint; overload;
    function RawArc(X1, Y1, x2, y2, x3, y3, x4, y4: Extended): TDoublePoint; overload;
    procedure RawCircle(X, Y, R: Extended);
    procedure RawConcat(A, B, C, D, E, F: Extended);
    procedure RawCurveto(X1, Y1, X2, Y2, X3, Y3: Extended);
    procedure RawEllipse(x1, y1, x2, y2: Extended);
    procedure RawExtGlyphTextOut(X, Y, Orientation: Extended; Text: PWord; Len: Integer; DX: PExt);
    procedure RawExtTextOut(X, Y, Orientation: Extended; TextStr: AnsiString; Dx:PExt);
    procedure RawExtWideTextOut(X, Y, Orientation: Extended; Text: PWord; Len: Integer; DX: PExt);
    function RawGetTextWidth(Text: AnsiString): Extended;
    function RawGetWideWidth(WideText: WideString): Extended;
    procedure RawLineTo(X, Y: Extended);
    procedure RawMoveTo(X, Y: Extended);
    function RawPie(X1, Y1, x2, y2, BegAngle, EndAngle: Extended): TDoublePoint; overload;
    function RawPie(X1, Y1, x2, y2, x3, y3, x4, y4: Extended): TDoublePoint; overload;
    procedure RawRect(X, Y, W, H: Extended);
    procedure RawRectRotated(X, Y, W, H, Angle: Extended);
    procedure RawSetTextPosition(X, Y, Orientation: Extended);
    procedure RawShowImage(ImageIndex: Integer; X, Y, W, H, Angle: Extended);
    procedure RawTextOut(X, Y, Orientation: Extended; TextStr: AnsiString);
    procedure RawTranslate(XT, YT: Extended);
    procedure RawWideTextOut(X, Y, Orientation: Extended; WideText: WideString);
    procedure SetHeight(const Value: Integer);virtual;
    procedure SetIntCharacterSpacing(Spacing: Extended);
    procedure SetWidth(const Value: Integer);virtual;
    procedure TextShow(TextStr: AnsiString);
    procedure WideTextShow(WideText: WideString);
    function GetHeight: Integer;
    function GetWidth: Integer;

  protected
    FContent: TAnsiStringList;
    FBCDStart: Boolean;
    function ReceiveFont: TPDFFont;
  public
    constructor Create(Engine:TPDFEngine; FontManager:TPDFFonts);
    destructor Destroy; override;
    function ExtToIntX(AX: Extended): Extended;
    function ExtToIntY(AY: Extended): Extended;
    /// <summary>
    ///   The function is used to write to any content whatsoever operators specified by the parameter
    ///   Action
    /// </summary>
    /// <param name="Action">
    ///   line to be added to canvas content
    /// </param>
    procedure AppendAction(Action: AnsiString);
    /// <summary>
    ///   Draws an arc defined by a bounding rectangle and by the start and end angles of the arc
    /// </summary>
    /// <param name="X1">
    ///   X coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="Y1">
    ///   Y coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="X2">
    ///   X coordinate of the lower right corner of the bounding rectangle
    /// </param>
    /// <param name="Y2">
    ///   Y coordinate of the lower right corner of the bounding rectangle
    /// </param>
    /// <param name="BegAngle">
    ///   The starting angle of the arc drawing
    /// </param>
    /// <param name="EndAngle">
    ///   The ending angle of the arc drawing
    /// </param>
    /// <returns>
    ///   Returns the endpoint of the arc
    /// </returns>
    function Arc(X1, Y1, X2, Y2, BegAngle, EndAngle: Extended): TDoublePoint; overload;
    /// <summary>
    ///   Draws an arc defined by a bounding rectangle and two points on the ellipse. The points on the ellipse 
    ///  defined by the intersection of the lines extending from the center of the ellipse to the points at the coordinates (X3, Y3) and (X4, Y4)
    /// </summary>
    /// <param name="X1">
    ///   X coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="Y1">
    ///   Y coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="X2">
    ///   X coordinate of the lower right corner of the bounding rectangle
    /// </param>
    /// <param name="Y2">
    ///   Y coordinate of the lower right corner of the bounding rectangle
    /// </param>
    /// <param name="X3">
    ///   X coordinate of the point, which determines the starting point of drawing
    /// </param>
    /// <param name="Y3">
    ///   Y coordinate of the point, which determines the starting point of drawing
    /// </param>
    /// <param name="X4">
    ///   X coordinate of the point, which determines the ending point of drawing
    /// </param>
    /// <param name="Y4">
    ///   Y coordinate of the point, which determines the ending point of drawing
    /// </param>
    function Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Extended): TDoublePoint; overload;
    /// <summary>
    ///   Draws a circle
    /// </summary>
    /// <param name="X">
    ///   X coordinate of the center of the circle
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the center of the circle
    /// </param>
    /// <param name="R">
    ///   The value of the radius of the circle
    /// </param>
    procedure Circle(X, Y, R: Extended);
    /// <summary>
    ///   This procedure install the current paths as the boundary for clipping subsequent drawing. The use
    ///   of the clip operator may require some care, because clip and eoclip operators do not consume the
    ///   current path.
    /// </summary>
    /// <remarks>
    ///   No practical way of removing a clipping path, except by "GStateRestore "-ing a graphical state
    ///   before clipping is imposed.
    /// </remarks>
    procedure Clip;
    /// <summary>
    ///   This closes a path by connecting the first and the last point in the path currently being
    ///   constructed. Call to this procedure is often needed to avoid a notch in a stroked path, and to make
    ///   "line join" work correctly in joining the first and the last points.
    /// </summary>
    procedure ClosePath;
    /// <summary>
    ///   Add a commentary to the canvas content
    /// </summary>
    procedure Comment(st: AnsiString);
    /// <summary>
    ///   This procedure adds a Bezier cubic curve segment to the path starting at the current point as (x0,
    ///   y0), using two points (x1,y1) and (x2, y2) as control points, and terminating at point (x3, y3).
    ///   The new current point will be (x3, y3). If there is no current point, an error will result.
    /// </summary>
    /// <param name="X1">
    ///   X coordinate of the first control point
    /// </param>
    /// <param name="Y1">
    ///   Y coordinate of the first control point
    /// </param>
    /// <param name="X2">
    ///   X coordinate of the second control point
    /// </param>
    /// <param name="Y2">
    ///   Y coordinate of the second control point
    /// </param>
    /// <param name="X3">
    ///   X coordinate of the ending point
    /// </param>
    /// <param name="Y3">
    ///   Y coordinate of the ending point
    /// </param>
    procedure Curveto(X1, Y1, X2, Y2, X3, Y3: Extended);
    /// <summary>
    ///   This procedure create an ellipse path specified by top left point at pixel coordinates (X1, Y1) and
    ///   the bottom right point at (X2, Y2) in the counter-clock-wise direction. If you need a ellipse drawn
    ///   in the clock-wise direction, please use Arc page 38)(x1, y1, x2,y2, 360.0); ClosePath; This
    ///   function performs a move to angle 0 (right edge) of the circle. Current point will also be at the
    ///   same location after the call.
    /// </summary>
    /// <param name="X1">
    ///   X coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="Y1">
    ///   Y coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="X2">
    ///   X coordinate of the lower right corner of the bounding rectangle
    /// </param>
    /// <param name="Y2">
    ///   Y coordinate of the lower right corner of the bounding rectangle
    /// </param>
    procedure Ellipse(X1, Y1, X2, Y2: Extended);
    /// <summary>
    ///   This procedure installs the current paths as the boundary for clipping subsequent drawing and uses
    ///   the "even-odd" rule for defining the "inside" that shows through the clipping window. The use of
    ///   the clip operator may require some care, because clip and eoclip operators do not consume the
    ///   current path. Also note that there is no practical way of removing a clipping path, except for by
    ///   "GStateRestore "-ing a graphical state before clipping is imposed.
    /// </summary>
    /// <example>
    ///   with MyPDF.CurrentPage do <br />begin <br />GStateSave; <br />NewPath; <br />Rectangle( x,
    ///   y,x+width,y+height); <br />Clip; <br />NewPath; <br />GStateRestore; <br />end;
    /// </example>
    procedure EoClip;
    /// <summary>
    ///   This procedure uses the current path as the boundary for color filling and uses the "evenodd" rule
    ///   for defining an "inside" that is painted.
    /// </summary>
    procedure EoFill;
    /// <summary>
    ///   This function is used to first fill the inside with the current fill color, and then stroking the
    ///   path with the current stroke color. PDF's graphics state maintains separate colors for fill and
    ///   stroke operations, thus these combined operators are made available.
    /// </summary>
    procedure EoFillAndStroke;

    /// <summary>
    ///   The function displays the text using glyphs that are in the font
    /// </summary>
    /// <param name="X">
    ///   X coordinate from which  to display text
    /// </param>
    /// <param name="Y">
    ///   Y coordinate from which  to display text
    /// </param>
    /// <param name="Orientation">
    ///   Orientation of the text
    /// </param>
    /// <param name="Text">
    ///   a variable points to an array WORD, where every word is the code for the glyph in the font, which is necessary 
    ///   to display
    /// </param>
    /// <param name="Len">
    ///   Length of text array
    /// </param>
    /// <param name="DX">
    ///   A pointer to an array Extended, where each element is the distance between glyphs.
    /// </param>
    procedure ExtGlyphTextOut(X, Y, Orientation: Extended; Text: PWord; Len: Integer; DX: PExt);
    /// <summary>
    ///   This procedure uses the current path as the boundary for color filling and uses the "non-zero
    ///   winding number" rule.
    /// </summary>
    procedure Fill;
    /// <summary>
    ///   This function is used to first fill the inside with the current fill color, and then stroking the
    ///   path with the current stroke ñolor. PDF's graphics state maintains separate colors for fill and
    ///   stroke operations, thus these combined operators are made available.
    /// </summary>
    procedure FillAndStroke;
    /// <summary>
    ///   Return size of the current font in points.
    /// </summary>
    function GetCurrentFontSize: Extended;
    /// <summary>
    ///   A well-structured PDF document typically contains many graphical elements that are essentially
    ///   independent of each other and sometimes nested to multiple levels. The graphics state stack allows
    ///   these elements to make local changes to the graphics state without disturbing the graphics state of
    ///   the surrounding environment. <br />This procedure restores the entire graphics state to its former
    ///   value by popping it from the stack.
    /// </summary>
    procedure GStateRestore;
    /// <summary>
    ///   A well-structured PDF document typically contains many graphical elements that are essentially
    ///   independent of each other and sometimes nested to multiple levels. The graphics state stack allows
    ///   these elements to make local changes to the graphics state without disturbing the graphics state of
    ///   the surrounding environment. <br />This procedure pushes a copy of the entire graphics state onto
    ///   the stack.
    /// </summary>
    procedure GStateSave;
    /// <summary>
    ///   This procedure adds a line segment to the path, starting at the current point and ending at point
    ///   (x, y). Current point set to (x,y).
    /// </summary>
    /// <param name="X">
    ///   X coordinate of the ending point of the line
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the ending point of the line
    /// </param>
    procedure LineTo(X, Y: Extended);
    /// <summary>
    ///   This procedure moves the current point to the location specified by (x, y).
    /// </summary>
    /// <param name="X">
    ///   X coordinate where to move the next point
    /// </param>
    /// <param name="Y">
    ///   Y coordinate where to move the next point
    /// </param>
    procedure MoveTo(X, Y: Extended);
    /// <summary>
    ///   Clears the current path. Current point becomes undefined.
    /// </summary>
    procedure NewPath;
    /// <summary>
    ///   This procedure resets the dash pattern back to none, i.e., solid line.
    /// </summary>
    procedure NoDash;
    /// <summary>
    ///   Use Pie to append a pie-shaped wedge on the path. The wedge is defined by the ellipse bounded by
    ///   the rectangle determined by the points (X1, Y1) and X2, Y2). The section drawn is determined by
    ///   BegAngle and EndAngle, specified in degrees. <br />Current point is center of the wedge.
    /// </summary>
    /// <param name="X1">
    ///   X coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="Y1">
    ///   Y coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="X2">
    ///   X coordinate of the lower right corner of the bounding rectangle
    /// </param>
    /// <param name="Y2">
    ///   Y coordinate of the lower right corner of the bounding rectangle
    /// </param>
    /// <param name="BegAngle">
    ///   The starting angle of the arc drawing
    /// </param>
    /// <param name="EndAngle">
    ///   The ending angle of the arc drawing
    /// </param>
    procedure Pie(X1, Y1, X2, Y2, BegAngle, EndAngle: Extended); overload;
    /// <summary>
    ///   Use Pie to append a pie-shaped wedge on the path. The wedge is defined by the ellipse bounded by
    ///   the rectangle determined by the points (X1, Y1) and X2, Y2). The section drawn is determined by two
    ///   lines radiating from the center of the ellipse through the points (X3, Y3) and (X4, Y4) <br />
    ///   Current point is center of the wedge.
    /// </summary>
    /// <param name="X1">
    ///   X coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="Y1">
    ///   Y coordinate of the upper-left corner of the bounding rectangle
    /// </param>
    /// <param name="X2">
    ///   X coordinate of the lower right corner of the bounding rectangle
    /// </param>
    /// <param name="Y2">
    ///   Y coordinate of the lower right corner of the bounding rectangle
    /// </param>
    /// <param name="X3">
    ///   X coordinate of a point defining the starting point of drawing
    /// </param>
    /// <param name="Y3">
    ///   Y coordinate of a point defining the starting point of drawing
    /// </param>
    /// <param name="X4">
    ///   X coordinate of a point defining the ending point of drawing
    /// </param>
    /// <param name="Y4">
    ///   Y coordinate of a point defining the ending point of drawing
    /// </param>
    procedure Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Extended); overload;
    /// <summary>
    ///   This function draws a rectangle with one corner at (x1, y1) and second at (x2,y2).
    /// </summary>
    /// <param name="X1">
    ///   X coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="Y1">
    ///   Y coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="X2">
    ///   X coordinate of the lower right corner of the rectangle
    /// </param>
    /// <param name="Y2">
    ///   Y coordinate of the lower right corner of the rectangle
    /// </param>
    procedure Rectangle(X1, Y1, X2, Y2: Extended);
    /// <summary>
    ///   This function draws a rectangle of size (w, h) with one corner at (x,y), with an orientation
    ///   argument, angle, specified in degrees.
    /// </summary>
    /// <param name="X">
    ///   X coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="W">
    ///   Width of the rectangle
    /// </param>
    /// <param name="H">
    ///   Height of the rectangle
    /// </param>
    /// <param name="Angle">
    ///   rotation angle of the rectangle
    /// </param>
    procedure RectRotated(X, Y, W, H, Angle: Extended);
    /// <summary>
    ///   This procedure rotates the coordinate system by the angle given in degrees (positive is clock
    ///   wise).
    /// </summary>
    procedure Rotate(Angle: Extended);
    /// <summary>
    ///   Add a rectangle with rounded corners to path. The rectangle will have edges defined by the points
    ///   (X1,Y1), (X2,Y1), (X2,Y2), (X1,Y2), but the corners will be shaved to create a rounded appearance.
    ///   The curve of the rounded corners matches the curvature of an ellipse with width X3 and height Y3
    /// </summary>
    /// <param name="X1">
    ///   X coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="Y1">
    ///   Y coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="X2">
    ///   X coordinate of the lower right corner of the rectangle
    /// </param>
    /// <param name="Y2">
    ///   Y coordinate of the lower right corner of the rectangle
    /// </param>
    /// <param name="W">
    ///   The width of the ellipse, with respect to which the arc is calculated  
    /// </param>
    /// <param name="H">
    ///   The width of the ellipse, with respect to which the arc is calculated  
    /// </param>
    procedure RoundRect(X1, Y1, X2, Y2, W, H: Integer);
    /// <summary>
    ///   This procedure scales the coordinate system by scaling factors supplied for X and Y dimensions
    /// </summary>
    /// <param name="SX">
    ///   Scaling factor supplied for X dimension
    /// </param>
    /// <param name="SY">
    ///   Scaling factor supplied for Y dimension
    /// </param>
    procedure Scale(SX, SY: Extended);
    /// <summary>
    ///   This procedure sets the active truetype font for text operations. <br />llPDFLib emulates
    ///   fsUnderLine and fsStrikeOut style. If the font does not have fsBold or fsItalic style then llPDFLib
    ///   will emulate it as well.
    /// </summary>
    /// <param name="FontName">
    ///   Name of the truetype font
    /// </param>
    /// <param name="FontStyle">
    ///   Style of the font
    /// </param>
    /// <param name="FontSize">
    ///   Size of the font
    /// </param>
    /// <param name="FontCharset">
    ///   Charset, for ansi strings
    /// </param>
    procedure SetActiveFont(FontName: String; FontStyle: TFontStyles; FontSize:
        Extended; FontCharset: TFontCharset = ANSI_CHARSET); overload;
    /// <summary>
    ///   This procedure sets the active standard Type1 font for text operations. <br />
    /// </summary>
    /// <param name="StdFont">
    ///   Standard Type1 font
    /// </param>
    /// <param name="FontSize">
    ///   Size of the font
    /// </param>
    procedure SetActiveFont(StdFont:TPDFStdFont; FontSize: Extended); overload;
    /// <summary>
    ///   This procedure sets the additional space (in points) that should be inserted between characters.
    /// </summary>
    /// <param name="Spacing">
    ///   Additional space (in points)
    /// </param>
    procedure SetCharacterSpacing(Spacing: Extended);
    procedure SetCurrentFont(Index: Integer);

    /// <summary>
    ///   The line dash pattern controls the pattern of dashes and gaps used to stroke paths. Before
    ///   beginning to stroke a path, the dash array is cycled through, adding up the lengths of dashes and
    ///   gaps. When the accumulated length equals the value specified by the dash phase, stroking of the
    ///   path begins, using the dash array cyclically from that point onward.
    /// </summary>
    /// <param name="DashSpec">
    ///   Line dash pattern
    /// </param>
    procedure SetDash(DashSpec: AnsiString);
    /// <summary>
    ///   The flatness tolerance controls the maximum permitted distance in device pixels between the
    ///   mathematically correct path and an approximation constructed from straight line segments.
    /// </summary>
    /// <param name="FlatNess">
    ///   The flatness tolerance
    /// </param>
    procedure SetFlat(FlatNess: integer);
    /// <summary>
    ///   This procedure sets the horizontal scaling factor in a percentage. This essentially expands or
    ///   compresses the horizontal dimension of the string. The default value for this parameter is 100 (%).
    /// </summary>
    /// <param name="Scale">
    ///   Horizontal scaling factor in a percentage
    /// </param>
    procedure SetHorizontalScaling(Scale: Extended);
    /// <summary>
    ///   The line cap style specifies the shape to be used at the ends of open subpaths (and dashes, if any)
    ///   when they are stroked.
    /// </summary>
    /// <param name="LineCap">
    ///   line cap style
    /// </param>
    procedure SetLineCap(LineCap: TPDFLineCap);
    /// <summary>
    ///   The line join style specifies the shape to be used at the corners of paths that are stroked.
    /// </summary>
    /// <param name="LineJoin">
    ///   line join style
    /// </param>
    procedure SetLineJoin(LineJoin: TPDFLineJoin);
    /// <summary>
    ///   This procedure sets the current linewidth to the value specified in points
    /// </summary>
    /// <param name="lw">
    ///   New line width
    /// </param>
    procedure SetLineWidth(lw: Extended);

    /// <summary>
    ///   Parameter miterLimit sets maximum distance for "finishing drawing".
    /// </summary>
    /// <param name="MiterLimit">
    ///   Finishing drawing limit
    /// </param>
    procedure SetMiterLimit(MiterLimit: Extended);
    /// <summary>
    ///   Sets the color offill of closed areas.
    /// </summary>
    /// <param name="Color">
    ///   Color of the fill
    /// </param>
    procedure SetColorFill(Color:TPDFColor);
    /// <summary>
    ///   Sets the color of lines and curves
    /// </summary>
    /// <param name="Color">
    ///   The color of lines and curves
    /// </param>
    procedure SetColorStroke(Color: TPDFColor);
    /// <summary>
    ///   Sets the color of the fill for closed areas and the color of lines
    /// </summary>
    /// <param name="Color">
    ///   Color of the fill and lines 
    /// </param>
    procedure SetColor(Color:TPDFColor);
    /// <summary>
    ///   Specifies anew extended graphical state.
    /// </summary>
    /// <param name="State">
    ///   Object that specifies new graphical state
    /// </param>
    procedure SetExtGState(State: TPDFGState);
    /// <summary>
    ///   This procedure sets the mode that determines how the character outline is used. By default, the
    ///   character outline is used for filling operations by which inside of the outline path is painted
    ///   solidly with the current fill color. This may be <br />changed by calling this function.
    /// </summary>
    /// <param name="Mode">
    ///   Rendering mode
    /// </param>
    /// <remarks>
    ///   Mode Description <br />0 Fill text. <br />1 Stroke text. <br />2 Fill, then stroke, text. <br />3
    ///   Neither fill nor stroke text (invisible). <br />4 Fill text and add to path for clipping. <br />5
    ///   Stroke text and add to path for clipping. <br />6 Fill, then stroke, text and add to path for
    ///   clipping. <br />7 Add text to path for clipping.
    /// </remarks>
    procedure SetTextRenderingMode(Mode: integer);
    /// <summary>
    ///   This procedure sets the additional space (in points) that should be inserted between words, i.e.,
    ///   for every space character found in the text string.
    /// </summary>
    /// <param name="Spacing">
    ///   Additional space (in points)
    /// </param>
    procedure SetWordSpacing(Spacing: Extended);

    /// <summary>
    ///   Changes the current font size
    /// </summary>
    /// <param name="Scale">
    ///   New size
    /// </param>
    procedure SetFontWidthScale(Scale: Extended);
    /// <summary>
    ///   Displays the image on canvas
    /// </summary>
    /// <param name="ImageIndex">
    ///   Image index in the generated image
    /// </param>
    /// <param name="X">
    ///   X coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the upper left corner of the rectangle
    /// </param>
    procedure ShowImage(ImageIndex: Integer; X, Y: Extended); overload;
    /// <summary>
    ///   Displays the image on canvas
    /// </summary>
    /// <param name="ImageIndex">
    ///   Image index in the generated image
    /// </param>
    /// <param name="X">
    ///   X coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="ScaleX">
    ///   Scale of image compression across the width
    /// </param>
    /// <param name="ScaleY">
    ///   Scale of image compression along the height
    /// </param>
    procedure ShowImage(ImageIndex: Integer; X, Y, ScaleX,ScaleY: Extended); overload;
    /// <summary>
    ///   Displays the image on canvas
    /// </summary>
    /// <param name="ImageIndex">
    ///   Image index in the generated image
    /// </param>
    /// <param name="X">
    ///   X coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="W">
    ///   Width of the image
    /// </param>
    /// <param name="H">
    ///   Height of the image 
    /// </param>
    /// <param name="Angle">
    ///   Image rotation angle
    /// </param>
    procedure ShowImage(ImageIndex: Integer; X, Y, W, H, Angle: Extended);overload;
    /// <summary>
    ///   This function strokes the current paths by the current stroke color and current linewidth.
    /// </summary>
    procedure Stroke;
    /// <summary>
    ///   Specifies the rendering of the text relative to the baseline of the front or with respect to the top line of the  the font
    /// </summary>
    /// <param name="BaseLine">
    ///   Rendering parameter
    /// </param>
    procedure TextFromBaseLine(BaseLine: Boolean);
    /// <summary>
    ///   This procedure shifts the origin of the coordinate system by the (xt, yt) specified.
    /// </summary>
    /// <param name="XT">
    ///   X coordinate shift
    /// </param>
    /// <param name="YT">
    ///   Y coordinate shift
    /// </param>
    procedure Translate(XT, YT: Extended);
    /// <summary>
    ///   Displaying a line of text within the rectangle setting horizontal and vertical alignment
    /// </summary>
    /// <param name="Rect">
    ///   Rectangle, with respect to which the text will be displayed
    /// </param>
    /// <param name="Text">
    ///   Text to be displayed
    /// </param>
    /// <param name="Hor">
    ///   Horizontal alignment
    /// </param>
    /// <param name="Vert">
    ///   Vertical alignment
    /// </param>
    procedure TextBox(Rect: TRect; Text: AnsiString; Hor: THorJust; Vert: TVertJust);
    /// <summary>
    ///   Multi-line text display within the rectangle.
    /// </summary>
    /// <param name="LTCornX">
    ///   X coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="LTCornY">
    ///   Y coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="Interval">
    ///   String interval
    /// </param>
    /// <param name="BoxWidth">
    ///   Width of the rectangle
    /// </param>
    /// <param name="BoxHeight">
    ///   Height of the rectangle
    /// </param>
    /// <param name="TextStr">
    ///   Text string to output
    /// </param>
    /// <param name="Align">
    ///   Text string horizontal alignment
    /// </param>
    /// <returns>
    ///   Returns the number of the characters of the text that are managed to put in the given size of the rectangle
    /// </returns>
    function TextOutBox(LTCornX, LTCornY, Interval, BoxWidth, BoxHeight:integer; TextStr: String;Align:THorJust = hjLeft): Integer;{$ifdef UNICODE} overload; {$endif}
    /// <summary>
    ///   Text string output
    /// </summary>
    /// <param name="X">
    ///   X coordinate of the beginning point of text output 
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the beginning point of text output
    /// </param>
    /// <param name="Orientation">
    ///   Text orientation
    /// </param>
    /// <param name="TextStr">
    ///   Text string to output
    /// </param>
    procedure TextOut(X, Y, Orientation: Extended; TextStr: String); {$ifdef UNICODE} overload; {$endif}
    /// <summary>
    ///   Returns the number of lines required to output multiline text within a limited
    ///   width.
    /// </summary>
    /// <param name="BoxWidth">
    ///   Text width
    /// </param>
    /// <param name="TextStr">
    ///   Text string
    /// </param>
    function GetTextRowCount(BoxWidth: Integer; TextStr: String): Integer; {$ifdef UNICODE} overload; {$endif}
    /// <summary>
    ///   Returns the width, necessary to output this text
    /// </summary>
    function GetTextWidth(Text: String): Extended; {$ifdef UNICODE} overload; {$endif}
    /// <summary>
    ///   Extended output of text string
    /// </summary>
    /// <param name="X">
    ///   X coordinate of the beginning point of text output
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the beginning point of text output
    /// </param>
    /// <param name="Orientation">
    ///   Text orientation
    /// </param>
    /// <param name="TextStr">
    ///   Text string to output
    /// </param>
    /// <param name="Dx">
    ///   Pointer to Extended array, where each element is the distance between symbols.
    /// </param>
    procedure ExtTextOut(X, Y, Orientation: Extended; TextStr: String; Dx: PExt); {$ifdef UNICODE} overload; {$endif}
{$ifdef UNICODE}
    function TextOutBox(LTCornX, LTCornY, Interval, BoxWidth, BoxHeight:integer; TextStr: AnsiString;Align:THorJust = hjLeft): Integer; overload;
    procedure TextOut(X, Y, Orientation: Extended; TextStr: AnsiString);overload;
    function GetTextRowCount(BoxWidth: Integer; TextStr: AnsiString): Integer;overload;
    function GetTextWidth(Text: AnsiString): Extended;overload;
    procedure ExtTextOut(X, Y, Orientation: Extended; TextStr: AnsiString; Dx: PExt);overload;
{$endif}
    /// <summary>
    ///   unicode text string output
    /// </summary>
    /// <param name="X">
    ///   X coordinate of the beginning point of text output
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the beginning point of text output
    /// </param>
    /// <param name="Orientation">
    ///   Text orientation
    /// </param>
    /// <param name="WideText">
    ///   Text string to output
    /// </param>
    procedure WideTextOut(X, Y, Orientation: Extended; WideText:WideString);
    /// <summary>
    ///   Output of multiline unicode text within the rectangle.
    /// </summary>
    /// <param name="LTCornX">
    ///   X coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="LTCornY">
    ///   Y coordinate of the upper left corner of the rectangle
    /// </param>
    /// <param name="Interval">
    ///   String interval
    /// </param>
    /// <param name="BoxWidth">
    ///   Width of the rectangle
    /// </param>
    /// <param name="BoxHeight">
    ///   Height of the rectangle
    /// </param>
    /// <param name="WideText">
    ///   Text string to output
    /// </param>
    /// <returns>
    ///   Returns the number of the characters of the text that are managed to put in the given size of the rectangle
    /// </returns>
    function WideTextOutBox(LTCornX, LTCornY, Interval, BoxWidth, BoxHeight: integer; WideText:WideString): Integer;
    /// <summary>
    ///   Extended output of unicode text string
    /// </summary>
    /// <param name="X">
    ///   X coordinate of the beginning point of text output
    /// </param>
    /// <param name="Y">
    ///   Y coordinate of the beginning point of text output
    /// </param>
    /// <param name="Orientation">
    ///   Text orientation
    /// </param>
    /// <param name="WideText">
    ///   Text string to output
    /// </param>
    /// <param name="DX">
    ///   Pointer to Extended array, where each element is the distance between symbols.
    /// </param>
    procedure ExtWideTextOut(X, Y, Orientation: Extended; WideText:WideString; DX: PExt);
    /// <summary>
    ///   Returns the number of lines required to output multiline unicode text within a limited
    ///   width.
    /// </summary>
    /// <param name="BoxWidth">
    ///   Width of the text
    /// </param>
    /// <param name="WideText">
    ///   Text string
    /// </param>
    function GetWideTextRowCount(BoxWidth: Integer; WideText:WideString): Integer;
    /// <summary>
    ///   Returns the width, necessary to output unicode text
    /// </summary>
    function GetWideTextWidth(WideText: WideString): Extended;
    /// <summary>
    ///   Canvas height
    /// </summary>
    property Height: Integer read GetHeight write SetHeight;
    /// <summary>
    ///   Canvas width.
    /// </summary>
    property Width: Integer read GetWidth write SetWidth;
  end;


  /// <summary>
  ///   Tiling patterns consist of a small graphical figure (called a pattern cell) that is replicated at
  ///   fixed horizontal and vertical intervals to fill the area to be painted. The graphics objects to use
  ///   for tiling are created in this class
  /// </summary>
  TPDFPattern = class(TPDFCanvas)
  private
    FXStep: Cardinal;
    FYStep: Cardinal;
  protected
    procedure Save;override;
  public
    constructor Create(Engine:TPDFEngine; FontManager: TPDFFonts);
    /// <summary>
    ///   Horizontally step, with which the pattern in the filled area repeats
    /// </summary>
    property XStep: Cardinal read FXStep write FXStep;
    /// <summary>
    ///   Vertically step, with which the pattern in the filled area repeats
    /// </summary>
    property YStep: Cardinal read FYStep write FYStep;
  end;


  /// <summary>
  ///   Form is a special canvas, on which you can draw and which can be drawn on the page itself.
  ///   or like parts of acroform objects. This classis for implementation of this form
  /// </summary>
  TPDFForm = class(TPDFCanvas)
  private
    FPatterns: array of TPDFPattern;
    FHaveOptional:Boolean;
    FOptionalContent: TOptionalContent;
  protected
    procedure Save;override;
  public
    constructor Create(Engine:TPDFEngine; FontManager: TPDFFonts;
      OptionalContent: TOptionalContent= nil);
    /// <summary>
    ///   Set a pattern in the form which closed areas will be filled with 
    /// </summary>
    /// <param name="Pattern">
    ///   Object specifying thepattern
    /// </param>
    procedure SetPattern(Pattern: TPDFPattern);
  end;




  TPDFPages = class;

  TPDFAnnotation = class;

  TPDFAnnotationArray = array of TPDFAnnotation;

  /// <summary>
  ///   This class consist of information about one page of the PDF document. <br />The class supports
  ///   drawing and filling a variety of shapes and lines, writing text and rendering graphic images.
  /// </summary>
  TPDFPage = class(TPDFCanvas)
  private
    FAnnotations: TPDFAnnotationArray;
    FForms: array of TPDFForm;
    FMeta: array of TPDFForm;
    FPatterns: array of TPDFPattern;
    FOP:array of TOptionalContent;
    FAskCanvas: Boolean;
    FCanvas: TCanvas;
    FOrientation: TPDFPageOrientation;
    FOwner: TPDFPages;
    FRotate: TPDFPageRotate;
    FThumbnail: Integer;
    procedure CloseCanvas(AskedCanvas: Boolean);
    procedure SetOrientation(const Value: TPDFPageOrientation);
    procedure SetSize(const Value: TPDFPageSize);
    procedure SetThumbnail(const Value: Integer);
    procedure SetWidth( const Value: Integer);override;
    procedure SetHeight( const Value: Integer);override;
  protected
    procedure Save; override;
  public
    constructor Create(Engine:TPDFEngine;Owner: TPDFPages; FontManager: TPDFFonts);
    destructor Destroy; override;
    /// <summary>
    ///   Creates annotation, clicking which leads to the specified page
    /// </summary>
    /// <param name="ARect">
    ///   Rectangle, which annotation is created within
    /// </param>
    /// <param name="PageIndex">
    ///   Page index for transition
    /// </param>
    /// <param name="TopOffset">
    ///   The offset relative to the top of the page
    /// </param>
    function SetLinkToPage(ARect: TRect; PageIndex,TopOffset: Integer): TPDFAnnotation;
    /// <summary>
    ///   Creates an annotation clicking which leads to transition to the specified URL
    /// </summary>
    /// <param name="ARect">
    ///   Rectangle, within which annotation will be created
    /// </param>
    /// <param name="URL">
    ///   URL for transition
    /// </param>
    function SetUrl(ARect: TRect; URL: AnsiString): TPDFAnnotation;
    /// <summary>
    ///   Draws metafile on the page canvas as a series of lines, areas and text.
    /// </summary>
    /// <param name="MF">
    ///   depicted metafile
    /// </param>
    /// <param name="OptionalContent">
    ///   Optional content, which the metafile will be displayed in
    /// </param>
    procedure PlayMetaFile(MF: TMetaFile;OptionalContent: TOptionalContent=nil);overload;
    /// <summary>
    ///   Draws metafile on the page canvas as a series of lines, areas and text.
    /// </summary>
    /// <param name="MF">
    ///   Depicted metafile
    /// </param>
    /// <param name="x">
    ///  X coordinate from which will be displayed metafile
    /// </param>
    /// <param name="y">
    ///   Y coordinate from which will be displayed metafile
    /// </param>
    /// <param name="XScale">
    ///   Level of compression across the width
    /// </param>
    /// <param name="YScale">
    ///   Level of compression along the height
    /// </param>
    /// <param name="OptionalContent">
    ///   Optional content, which the metafile will be displayed in
    /// </param>
    procedure PlayMetaFile(MF: TMetafile; x, y, XScale, YScale: Extended; OptionalContent: TOptionalContent=nil);overload;
    /// <summary>
    ///   Draws metafile on the page canvas as a series of lines, areas and text.
    /// </summary>
    /// <param name="Form">
    ///   Form to display
    /// </param>
    /// <param name="X">
    ///   X coordinate from which will be displayed metafile
    /// </param>
    /// <param name="Y">
    ///   Y coordinate from which will be displayed metafile 
    /// </param>
    /// <param name="XScale">
    ///   Level of compression across the width
    /// </param>
    /// <param name="YScale">
    ///   Level of compression along the height
    /// </param>
    procedure PlayForm(Form: TPDFForm; X, Y, XScale, YScale: Extended);
    /// <summary>
    ///   Set a pattern in the form which closed areas will be filled with    
    /// </summary>
    /// <param name="Pattern">
    ///   Object specifying the pattern
    /// </param>
    procedure SetPattern(Pattern: TPDFPattern);
    /// <summary>
    ///   Turn on the optional content. All that will be drawn further will belong to this
     /// optional content until it is turned off.
    /// </summary>
    /// <param name="OptionalContent">
    ///   Object specifying optional content.
    /// </param>
    procedure TurnOnOptionalContent(OptionalContent: TOptionalContent);
    /// <summary>
    ///   Turns off previously turned on optional content.
    /// </summary>
    procedure TurnOffOptionalContent;
    /// <summary>
    ///   Standard canvas, which has HDC and can be used for GDI functions
    /// </summary>
    property Canvas: TCanvas read FCanvas;
    /// <summary>
    ///   Page orientation
    /// </summary>
    property Orientation: TPDFPageOrientation read FOrientation write SetOrientation;
    /// <summary>
    ///   Page rotation
    /// </summary>
    property PageRotate: TPDFPageRotate read FRotate write FRotate;
    /// <summary>
    ///   Page size
    /// </summary>
    property Size: TPDFPageSize write SetSize;
    /// <summary>
    ///   Thumbnail of the page. Defined by image index in saved document
    /// </summary>
    property Thumbnail: Integer write SetThumbnail;
{#skipend}
  end;


  TPDFPages = class(TPDFManager)
  private
    FActions: TPDFManager;
    FAutoURLCreate: Boolean;
    FCurrentPage: TPDFPage;
    FCurrentPageIndex: Integer;
    FEMFOptions: TObject;
    FFonts: TPDFFonts;
    FImages: TPDFImages;
    FPatterns: TPDFListManager;
    FList: TList;
    FAskCanvas:Boolean;
    FOwner:TObject;
    function GetPage(index:Integer): TPDFPage;
  protected
    function GetCount: Integer; override;
    procedure Save;override;
    procedure Clear;override;
    function GetPageIndex(Page: TPDFPage):Integer;
  public
    constructor Create(Owner:TObject; Engine: TPDFEngine; FontManager: TPDFFonts);
    destructor Destroy; override;
    procedure Add;
    procedure CloseCanvas;
    procedure CreateCanvas;
    procedure RequestCanvas;
    procedure SaveIndex(Index:Integer);
    procedure SetCurrentPage(Index:Integer);
    property Actions: TPDFManager write FActions;
    property AutoURLCreate: Boolean read FAutoURLCreate write FAutoURLCreate;
    property Count: Integer read GetCount;
    property CurrentPage: TPDFPage read FCurrentPage;
    property CurrentPageIndex: Integer read FCurrentPageIndex ;
    property EMFOptions: TObject read FEMFOptions;
    property Images: TPDFImages read FImages write FImages;
    property Patterns: TPDFListManager read FPatterns write FPatterns;
    property Pages[index:Integer]: TPDFPage read GetPage; default;
    property Owner:TObject read FOwner;
  end;


  /// Description: TPDFAnnotation is base class of all annotations.
  TPDFAnnotation = class(TPDFObject)
  protected
    FOwner: TPDFPage;
    FBorderStyle: AnsiString;
    FFlags: TPDFAnnotationFlags;
    FBorderColor: TPDFColor;
    FLeft, FTop, FRight, FBottom: Integer;
    function CalcFlags: Integer;
    procedure ChangePage(Page: TPDFPage; Box: TRect);
  public
    /// Description:
    /// Arguments:
    ///   Page: Page where will located this object
    ///   Box: Specifies position of the annotation on the page.
    constructor Create( Page: TPDFPage;Box: TRect);
    /// Description: A dash array defining a pattern of dashes and gaps to be used in drawing a dashed border.
    property BorderStyle: Ansistring write FBorderStyle;
    /// Description: A set of flags specifying various characteristics of the annotation
    property Flags: TPDFAnnotationFlags {$ifdef ActiveX}read FFlags {$endif} write FFlags;
    /// Description: Specifies the border color of the PDF control.
    property BorderColor: TPDFColor write FBorderColor;
  end;


  /// <summary>
  ///   The function to convert the gray to PDF Color
  /// </summary>
  /// <param name="G">
  ///   Grayscale level from 0 to 1  
  /// </param>
  function GrayToPDFColor(G:Extended):TPDFColor;
  /// <summary>
  ///   The function to convert RGB to PDFColor
  /// </summary>
  /// <param name="R">
  ///   Red grade level from 0 to 1
  /// </param>
  /// <param name="G">
  ///   Green grade level from 0 to 1
  /// </param>
  /// <param name="B">
  ///   Blue grade level from 0 to 1
  /// </param>
  function RGBToPDFColor(R,G,B:Extended):TPDFColor;
  /// <summary>
  ///   The function to convert CMYK to PDFColor
  /// </summary>
  /// <param name="C">
  ///   Grade level of cyan from 0 to 1
  /// </param>
  /// <param name="M">
  ///   Grade level of magenta from 0 to 1
  /// </param>
  /// <param name="Y">
  ///   Grade level of yellow from 0 to 1
  /// </param>
  /// <param name="K">
  ///   Grade level of key from 0 to 1
  /// </param>
  function CMYKToPDFColor(C,M,Y,K:Extended):TPDFColor;
  /// <summary>
  ///   The function to convert TColor to PDFColor
  /// </summary>
  /// <param name="Color">
  ///   Color
  /// </param>
  function ColorToPDFColor(Color:TColor):TPDFColor;



implementation

uses llPDFResources, llPDFEMF, llPDFSecurity,
  llPDFAction, llPDFAnnotation, llPDFCrypt, llPDFDocument, llPDFTrueType;


const
   URLDetectStrings: array [ 0..2 ] of AnsiString = ( 'http://', 'ftp://', 'mailto:' );


function GrayToPDFColor(G:Extended):TPDFColor;
begin
  Result.ColorSpace := csGray;
  Result.Gray := G;
end;

function RGBToPDFColor(R,G,B:Extended):TPDFColor;
begin
  Result.ColorSpace := csRGB;
  Result.Red := R ;
  Result.Green := G ;
  Result.Blue := B ;
end;

function CMYKToPDFColor(C,M,Y,K:Extended):TPDFColor;
begin
  Result.ColorSpace := csCMYK;
  Result.Cyan := C ;
  Result.Magenta := M ;
  Result.Yellow := Y ;
  Result.Key := K ;
end;

function ColorToPDFColor(Color:TColor):TPDFColor;
begin
  Result.ColorSpace := csRGB;
  Result.Red := GetRValue(Color) / 255;
  Result.Green := GetGValue(Color) / 255;
  Result.Blue := GetBValue(Color) / 255;
end;
   

{
********************************** TPDFCanvas **********************************
}
procedure TPDFCanvas.AppendAction(Action: AnsiString);
begin
  FContent.Add ( Action );
end;

function TPDFCanvas.Arc(X1, Y1, X2, Y2, BegAngle, EndAngle: Extended):
        TDoublePoint;
var
  d: TDoublePoint;
begin
  FPathInited := True;
  D := RawArc ( ExtToIntX ( X1 ), ExtToIntY ( Y1 ), ExtToIntX ( X2 ), ExtToIntY ( Y2 ), -EndAngle, -BegAngle );
  Result := DPoint ( IntToExtX ( d.x ), IntToExtY ( d.y ) );
end;

function TPDFCanvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Extended): TDoublePoint;
var
  d: TDoublePoint;
begin
  FPathInited := True;
  D := RawArc ( ExtToIntX ( X1 ), ExtToIntY ( Y1 ), ExtToIntX ( X2 ), ExtToIntY ( Y2 ),
    ExtToIntX ( X4 ), ExtToIntY ( Y4 ), ExtToIntX ( X3 ), ExtToIntY ( y3 ) );
  Result := DPoint ( IntToExtX ( d.x ), IntToExtY ( d.y ) );
end;

procedure TPDFCanvas.BeginText;
begin
  if FTextInited then
    Exit;
  AppendAction ( 'BT' );
  TP.x := 0;
  TP.y := 0;
  FTextInited := True;
end;

procedure TPDFCanvas.Circle(X, Y, R: Extended);
begin
  FPathInited := True;
  RawCircle ( ExtToIntX ( X ), ExtToIntY ( Y ), ExtToIntX ( R ) );
end;

procedure TPDFCanvas.Clip;
begin
  EndText;
  if FPathInited then
    AppendAction ( 'W' );
end;

procedure TPDFCanvas.ClosePath;
begin
  EndText;
  AppendAction ( 'h' );
end;

procedure TPDFCanvas.Comment(st: AnsiString);
begin
  AppendAction ( '% ' + st );
end;

constructor TPDFCanvas.Create(Engine: TPDFEngine; FontManager:TPDFFonts);
begin
  inherited Create( Engine);
  FFonts := FontManager;
  FContent := TAnsiStringList.Create;
  FCharset := 0;
  FIsTrueType := False;
  FStdFont := stdfHelvetica;
  FCurrentFontSize := 8;
  FCurrentFontStyle := [ ];
  FFontIsChanged := True;
  FCurrentIndex := -1;
//  FUnicodeUse := False;
  FCurrentDash := '[] 0';
  FLinkedFont := nil;
  FLinkedImages := nil;
  FMF := nil;
  FBaseLine := False;
  FRes := Eng.Resolution;
  D2P := FRes / 72;
  FCharSpace := 0;
  FWordSpace := 0;
  FHorizontalScaling := 100;
  FTextLeading := 0;
  FRender := 0;
  FRise := 0;
  FTextInited := False;
  FSaveCount := 0;
  GStateSave;
  Factions := False;
  FPathInited :=False;
  FMatrix.a := 1;
  FMatrix.b := 0;
  FMatrix.c := 0;
  FMatrix.d := 1;
  FMatrix.x := 0;
  FMatrix.y := 0;
  FF := FMatrix;
  FTextUsed := False;
  FColorUsed := False;
  FGrayUsed := False;
  FRGBUsed := False;
  FCMYKUsed := False;
  FFontScale := 1;
end;

procedure TPDFCanvas.Curveto(X1, Y1, X2, Y2, X3, Y3: Extended);
begin
  FPathInited := true;
  RawCurveto ( ExtToIntX ( x1 ), ExtToIntY ( y1 ), ExtToIntX ( x2 ), ExtToIntY ( y2 ), ExtToIntX ( x3 ), ExtToIntY ( y3 ) );
end;

destructor TPDFCanvas.Destroy;
begin
  FContent.Free;
  inherited;
end;

procedure TPDFCanvas.DrawArcWithBezier(CenterX, CenterY, RadiusX, RadiusY,
        StartAngle, SweepRange: Extended; UseMoveTo: Boolean);
var
  Coord, C2: array [ 0..3 ] of TDoublePoint;
  a, b, c, x, y: Extended;
  ss, cc: Double;
  i: Integer;
begin
  if SweepRange = 0 then
  begin
    if UseMoveTo then
      RawMoveTo ( CenterX + RadiusX * cos ( StartAngle ),
        CenterY - RadiusY * sin ( StartAngle ) );
    RawLineTo ( CenterX + RadiusX * cos ( StartAngle ),
      CenterY - RadiusY * sin ( StartAngle ) );
    Exit;
  end;
  b := sin ( SweepRange / 2 );
  c := cos ( SweepRange / 2 );
  a := 1 - c;
  x := a * 4 / 3;
  y := b - x * c / b;
  ss := sin ( StartAngle + SweepRange / 2 );
  cc := cos ( StartAngle + SweepRange / 2 );
  Coord [ 0 ] := DPoint ( c, b );
  Coord [ 1 ] := DPoint ( c + x, y );
  Coord [ 2 ] := DPoint ( c + x, -y );
  Coord [ 3 ] := DPoint ( c, -b );
  for i := 0 to 3 do
  begin
    C2 [ i ].x := CenterX + RadiusX * ( Coord [ i ].x * cc + Coord [ i ].y * ss ) - 0.0001;
    C2 [ i ].y := CenterY + RadiusY * ( -Coord [ i ].x * ss + Coord [ i ].y * cc ) - 0.0001;
  end;
  if UseMoveTo then
    RawMoveTo ( C2 [ 0 ].x, C2 [ 0 ].y );
  RawCurveto ( C2 [ 1 ].x, C2 [ 1 ].y, C2 [ 2 ].x, C2 [ 2 ].y, C2 [ 3 ].x, C2 [ 3 ].y );
end;

procedure TPDFCanvas.Ellipse(X1, Y1, X2, Y2: Extended);
begin
  FPathInited := True;
  RawEllipse ( ExtToIntX ( X1 ), ExtToIntY ( Y1 ), ExtToIntX ( X2 ), ExtToIntY ( Y2 ) );
end;

procedure TPDFCanvas.EndText;
begin
  if not FTextInited then
    Exit;
  AppendAction ( 'ET' );
  FCharSpace := 0;
  FTextInited := False;
end;

procedure TPDFCanvas.EoClip;
begin
  EndText;
  if FPathInited then
    AppendAction ( 'W*' );
end;

procedure TPDFCanvas.EoFill;
begin
  EndText;
  FPathInited := False;
  AppendAction ( 'f*' );
end;

procedure TPDFCanvas.EoFillAndStroke;
begin
  EndText;
  FPathInited := False;
  AppendAction ( 'B*' );
end;

procedure TPDFCanvas.ExtGlyphTextOut(X, Y, Orientation: Extended; Text: PWord;
        Len: Integer; DX: PExt);
var
  I: Integer;
  Ext: array of Single;
  P: PExt;
  o: Extended;
begin
  if Len = 0 then
    Exit;
  if DX <> nil then
  begin
    SetLength ( Ext, Len );
    P := DX;
    for I := 0 to Len - 1 do
    begin
      Ext [ i ] := p^ / D2P / FCurrentFontSize;
      inc ( P );
    end;
  end
  else
    Ext := nil;
  o := GetRawTextHeight;
  if Orientation = 0 then
    RawExtGlyphTextOut ( ExtToIntX ( X ), ExtToIntY ( Y ) - O, Orientation, Text, Len, @Ext [ 0 ] )
  else
    RawExtGlyphTextOut ( ExtToIntX ( X ) + o * sin ( Orientation * Pi / 180 ),
      ExtToIntY ( Y ) - o * cos ( Orientation * Pi / 180 ), Orientation, Text, Len, @Ext [ 0 ] );
  Ext := nil;
end;

procedure TPDFCanvas.ExtGlyphTextShow(Text: PWord; Len: Integer; Dx: PExt);
var
  i, Cr,Sp: Integer;
  RealWidth,CalculateWidth, CharWidth: Extended;
  CalcWidth: Boolean;
  Sizes: PSingleArray;
  BaseFont : TPDFTrueTypeFont;
  GlyphArray: PWordArray;
  Ch, ChNext:PNewCharInfo;
  OS: AnsiString;
begin
  if Len = 0 then
    Exit;
  BaseFont := ReceiveFont as TPDFTrueTypeFont;
  if not (BaseFont is TPDFTrueTypeFont) then
    Exit;
  CalcWidth := ( fsUnderline in FCurrentFontStyle ) or ( fsStrikeOut in FCurrentFontStyle );
  FTextUsed := True;
  GlyphArray := PWordArray(Text);
  if DX = nil then
  begin
    Cr := 0;
    Sp := 0;
    Ch := BaseFont.CharByIndex[GlyphArray[0]];
    SetCurrentFont(Ch^.FontIndex);
    OS := '';
    RealWidth := 0;
    for i := 0 to Len - 1 do
    begin
      if i <> 0 then
        Ch := BaseFont.CharByIndex[GlyphArray[i]];
      if Ch^.FontIndex = 0 then
      begin
        BaseFont.UsedChar(Byte(Ch^.NewCharacter));
        if ( Ch^.NewCharacter = ' ') and ( Len <> 1 ) then
          inc(sp);
      end;
      if FCurrentIndex <> Ch^.FontIndex then
      begin
        AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
        SetCurrentFont(Ch^.FontIndex);
        OS := Ch^.NewCharacter;
      end else
        OS := OS + Ch^.NewCharacter;
      if CalcWidth then
      begin
        CharWidth := Ch^.Width;
        if ( CharWidth <> 0.0 ) or ( len <> 1 ) then
          Inc ( Cr );
        RealWidth := RealWidth + CharWidth;
      end;
    end;
    AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
    if not CalcWidth then
      Exit;
    RealWidth := RealWidth * FCurrentFontSize / 1000;
    if FHorizontalScaling <> 100 then
      RealWidth := RealWidth * FHorizontalScaling / 100;
    if FWordSpace > 0 then
      RealWidth := RealWidth + Sp * FWordSpace;
    if FCharSpace > 0 then
      RealWidth := RealWidth + Cr * FCharSpace;
    PaintTextLines ( RealWidth );
  end else
  begin
    Sizes := PSingleArray ( Dx );
    SetWordSpacing ( 0 );
    OS := '';
    RealWidth := 0;
    CalculateWidth := 0;
    ChNext := BaseFont.CharByIndex[GlyphArray^ [ 0 ] ];
    SetCurrentFont(ChNext^.FontIndex);
    for i := 0 to Len - 1 do
    begin
      Ch := ChNext;
      if Ch^.FontIndex = 0 then
        BaseFont.UsedChar(Byte(Ch^.NewCharacter));
      CharWidth := Ch^.Width / 1000;
      if FHorizontalScaling <> 100 then
        CharWidth := CharWidth * FHorizontalScaling / 100;
      if Ch^.FontIndex <> FCurrentIndex then
      begin
        SetIntCharacterSpacing ( ( CalculateWidth - RealWidth ) / Length(OS) );
        AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
        AppendAction ( FormatFloat ( CalculateWidth ) + ' 0 Td' );
        RealWidth := 0;
        CalculateWidth := 0;
        OS := CH^.NewCharacter;
        SetCurrentFont(Ch^.FontIndex);
      end else
        OS := OS + CH^.NewCharacter;
      if abs(CharWidth - Sizes[i]) > 0.2 then
      begin
        SetIntCharacterSpacing ( ( CalculateWidth - RealWidth ) / Length(OS) );
        AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
        if i <> len - 1 then
        begin
          AppendAction ( FormatFloat ( CalculateWidth+Sizes[i] ) + ' 0 Td' );
          ChNext := BaseFont.CharByIndex[GlyphArray^ [i+1]];
          if ChNext^.FontIndex <> FCurrentIndex then
             SetCurrentFont(ChNext^.FontIndex);
        end;
        OS := '';
        RealWidth := 0;
        CalculateWidth := 0;
      end else
      begin
        RealWidth := RealWidth + CharWidth;
        CalculateWidth := CalculateWidth + Sizes[i];
        if i <> len - 1 then
          ChNext := BaseFont.CharByIndex[GlyphArray^ [i+1]];
      end;
    end;
    if OS <> '' then
    begin
      SetIntCharacterSpacing ( ( CalculateWidth - RealWidth ) / Length(OS) );
      AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
    end;

    if ( ( not ( fsUnderLine in FCurrentFontStyle ) ) and ( not ( fsStrikeOut in FCurrentFontStyle ) ) ) then
      Exit;
    RealWidth := 0;
    for I := 0 to Len - 1 do
      RealWidth := RealWidth + Sizes[i];
    RealWidth := RealWidth * FCurrentFontSize;
    PaintTextLines ( RealWidth );
  end;
end;

procedure TPDFCanvas.ExtTextOut(X, Y, Orientation: Extended; TextStr: AnsiString; Dx: PExt);
var
  I, J: Integer;
  Ext: array of Single;
  P: PExt;
  K: Integer;
  O: Extended;
  ws, URL: AnsiString;
  Off: Integer;
  offUrl, LenUrl: Extended;
  fnd: Boolean;
begin
  if TextStr = '' then
    Exit;
  if Dx = nil then
  begin
    TextOut ( X, Y, Orientation, TextStr );
	exit;
  end;
  k := length ( TextStr );
  SetLength ( Ext, K );
  P := DX;
  for I := 0 to k - 1 do
  begin
    Ext [ i ] := p^ / D2P / FCurrentFontSize;
    inc ( P );
  end;
  if Orientation = 0 then
  begin
    O := GetRawTextHeight;
    RawExtTextOut ( ExtToIntX ( X ), ExtToIntY ( Y ) - O, Orientation, TextStr, @Ext [ 0 ] );
    if Self is TPDFPage then
      if TPDFPage(Self).FOwner.FAutoURLCreate then
      begin
        ws := LCase ( TextStr );
        fnd := False;
        for I := 0 to 2 do
          if PosText ( URLDetectStrings [ i ], ws, 1 ) <> 0 then
            fnd := True;
        if fnd then
        begin
          for I := 0 to 2 do
          begin
            OFF := 1;
            K := PosText ( URLDetectStrings [ i ], ws, 1 );
            while K <> 0 do
            begin
              if K <> 1 then
                if ws [ K - 1 ] <> #32 then
                begin
                  OFF := PosText ( ' ', ws, OFF ) + 1;
                  K := PosText ( URLDetectStrings [ i ], ws, OFF );
                  Continue;
                end;
              OFF := PosText ( ' ', ws, K + 1 );
              if OFF = 0 then
              begin
                off := Length ( ws );
                URL := Copy ( TextStr, K, OFF - K + 1 );
              end else
                URL := Copy ( TextStr, K, OFF - K );
              P := Dx;
              offUrl := 0;
              LenUrl := 0;
              for J := 1 to K - 1 do
              begin
                offUrl := offUrl + p^;
                Inc ( P );
              end;
              for j := 1 to Length ( URL ) do
              begin
                LenUrl := LenUrl + p^;
                Inc ( P );
              end;
              if FBaseLine then
                TPDFPage(Self).SetUrl ( Rect ( Trunc ( X + offUrl ), Trunc ( Y ),
                  Trunc ( X + offURL + LenUrl ), Trunc ( Y - FCurrentFontSize * d2p ) ), URL )
              else
                TPDFPage(Self).SetUrl ( Rect ( Trunc ( X + offUrl ), trunc ( Y ),
                  Trunc ( X + offURL + LenUrl ), Trunc ( Y + O * d2p ) ), URL );
              K := PosText ( URLDetectStrings [ i ], ws, OFF );
            end;
          end;
        end;
      end;
  end
  else
  begin
    O := GetRawTextHeight;
    RawExtTextOut ( ExtToIntX ( X ) + o * sin ( Orientation * Pi / 180 ), ExtToIntY ( Y ) - o * cos ( Orientation * Pi / 180 ),
      Orientation, TextStr, @Ext [ 0 ] );
  end;
  Ext := nil;
end;

procedure TPDFCanvas.ExtTextShow(TextStr: AnsiString; Dx: PExt);
var
  CodePage: Integer;
  Len: Integer;
  Mem: PWord;
  S: AnsiString;
  TL: Integer;
  I: Integer;
  P: PExt;
  SZ: Extended;
  B: Byte;
  st: TStringType;
begin
  if TextStr = '' then
    Exit;
   FTextUsed := True;
  SetHorizontalScaling ( 100 );
  SetWordSpacing ( 0 );
  SetCharacterSpacing ( 0 );
  P := Dx;
  SetCurrentFont (0);
  st := GetStringType(TextStr);
  if (st = stASCII) or ((st = stANSI) and(FCurrentFont is TPDFStandardFont)) then
  begin
    FCurrentFont.FillUsed ( TextStr );
    for I := 1 to Length ( TextStr ) do
    begin
      B := Byte ( TextStr [ i ] );
      S := '(' + EscapeSpecialChar ( ANSIChar ( B ) ) + ')';
      AppendAction ( S + ' Tj ' + FormatFloat ( p^ ) + ' 0 Td' );
      Inc ( P );
    end;
    P := Dx;
    SZ := 0;
    if ( ( not ( fsUnderLine in FCurrentFontStyle ) ) and ( not ( fsStrikeOut in FCurrentFontStyle ) ) ) then
      Exit;
    for I := 1 to Length ( TextStr ) do
    begin
      SZ := SZ + P^;
      Inc ( P );
    end;
    PaintTextLines ( SZ );
  end else
  begin
    TL := Length ( TextStr );
    CodePage := CharSetToCodePage ( FCharset );
    Len := MultiByteToWideChar ( CodePage, 0, PANSIChar ( TextStr ), TL, nil, 0 );
    if Len = 0 then
      raise EPDFException.Create ( 'Cannot convert text to unicode' );
    GetMem ( Mem, Len * 2 );
    try
      Len := MultiByteToWideChar ( CodePage, 0, PANSIChar ( TextStr ), TL, PWideChar ( Mem ), Len );
      if Len = 0 then
        raise EPDFException.Create ( 'Cannot convert text to unicode' );
      ExtWideTextShow ( Mem, Len, Dx );
    finally
      FreeMem ( Mem );
    end;
  end;
end;

function TPDFCanvas.ExtToIntX(AX: Extended): Extended;
begin
  Result := AX / D2P;
  FActions := True;
end;

function TPDFCanvas.ExtToIntY(AY: Extended): Extended;
begin
  Result := FHeight - AY / D2P;
  Factions := True;
end;

procedure TPDFCanvas.ExtWideTextOut(X, Y, Orientation: Extended; WideText:WideString; DX: PExt);
var
  I: Integer;
  Ext: array of Single;
  P: PExt;
  o: Extended;
  ws, URL: AnsiString;
  J: Integer;
  K: Integer;
  Off: Integer;
  offUrl, LenUrl: Extended;
  fnd: Boolean;
  T: PWord;
  Text: PWord; Len: Integer;
begin
  Text := Pointer(PWideChar(WideText));
  Len := Length(WideText);
  if Len = 0 then
    Exit;
  if DX = nil then
  begin
    WideTextOut ( X, Y, Orientation, WideText );
    Exit;
  end;
  SetLength ( Ext, Len );
  P := DX;
  for I := 0 to Len - 1 do
  begin
    Ext [ i ] := p^ / D2P / FCurrentFontSize;
    inc ( P );
  end;
  o := GetRawTextHeight;
  if Orientation = 0 then
  begin
    RawExtWideTextOut ( ExtToIntX ( X ), ExtToIntY ( Y ) - O, Orientation, Text, Len, @Ext [ 0 ] );
    if Self is TPDFPage then
      if TPDFPage(Self).FOwner.FAutoURLCreate then
      begin
        ws := '';
        T := Text;
        for I := 1 to Len do
        begin
          ws := ws + ANSIChar ( Byte ( T^ ) );
          Inc ( T );
        end;
        ws := LCase ( ws );
        fnd := False;
        for I := 0 to 2 do
          if PosText ( URLDetectStrings [ i ], ws, 1 ) <> 0 then
            fnd := True;
        if fnd then
        begin
          for I := 0 to 2 do
          begin
            OFF := 1;
            K := PosText ( URLDetectStrings [ i ], ws, 1 );
            while K <> 0 do
            begin
              if K <> 1 then
                if ws [ K - 1 ] <> #32 then
                begin
                  OFF := PosText ( ' ', ws, OFF ) + 1;
                  if off = 1 then
                    break;
                  K := PosText ( URLDetectStrings [ i ], ws, OFF );
                  Continue;
                end;
              OFF := PosText ( ' ', ws, K + 1 );
              T := Text;
              Inc ( T, K - 1 );
              URL := '';
              if OFF = 0 then
              begin
                off := Length ( ws );
                for J := 1 to OFF - K + 1 do
                begin
                  URL := URL + ANSIChar ( Byte ( T^ ) );
                  Inc ( T );
                end;
              end else
                for J := 1 to OFF - K do
                begin
                  URL := URL + ANSIChar ( Byte ( T^ ) );
                  Inc ( T );
                end;
              P := Dx;
              offUrl := 0;
              LenUrl := 0;
              for J := 1 to K - 1 do
              begin
                offUrl := offUrl + p^;
                Inc ( P );
              end;
              for j := 1 to Length ( URL ) do
              begin
                LenUrl := LenUrl + p^;
                Inc ( P );
              end;
              if FBaseLine then
                TPDFPage(Self).SetUrl ( Rect ( Trunc ( X + offUrl ), Trunc ( Y ), Trunc ( X + offURL + LenUrl ), Trunc ( Y - FCurrentFontSize * d2p ) ), URL )
              else
                TPDFPage(Self).SetUrl ( Rect ( Trunc ( X + offUrl ), trunc ( Y ), Trunc ( X + offURL + LenUrl ), Trunc ( Y + O * d2p ) ), URL );
              K := PosText ( URLDetectStrings [ i ], ws, OFF );
            end;
          end;
        end;
      end;
  end
  else
    RawExtWideTextOut ( ExtToIntX ( X ) + o * sin ( Orientation * Pi / 180 ),
      ExtToIntY ( Y ) - o * cos ( Orientation * Pi / 180 ), Orientation, Text, Len, @Ext [ 0 ] );
  Ext := nil;
end;

procedure TPDFCanvas.ExtWideTextShow(Text: PWord; Len: Integer; Dx: PExt);
var
  I: Integer;
  OS: AnsiString;
  RealWidth: Extended;
  CalculateWidth: Extended;
  CharWidth: Extended;
  UnicodeTextArray: PWordArray;
  Sizes: PSingleArray;
  Ch,ChNext:PNewCharInfo;
  BaseFont:TPDFTrueTypeFont;
begin
  if Len = 0 then
    Exit;
  if Not FIsTrueType then
    raise EPDFException.Create(SAvailableForTrueTypeFontOnly);
  BaseFont := ReceiveFont as TPDFTrueTypeFont;
  UnicodeTextArray := PWORDArray ( Text );
  Sizes := PSingleArray ( Dx );
  SetWordSpacing ( 0 );
  OS := '';
  RealWidth := 0;
  CalculateWidth := 0;
  ChNext := BaseFont.CharByUnicode[UnicodeTextArray^ [ 0 ] ];
  SetCurrentFont(ChNext^.FontIndex);
  for i := 0 to Len - 1 do
  begin
    Ch := ChNext;
    if Ch^.FontIndex = 0 then
      BaseFont.UsedChar(Byte(Ch^.NewCharacter));
    CharWidth := Ch^.Width / 1000;
    if FHorizontalScaling <> 100 then
      CharWidth := CharWidth * FHorizontalScaling / 100;
    if Ch^.FontIndex <> FCurrentIndex then
    begin
      SetIntCharacterSpacing ( ( CalculateWidth - RealWidth ) / Length(OS) );
      AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
      AppendAction ( FormatFloat ( CalculateWidth ) + ' 0 Td' );
      RealWidth := 0;
      CalculateWidth := 0;
      OS := CH^.NewCharacter;
      SetCurrentFont(Ch^.FontIndex);
    end else
      OS := OS + CH^.NewCharacter;
    if abs(CharWidth - Sizes[i]) > 0.2 then
    begin
      SetIntCharacterSpacing ( ( CalculateWidth - RealWidth ) / Length(OS) );
      AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
      if i <> len - 1 then
      begin
        AppendAction ( FormatFloat ( CalculateWidth+Sizes[i] ) + ' 0 Td' );
        ChNext := BaseFont.CharByUnicode[UnicodeTextArray^ [i+1]];
        if ChNext^.FontIndex <> FCurrentIndex then
           SetCurrentFont(ChNext^.FontIndex);
      end;
      OS := '';
      RealWidth := 0;
      CalculateWidth := 0;
    end else
    begin
      RealWidth := RealWidth + CharWidth;
      CalculateWidth := CalculateWidth + Sizes[i];
      if i <> len - 1 then
        ChNext := BaseFont.CharByUnicode[UnicodeTextArray^ [i+1]];
    end;
  end;
  if OS <> '' then
  begin
    SetIntCharacterSpacing ( ( CalculateWidth - RealWidth ) / Length(OS) );
    AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
  end;

  if ( ( not ( fsUnderLine in FCurrentFontStyle ) ) and ( not ( fsStrikeOut in FCurrentFontStyle ) ) ) then
    Exit;
  RealWidth := 0;
  for I := 0 to Len - 1 do
    RealWidth := RealWidth + Sizes[i];
  RealWidth := RealWidth * FCurrentFontSize;
  PaintTextLines ( RealWidth );
end;

procedure TPDFCanvas.Fill;
begin
  EndText;
  FPathInited := False;
  AppendAction ( 'f' );
end;

procedure TPDFCanvas.FillAndStroke;
begin
  EndText;
  FPathInited := False;
  AppendAction ( 'B' );
end;

function TPDFCanvas.GetCurrentFontSize: Extended;
begin
  Result := FCurrentFontSize;
end;

function TPDFCanvas.GetHeight: Integer;
begin
  Result := Round ( FHeight * D2P );
end;

function TPDFCanvas.GetRawTextHeight: Extended;
var
  CF: TPDFFont;
begin
  if FBaseLine then
    Result := 0
  else if FFontIsChanged then
  begin
    CF := ReceiveFont ;
    Result := FCurrentFontSize * ( CF.Ascent ) / 1000;
  end
  else
    Result := FCurrentFontSize * ( FCurrentFont.Ascent ) / 1000;
end;

function TPDFCanvas.GetTextRowCount(BoxWidth: Integer; TextStr: AnsiString):
    Integer;
var
  i, Len: Integer;
  Ch: AnsiChar;
  CWidth, StrWidth, OutWidth: Extended;
  CF: TPDFFont;
begin
  Result := 0;
  StrWidth := 0;
  OutWidth := 0;
  i := 1;
  CF := ReceiveFont;
  Len := Length ( TextStr );
  while i <= Len do
  begin
    ch := TextStr [ i ];
    CWidth := CF.Width[ Byte(ch) ] * FCurrentFontSize / 1000;
    if FHorizontalScaling <> 100 then
      CWidth := CWidth * FHorizontalScaling / 100;
    if CWidth > 0 then
      CWidth := CWidth + FCharSpace
    else
      CWidth := 0;
    if ( ch = ' ' ) and ( FWordSpace > 0 ) and ( i <> Len ) then
      CWidth := CWidth + FWordSpace;
    if ( ( OutWidth + StrWidth + CWidth ) < BoxWidth ) and
      ( i < Length ( TextStr ) ) and ( not ( Ch in [ #10, #13 ] ) ) then
    begin
      StrWidth := StrWidth + CWidth;
      if ch = ' ' then
      begin
        OutWidth := OutWidth + StrWidth;
        StrWidth := 0;
      end;
    end else
    begin
      if ( ch = #13 ) and ( i < Len ) then
        if ( TextStr [ i + 1 ] = #10 ) then
          Inc ( i );
      if i = Len then
        StrWidth := CWidth
      else
        StrWidth := StrWidth + CWidth;
      OutWidth := 0;
      Inc ( Result );
    end;
    Inc ( i );
  end;
end;

function TPDFCanvas.GetTextWidth(Text: AnsiString): Extended;
begin
  Result := RawGetTextWidth ( Text ) * D2P;
end;

function TPDFCanvas.GetWideTextRowCount(BoxWidth: Integer; WideText:WideString): Integer;
var
  BeforeLastWordWidth, LastWordWidth: Extended;
  i, OutLen: Integer;
  CWidth, StrWidth: Extended;
  PW: PWord;
  CU: Word;
  T: PWord;
  CFU: TPDFFont;
  LastWord: PWord;
  LineCount: Integer;
  BeforeLastWordChar: Integer;
  NX: Boolean;
  Text: PWord;
  Len: Integer;
begin
  Text := Pointer(PWideChar(WideText));
  Len := Length(WideText);
  if Len = 0 then
  begin
    Result := 0;
    Exit;
  end;
  i := 1;
  PW := Text;
  OutLen := 0;
  BeforeLastWordWidth := 0;
  LastWordWidth := 0;
  LineCount := 0;
  LastWord := nil;
  StrWidth := BoxWidth * D2P;
  BeforeLastWordChar := 0;
  CFU := ReceiveFont;
  while i <= Len do
  begin
    CU := PW^;
    CWidth := CFU.Width [ CU ];
    CWidth := CWidth * FCurrentFontSize / 1000;
    if FHorizontalScaling <> 100 then
      CWidth := CWidth * FHorizontalScaling / 100;
    if CWidth > 0 then
      CWidth := CWidth + FCharSpace
    else
      CWidth := 0;
    if ( cu = 32 ) and ( FWordSpace > 0 ) and ( i <> Len ) then
      CWidth := CWidth + FWordSpace;
    if ( BeforeLastWordWidth + LastWordWidth + CWidth < StrWidth ) and ( not ( ( CU = 13 ) or ( CU = 10 ) ) ) and ( i <> Len ) then
    begin
      Inc ( OutLen );
      if CU = 32 then
      begin
        BeforeLastWordWidth := BeforeLastWordWidth + LastWordWidth + CWidth;
        LastWordWidth := 0;
        BeforeLastWordChar := OutLen;
        LastWord := PW;
        Inc ( LastWord );
      end else
        LastWordWidth := CWidth + LastWordWidth;
    end else
    begin
      if ( CU = 13 ) and ( i <> Len ) then
      begin
        T := PW;
        Inc ( T );
        if T^ = 10 then
        begin
          Inc ( I );
          Inc ( PW );
        end;
      end;
      if ( CU = 10 ) or ( CU = 13 ) or ( CU = 32 ) or ( i = Len ) then
      begin
        NX := ( BeforeLastWordWidth + LastWordWidth + CWidth > StrWidth ) and ( i = Len );
        Inc ( LineCount );
        if NX then
          OutLen := 1
        else
          OutLen := 0;
        BeforeLastWordChar := 0;
        BeforeLastWordWidth := 0;
        LastWordWidth := 0;
        LastWord := nil;
      end else
      begin
        if LastWord <> nil then
        begin
          LastWordWidth := LastWordWidth + CWidth;
          OutLen := OutLen - BeforeLastWordChar + 1;
          BeforeLastWordChar := 0;
          BeforeLastWordWidth := 0;
          LastWord := nil;
          Inc ( LineCount );
        end else
        begin
          Inc ( LineCount );
          OutLen := 1;
          BeforeLastWordChar := 0;
          BeforeLastWordWidth := 0;
          LastWordWidth := CWidth;
          LastWord := nil;
        end;
      end;
    end;
    Inc ( i );
    Inc ( PW );
  end;
  if OutLen <> 0 then
    Inc ( LineCount );
  Result := LineCount;
end;

function TPDFCanvas.GetWideTextWidth(WideText: WideString): Extended;
begin
  Result := IntToExtX ( RawGetWideWidth ( WideText ) );
end;

function TPDFCanvas.GetWidth: Integer;
begin
  Result := Round ( FWidth * D2P );
end;

procedure TPDFCanvas.GStateRestore;
begin
  if FBCDStart then
    raise EPDFException.Create(SBCDSaveRestoreStateError);
  if FSaveCount <> 1 then
  begin
    EndText;
    AppendAction ( 'Q' );
    Dec ( FSaveCount );
    if FCurrentFontIndex > FSaveCount then
      FFontIsChanged := True;
  end;
end;

procedure TPDFCanvas.GStateSave;
begin
  if FBCDStart then
    raise EPDFException.Create(SBCDSaveRestoreStateError);
  EndText;
  Inc ( FSaveCount );
  AppendAction ( 'q' );
end;

function TPDFCanvas.IntToExtX(AX: Extended): Extended;
begin
  Result := AX * D2P;
  Factions := True;
end;

function TPDFCanvas.IntToExtY(AY: Extended): Extended;
begin
  Result := ( FHeight - AY ) * D2P;
  Factions := True;
end;

procedure TPDFCanvas.LineTo(X, Y: Extended);
begin
  FPathInited := True;
  RawLineTo ( ExttointX ( X ), ExtToIntY ( Y ) );
end;

procedure TPDFCanvas.MoveTo(X, Y: Extended);
begin
  FPathInited := True;
  RawMoveTo ( ExttointX ( X ), ExtToIntY ( Y ) );
end;

procedure TPDFCanvas.NewPath;
begin
  EndText;
  AppendAction ( 'n' );
end;

procedure TPDFCanvas.NoDash;
begin
  EndText;
  SetDash ( '[] 0' );
end;

procedure TPDFCanvas.PaintTextLines(Width: Extended);
begin
  if ( ( not ( fsUnderLine in FCurrentFontStyle ) ) and ( not ( fsStrikeOut in FCurrentFontStyle ) ) ) then
    Exit;
  if fsUnderLine in FCurrentFontStyle then
  begin
    if FRealAngle <> 0 then
      RawRectRotated ( TP.x + 3 * sin ( ( PI / 180 ) * FRealAngle ), TP.y - 3 * cos ( FRealAngle * ( PI / 180 ) ),
        Width, -FCurrentFontSize * 0.05, FRealAngle )
    else
      RawRect ( TP.x, TP.y - FCurrentFontSize * 0.05, Width, -FCurrentFontSize * 0.05 );
  end;
  if fsStrikeOut in FCurrentFontStyle then
  begin
    if FRealAngle <> 0 then
      RawRectRotated ( TP.x - FCurrentFontSize / 4 * sin ( ( PI / 180 ) * FRealAngle ), TP.y + FCurrentFontSize / 4 * cos ( FRealAngle * ( PI / 180 ) ),
        Width, FCurrentFontSize * 0.05, FRealAngle )
    else
      RawRect ( TP.x, TP.y + FCurrentFontSize / 4, Width, FCurrentFontSize * 0.05 );
  end;
  case FRender of
    0: Fill;
    1: Stroke;
    2: FillAndStroke;
  else
    Fill;
  end;
end;

procedure TPDFCanvas.Pie(X1, Y1, X2, Y2, BegAngle, EndAngle: Extended);
begin
  RawPie ( ExtToIntX ( X1 ), ExtToIntY ( Y1 ), ExtToIntX ( X2 ), ExtToIntY ( Y2 ), -EndAngle, -BegAngle );
end;

procedure TPDFCanvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Extended);
begin
  RawPie ( ExtToIntX ( X1 ), ExtToIntY ( Y1 ), ExtToIntX ( X2 ),
    ExtToIntY ( Y2 ), ExtToIntX ( X4 ), ExtToIntY ( Y4 ), ExtToIntX ( X3 ), ExtToIntY ( y3 ) );
end;


function TPDFCanvas.RawArc(X1, Y1, x2, y2, BegAngle,  EndAngle: Extended):
        TDoublePoint;
var
  CenterX, CenterY: Extended;
  RadiusX, RadiusY: Extended;
  StartAngle, EndsAngle, SweepRange: Extended;
  UseMoveTo: Boolean;
begin
  CenterX := ( x1 + x2 ) / 2;
  CenterY := ( y1 + y2 ) / 2;
  RadiusX := ( abs ( x1 - x2 ) - 1 ) / 2;
  RadiusY := ( abs ( y1 - y2 ) - 1 ) / 2;
  if RadiusX < 0 then
    RadiusX := 0;
  if RadiusY < 0 then
    RadiusY := 0;
  
  StartAngle := BegAngle * pi / 180;
  EndsAngle := EndAngle * pi / 180;
  SweepRange := EndsAngle - StartAngle;
  
  if SweepRange < 0 then
    SweepRange := SweepRange + 2 * PI;
  
  Result := DPoint ( CenterX + RadiusX * cos ( StartAngle ),
    CenterY - RadiusY * sin ( StartAngle ) );
  UseMoveTo := True;
  while SweepRange > PI / 2 do
  begin
    DrawArcWithBezier ( CenterX, CenterY, RadiusX, RadiusY,
      StartAngle, PI / 2, UseMoveTo );
    SweepRange := SweepRange - PI / 2;
    StartAngle := StartAngle + PI / 2;
    UseMoveTo := False;
  end;
  if SweepRange >= 0 then
    DrawArcWithBezier ( CenterX, CenterY, RadiusX, RadiusY,
      StartAngle, SweepRange, UseMoveTo );
end;

function TPDFCanvas.RawArc(X1, Y1, x2, y2, x3, y3, x4, y4: Extended):
        TDoublePoint;
var
  CenterX, CenterY: Extended;
  RadiusX, RadiusY: Extended;
  StartAngle, EndAngle, SweepRange: Extended;
  UseMoveTo: Boolean;
begin
  CenterX := ( x1 + x2 ) / 2;
  CenterY := ( y1 + y2 ) / 2;
  RadiusX := ( abs ( x1 - x2 ) - 1 ) / 2;
  RadiusY := ( abs ( y1 - y2 ) - 1 ) / 2;
  if RadiusX < 0 then
    RadiusX := 0;
  if RadiusY < 0 then
    RadiusY := 0;
  
  StartAngle := ArcTan2 ( - ( y3 - CenterY ) * RadiusX,
    ( x3 - CenterX ) * RadiusY );
  EndAngle := ArcTan2 ( - ( y4 - CenterY ) * RadiusX,
    ( x4 - CenterX ) * RadiusY );
  SweepRange := EndAngle - StartAngle;
  
  if SweepRange <= 0 then
    SweepRange := SweepRange + 2 * PI;
  
  Result := DPoint ( CenterX + RadiusX * cos ( StartAngle ),
    CenterY - RadiusY * sin ( StartAngle ) );
  
  UseMoveTo := True;
  while SweepRange > PI / 2 do
  begin
    DrawArcWithBezier ( CenterX, CenterY, RadiusX, RadiusY,
      StartAngle, PI / 2, UseMoveTo );
    SweepRange := SweepRange - PI / 2;
    StartAngle := StartAngle + PI / 2;
    UseMoveTo := False;
  end;
  if SweepRange >= 0 then
    DrawArcWithBezier ( CenterX, CenterY, RadiusX, RadiusY,
      StartAngle, SweepRange, UseMoveTo );
end;

procedure TPDFCanvas.RawCircle(X, Y, R: Extended);
  const
    b: Extended = 0.5522847498;
begin
  RawMoveto ( X + R, Y );
  RawCurveto ( X + R, Y + b * R, X + b * R, Y + R, X, Y + R );
  RawCurveto ( X - b * R, Y + R, X - R, Y + b * R, X - R, Y );
  RawCurveto ( X - R, Y - b * R, X - b * R, Y - R, X, Y - R );
  RawCurveto ( X + b * R, Y - R, X + R, Y - b * R, X + R, Y );
end;

procedure TPDFCanvas.RawConcat(A, B, C, D, E, F: Extended);
begin
  EndText;
  FF.a := A;
  FF.b := B;
  FF.c := C;
  FF.d := D;
  FF.x := E;
  FF.y := F;
  AppendAction ( FormatFloat ( A ) + ' ' + FormatFloat ( B ) + ' ' +
    FormatFloat ( C ) + ' ' + FormatFloat ( D ) + ' ' +
    FormatFloat ( E ) + ' ' + FormatFloat ( F ) + ' cm' );
end;

procedure TPDFCanvas.RawCurveto(X1, Y1, X2, Y2, X3, Y3: Extended);
begin
  EndText;
  AppendAction ( FormatFloat ( x1 ) + ' ' + FormatFloat ( y1 ) + ' ' + FormatFloat ( x2 ) + ' ' +
    FormatFloat ( y2 ) + ' ' + FormatFloat ( x3 ) + ' ' + FormatFloat ( y3 ) + ' c' );
  FX := X3;
  FY := Y3;
end;

procedure TPDFCanvas.RawEllipse(x1, y1, x2, y2: Extended);
  const
    b = 0.5522847498;
  var
    RX, RY, X, Y: Extended;
begin
  Rx := ( x2 - x1 ) / 2;
  Ry := ( y2 - y1 ) / 2;
  X := x1 + Rx;
  Y := y1 + Ry;
  RawMoveto ( X + Rx, Y );
  RawCurveto ( X + RX, Y + b * RY, X + b * RX, Y + RY, X, Y + RY );
  RawCurveto ( X - b * RX, Y + RY, X - RX, Y + b * RY, X - RX, Y );
  RawCurveto ( X - RX, Y - b * RY, X - b * RX, Y - RY, X, Y - RY );
  RawCurveto ( X + b * RX, Y - RY, X + RX, Y - b * RY, X + RX, Y );
end;

procedure TPDFCanvas.RawExtGlyphTextOut(X, Y, Orientation: Extended; Text:
        PWord; Len: Integer; DX: PExt);
begin
  RawSetTextPosition ( X, Y, Orientation );
  ExtGlyphTextShow ( Text, Len, Dx );
end;

procedure TPDFCanvas.RawExtTextOut(X, Y, Orientation: Extended; TextStr: AnsiString;
        Dx: PExt);
begin
  RawSetTextPosition ( X, Y, Orientation );
  ExtTextShow ( TextStr, Dx );
end;

procedure TPDFCanvas.RawExtWideTextOut(X, Y, Orientation: Extended; Text: PWord; Len: Integer; DX: PExt);
begin
  RawSetTextPosition ( X, Y, Orientation );
  ExtWideTextShow ( Text, Len, Dx );
end;

function TPDFCanvas.RawGetTextWidth(Text: AnsiString): Extended;
var
  i, L: Integer;
  CF: TPDFFont;
  TL: Integer;
  Cr, Sp: Integer;
  B: Byte;
  CodePage: Integer;
  Len: Integer;
  Mem: PWord;
begin
  Result := 0;
  TL := Length ( Text );
  if ( FHorizontalScaling <= 0 ) or ( TL = 0 ) then
    Exit;
  if FCharset = 0 then
  begin
    SetCurrentFont(0);
    CF := FCurrentFont;
    Cr := 0;
    Sp := 0;
    for i := 1 to TL do
    begin
      B := Byte ( Text [ i ] );
      if ( B = 32 ) and ( I <> TL ) then
        Inc ( Sp );
      L := CF.Width [ B ];
      if ( L <> 0 ) or ( i <> TL ) then
        Inc ( Cr );
      Result := Result + L;
    end;
    Result := Result * FCurrentFontSize / 1000;
    if FHorizontalScaling <> 100 then
      Result := Result * FHorizontalScaling / 100;
    if FWordSpace > 0 then
      Result := Result + Sp * FWordSpace;
    if FCharSpace > 0 then
      Result := Result + Cr * FCharSpace;
  end else
  begin
    CodePage := CharSetToCodePage ( FCharset );
    Len := MultiByteToWideChar ( CodePage, 0, PANSIChar ( Text ), TL, nil, 0 );
    if Len = 0 then
      raise EPDFException.Create ( 'Cannot convert text to unicode' );
    GetMem ( Mem, Len * 2 );
    try
      Len := MultiByteToWideChar ( CodePage, 0, PANSIChar ( Text ), TL, PWideChar ( Mem ), Len );
      if Len = 0 then
        raise EPDFException.Create ( 'Cannot convert text to unicode' );
      Result := RawGetWideWidth ( MakeWideString( Mem, Len ));
    finally
      FreeMem ( Mem );
    end;
  end;
end;

function TPDFCanvas.RawGetWideWidth(WideText:WideString): Extended;
var
  CF: TPDFFont;
  L, I: Integer;
  W: PWord;
  Cr: Integer;
  Sp: Integer;
  Text: PWord;
  Len: Integer;
begin
  Result := 0;
  Text := Pointer(PWideCHar(WideText));
  Len := Length(WideText);
  if Len = 0 then
    Exit;
  Sp := 0;
  Cr := 0;
  W := Text;
  CF := ReceiveFont;
  for I := 1 to Len do
  begin
    if ( W^ = 32 ) and ( I <> Len ) then
      Inc ( Sp );
    L := CF.Width [ W^ ];
    if ( L <> 0 ) or ( i <> Len ) then
      Inc ( Cr );
    Result := Result + L;
    Inc ( W );
  end;
  Result := Result * FCurrentFontSize / 1000;
  if FHorizontalScaling <> 100 then
    Result := Result * FHorizontalScaling / 100;
  if FWordSpace > 0 then
    Result := Result + Sp * FWordSpace;
  if FCharSpace > 0 then
    Result := Result + Cr * FCharSpace;
end;

procedure TPDFCanvas.RawLineTo(X, Y: Extended);
begin
  EndText;
  AppendAction ( FormatFloat ( X ) + ' ' + FormatFloat ( Y ) + ' l' );
  FX := X;
  FY := Y;
end;

procedure TPDFCanvas.RawMoveTo(X, Y: Extended);
begin
  EndText;
  AppendAction ( FormatFloat ( X ) + ' ' + FormatFloat ( Y ) + ' m' );
  FX := X;
  FY := Y;
end;

function TPDFCanvas.RawPie(X1, Y1, x2, y2, BegAngle, EndAngle: Extended):
        TDoublePoint;
var
  CX, CY: Extended;
  dp: TDoublePoint;
begin
  dp := RawArc ( X1, Y1, x2, y2, BegAngle, EndAngle );
  CX := X1 + ( x2 - X1 ) / 2;
  CY := Y1 + ( Y2 - Y1 ) / 2;
  RawLineTo ( CX, CY );
  RawMoveTo ( dp.x, dp.y );
  RawLineTo ( CX, CY );
end;

function TPDFCanvas.RawPie(X1, Y1, x2, y2, x3, y3, x4, y4: Extended):
        TDoublePoint;
var
  CX, CY: Extended;
  dp: TDoublePoint;
begin
  dp := RawArc ( X1, Y1, x2, y2, x3, y3, x4, y4 );
  CX := X1 + ( x2 - X1 ) / 2;
  CY := Y1 + ( Y2 - Y1 ) / 2;
  RawLineTo ( CX, CY );
  RawMoveTo ( dp.x, dp.y );
  RawLineTo ( CX, CY );
end;

procedure TPDFCanvas.RawRect(X, Y, W, H: Extended);
begin
  EndText;
  AppendAction ( FormatFloat ( x ) + ' ' + FormatFloat ( y ) + ' ' +
    FormatFloat ( w ) + ' ' + FormatFloat ( h ) + ' re' );
  FX := X;
  FY := Y;
end;

procedure TPDFCanvas.RawRectRotated(X, Y, W, H, Angle: Extended);
var
  xo, yo: Extended;
begin
  RawMoveto ( x, y );
  RotateCoordinate ( w, 0, angle, xo, yo );
  RawLineto ( x + xo, y + yo );
  RotateCoordinate ( w, h, angle, xo, yo );
  RawLineto ( x + xo, y + yo );
  RotateCoordinate ( 0, h, angle, xo, yo );
  RawLineto ( x + xo, y + yo );
  RawLineto ( x, y );
end;

procedure TPDFCanvas.RawSetTextPosition(X, Y, Orientation: Extended);
var
  c, c1, s, g, it: Extended;
begin
  BeginText;
  ReceiveFont;
  g := PI * Orientation / 180.0;
  c := cos ( g ) * FCurrentFontSize;
  c1 := c * FFontScale;
  s := sin ( g ) * FCurrentFontSize;
  if not FItalicEmulated then
  begin
    AppendAction ( FormatFloat ( c1 ) + ' ' + FormatFloat ( s ) + ' ' + FormatFloat ( -s ) + ' ' +
      FormatFloat ( c ) + ' ' + FormatFloat ( x ) + ' ' + FormatFloat ( y ) + ' Tm' );
  end else
  begin
    it := PI/20.0;
    AppendAction ( FormatFloat ( c1 ) + ' ' + FormatFloat ( s ) + ' ' + FormatFloat ( it*c-s ) + ' ' +
        FormatFloat ( it*s+c ) + ' ' + FormatFloat ( x ) + ' ' + FormatFloat ( y ) + ' Tm' );
  end;

  FRealAngle := Orientation;
  TP.x := X;
  TP.y := Y;
end;

procedure TPDFCanvas.RawShowImage(ImageIndex: Integer; X, Y, W, H, Angle:
        Extended);
var
  i, idx: Integer;
  fnd: Boolean;
begin
  if ( ImageIndex < 0 ) or ( ImageIndex >= Length(Eng.Resources.Images) ) then
    raise EPDFException.Create ( SOutOfRange );
  if ( TPDFImage(Eng.Resources.Images [ ImageIndex ]).BitPerPixel = 1 )
    or ( TPDFImage(Eng.Resources.Images [ ImageIndex ]).GrayScale ) then
    FGrayUsed := True
  else
  begin
    FColorUsed := True;
    FRGBUsed := True
  end;
  idx :=0;
  fnd := False;
  for i:= 0 to Length( FLinkedImages ) -1 do
  begin
    if (FLinkedImages[i] = Eng.Resources.Images [ ImageIndex ]) then
    begin
      fnd := True;
      idx := i;
      Break;
    end;
  end;
  if not fnd then
  begin
    idx := Length( FLinkedImages) ;
    setlength(FLinkedImages, idx + 1);
    FLinkedImages[idx] := Eng.Resources.Images [ ImageIndex ] as TPDFImage;
  end;
  GStateSave;
  RawTranslate ( x, y );
  if Abs ( angle ) > 0.001 then
    Rotate ( angle );
  RawConcat ( w, 0, 0, h, 0, 0 );
  AppendAction ( '/Img' + IStr(idx)  + ' Do' );
  GStateRestore;

end;

procedure TPDFCanvas.RawTextOut(X, Y, Orientation: Extended; TextStr: AnsiString);
begin
  RawSetTextPosition ( X, Y, Orientation );
  TextShow ( TextStr );
end;

procedure TPDFCanvas.RawTranslate(XT, YT: Extended);
begin
  RawConcat ( 1, 0, 0, 1, xt, yt );
end;

procedure TPDFCanvas.RawWideTextOut(X, Y, Orientation: Extended; WideText: WideString);
begin
  RawSetTextPosition ( X, Y, Orientation );
  WideTextShow ( WideText );
end;

function TPDFCanvas.ReceiveFont: TPDFFont;
begin
  if not FFontIsChanged then
  begin
    Result := FCurrentFont;
    if Result is TPDFTrueTypeSubsetFont then
      Result := TPDFTrueTypeSubsetFont(Result).Parent;
    Exit;
  end;
  if FIsTrueType then
  begin
    Result := FFonts.GetFontByInfo ( FCurrentFontName, FCurrentFontStyle);
    FItalicEmulated := (fsItalic in FCurrentFontStyle) and (not(fsItalic in  (Result as TPDFTrueTypeFont).Style));
  end else
    Result := FFonts.GetFontByInfo ( FStdFont );
end;

procedure TPDFCanvas.Rectangle(X1, Y1, X2, Y2: Extended);
var
  convw, convh: Extended;
begin
  NormalizeRect ( x1, y1, x2, y2 );
  FPathInited := True;
  convw := ExtToIntX ( X2 ) - ExtToIntX ( X1 );
  convh := ExtToIntY ( Y1 ) - ExtToIntY ( Y2 );
  RawRect ( ExtToIntX ( X1 ), ExtToIntY ( y2 ), convw, convh );
end;

procedure TPDFCanvas.RectRotated(X, Y, W, H, Angle: Extended);
var
  convw, convh: Extended;
begin
  convw := ExtToIntX ( X + W ) - ExtToIntX ( X );
  convh := ExtToIntY ( Y + H ) - ExtToIntY ( Y );
  RawRectRotated ( ExtToIntX ( X ), ExtToIntY ( y ), convw, convh, Angle );
end;

procedure TPDFCanvas.Rotate(Angle: Extended);
var
  vsin, vcos: Extended;
begin
  Angle := Angle * ( PI / 180 );
  vsin := sin ( angle );
  vcos := cos ( angle );
  RawConcat ( vcos, vsin, -vsin, vcos, 0, 0 );
end;

procedure TPDFCanvas.RoundRect(X1, Y1, X2, Y2, W, H: Integer);
  const
    b = 0.5522847498;
  var
    RX, RY: Extended;
begin
  NormalizeRect ( x1, y1, x2, y2 );
  Rx := W / 2;
  Ry := H / 2;
  MoveTo ( X1 + RX, Y1 );
  LineTo ( X2 - RX, Y1 );
  Curveto ( X2 - RX + b * RX, Y1, X2, Y1 + RY - b * RY, X2, Y1 + ry );
  LineTo ( X2, Y2 - RY );
  Curveto ( X2, Y2 - RY + b * RY, X2 - RX + b * RX, Y2, X2 - RX, Y2 );
  LineTo ( X1 + RX, Y2 );
  Curveto ( X1 + RX - b * RX, Y2, X1, Y2 - RY + b * RY, X1, Y2 - RY );
  LineTo ( X1, Y1 + RY );
  Curveto ( X1, Y1 + RY - b * RY, X1 + RX - b * RX, Y1, X1 + RX, Y1 );
  ClosePath;
end;

procedure TPDFCanvas.Scale(SX, SY: Extended);
begin
  RawConcat ( sx, 0, 0, sy, 0, 0 );
end;

procedure TPDFCanvas.SetActiveFont(FontName: String; FontStyle: TFontStyles;
        FontSize: Extended; FontCharset: TFontCharset = ANSI_CHARSET);
begin
  if ( FCurrentFontName <> FontName ) or ( FCurrentFontStyle <> FontStyle ) or
    ( FontSize <> FCurrentFontSize ) or ( not FIsTrueType )then
  begin
    FCurrentFontName := FontName;
    FCurrentFontSize := FontSize;
    FCurrentFontStyle := FontStyle;
    FFontIsChanged := True;
    FCurrentIndex := -1;
    ReceiveFont;
  end;
  if FontCharset = DEFAULT_CHARSET then
    FCharset := GetDefFontCharSet
  else
    FCharset := FontCharset;
  FIsTrueType := True;
end;

procedure TPDFCanvas.SetActiveFont(StdFont: TPDFStdFont; FontSize: Extended);
begin
  if (FStdFont<> StdFont ) or ( FontSize <> FCurrentFontSize ) or (FIsTrueType) then
  begin
    FStdFont := StdFont;
    FCurrentFontSize := FontSize;
    FCurrentIndex := -1;
    FIsTrueType := False;
    FFontIsChanged := True;
    FCharset := 0;
  end;
end;

procedure TPDFCanvas.SetCharacterSpacing(Spacing: Extended);
begin
  Spacing := Spacing / D2P;
  if FCharSpace = Spacing then
    exit;
  BeginText;
  AppendAction ( FormatFloat ( Spacing, true ) + ' Tc' );
  FCharSpace := Spacing;
end;

procedure TPDFCanvas.SetColor(Color: TPDFColor);
var
  S:AnsiString;
begin
  S := PDFColorToStr(Color);
  case Color.ColorSpace of
    csGray:
      begin
        AppendAction( S +' g '+ S +' G');
        FGrayUsed := True;
      end;
    csRGB:
      begin
        AppendAction( S + ' rg '+ S + ' RG');
        FRGBUsed := True;
      end;
  else
    begin
      AppendAction(  S + ' k '+ S + ' K');
      FCMYKUsed := True;
    end;
  end;
end;

procedure TPDFCanvas.SetColorFill(Color: TPDFColor);
begin
  case Color.ColorSpace of
    csGray:
      begin
        AppendAction( FormatFloat(Color.Gray) +' g');
        FGrayUsed := True;
      end;
    csRGB:
      begin
        AppendAction( FormatFloat(Color.Red)+' '+FormatFloat(Color.Green)+' '+FormatFloat(Color.Blue) + ' rg');
        FRGBUsed := True;
      end;
  else
    begin
      AppendAction( FormatFloat(Color.Cyan)+' '+FormatFloat(Color.Magenta)+' '+FormatFloat(Color.Yellow)+' '+FormatFloat(Color.Key)+' k');
      FCMYKUsed := True;
    end;
  end;
end;

procedure TPDFCanvas.SetColorStroke(Color: TPDFColor);
begin
  case Color.ColorSpace of
    csGray:
      begin
        AppendAction( FormatFloat(Color.Gray) +' G');
        FGrayUsed := True;
      end;
    csRGB:
      begin
        AppendAction( FormatFloat(Color.Red)+' '+FormatFloat(Color.Green)+' '+FormatFloat(Color.Blue) + ' RG');
        FRGBUsed := True;
      end;
  else
    begin
      AppendAction( FormatFloat(Color.Cyan)+' '+FormatFloat(Color.Magenta)+' '+FormatFloat(Color.Yellow)+' '+FormatFloat(Color.Key)+' K');
      FCMYKUsed := True;
    end;
  end;
end;


procedure TPDFCanvas.SetCurrentFont(Index: Integer);
var
  I, idx: Integer;
  fnd: Boolean;
begin
  if FFontIsChanged or ( FCurrentIndex <> Index ) then
  begin
    BeginText;
    FTextUsed := True;
    FCurrentFont := ReceiveFont;
    if (Index > 0)and ( FCurrentFont is TPDFTrueTypeFont) then
    begin
      FCurrentFont := TPDFTrueTypeFont(FCurrentFont).SubsetFont[Index-1];
    end;
    fnd := False;
    for I := 0 to Length ( FLinkedFont ) - 1 do
      if FCurrentFont = FLinkedFont [ I ] then
      begin
        fnd := true;
        Break;
      end;
    if not fnd then
    begin
      idx := Length ( FLinkedFont );
      SetLength ( FLinkedFont, idx + 1 );
      FLinkedFont [ idx ] := FCurrentFont;
    end;
    AppendAction ( '/'+FCurrentFont.AliasName + ' 1 Tf' );
    FCurrentFont.FontUsed := True;
    FFontIsChanged := False;
    FCurrentIndex := Index;
    FCurrentFontIndex := FSaveCount;
  end;
end;

procedure TPDFCanvas.SetDash(DashSpec: AnsiString);
begin
  EndText;
  if FCurrentDash <> DashSpec then
  begin
    AppendAction ( DashSpec + ' d' );
    FCurrentDash := DashSpec;
  end;
end;

procedure TPDFCanvas.SetExtGState(State: TPDFGState);
var
  i, idx:Integer;
  fnd: Boolean;
begin
  fnd := False;
  idx := 0;
  for i:= 0 to Length (FLinkedExtGState) -1 do
  begin
    if State = FLinkedExtGState[i] then
    begin
      fnd := True;
      idx := i;
      Break;
    end;
  end;
  if not fnd then
  begin
    idx := Length (FLinkedExtGState);
    SetLength ( FLinkedExtGState, idx + 1);
    FLinkedExtGState[idx] := State;
  end;
  EndText;
  AppendAction('/GS'+IStr(idx)+' gs');
end;

procedure TPDFCanvas.SetFlat(FlatNess: integer);
begin
  EndText;
  AppendAction ( AnsiString(Format ( '%d i', [ FlatNess ] )) );
end;


procedure TPDFCanvas.SetHeight(const Value: Integer);
var
  I: Integer;
begin
  if Factions then
    raise EPDFException.Create ( SPageInProgress );
  I := round ( Value / D2P );
  if FHeight <> I then
  begin
    FHeight := I;
  end;
end;

procedure TPDFCanvas.SetHorizontalScaling(Scale: Extended);
begin
  if FHorizontalScaling = Scale then
    exit;
  BeginText;
  AppendAction ( FormatFloat ( Scale ) + ' Tz' );
  FHorizontalScaling := Scale;
end;

procedure TPDFCanvas.SetIntCharacterSpacing(Spacing: Extended);
begin
  if FCharSpace = Spacing then
    exit;
  BeginText;
  AppendAction ( FormatFloat ( Spacing, true ) + ' Tc' );
  FCharSpace := Spacing;
end;

procedure TPDFCanvas.SetLineCap(LineCap: TPDFLineCap);
begin
  EndText;
  AppendAction ( AnsiString(Format ( '%d J', [ Ord ( LineCap ) ] )) );
end;

procedure TPDFCanvas.SetLineJoin(LineJoin: TPDFLineJoin);
begin
  EndText;
  AppendAction ( AnsiString(Format ( '%d j', [ Ord ( LineJoin ) ] ) ));
end;

procedure TPDFCanvas.SetLineWidth(lw: Extended);
begin
  EndText;
  AppendAction ( FormatFloat ( lw / D2P ) + ' w' );
end;

procedure TPDFCanvas.SetMiterLimit(MiterLimit: Extended);
begin
  EndText;
  MiterLimit := MiterLimit / D2P;
  AppendAction ( FormatFloat ( MiterLimit ) + ' M' );
end;

procedure TPDFCanvas.SetTextRenderingMode(Mode: integer);
begin
  BeginText;
  AppendAction ( AnsiString(Format ( '%d Tr', [ mode ] ) ));
  FRender := Mode;
end;

procedure TPDFCanvas.SetWidth(const Value: Integer);
var
  I: Integer;
begin
  if Factions then
    raise EPDFException.Create ( SPageInProgress );
  I := round ( Value / D2P );
  if FWidth <> I then
    FWidth := I;
end;

procedure TPDFCanvas.SetWordSpacing(Spacing: Extended);
begin
  Spacing := Spacing / D2P;
  if FWordSpace = Spacing then
    exit;
  BeginText;
  AppendAction ( FormatFloat ( Spacing ) + ' Tw' );
  FWordSpace := Spacing;
end;

procedure TPDFCanvas.ShowImage(ImageIndex: Integer; x, y, ScaleX,ScaleY: Extended);
var
  W,H: Extended;
begin
  if ( ImageIndex < 0 ) or ( ImageIndex >= Length(Eng.Resources.Images) ) then
    raise EPDFException.Create ( SOutOfRange );
  W := TPDFImage(Eng.Resources.Images[ImageIndex]).Width;
  H := TPDFImage(Eng.Resources.Images[ImageIndex]).Height;
  ShowImage ( ImageIndex, X, Y, W*ScaleX, H*ScaleY, 0);
end;

procedure TPDFCanvas.ShowImage(ImageIndex: Integer; x, y: Extended);
var
  W,H: Extended;
begin
  if ( ImageIndex < 0 ) or ( ImageIndex >= Length(Eng.Resources.Images) ) then
    raise EPDFException.Create ( SOutOfRange );
  W := TPDFImage(Eng.Resources.Images[ImageIndex]).Width;
  H := TPDFImage(Eng.Resources.Images[ImageIndex]).Height;
  ShowImage ( ImageIndex, X, Y, W, H, 0);
end;

procedure TPDFCanvas.ShowImage(ImageIndex: Integer; x, y, w, h, angle: Extended);
begin
  if ( w = 0 ) or ( h = 0 ) then Exit;
  RawShowImage ( ImageIndex, ExtToIntX ( X ), ExtToIntY ( y ) - h / d2p, w / d2p, h / d2p, angle );
end;

procedure TPDFCanvas.Stroke;
begin
  EndText;
  FPathInited := False;
  AppendAction ( 'S' );
end;

procedure TPDFCanvas.TextBox(Rect: TRect; Text: AnsiString; Hor: THorJust; Vert: TVertJust);
var
  x, y: Extended;
begin
  NormalizeRect ( Rect );
  Y := Rect.Top;
  x := Rect.Left;
  case Hor of
    hjLeft: x := Rect.Left;
    hjRight: x := Rect.Right - GetTextWidth ( Text );
    hjCenter: x := Rect.Left + ( Rect.Right - Rect.Left - GetTextWidth ( Text ) ) / 2;
  end;
  case Vert of
    vjUp: y := Rect.Top;
    vjDown: y := Rect.Bottom - FCurrentFontSize;
    vjCenter: y := Rect.Top + ( Rect.Bottom - Rect.Top - FCurrentFontSize ) / 2;
  end;
  TextOut ( x, y, 0, Text );
end;

procedure TPDFCanvas.TextFromBaseLine(BaseLine: Boolean);
begin
  FBaseLine := BaseLine;
end;

procedure TPDFCanvas.TextOut(X, Y, Orientation: Extended; TextStr: AnsiString);
var
  O: Extended;
  ws, URL: AnsiString;
  I: Integer;
  K: Integer;
  Off: Integer;
  offUrl, LenUrl: Extended;
  fnd: Boolean;
begin                                                                                   
  if TextStr = '' then
    Exit;
  O := GetRawTextHeight;
  if Orientation = 0 then
  begin
    RawTextOut ( ExtToIntX ( X ), ExtToIntY ( Y ) - O, Orientation, TextStr );
    if Self is TPDFPage then
      if TPDFPage(Self).FOwner.FAutoURLCreate then
      begin
        ws := LCase ( TextStr );
        fnd := False;
        for I := 0 to 2 do
          if PosText ( URLDetectStrings [ i ], ws, 1 ) <> 0 then
            fnd := True;
        if fnd then
        begin
          for I := 0 to 2 do
          begin
            K := PosText ( URLDetectStrings [ i ], ws, 1 );
            while K <> 0 do
            begin
              if K <> 1 then
                if ws [ K - 1 ] <> #32 then
                begin
                  OFF := K + Length ( URLDetectStrings [ i ] );
                  K := PosText ( URLDetectStrings [ i ], ws, OFF );
                  Continue;
                end;
              OFF := PosText ( ' ', ws, K + 1 );
              if OFF = 0 then
              begin
                off := Length ( ws );
                URL := Copy ( TextStr, K, OFF - K + 1 );
              end else
                URL := Copy ( TextStr, K, OFF - K );
              offUrl := GetTextWidth ( Copy ( TextStr, 1, K - 1 ) );
              LenUrl := GetTextWidth ( URL );
              if FBaseLine then
                TPDFPage(Self).SetUrl ( Rect ( Trunc ( X + offUrl ), Trunc ( Y ), Trunc ( X + offURL + LenUrl ), Trunc ( Y - FCurrentFontSize * d2p ) ), URL )
              else
                TPDFPage(Self).SetUrl ( Rect ( Trunc ( X + offUrl ), trunc ( Y ), Trunc ( X + offURL + LenUrl ), Trunc ( Y + O * d2p ) ), URL );
              K := PosText ( URLDetectStrings [ i ], ws, OFF );
            end;
          end;
        end;
      end;
  end else
    RawTextOut ( ExtToIntX ( X ) + o * sin ( Orientation * Pi / 180 ),
      ExtToIntY ( Y ) - O * cos ( Orientation * Pi / 180 ), Orientation, TextStr );
end;


procedure TPDFCanvas.SetFontWidthScale(Scale: Extended);
begin
  FFontScale := Scale;
end;

function TPDFCanvas.TextOutBox(LTCornX, LTCornY, Interval, BoxWidth, BoxHeight:
        integer; TextStr: AnsiString;Align:THorJust = hjLeft): Integer;
var
  i, Count, Len: Integer;
  StrLine, OutTxtLine: AnsiString;
  Ch: ANSIChar;
  CWidth, StrWidth, OutWidth: Extended;
  CNT, CodePage: Integer;
  Mem: PWord;
  AlignOffset:Extended;
  St: TStringType;
begin
  if TextStr = '' then
  begin
    Result := 0;
    Exit;
  end;
  Len := Length ( TextStr );
  Result := 0;
  St := GetStringType(TextStr);
  if (st = stASCII) or ((st = stANSI) and(FCurrentFont is TPDFStandardFont)) then
  begin
    BeginText;
    i := 1;
    Count := 0;
    StrWidth := 0;
    OutWidth := 0;
    OutTxtLine := '';
    StrLine := '';
    SetCurrentFont ( 0 );
    while i <= Len do
    begin
      ch := TextStr [ i ];
      if ( ch = #13 ) and ( i < Len ) then
      begin
          if ( TextStr [ i + 1 ] = #10 ) then
            Inc ( i );
          case align of
            hjCenter: AlignOffset :=  (BoxWidth   - GetTextWidth(OutTxtLine + StrLine)) / 2.0;
            hjRight: AlignOffset := BoxWidth - GetTextWidth(OutTxtLine + StrLine);
            else
              AlignOffset := 0;
          end;
          TextOut ( LTCornX + AlignOffset, LTCornY + Count * Interval, 0, {Trim} ( OutTxtLine + StrLine ) );
          Inc ( i );
          OutTxtLine := '';
          OutWidth := 0;
          Inc ( Count );
          StrLine := '';
          Continue;
      end;
      CWidth := FCurrentFont.Width [ Ord ( ch ) ] * FCurrentFontSize / 1000;
      if FHorizontalScaling <> 100 then
        CWidth := CWidth * FHorizontalScaling / 100;
      if CWidth > 0 then
        CWidth := CWidth + FCharSpace
      else
        CWidth := 0;
      if ( ch = ' ' ) and ( FWordSpace > 0 ) and ( i <> Length ( TextStr ) ) then
        CWidth := CWidth + FWordSpace;
      if ( ( OutWidth + StrWidth + CWidth ) < BoxWidth ) and ( i < Len ) and ( not ( Ch in [ #10, #13 ] ) ) then
      begin
        StrWidth := StrWidth + CWidth;
        StrLine := StrLine + ch;
        if ch = ' ' then
        begin
          OutTxtLine := OutTxtLine + StrLine;
          OutWidth := OutWidth + StrWidth;
          StrWidth := 0;
          StrLine := '';
        end;
      end else
      begin
        if i = Len then
        begin
          StrWidth := StrWidth + CWidth;
          StrLine := StrLine + ch;
          OutWidth := 0;
        end;
        if ( OutWidth = 0 ) {or (StrLine <> '')} then
        begin
          case align of
            hjCenter: AlignOffset :=  (BoxWidth   - GetTextWidth(OutTxtLine + StrLine)) / 2.0;
            hjRight: AlignOffset := BoxWidth - GetTextWidth(OutTxtLine + StrLine);
            else
              AlignOffset := 0;
          end;
          TextOut ( LTCornX+ AlignOffset, LTCornY + Count * Interval, 0, {Trim} ( OutTxtLine + StrLine ) );
          StrLine := ch;
          StrWidth := CWidth;
        end else
        begin
          case align of
            hjCenter: AlignOffset :=  (BoxWidth   - GetTextWidth(OutTxtLine)) / 2.0;
            hjRight: AlignOffset := BoxWidth - GetTextWidth(OutTxtLine);
            else
              AlignOffset := 0;
          end;
          TextOut ( LTCornX + AlignOffset, LTCornY + Count * Interval, 0, OutTxtLine );
          StrLine := StrLine + ch;
          StrWidth := StrWidth + CWidth;
        end;
        OutTxtLine := '';
        OutWidth := 0;
        Inc ( Count );
        if ( Count * Interval ) + FCurrentFontSize > BoxHeight then
        begin
          Result := i;
          exit;
        end;
      end;
      Inc ( i );
    end;
    Result:= i;

  end else
  begin
    CodePage := CharSetToCodePage ( FCharset );
    CNT := MultiByteToWideChar ( CodePage, 0, PANSIChar ( TextStr ), Len, nil, 0 );
    if CNT = 0 then
      raise EPDFException.Create ( 'Cannot convert text to unicode' );
    GetMem ( Mem, CNT * 2 );
    try
      CNT := MultiByteToWideChar ( CodePage, 0, PANSIChar ( TextStr ), Len, PWideChar ( Mem ), CNT );
      if CNT = 0 then
        raise EPDFException.Create ( 'Cannot convert text to unicode' );
      Result := WideTextOutBox ( LTCornX, LTCornY, Interval, BoxWidth, BoxHeight, MakeWideString(Mem, CNT ));
    finally
      FreeMem ( Mem );
    end;
  end;
end;

procedure TPDFCanvas.TextShow(TextStr: AnsiString);
var
  s: AnsiString;
  TL: Integer;
  CodePage: Integer;
  Len: Integer;
  Mem: PWord;
  i: Integer;
  TextWidth: Extended;
  st: TStringType;
begin
  FTextUsed := True;
  for i := 1 to Length ( TextStr ) do
    if TextStr [ i ] < #32 then
      TextStr [ i ] := #32;
  St := GetStringType(TextStr);
  if (st = stASCII) or ((st = stANSI) and(FCurrentFont is TPDFStandardFont)) then
  begin
    SetCurrentFont ( 0 );
    FCurrentFont.FillUsed ( TextStr );
    s := EscapeSpecialChar ( TextStr );
    AppendAction ( '(' + s + ') Tj' );
    if ( ( not ( fsUnderLine in FCurrentFontStyle ) ) and ( not ( fsStrikeOut in FCurrentFontStyle ) ) ) then
      Exit;
    TextWidth := RawGetTextWidth ( TextStr );
    PaintTextLines ( TextWidth );
  end else
  begin
    TL := Length ( TextStr );
    CodePage := CharSetToCodePage ( FCharset );
    Len := MultiByteToWideChar ( CodePage, 0, PANSIChar ( TextStr ), TL, nil, 0 );
    if Len = 0 then
      raise EPDFException.Create ( 'Cannot convert text to unicode' );
    GetMem ( Mem, Len * 2 );
    try
      Len := MultiByteToWideChar ( CodePage, 0, PANSIChar ( TextStr ), TL, PWideChar ( Mem ), Len );
      if Len = 0 then
        raise EPDFException.Create ( 'Cannot convert text to unicode' );
      WideTextShow ( MakeWideString(mem, Len ));
    finally
      FreeMem ( Mem );
    end;
  end;
end;

procedure TPDFCanvas.Translate(XT, YT: Extended);
begin
  RawTranslate ( ExtToIntX ( XT ), ExtToIntY ( YT ) );
end;

procedure TPDFCanvas.WideTextOut(X, Y, Orientation: Extended; WideText:WideString);
var
  O: Extended;
  ws, URL: AnsiString;
  I, J: Integer;
  K: Integer;
  Off: Integer;
  offUrl, LenUrl: Extended;
  fnd: Boolean;
  T: PWord;
  Text:PWord;
  Len: Integer;
begin
  Text := Pointer(PWideChar(WideText));
  Len := Length(WideText);
  if Len = 0 then
    Exit;
  O := GetRawTextHeight;
  if Orientation = 0 then
  begin
    RawWideTextOut ( ExtToIntX ( X ), ExtToIntY ( Y ) - o, Orientation, WideText );
    if Self is TPDFPage then
      if TPDFPage(Self).FOwner.FAutoURLCreate then
      begin
        ws := '';
        T := Text;
        for I := 1 to Len do
        begin
          ws := ws + ANSIChar ( Byte ( T^ ) );
          Inc ( T );
        end;
        ws := LCase ( ws );
        fnd := False;
        for I := 0 to 2 do
          if PosText ( URLDetectStrings [ i ], ws, 1 ) <> 0 then
            fnd := True;
        if fnd then
        begin
          for I := 0 to 2 do
          begin
            OFF := 1;
            K := PosText ( URLDetectStrings [ i ], ws, 1 );
            while K <> 0 do
            begin
              if K <> 1 then
                if ws [ K - 1 ] <> #32 then
                begin
                  OFF := PosText ( ' ', ws, OFF ) + 1;
                  K := PosText ( URLDetectStrings [ i ], ws, OFF );
                  Continue;
                end;
              OFF := PosText ( ' ', ws, K + 1 );
              T := Text;
              Inc ( T, K - 1 );
              URL := '';
              if OFF = 0 then
              begin
                off := Length ( ws );
                for J := 1 to OFF - K + 1 do
                begin
                  URL := URL + ANSIChar ( Byte ( T^ ) );
                  Inc ( T );
                end;
              end else
                for J := 1 to OFF - K do
                begin
                  URL := URL + ANSIChar ( Byte ( T^ ) );
                  Inc ( T );
                end;
              offUrl := GetWideTextWidth ( MakeWideString(Text, K - 1 ));
              LenUrl := GetTextWidth ( URL );
              if FBaseLine then
                TPDFPage(Self).SetUrl ( Rect ( Trunc ( X + offUrl ), Trunc ( Y ), Trunc ( X + offURL + LenUrl ), Trunc ( Y - FCurrentFontSize * d2p ) ), URL )
              else
                TPDFPage(Self).SetUrl ( Rect ( Trunc ( X + offUrl ), trunc ( Y ), Trunc ( X + offURL + LenUrl ), Trunc ( Y + O * d2p ) ), URL );
              K := PosText ( URLDetectStrings [ i ], ws, OFF );
            end;
          end;
        end;
      end;
  end else
    RawWideTextOut ( ExtToIntX ( X ) + O * sin ( Orientation * Pi / 180 ),
      ExtToIntY ( Y ) - O * cos ( Orientation * Pi / 180 ), Orientation, WideText );
end;

function TPDFCanvas.WideTextOutBox(LTCornX, LTCornY, Interval, BoxWidth, BoxHeight: integer;WideText:WideString): Integer;
var
  BeforeLastWordWidth, LastWordWidth: Extended;
  i, OutLen: Integer;
  CWidth, StrWidth: Extended;
  PW: PWord;
  CU: Word;
  StartLine, T: PWord;
  CF: TPDFFont;
  LastWord: PWord;
  LineCount: Integer;
  BeforeLastWordChar: Integer;
  Base: Boolean;
  NX: Boolean;
  MaxLine: Integer;
  Text: PWord;
  Len: Integer;
begin
  Text := Pointer(PWideChar(WideText));
  Len := Length(WideText);
  if Len = 0 then
  begin
    Result := 0;
    Exit;
  end;
  Result := 0; //
  Base := FBaseLine;
  i := 1;
  PW := Text;
  StartLine := Text;
  OutLen := 0;
  BeforeLastWordWidth := 0;
  LastWordWidth := 0;
  LineCount := 0;
  LastWord := nil;
  StrWidth := BoxWidth / d2p;
  BeforeLastWordChar := 0;
  if BoxHeight < FCurrentFontSize then
    Exit;
  MaxLine := trunc ( ( BoxHeight - FCurrentFontSize ) / Interval );
  CF := ReceiveFont;
  while i <= Len do
  begin
    CU := PW^;
    CWidth := CF.Width [ CU ];
    CWidth := CWidth * FCurrentFontSize / 1000;
    if FHorizontalScaling <> 100 then
      CWidth := CWidth * FHorizontalScaling / 100;
    if CWidth > 0 then
      CWidth := CWidth + FCharSpace
    else
      CWidth := 0;
    if ( cu = 32 ) and ( FWordSpace > 0 ) and ( i <> Len ) then
      CWidth := CWidth + FWordSpace;
    if ( BeforeLastWordWidth + LastWordWidth + CWidth < StrWidth ) and ( not ( ( CU = 13 ) or ( CU = 10 ) ) ) and ( i <> Len ) then
    begin
      Inc ( OutLen );
      if CU = 32 then
      begin
        BeforeLastWordWidth := BeforeLastWordWidth + LastWordWidth + CWidth;
        LastWordWidth := 0;
        BeforeLastWordChar := OutLen;
        LastWord := PW;
        Inc ( LastWord );
      end else
        LastWordWidth := CWidth + LastWordWidth;
    end else
    begin
      if ( CU = 13 ) and ( i <> Len ) then
      begin
        T := PW;
        Inc ( T );
        if T^ = 10 then
        begin
          Inc ( I );
          Inc ( PW );
        end;
      end;
      if ( CU = 10 ) or ( CU = 13 ) or ( CU = 32 ) or ( i = Len ) then
      begin
        NX := ( BeforeLastWordWidth + LastWordWidth + CWidth > StrWidth ) and ( i = Len );
        if ( i = Len ) and not ( ( CU = 10 ) or ( CU = 13 ) or ( CU = 32 ) or NX ) then
          Inc ( OutLen );
        if OutLen <> 0 then
          WideTextOut ( LTCornX, LTCornY + Interval * LineCount, 0, MakeWideString(StartLine, OutLen ));
        Inc ( LineCount );
        if NX then
          OutLen := 1
        else
          OutLen := 0;
        BeforeLastWordChar := 0;
        BeforeLastWordWidth := 0;
        LastWordWidth := 0;
        LastWord := nil;
        StartLine := PW;
        if not NX then
          Inc ( StartLine );
      end else
      begin
        if LastWord <> nil then
        begin
          WideTextOut ( LTCornX, LTCornY + Interval * LineCount, 0, MakeWideString(StartLine, BeforeLastWordChar - 1 ));
          StartLine := LastWord;
          LastWordWidth := LastWordWidth + CWidth;
          OutLen := OutLen - BeforeLastWordChar + 1;
          BeforeLastWordChar := 0;
          BeforeLastWordWidth := 0;
          LastWord := nil;
          Inc ( LineCount );
        end else
        begin
          if OutLen <> 0 then
            WideTextOut ( LTCornX, LTCornY + Interval * LineCount, 0, MakeWideString(StartLine, OutLen ));
          Inc ( LineCount );
          OutLen := 1;
          BeforeLastWordChar := 0;
          BeforeLastWordWidth := 0;
          LastWordWidth := CWidth;
          LastWord := nil;
          StartLine := PW;
        end;
      end;
    end;
    if MaxLine < LineCount then
    begin
      Result := i;
      FBaseLine := Base;
      Exit;
    end;
    Inc ( i );
    Inc ( PW );
  end;
  if OutLen <> 0 then
    WideTextOut ( LTCornX, LTCornY + Interval * LineCount, 0, MakeWideString(StartLine, OutLen ));
  Result := i;
  FBaseLine := Base;
end;


procedure TPDFCanvas.WideTextShow(WideText:WideString);
var
  Cr, Sp: Integer;
  L,i: Integer;
  TL: Extended;
  Calc: Boolean;
  Len: Integer;
  BaseFont: TPDFTrueTypeFont;
  Ch:PNewCharInfo;
  Unicode:Word;
  OS: AnsiString;
begin
  if Not FIsTrueType then
    raise EPDFException.Create(SAvailableForTrueTypeFontOnly);
  Len := Length(WideText);
  if Len = 0 then
    Exit;
  Calc := ( fsUnderline in FCurrentFontStyle ) or ( fsStrikeOut in FCurrentFontStyle );
  Cr := 0;
  Sp := 0;
  FTextUsed := True;
  BaseFont := ReceiveFont as TPDFTrueTypeFont;
  Unicode := Word(WideText[1]);
  Ch := BaseFont.CharByUnicode[Unicode];
  SetCurrentFont(Ch^.FontIndex);
  OS := '';
  TL := 0;
  for i := 1 to Len do
  begin
    if i <> 1 then
    begin
      Unicode := Word(WideText[i]);
      Ch := BaseFont.CharByUnicode[Unicode];
    end;
    if Ch^.FontIndex = 0 then
      BaseFont.UsedChar(Byte(Ch^.NewCharacter));
    if FCurrentIndex <> Ch^.FontIndex then
    begin
      AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
      SetCurrentFont(Ch^.FontIndex);
      OS := Ch^.NewCharacter;
    end else
      OS := OS + Ch^.NewCharacter;
    if Calc then
    begin
      L := Ch^.Width;
      if ( L <> 0 ) or ( len <> 1 ) then
        Inc ( Cr );
      TL := TL + L;
      if ( Unicode = 32 ) and ( Len <> 1 ) then
        Inc ( Sp );
    end;
  end;
  AppendAction ( '(' + EscapeSpecialChar ( OS ) + ') Tj' );
  if not Calc then
    Exit;
  TL := TL * FCurrentFontSize / 1000;
  if FHorizontalScaling <> 100 then
    TL := TL * FHorizontalScaling / 100;
  if FWordSpace > 0 then
    TL := TL + Sp * FWordSpace;
  if FCharSpace > 0 then
    TL := TL + Cr * FCharSpace;
  PaintTextLines ( TL );
end;

{$ifdef UNICODE}
function TPDFCanvas.TextOutBox(LTCornX, LTCornY, Interval, BoxWidth, BoxHeight:integer; TextStr: string;Align:THorJust = hjLeft): Integer;
begin
  if FIsTrueType then
    Result := WideTextOutBox(LTCornX, LTCornY, Interval, BoxWidth, BoxHeight,TextStr)
  else
    Result := TextOutBox(LTCornX, LTCornY, Interval, BoxWidth, BoxHeight,AnsiString(TextStr),Align);
end;

procedure TPDFCanvas.TextOut(X, Y, Orientation: Extended; TextStr: string);
begin
  if FIsTrueType then
    WideTextOut( X, Y, Orientation, TextStr)
  else
    TextOut( X,Y,Orientation, AnsiString(TextStr));
end;
function TPDFCanvas.GetTextRowCount(BoxWidth: Integer; TextStr: string): Integer;
begin
  if FIsTrueType then
    Result := GetWideTextRowCount( BoxWidth, TextStr)
  else
    Result := GetTextRowCount(BoxWidth, AnsiString(TextStr));
end;

function TPDFCanvas.GetTextWidth(Text: string): Extended;
begin
  if FIsTrueType then
    Result := GetWideTextWidth( Text)
  else
    Result := GetTextWidth( AnsiString(Text));
end;
procedure TPDFCanvas.ExtTextOut(X, Y, Orientation: Extended; TextStr: string; Dx: PExt);
begin
  if FIsTrueType then
    ExtWideTextOut(x,  y, Orientation, TextStr, DX)
  else
    ExtTextOut( X, Y, Orientation, AnsiString( TextStr), Dx);
end;
{$endif}



{ TPDFPage }

{
*********************************** TPDFPage ***********************************
}
constructor TPDFPage.Create(Engine:TPDFEngine;Owner: TPDFPages; FontManager: TPDFFonts);
begin
  inherited Create( Engine, FontManager );
  FOwner := Owner;
  FThumbnail := -1;
  Size := psA4;
  FAnnotations := nil;
  FBCDStart := False;
end;

destructor TPDFPage.Destroy;
var
  i: Integer;
begin
  if FMF <> nil then
  begin
    FCanvas.Free;
    FMF.Free;
  end;
  for i := 0 to Length(FMeta) -1 do
    FMeta[i].Free;
  for i:= 0 to Length(FAnnotations) -1 do
    FAnnotations[i].Free;
  inherited;
end;

procedure TPDFPage.Save;
var
  ResourseID, ContentID: Integer;
  I:Integer;
  MS: TMemoryStream;
  CS: TCompressionStream;
  S: AnsiString;
begin
  if FBCDStart then
     TurnOffOptionalContent;
  if FTextInited then
    EndText;
  for I := FSaveCount downto 1 do
    GStateRestore;
  FSaveCount := 2;
  GStateRestore;

  for I := 0 to Length( FMeta) - 1 do
    FMeta[I].Save;

  for I := 0 to Length( FAnnotations) - 1 do
    FAnnotations [ I ] .Save;
  ResourseID := Eng.GetNextID;
  Eng.StartObj( ResourseID);

  if Eng.PDFACompatibile then
    if FRGBUsed or FGrayUsed or FCMYKUsed then
    begin
      Eng.SaveToStream('/ColorSpace <<');
      if FGrayUsed  then
        Eng.SaveToStream('/DefaultGray '+ GetRef( Eng.GrayICCObject ));
      if FRGBUsed  then
        Eng.SaveToStream('/DefaultRGB '+ GetRef( Eng.RGBICCObject ));
      if FCMYKUsed  then
        Eng.SaveToStream('/DefaultCMYK '+ GetRef( Eng.CMYKICCObject ));
      Eng.SaveToStream('>>');
    end;

  Eng.SaveToStream ( '/ProcSet [/PDF ', False );
  if FTextUsed then
    Eng.SaveToStream ( '/Text ', False );
  if FGrayUsed then
    Eng.SaveToStream ( '/ImageB ', False );
  if FColorUsed then
    Eng.SaveToStream ( '/ImageC ', False );
  Eng.SaveToStream ( ']' );
  if Length ( FLinkedFont ) > 0 then
  begin
    Eng.SaveToStream ( '/Font <<' );
    for I := 0 to Length ( FLinkedFont ) - 1 do
        Eng.SaveToStream ( '/' + FLinkedFont [ I ].AliasName + ' ' + FLinkedFont [ I ].RefID );
    Eng.SaveToStream ( '>>' );
  end;

  if Length ( FLinkedExtGState ) > 0 then
  begin
    Eng.SaveToStream ( '/ExtGState <<' );
    for I := 0 to Length ( FLinkedExtGState ) - 1 do
        Eng.SaveToStream ( '/GS' + IStr( I ) +' '+ FLinkedExtGState [ I ].RefID );
    Eng.SaveToStream ( '>>' );
  end;

  if Length ( FOP ) > 0 then
  begin
    Eng.SaveToStream ( '/Properties <<' );
    for I := 0 to Length ( FOP ) - 1 do
        Eng.SaveToStream ( '/OC' + IStr( I ) +' '+ FOP [ I ].RefID );
    Eng.SaveToStream ( '>>' );
  end;

  if Length ( FPatterns ) > 0 then
  begin
    Eng.SaveToStream ( '/Pattern <<' );
    for I := 0 to Length ( FPatterns ) - 1 do
        Eng.SaveToStream ( '/Ptn' + IStr(I) + ' ' + FPatterns [ I ].RefID );
    Eng.SaveToStream ( '>>' );
  end;

  if ( Length(FLinkedImages) > 0 ) or ( Length(FMeta) >0 ) or ( Length(FForms) >0 ) then
  begin
    Eng.SaveToStream ( '/XObject <<' );
    for I := 0 to Length(FLinkedImages) - 1 do
      Eng.SaveToStream ( '/Img' + IStr( I ) + ' ' + TPDFImage ( FLinkedImages [ I ] ).RefID );
    for I:=0 to Length(FForms) -1 do
      Eng.SaveToStream ( '/Frm' + IStr ( I ) + ' ' + FForms [ I ].RefID );
    for I:=0 to Length(FMeta) -1 do
      Eng.SaveToStream ( '/IF' + IStr ( I ) + ' ' + FMeta [ I ].RefID );
    Eng.SaveToStream ( '>>' );
  end;
  Eng.CloseObj;

  ContentID := Eng.GetNextID;
  Eng.StartObj ( ContentID );
  if Eng.Compression = ctFlate then
  begin
    MS := TMemoryStream.Create;
    try
      CS := TCompressionStream.Create ( clDefault, MS );
      try
        FContent.SaveToStream ( CS );
      finally
        CS.Free;
      end;
      Eng.SaveToStream ( '/Length ' + IStr ( CalcAESSize( Eng.SecurityInfo.State,MS.size ) ) );
      Eng.SaveToStream ( '/Filter /FlateDecode' );
      Eng.StartStream;
      MS.Position := 0;
      CryptStreamToStream ( Eng.SecurityInfo,MS, Eng.Stream, ContentID );
    finally
      MS.Free;
    end;
  end else
  begin
    S := FContent.Text;
    Eng.SaveToStream ( '/Length ' + IStr ( CalcAESSize(Eng.SecurityInfo.State, Length( S ) ) ) );
    Eng.StartStream;
    CryptStringToStream(Eng.SecurityInfo,Eng.Stream, S,ContentID );
  end;
  Eng.CloseStream;
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /Page' );
  Eng.SaveToStream ( '/Parent ' + GetRef ( FOwner.ID )  );
  Eng.SaveToStream ( '/MediaBox [0 0 ' + IStr ( FWidth ) + ' ' + IStr ( FHeight ) + ']' );
  if FThumbnail >= 0 then
    Eng.SaveToStream ( '/Thumb ' + Eng.Resources.Images[ FThumbnail ].RefID);
  case FRotate of
      pr90: Eng.SaveToStream ( '/Rotate 90' );
      pr180: Eng.SaveToStream ( '/Rotate 180' );
      pr270: Eng.SaveToStream ( '/Rotate 270' );
    end;
    Eng.SaveToStream ( '/Resources ' + GetRef ( ResourseID )  );
    Eng.SaveToStream ( '/Contents [' + GetRef ( ContentID ) + ']' );

  if Length( FAnnotations) <> 0 then
  begin
    Eng.SaveToStream ( '/Annots [', false );
    for I := 0 to Length( FAnnotations) - 1 do
      Eng.SaveToStream ( FAnnotations [ I ] .RefID + ' ', false );
    Eng.SaveToStream ( ']' );
  end;
  Eng.CloseObj;
end;

procedure TPDFPage.SetOrientation(const Value: TPDFPageOrientation);
begin
  if Factions then
    raise EPDFException.Create ( SPageInProgress );
  FOrientation := Value;
  if Value = poPagePortrait then
    if FWidth > FHeight then
      swp ( FWidth, FHeight );
  if Value = poPageLandScape then
    if FWidth < FHeight then
      swp ( FWidth, FHeight );
end;

procedure TPDFPage.SetSize(const Value: TPDFPageSize);
const
  val:array[0..37] of Integer = (792,612,842,595,1190,842,1008,612,728,516,649,459,792,595,1031,728,595,419,936,612,756,522,
1031,728,708,499,459,323,623,312,540,279,639,279,684,297,747,324);
begin
  if Factions then
    raise EPDFException.Create ( SPageInProgress );
  FHeight := Val[Ord(Value) shl 1];
  FWidth := Val[Ord(Value) shl 1 + 1];
end;

procedure TPDFPage.SetThumbnail(const Value: Integer);
begin
  if Value <= Length( Eng.Resources.Images) then
    EPDFException.Create( SOutOfRange);
  FThumbnail := Value;
end;


function TPDFPage.SetLinkToPage ( ARect: TRect; PageIndex,
  TopOffset: Integer ): TPDFAnnotation;
begin
  Result := TPDFActionAnnotation.Create ( Self, ARect,
    TPDFGoToPageAction.Create(TPDFActions(FOwner.FActions), PageIndex, TopOffset, True));
  Result.BorderStyle:='[]';
end;

function TPDFPage.SetUrl ( ARect: TRect; URL: AnsiString ): TPDFAnnotation;
begin
  Result := TPDFActionAnnotation.Create ( Self, ARect,
    TPDFURLAction.Create(TPDFActions(FOwner.FActions), URL));
  Result.BorderStyle:='[]';
end;

procedure TPDFPage.PlayMetaFile(MF: TMetafile; x, y, XScale, YScale:Extended;
  OptionalContent: TOptionalContent);
var
  P: TPDFForm;
  Pars: TEMWParser;
  S: TSize;
  NMF: TMetafile;
  MFC: TMetafileCanvas;
  AX: Extended;
  XS, YS: Integer;
  W, H: Integer;
  Append: Boolean;
  I: Integer;
begin
  Append := False;
  AX := 1;
  P := TPDFForm.Create(Eng,  FFonts, OptionalContent);
  P.FWidth := FWidth;
  P.FHeight := FHeight;
  P.FRes := FRes;
  P.D2P := D2P;
  if TPDFEMFParseOptions( FOwner.EMFOptions).ReDraw then
  begin
    NMF := TMetafile.Create;
    try
      if TPDFEMFParseOptions(FOwner.EMFOptions).UseScreen then
      begin
        XS := GetDeviceCaps ( TPDFEMFParseOptions(FOwner.EMFOptions).UsedDC, HORZRES );
        YS := GetDeviceCaps ( TPDFEMFParseOptions(FOwner.EMFOptions).UsedDC, VERTRES );
        if ( MF.Height > YS ) or ( MF.Width > XS ) then
        begin
          AX := Min ( YS / MF.Height, XS / MF.Width );
          NMF.Height := Round ( MF.Height * AX );
          NMF.Width := Round ( MF.Width * AX );
        end else
        begin
          NMF.Height := MF.Height;
          NMF.Width := MF.Width;
        end;
      end else
      begin
        NMF.Height := MF.Height;
        NMF.Width := MF.Width;
      end;
      W := NMF.Width;
      H := NMF.Height;
      MFC := TMetafileCanvas.Create ( NMF, TPDFEMFParseOptions(FOwner.EMFOptions).UsedDC );
      try
        if AX = 1 then
          MFC.Draw ( 0, 0, MF )
        else
          MFC.StretchDraw ( Rect ( 0, 0, W - 1, H - 1 ), MF );
      finally
        MFC.Free;
      end;
      Pars := TEMWParser.Create ( Eng,FFonts, P, TPDFEMFParseOptions(FOwner.EMFOptions),
        FOwner.Images, FOwner.Patterns, Eng.Resolution, P.FContent );
      try
        MF.Enhanced := True;
        Pars.LoadMetaFile ( NMF );
        S := Pars.GetMax;
        if ( S.cx <> 0 ) and ( S.cy <> 0 ) then
          Append := True;
        if Append then
        begin
          P.Width := abs ( S.cx );
          P.Height := abs ( S.cy );
          Pars.Execute;
        end;
      finally
        Pars.Free;
      end;
    finally
      NMF.Free;
    end;
  end else
  begin
    Pars := TEMWParser.Create ( Eng, FFonts, P, TPDFEMFParseOptions(FOwner.EMFOptions), FOwner.Images,
      FOwner.Patterns, Eng.Resolution, P.FContent );
    try
      MF.Enhanced := True;
      Pars.LoadMetaFile ( MF );
      S := Pars.GetMax;
      if ( S.cx <> 0 ) and ( S.cy <> 0 ) then
        Append := True;
      if Append then
      begin
        P.Width := abs ( S.cx );
        P.Height := abs ( S.cy );
        Pars.Execute;
      end;
    finally
      Pars.Free;
    end;
  end;
  if Append then
  begin
    EndText;
    I := Length( FMeta);
    SetLength(FMeta, I +1);
    FMeta[I] := P;
    AppendAction ( 'q /IF' + IStr ( i ) + ' Do Q' );
    P.FMatrix.x := x / D2P;
    P.FMatrix.y := ( Height - P.Height * YScale / AX - y ) / D2P;
    P.FMatrix.a := XScale / AX;
    P.FMatrix.d := YScale / AX;
  end;
end;

procedure TPDFPage.PlayMetaFile(MF: TMetaFile;OptionalContent: TOptionalContent);
begin
  PlayMetaFile ( MF, 0, 0, 1, 1, OptionalContent );
end;

procedure TPDFPage.SetWidth(const Value: Integer);
var
  W, I:Integer;
begin
  W := FWidth;
  inherited SetWidth(Value);
  if W <> FWidth then
  begin
    if FMF <> nil then
      if not FAskCanvas then
      begin
        I := GetDeviceCaps ( TPDFEMFParseOptions(FOwner.FEMFOptions).UsedDC, LOGPIXELSX );
        FMF.Width := MulDiv ( FWidth, I, 72 );
        FCanvas.Free;
        FCanvas := TMetafileCanvas.Create ( FMF, TPDFEMFParseOptions(FOwner.EMFOptions).UsedDC );
      end;
  end;
end;

procedure TPDFPage.SetHeight(const Value: Integer);
var
  H, I:Integer;
begin
  H := FHeight;
  inherited SetHeight(Value);
  if H <> FHeight then
  begin
    if FMF <> nil then
      if not FAskCanvas then
      begin
        I := GetDeviceCaps ( TPDFEMFParseOptions(FOwner.EMFOptions).UsedDC, LOGPIXELSX );
        FMF.Height := MulDiv ( FHeight, I, 72 );
        FCanvas.Free;
        FCanvas := TMetafileCanvas.Create ( FMF, TPDFEMFParseOptions(FOwner.EMFOptions).UsedDC );
      end;
  end;
end;

procedure TPDFPage.TurnOffOptionalContent;
begin
  AppendAction('EMC');
  FBCDStart := False;
end;

procedure TPDFPage.TurnOnOptionalContent(
  OptionalContent: TOptionalContent);
var
  i: Integer;
  fnd: Boolean;
  idx: Integer;
begin
  idx := 0; 
  fnd := False;
  for i := 0 to Length( FOP) -1 do
    if FOP[i] = OptionalContent then
    begin
      fnd := True;
      idx := i;
      Break;
    end;
  if not fnd then
  begin
    idx := Length(FOP);
    SetLength( FOP,idx + 1);
    FOP[idx] := OptionalContent;
  end;
  AppendAction('/OC /OC'+IStr(idx)+' BDC');
  FBCDStart := True;
end;


procedure TPDFPage.CloseCanvas(AskedCanvas: Boolean);
var
  s: AnsiString;
  Pars: TEMWParser;
  SZ: TSize;
  Z: Boolean;
begin
  if FMF = nil then
    Exit;
  FCanvas.Free;
  Z := False;
  if AskedCanvas then
  begin
    Pars := TEMWParser.Create ( Eng, FFonts, Self, TPDFEMFParseOptions(FOwner.EMFOptions),
      FOwner.Images, FOwner.Patterns, Eng.Resolution, FContent );
    try
      FMF.Enhanced := True;
      Pars.LoadMetaFile ( FMF );
      SZ := Pars.GetMax;
      if ( SZ.cx <= 0 ) or ( SZ.cy <= 0 ) then
        Z := True;
      if not Z then
      begin
        EndText;
        s := FContent.Text;
        FContent.Clear;
        FFontIsChanged := True;
        Pars.Execute;
        EndText;
        if TPDFEMFParseOptions(FOwner.EMFOptions).CanvasOver then
          FContent.Text := FContent.Text + #13 + s
        else
          FContent.Text := s + #13 + FContent.Text;
      end;
    finally
      Pars.Free;
    end;
  end;
  FMF.Free;
  FMF := nil;
  FAskCanvas := False;
end;

procedure TPDFPage.PlayForm(Form: TPDFForm; X, Y, XScale, YScale: Extended);
var
  i, idx: Integer;
  fnd: Boolean;
begin
  fnd := False;
  idx := 0;
  for i := 0 to Length( FForms) -1 do
    if FForms[i] = Form then
    begin
      fnd := True;
      idx := i;
      Break;
    end;
  if not fnd then
  begin
    idx := Length(FForms);
    SetLength(FForms, idx + 1 );
    FForms[idx] := Form;
  end;
  EndText;
  GStateSave;
  AppendAction ( FormatFloat ( XScale ) + ' 0 0 '+ FormatFloat ( YScale ) + ' ' +
    FormatFloat ( x / D2P ) + ' ' + FormatFloat ( ( Height - Form.Height * YScale - y ) / D2P ) + ' cm' );
  AppendAction ( '/Frm'+IStr(idx)+' Do');
  GStateRestore;
end;

procedure TPDFPage.SetPattern(Pattern: TPDFPattern);
var
  i, idx: Integer;
  fnd: Boolean;
begin
  fnd := False;
  idx := 0;
  for i := 0 to Length( FPatterns) -1 do
    if FPatterns[i] = Pattern then
    begin
      fnd := True;
      idx := i;
      Break;
    end;
  if not fnd then
  begin
    idx := Length(FPatterns);
    SetLength(FPatterns, idx + 1 );
    FPatterns[idx] := Pattern;
  end;
  EndText;       
  AppendAction ( '/Pattern cs /Ptn'+IStr(idx)+' scn');
end;


{ TPDFPages }

constructor TPDFPages.Create(Owner:TObject;Engine: TPDFEngine; FontManager: TPDFFonts);
begin
  inherited Create ( Engine );
  FList := TList.Create;
  FCurrentPage := nil;
  FCurrentPageIndex := -1;
  FFonts := FontManager;
  FEMFOptions := TPDFEMFParseOptions.Create;
  FAskCanvas := False;
  FOwner := Owner;
end;

destructor TPDFPages.Destroy;
var
  i: Integer;
begin
  For i:= 0 to FList.Count - 1 do
    TPDFPage(FList[i]).Free;
  FList.Free;
  FEMFOptions.Free;
  inherited;
end;

procedure TPDFPages.Add;
begin
  if FList.Count <> 0 then
    CloseCanvas;
  FCurrentPage := TPDFPage.Create( FEngine, Self, FFonts );
  FCurrentPageIndex := FList.Add( FCurrentPage );
  CreateCanvas;
end;

procedure TPDFPages.Clear;
var
  i: Integer;
begin
  For i:= 0 to FList.Count - 1 do
    TPDFPage(FList[i]).Free;
  FList.Clear;
  FCurrentPage := nil;
  FCurrentPageIndex := -1;
  inherited;
end;

procedure TPDFPages.CloseCanvas;
begin
  FCurrentPage.CloseCanvas(FAskCanvas);
  FAskCanvas := False;
end;

procedure TPDFPages.CreateCanvas;
var
  I, J: Integer;
begin
  if FCurrentPage.FMF = nil then
  begin
    FCurrentPage.FMF := TMetafile.Create;
    FAskCanvas := False;
    I := GetDeviceCaps ( TPDFEMFParseOptions(EMFOptions).UsedDC, LOGPIXELSX );
    J := GetDeviceCaps ( TPDFEMFParseOptions(EMFOptions).UsedDC, LOGPIXELSY );
    FCurrentPage.FMF.Height := MulDiv ( FCurrentPage.FHeight, J, 72 );
    FCurrentPage.FMF.Width := MulDiv ( FCurrentPage.FWidth, I, 72 );
    FCurrentPage.FCanvas := TMetafileCanvas.Create ( FCurrentPage.FMF, TPDFEMFParseOptions(EMFOptions).UsedDC );
  end
  else
    raise EPDFException.Create ( SCanvasForThisPageAlreadyCreated );
end;

function TPDFPages.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPDFPages.GetPage(index:Integer): TPDFPage;
begin
  Result := TPDFPage(FList[Index]);
end;

procedure TPDFPages.RequestCanvas;
begin
  FAskCanvas := True;
end;


procedure TPDFPages.SaveIndex(Index:Integer);
begin
  TPDFPage(FList[Index]).Save;
end;

procedure TPDFPages.SetCurrentPage(Index:Integer);
begin
  if (Index >= FList.Count) or (Index < 0 ) then
    raise EPDFException.Create( SOutOfRange);
  CloseCanvas;
  FCurrentPage := TPDFPage(FList[Index]);
  FCurrentPageIndex := Index;
  CreateCanvas;
end;


procedure TPDFPages.Save;
var
  I: Integer;
begin
  FEngine.StartObj ( ID );
  FEngine.SaveToStream ( '/Type /Pages' );
  FEngine.SaveToStream ( '/Kids [' );
  for i := 0 to FList.Count - 1 do
    FEngine.SaveToStream ( TPDFPage(FList[I]).RefID + ' ' );
  FEngine.SaveToStream ( ']' );
  FEngine.SaveToStream ( '/Count ' + IStr ( FList.Count ) );
  FEngine.CloseObj;
end;

function TPDFPages.GetPageIndex(Page: TPDFPage): Integer;
begin
  result := FList.IndexOf(Page);
end;

{ TPDFAnnotation }

function TPDFAnnotation.CalcFlags: Integer;
begin
  Result := 0;
  if afInvisible in FFlags then
    Result := Result or 1;
  if afHidden in FFlags then
    Result := Result or 2;
  if afPrint in FFlags then
    Result := Result or 4;
  if afNoZoom in FFlags then
    Result := Result or 8;
  if afNoRotate in FFlags then
    Result := Result or 16;
  if afNoView in FFlags then
    Result := Result or 32;
  if afReadOnly in FFlags then
    Result := Result or 64;
end;

procedure TPDFAnnotation.ChangePage(Page: TPDFPage; Box: TRect);
var
  i: Integer;
  AI: Integer;
  R: TRect;
  A: TPDFAnnotationArray;
begin
  i := Length( FOwner.FAnnotations);
  SetLength( A, i - 1);
  AI := 0;
  for i:= 0 to i -1 do
    if FOwner.FAnnotations[i] <> Self then
    begin
      A[AI] := FOwner.FAnnotations[i];
      inc(AI);
    end;
  FOwner.FAnnotations := A;
  i := Length( Page.FAnnotations);
  SetLength( Page.FAnnotations, i + 1);
  Page.FAnnotations[i] := Self;
  FOwner := Page;
  R := Box;
  NormalizeRect ( R.Left, R.Top, R.Right, R.Bottom );
  FLeft := Round ( FOwner.ExtToIntX ( R.Left ) );
  FTop := Round ( FOwner.ExtToIntY ( R.Top ) );
  FBottom := Round ( FOwner.ExtToIntY ( R.Bottom ) );
  FRight := Round ( FOwner.ExtToIntX ( R.Right ) );
end;

constructor TPDFAnnotation.Create(Page: TPDFPage; Box: TRect);
var
  i: Integer;
  R: TRect;
begin
  inherited Create( Page.Eng);
  i := Length( Page.FAnnotations);
  SetLength( Page.FAnnotations, i + 1);
  Page.FAnnotations[i] := Self;
  FFlags := [afPrint];
  FBorderStyle :='[0 0 1]';
  FOwner := Page;
  R := Box;
  NormalizeRect ( R.Left, R.Top, R.Right, R.Bottom );
  FLeft := Round ( FOwner.ExtToIntX ( R.Left ) );
  FTop := Round ( FOwner.ExtToIntY ( R.Top ) );
  FBottom := Round ( FOwner.ExtToIntY ( R.Bottom ) );
  FRight := Round ( FOwner.ExtToIntX ( R.Right ) );
end;


{ TPDFForm }

constructor TPDFForm.Create(Engine: TPDFEngine; FontManager: TPDFFonts;
  OptionalContent: TOptionalContent);
begin
  inherited Create( Engine, FontManager);
  FMatrix.a := 1;
  FMatrix.b := 0;
  FMatrix.c := 0;
  FMatrix.d := 1;
  FMatrix.x := 0;
  FMatrix.y := 0;
  if OptionalContent <> nil then
  begin
    FHaveOptional := True;
    FOptionalContent := OptionalContent;
  end else
    FHaveOptional := False;
end;

procedure TPDFForm.Save;
var
  I:Integer;
  MS: TMemoryStream;
  CS: TCompressionStream;
begin
  if FTextInited then
    EndText;
  for I := FSaveCount + 1 downto 0 do
    GStateRestore;
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /XObject' );
  Eng.SaveToStream ( '/Subtype /Form' );
  if FHaveOptional then
  begin
     Eng.SaveToStream('/OC '+FOptionalContent.RefID);
  end;
  Eng.SaveToStream ( '/Matrix [' + FormatFloat ( FMatrix.a ) + ' ' + FormatFloat ( FMatrix.b ) + ' ' + FormatFloat ( FMatrix.c ) + ' ' +
    FormatFloat ( FMatrix.d ) + ' ' + FormatFloat ( FMatrix.x ) + ' ' + FormatFloat ( FMatrix.y ) + ' ]' );
  Eng.SaveToStream ( '/BBox [0 0 ' + IStr ( FWidth ) + ' ' + IStr ( FHeight ) + ']' );
  Eng.SaveToStream ( '/Resources <<'  );
  if Eng.PDFACompatibile then
    if FRGBUsed or FGrayUsed or FCMYKUsed then
    begin
      Eng.SaveToStream('/ColorSpace <<');
      if FGrayUsed  then
        Eng.SaveToStream('/DefaultGray '+ GetRef( Eng.GrayICCObject ));
      if FRGBUsed  then
        Eng.SaveToStream('/DefaultRGB '+ GetRef( Eng.RGBICCObject ));
      if FCMYKUsed  then
        Eng.SaveToStream('/DefaultCMYK '+ GetRef( Eng.CMYKICCObject ));
      Eng.SaveToStream('>>');
    end;
  Eng.SaveToStream ( '/ProcSet [/PDF ', False );
  if FTextUsed then
    Eng.SaveToStream ( '/Text ', False );
  if FGrayUsed then
    Eng.SaveToStream ( '/ImageB ', False );
  if FColorUsed then
    Eng.SaveToStream ( '/ImageC ', False );
  Eng.SaveToStream ( ']' );
  if Length ( FLinkedFont ) > 0 then
  begin
    Eng.SaveToStream ( '/Font <<' );
    for I := 0 to Length ( FLinkedFont ) - 1 do
        Eng.SaveToStream ( '/' + FLinkedFont[I].AliasName + ' ' + FLinkedFont [ I ].RefID);
    Eng.SaveToStream ( '>>' );
  end;

  if Length ( FPatterns ) > 0 then
  begin
    Eng.SaveToStream ( '/Pattern <<' );
    for I := 0 to Length ( FPatterns ) - 1 do
        Eng.SaveToStream ( '/Ptn' + IStr(I) + ' ' + FPatterns [ I ].RefID);
    Eng.SaveToStream ( '>>' );
  end;

  if Length ( FLinkedExtGState ) > 0 then
  begin
    Eng.SaveToStream ( '/ExtGState <<' );
    for I := 0 to Length ( FLinkedExtGState ) - 1 do
        Eng.SaveToStream ( '/GS' + IStr( I ) +' '+ FLinkedExtGState [ I ].RefID);
    Eng.SaveToStream ( '>>' );
  end;

  if ( Length(FLinkedImages) > 0 )  then
  begin
    Eng.SaveToStream ( '/XObject <<' );
    for I := 0 to Length(FLinkedImages) - 1 do
      Eng.SaveToStream ( '/Img' + IStr( I ) + ' ' + TPDFImage ( FLinkedImages [ I ] ).RefID);
    Eng.SaveToStream ( '>>' );
  end;

  Eng.SaveToStream ( '>>'  );


  if Eng.Compression = ctFlate then
  begin
    MS := TMemoryStream.Create;
    try
      CS := TCompressionStream.Create ( clDefault, MS );
      try
        FContent.SaveToStream ( CS );
      finally
        CS.Free;
      end;
      Eng.SaveToStream ( '/Length ' + IStr ( CalcAESSize(Eng.SecurityInfo.State, MS.size ) ) );
      Eng.SaveToStream ( '/Filter /FlateDecode' );
      Eng.StartStream;
      MS.Position := 0;
      CryptStreamToStream ( Eng.SecurityInfo,MS, Eng.Stream, ID );
    finally
      MS.Free;
    end;
  end else
  begin
    Eng.SaveToStream ( '/Length ' + IStr ( CalcAESSize( Eng.SecurityInfo.State, Length ( FContent.Text ) ) ) );
    Eng.StartStream;
    CryptStringToStream(Eng.SecurityInfo,Eng.Stream, FContent.Text,ID );
  end;
  Eng.CloseStream;
end;


procedure TPDFForm.SetPattern(Pattern: TPDFPattern);
var
  i, idx: Integer;
  fnd: Boolean;
begin
  fnd := False;
  idx := 0;
  for i := 0 to Length( FPatterns) -1 do
    if FPatterns[i] = Pattern then
    begin
      fnd := True;
      idx := i;
      Break;
    end;
  if not fnd then
  begin
    idx := Length(FPatterns);
    SetLength(FPatterns, idx + 1 );
    FPatterns[idx] := Pattern;
  end;
  EndText;
  AppendAction ( '/Pattern cs /Ptn'+IStr(idx)+' scn');
end;


{ TPDFGState }

constructor TPDFGState.Create(PDFEngine: TPDFEngine);
begin
  inherited Create( PDFEngine );
  FLineWidthInited := False;
  FLineCapInited := False;
  FLineJoinInited := False;
  FMitterLimitInited := False;
  FAlphaFillInited := False;
  FAlphaStrokeInited := False;
end;

procedure TPDFGState.Save;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /ExtGState' );
  Eng.SaveToStream ( '/Subtype /Widget' );
  if  FLineCapInited then
    Eng.SaveToStream ( '/LC ' + IStr(Ord(FLineCap) ) );
  if  FLineJoinInited then
    Eng.SaveToStream ( '/LJ ' + IStr(Ord(FLineJoin) ) );
  if  FLineWidthInited then
    Eng.SaveToStream ( '/LW ' + FormatFloat(FLineWidth) );
  if  FMitterLimitInited then
    Eng.SaveToStream ( '/ML ' + FormatFloat(FMitterLimit) );
  if  FAlphaFillInited then
    Eng.SaveToStream ( '/ca ' + FormatFloat(FAlphaFill) );
  if  FAlphaStrokeInited then
    Eng.SaveToStream ( '/CA ' + FormatFloat(FAlphaStroke) );
  Eng.CloseObj;
end;

procedure TPDFGState.SetAlphaFill(const Value: Extended);
begin
  if Eng.PDFACompatibile and (Value <> 1) then
    raise EPDFException.Create(SPDFACompatible);
  FAlphaFill := Value;
  FAlphaFillInited := True;
end;

procedure TPDFGState.SetAlphaStroke(const Value: Extended);
begin
  if Eng.PDFACompatibile and (Value <> 1) then
    raise EPDFException.Create(SPDFACompatible);
  FAlphaStroke := Value;
  FAlphaStrokeInited := True;
end;

procedure TPDFGState.SetLineCap(const Value: TPDFLineCap);
begin
  FLineCap := Value;
  FLineCapInited := True;
end;

procedure TPDFGState.SetLineJoin(const Value: TPDFLineJoin);
begin
  FLineJoin := Value;
  FLineJoinInited := True;
end;

procedure TPDFGState.SetLineWidth(const Value: Extended);
begin
  FLineWidth := Value;
  FLineWidthInited := True;
end;

procedure TPDFGState.SetMitterLimit(const Value: Extended);
begin
  FMitterLimit := Value;
  FMitterLimitInited := True;
end;


{ TPDFPattern }

constructor TPDFPattern.Create(Engine: TPDFEngine; FontManager: TPDFFonts);
begin
  inherited Create( Engine, FontManager);
  FMatrix.a := 1;
  FMatrix.b := 0;
  FMatrix.c := 0;
  FMatrix.d := 1;
  FMatrix.x := 0;
  FMatrix.y := 0;
  FXStep := 0;
  FYStep := 0;
end;

procedure TPDFPattern.Save;
var
  I:Integer;
  MS: TMemoryStream;
  CS: TCompressionStream;
begin
  if FTextInited then
    EndText;
  for I := FSaveCount + 1 downto 0 do
    GStateRestore;
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /Pattern' );
  Eng.SaveToStream ( '/PatternType 1' );
  Eng.SaveToStream ( '/PaintType 1 /TilingType 1' );
  Eng.SaveToStream ( '/XStep '+ IStr(FXStep)+ ' /YStep '+IStr(FYStep ));

  Eng.SaveToStream ( '/Matrix [' + FormatFloat ( FMatrix.a ) + ' ' + FormatFloat ( FMatrix.b ) + ' ' + FormatFloat ( FMatrix.c ) + ' ' +
    FormatFloat ( FMatrix.d ) + ' ' + FormatFloat ( FMatrix.x ) + ' ' + FormatFloat ( FMatrix.y ) + ' ]' );
  Eng.SaveToStream ( '/BBox [0 0 ' + IStr ( FWidth ) + ' ' + IStr ( FHeight ) + ']' );
  Eng.SaveToStream ( '/Resources <<'  );
  if Eng.PDFACompatibile then
    if FRGBUsed or FGrayUsed or FCMYKUsed then
    begin
      Eng.SaveToStream('/ColorSpace <<');
      if FGrayUsed  then
        Eng.SaveToStream('/DefaultGray '+ GetRef( Eng.GrayICCObject ));
      if FRGBUsed  then
        Eng.SaveToStream('/DefaultRGB '+ GetRef( Eng.RGBICCObject ));
      if FCMYKUsed  then
        Eng.SaveToStream('/DefaultCMYK '+ GetRef( Eng.CMYKICCObject ));
      Eng.SaveToStream('>>');
    end;
  Eng.SaveToStream ( '/ProcSet [/PDF ', False );
  if FTextUsed then
    Eng.SaveToStream ( '/Text ', False );
  if FGrayUsed then
    Eng.SaveToStream ( '/ImageB ', False );
  if FColorUsed then
    Eng.SaveToStream ( '/ImageC ', False );
  Eng.SaveToStream ( ']' );
  if Length ( FLinkedFont ) > 0 then
  begin
    Eng.SaveToStream ( '/Font <<' );
    for I := 0 to Length ( FLinkedFont ) - 1 do
        Eng.SaveToStream ( '/' + FLinkedFont[I].AliasName + ' ' + FLinkedFont [ I ].RefID);
    Eng.SaveToStream ( '>>' );
  end;
  if Length ( FLinkedExtGState ) > 0 then
  begin
    Eng.SaveToStream ( '/ExtGState <<' );
    for I := 0 to Length ( FLinkedExtGState ) - 1 do
        Eng.SaveToStream ( '/GS' + IStr( I ) +' '+ FLinkedExtGState [ I ].RefID);
    Eng.SaveToStream ( '>>' );
  end;
  if ( Length(FLinkedImages) > 0 )  then
  begin
    Eng.SaveToStream ( '/XObject <<' );
    for I := 0 to Length(FLinkedImages) - 1 do
      Eng.SaveToStream ( '/Img' + IStr( I ) + ' ' + TPDFImage ( FLinkedImages [ I ] ).RefID );
    Eng.SaveToStream ( '>>' );
  end;
  Eng.SaveToStream ( '>>'  );
  if Eng.Compression = ctFlate then
  begin
    MS := TMemoryStream.Create;
    try
      CS := TCompressionStream.Create ( clDefault, MS );
      try
        FContent.SaveToStream ( CS );
      finally
        CS.Free;
      end;
      Eng.SaveToStream ( '/Length ' + IStr ( CalcAESSize( Eng.SecurityInfo.State,MS.size ) ) );
      Eng.StartStream;
      MS.Position := 0;
      CryptStreamToStream ( Eng.SecurityInfo,MS, Eng.Stream, ID );
    finally
      MS.Free;
    end;
  end else
  begin
    Eng.SaveToStream ( '/Length ' + IStr ( CalcAESSize( Eng.SecurityInfo.State, Length ( FContent.Text ) ) ) );
    Eng.StartStream;
    CryptStringToStream(Eng.SecurityInfo,Eng.Stream, FContent.Text,ID );
  end;
  Eng.CloseStream;
end;


{ TOptionalConent }

constructor TOptionalContent.Create(PDFEngine: TPDFEngine; Name: AnsiString;
  Visible, CanExchange: Boolean);
begin
  inherited Create(PDFEngine);
  FName := Name;
  FVisible := Visible;
  FCAN := CanExchange;
end;

procedure TOptionalContent.Save;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Name ' + CryptString( FName ) );
  Eng.SaveToStream ( '/Type/OCG');
  Eng.CloseObj;
end;


{ TOptionalContents }

procedure TOptionalContents.Save;
var
  i: Integer;
begin
  inherited;
  if FList.Count = 0 then Exit;
  FEngine.StartObj ( ID );
  FEngine.SaveToStream ( '/OCGs [', false );
  for i := 0 to FList.Count- 1 do
    FEngine.SaveToStream ( ' '+ TPDFObject(FList[i]).RefID, False);
  FEngine.SaveToStream ( ' ]');
  FEngine.SaveToStream ( '/D <<');
  FEngine.SaveToStream ( '/ON [', false );
  for i := 0 to FList.Count - 1 do
    if TOptionalContent(FList[i]).FVisible then
    FEngine.SaveToStream ( ' '+ TPDFObject(FList[i]).RefID, False);
  FEngine.SaveToStream ( ' ]');
  FEngine.SaveToStream ( '/OFF [', false );
  for i := 0 to FList.Count - 1 do
    if not TOptionalContent(FList[i]).FVisible then
    FEngine.SaveToStream ( ' '+ TPDFObject(FList[i]).RefID, False);
  FEngine.SaveToStream ( ' ]');
  FEngine.SaveToStream ( '/Locked [', false );
  for i := 0 to FList.Count - 1 do
    if not TOptionalContent(FList[i]).FCAN then
    FEngine.SaveToStream ( ' '+ TPDFObject(FList[i]).RefID, False);
  FEngine.SaveToStream ( ' ]');
    FEngine.SaveToStream ( '/Order [', false );
  for i := 0 to FList.Count - 1 do
    FEngine.SaveToStream ( ' '+ TPDFObject(FList[i]).RefID, False);
  FEngine.SaveToStream ( ' ]');

  FEngine.SaveToStream ( ' >>');
  FEngine.CloseObj;
end;

function TPDFCanvas.GetStringType(CheckStr:AnsiString): TStringType;
var
  i : Integer;
  fnd : Boolean;
begin
  fnd := false;
  for i:= 0 to Length(CheckStr) do
    if CheckStr[i] > #127 then
    begin
      fnd := true;
      break;
    end;
  if not fnd then
    Result := stASCII
  else
    if FCharset = 0 then
      result := stANSI
    else
      result := stNeedUnicode;
end;



end.





