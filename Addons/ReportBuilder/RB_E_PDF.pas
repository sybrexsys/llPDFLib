{**************************************************
                                                  
                   llPDFLib                       
      Version  6.3.0.1377,   14.03.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

//{$DEFINE RB603}
//{$DEFINE RB70}
{$define RB90}
//{$Define ppRichView}

{$ifdef RB90}
{$define RB70}
{$endif}

{$ifdef RB70}
{$undef RB603}
{$endif}

{$ifdef RB603}
{$undef RB70}
{$undef RB90}
{$endif}


unit RB_E_PDF;

interface
uses
  Classes, Windows, Graphics, llPDFDocument, llPDFTypes, SysUtils, ExtCtrls, ppPlainText,
  ppDevice, ppFilDev, ppTypes, ppUtils, ppPrintr, ppForms, ppDrwCmd,
  {$ifdef RB90}ppRichtxDrwCmd, ppBarCodDrwCmd,{$endif}
  Dialogs, RichEdit, ComCtrls, Forms {$IFDEF ppRichView}, ppRichView{$EndIf};

type

  TllPDFDevice = class(TppFileDevice)
  private
    FPDF: TPDFDocument;
    CurPage: Integer;
    Page: TppPage;
    procedure CalcDrawPosition(aDrawCommand: TppDrawCommand);
    function GetCanvas: TCanvas;
    function CU(Value: Integer): Integer;
  protected
    {$IFDEF ppRichView}
    procedure DrawRichView(aDrawRV:TppDrawRichView);
    {$ENDIF}
    procedure DirectDrawImage(aDrawImage: TppDrawImage);
    procedure DrawImage(aDrawImage: TppDrawImage);
    procedure DrawLine(aDrawLine: TppDrawLine);
    procedure DrawShape(aDrawShape: TppDrawShape);
    procedure DrawText(aDrawText: TppDrawText);
    procedure DrawRTF(aDrawRTF: TppDrawRichText);
    procedure DrawBarcode(aDrawBarcode: TppDrawBarCode);
    procedure DrawBMP(aDrawImage: TppDrawImage);
    procedure DrawGraphic(aDrawImage: TppDrawImage);
    procedure DrawItems;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure EndJob; override;
    procedure StartJob; override;
    procedure ReceivePage(aPage: TppPage); override;
    property Canvas: TCanvas read GetCanvas;
    class function DeviceName: string; override;
    class function DefaultExt: string; override;
    class function DefaultExtFilter: string; override;
    class function DeviceDescription(aLanguageIndex: Longint): string; override;
  end;


implementation

procedure llDrawDIBitmap(aCanvas: TCanvas; const aRect: TRect; aBitmap: TBitmap; aCopyMode: TCopyMode);
var
  lpBitMapInfo: PBitmapInfo;
  lpImage: Pointer;
  liInfoSize: Integer;
  lSavePalette: HPalette;
  lbRestorePalette: Boolean;
  liImageSize: DWord;
  lbHalftone: Boolean;
  lPoint: TPoint;
  lBitmapDescription: Windows.TBitmap;
  lbMonochrome: Boolean;
  liBitmapBPP, liDeviceBPP: Integer;
  lHBitmap: HBITMAP;
  mb:TBitmap;
begin
  mb:=TBitmap.Create;
  try
    mb.Assign(aBitmap);
    lHBitmap := mb.Handle;
    lSavePalette := 0;
    lbRestorePalette := False;
    if aBitmap.Palette <> 0 then
      begin
        lSavePalette := SelectPalette(aCanvas.Handle, aBitmap.Palette, False);
        RealizePalette(aCanvas.Handle);
        lbRestorePalette := True;
      end
    else
      begin
        SelectPalette(aCanvas.Handle, SystemPalette16, False);
        RealizePalette(aCanvas.Handle);

      end;

    GetObject(lHBitmap, SizeOf(lBitmapDescription), @lBitmapDescription);
    liBitmapBPP := (lBitmapDescription.bmBitsPixel * lBitmapDescription.bmPlanes);
    liDeviceBPP := GetDeviceCaps(aCanvas.Handle, BITSPIXEL) * GetDeviceCaps(aCanvas.Handle, PLANES);
    lbHalftone := (liDeviceBPP <= 8) and (liDeviceBPP < liBitmapBPP);
    lbMonochrome := (liBitmapBPP = 1);
    if lbHalftone then
      begin
        GetBrushOrgEx(aCanvas.Handle, lPoint);
        SetStretchBltMode(aCanvas.Handle, HALFTONE);
        SetBrushOrgEx(aCanvas.Handle, lPoint.x, lPoint.y, @lPoint);
      end
    else if not lbMonochrome then
      SetStretchBltMode(aCanvas.Handle, STRETCH_DELETESCANS);
    liInfoSize   := 0;
    liImageSize  := 0;
    ppGetDIBSizes(lHBitmap, liInfoSize, liImageSize);
    lpBitMapInfo  := AllocMem(liInfoSize);
    lpImage       := AllocMem(liImageSize);
    ppGetDIB(lHBitmap, aBitmap.Palette, lpBitMapInfo^, lpImage^);
    StretchDIBits(aCanvas.Handle,
                  aRect.Left, aRect.Top, aRect.Right - aRect.Left, aRect.Bottom - aRect.Top,
                  0, 0, lpBitMapInfo^.bmiHeader.biWidth, lpBitMapInfo^.bmiHeader.biHeight,
                  lpImage, lpBitMapInfo^, DIB_RGB_COLORS, aCopyMode);

    FreeMem(lpBitmapInfo, liInfoSize);
    FreeMem(lpImage, liImageSize);
    if lbRestorePalette then
      SelectPalette(aCanvas.Handle, lSavePalette, False);
  finally
   mb.Free;
  end;
end;


{ TllPDFDevice }

constructor TllPDFDevice.Create(aOwner: TComponent);
var
  DC: HDC;
begin
  inherited Create(aOwner);
  FPDF := TPDFDocument.Create(nil);
  FPDF.Compression := ctFlate;
  FPDF.OnePass := True;
  DC := GetDC(0);
  FPDF.EMFOptions.ColorImagesAsJPEG:=True;
  FPDF.Resolution := GetDeviceCaps(dc, LOGPIXELSX);
  ReleaseDC(0, DC);
end;

class function TllPDFDevice.DefaultExt: string;
begin
  Result := 'PDF';
end;

class function TllPDFDevice.DefaultExtFilter: string;
begin
  Result := 'Adobe Acrobat PDF files|*.PDF|All files|*.*';
end;

destructor TllPDFDevice.Destroy;
begin
  FPDF.Free;
  inherited;
end;

class function TllPDFDevice.DeviceDescription(aLanguageIndex: Integer): string;
begin
  Result := 'Adobe Acrobat PDF File';
end;

class function TllPDFDevice.DeviceName: string;
begin
  Result := 'PDFFile';
end;

procedure TllPDFDevice.EndJob;
begin
  try
    FPDF.EndDoc;
  except
    on exception do
    begin
      FPDF.Abort;
      raise;
    end;
  end;
  inherited;
end;

procedure TllPDFDevice.ReceivePage(aPage: TppPage);
begin
  inherited;
  if IsRequestedPage then
  begin
    DisplayMessage(aPage);
    if not IsMessagePage then
    begin
      Inc(CurPage);
      Page := aPage;
      if CurPage <> 0 then FPDF.NewPage;
      FPDF.EMFOptions.CanvasOver := False;
      FPDF.CurrentPage.Width := ppToScreenPixels(Page.PageDef.mmWidth, utMMThousandths, pprtHorizontal, nil);
      FPDF.CurrentPage.Height := ppToScreenPixels(Page.PageDef.mmHeight, utMMThousandths, pprtHorizontal, nil);
      DrawItems;
    end;
  end;
end;

procedure TllPDFDevice.StartJob;
begin
  inherited;
  FPDF.Compression := ctFlate;
  if FPDF.Printing then FPDF.Abort;
  FPDF.OnePass := True;
  FPDF.OutputStream := FileStream;
  FPDF.BeginDoc;
  CurPage := -1;
end;

procedure TllPDFDevice.CalcDrawPosition(aDrawCommand: TppDrawCommand);
begin
  aDrawCommand.DrawLeft := CU(aDrawCommand.Left);
  aDrawCommand.DrawTop := CU(aDrawCommand.Top);
  aDrawCommand.DrawRight := CU(aDrawCommand.Left + aDrawCommand.Width);
  aDrawCommand.DrawBottom := CU(aDrawCommand.Top + aDrawCommand.Height);
end;


procedure TllPDFDevice.DrawItems;
var
  i: Integer;
  aDrawCommand: TppDrawCommand;
begin
  for i := 0 to Page.DrawCommandCount - 1 do
  begin
    aDrawCommand := Page.DrawCommands[i];
    CalcDrawPosition(aDrawCommand);
    if (aDrawCommand is TppDrawText) then DrawText(TppDrawText(aDrawCommand))
    else if (aDrawCommand is TppDrawCalc) then DrawText(TppDrawText(aDrawCommand))
    else if (aDrawCommand is TppDrawShape) then DrawShape(TppDrawShape(aDrawCommand))
    else if (aDrawCommand is TppDrawLine) then DrawLine(TppDrawLine(aDrawCommand))
    else if (aDrawCommand is TppDrawImage) then DrawImage(TppDrawImage(aDrawCommand))
    else if (aDrawCommand is TppDrawRichText) then DrawRTF(TppDrawRichText(aDrawCommand))
    else if (aDrawCommand is TppDrawBarCode) then DrawBarcode(TppDrawBarCode(aDrawCommand))
{$IFDEF ppRichView}
    else if (aDrawCommand is TppDrawRichView) then DrawRichView(TppDrawRichView(aDrawCommand))
{$ENDIF}
    ;
  end;
end;

procedure TllPDFDevice.DrawLine(aDrawLine: TppDrawLine);
var
  PenWidth: Integer;
  Size: Integer;
  Offset: Integer;
  Lines: Integer;
  Line: Integer;
  Position: Integer;
begin
  PenWidth := Round((aDrawLine.Weight * Screen.PixelsPerInch / 72));
  if (PenWidth = 0) then Size := 1 else Size := PenWidth;
  if aDrawLine.LineStyle = lsSingle then Lines := 1 else Lines := 2;
  if aDrawLine.LinePosition = lpBottom then aDrawLine.DrawBottom := aDrawLine.DrawBottom - 1;
  if aDrawLine.LinePosition = lpRight then aDrawLine.DrawRight := aDrawLine.DrawRight - 1;
  Canvas.Brush.Style := bsCross;
  Canvas.Pen := aDrawLine.Pen;
  Canvas.Pen.Width := 1;
  for Line := 1 to Lines do
  begin
    if Line = 1 then Offset := 0 else Offset := Size * 2;
    for Position := 0 to Size - 1 do
      case aDrawLine.LinePosition of
        lpTop:
          begin
            Canvas.MoveTo(aDrawLine.DrawLeft, aDrawLine.DrawTop + Offset + Position);
            Canvas.LineTo(aDrawLine.DrawRight, aDrawLine.DrawTop + Offset + Position);
          end;
        lpBottom:
          begin
            Canvas.MoveTo(aDrawLine.DrawLeft, aDrawLine.DrawBottom - Offset - Position);
            Canvas.LineTo(aDrawLine.DrawRight, aDrawLine.DrawBottom - Offset - Position);
          end;
        lpLeft:
          begin
            Canvas.MoveTo(aDrawLine.DrawLeft + Offset + Position, aDrawLine.DrawTop);
            Canvas.LineTo(aDrawLine.DrawLeft + Offset + Position, aDrawLine.DrawBottom);
          end;
        lpRight:
          begin
            Canvas.MoveTo(aDrawLine.DrawRight - Offset - Position, aDrawLine.DrawTop);
            Canvas.LineTo(aDrawLine.DrawRight - Offset - Position, aDrawLine.DrawBottom);
          end;
      end;
  end;
end;

procedure TllPDFDevice.DrawShape(aDrawShape: TppDrawShape);
begin
  Canvas.Pen := aDrawShape.Pen;
  Canvas.Brush := aDrawShape.Brush;
  Canvas.Pen.Width := aDrawShape.Pen.Width;
  case aDrawShape.ShapeType of
    stRectangle:
      Canvas.Rectangle(aDrawShape.DrawLeft, aDrawShape.DrawTop, aDrawShape.DrawRight, aDrawShape.DrawBottom);
    stEllipse:
      Canvas.Ellipse(aDrawShape.DrawLeft, aDrawShape.DrawTop, aDrawShape.DrawRight, aDrawShape.DrawBottom);
    stRoundRect:
      begin
        Canvas.RoundRect(aDrawShape.DrawLeft, aDrawShape.DrawTop, aDrawShape.DrawRight,
          aDrawShape.DrawBottom, CU(aDrawShape.XCornerRound), CU(aDrawShape.YCornerRound));
      end;
  end;
end;

procedure TllPDFDevice.DrawImage(aDrawImage: TppDrawImage);
begin
  if (aDrawImage = nil) or (aDrawImage.Picture = nil) or
    (aDrawImage.Picture.Graphic = nil) or (aDrawImage.Picture.Graphic.Empty) then Exit;
  if aDrawImage.Picture.Graphic is TBitmap then
    if aDrawImage.AsBitmap.Monochrome and aDrawImage.DirectDraw then DirectDrawImage(aDrawImage) else DrawBMP(aDrawImage)
  else if aDrawImage.DirectDraw then DirectDrawImage(aDrawImage)
  else if (aDrawImage.AsBitmap <> nil) then DrawBMP(aDrawImage)
  else DrawGraphic(aDrawImage);

end;

procedure TllPDFDevice.DirectDrawImage(aDrawImage: TppDrawImage);
var
  SaveClipRgn: HRGN;
  NewClipRgn: HRGN;
  DrawRect: TRect;
  ImageWidth: Integer;
  ImageHeight: Integer;
  ControlWidth: Integer;
  ControlHeight: Integer;
  Scale: Single;
  ScaledWidth: Integer;
  ScaledHeight: Integer;
begin
  DrawRect := aDrawImage.DrawRect;
  ImageWidth := aDrawImage.Picture.Graphic.Width;
  ImageHeight := aDrawImage.Picture.Graphic.Height;
  if aDrawImage.Stretch then
  begin
    if aDrawImage.MaintainAspectRatio then
    begin
      ControlWidth := DrawRect.Right - DrawRect.Left;
      ControlHeight := DrawRect.Bottom - DrawRect.Top;
      Scale := ppCalcAspectRatio(ImageWidth, ImageHeight, ControlWidth, ControlHeight);
      ScaledWidth := Trunc(ImageWidth * Scale);
      ScaledHeight := Trunc(ImageHeight * Scale);
      if aDrawImage.Center then
      begin
        DrawRect.Left := DrawRect.Left + (ControlWidth - ScaledWidth) div 2;
        DrawRect.Top := DrawRect.Top + (ControlHeight - ScaledHeight) div 2;
      end;
      DrawRect.Right := DrawRect.Left + ScaledWidth;
      DrawRect.Bottom := DrawRect.Top + ScaledHeight;
    end;
    Canvas.StretchDraw(DrawRect, aDrawImage.Picture.Graphic);
  end
  else
  begin
    SaveClipRgn := 0;
    GetClipRgn(Canvas.Handle, SaveClipRgn);
    NewClipRgn := CreateRectRgnIndirect(aDrawImage.DrawRect);
    SelectClipRgn(Canvas.Handle, NewClipRgn);
    ControlWidth := CU(aDrawImage.Width);
    ControlHeight := CU(aDrawImage.Height);
    if aDrawImage.Center then
    begin
      DrawRect.Left := DrawRect.Left + ((ControlWidth - ImageWidth) div 2);
      DrawRect.Top := DrawRect.Top + ((ControlHeight - ImageHeight) div 2);
    end;
    DrawRect.Right := DrawRect.Left + ImageWidth;
    DrawRect.Bottom := DrawRect.Top + ImageHeight;
    Canvas.StretchDraw(DrawRect, aDrawImage.Picture.Graphic);
    SelectClipRgn(Canvas.Handle, SaveClipRgn);
    DeleteObject(NewClipRgn);
  end
end;

procedure TllPDFDevice.DrawText(aDrawText: TppDrawText);
var
  LineHeight: Integer;
  CalcHeight: Integer;
  LinesFit: Boolean;
  LineSpaceUsed: Integer;
  Lines: Integer;
  Line: Integer;
  DrawRect: TRect;
  ARect: TRect;
  CalcRect: TRect;
  WidthAvailable: Integer;
  TextWidth: Integer;
  SourceText: TStringList;
  SLine: string;
  Start: Integer;
  Leading: Integer;
  LineBuf: PChar;
  TextMetric: TTextMetric;
  TruncTheText: Boolean;
  RectHeight: Longint;
  ACalcHeight: Longint;
  TabStopCount: Integer;
  TabStop: Integer;
  TabStopArray: TppTabStopPos;
  ATop: Integer;
  MaxWidth: Integer;
  APos: Integer;
  FullJustification: Boolean;

begin
  TabStopCount := aDrawText.TabStopPositions.Count;
  if aDrawText.IsMemo and (aDrawText.TabStopPositions.Count > 0) then
  begin
    TppPlainText.ConvertTabStopPos(utScreenPixels, aDrawText.TabStopPositions, TabStopArray, TabStopCount, nil);
    for TabStop := 0 to TabStopCount - 1 do
      TabStopArray[TabStop] := TabStopArray[TabStop];
  end;
  if (Canvas.Font.CharSet <> aDrawText.Font.CharSet) or (Canvas.Font.Color <> aDrawText.Font.Color) or
    (Canvas.Font.Pitch <> aDrawText.Font.Pitch) or (Canvas.Font.Size <> aDrawText.Font.Size) or
    (Canvas.Font.Style <> aDrawText.Font.Style) or (Canvas.Font.Name <> aDrawText.Font.Name) then Canvas.Font := aDrawText.Font;
  Canvas.Font.Height := aDrawText.Font.Height;
  TruncTheText := False;
  if (Canvas.Font.Height = 0) then Canvas.Font.Height := -1;
  GetTextMetrics(Canvas.Handle, TextMetric);
  if not (aDrawText.IsMemo) then Leading := TextMetric.tmExternalLeading
  else Leading := Trunc(ppFromMMThousandths(aDrawText.Leading, utScreenPixels, pprtVertical, nil));
  LineHeight := TextMetric.tmHeight + Leading;
  DrawRect := Rect(aDrawText.DrawLeft, aDrawText.DrawTop, aDrawText.DrawRight, aDrawText.DrawBottom);
  if aDrawText.AutoSize and not (aDrawText.WordWrap) and (Length(aDrawText.Text) > 0) then
  begin
    RectHeight := DrawRect.Bottom - DrawRect.Top;
    CalcHeight := LineHeight;
    if (CalcHeight > RectHeight) then DrawRect.Bottom := DrawRect.Top + CalcHeight;
  end;
  LinesFit := True;
  Line := 0;
  Lines := aDrawText.WrappedText.Count - 1;
  WidthAvailable := (DrawRect.Right - DrawRect.Left);
  if (aDrawText.IsMemo) and (aDrawText.WrappedText.Count > 1) then
  begin
    while (Line <= Lines) do
    begin
      sLine := aDrawText.WrappedText[Line];
      APos := Pos(TppTextMarkups.EOP, sLine);
      if (APos <> 0) then SLine := TppPlainText.StringStrip(SLine, TppTextMarkups.EOP);
      TextWidth := TppPlainText.GetTabbedTextWidth(Canvas, SLine, TabStopCount, TabStopArray);
      if (APos <> 0) then sLine := sLine + TppTextMarkups.EOP;
      if (TextWidth > WidthAvailable) and (Abs(Canvas.Font.Height) > 1) then
      begin
        if (Canvas.Font.Height > 0) then Canvas.Font.Height := Canvas.Font.Height - 1
        else Canvas.Font.Height := Canvas.Font.Height + 1;
        if (Abs(Canvas.Font.Height) > 1) then Inc(Line) else Line := Lines + 1;
      end else Inc(Line);
    end;
    GetTextMetrics(Canvas.Handle, TextMetric);
    if not (aDrawText.IsMemo) then Leading := TextMetric.tmExternalLeading
    else Leading := Trunc(ppFromMMThousandths(aDrawText.Leading, utScreenPixels, pprtVertical, nil));
    LineHeight := TextMetric.tmHeight + Leading;
    CalcHeight := Round((DrawRect.Bottom - DrawRect.Top) / aDrawText.WrappedText.Count);
    if ((Abs(CalcHeight - LineHeight) / LineHeight) <= 0.10) then LineHeight := CalcHeight
    else
    begin
      LinesFit := LineHeight <= Trunc((DrawRect.Bottom - DrawRect.Top) / aDrawText.WrappedText.Count);
      while not (LinesFit) and (Abs(Canvas.Font.Height) > 1) do
      begin
        if Leading > 0 then Dec(Leading)
        else
        begin
          if Canvas.Font.Height > 0 then Canvas.Font.Height := Canvas.Font.Height - 1 else Canvas.Font.Height := Canvas.Font.Height + 1;
          GetTextMetrics(Canvas.Handle, TextMetric);
        end;
        LineHeight := TextMetric.tmHeight + Leading;
        LinesFit := LineHeight <= Trunc((DrawRect.Bottom - DrawRect.Top) / aDrawText.WrappedText.Count);
      end;
    end;
  end;
  if not (LinesFit) then Lines := Trunc((DrawRect.Bottom - DrawRect.Top) / LineHeight);
  if Abs(Canvas.Font.Height) < 1 then
  begin
    if Canvas.Font.Height > 0 then Canvas.Font.Height := 1 else Canvas.Font.Height := -1;
    TruncTheText := True;
  end;
  SourceText := TStringList.Create;
  if aDrawText.WordWrap then SourceText.Assign(aDrawText.WrappedText)
  else if (Length(aDrawText.Text) > 0) then
  begin
    SourceText.Add(aDrawText.Text);
    Lines := 0;
  end;
  CalcRect := DrawRect;
  if aDrawText.AutoSize then
  begin
    MaxWidth := 0;
    for Line := 0 to Lines do
    begin
      sLine := SourceText[Line];
      APos := Pos(TppTextMarkups.EOP, sLine);
      if (APos <> 0) then sLine := TppPlainText.StringStrip(sLine, TppTextMarkups.EOP);
      TextWidth := TppPlainText.GetTabbedTextWidth(Canvas, sLine, TabStopCount, TabStopArray);
      if (APos <> 0) then sLine := sLine + TppTextMarkups.EOP;
      if TextWidth > MaxWidth then MaxWidth := TextWidth;
    end;
    WidthAvailable := (CalcRect.Right - CalcRect.Left);
    if (MaxWidth <> WidthAvailable) then
    begin
      if aDrawText.Alignment = taLeftJustify then CalcRect.Right := CalcRect.Left + MaxWidth
      else if aDrawText.Alignment = taRightJustify then CalcRect.Left := CalcRect.Right - MaxWidth
      else if aDrawText.Alignment = taCenter then
      begin
        CalcRect.Left := CalcRect.Left + Round((WidthAvailable - MaxWidth) / 2);
        CalcRect.Right := CalcRect.Left + MaxWidth;
      end;
    end;
  end;
  if not (aDrawText.Transparent) then
  begin
    Canvas.Brush.Color := aDrawText.Color;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(CalcRect);
  end;
  Canvas.Brush.Style := bsClear;
  LineSpaceUsed := 0;
  FullJustification := False;
  for Line := 0 to Lines do
  begin
    SLine := SourceText[Line];
    WidthAvailable := (CalcRect.Right - CalcRect.Left);
    ARect := CalcRect;
    ARect.Top := ARect.Top + LineSpaceUsed;
    ATop := ARect.Top;
    if (aDrawText.TextAlignment = taFullJustified) then
    begin
      Start := ARect.Left;
      if aDrawText.ForceJustifyLastLine or (Pos(TppTextMarkups.EOP, SLine) = 0) then
      begin
        if (Pos(TppTextMarkups.EOP, sLine) <> 0) and (Pos(TppTextMarkups.Space, Trim(sLine)) = 0) then
        begin
          FullJustification := False;
          SetTextJustification(Canvas.Handle, 0, 0);
          sLine := TppPlainText.StringStrip(sLine, TppTextMarkups.EOP);
        end
        else
        begin
          FullJustification := True;
          TppPlainText.SetCanvasToJustify(Canvas, ARect, sLine, TabStopCount, TabStopArray);
          sLine := TppPlainText.StringStrip(sLine, TppTextMarkups.EOP);
        end;
      end
      else
      begin
        sLine := TppPlainText.StringStrip(sLine, TppTextMarkups.EOP);
        SetTextJustification(Canvas.Handle, 0, 0);
      end;
    end
    else
    begin
      TextWidth := TppPlainText.GetTabbedTextWidth(Canvas, sLine, TabStopCount, TabStopArray);
      if aDrawText.TextAlignment = taLeftJustified then Start := ARect.Left
      else if aDrawText.TextAlignment = taRightJustified then Start := ARect.Right - TextWidth
      else if aDrawText.TextAlignment = taCentered then Start := ARect.Left + Round(((WidthAvailable - TextWidth) / 2) - 0.5)
      else Start := 0;
    end;
    if aDrawText.IsMemo and not (TruncTheText) then
    begin
      LineBuf := StrAlloc(Length(SLine) + 1);
      StrPCopy(LineBuf, sLine);
      TabbedTextOut(Canvas.Handle, Start, ATop, LineBuf, StrLen(LineBuf), TabStopCount, TabStopArray, Start);
      StrDispose(LineBuf);
    end
    else
    begin
      if aDrawText.AutoSize and not (aDrawText.IsMemo) then Canvas.TextOut(Start, ATop, sLine)
      else Canvas.TextRect(ARect, Start, ATop, sLine);
    end;
    Inc(LineSpaceUsed, LineHeight);
  end;
  if (FullJustification) then SetTextJustification(Canvas.Handle, 0, 0);
  SourceText.Free;
  if aDrawText.AutoSize then
  begin
    aDrawText.DrawLeft := CalcRect.Left;
    aDrawText.DrawRight := CalcRect.Right;
    aDrawText.DrawBottom := aDrawText.DrawTop + LineSpaceUsed;
  end;
end;

procedure TllPDFDevice.DrawRTF(aDrawRTF: TppDrawRichText);
var
  rr: TCustomRichEdit;
  CR: TCharRange;
  IPD: Single;
  l, t, w, h: Integer;
  ControlWidth, ControlHeight: Integer;
  MF: TMetafile;
  MFC: TMetafileCanvas;
  lPrinter: TppPrinter;
  DC: HDC;
  CanvasRect: TRect;
begin
{$IFDEF RB603}
  IPD := 25400 / Screen.PixelsPerInch;
  L := round(aDrawRTF.Left / IPD);
  T := Round(aDrawRTF.Top / IPD);
  W := Round(aDrawRTF.Width / IPD);
  H := Round(aDrawRTF.Height / IPD);
  rr := ppGetRichEditClass.Create(nil);
  rr.Parent := ppParentWnd;
  CR.cpMin := aDrawRTF.StartCharPos;
  CR.cpMax := aDrawRTF.EndCharPos;
  aDrawRTF.RichTextStream.Position := 0;
  rr.Lines.LoadFromStream(aDrawRTF.RichTextStream);
  lPrinter := ppPrinter;
  if lPrinter <> nil then lPrinter.PrinterSetup := Page.PrinterSetup;
  if (lPrinter <> nil) and (lPrinter.DC <> 0) then
    DC := lPrinter.DC else DC := GetDC(0);
  try
    ControlWidth := Trunc(ppFromMMThousandths(aDrawRTF.Width, utPrinterPixels, pprtHorizontal, lPrinter));
    ControlHeight := Trunc(ppFromMMThousandths(aDrawRTF.Height, utPrinterPixels, pprtVertical, lPrinter));
    MF := TMetafile.Create;
    try
      MF.Width := ControlWidth;
      MF.Height := ControlHeight;
      CanvasRect := Rect(0, 0, ControlWidth, ControlHeight);
      MFC := TMetaFileCanvas.Create(MF, DC);
      try
       ppGetRTFEngine(rr).DrawRichText(MFC.Handle, DC, CanvasRect, CR);
      finally
        MFC.Free;
      end;
      FPDF.Canvas.StretchDraw(Rect(l, t, l + w, t + h), MF);
    finally
      MF.Free;
    end;
  finally
    if (lPrinter = nil) or (lPrinter.DC = 0) then ReleaseDC(0, DC);
  end;
{$ENDIF}
{$IFDEF RB70}
  IPD := 25400 / Screen.PixelsPerInch;
  L := round(aDrawRTF.Left / IPD);
  T := Round(aDrawRTF.Top / IPD);
  W := Round(aDrawRTF.Width / IPD);
  H := Round(aDrawRTF.Height / IPD);
  lPrinter := ppPrinter;
  if lPrinter <> nil then lPrinter.PrinterSetup := Page.PrinterSetup;
  if (lPrinter <> nil) and (lPrinter.DC <> 0) then DC := lPrinter.DC else DC := GetDC(0);
  ControlWidth := Trunc(ppFromMMThousandths(aDrawRTF.Width, utPrinterPixels, pprtHorizontal, lPrinter));
  ControlHeight := Trunc(ppFromMMThousandths(aDrawRTF.Height, utPrinterPixels, pprtVertical, lPrinter));
  MF := TMetaFile.Create;
  try
    MF.Width := ControlWidth;
    MF.Height := ControlHeight;
    CanvasRect := Rect(0, 0, ControlWidth, ControlHeight);

    MFC := TMetaFileCanvas.Create(MF, DC);
    try
      rr := ppGetRichEditClass.Create(nil);
      try
        rr.Lines.LoadFromStream(aDrawRTF.RichTextStream);
        aDrawRTF.RichTextStream.Position := 0;
        ppGetRichEditLines(RR).LoadFromStream(aDrawRTF.RichTextStream);
        CR.cpMin := aDrawRTF.StartCharPos;
        CR.cpMax := aDrawRTF.EndCharPos;
        TppRTFEngine.DrawRichText(RR, MFC.Handle, DC, CanvasRect, CR);
      finally
        rr.Free;
      end;
    finally
      MFC.Free;
    end;
    Canvas.StretchDraw(Rect(l, t, l + w, t + h), MF);
  finally
    MF.Free;
  end;
  if (lPrinter = nil) or (lPrinter.DC = 0) then ReleaseDC(0, DC);
{$ENDIF}
end;

procedure TllPDFDevice.DrawBarcode(aDrawBarcode: TppDrawBarCode);
begin
  aDrawBarcode.CalcBarCodeSize(FPDF.Canvas);
  FPDF.Canvas.Pen.Color := clBlack;
  aDrawBarcode.DrawBarCode(FPDF.Canvas, aDrawBarcode.DrawLeft, aDrawBarcode.DrawTop,
    Point(FPDF.Resolution, FPDF.Resolution), True);
end;

function TllPDFDevice.GetCanvas: TCanvas;
begin
  Result := FPDF.Canvas;
end;

function TllPDFDevice.CU(Value: Integer): Integer;
begin
  result := Round(((Value / 1000) * 0.03937) * Screen.PixelsPerInch);
end;

procedure TllPDFDevice.DrawBMP(aDrawImage: TppDrawImage);
var
  SaveClipRgn: HRGN;
  NewClipRgn: HRGN;
  DrawRect: TRect;
  ImageWidth: Integer;
  ImageHeight: Integer;
  ControlWidth: Integer;
  ControlHeight: Integer;
  Scale: Single;
  ScaledWidth: Integer;
  ScaledHeight: Integer;
begin
  DrawRect := aDrawImage.DrawRect;
  ControlWidth := DrawRect.Right - DrawRect.Left;
  ControlHeight := DrawRect.Bottom - DrawRect.Top;
  ImageWidth := aDrawImage.Picture.Graphic.Width;
  ImageHeight := aDrawImage.Picture.Graphic.Height;
  if aDrawImage.Stretch then
  begin
    if aDrawImage.MaintainAspectRatio then
    begin
      Scale := ppCalcAspectRatio(ImageWidth, ImageHeight, ControlWidth, ControlHeight);
      ScaledWidth := Trunc(ImageWidth * Scale);
      ScaledHeight := Trunc(ImageHeight * Scale);
      if aDrawImage.Center then
      begin
        DrawRect.Left := DrawRect.Left + ((ControlWidth - ScaledWidth) div 2);
        DrawRect.Top := DrawRect.Top + ((ControlHeight - ScaledHeight) div 2);
      end;
      DrawRect.Right := DrawRect.Left + ScaledWidth;
      DrawRect.Bottom := DrawRect.Top + ScaledHeight;
    end;
    llDrawDIBitmap(Canvas, DrawRect, aDrawImage.AsBitmap, cmSrcCopy);
  end
  else
  begin
    SaveClipRgn := 0;
    GetClipRgn(Canvas.Handle, SaveClipRgn);
    NewClipRgn := CreateRectRgnIndirect(aDrawImage.DrawRect);
    SelectClipRgn(Canvas.Handle, NewClipRgn);
    if aDrawImage.Center then
    begin
      DrawRect.Left := DrawRect.Left + ((ControlWidth - ImageWidth) div 2);
      DrawRect.Top := DrawRect.Top + ((ControlHeight - ImageHeight) div 2);
    end;
    DrawRect.Right := DrawRect.Left + ImageWidth;
    DrawRect.Bottom := DrawRect.Top + ImageHeight;
    llDrawDIBitmap(Canvas, DrawRect, aDrawImage.AsBitmap, cmSrcCopy);
    SelectClipRgn(Canvas.Handle, SaveClipRgn);
    DeleteObject(NewClipRgn);
  end;
end;

procedure TllPDFDevice.DrawGraphic(aDrawImage: TppDrawImage);
var
  ClipRect: TRect;
  MemCanvas: TppDeviceCompatibleCanvas;
  PictureWidth, PictureHeight: Longint;
  DrawWidth, DrawHeight: Longint;
  Scale: Single;
  ScaledWidth: Integer;
  ScaledHeight: Integer;
begin
  PictureWidth := aDrawImage.Picture.Width;
  PictureHeight := aDrawImage.Picture.Height;
  DrawWidth := aDrawImage.DrawRight - aDrawImage.DrawLeft;
  DrawHeight := aDrawImage.DrawBottom - aDrawImage.DrawTop;
  if aDrawImage.Stretch and aDrawImage.MaintainAspectRatio then
  begin
    ClipRect := Rect(0, 0, DrawWidth, DrawHeight);
    Scale := ppCalcAspectRatio(PictureWidth, PictureHeight, DrawWidth, DrawHeight);
    ScaledWidth := Trunc(PictureWidth * Scale);
    ScaledHeight := Trunc(PictureHeight * Scale);
    if aDrawImage.Center then
    begin
      ClipRect.Left := ClipRect.Left + ((DrawWidth - ScaledWidth) div 2);
      ClipRect.Top := ClipRect.Top + ((DrawHeight - ScaledHeight) div 2);
    end;
    ClipRect.Right := ClipRect.Left + ScaledWidth;
    ClipRect.Bottom := ClipRect.Top + ScaledHeight;
  end
  else if aDrawImage.Stretch then ClipRect := Rect(0, 0, DrawWidth, DrawHeight)
  else if aDrawImage.Center then ClipRect := Bounds((DrawWidth - PictureWidth) div 2, (DrawHeight - PictureHeight) div 2,
      PictureWidth, PictureHeight) else ClipRect := Rect(0, 0, PictureWidth, PictureHeight);
  MemCanvas := TppDeviceCompatibleCanvas.Create(Canvas.Handle, DrawWidth, DrawHeight, aDrawImage.Picture.Graphic.Palette);
  if (aDrawImage.Picture.Graphic is TBitmap) then llDrawDIBitmap(MemCanvas, ClipRect, aDrawImage.Picture.Bitmap, cmSrcCopy)
  else MemCanvas.StretchDraw(ClipRect, aDrawImage.Picture.Graphic);
   MemCanvas.RenderToDevice(aDrawImage.DrawRect, aDrawImage.Picture.Graphic.Palette, cmSrcCopy);
  MemCanvas.Free;
end;

{$IFDEF ppRichView}
procedure TllPDFDevice.DrawRichView(aDrawRV: TppDrawRichView);
begin
  aDrawRV.DrawTo(Canvas,aDrawRV.DrawRect);
end;
{$ENDIF}




initialization
  ppRegisterDevice(TllPDFDevice);
finalization
  ppUnRegisterDevice(TllPDFDevice);
end.

