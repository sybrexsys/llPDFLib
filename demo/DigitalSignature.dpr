program DigitalSignature;
{$i demo.inc}

var
  MyPDF: TPDFDocument;
  I, D: Integer;
  Form: TPDFForm;
  Img: TBitmap;
  W,H: Integer;
  MF: TMetafile;
begin
  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.FileName := 'Data\PDFFiles\DigSignInvisible.pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Digital Signature Invisible]';
    MyPDF.AutoLaunch := True;
    MyPDF.Compression := ctNone;
    MyPDF.BeginDoc;
    MyPDF.AppendDigitalSignatureKeys('Data\Other\LongJohnSilver.pfx','123456');
    MyPDF.DigitalSignature.Name := 'John Silver';
    MyPDF.DigitalSignature.Location := 'Treasure island';
    MyPDF.DigitalSignature.Reason := 'Yo-ho-ho';
    I := MyPDF.Images.AddImage('Data\Images\island.bmp',itcCCITT4);
    MyPDF.CurrentPage.ShowImage(i,0,0,MyPDF.CurrentPage.Width,MyPDF.CurrentPage.Height,0);
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;

  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.FileName := 'Data\PDFFiles\DigSignVisible.pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Digital Signature Visible]';
    MyPDF.AutoLaunch := True;
    MyPDF.Compression := ctNone;
    MyPDF.BeginDoc;
    MyPDF.AppendDigitalSignatureKeys('Data\Other\LongJohnSilver.pfx','123456');
    MyPDF.DigitalSignature.Name := 'John Silver';
    MyPDF.DigitalSignature.Location := 'Treasure island';
    MyPDF.DigitalSignature.Reason := 'Yo-ho-ho';
    Img := TBitmap.Create;
    try
      Img.LoadFromFile('Data\Images\anchor.bmp');
      W := Img.Width;
      H := Img.Height;
      I := MyPDF.Images.AddImageWithTransparency(Img,itcFlate,clWhite);
    finally
      Img.Free;
    end;
    Form := MyPDF.DigitalSignature.CreateVisualForm(MyPDF.CurrentPage,
      Rect(MyPDF.CurrentPage.Width - 150,MyPDF.CurrentPage.Height - 100,
      MyPDF.CurrentPage.Width-150+ W shr 1,MyPDF.CurrentPage.Height-100+H shr 1));
    with Form do
    begin
      ShowImage(I,0,0,Width,Height,0);
    end;
    with MyPDF.CurrentPage do
    begin
      MF := TMetafile.Create;
      try
        MF.LoadFromFile('Data\Images\chart.emf');
        PlayMetaFile(MF,0,0,1,1);
      finally
        MF.Free;
      end;
    end;
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;

end.

