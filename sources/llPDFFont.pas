{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFFont;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
{$endif}
  llPDFTrueType,llPDFEngine, llPDFMisc, llPDFTypes;

type

  TPDFANSICharacterWidth = array [ 0..127 ] of Integer;
  PPDFANSICharacterWidth = ^TPDFANSICharacterWidth;


  TGlyphData = record
    Unicode: Word;
    Width: Word;
    BaseWidth:Word;
    AddWidth: Word;
    Used: Boolean;
    NewIdx: Word;
    FontID:Word;
    Size: Word;
    DataOffset:Integer;
  end;

  TPDFFont = class(TPDFObject)
  private
    FAlias: AnsiString;
    FUsed: Boolean;
    function GetAscent: Integer; virtual; abstract;
    function GetDescent: Integer; virtual; abstract;
    function GetWidth(Index:Word): Integer; virtual; abstract;
  public
    procedure FillUsed(s:AnsiString); virtual;
    procedure UsedChar(Ch:Byte); virtual;
    procedure SetAllASCII; virtual;
    property Ascent: Integer read GetAscent;
    property AliasName: AnsiString read FAlias;
    property Descent: Integer read GetDescent;
    property FontUsed: Boolean read FUsed write FUsed;
    property Width[Index:Word]: Integer read GetWidth;
  end;
                                                        

  TPDFStandardFont = class(TPDFFont)
  private
    FStyle: TPDFStdFont;
    function GetAscent: Integer; override;
    function GetDescent: Integer; override;
    function GetWidth(Index: Word): Integer; override;
  public
    constructor Create(Engine: TPDFEngine; Style: TPDFStdFont);
    procedure Save; override;
  end;

  TPDFTrueTypeFont = class;


  TPDFTrueTypeSubsetFont = class (TPDFFont)
  private
    FParent: TPDFTrueTypeFont;
    FLast :Integer;
    FIndexes: array[32..127] of integer;
    FUnicodes: array[32..127] of Word;
    procedure GetToUnicodeStream(Alias: AnsiString; Stream: TStream;
        AliasName:AnsiString);

  protected
    procedure Save;override;
    function GetAscent: Integer; override;
    function GetDescent: Integer; override;
    function GetWidth(Index: Word): Integer; override;

  public
    constructor Create(Engine:TPDFEngine; AParent: TPDFTrueTypeFont);
    destructor Destroy;override;
    property Parent: TPDFTrueTypeFont read FParent;
  end;

  TPDFTrueTypeFont = class(TPDFFont)
  private
    FIsEmbedded: Boolean;
    FFirstChar: Integer;
    FLastChar: Integer;
    FFontName: String;
    FFontNameAddon:AnsiString;
    FFontStyle: TFontStyles;
    FASCIIList: array [ 32..127 ] of Integer;
    FUsedList: array [32.. 127] of Boolean;

    FExtendedFonts: array of TPDFTrueTypeSubsetFont;
    FCurrentIndex:Integer;
    FCurrentChar: Integer;
    FManager: TTrueTypeManager;

    function GetAscent: Integer; override;
    function GetDescent: Integer; override;
    function GetWidth(Index: Word): Integer; override;
    function GetSubset(Index: Integer): TPDFFont;
    function GetNewCharByIndex(Index: Integer): PNewCharInfo;
    function GetNewCharByUnicode(Index: Word): PNewCharInfo;
  public
    constructor Create(Engine:TPDFEngine;FontName:String; FontStyle: TFontStyles;IsEmbedded:Boolean);
    destructor Destroy; override;
    procedure Save; override;
    procedure FillUsed(s:AnsiString); override;
    procedure UsedChar(Ch:Byte); override;
    procedure SetAllASCII; override;
    procedure MarkAsUsed(Glyph:PGlyphInfo;Unicode:Word);
    property Name: String read FFontName;
    property Style: TFontStyles read FFontStyle;
    property SubsetFont[Index: Integer]:TPDFFont read GetSubset;
    property CharByIndex[Index: Integer]: PNewCharInfo read GetNewCharByIndex;
    property CharByUnicode[Index: Word]: PNewCharInfo read GetNewCharByUnicode;
  end;


  TPDFFonts = class (TPDFManager)
  private
    FNonEmbeddedFonts: TStringList;
    function GetTrueTypeFont(FontName: String; Style: TFontStyles): TPDFFont;
    procedure SetNonEmbeddedFonts(const Value: TStringList);
  protected
    procedure Save;override;
    procedure Clear;override;
    function GetCount:Integer; override;
  public
    constructor Create(PDFEngine: TPDFEngine);
    destructor Destroy; override;
    function GetFontByInfo(StdFont:TPDFStdFont): TPDFFont;overload;
    function GetFontByInfo(FontName: String; Style: TFontStyles): TPDFFont; overload;
    property NonEmbeddedFonts: TStringList read FNonEmbeddedFonts write SetNonEmbeddedFonts;
  end;

implementation

uses  llPDFResources,
{$ifdef WIN64}
  System.ZLib, System.ZLibConst,
{$else}
  llPDFFlate,
{$endif}
 llPDFSecurity, llPDFCrypt;

const

PDFStandardFontNames: array [ 0..13 ] of AnsiString
  = ( 'Helvetica', 'Helvetica-Bold', 'Helvetica-Oblique', 'Helvetica-BoldOblique',
    'Times-Roman', 'Times-Bold', 'Times-Italic', 'Times-BoldItalic',
    'Courier', 'Courier-Bold', 'Courier-Oblique', 'Courier-BoldOblique',
    'Symbol', 'ZapfDingbats' );

const StdFontAliases : array[0..13] of AnsiString =
(	'Helv','HeBo','HeOb','HeBO','TiRo','TiBo','TiIt','TiBI','Cour','CoBo','CoOb','CoBO','Symb','ZaDb');


  StWidth: array [ 0..13, 0..268 ] of word = (
    (
    278, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 278, 355, 556, 556, 889, 667, 191,
    333, 333, 389, 584, 278, 333, 278, 278, 556, 556,
    556, 556, 556, 556, 556, 556, 556, 556, 278, 278,
    584, 584, 584, 556, 1015, 667, 667, 722, 722, 667,
    611, 778, 722, 278, 500, 667, 556, 833, 722, 778,
    667, 778, 722, 667, 611, 722, 667, 944, 667, 667,
    611, 278, 278, 278, 469, 556, 333, 556, 556, 500,
    556, 556, 278, 556, 556, 222, 222, 500, 222, 833,
    556, 556, 556, 556, 333, 500, 278, 556, 500, 722,
    500, 500, 500, 334, 260, 334, 584, 350, 558, 350,
    222, 556, 333, 1000, 556, 556, 333, 1000, 667, 333,
    1000, 350, 611, 350, 350, 222, 222, 333, 333, 350,
    556, 1000, 333, 1000, 500, 333, 944, 350, 500, 667,
    278, 333, 556, 556, 556, 556, 260, 556, 333, 737,
    370, 556, 584, 333, 737, 333, 333, 584, 333, 333,
    333, 556, 537, 278, 333, 333, 365, 556, 834, 834,
    834, 611, 667, 667, 667, 667, 667, 667, 1000, 722,
    667, 667, 667, 667, 278, 278, 278, 278, 722, 722,
    778, 778, 778, 778, 778, 584, 778, 722, 722, 722,
    722, 667, 667, 611, 556, 556, 556, 556, 556, 556,
    889, 500, 556, 556, 556, 556, 278, 278, 278, 278,
    556, 556, 556, 556, 556, 556, 556, 584, 611, 556,
    556, 556, 556, 500, 556, 500, 556, 333, 333, 333,
    278, 500, 500, 167, 333, 222, 584, 333, 400
    ),

    (
    278, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 333, 474, 556, 556, 889, 722, 238,
    333, 333, 389, 584, 278, 333, 278, 278, 556, 556,
    556, 556, 556, 556, 556, 556, 556, 556, 333, 333,
    584, 584, 584, 611, 975, 722, 722, 722, 722, 667,
    611, 778, 722, 278, 556, 722, 611, 833, 722, 778,
    667, 778, 722, 667, 611, 722, 667, 944, 667, 667,
    611, 333, 278, 333, 584, 556, 333, 556, 611, 556,
    611, 556, 333, 611, 611, 278, 278, 556, 278, 889,
    611, 611, 611, 611, 389, 556, 333, 611, 556, 778,
    556, 556, 500, 389, 280, 389, 584, 350, 558, 350,
    278, 556, 500, 1000, 556, 556, 333, 1000, 667, 333,
    1000, 350, 611, 350, 350, 278, 278, 500, 500, 350,
    556, 1000, 333, 1000, 556, 333, 944, 350, 500, 667,
    278, 333, 556, 556, 556, 556, 280, 556, 333, 737,
    370, 556, 584, 333, 737, 333, 333, 584, 333, 333,
    333, 611, 556, 278, 333, 333, 365, 556, 834, 834,
    834, 611, 722, 722, 722, 722, 722, 722, 1000, 722,
    667, 667, 667, 667, 278, 278, 278, 278, 722, 722,
    778, 778, 778, 778, 778, 584, 778, 722, 722, 722,
    722, 667, 667, 611, 556, 556, 556, 556, 556, 556,
    889, 556, 556, 556, 556, 556, 278, 278, 278, 278,
    611, 611, 611, 611, 611, 611, 611, 584, 611, 611,
    611, 611, 611, 556, 611, 556, 611, 333, 333, 333,
    278, 611, 611, 167, 333, 278, 584, 333, 400
    ),

    (
    278, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 278, 355, 556, 556, 889, 667, 191,
    333, 333, 389, 584, 278, 333, 278, 278, 556, 556,
    556, 556, 556, 556, 556, 556, 556, 556, 278, 278,
    584, 584, 584, 556, 1015, 667, 667, 722, 722, 667,
    611, 778, 722, 278, 500, 667, 556, 833, 722, 778,
    667, 778, 722, 667, 611, 722, 667, 944, 667, 667,
    611, 278, 278, 278, 469, 556, 333, 556, 556, 500,
    556, 556, 278, 556, 556, 222, 222, 500, 222, 833,
    556, 556, 556, 556, 333, 500, 278, 556, 500, 722,
    500, 500, 500, 334, 260, 334, 584, 350, 558, 350,
    222, 556, 333, 1000, 556, 556, 333, 1000, 667, 333,
    1000, 350, 611, 350, 350, 222, 222, 333, 333, 350,
    556, 1000, 333, 1000, 500, 333, 944, 350, 500, 667,
    278, 333, 556, 556, 556, 556, 260, 556, 333, 737,
    370, 556, 584, 333, 737, 333, 333, 584, 333, 333,
    333, 556, 537, 278, 333, 333, 365, 556, 834, 834,
    834, 611, 667, 667, 667, 667, 667, 667, 1000, 722,
    667, 667, 667, 667, 278, 278, 278, 278, 722, 722,
    778, 778, 778, 778, 778, 584, 778, 722, 722, 722,
    722, 667, 667, 611, 556, 556, 556, 556, 556, 556,
    889, 500, 556, 556, 556, 556, 278, 278, 278, 278,
    556, 556, 556, 556, 556, 556, 556, 584, 611, 556,
    556, 556, 556, 500, 556, 500, 556, 333, 333, 333,
    278, 500, 500, 167, 333, 222, 584, 333, 400
    ),

    (
    278, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 333, 474, 556, 556, 889, 722, 238,
    333, 333, 389, 584, 278, 333, 278, 278, 556, 556,
    556, 556, 556, 556, 556, 556, 556, 556, 333, 333,
    584, 584, 584, 611, 975, 722, 722, 722, 722, 667,
    611, 778, 722, 278, 556, 722, 611, 833, 722, 778,
    667, 778, 722, 667, 611, 722, 667, 944, 667, 667,
    611, 333, 278, 333, 584, 556, 333, 556, 611, 556,
    611, 556, 333, 611, 611, 278, 278, 556, 278, 889,
    611, 611, 611, 611, 389, 556, 333, 611, 556, 778,
    556, 556, 500, 389, 280, 389, 584, 350, 558, 350,
    278, 556, 500, 1000, 556, 556, 333, 1000, 667, 333,
    1000, 350, 611, 350, 350, 278, 278, 500, 500, 350,
    556, 1000, 333, 1000, 556, 333, 944, 350, 500, 667,
    278, 333, 556, 556, 556, 556, 280, 556, 333, 737,
    370, 556, 584, 333, 737, 333, 333, 584, 333, 333,
    333, 611, 556, 278, 333, 333, 365, 556, 834, 834,
    834, 611, 722, 722, 722, 722, 722, 722, 1000, 722,
    667, 667, 667, 667, 278, 278, 278, 278, 722, 722,
    778, 778, 778, 778, 778, 584, 778, 722, 722, 722,
    722, 667, 667, 611, 556, 556, 556, 556, 556, 556,
    889, 556, 556, 556, 556, 556, 278, 278, 278, 278,
    611, 611, 611, 611, 611, 611, 611, 584, 611, 611,
    611, 611, 611, 556, 611, 556, 611, 333, 333, 333,
    278, 611, 611, 167, 333, 278, 584, 333, 400
    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 333, 408, 500, 500, 833, 778, 180,
    333, 333, 500, 564, 250, 333, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 278, 278,
    564, 564, 564, 444, 921, 722, 667, 667, 722, 611,
    556, 722, 722, 333, 389, 722, 611, 889, 722, 722,
    556, 722, 667, 556, 611, 722, 722, 944, 722, 722,
    611, 333, 278, 333, 469, 500, 333, 444, 500, 444,
    500, 444, 333, 500, 500, 278, 278, 500, 278, 778,
    500, 500, 500, 500, 333, 389, 278, 500, 500, 722,
    500, 500, 444, 480, 200, 480, 541, 350, 500, 350,
    333, 500, 444, 1000, 500, 500, 333, 1000, 556, 333,
    889, 350, 611, 350, 350, 333, 333, 444, 444, 350,
    500, 1000, 333, 980, 389, 333, 722, 350, 444, 722,
    250, 333, 500, 500, 500, 500, 200, 500, 333, 760,
    276, 500, 564, 333, 760, 333, 333, 564, 300, 300,
    333, 500, 453, 250, 333, 300, 310, 500, 750, 750,
    750, 444, 722, 722, 722, 722, 722, 722, 889, 667,
    611, 611, 611, 611, 333, 333, 333, 333, 722, 722,
    722, 722, 722, 722, 722, 564, 722, 722, 722, 722,
    722, 722, 556, 500, 444, 444, 444, 444, 444, 444,
    667, 444, 444, 444, 444, 444, 278, 278, 278, 278,
    500, 500, 500, 500, 500, 500, 500, 564, 500, 500,
    500, 500, 500, 500, 500, 500, 611, 333, 333, 333,
    278, 556, 556, 167, 333, 278, 564, 333, 400
    ),
    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 333, 555, 500, 500, 1000, 833, 278,
    333, 333, 500, 570, 250, 333, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 333, 333,
    570, 570, 570, 500, 930, 722, 667, 722, 722, 667,
    611, 778, 778, 389, 500, 778, 667, 944, 722, 778,
    611, 778, 722, 556, 667, 722, 722, 1000, 722, 722,
    667, 333, 278, 333, 581, 500, 333, 500, 556, 444,
    556, 444, 333, 500, 556, 278, 333, 556, 278, 833,
    556, 500, 556, 556, 444, 389, 333, 556, 500, 722,
    500, 500, 444, 394, 220, 394, 520, 350, 500, 350,
    333, 500, 500, 1000, 500, 500, 333, 1000, 556, 333,
    1000, 350, 667, 350, 350, 333, 333, 500, 500, 350,
    500, 1000, 333, 1000, 389, 333, 722, 350, 444, 722,
    250, 333, 500, 500, 500, 500, 220, 500, 333, 747,
    300, 500, 570, 333, 747, 333, 333, 570, 300, 300,
    333, 556, 540, 250, 333, 300, 330, 500, 750, 750,
    750, 500, 722, 722, 722, 722, 722, 722, 1000, 722,
    667, 667, 667, 667, 389, 389, 389, 389, 722, 722,
    778, 778, 778, 778, 778, 570, 778, 722, 722, 722,
    722, 722, 611, 556, 500, 500, 500, 500, 500, 500,
    722, 444, 444, 444, 444, 444, 278, 278, 278, 278,
    500, 556, 500, 500, 500, 500, 500, 570, 500, 556,
    556, 556, 556, 500, 556, 500, 667, 333, 333, 333,
    278, 556, 556, 167, 333, 278, 570, 333, 400
    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 333, 420, 500, 500, 833, 778, 214,
    333, 333, 500, 675, 250, 333, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 333, 333,
    675, 675, 675, 500, 920, 611, 611, 667, 722, 611,
    611, 722, 722, 333, 444, 667, 556, 833, 667, 722,
    611, 722, 611, 500, 556, 722, 611, 833, 611, 556,
    556, 389, 278, 389, 422, 500, 333, 500, 500, 444,
    500, 444, 278, 500, 500, 278, 278, 444, 278, 722,
    500, 500, 500, 500, 389, 389, 278, 500, 444, 667,
    444, 444, 389, 400, 275, 400, 541, 350, 500, 350,
    333, 500, 556, 889, 500, 500, 333, 1000, 500, 333,
    944, 350, 556, 350, 350, 333, 333, 556, 556, 350,
    500, 889, 333, 980, 389, 333, 667, 350, 389, 556,
    250, 389, 500, 500, 500, 500, 275, 500, 333, 760,
    276, 500, 675, 333, 760, 333, 333, 675, 300, 300,
    333, 500, 523, 250, 333, 300, 310, 500, 750, 750,
    750, 500, 611, 611, 611, 611, 611, 611, 889, 667,
    611, 611, 611, 611, 333, 333, 333, 333, 722, 667,
    722, 722, 722, 722, 722, 675, 722, 722, 722, 722,
    722, 556, 611, 500, 500, 500, 500, 500, 500, 500,
    667, 444, 444, 444, 444, 444, 278, 278, 278, 278,
    500, 500, 500, 500, 500, 500, 500, 675, 500, 500,
    500, 500, 500, 444, 500, 444, 556, 333, 333, 333,
    278, 500, 500, 167, 333, 278, 675, 333, 400
    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 389, 555, 500, 500, 833, 778, 278,
    333, 333, 500, 570, 250, 333, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 333, 333,
    570, 570, 570, 500, 832, 667, 667, 667, 722, 667,
    667, 722, 778, 389, 500, 667, 611, 889, 722, 722,
    611, 722, 667, 556, 611, 722, 667, 889, 667, 611,
    611, 333, 278, 333, 570, 500, 333, 500, 500, 444,
    500, 444, 333, 500, 556, 278, 278, 500, 278, 778,
    556, 500, 500, 500, 389, 389, 278, 556, 444, 667,
    500, 444, 389, 348, 220, 348, 570, 350, 500, 350,
    333, 500, 500, 1000, 500, 500, 333, 1000, 556, 333,
    944, 350, 611, 350, 350, 333, 333, 500, 500, 350,
    500, 1000, 333, 1000, 389, 333, 722, 350, 389, 611,
    250, 389, 500, 500, 500, 500, 220, 500, 333, 747,
    266, 500, 606, 333, 747, 333, 333, 570, 300, 300,
    333, 576, 500, 250, 333, 300, 300, 500, 750, 750,
    750, 500, 667, 667, 667, 667, 667, 667, 944, 667,
    667, 667, 667, 667, 389, 389, 389, 389, 722, 722,
    722, 722, 722, 722, 722, 570, 722, 722, 722, 722,
    722, 611, 611, 500, 500, 500, 500, 500, 500, 500,
    722, 444, 444, 444, 444, 444, 278, 278, 278, 278,
    500, 556, 500, 500, 500, 500, 500, 570, 500, 556,
    556, 556, 556, 444, 500, 444, 611, 333, 333, 333,
    278, 556, 556, 167, 333, 278, 606, 333, 400
    ),

    (
    600, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600
    ),
    (
    600, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600
    ),

    (
    600, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600
    ),

    (
    600, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600
    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 333, 713, 500, 549, 833, 778, 439,
    333, 333, 500, 549, 250, 549, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 278, 278,
    549, 549, 549, 444, 549, 722, 667, 722, 612, 611,
    763, 603, 722, 333, 631, 722, 686, 889, 722, 722,
    768, 741, 556, 592, 611, 690, 439, 768, 645, 795,
    611, 333, 863, 333, 658, 500, 500, 631, 549, 549,
    494, 439, 521, 411, 603, 329, 603, 549, 549, 576,
    521, 549, 549, 521, 549, 603, 439, 576, 713, 686,
    493, 686, 494, 480, 200, 480, 549, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 620, 247, 549, 167, 713, 500, 753, 753, 753,
    753, 1042, 987, 603, 987, 603, 400, 549, 411, 549,
    549, 713, 494, 460, 549, 549, 549, 549, 1000, 603,
    1000, 658, 823, 686, 795, 987, 768, 768, 823, 768,
    768, 713, 713, 713, 713, 713, 713, 713, 768, 713,
    790, 790, 890, 823, 549, 250, 713, 603, 603, 1042,
    987, 603, 987, 603, 494, 329, 790, 790, 786, 713,
    384, 384, 384, 384, 384, 384, 494, 494, 494, 494,
    0, 329, 274, 686, 686, 686, 384, 384, 384, 384,
    384, 384, 494, 494, 494, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0

    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 974, 961, 974, 980, 719, 789, 790,
    791, 690, 960, 939, 549, 855, 911, 933, 911, 945,
    974, 755, 846, 762, 761, 571, 677, 763, 760, 759,
    754, 494, 552, 537, 577, 692, 786, 788, 788, 790,
    793, 794, 816, 823, 789, 841, 823, 833, 816, 831,
    923, 744, 723, 749, 790, 792, 695, 776, 768, 792,
    759, 707, 708, 682, 701, 826, 815, 789, 789, 707,
    687, 696, 689, 786, 787, 713, 791, 785, 791, 873,
    761, 762, 762, 759, 759, 892, 892, 788, 784, 438,
    138, 277, 415, 392, 392, 668, 668, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 732, 544, 544, 910, 667, 760, 760, 776, 595,
    694, 626, 788, 788, 788, 788, 788, 788, 788, 788,
    788, 788, 788, 788, 788, 788, 788, 788, 788, 788,
    788, 788, 788, 788, 788, 788, 788, 788, 788, 788,
    788, 788, 788, 788, 788, 788, 788, 788, 788, 788,
    788, 788, 894, 838, 1016, 458, 748, 924, 748, 918,
    927, 928, 928, 834, 873, 828, 924, 924, 917, 930,
    931, 463, 883, 836, 836, 867, 867, 696, 696, 874,
    0, 874, 760, 946, 771, 865, 771, 888, 967, 888,
    831, 873, 927, 970, 918, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0
    ) );
  StdFontAscent: array [ 0..13 ] of Integer = ( 728, 728, 728, 728, 613, 633, 613, 633, 693, 677, 694, 677, 1000, 1000 );
  StdFontDescent: array [ 0..13 ] of Integer = ( -210, -210, -208, -210, -188, -209, -188, -216, -216, -216, -216, -217, 0, 0 );





type
  TFontInfo = record
    FontName: String;
    Style: TFontStyles;
    Error: Boolean;
    DefItalic: Boolean;
    DefBold: Boolean;
    Step: Integer;
  end;


function FontTestBack ( const Enum: ENUMLOGFONTEX; Nop:Pointer; FT: DWORD; var FI: TFontInfo ): Integer; stdcall;
var
  Bold, Italic: Boolean;
  Er: Boolean;
begin
  if FT <> TRUETYPE_FONTTYPE then
  begin
    Result := 1;
    Exit;
  end;
  if  StrComp(PChar(fi.FontName) ,Enum.elfLogFont.lfFaceName)<>0 then
    fi.FontName := Enum.elfLogFont.lfFaceName;
  Bold := Enum.elfLogFont.lfWeight >= 600;
  Italic := Enum.elfLogFont.lfItalic <> 0;
  if FI.Step = 0 then
  begin
    FI.DefItalic := Italic;
    FI.DefBold := Bold;
  end;
  Inc ( FI.Step );
  Er := False;
  if ( fsbold in FI.Style ) <> Bold then
    Er := True;
  if ( fsItalic in FI.Style ) <> Italic then
    Er := True;
  FI.Error := Er;
  if Er then
    Result := 1
  else
    Result := 0;
end;


function FontTest ( var FontName: String; var FontStyle: TFontStyles ): Boolean;
var
  LogFont: TLogFont;
  DC: HDC;
  ST: TFontStyles;
  FI: TFontInfo;
begin
  FI.FontName := FontName;
  FI.Style := FontStyle;
  FillChar ( LogFont, SizeOf ( LogFont ), 0 );
  LogFont.lfCharSet := DEFAULT_CHARSET;
  StrPCopy( LogFont.lfFaceName, FI.FontName );
  FI.Step := 0;
  FI.Error := True;
  ST := FI.Style;
  DC := GetDC ( 0 );
  try
    EnumFontFamiliesEx ( DC, LogFont, @FontTestBack, FInt ( @FI ), 0 );
    if FI.Step <> 0 then
      if FI.Error then
      begin
        if fsItalic in FI.Style then
        begin
          FI.Style := FontStyle - [ fsItalic ];
          EnumFontFamiliesEx ( DC, LogFont, @FontTestBack, FInt ( @FI ), 0 );
        end;
        if FI.Error then
          if fsBold in FontStyle then
          begin
            FI.Style := FI.Style - [ fsBold ];
            EnumFontFamiliesEx ( DC, LogFont, @FontTestBack, FInt ( @FI ), 0 );
          end;
        if FI.Error then
        begin
          FI.Style := [ ];
          EnumFontFamiliesEx ( DC, LogFont, @FontTestBack, FInt ( @FI ), 0 );
        end;
        if FI.Error then
        begin
          FI.Style := [ ];
          if FI.DefItalic then
            FI.Style := FI.Style + [ fsItalic ];
          if FI.DefBold then
            FI.Style := FI.Style + [ fsBold ];
          EnumFontFamiliesEx ( DC, LogFont, @FontTestBack, FInt ( @FI ), 0 );
        end;
      end;
  finally
    ReleaseDC ( 0, DC );
  end;
  Result := not FI.Error;
  if FI.FontName <> FontName then
    FontName := FI.FontName;
  if not FI.Error then
    FontStyle := FI.Style;
end;





{ TPDFTrueTypeFont }


constructor TPDFTrueTypeFont.Create(Engine:TPDFEngine;FontName:String; FontStyle: TFontStyles;IsEmbedded:Boolean);
var
  i: Integer;
begin
  inherited Create( Engine);
  FFontName := FontName;
  FFontStyle := FontStyle;
  FIsEmbedded := IsEmbedded;
  FManager := TTrueTypeManager.Create(FontName,FontStyle);
  FCurrentIndex := 0;
  FCurrentChar := 128;
  FFirstChar := 128;
  FLastChar := 31;
  for I := 1 to 6 do
    FFontNameAddon := FFontNameAddon + AnsiChar(Random(26)+65);
  for i:= 32 to 127 do FASCIIList[i] := FManager.GetIdxByUnicode(i);
end;


destructor TPDFTrueTypeFont.Destroy;
var
  i: integer;
begin
  for i := 0 to length(FExtendedFonts) -1 do
    if FExtendedFonts[i]<> nil then
      FExtendedFonts[i].Free;
  FManager.Free;
  inherited;
end;

procedure TPDFTrueTypeFont.FillUsed(s:AnsiString);
var
  I: Integer;
  B: Byte;
begin
  FUsed := True;
  for I := 1 to Length ( s ) do
  begin
    b := Ord ( s [ i ] );
    if (B> 31 ) and (B < 128) then
    begin
      if not FUsedList[B] then
      begin
        FUsedList[B] := True;
        if B > FLastChar then
          FLastChar := B;
        if B < FFirstChar then
          FFirstChar := B;
      end;
    end;
  end;
end;


function TPDFTrueTypeFont.GetAscent: Integer;
begin
  Result := FManager.Ascent;
end;

function TPDFTrueTypeFont.GetDescent: Integer;
begin
  Result := FManager.Descent;
end;


function TPDFTrueTypeFont.GetWidth(Index: Word): Integer;
var
  C: PGlyphInfo;
begin
  if (Index < 128) and (Index > 31) and (FASCIIList[Index] > 0)  then
    C := FManager.Glyphs[FASCIIList[Index]]
  else
    C := FManager.GlyphByUnicode[Index];
  Result := C^.CharInfo.Width;
end;



procedure TPDFTrueTypeFont.Save;
var
  I: Integer;
  Wid: AnsiString;
  MS, MS1: TMemoryStream;
  CS: TCompressionStream;
  RS: Integer;
  FFN: AnsiString;
  FontDescriptorID: Integer;
  FontFileID: Integer;
  UsedArray:array [0..127] of byte;
begin
  for i := 0 to Length(FExtendedFonts) -1 do
    FExtendedFonts[i].Save;
  if FFirstChar > FLastChar then
    Exit;
  FontFileID := -1;
  if FIsEmbedded then
  begin
    MS := TMemoryStream.Create;
    try
      FillChar(UsedArray,Length(UsedArray),0);
      for i := 32 to 127 do
        if FUsedList[i] then
          UsedArray[i] := 1;
      FManager.PrepareASCIIFont(@UsedArray,MS);
      RS := MS.Size;
      MS.Position := 0;
      MS1 := TMemoryStream.Create;
      try
        CS := TCompressionStream.Create ( clMax, MS1 );
        try
          CS.CopyFrom ( MS, MS.Size );
        finally
          CS.Free;
        end;
        MS.Clear;
        FontFileID := Eng.GetNextID;
        Eng.StartObj ( FontFileID );
        Eng.SaveToStream ( '/Filter /FlateDecode /Length ' + IStr ( CalcAESSize(Eng.SecurityInfo.State, MS1.Size ) ) + ' /Length1 ' + IStr ( RS ) );
        Eng.StartStream;
        ms1.Position := 0;
        CryptStreamToStream(Eng.SecurityInfo, MS1, Eng.Stream, FontFileID);
        Eng.CloseStream;
      finally
        MS1.Free;
      end;
    finally
      MS.Free;
    end;
  end;
  Wid := '';
  for I := FFirstChar to FLastChar do
  begin
    if FUsedList[i] then
      Wid := Wid + IStr ( FManager.Glyphs [ FASCIIList[i]].CharInfo.Width ) + ' '
    else
      Wid := Wid + '0 ';
    if I mod 16 = 0 then
      Wid := Wid + #13#10;
  end;
  FFN := FManager.PostScriptName;
  if FIsEmbedded then
    FFN := FFontNameAddon+'+'+FFN;
  FontDescriptorID := Eng.GetNextID;
  Eng.StartObj ( FontDescriptorID );
  Eng.SaveToStream ( '/Type /FontDescriptor' );
  Eng.SaveToStream ( '/Ascent ' + IStr ( FManager.Ascent ) );
  Eng.SaveToStream ( '/CapHeight 666' );
  Eng.SaveToStream ( '/Descent ' + IStr ( FManager.Descent ) );
  Eng.SaveToStream ( '/Flags 32' );
  Eng.SaveToStream ( '/FontBBox [' + RectToStr(FManager.FontBox ) + ']' );
  Eng.SaveToStream ( '/FontName /' + FFN );
  Eng.SaveToStream ( '/ItalicAngle ' + IStr ( FManager.ItalicAngle ) );
  Eng.SaveToStream ( '/StemV 87' );
  if Eng.PDFACompatibile then
    Eng.SaveToStream ( '/MissingWidth 0' );
  if FIsEmbedded then
    Eng.SaveToStream ( '/FontFile2 ' + IStr ( FontFileID ) + ' 0 R' );
  Eng.CloseObj;
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /Font' );
  Eng.SaveToStream ( '/Subtype /TrueType' );
  Eng.SaveToStream ( '/BaseFont /' + FFN );
  Eng.SaveToStream ( '/FirstChar ' + IStr ( FFirstChar ) );
  Eng.SaveToStream ( '/LastChar ' + IStr ( FLastChar ) );
  Eng.SaveToStream ( '/Encoding /WinAnsiEncoding');
  Eng.SaveToStream ( '/FontDescriptor ' + IStr ( FontDescriptorID ) + ' 0 R' );
  Eng.SaveToStream ( '/Widths [' + Wid + ']' );
  Eng.CloseObj;
end;

procedure TPDFTrueTypeFont.SetAllASCII;
var
  I: Integer;
begin
  FUsed := True;
  FFirstChar := 32;
  FLastChar := 127;
  for I := 32 to 127 do
    FUsedList[i] := True;
end;

procedure TPDFTrueTypeFont.UsedChar(Ch:Byte);
begin

  if (Ch < 32) or (Ch >127) then
    Exit;
  FUsed := True;
  FUsedList[Ch] := True;
  if Ch > FLastChar then
    FLastChar := Ch;
  if Ch < FFirstChar then
    FFirstChar := Ch;
end;



procedure TPDFTrueTypeFont.MarkAsUsed(Glyph:PGlyphInfo;Unicode:Word);
var
  idx : Integer;
begin
  if Glyph^.ExtUsed then
    Exit;
  Glyph^.ExtUsed := true;
  FUsed := True;
  idx := (FarInteger(Pointer(Glyph)) - FarInteger(Pointer(FManager.Glyphs[0]))) div sizeof(TGlyphInfo);
  if (Unicode > 0 ) and (Unicode < 128) then
  begin
    Glyph^.CharInfo.NewCharacter := AnsiChar(Unicode);
    Glyph^.CharInfo.FontIndex := 0;
  end else
  begin
    if FCurrentChar = 128 then
    begin
      inc(FCurrentIndex);
      SetLength(FExtendedFonts,FCurrentIndex);
      FExtendedFonts[FCurrentIndex - 1] := TPDFTrueTypeSubsetFont.Create(Eng,Self);
      FExtendedFonts[FCurrentIndex - 1].FAlias := FAlias+'+'+IStr(FCurrentIndex);
      FCurrentChar := 32;
    end;
    Glyph^.CharInfo.NewCharacter := AnsiChar(FCurrentChar);
    Glyph^.CharInfo.FontIndex := FCurrentIndex;
    FExtendedFonts[FCurrentIndex - 1].FLast := FCurrentChar;
    FExtendedFonts[FCurrentIndex - 1].FIndexes[FCurrentChar] := idx;
    if Unicode > 0 then
      FExtendedFonts[FCurrentIndex - 1].FUnicodes[FCurrentChar] := Unicode
    else
      if Glyph^.Unicode < $FFFF then
        FExtendedFonts[FCurrentIndex - 1].FUnicodes[FCurrentChar] := Glyph^.Unicode
      else
        FExtendedFonts[FCurrentIndex - 1].FUnicodes[FCurrentChar] := 0;
    inc(FCurrentChar);
  end;
end;



function TPDFTrueTypeFont.GetSubset(Index: Integer): TPDFFont;
begin
  if (Index< 0) or (Index >=Length(FExtendedFonts)) then
    raise EPDFException.Create(SOutOfRange);
  result := FExtendedFonts[Index];
end;

function TPDFTrueTypeFont.GetNewCharByIndex(Index: Integer): PNewCharInfo;
var
  Glyph: PGlyphInfo;
begin
  Glyph := FManager.Glyphs[Index];
  MarkAsUsed(Glyph,0);
  Result := Pointer(Glyph);
end;

function TPDFTrueTypeFont.GetNewCharByUnicode(Index: Word): PNewCharInfo;
var
  Glyph: PGlyphInfo;
begin
  Glyph := FManager.GlyphByUnicode[Index];
  MarkAsUsed(Glyph,Index);
  Result := Pointer(Glyph);
end;

{ TPDFStandardFont }

constructor TPDFStandardFont.Create(Engine: TPDFEngine; Style: TPDFStdFont);
begin
 inherited Create( Engine);
 FStyle := Style;
end;

function TPDFStandardFont.GetAscent: Integer;
begin
  Result := StdFontAscent [ Ord(FStyle) ];
end;

function TPDFStandardFont.GetDescent: Integer;
begin
  Result := StdFontDescent [ Ord(FStyle) ]
end;

function TPDFStandardFont.GetWidth(Index: Word): Integer;
begin
  if Word(Index) >= 256 then
    raise EPDFException.Create(SOutOfRange);
  Result := stWidth [ Ord(FStyle), Word(Index) ];
end;

procedure TPDFStandardFont.Save;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /Font' );
  Eng.SaveToStream ( '/Subtype /Type1' );
  Eng.SaveToStream ( '/BaseFont /' + PDFStandardFontNames [ Ord(FStyle) ] );
  if FStyle < stdfSymbol then
    Eng.SaveToStream ( '/Encoding /WinAnsiEncoding' );
  Eng.SaveToStream ( '/FirstChar 32' );
  Eng.SaveToStream ( '/LastChar 255' );
  Eng.CloseObj;
end;


{ TPDFFont }


procedure TPDFFont.FillUsed(s:AnsiString);
begin

end;

procedure TPDFFont.SetAllASCII;
begin

end;

procedure TPDFFont.UsedChar(Ch:Byte);
begin

end;


{ TPDFFonts }


constructor TPDFFonts.Create(PDFEngine: TPDFEngine);
begin
  inherited Create(PDFEngine);
  FNonEmbeddedFonts := TStringList.Create;
end;

destructor TPDFFonts.Destroy;
begin
  inherited;
  FNonEmbeddedFonts.Free;
end;

procedure TPDFFonts.Clear;
var
  I: Integer;
begin
  for i := 0 to Length(FEngine.Resources.Fonts)  -1 do
    TPDFFont(FEngine.Resources.Fonts[I]).Free;
  FEngine.Resources.Fonts := nil;
  inherited;
end;


function TPDFFonts.GetCount: Integer;
begin
  Result := Length(FEngine.Resources.Fonts);
end;

function TPDFFonts.GetFontByInfo(StdFont: TPDFStdFont): TPDFFont;
var
  i: Integer;
  FNT: TPDFStandardFont;
begin
  for i := 0 to Length(FEngine.Resources.Fonts)  -1 do
    if FEngine.Resources.Fonts[i] is TPDFStandardFont then
      if TPDFStandardFont(FEngine.Resources.Fonts[i]).FStyle = StdFont then
      begin
        Result := FEngine.Resources.Fonts[i] as TPDFFont;
        Exit;
      end;
  FNT := TPDFStandardFont.Create(FEngine, StdFont);
  i := Length(FEngine.Resources.Fonts);
  SetLength(FEngine.Resources.Fonts, i+1);
  FEngine.Resources.Fonts[i] := FNT;
  FEngine.Resources.LastFont := FNT;
  FNT.FAlias := StdFontAliases[Ord(StdFont)];
  Result := FNT;
end;

function TPDFFonts.GetFontByInfo(FontName: String; Style: TFontStyles): TPDFFont;
var
 FA :String;
begin
  Style :=  Style - [fsUnderline, fsStrikeOut];
  FA:=UpperCase(FontName);
  Result :=GetTrueTypeFont(FontName, Style);
end;


function TPDFFonts.GetTrueTypeFont(FontName: String; Style: TFontStyles): TPDFFont;
var
  i: Integer;
  FS: TFontStyles;
  FN: String;
  TT: TPDFFont;
  IsEmbedded: Boolean;
begin
  FontName := UpperCase(FontName);
  for i := 0 to Length(FEngine.Resources.Fonts)  -1 do
    if FEngine.Resources.Fonts[i] is TPDFTrueTypeFont then
      if (TPDFTrueTypeFont(FEngine.Resources.Fonts[i]).Style = Style) and
        (TPDFTrueTypeFont(FEngine.Resources.Fonts[i]).Name = FontName) then
      begin
        Result := FEngine.Resources.Fonts[i] as TPDFFont;
        Exit;
      end;
  FS := Style;
  FN := FontName;
  if not FontTest ( FN, FS ) then
  begin
    Result := GetFontByInfo ( 'Arial', Style );
    Exit;
  end;
  if FN <> FontName then
    FontName := UpperCase(FN);
  if FS <> Style then
    for i := 0 to Length(FEngine.Resources.Fonts)  - 1 do
      if FEngine.Resources.Fonts[i] is TPDFTrueTypeFont then
        if (TPDFTrueTypeFont(FEngine.Resources.Fonts[i]).Style = FS) and
          (TPDFTrueTypeFont(FEngine.Resources.Fonts[i]).Name = FontName) then
        begin
          Result := FEngine.Resources.Fonts[i] as TPDFFont;
          Exit;
        end;
  IsEmbedded := True;
  for I := 0 to FNonEmbeddedFonts.Count - 1 do
    if UpperCase(FNonEmbeddedFonts [ I ] ) = FontName then
    begin
      IsEmbedded := False;
      Break;
    end;
  TT := TPDFTrueTypeFont.Create(FEngine, FontName, FS, IsEmbedded);
  i := Length(FEngine.Resources.Fonts);
  SetLength(FEngine.Resources.Fonts, i+1);
  FEngine.Resources.Fonts[i] := TT;
  TT.FAlias := 'TT'+IStr(i);
  Result := TT;
  FEngine.Resources.LastFont := TT;
end;

procedure TPDFFonts.Save;
var
  i: Integer;
begin
  for i := 0 to Length(FEngine.Resources.Fonts)  -1 do
    if TPDFFont(FEngine.Resources.Fonts[i]).FontUsed then
      FEngine.SaveObject(FEngine.Resources.Fonts[i]);
end;

procedure TPDFFonts.SetNonEmbeddedFonts(const Value: TStringList);
begin
  FNonEmbeddedFonts.Assign(Value);
end;


{ TPDFTrueTypeSubsetFont }

constructor TPDFTrueTypeSubsetFont.Create(Engine:TPDFEngine; AParent: TPDFTrueTypeFont);
begin
  inherited Create(Engine);
  FParent := AParent;
end;

destructor TPDFTrueTypeSubsetFont.Destroy;
begin

  inherited;
end;

function TPDFTrueTypeSubsetFont.GetAscent: Integer;
begin
  Result := FParent.Ascent;
end;

function TPDFTrueTypeSubsetFont.GetDescent: Integer;
begin
  Result := FParent.Descent;
end;

function TPDFTrueTypeSubsetFont.GetWidth(Index: Word): Integer;
begin
  Result := FParent.GetWidth(Index);
end;

procedure TPDFTrueTypeSubsetFont.GetToUnicodeStream ( Alias: AnsiString; Stream: TStream;AliasName:AnsiString);
var
  SS: TAnsiStringList;
  I: Integer;
begin
  ss := TAnsiStringList.Create ;
  try
    ss.Add ( '/CIDInit /ProcSet findresource begin 12 dict begin begincmap /CIDSystemInfo << ' );
    ss.Add ( '/Registry (' + AliasName + ') /Ordering ('+AliasName+'+) /Supplement 0 >> def' );
    ss.Add ( '/CMapName /' + AliasName + '+0 def' );
    ss.Add ( '/CMapType 2 def' );
    ss.Add ( '1 begincodespacerange <' + ByteToHex ( 32 ) + '> <' + ByteToHex ( FLast ) + '> endcodespacerange' );
{$ifdef UNICODE}
    ss.LineBreak :='';
{$endif}
    ss.Add ( IStr ( FLast -31 ) + ' beginbfchar' );
    for i:= 32 to FLast do
      ss.Add ( '<' + ByteToHex ( i ) + '> <' + WordToHex ( FUnicodes [ i ] ) + '>' );
    ss.Add ( 'endbfchar' );
    ss.Add ( 'endcmap CMapName currentdict /CMap defineresource pop end end' );
    ss.SaveToStream(Stream);
  finally
    ss.Free;
  end;
end;


procedure TPDFTrueTypeSubsetFont.Save;
var
  I, L: Integer;
  Wid: AnsiString;
  MS, MS1: TMemoryStream;
  CS: TCompressionStream;
  RS: Integer;
  FFN: AnsiString;
  FontDescriptorID: Integer;
  FontFileID, UnicodeID: Integer;
begin
  FFN := FParent.FFontNameAddon+'+'+FParent.FManager.PostScriptName;
  UnicodeID := Eng.GetNextID;
  Eng.StartObj ( UnicodeID );
  MS1 := TMemoryStream.Create;
  try
    CS := TCompressionStream.Create ( clDefault, MS1 );
    try
      GetToUnicodeStream ( AliasName, CS, FFN );
    finally
      CS.Free;
    end;
    Eng.SaveToStream ( '/Filter /FlateDecode /Length ' + IStr ( CalcAESSize( Eng.SecurityInfo.State,MS1.Size ) ) );
    Eng.StartStream;
    ms1.Position := 0;
    CryptStreamToStream(Eng.SecurityInfo, MS1, Eng.Stream, UnicodeID);
    Eng.CloseStream;
  finally
    MS1.Free;
  end;
  Eng.CloseObj;

  MS := TMemoryStream.Create;
  try
    FParent.FManager.PrepareFont(@FIndexes,FLast - 31, MS);
    RS := MS.Size;
    MS.Position := 0;
    MS1 := TMemoryStream.Create;
    try
      CS := TCompressionStream.Create ( clMax, MS1 );
      try
        CS.CopyFrom ( MS, MS.Size );
      finally
        CS.Free;
      end;
      MS.Clear;
      FontFileID := Eng.GetNextID;
      Eng.StartObj ( FontFileID );
      Eng.SaveToStream ( '/Filter /FlateDecode /Length ' + IStr ( CalcAESSize( Eng.SecurityInfo.State,MS1.Size ) ) +
        ' /Length1 ' + IStr ( RS ) );
      Eng.StartStream;
      ms1.Position := 0;
      CryptStreamToStream(Eng.SecurityInfo, MS1, Eng.Stream, FontFileID);
      Eng.CloseStream;
    finally
      MS1.Free;
    end;
  finally
    MS.Free;
  end;
  Wid := '';
  L := 1;
  for I := 32 to FLast do
  begin
      Wid := Wid + IStr ( FParent.FManager.Glyphs [ FIndexes[i]].CharInfo.Width ) + ' ';
    inc(L);
    if L mod 16 = 0 then
      Wid := Wid + #13#10;
  end;
  FontDescriptorID := Eng.GetNextID;
  Eng.StartObj ( FontDescriptorID );
  Eng.SaveToStream ( '/Type /FontDescriptor' );
  Eng.SaveToStream ( '/Ascent ' + IStr ( FParent.FManager.Ascent ) );
  Eng.SaveToStream ( '/CapHeight 666' );
  Eng.SaveToStream ( '/Descent ' + IStr ( FParent.FManager.Descent ) );
  Eng.SaveToStream ( '/Flags 32' );
  Eng.SaveToStream ( '/FontBBox [' + RectToStr(FParent.FManager.FontBox ) + ']' );
  Eng.SaveToStream ( '/FontName /' + FFN );
  Eng.SaveToStream ( '/ItalicAngle ' + IStr ( FParent.FManager.ItalicAngle ) );
  Eng.SaveToStream ( '/StemV 87' );
  if Eng.PDFACompatibile then
    Eng.SaveToStream ( '/MissingWidth 0' );
  Eng.SaveToStream ( '/FontFile2 ' + IStr ( FontFileID ) + ' 0 R' );
  Eng.CloseObj;
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /Font' );
  Eng.SaveToStream ( '/Subtype /TrueType' );
  Eng.SaveToStream ( '/BaseFont /' + FFN );
  Eng.SaveToStream ( '/FirstChar 32');
  Eng.SaveToStream ( '/LastChar ' + IStr ( FLast ) );
  Eng.SaveToStream ( '/Encoding /WinAnsiEncoding' );
  Eng.SaveToStream ( '/ToUnicode ' + GetRef ( UnicodeID )  );
  Eng.SaveToStream ( '/FontDescriptor ' + IStr ( FontDescriptorID ) + ' 0 R' );
  Eng.SaveToStream ( '/Widths [' + Wid + ']' );
  Eng.CloseObj;
end;

end.
