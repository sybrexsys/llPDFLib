program ImageCompression;
{$i demo.inc}


var
  MyPDF: TPDFDocument;
  I: Integer;

begin
    MyPDF := TPDFDocument.Create(nil);
    try
      MyPDF.AutoLaunch := false;
      MyPDF.Compression := ctFlate;
      MyPDF.FileName := 'Data\PDFFiles\Flate.pdf';
      MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Flate]';
      MyPDF.BeginDoc;
      I:=MyPDF.Images.AddImage('Data\Images\island.bmp',itcFlate);
      MyPDF.CurrentPage.Width:=310;
      MyPDF.CurrentPage.Height:=310;
      MyPDF.CurrentPage.ShowImage(I,5,5,300,300,0);
      MyPDF.EndDoc;

      MyPDF.FileName := 'Data\PDFFiles\CCITT3.pdf';
      MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [CCITT3]';
      MyPDF.BeginDoc;
      I:=MyPDF.Images.AddImage('Data\Images\island.bmp',itcCCITT3);
      MyPDF.CurrentPage.Width:=310;
      MyPDF.CurrentPage.Height:=310;
      MyPDF.CurrentPage.ShowImage(I,5,5,300,300,0);
      MyPDF.EndDoc;

      MyPDF.FileName := 'Data\PDFFiles\CCITT3(2D).pdf';
      MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [CCITT3(2D)]';
      MyPDF.BeginDoc;
      I:=MyPDF.Images.AddImage('Data\Images\island.bmp',itcCCITT32d);
      MyPDF.CurrentPage.Width:=310;
      MyPDF.CurrentPage.Height:=310;
      MyPDF.CurrentPage.ShowImage(I,5,5,300,300,0);
      MyPDF.EndDoc;

      MyPDF.FileName := 'Data\PDFFiles\CCITT4D.pdf';
      MyPDF.DocumentInfo.Title := 'llPDFLib 6 Demo [CCITT4]';
      MyPDF.BeginDoc;
      I:=MyPDF.Images.AddImage('Data\Images\island.bmp',itcCCITT4);
      MyPDF.CurrentPage.Width:=310;
      MyPDF.CurrentPage.Height:=310;
      MyPDF.CurrentPage.ShowImage(I,5,5,300,300,0);
      MyPDF.EndDoc;

      MyPDF.FileName := 'Data\PDFFiles\Jpeg.pdf';
      MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Jpeg]';
      MyPDF.BeginDoc;
      I:=MyPDF.Images.AddImage('Data\Images\island.bmp',itcJpeg);
      MyPDF.CurrentPage.Width:=310;
      MyPDF.CurrentPage.Height:=310;
      MyPDF.CurrentPage.ShowImage(I,5,5,300,300,0);
      MyPDF.EndDoc;
    finally
      MyPDF.Free;
    end;
end.

