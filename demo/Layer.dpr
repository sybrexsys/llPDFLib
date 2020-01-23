program Layer;
{$i demo.inc}

var
  MyPDF: TPDFDocument;
  Op1, Op2, Op3, Op4: TOptionalContent;
  F1: TPDFForm;
  I: Integer;
  MF: TMetafile;
begin
  MyPDF := TPDFDocument.Create(nil);
  try
    MyPDF.AutoLaunch := True;
    MyPDF.Compression := ctNone;
    MyPDF.FileName := 'Data\PDFFiles\Layer.pdf';
    MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Optional Content]';
    MyPDF.BeginDoc;
    Op1 := MyPDF.AppendOptionalContent('Layer 1 Visible rectangle and form with text', True);
    Op2 := MyPDF.AppendOptionalContent('Layer 2 Invisible round rectangle', False);
    Op3 := MyPDF.AppendOptionalContent('Layer 2 Visible image File', True, False );
    Op4 := MyPDF.AppendOptionalContent('Layer 4 Invisible ellipse', false );
    F1 :=MyPDF.AppendForm(Op1);
    with F1 do
    begin
      Width := 200;
      Height := 100;
      SetColorStroke( RGBToPDFColor(0.0, 0.0, 0.0 ) );
      SetColorFill ( RGBToPDFColor( 0.0, 0.0, 0.0 ) );
      SetActiveFont(stdfHelvetica,40);
      TextOut(40,40,0,'Test');
    end;
    with MyPDF.CurrentPage do
    begin

      SetColorStroke( RGBToPDFColor( 1.0, 0.0, 0.0 ) );
      SetColorFill ( RGBToPDFColor( 0.0, 1.0, 0.0 ) );
      NewPath;
      Rectangle( 100, 100, 300, 300 );
      FillAndStroke;


      TurnOnOptionalContent(OP1);
        SetColorFill(RGBToPDFColor(0.1,0.7,1));
        Rectangle(20,200,400,300);
        FillAndStroke;
      TurnOffOptionalContent;

      TurnOnOptionalContent(OP2);
        SetColorFill(RGBToPDFColor(0.3,0.4,0.5));
        SetColorStroke(RGBToPDFColor(1,1,0));
        NewPath;
        RoundRect(420,80,500,260, 10, 10);
        FillAndStroke;
      TurnOffOptionalContent;

      TurnOnOptionalContent(Op4);
        SetColorStroke( RGBToPDFColor( 1.0, 1.0, 0.0 ) );
        SetColorFill ( RGBToPDFColor( 1.0, 1.0, 1.0 ) );
        Ellipse( 150, 150, 250, 350 );
        FillAndStroke;
      TurnOffOptionalContent;

      TurnOnOptionalContent(Op3);

      TurnOffOptionalContent;

      PlayForm( F1, 0,0,1,1);
      I := MyPDF.Images.AddImage('Data\Images\logo.bmp',itcFlate);
      F1 :=MyPDF.AppendForm(Op3);
      with F1 do
      begin
        Width := 200;
        Height := 100;
        ShowImage(I,0,0,Width,Height,0);
      end;
      PlayForm( F1, 200,0,1,1);

      MF := TMetafile.Create;
      try
        MF.LoadFromFile('Data\Images\Logo.emf');
        PlayMetaFile(MF,40,40,0.7,0.7,Op3);
      finally
        MF.Free;
      end;

    end;
    MyPDF.EndDoc;
  finally
    MyPDF.Free;
  end;
end.

