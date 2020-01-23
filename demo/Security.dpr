program Security;
{$i demo.inc}

var
  MyPDF: TPDFDocument;
  MF: TMetafile;
  I: Integer;
begin
  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.AutoLaunch := True;
    MyPDF.Security.State := ss256AES;
    myPDF.Security.UserPassword := '';
    myPDF.Security.OwnerPassword :='12345';
    MyPDF.Compression := ctNone;
    MyPDF.FileName := 'Data\PDFFiles\Pattern.pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Security 256 Bit AES]';
    MyPDF.BeginDoc;
    I := MyPDF.Images.AddImage('Data\Images\logo.bmp',itcFlate);
    MyPDF.CurrentPage.ShowImage(I,0,0);
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;
end.

