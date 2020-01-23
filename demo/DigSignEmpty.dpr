program DigSignEmpty;
{$i demo.inc}

var
  MyPDF: TPDFDocument;
  I, D: Integer;
  Img: TBitmap;
  W,H: Integer;
  DS: TPDFDigitalSignatureAnnotation;
begin
  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.FileName := 'Data\PDFFiles\DigSignEmpty.pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Digital Signature Empty]';
    MyPDF.AutoLaunch := True;
    MyPDF.Compression := ctNone;
    MyPDF.BeginDoc;
    Img := TBitmap.Create;
    try
      Img.LoadFromFile('Data\Images\anchor.bmp');
      W := Img.Width;
      H := Img.Height;
      I := MyPDF.Images.AddImageWithTransparency(Img,itcJpeg,clWhite);
    finally
      Img.Free;
    end;
    DS := TPDFDigitalSignatureAnnotation.Create(MyPDF.AcroForms,MyPDF.CurrentPage,'DigSign',
      Rect(MyPDF.CurrentPage.Width - 150,MyPDF.CurrentPage.Height - 100,
      MyPDF.CurrentPage.Width-150+ W shr 1,MyPDF.CurrentPage.Height-100+H shr 1));
    with DS.Form do
    begin
      ShowImage(I,0,0,Width,Height,0);
    end;
    D := MyPDF.Images.AddImage('Data\Images\island.bmp',itcCCITT4);
    MyPDF.CurrentPage.ShowImage(D,0,0,MyPDF.CurrentPage.Width,MyPDF.CurrentPage.Height,0);
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;
end.

