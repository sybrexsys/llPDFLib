program AcroForm;
{$i demo.inc}

var
  PDF: TPDFDocument;
  Btn1, Btn2: TPDFButton;
  Ed: TPDFEditBox;
  CB: TPDFCheckBox;
  RB: TPDFRadioButton;
  HV1, HV2: TPDFVisibleAction;
  A: TPDFAction;



begin
  PDF := TPDFDocument.Create(nil);
  try
    PDF.AutoLaunch := True ;
    PDF.FileName := 'Data\PDFFiles\AcroForm.pdf';
    PDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [AcroForm]';
    PDF.NonEmbeddedFonts.Add('Arial');
    PDF.BeginDoc;
    PDF.Compression := ctNone;
    PDF.AutoCreateURL := True;
    with PDF.CurrentPage do
    begin
      Width := 140;
      Height := 120;
      SetColorStroke(GrayToPDFColor(0));
      SetColorFill(GrayToPDFColor(0.7));
      Rectangle(10, 10, 130, 20);
      FillAndStroke;
      SetColorFill(GrayToPDFColor(1));
      Rectangle(10, 20, 130, 110);
      FillAndStroke;
      SetColorFill(GrayToPDFColor(0));
      SetActiveFont(stdfHelvetica, 8);
      TextOut(35, 45, 0, 'Subscribe');
      TextOut(35, 60, 0, 'Unsubscribe');
      SetActiveFont(stdfHelvetica, 10);
      SetTextRenderingMode(2);
      SetLineWidth(0.3);
      SetColorFill(GrayToPDFColor(1));
      TextBox(Rect(10, 15, 130, 18), 'Sybrex News', hjCenter, vjCenter);
    end;
      Ed := TPDFEditBox.Create(PDF.AcroForms, PDF.CurrentPage,'email', Rect(20, 30, 120, 43));
      Ed.Text := 'Your Email';
      CB := TPDFCheckBox.Create( PDF.AcroForms, PDF.CurrentPage,'html', Rect(20, 75, 120, 85));
      CB.Caption := 'Send HTML Version';

      RB := TPDFRadioButton.Create( PDF.AcroForms, PDF.CurrentPage, 'action',Rect(20, 45, 30, 55),'sign', True) ;
      Btn1 := TPDFButton. Create( PDF.AcroForms, PDF.CurrentPage, 'Btn1',Rect(20, 90, 65, 105),'Send');
      Btn1.OnMouseUp := TPDFSubmitAction.Create(PDF.Actions, 'http://www.sybrex.com/subscription.php', True, stPost, True );
      HV1 := TPDFVisibleAction.Create(PDF.Actions, False);
      HV1.Add(CB);
      RB.OnMouseUp := HV1;

      RB := TPDFRadioButton.Create( PDF.AcroForms, PDF.CurrentPage,'action',Rect(20, 60, 30, 70), 'delete', False) ;
      HV2 := TPDFVisibleAction.Create(PDF.Actions, True);
      RB.OnMouseUp := HV2;
      HV2.Add(CB);
      Btn2 := TPDFButton. Create( PDF.AcroForms, PDF.CurrentPage,'Btn2',Rect(70, 90, 120, 105), 'Reset');
      A := TPDFResetAction.Create(PDF.Actions,True);
      A.AddNext( HV1 );
      Btn2.OnMouseUp := A;
    PDF.EndDoc;
  finally
    PDF.Free
  end;

end.

