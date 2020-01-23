program Patterns;
{$i demo.inc}

var
  MyPDF: TPDFDocument;
  Img: TBitmap;
  Pattern:TPDFPattern;
  i: Integer;
begin
  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.AutoLaunch := True;
    MyPDF.Compression := ctNone;
    MyPDF.FileName := 'Data\PDFFiles\Pattern.pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Patterns]';
    MyPDF.BeginDoc;
    Img := TBitmap.Create;
    try
      Img.LoadFromFile('Data\Images\anchor.bmp');
      i := myPDF.Images.AddImage(Img,itcJpeg);
    finally
      Img.Free;
    end;
    Pattern := MyPDF.AppendPattern;
    with Pattern do
    begin
      Width := 30;
      Height := 30;
      XStep := 30;
      YStep := 30;
      ShowImage(i,0,0,30,30,0);
    end;
    with MyPDF.CurrentPage do
    begin
      NewPath;
      SetPattern(Pattern);
      Ellipse(100,100,480,180);
      FillAndStroke;
      SetActiveFont(stdfHelveticaBold,160);
      SetTextRenderingMode(2);
      TextOut(20,400,0,'Pattern');
    end;
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;

end.

