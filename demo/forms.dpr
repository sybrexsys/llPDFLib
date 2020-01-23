program Forms;
{$i demo.inc}

var
  MyPDF: TPDFDocument;
  Form: TPDFForm;
  I: Integer;
begin
    MyPDF := TPDFDocument.Create(nil);
    try
      MyPDF.AutoLaunch := True;
      MyPDF.Compression := ctFlate;
      MyPDF.FileName := 'Data\PDFFiles\Forms.pdf';
      MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Forms]';
      MyPDF.OnePass := True;
      MyPDF.BeginDoc;
      Form := MyPDF.AppendForm;;
      with Form do
      begin
        Width := 240;
        Height := 240;
        SetLineWidth(1);
        SetColorStroke(GrayToPDFColor(0));
        for I := 12 downto 1 do
        begin
          SetColorFill(RGBToPDFColor(1, i / 12, i / 12));
          Pie((6 - I) * 10, Height / 2 - (Width / 2 ) + (6 - I) * 10,
            Width - (6 - I) * 10, Height / 2 + (Width / 2 ) - (6 - I) * 10, 0, I * 30);
          FillAndStroke;
        end;
      end;
      for I := 1 to 20 do
      begin
        if I <> 1 then MyPDF.NewPage;
        MyPDF.CurrentPage.PlayForm(Form,i*10,i*10,1/i,1);
      end;
      MyPDF.EndDoc;
    finally
      MyPDF.Free;
    end;
end.

