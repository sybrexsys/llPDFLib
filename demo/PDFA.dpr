program PDFA;
{$i demo.inc}

var
  MyPDF: TPDFDocument;
  MF: TMetafile;
  I: Integer;
begin
  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.AutoLaunch := True;
    MyPDF.Compression := ctNone;
    MyPDF.PDFACompatible := True;
    MyPDF.FileName := 'Data\PDFFiles\PDFA.pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [PDF/A]';
    MyPDF.BeginDoc;
    I := MyPDF.Images.AddImage('Data\Images\logo.bmp',itcFlate);
    MyPDF.CurrentPage.ShowImage(I,0,0);
    MyPDF.CurrentPage.SetActiveFont('Arial',[fsBold],20);
    for i := 0 to 20 do
      MyPDF.CurrentPage.TextOut(20,20+i*30,0,IntToStr(I)+' Test string');
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;
end.

