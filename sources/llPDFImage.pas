{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFImage;
{$i pdf.inc}
interface
uses
{$ifndef USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math, Jpeg,
{$else}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
  Vcl.Imaging.jpeg,
{$endif}
  llPDFTypes,llPDFEngine;

type


  TImgPoint = record
    x: integer;
    y: integer;
  end;

  TImgBorder = record
    LeftTop:TImgPoint;
    RightBottom:TImgPoint;
  end;

  TBWImage = class
  private
    FBuffer: PCardinalArray;
    FHeight: Integer;
    FWidth: Integer;
    FLineSize :Integer;
    FMemorySize: Integer;
    function GetPixel(X, Y: Integer): Boolean;
    function NormalizeSize(X,Y: integer;var W, H: integer): Boolean;
    procedure SetPixel(X, Y: Integer; const Value: Boolean);
  public
    constructor Create(W,H: Integer;InitialColorIsBlack:Boolean=False); overload;
    constructor Create(BMP: TBitmap);overload;
    constructor CreateCopy(Img: TBWImage);
    destructor Destroy;override;
    procedure ClearRectangle(X, Y, W, H: Integer);
    procedure CopyRectangleTo(Destination: TBWImage;SX, SY, DX, DY, W, H: Integer;
        ClearDestination: Boolean = False);
    procedure CopyToBitmap(BMP: TBitmap);
    function CheckNeighbor(X, Y, Level: integer): boolean;
    function GetBlackPoint(var BlackPoint: TImgPoint): Boolean;
    function GetBorder(StartPosition: TImgPoint): TImgBorder;
    procedure DrawHorLine(XStart,XEnd, Y:Integer;IsBlack:Boolean);
    procedure MoveAndClear(DestSymbol: TBWImage; StartPosition: TImgPoint;Border: TImgBorder);
    procedure InitBlackPoint(var BlackPoint: TImgPoint);
    procedure SaveToFile(FileName:String);
    property Pixel[X,Y: Integer]:Boolean read GetPixel write SetPixel;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Memory: PCardinalArray read FBuffer;
    property MemorySize: Integer read FMemorySize;
  end;


  /// <summary>
  ///   It describes the options allowing for which JBIG2 compression of black and white images will be held 
  /// </summary>

  TJBIG2Options = class( TPersistent)
  private
    FLossyLevel: Integer;
    FSkipBlackDots: Boolean;
    FBlackDotSize: Integer;
    FSymbolExtract: TImgCopyType;
//    FUseSingleDictionary: Boolean;
  public
    constructor Create;
    /// <summary>
    ///   Noise level at compression. When the value is 0 then compared characters must be
    ///   identical, 9 - in this case the size will be identical 
    /// </summary>
    property LossyLevel: Integer read FLossyLevel write FLossyLevel ;

    /// <summary>
    ///   When scanning pages noises, which are not true  symbols can often occur
     /// This Property can delete such noise
    /// </summary>
    property SkipBlackDots:Boolean read FSkipBlackDots write FSkipBlackDots;
    /// <summary>
    ///   The size of black dots, that will be ignored during compressionif SkipBlackDots is set for 
    ///   positive value
    /// </summary>
    property BlackDotSize: Integer read FBlackDotSize write FBlackDotSize;
    /// <summary>
    ///   In many scanned documents symbols may be within certain areas and tables
    /// Then if we use icRectangle, it will be "during compression" such tables as a whole,
    /// Considering the characters withtin, if icImageOnly is used each character is individually cut
    /// </summary>
    property SymbolExtract:TImgCopyType read FSymbolExtract write FSymbolExtract;
    //    property UseSingleDictionary: Boolean read FUseSingleDictionary write FUseSingleDictionary;
{#int}    
  end;



  TPDFImages = class;

  TPDFImage = class(TPDFObject)
  private
    FBitPerPixel: Integer;
    FBWInvert: Boolean;
    FCompression: TImageCompressionType;
    FData: TMemoryStream;
    FJBIG2Data: TMemoryStream;
    FGrayScale: Boolean;
    FHeight: Integer;
    FIsMask: Boolean;
    FLoaded: Boolean;
    FMaskIndex: Integer;
    FWidth: Integer;
    FOwner: TPDFImages;
  protected
    procedure Save;override;
  public
    constructor Create(Engine: TPDFEngine;AOwner: TPDFImages);
    destructor Destroy; override;
    procedure Load(Image:TGraphic; Compression: TImageCompressionType);
    property IsMask: Boolean read FIsMask write FIsMask;
    property BitPerPixel: Integer read FBitPerPixel;
    property GrayScale: Boolean read FGrayScale;
    property Height: Integer read FHeight;
    property Width:Integer read FWidth;

  end;

  /// <summary>
  ///   Managing object which adds images in PDF documents
  /// </summary>
  /// <remarks>
  ///   This object can not be created independently. Property TPDFDocument.Images should beused.
  /// </remarks>
  TPDFImages = class(TPDFManager)
  private
    FJPEGQuality: Integer;
    FJBIG2Options: TJBIG2Options;
    FJBIG2Dictionary: TPDFObject;
    function Add(Image:TPDFImage):Integer;
    function AddImageWithParams(Image: TGraphic; Compression:
        TImageCompressionType;MaskIndex:Integer = - 1): Integer;
  protected
    procedure Clear;override;
    function GetCount: Integer;override;
    procedure Save;override;
  public
    constructor Create(PDFEngine: TPDFEngine);
    destructor Destroy;override;
    /// <summary>
    ///   Adds an image from TGraphic in the generated document taking compression into account. Currently
    ///   TBitmap and TJPegImage are supported
    /// </summary>
    /// <param name="Image">
    ///   An object that stores the image you want to insert into the document
    /// </param>
    /// <param name="Compression">
    ///   compression type, by which the image will be saved in the document
    /// </param>
    /// <returns>
    ///   Returns index of the saved in the document image.
    /// </returns>
    /// <remarks>
    ///   Since the image can take a large size, it is immediately written to the generated
    /// output stream or file
    /// </remarks>
    function AddImage(Image: TGraphic; Compression: TImageCompressionType): Integer; overload;

    /// <summary>
    ///   Adds an image from file in the generated document according to the compression. Currently
    ///   bmp and jpeg formats are supported
    /// </summary>
    /// <param name="FileName">
    ///   The file name in which stores the image you want to insert into the document
    /// </param>
    /// <param name="Compression">
    ///   compression type, by which the image will be saved in the document
    /// </param>
    /// <returns>
    ///   Returns the index of the saved in the document image.
    /// </returns>
    /// <remarks>
    ///   Since the image can take a large size, it is immediately written to the generated 
    /// output stream or file
    /// </remarks>
    function AddImage(FileName:TFileName; Compression: TImageCompressionType): Integer; overload;
    /// <summary>
    ///   In some cases, you want to display in the document not a rectangular image, but some
    /// Part of it. In this case, we can use a mask. The mask is black and white image,
    /// Which shows what part of the image, which is used to output the mask is necessary.
    ///   This function is designed to create a mask in the document
    /// </summary>
    /// <param name="Image">
    ///   An object that stores mask image 
    /// </param>
    /// <param name="TransparentColor">
    ///   color, which is considered transparent in this image
    /// </param>
    /// <returns>
    ///   It returns the index of stored masks.
    /// </returns>
    function AddImageAsMask(Image: TGraphic; TransparentColor: TColor = -1): Integer;
    /// <summary>
    ///   This function saves image with a mask in a document. 
    /// </summary>
    /// <param name="Image">
    ///   An object that stores the image you want to insert into the document
    /// </param>
    /// <param name="Compression">
    ///   compression type, by which the image will be saved in the document
    /// </param>
    /// <param name="MaskIndex">
    ///   Index of the mask to be used with this image further.
    /// </param>
    /// <returns>
    ///   The function returns the index of the mask image 
    /// </returns>
    /// <remarks>
    ///   One and the same mask may be used for multiple images
    /// </remarks>
    function AddImageWithMask(Image:TGraphic; Compression: TImageCompressionType;MaskIndex: Integer): Integer;
    /// <summary>
    ///   In some cases, we know what color in the source image should not be displayed. This
     /// Function combines two functions such as AddImageAsMask and AddImageWithMask.
    /// </summary>
    /// <param name="Image">
    ///   An object that stores the image you want to insert into the document    
    /// </param>
    /// <param name="Compression">
    ///   compression type, by which the image will be saved in the document
    /// </param>
    /// <param name="TransparentColor">
    ///   color, which is considered transparent in this image
    /// </param>
    /// <returns>
    ///   It returns the index of the image with a transparent color in the generated document
    /// </returns>
    function AddImageWithTransparency(Image: TGraphic; Compression: TImageCompressionType; TransparentColor: TColor = -1): Integer;

    /// <summary>
    ///   The compression quality level of the JPEG images in the document. Please note that the image is
    /// written to the output stream immediately, so the value will be considered only for those
    /// Images that were added after the change in this value    
    /// </summary>
    property JPEGQuality: Integer read FJPEGQuality write FJPEGQuality ;
    /// <summary>
    ///   The set of options used for JBIG2 compression. Please note that
    /// Images are recorded in the output stream immediately, so the value will be taken into account
    /// Only for those images that have been added after the change of the value
    /// </summary>
    property JBIG2Options: TJBIG2Options read FJBIG2Options;
  end;


implementation

uses
{$ifdef WIN64}
  System.ZLib, System.ZLibConst,
{$else}
  llPDFFlate,
{$endif}
  llPDFMisc, llPDFResources, llPDFCCITT, llPDFJBIG2,
  llPDFSecurity, llPDFCrypt;

{ TPDFImages }

{
********************************** TPDFImages **********************************
}


function TPDFImages.AddImage(FileName: TFileName;
  Compression: TImageCompressionType): Integer;
var
  Gr: TGraphic;
  MS: TMemoryStream;
  BMSig: Word;
begin
  MS := TMemoryStream.Create;
  try
    MS.LoadFromFile ( FileName );
    MS.Position := 0;
    MS.Read ( BMSig, 2 );
    MS.Position := 0;
    if BMSig = 19778 then
      GR := TBitmap.Create
    else
      GR := TJPEGImage.Create;
    try
      Gr.LoadFromStream ( MS );
      Result := AddImage ( Gr, Compression );
    finally
      Gr.Free;
    end;
  finally
    MS.Free;
  end;

end;

function TPDFImages.AddImageWithParams(Image: TGraphic; Compression: TImageCompressionType;MaskIndex:Integer = - 1): Integer;
var
  PDFImage: TPDFImage;
  DIB: DIBSECTION;
  B: TBitmap;
begin
  if Compression >=  itcCCITT3  then
  begin
    if  not ( Image is TBitmap ) then
      raise EPDFException.Create ( SCCITTCompressionWorkOnlyForBitmap );
    B := TBitmap ( Image );
    if B.PixelFormat <> pf1bit then
    begin
      if B.PixelFormat = pfDevice then
      begin
        DIB.dsBmih.biSize := 0;
        GetObject( B.Handle, sizeof (DIB), @DIB);
        if DIB.dsBm.bmBitsPixel = 1 then
          B.PixelFormat := pf1bit
        else
          raise Exception.Create ( SCannotCompressNotMonochromeImageViaCCITT );
      end
      else
        raise Exception.Create ( SCannotCompressNotMonochromeImageViaCCITT );
    end;
  end;
  PDFImage := TPDFImage.Create( FEngine, self );
  try
    PDFImage.Load( Image, Compression);
  except
    PDFImage.Free;
    raise;
  end;
  PDFImage.FIsMask := False;
  PDFImage.FMaskIndex := MaskIndex;
  PDFImage.Save;
  Result := Add (PDFImage);
  if TJBig2SymbolDictionary(FJBIG2Dictionary).TotalWidth > 131071 then
  begin
    FEngine.SaveObject(FJBIG2Dictionary);
    TJBig2SymbolDictionary(FJBIG2Dictionary).Clear;
  end;
end;


function TPDFImages.AddImage(Image: TGraphic; Compression: TImageCompressionType): Integer;
begin
  Result := AddImageWithParams(Image,Compression);
end;

function TPDFImages.AddImageAsMask(Image: TGraphic; TransparentColor: TColor =  -1): Integer;
var
  B: TBitmap;
  PDFImage: TPDFImage;
begin
  Result := -1;
  if not ( Image is TBitmap ) then
    raise EPDFException.Create ( SCreateMaskAvailableOnlyForBitmapImages );
  B := TBitmap.Create;
  try
    B.Assign ( Image );
    B.PixelFormat := pf24bit;
    if TransparentColor = -1 then
      TransparentColor := B.TransparentColor;
    B.Mask ( TransparentColor );
    B.Monochrome := True;
    B.PixelFormat := pf1bit;
    PDFImage := TPDFImage.Create( FEngine, Self );
    try
      PDFImage.Load( B, itcCCITT4);
    except
      PDFImage.Free;
      raise;
    end;
    with PDFImage do
    begin
      FIsMask := True;
      FBitPerPixel := 1;
      FGrayScale := True;
    end;
    PDFImage.Save;
    Result := Add (PDFImage);
  finally
    B.Free;
  end;
end;

function TPDFImages.AddImageWithMask(Image:TGraphic; Compression:
        TImageCompressionType;MaskIndex: Integer): Integer;
begin
  if MaskIndex >= Count then
    raise EPDFException.Create ( SUnknowMaskImageOutOfBound );
  if not TPDFImage ( FEngine.Resources.Images [ MaskIndex ] ).FIsMask then
    raise EPDFException.Create ( SMaskImageNotMarkedAsMaskImage );
  Result := AddImageWithParams(Image, Compression,MaskIndex);
end;

function TPDFImages.AddImageWithTransparency(Image: TGraphic; Compression:
        TImageCompressionType; TransparentColor: TColor = -1): Integer;
var
  MaskIndex: Integer;
begin
  MaskIndex := AddImageAsMask( Image, TransparentColor);
  Result := AddImageWithMask( Image, Compression, MaskIndex);
end;

procedure TPDFImages.Clear;
var
  i: Integer;
begin
  for i:= 0 to Length(FEngine.Resources.Images) -1 do
  begin
    TPDFImage( FEngine.Resources.Images[i]).Free;
  end;
  FEngine.Resources.Images := nil;
  TJBig2SymbolDictionary(FJBIG2Dictionary).ClearDictionary;
  inherited;
end;

function TPDFImages.GetCount: Integer;
begin
  Result := Length(FEngine.Resources.Images);
end;


procedure TPDFImages.Save;
begin
  if TJBig2SymbolDictionary(FJBIG2Dictionary).TotalWidth > 0 then
  begin
    FEngine.SaveObject(FJBIG2Dictionary);
    TJBig2SymbolDictionary(FJBIG2Dictionary).Clear;
  end;
end;

function TPDFImages.Add(Image: TPDFImage): Integer;
var
  i: Integer;
begin
  i := Length(FEngine.Resources.Images);
  SetLength(FEngine.Resources.Images, i+1);
  FEngine.Resources.Images[i]:= Image;
  Result := i;
end;


{ TPDFImage }

{
********************************** TPDFImage ***********************************
}
constructor TPDFImage.Create(Engine: TPDFEngine;AOwner: TPDFImages );
begin
  inherited Create ( Engine );
  FLoaded := False;
  FMaskIndex := -1;
  FIsMask := False;
  FOwner := AOwner;
  FJBIG2Data := nil;
end;

destructor TPDFImage.Destroy;
begin
  inherited;
end;

procedure TPDFImage.Load(Image:TGraphic; Compression: TImageCompressionType);
var
  J: TJPEGImage;
  B: TBitmap;
  CS: TCompressionStream;
  Global: TJBig2SymbolDictionary;
  JBIG2Compression : TJBIG2Compression;
  pb: PByteArray;
  bb: Byte;
  p: Byte;
  x, y: Integer;

begin
  if not ( ( Image is TJPEGImage ) or ( Image is TBitmap ) ) then
    raise EPDFException.Create ( SNotValidImage );
  if ( Image is TBitmap ) and ( TBitmap ( Image ).PixelFormat = pf1bit ) and ( Compression <> itcJpeg ) then
  begin
    pb := TBitmap ( Image ).ScanLine [ 0 ];
    bb := pb [ 0 ] shr 7;
    if TBitmap ( Image ).Canvas.Pixels [ 0, 0 ] > 0 then
      p := 1
    else
      p := 0;
    FBWInvert := p <> bb;
  end
  else
    FBWInvert := False;
  FWidth := Image.Width;
  FHeight := Image.Height;
  FCompression := Compression;
  FData := TMemoryStream.Create;
//  if FOwner.FJBIG2Options.UseSingleDictionary then
//    Global := TJBig2SymbolDictionary(FOwner.FJBIG2Dictionary)
//  else
    Global := nil;
  case Compression of
    itcJpeg:
      begin
        J := TJPEGImage.Create;
        try
          J.Assign ( Image );
          J.ProgressiveEncoding := False;
          J.CompressionQuality := FOwner.FJPEGQuality;
          J.SaveToStream ( FData );
          if J.Grayscale then
            FGrayscale := True;
          FBitPerPixel := 8;
        finally
          J.Free;
        end;
     end;
    itcFlate:
      begin
        B := TBitmap.Create;
        try
          B.Assign ( Image );
          b.PixelFormat := pf24bit;
          CS := TCompressionStream.Create ( clDefault, FData );
          try
            for y := 0 to B.Height - 1 do
            begin
              pb := B.ScanLine [ y ];
              x := 0;
              while x <= ( b.Width - 1 ) * 3 do
              begin
                bb := pb [ x ];
                pb [ x ] := pb [ x + 2 ];
                pb [ x + 2 ] := bb;
                x := x + 3;
              end;
              CS.Write ( pb^, b.Width * 3 );
            end;
          finally
            CS.Free;
          end;
          FBitPerPixel := 8;
          FGrayScale := False;
        finally
          B.Free;
        end;
      end;
    itcCCITT3..itcJBIG2:
      begin
        B := TBitmap ( Image );
        FBitPerPixel := 1;
        case Compression of
          itcCCITT3: SaveBMPtoCCITT ( B, FData, CCITT31D );
          itcCCITT32d: SaveBMPtoCCITT ( B, FData, CCITT32D );
          itcCCITT4: SaveBMPtoCCITT ( B, FData, CCITT42D );
          itcJBIG2:
            begin
              JBIG2Compression := TJBIG2Compression.Create(Global,FOwner.JBIG2Options);
              try
                JBIG2Compression.Execute(FData,B);
              finally
                JBIG2Compression.Free;
              end;
            end;
        end;
      end;
  end;
  FLoaded := True;
end;

procedure TPDFImage.Save;
var
  Invert: AnsiString;
begin
  Eng.StartObj ( ID );
  Eng.SaveToStream ( '/Type /XObject' );
  Eng.SaveToStream ( '/Subtype /Image' );
  if ( FBitPerPixel <> 1 ) and ( not FGrayScale ) then
    Eng.SaveToStream ( '/ColorSpace /DeviceRGB' )
  else
    Eng.SaveToStream ( '/ColorSpace /DeviceGray' );
  Eng.SaveToStream ( '/BitsPerComponent ' + IStr ( FBitPerPixel ) );
  Eng.SaveToStream ( '/Width ' + IStr ( FWidth ) );
  Eng.SaveToStream ( '/Height ' + IStr ( FHeight ) );
  if FIsMask then
    Eng.SaveToStream ( '/ImageMask true' );
  if FMaskIndex <> -1 then
    Eng.SaveToStream ( '/Mask ' + TPDFImage ( Eng.Resources.Images [ FMaskIndex ] ).RefID );
  case FCompression of
    itcJpeg: Eng.SaveToStream ( '/Filter /DCTDecode' );
    itcFlate: Eng.SaveToStream ( '/Filter /FlateDecode' );
    itcJBIG2: Eng.SaveToStream ( '/Filter /JBIG2Decode' );
  else
    begin
      Eng.SaveToStream ( '/Filter [/CCITTFaxDecode]' );
      if FBWInvert then Invert := '/BlackIs1 true' else Invert := '';
    end;
  end;
  Eng.SaveToStream ( '/Length ' + IStr ( CalcAESSize(Eng.SecurityInfo.State, FData.Size ) ) );
  case FCompression of
    itcCCITT3: Eng.SaveToStream ( '/DecodeParms [<</K 0 /Columns ' + IStr ( FWidth ) + ' /Rows ' + IStr ( FHeight ) + Invert +'>>]' );
    itcCCITT32d: Eng.SaveToStream ( '/DecodeParms [<</K 1 /Columns ' + IStr ( FWidth ) + ' /Rows ' + IStr ( FHeight ) + Invert + '>>]' );
    itcCCITT4: Eng.SaveToStream ( '/DecodeParms [<</K -1 /Columns ' + IStr ( FWidth ) + ' /Rows ' + IStr ( FHeight ) +  Invert + '>>]' );
    itcJBIG2:
      begin
//        if FOwner.FJBIG2Options.FUseSingleDictionary then
//          Eng.SaveToStream('/DecodeParms <</JBIG2Globals '+IntToStr(FOwner.FJBIG2Dictionary.ID)+' 0 R >>');
      end;
  end;
  Eng.StartStream;
  CryptStream ( FData );
  FData.Free;
  Eng.CloseStream;
end;


{ TBWImage }


procedure TBWImage.ClearRectangle(X, Y, W, H: Integer);
var
  I,J: integer;
  Start,Finish,StartBit,
  FinishBit, Offset:Integer;
  Count : Integer;
begin
  if not NormalizeSize(X,Y,W,H) then
    Exit;
  Offset :=   Y*FLineSize;
  Start := X shr 5 ;
  StartBit := X and 31;

  if StartBit = 0 then
  begin
    Count := W shr 5;
    FinishBit := W and 31;
    for i := 0 to H - 1 do
    begin
      for j := 0 to Count - 1 do
        FBuffer[Offset+Start+j] := 0;
      if FinishBit <> 0 then
        FBuffer[Offset+Start+Count] := FBuffer[Offset+Start+Count] and ($FFFFFFFF shr FinishBit);
      Inc(Offset,FLineSize);
    end;
    Exit;
  end;
  StartBit := 32 - StartBit;
  Finish :=  (X + W) shr 5;
  FinishBit := (X + W) and 31;
  for i := 0 to H - 1  do
  begin
    if Start <> Finish then
    begin
      FBuffer[Start+Offset] := FBuffer[Start+Offset] and ($FFFFFFFF shl StartBit);
      for j:=  Start + 1 to Finish - 1 do
        FBuffer[j+Offset] := 0;
      if FinishBit <> 0 then
        FBuffer[Finish+Offset] := FBuffer[Finish+Offset] and ($FFFFFFFF shr FinishBit);
    end else
    begin
      FBuffer[Start+Offset] := FBuffer[Start+Offset] and (($FFFFFFFF shl StartBit) or ($FFFFFFFF shr FinishBit));
    end;
    Inc(Offset,FLineSize);
  end;
end;



procedure TBWImage.CopyRectangleTo(Destination: TBWImage;SX, SY, DX, DY, W, H:
    Integer; ClearDestination: Boolean = False);
var
  i, t, j: Integer;
  Tmp: TBWImage;
  Wrk, WrkDest: integer;
  Full, Part:Cardinal;
  Start,StartBit, Offset, C:Cardinal;

  OffsetDest: Cardinal;
  StartBitDest: Cardinal;
  StartDest: Cardinal;
begin
  if not Destination.NormalizeSize(DX,DY,W,H) then
    Exit;
  if not NormalizeSize(SX,SY,W,H) then
    Exit;
  if Destination = Self then
  begin
    Tmp := TBWImage.Create(W,H);
    try
      CopyRectangleTo(Tmp,Sx,SY,0,0,W,H);
      Tmp.CopyRectangleTo(Tmp,0,0,Dx,Dy,W,H);
    finally
      Tmp.Free;
    end;
    Exit;
  end;
  if ClearDestination then
    Destination.ClearRectangle(DX,DY,W,H);
  Full := (W+31) shr 5;
  T := Full - 1;
  Part := W and 31;

  Start := SX shr 5 ;
  StartBit := SX and 31;
  Offset :=   SY*FLineSize;
  StartDest := DX shr 5 ;
  StartBitDest := DX and 31;
  OffsetDest :=   DY*Destination.FLineSize;

  Wrk := Offset + Start;
  WrkDest := OffsetDest + StartDest;

  for i := 0 to H - 1 do
  begin
    for j := 0 to Full - 1 do
    begin
      if StartBit = 0 then
        C := FBuffer[wrk+j]
      else
      begin
        C :=  FBuffer[wrk+j] shl StartBit or FBuffer[wrk+j+1] shr (32- StartBit);
      end;
      if (Part <> 0) and (j = t) then
        C := C and ($FFFFFFFF shl (32-Part));
      if StartBitDest = 0 then
      begin
        Destination.FBuffer[WrkDest+j] := Destination.FBuffer[WrkDest+j] or C;
      end else
      begin
        Destination.FBuffer[WrkDest+j] := Destination.FBuffer[WrkDest+j] or (C  shr StartBitDest);
        Destination.FBuffer[WrkDest+j+1] := Destination.FBuffer[WrkDest+j+1] or (C  shl (32 - StartBitDest));
      end;
    end;
    Inc(Wrk,FLineSize);
    Inc(WrkDest,Destination.FLineSize);
  end;
end;



procedure TBWImage.CopyToBitmap(BMP: TBitmap);
var
  i,j: Cardinal;
  Off: Cardinal;
  Dst:PCardinalArray;
begin
  bmp.PixelFormat := pf1bit;
  bmp.Width := Width;
  bmp.Height := Height;
  Off := 0;
  for j := 0 to FHeight - 1 do
  begin
    Dst := BMP.ScanLine[j];
    for i := 0 to FLineSize - 1 do
      Dst[i] := not ByteSwap(FBuffer[off+i]);
    inc(off,FLineSize);
  end;
end;

constructor TBWImage.Create(W,H: Integer;InitialColorIsBlack:Boolean=False);
var
  I: Integer;
  Color:Cardinal;
begin
   FWidth := W;
   FHeight := H;
   FLineSize := (W+31) shr 5;
   FMemorySize := H * FLineSize;
   FBuffer := GetMemory((FMemorySize+1) shl 5 );
   if InitialColorIsBlack then
     Color := $FFFFFFFF
   else
     Color := 0;
   for I := 0 to FMemorySize do
     FBuffer[i] := Color;
end;


constructor TBWImage.CreateCopy(Img: TBWImage);
begin
   FWidth := Img.Width;
   FHeight := Img.FHeight;
   FLineSize := (FWidth+31) shr 5;
   FMemorySize := FHeight * FLineSize;
   FBuffer := GetMemory((FMemorySize+1) shl 5 );
   Move(Img.FBuffer[0],FBuffer[0], (FMemorySize+1) shl 5 );
end;


constructor TBWImage.Create(BMP: TBitmap);
var
  i,J: Cardinal;
  Off: Cardinal;
  inverse:Boolean;
  MemBlack,CanvasBlack:Boolean;
  C: Cardinal;
  Src:PCardinalArray;
  Bits: Integer;
  Mask : Cardinal;
begin
  if bmp.PixelFormat <> pf1bit then
    raise Exception.Create('Creation possible for b/w images only');
  Create(BMP.Width,BMP.Height);
  MemBlack := PByte(BMP.ScanLine[0])^ and $80 <> 0;
  CanvasBlack:= BMP.Canvas.Pixels[0,0]= clBlack;
  inverse :=  MemBlack <> CanvasBlack;
  Off := 0;
  Bits := FWidth and 31;
  if Bits <> 0 then
    Mask := not($FFFFFFFF shr Bits)
  else
    Mask := $FFFFFFFF;
  for i := 0 to FHeight - 1 do
  begin
    Src := BMP.ScanLine[i];
    for j := 0 to FLineSize - 1 do
    begin
      C := byteswap(Src[j]);
      if inverse then C := not C;
      FBuffer[off+j] := C;
    end;
    inc(off,FLineSize);
    if Bits <> 0 then
      FBuffer[Off - 1] := FBuffer[Off - 1] and Mask;
  end;
end;


destructor TBWImage.Destroy;
begin
  FreeMemory(FBuffer);
  inherited;
end;
{
procedure TBWImage.SetPixel(X, Y: Integer; const Value: Boolean);
var
  C, Mask: Cardinal;
begin
  C := Y * FLineSize+ X shr 5;
  Mask := 1 shl (31 - X and 31);
  if Value then
    FBuffer[C] := FBuffer[C] or Mask
  else
    FBuffer[C] := FBuffer[C] and not Mask;
end;

procedure TBWImage.DrawHorLine(XStart, XEnd, Y: Integer; IsBlack: Boolean);
var
  I,J: Integer;
  Start,Finish,StartBit,
  FinishBit, Offset:Integer;
  Count :  Integer;
  Color: Cardinal;

  W: Integer;
begin
  if Y >= FHeight then
    Exit;
  if XStart >= FWidth then
    Exit;
  if XEnd < XStart then
    Exit;
  if XEnd >= FWidth then
    XEnd := FWidth - 1;

  if XStart = XEnd then
  begin
    Pixel[XStart,Y] := IsBlack;
    Exit;
  end;

  Offset := Y*FLineSize;

  Start := XStart shr 5 ;
  StartBit := XStart and 31;
  if not IsBlack then
    Color := 0
  else
    Color := $FFFFFFFF;
  W := XEnd - XStart + 1;
  if StartBit = 0 then
  begin
    Count := W shr 5;
    for i := 0 to Count - 1 do
      FBuffer[Offset+Start+i] := Color;
    FinishBit := W and 31;
    if FinishBit <> 0 then
    begin
      if IsBlack then
         FBuffer[Offset+Start+Count] := FBuffer[Offset+Start+Count] or (not ($FFFFFFFF shr FinishBit))
      else
        FBuffer[Offset+Start+Count] := FBuffer[Offset+Start+Count] and ($FFFFFFFF shr FinishBit);
    end;
    Exit;
  end;
  Finish :=  XEnd shr 5;
  FinishBit := XEnd and 31;
  if Start <> Finish then
  begin
    if IsBlack then
      FBuffer[Start+Offset] := FBuffer[Start+Offset] or ($FFFFFFFF shr StartBit)
    else
      FBuffer[Start+Offset] := FBuffer[Start+Offset] and not($FFFFFFFF shr StartBit);
    for j:=  Start + 1 to Finish - 1 do
      FBuffer[j+Offset] := Color;
    if FinishBit <> 31 then
    begin
      if IsBlack then
        FBuffer[Finish+Offset] := FBuffer[Finish+Offset] or (not($FFFFFFFF shr (FinishBit+1)))
      else
        FBuffer[Finish+Offset] := FBuffer[Finish+Offset] and ($FFFFFFFF shr (FinishBit+1))
    end else
    begin
      FBuffer[Finish+Offset] := Color;
    end;
  end else
  begin
    if IsBlack then
      FBuffer[Start+Offset] := FBuffer[Start+Offset] or (($FFFFFFFF shr StartBit) and ($FFFFFFFF shl (31-FinishBit)))
    else
      FBuffer[Start+Offset] := FBuffer[Start+Offset] and ( not (($FFFFFFFF shr StartBit) and ($FFFFFFFF shl (31 - FinishBit))));
  end;
end;

function TBWImage.GetBlackPoint(var BlackPoint: TImgPoint): Boolean;
var
  i,j, off: Integer;
begin
  result := false;
  if (BlackPoint.y < 0) or (BlackPoint.y >=FHeight) then
    Exit;
  off := FLineSize * BlackPoint.y;
  for i := BlackPoint.y to FHeight - 1 do
  begin
    for j := 0 to FLineSize - 1 do
      if FBuffer[off+j] <> 0 then
      begin
        BlackPoint.y := i;
        BlackPoint.x := (j shl 5 ) + (31 - Log32(FBuffer[off+j]));
        result := true;
        Exit;
      end;
    inc(off, FLineSize);
  end;
end;
}
function TBWImage.GetBorder(StartPosition: TImgPoint): TImgBorder;
type
  TBorderDirection = (bdRight, bdBottom, bdLeft, bdTop);
var
  Direction: TBorderDirection;
  CurrentPoint:TImgPoint;

  procedure GetNext(var Point: TImgPoint;Direction: TBorderDirection);
  begin
    Case Direction of
      bdRight: Inc(Point.x);
      bdBottom: Inc(Point.y);
      bdLeft: Dec(Point.x);
      bdTop: Dec(Point.y);
    end
  end;

  procedure MakeStep(var Point: TImgPoint;var Direction: TBorderDirection);
  var
    D: TBorderDirection;
    IsBlack: Boolean;
    TmpPoint, TmpPoint2:TImgPoint;
  begin
    TmpPoint := Point;
    D := Direction;
    GetNext(TmpPoint,D);
    IsBlack := GetPixel(TmpPoint.x,TmpPoint.y);
    if IsBlack then
    begin
      if D <> bdRight then dec(D) else D := bdTop;
      TmpPoint2 := TmpPoint;
      GetNext(TmpPoint2,D);
      if GetPixel(TmpPoint2.x,TmpPoint2.y) then
      begin
        Direction := D;
        Point := TmpPoint2;
        Exit;
      end;
      Point := TmpPoint;
      Exit;
    end;
    if D <> bdTop then Inc(D) else D := bdRight;
    tmpPoint := Point;
    GetNext(TmpPoint,D);
    IsBlack := GetPixel(TmpPoint.x,TmpPoint.y);
    if IsBlack then
    begin
      Point := tmpPoint;
      Exit;
    end;
    if D <> bdTop then Inc(D) else D := bdRight;
    Direction := D;
  end;

begin
  Result.LeftTop := StartPosition;
  Result.RightBottom := StartPosition;

  CurrentPoint := StartPosition;

  Direction := bdRight;
  MakeStep(CurrentPoint,Direction);
  while (CurrentPoint.x <> StartPosition.x) or (CurrentPoint.y <> StartPosition.y) do
  begin
    if CurrentPoint.x < result.LeftTop.x then
      Result.LeftTop.x := CurrentPoint.x;
    if CurrentPoint.y < result.LeftTop.y then
      Result.LeftTop.y := CurrentPoint.y;
    if CurrentPoint.x > result.RightBottom.x then
      Result.RightBottom.x := CurrentPoint.x;
    if CurrentPoint.y > result.RightBottom.y then
      Result.RightBottom.y := CurrentPoint.y;
    MakeStep(CurrentPoint,Direction);
  end;
end;
{
function TBWImage.GetPixel(X, Y: Integer): Boolean;
var
  C, Mask: Cardinal;
begin
  if (X >= FWidth) or ( Y >= FHeight) or (X < 0) or ( Y < 0) then
  begin
    Result := False;
    Exit;
  end;
  C := FBuffer[Y * FLineSize+ X shr 5];
  Mask := 1 shl (31 - X and 31);
  Result := C and Mask > 0;
end;


procedure TBWImage.InitBlackPoint(var BlackPoint: TImgPoint);
begin
  BlackPoint.x := 0;
  BlackPoint.y := 0;
end;

procedure TBWImage.MoveAndClear(DestSymbol: TBWImage; StartPosition: TImgPoint;Border: TImgBorder);
var
  Stack: array of TImgPoint;
  StackSize:Integer;

  WrkPoint,TmpPoint: TImgPoint;
  Y, X, XLeft, XRight:Integer;
  fnd :Boolean;


  procedure StackGrow;
  var
    Delta, Capacity: Integer;
  begin
    Capacity := Length(Stack);
    if Capacity > 64 then
      Delta := Capacity shr 2
    else
      if Capacity > 8 then
        Delta := 16
      else
        Delta := 4;
    SetLength(Stack, Capacity + Delta);
  end;

  procedure Push(Point: TImgPoint);
  var
    i: Integer;
  begin
    for i := 0 to StackSize-1 do
      if (Point.x = Stack[i].x) and (Point.y = Stack[i].y) then
        Exit;
    if Length(Stack) = StackSize then
      StackGrow;
    Stack[StackSize] := Point;
    inc(StackSize);
  end;

  function Pop(var Point: TImgPoint):Boolean;
  begin
    if StackSize = 0 then
    begin
      Result := false;
      Exit
    end;
    dec(StackSize);
    Point := Stack[StackSize];
    result := true;
  end;

  procedure CheckLine(YLine:Integer);
  begin
    X := XLeft;
    while X <= XRight do
    begin
      fnd := false;
      while GetPixel(X,YLine) and (fnd or (X <= XRight)) do
      begin
        fnd := true;
        inc(x);
      end;
      if fnd then
      begin
        TmpPoint.y := YLine;
        TmpPoint.x := X - 1;
        Push(TmpPoint);
      end;
      inc(X);
    end;
  end;

  procedure GetLR;
  begin
    Dec(X);
    while GetPixel(X,Y) do Dec(x);
    XLeft := X + 1;
    X := WrkPoint.x;
    Inc(X);
    while GetPixel(X,Y) do Inc(x);
    XRight := X - 1;
  end;

begin
  StackSize := 0;
  Stack := nil;
  push(StartPosition);
  while Pop(WrkPoint) do
  begin
    X := WrkPoint.x;
    Y := WrkPoint.y;
    GetLR;
    if y-1 >= Border.LeftTop.y then
      CheckLine(Y-1);
    if y+1 <= Border.RightBottom.y then
      CheckLine(Y+1);
    DestSymbol.DrawHorLine(XLeft - Border.LeftTop.x,XRight - Border.LeftTop.x,WrkPoint.y - Border.LeftTop.y,True);
    DrawHorLine(XLeft,XRight,WrkPoint.y,False);
  end;
end;

function TBWImage.NormalizeSize(X,Y: integer;var W, H: integer): Boolean;
begin
  Result := False;
  if X >= Width then
  begin
    W := 0;
    Exit;
  end;
  if Y >= Height then
  begin
    H := 0;
    Exit;
  end;
  Result := True;
  if X + W > Width then
    W := Width - X;
  if Y + H > Height then
    H := Height - Y;
end;

function TBWImage.CheckNeighbor(X, Y, Level: integer):boolean;
var
  cnt: Integer;
  h,w: integer;
begin
  cnt := 0;
  result := true;
  for w := x-1 to x+1 do
    for h := y-1 to y+1 do
    begin
      if (w<>x) or (h<>y) then
      begin
        if Pixel[w,h] then
          inc(Cnt);
        if Cnt = Level then
          exit;
      end;
    end;
  result := false;
end;
)

procedure TBWImage.SaveToFile(FileName: String);
var
  BMP : TBitmap;
begin
  BMP := TBitmap.Create;
  try
    CopyToBitmap(BMP);
    BMP.SaveToFile(FileName);
  finally
    BMP.Free;
  end;
end;


{ TJBIG2Options }

constructor TJBIG2Options.Create;
begin
  FLossyLevel := 5;
  FSkipBlackDots := True;
  FBlackDotSize := 3;
  FSymbolExtract := icImageOnly;
//  FUseSingleDictionary := True;
end;


constructor TPDFImages.Create(PDFEngine: TPDFEngine);
begin
  FJPEGQuality := 80;
  FJBIG2Options := TJBIG2Options.Create;
  FJBIG2Dictionary := TJBig2SymbolDictionary.Create(PDFEngine,FJBIG2Options);
  inherited Create(PDFEngine);
end;

destructor TPDFImages.Destroy;
begin
  FJBIG2Dictionary.Free;
  FJBIG2Options.Free;
  inherited;
end;



end.

