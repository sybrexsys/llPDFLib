program Demo;
{$i demo.inc}

type
  cont = record
    Main: Boolean;
    Page: Integer;
    Top: Integer;
    Caption: string;
  end;
const
  contents: array[1..23] of cont =
  ((main: True; Page: 3; Top: 0; Caption: 'Graphics'),
    (main: False; Page: 4; Top: 0; Caption: 'Lines'),
    (main: False; Page: 5; Top: 0; Caption: 'Rectangle'),
    (main: False; Page: 6; Top: 0; Caption: 'Rotate Rectangle'),
    (main: False; Page: 7; Top: 0; Caption: 'Round Rectangle'),
    (main: False; Page: 8; Top: 0; Caption: 'Curves Bezier'),
    (main: False; Page: 9; Top: 0; Caption: 'Circle'),
    (main: False; Page: 10; Top: 0; Caption: 'Ellipse'),
    (main: False; Page: 11; Top: 0; Caption: 'Pie'),
    (main: True; Page: 12; Top: 0; Caption: 'Text'),
    (main: False; Page: 13; Top: 0; Caption: 'Fonts'),
    (main: False; Page: 14; Top: 0; Caption: 'Text Scalling'),
    (main: False; Page: 14; Top: 260; Caption: 'Word Spacing'),
    (main: False; Page: 14; Top: 520; Caption: 'Character Spacing'),
    (main: False; Page: 15; Top: 0; Caption: 'Text Rendering'),
    (main: False; Page: 15; Top: 260; Caption: 'Text Rotation'),
    (main: False; Page: 16; Top: 0; Caption: 'Cyrillic Charset'),
    (main: False; Page: 17; Top: 0; Caption: 'Greek Charset'),
    (main: False; Page: 18; Top: 0; Caption: 'Turkish Charset'),
    (main: False; Page: 19; Top: 0; Caption: 'Baltic Charset'),
    (main: False; Page: 20; Top: 0; Caption: 'East Europe Charset'),
    (main: True; Page: 21; Top: 0; Caption: 'Images'),
    (main: True; Page: 23; Top: 0; Caption: 'Annotations'));

var
  MyPDF: TPDFDocument;
  I, J: Integer;
  S, K: Integer;
  X, Y: Integer;
  St: string;
  O, B: TPDFOutlineNode;
  x0: Extended; y0: Extended;
  x1: Extended; y1: Extended;
  x2: Extended; y2: Extended;
  x3: Extended; y3: Extended;
  UR: TPDFURLAction;
  GTP: TPDFGoToPageAction;
  Ann: TPDFTextAnnotation;
  ST1, ST2: string;
{$ifdef unicode}
  SST: RawByteString;
{$endif}
const
  Dashes: array[1..9] of string =
  ('[2  2] 0', '[4  4] 0', '[8  8] 0', '[8  8] 4', '[8  8] 8', '[12  4] 0', '[16  3  4  3] 0', '[13  3  2  3  2  3] 0', '[ ] 0');
begin
  Randomize;
  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.FileName := 'Data\PDFFiles\MainDemo.pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [MainDemo]';
    MyPDF.Compression := ctNone;
    MyPDF.PageMode := pmUseOutlines;
    MyPDF.PageLayout := plSinglePage;
    MyPDF.AutoLaunch := True;
    MyPDF.AutoCreateURL := True;
    st := '';
    MyPDF.NonEmbeddedFonts.Add('Impact');
    MyPDF.BeginDoc;
    with MyPDF.CurrentPage do
    begin
      SetLineWidth(1);
      SetColorFill(GrayToPDFColor(0.5));
      SetColorStroke(ColorToPDFColor( clRed));
      SetTextRenderingMode(2);
      SetActiveFont('Verdana', [], 48);
      TextOut((Width - GetTextWidth('Sybrex Systems')) / 2, 100, 0, 'Sybrex Systems');
      SetActiveFont('Arial', [], 48);
      TextOut((Width - GetTextWidth('llPDFLib v 6.x')) / 2, 240, 0, 'llPDFLib v 6.x');
      SetColorStroke(ColorToPDFColor(clBlue));
      SetActiveFont('Times', [], 100);
      TextOut((Width - GetTextWidth('Demo')) / 2, 280, 0, 'Demo');
      SetColorStroke(RGBToPDFColor( 0, 0.5, 0.25));
      SetActiveFont('Courier', [], 40);
      SetHorizontalScaling(50);
      TextOut((Width - GetTextWidth('http://www.sybrex.com')) / 2, 380, 0, 'http://www.sybrex.com');
      SetHorizontalScaling(100);
      SetActiveFont('Arial', [], 12);
      SetColorStroke(RGBToPDFColor( 0, 0.5, 0.75));
      SetLineWidth(0.5);
      TextOut((Width - GetTextWidth('Copyright '#169' 2001-2015 Sybrex Systems')) / 2,
        440, 0, 'Copyright '#169' 2001-2015 Sybrex Systems');
    end;
    for I := 1 to 23 do
      MyPDF.NewPage;
    B := MyPDF.Outlines.Add(nil, 'llPDFLib Demo', TPDFGoToPageAction.Create(MyPDF.Actions,0,0,True));
    B.Expanded := True;
    O := nil;
    for I := 1 to High(Contents) do
      with MyPDF[contents[I].Page - 1] do
      begin
        SetLineWidth(1);
        if contents[I].Main then
        begin
          SetTextRenderingMode(2);
          SetColorFill(GrayToPDFColor(0.5));
          SetColorStroke(ColorToPDFColor( clRed));
          SetActiveFont('Times', [fsbold], 100);
          TextOut((Width - GetTextWidth(Contents[i].Caption)) / 2, 340, 0, Contents[i].Caption);
          SetColorStroke(ColorToPDFColor( clBlue));
          SetActiveFont('Courier', [], 40);
          TextOut((Width - GetTextWidth('Chapter')) / 2, 300, 0, 'Chapter');
          O := MyPDF.Outlines.AddChild(B, Contents[i].Caption,
            TPDFGoToPageAction.Create(MyPDF.Actions, Contents[i].Page - 1, Contents[i].Top, True));
          O.Expanded := True;
        end else
        begin
          SetActiveFont('Arial', [fsbold], 28);
          TextOut((Width - GetTextWidth(Contents[i].Caption)) / 2, Contents[i].Top + 20, 0, Contents[i].Caption);
          MyPDF.Outlines.AddChild(O, Contents[i].Caption,
            TPDFGoToPageAction.Create(MyPDF.Actions, Contents[i].Page - 1, Contents[i].Top, True));
        end;
      end;

    MyPDF.CurrentPageIndex :=1;
    with MyPDF.CurrentPage do
    begin
      SetColor(GrayToPDFColor(0));
      SetActiveFont('Arial', [fsBold], 48);
      TextOut((Width - GetTextWidth('Contents')) / 2, 10, 0, 'Contents');
      for I := 1 to High(Contents) do
      begin
        if contents[I].Main then
        begin
          SetActiveFont('Arial', [fsBold], 18);
          TextOut(100, 80 + I * 20, 0, contents[i].Caption);
        end else
        begin
          SetActiveFont('Arial', [], 18);
          TextOut(120, 80 + I * 20, 0, contents[i].Caption);
        end;
        TextOut(450, 80 + I * 20, 0, IntToStr(contents[i].Page));
        SetLinkToPage(Rect(100, 80 + I * 20, 500, 100 + I * 20), contents[I].Page - 1, contents[I].Top);
      end;
    end;


    MyPDF.CurrentPageIndex :=3;
    with MyPDF.CurrentPage do
    begin
      SetColor(GrayToPDFColor(0));
      SetLineWidth(2);
      for I := 1 to 9 do
      begin
        SetDash(dashes[i]);
        MoveTo(50, 100 + (I * 20));
        LineTo(300, 100 + (I * 20));
        Stroke;
      end;
      SetActiveFont('Arial', [fsBold], 14);
      for I := 1 to 9 do
        TextOut(350, 85 + (I * 20), 0, dashes[i]);
      for I := 1 to 15 do
        TextOut(350, 285 + (I * 20), 0, 'Line width =' + FloatToStr(I * 0.25));
      NoDash;
      for I := 1 to 15 do
      begin
        SetColorStroke(RGBToPDFColor(I / 16, I / 16, 1));
        SetLineWidth(0.25 * I);
        MoveTo(50, 300 + (I * 20));
        LineTo(300, 300 + (I * 20));
        Stroke;
      end;
    end;


    MyPDF.CurrentPageIndex :=4;
    with MyPDF.CurrentPage do
    begin
      GStateSave;
      NewPath;
      Rectangle(50, 100, Width - 50, Height - 50);
      ClosePath;
      clip;
      newpath;
      SetLineWidth(0.5);
      for I := 1 to 200 do
      begin
        SetColorFill(RGBToPDFColor(Random(256) / 256, Random(256) / 256, Random(256) / 256));
        SetColorStroke(RGBToPDFColor(Random(256) / 256, Random(256) / 256, Random(256) / 256));
        X := Random(Width - 50);
        Y := Random(Height - 50);
        S := Random(200);
        K := Random(200);
        Rectangle(X, Y, X + S, Y + K);
        FillAndStroke;
      end;
      GStateRestore;
      NewPath;
      SetLineWidth(2);
      SetColor(GrayToPDFColor(0));
      Rectangle(50, 100, Width - 50, Height - 50);
      Stroke;
    end;

    MyPDF.CurrentPageIndex :=5;
    with MyPDF.CurrentPage do
    begin
      GStateSave;
      NewPath;
      Rectangle(50, 100, Width - 50, Height - 50);
      ClosePath;
      clip;
      newpath;
      SetLineWidth(0.5);
      for I := 1 to 200 do
      begin
        SetColorFill(RGBToPDFColor( Random(256) / 256, Random(256) / 256, Random(256) / 256) );
        SetColorStroke(RGBToPDFColor( Random(256) / 256, Random(256) / 256, Random(256) / 256));
        X := Random(Width - 50);
        Y := Random(Height - 50);
        S := Random(200);
        K := Random(200);
        RectRotated(X, Y, S, K, Random(360));
        FillAndStroke;
      end;
      GStateRestore;
      NewPath;
      SetLineWidth(2);
      SetColor(GrayToPDFColor(0));
      Rectangle(50, 100, Width - 50, Height - 50);
      Stroke;
    end;

    MyPDF.CurrentPageIndex :=6;
    with MyPDF.CurrentPage do
    begin
      SetColorStroke(GrayToPDFColor(1));
      for I := 1 to 20 do
      begin
        SetColorFill(RGBToPDFColor( I / 20, I / 20, 1));
        RoundRect(50 + (I - 1) * 5, 100 + (I - 1) * 10,
          Width - 50 - (I - 1) * 5, Height - 50 - (I - 1) * 10, 50, 50);
        FillAndStroke;
      end;
    end;

    MyPDF.CurrentPageIndex :=7;
    with MyPDF.CurrentPage do
    begin
      x0 := 150; y0 := 150;
      x1 := 250; y1 := 200;
      x2 := 350; y2 := 400;
      x3 := 450; y3 := 100;

      SetColor(GrayToPDFColor(0));
      nodash;
      SetLineWidth(1.5);
      MoveTo(x0, y0);
      Curveto(x1, y1, x2, y2, x3, y3);
      stroke;
      SetDash('[2 3]0 ');
      SetLineWidth(0.3);
      moveto(x0, y0);
      lineto(x1, y1);
      moveto(x3, y3);
      lineto(x2, y2);
      stroke;
      nodash;
      setColorFill(GrayToPDFColor(0.0));
      setActiveFont('Arial', [], 12);
      textOut(x0 - 15, y0 - 25, 0.0, 'x0, y0');
      textOut(x1 - 15, y1 + 10, 0.0, 'x1, y1');
      textOut(x2 - 15, y2 - 25, 0.0, 'x2, y2');
      textOut(x3 - 15, y3 + 10, 0.0, 'x3, y3');

      y0 := 700; x0 := 100;
      y1 := 550; x1 := 50;
      y2 := 700; x2 := 500;
      y3 := 500; x3 := 450;

      SetColor(GrayToPDFColor( 0.0));
      nodash;
      SetLineWidth(1.5);
      MoveTo(x0, y0);
      Curveto(x1, y1, x2, y2, x3, y3);
      stroke;
      SetDash('[2 3]0 ');
      SetLineWidth(0.3);
      moveto(x0, y0);
      lineto(x1, y1);
      moveto(x3, y3);
      lineto(x2, y2);
      stroke;
      nodash;
      setColorFill(GrayToPDFColor(0.0));
      setActiveFont('Arial', [], 12);
      textOut(x0 - 15, y0 - 25, 0.0, 'x0, y0');
      textOut(x1 - 15, y1 + 10, 0.0, 'x1, y1');
      textOut(x2 - 15, y2 - 25, 0.0, 'x2, y2');
      textOut(x3 - 15, y3 + 10, 0.0, 'x3, y3');
    end;

    MyPDF.CurrentPageIndex :=8;
    with MyPDF.CurrentPage do
    begin
      GStateSave;
      NewPath;
      Circle(Width / 2, Height / 2, Width / 2 - 50);
      ClosePath;
      clip;
      newpath;
      SetLineWidth(0.5);
      for I := 1 to 200 do
      begin
        SetColorFill(RGBToPDFColor(Random(256) / 256, Random(256) / 256, Random(256) / 256));
        SetColorStroke(RGBToPDFColor(Random(256) / 256, Random(256) / 256, Random(256) / 256));
        X := Random(Width - 50);
        Y := Random(Height - 50);
        S := Random(75);
        Circle(X, Y, S);
        FillAndStroke;
      end;
      GStateRestore;
      NewPath;
      SetLineWidth(2);
      SetColor(GrayToPDFColor(0));
      Circle(Width / 2, Height / 2, Width / 2 - 50);
      Stroke;
    end;

    MyPDF.CurrentPageIndex :=9;
    with MyPDF.CurrentPage do
    begin
      GStateSave;
      NewPath;
      Ellipse(50, 100, Width - 50, Height - 50);
      ClosePath;
      clip;
      newpath;
      SetLineWidth(0.5);
      for I := 1 to 200 do
      begin
        SetColorFill(RGBToPDFColor( Random(256) / 256, Random(256) / 256, Random(256) / 256));
        SetColorStroke(RGBToPDFColor( Random(256) / 256, Random(256) / 256, Random(256) / 256));
        X := Random(Width - 50);
        Y := Random(Height - 50);
        S := Random(150);
        K := Random(150);
        Ellipse(X, Y, X + S + 50, Y + K + 50);
        FillAndStroke;
      end;
      GStateRestore;
      NewPath;
      SetLineWidth(2);
      SetColor(GrayToPDFColor(0));
      Ellipse(50, 100, Width - 50, Height - 50);
      Stroke;
    end;

    MyPDF.CurrentPageIndex :=10;
    with MyPDF.CurrentPage do
    begin
      SetLineWidth(1);
      SetColorStroke(GrayToPDFColor(0));
      for I := 12 downto 1 do
      begin
        SetColorFill(RGBToPDFColor(1, i / 12, i / 12));
        Pie(50 + (12 - I) * 10, Height / 2 - (Width / 2 - 50) + (12 - I) * 10,
          Width - 50 - (12 - I) * 10, Height / 2 + (Width / 2 - 50) - (12 - I) * 10, 0, I * 30);
        FillAndStroke;
      end;
    end;

    MyPDF.CurrentPageIndex :=12;
    St := '0123456789 ABDCEFGHI abcdefghi';
    with MyPDF.CurrentPage do
    begin
      SetColor(GrayToPDFColor(0));
      for I := 1 to 16 do
        Rectangle(50, 120 + (I - 1) * 40, Width - 50, 120 + I * 40);
      Stroke;
      SetActiveFont('Arial', [], 10);
      for I := 1 to 14 do
        TextOut(60, 120 + (I - 1) * 40, 0, 'Standard Font');
      TextOut(60, 120 + 14 * 40, 0, 'Embedded Font');
      TextOut(60, 120 + 15 * 40, 0, 'Nonembedded Font');
      SetActiveFont(stdfHelvetica, 20);
      TextOut(60, 130 + 0 * 40, 0, st);
      SetActiveFont(stdfHelveticaBold, 20);
      TextOut(60, 130 + 1 * 40, 0, st);
      SetActiveFont(stdfHelveticaOblique, 20);
      TextOut(60, 130 + 2 * 40, 0, st);
      SetActiveFont(stdfHelveticaBoldOblique,  20);
      TextOut(60, 130 + 3 * 40, 0, st);
      SetActiveFont(stdfTimesRoman, 20);
      TextOut(60, 130 + 4 * 40, 0, st);
      SetActiveFont(stdfTimesBold, 20);
      TextOut(60, 130 + 5 * 40, 0, st);
      SetActiveFont(stdfTimesItalic, 20);
      TextOut(60, 130 + 6 * 40, 0, st);
      SetActiveFont(stdfTimesBoldItalic, 20);
      TextOut(60, 130 + 7 * 40, 0, st);
      SetActiveFont(stdfCourier,  20);
      TextOut(60, 130 + 8 * 40, 0, st);
      SetActiveFont(stdfCourierBold, 20);
      TextOut(60, 130 + 9 * 40, 0, st);
      SetActiveFont(stdfCourierOblique, 20);
      TextOut(60, 130 + 10 * 40, 0, st);
      SetActiveFont(stdfCourierBoldOblique, 20);
      TextOut(60, 130 + 11 * 40, 0, st);
      SetActiveFont(stdfSymbol,20);
      TextOut(60, 130 + 12 * 40, 0, st);
      SetActiveFont(stdfZapfDingbats, 20);
      TextOut(60, 130 + 13 * 40, 0, st);
      SetActiveFont('Verdana', [], 20);
      TextOut(60, 130 + 14 * 40, 0, st);
      SetActiveFont('Impact', [], 20);
      TextOut(60, 130 + 15 * 40, 0, st);
    end;

    MyPDF.CurrentPageIndex :=13;
    with MyPDF.CurrentPage do
    begin
      SetColor(GrayToPDFColor(0));
      SetLineWidth(1);
      Rectangle(100, 100, 250, 175);
      Rectangle(250, 100, 500, 175);
      Rectangle(100, 175, 250, 250);
      Rectangle(250, 175, 500, 250);

      Rectangle(100, 350, 250, 425);
      Rectangle(250, 350, 500, 425);
      Rectangle(100, 425, 250, 500);
      Rectangle(250, 425, 500, 500);

      Rectangle(100, 600, 250, 675);
      Rectangle(250, 600, 500, 675);
      Rectangle(100, 675, 250, 750);
      Rectangle(250, 675, 500, 750);
      Stroke;
      SetActiveFont('Times', [], 15);
      TextBox(Rect(100, 100, 250, 175), '= 100 (Default)', hjCenter, vjCenter);
      TextBox(Rect(100, 175, 250, 250), '= 50', hjCenter, vjCenter);

      TextBox(Rect(100, 350, 250, 425), '= 0 (Default)', hjCenter, vjCenter);
      TextBox(Rect(100, 425, 250, 500), '= 15', hjCenter, vjCenter);

      TextBox(Rect(100, 600, 250, 675), '= 0 (Default)', hjCenter, vjCenter);
      TextBox(Rect(100, 675, 250, 750), '= 2.5', hjCenter, vjCenter);


      SetActiveFont('Times', [fsBold], 25);
      TextBox(Rect(250, 100, 500, 175), 'Test String', hjCenter, vjCenter);
      TextBox(Rect(250, 350, 500, 425), 'Test String', hjCenter, vjCenter);
      TextBox(Rect(250, 600, 500, 675), 'Test String', hjCenter, vjCenter);
      SetHorizontalScaling(50);
      TextBox(Rect(250, 175, 500, 250), 'Test String', hjCenter, vjCenter);
      SetHorizontalScaling(100);
      SetWordSpacing(15);
      TextBox(Rect(250, 425, 500, 500), 'Test String', hjCenter, vjCenter);
      SetWordSpacing(0);
      SetCharacterSpacing(2.5);
      TextBox(Rect(250, 675, 500, 750), 'Test String', hjCenter, vjCenter);
      SetCharacterSpacing(0);
    end;

    MyPDF.CurrentPageIndex :=14;
    with MyPDF.CurrentPage do
    begin
      SetLineWidth(1);
      SetColor(GrayToPDFColor(0));
      for I := 1 to 4 do
      begin
        Rectangle(150 + (I - 1) * 80, 100, 150 + I * 80, 175);
        Rectangle(150 + (I - 1) * 80, 175, 150 + I * 80, 250);
      end;
      Stroke;
      SetActiveFont('Arial', [], 16);
      for I := 1 to 4 do
        TextBox(Rect(150 + (I - 1) * 80, 100, 150 + I * 80, 175), 'Mode ' + IntToStr(I - 1), hjCenter, vjCenter);
      SetActiveFont('Arial', [], 10);
      TextBox(Rect(150, 175, 150 + 80, 250), '(Fill)', hjCenter, vjUp);
      TextBox(Rect(150 + 80, 175, 150 + 160, 250), '(Stroke)', hjCenter, vjUp);
      TextBox(Rect(150 + 160, 175, 150 + 240, 250), '(Fill & Stroke)', hjCenter, vjUp);
      TextBox(Rect(150 + 3 * 80, 175, 150 + 4 * 80, 250), '(Invisible)', hjCenter, vjUp);
      SetActiveFont('Arial', [], 48);
      SetColorFill(ColorToPDFColor(clRed));
      SetColorStroke(ColorToPDFColor(clBlue));
      for I := 1 to 4 do
      begin
        SetTextRenderingMode(I - 1);
        TextBox(Rect(150 + (I - 1) * 80, 175, 150 + I * 80, 250), 'R', hjCenter, vjCenter);
      end;
      SetActiveFont('Times', [fsBold], 25);
      SetTextRenderingMode(2);
      SetLineWidth(0.5);
      for I := 0 to 35 do
      begin
        SetColorFill(RGBToPDFColor( Random(256) / 256, Random(256) / 256, Random(256) / 256));
        SetColorStroke(RGBToPDFColor( Random(256) / 256, Random(256) / 256, Random(256) / 256));
        TextOut(Width / 2, 550, I * 10, '                 Rotated text');
      end;
    end;
    MyPDF.CurrentPageIndex :=15;
    with MyPDF.CurrentPage do
    begin
      SetColor(GrayToPDFColor(0));
      SetActiveFont('Times New Roman', [], 24, RUSSIAN_CHARSET);
      for I := 161 to 255 do
      begin
        TextOut(50 + (I mod 16) * 32, (I div 16 - 8) * 40, 0, chr(I));
      end;
    end;

    MyPDF.CurrentPageIndex :=16;
    with MyPDF.CurrentPage do
    begin
      SetColor(GrayToPDFColor(0));
      SetActiveFont('Verdana', [], 24, GREEK_CHARSET);
      for I := 161 to 255 do
      begin
        TextOut(50 + (I mod 16) * 32, (I div 16 - 8) * 40, 0, chr(I));
      end;
    end;

    MyPDF.CurrentPageIndex :=17;
    with MyPDF.CurrentPage do
    begin
      SetColor(GrayToPDFColor(0));
      SetActiveFont('Verdana', [], 24, TURKISH_CHARSET);
      for I := 161 to 255 do
      begin
        TextOut(50 + (I mod 16) * 32, (I div 16 - 8) * 40, 0, chr(I));
      end;
    end;

    MyPDF.CurrentPageIndex :=18;
    with MyPDF.CurrentPage do
    begin
      SetColor(GrayToPDFColor(0));
      SetActiveFont('Verdana', [], 24, BALTIC_CHARSET);
      for I := 161 to 255 do
      begin
        TextOut(50 + (I mod 16) * 32, (I div 16 - 8) * 40, 0, chr(I));
      end;
    end;

    MyPDF.CurrentPageIndex :=19;
    with MyPDF.CurrentPage do
    begin
      SetColor(GrayToPDFColor(0));
      SetActiveFont('Verdana', [], 24, EASTEUROPE_CHARSET);
      for I := 161 to 255 do
      begin
        TextOut(50 + (I mod 16) * 32, (I div 16 - 8) * 40, 0, chr(I));
      end;
    end;

    MyPDF.CurrentPageIndex := 21;
    K := MyPDF.Images.AddImage('Data\Images\logo.bmp', itcjpeg);
    with MyPDF.CurrentPage do
    begin
      ShowImage(K, (Width - 200) / 2, 30, 200, 200, 0);
      for I := 1 to 20 do
        ShowImage(K, 200 + I * 10, 400 + I * 10, (21 - I) * 10, (21 - I) * 10, I * 10);
    end;

{$ifdef unicode}
    SSt := '';
    for I := 128 to 255 do SSt := SSt + ANSIChar(I);
{$else}
    St := '';
    for I := 128 to 255 do St := St + chr(I);
{$endif}

    MyPDF.CurrentPageIndex :=23;

    Ann := TPDFTextAnnotation.Create(MyPDF.CurrentPage, Rect(0, 0, MyPDF.CurrentPage.Width, 200));
    Ann.Caption:='Open Annatation';
    Ann.Text := 'Test of the annatation can be places here';
    Ann.BorderColor := ColorToPDFColor( clYellow);
    Ann.Flags := [afNoRotate];
    Ann.Opened := True;

    Ann := TPDFTextAnnotation.Create(MyPDF.CurrentPage, Rect(0, 200, MyPDF.CurrentPage.Width, 400));
    Ann.Caption := 'Closed Annatation';
    Ann.Text := 'Test of the annatation can be places here';
    Ann.BorderColor := ColorToPDFColor( clNavy );
    Ann.Flags := [afNoRotate];
    Ann.Opened := False;

    Ann := TPDFTextAnnotation.Create(MyPDF.CurrentPage, Rect(0, 400, MyPDF.CurrentPage.Width, 600));
    Ann.Caption := 'Russian Annatation';
    Ann.BorderColor := ColorToPDFColor( clYellow );
    Ann.Flags := [afNoRotate];
    Ann.Opened := True;
{$ifndef UNICODE}
    Ann.Charset := RUSSIAN_CHARSET;
    Ann.Text :=  St;
{$else}
    SetLength( st, Length (sst));
    MultiByteToWideChar(1251,0,PAnsiChar(sst),Length(sst),PWideChar(@st[1]), Length(sst));
    Ann.Text := st;
{$endif}

    Ann := TPDFTextAnnotation.Create(MyPDF.CurrentPage, Rect(0, 600, MyPDF.CurrentPage.Width, 800));
    Ann.Caption := 'Greek Annatation';
    Ann.BorderColor := ColorToPDFColor( clNavy );
    Ann.Flags := [afNoRotate];
    Ann.Opened := True;
{$ifndef UNICODE}
    Ann.Charset := GREEK_CHARSET;
    Ann.Text :=  St;
{$else}
    SetLength( st, Length (sst));
    MultiByteToWideChar(1253,0,PAnsiChar(sst),Length(sst),PWideChar(@st[1]), Length(sst));
    Ann.Text := st;
{$endif}


    St1 := 'http://www.sybrex.com';
    ST2 := 'Our homepage';
    UR := TPDFUrlAction.Create(MyPDF.Actions, ST1);
    for I := 1 to MyPDF.PageCount - 1 do
      with MyPDF[I] do
      begin
        SetLineWidth(2);
        SetColor(GrayToPDFColor(0.5));
        SetTextRenderingMode(0);
        SetActiveFont('Times', [fsBold], 12);
        TextOut(Width - 5 - GetTextWidth(IntToStr(I + 1)), Height - 17, 0, IntToStr(I + 1));
        SetActiveFont('Arial', [fsBold, fsItalic], 10);
        if Odd(I) then
        begin
          TextOut(5, Height - 15, 0, St1);
        end else
        begin
          TextOut(5, Height - 15, 0, ST2);
          TPDFActionAnnotation.Create(MyPDF[i], Rect(5, Height - 15, round(GetTextWidth(ST2)) + 5, Height), UR);
        end;
        NewPath;
        MoveTo(5, Height - 15);
        LineTo(Width - 5, Height - 15);
        Stroke;
      end;
      
    MyPDF.Outlines.Add(nil, 'HomePage', UR);
    MyPDF.Outlines.Add(nil, 'Mail to Us', TPDFURLAction.Create(MyPDF.Actions,'mailto:em-info@sybrex.com'));
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;
end.

