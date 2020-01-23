program CJK;
{$i demo.inc}


var
  MyPDF: TPDFDocument;
  MF:TMetafile;
begin
    MyPDF := TPDFDocument.Create(nil);
    try
      MyPDF.FileName := 'Data\PDFFiles\CJK.pdf';
      MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [CJK]';
      MyPDF.AutoLaunch := True;
      MyPDF.Compression := ctFlate;
      MyPDF.BeginDoc;
      MF:=TMetafile.Create;
      try
        MF.LoadFromFile('Data\Images\CJK.emf');
        MyPDF.CurrentPage.PlayMetaFile(MF);
      finally
        MF.Free;
      end;
      MyPDF.EndDoc;
    finally
      MyPDF.Free;
    end;
end.

