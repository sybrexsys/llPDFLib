program JBIG2;
{$i demo.inc}

var
  MyPDF: TPDFDocument;
  MF:TMetafile;
  I, D: Integer;
  Form: TPDFForm;
  Img: TBitmap;
  W,H: Integer;
begin
  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.FileName := 'Data\PDFFiles\JBIG2[rectangle].pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [JBIG2 Compression]';
    MyPDF.AutoLaunch := True;
    MyPDF.Compression := ctNone;
    MyPDF.BeginDoc;
    MyPDF.Images.JBIG2Options.SkipBlackDots := True;
    MyPDF.Images.JBIG2Options.BlackDotSize := 3;
    MyPDF.Images.JBIG2Options.LossyLevel := 5;
    MyPDF.Images.JBIG2Options.SymbolExtract := icRectangle;
    Img := TBitmap.Create;
    try
      Img.LoadFromFile('Data\Images\blank.bmp');
      W := Img.Width;
      H := Img.Height;
      I := MyPDF.Images.AddImage(Img,itcJBIG2);
    finally
      Img.Free;
    end;
    MyPDF.CurrentPage.ShowImage(I,0,0,MyPDF.CurrentPage.Width,MyPDF.CurrentPage.Height,0);
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;

  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.FileName := 'Data\PDFFiles\JBIG2[symbol].pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [JBIG2 Compression]';
    MyPDF.AutoLaunch := False;
    MyPDF.Compression := ctNone;
    MyPDF.BeginDoc;
    MyPDF.Images.JBIG2Options.SkipBlackDots := True;
    MyPDF.Images.JBIG2Options.BlackDotSize := 3;
    MyPDF.Images.JBIG2Options.LossyLevel := 5;
    MyPDF.Images.JBIG2Options.SymbolExtract := icImageOnly;
    Img := TBitmap.Create;
    try
      Img.LoadFromFile('Data\Images\blank.bmp');
      W := Img.Width;
      H := Img.Height;
      I := MyPDF.Images.AddImage(Img,itcJBIG2);
    finally
      Img.Free;
    end;
    MyPDF.CurrentPage.ShowImage(I,0,0,MyPDF.CurrentPage.Width,MyPDF.CurrentPage.Height,0);
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;

  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.FileName := 'Data\PDFFiles\JBIG2[lossylevel6].pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [JBIG2 Compression]';
    MyPDF.AutoLaunch := False;
    MyPDF.Compression := ctNone;
    MyPDF.BeginDoc;
    MyPDF.Images.JBIG2Options.SkipBlackDots := True;
    MyPDF.Images.JBIG2Options.BlackDotSize := 3;
    MyPDF.Images.JBIG2Options.LossyLevel := 6;
    MyPDF.Images.JBIG2Options.SymbolExtract := icRectangle;
    Img := TBitmap.Create;
    try
      Img.LoadFromFile('Data\Images\journal.bmp');
      W := Img.Width;
      H := Img.Height;
      I := MyPDF.Images.AddImage(Img,itcJBIG2);
    finally
      Img.Free;
    end;
    MyPDF.CurrentPage.ShowImage(I,0,0,MyPDF.CurrentPage.Width,MyPDF.CurrentPage.Height,0);
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;

  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.FileName := 'Data\PDFFiles\JBIG2[lossylevel3].pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [JBIG2 Compression]';
    MyPDF.AutoLaunch := False;
    MyPDF.Compression := ctNone;
    MyPDF.BeginDoc;
    MyPDF.Images.JBIG2Options.SkipBlackDots := True;
    MyPDF.Images.JBIG2Options.BlackDotSize := 3;
    MyPDF.Images.JBIG2Options.LossyLevel := 3;
    MyPDF.Images.JBIG2Options.SymbolExtract := icImageOnly;
    Img := TBitmap.Create;
    try
      Img.LoadFromFile('Data\Images\journal.bmp');
      W := Img.Width;
      H := Img.Height;
      I := MyPDF.Images.AddImage(Img,itcJBIG2);
    finally
      Img.Free;
    end;
    MyPDF.CurrentPage.ShowImage(I,0,0,MyPDF.CurrentPage.Width,MyPDF.CurrentPage.Height,0);
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;
end.

