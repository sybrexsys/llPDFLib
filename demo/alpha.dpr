program Alpha;
{$i demo.inc}


var
  MyPDF: TPDFDocument;
  GState: TPDFGState;
begin
    MyPDF := TPDFDocument.Create(nil);
    try
      MyPDF.AutoLaunch := True;
      MyPDF.Compression := ctFlate;
      MyPDF.FileName := 'Data\PDFFiles\AlphaBlending.pdf';
      MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [AlphaBlending]';
      MyPDF.OnePass := True;
      MyPDF.BeginDoc;
      GState := MyPDF.AppendExtGState;
      GState.AlphaFill :=0.5;
      GState.AlphaStroke := 0.5;
      with MyPDF.CurrentPage do
      begin
        SetExtGState(GState);
        SetColorStroke( RGBToPDFColor( 1.0, 0.0, 0.0 ) );
        SetColorFill ( RGBToPDFColor( 0.0, 1.0, 0.0 ) );
		Rectangle( 100, 100, 300, 300 );
		FillAndStroke;
        SetColorStroke( RGBToPDFColor( 1.0, 1.0, 0.0 ) );
        SetColorFill ( RGBToPDFColor( 0.0, 1.0, 1.0 ) );
		Rectangle( 150, 150, 350, 350 );
		FillAndStroke;
      end;
      MyPDF.EndDoc;
    finally
      MyPDF.Free;
    end;
end.

