{**************************************************
                                                  
                   llPDFLib                       
      Version  6.3.0.1377,   14.03.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit QRPDFFilter;

interface
  uses Windows, Messages, SysUtils, Classes, Graphics, Controls, QRPrntr,
  QuickRpt, Db, StdCtrls, QRCtrls, QR3Const, Printers, forms, llPDFDocument, llPDFTypes;


  procedure QRPDFExportPrinter(PDF: TPDFDocument; QRPrinter: TQRPrinter);
  procedure QRPDFExportReport(PDF: TPDFDocument; QRReport: TCustomQuickRep); overload;
  procedure QRPDFExportReport(PDF: TPDFDocument; QRReport: TQRCompositeReport); overload;


implementation


procedure QRPDFExportPrinter(PDF: TPDFDocument; QRPrinter: TQRPrinter);
var
  i, Count: Integer;
  MF: TMetafile;
  DC: HDC;
begin
  if not Assigned(QRPrinter) then
    Exit;
  PDF.Abort;
  DC := GetDC(0);
  PDF.OnePass:=True;
  PDF.EMFOptions.Redraw := True;
  PDF.Resolution := GetDeviceCaps(DC, LOGPIXELSX);
  ReleaseDc(0,DC);
  PDF.BeginDoc;
  Count := QRPrinter.AvailablePages{PageCount};
  for i := 1 to Count do begin
    if i > 1 then
      PDF.NewPage;
    MF := QRPrinter.GetPage(i);
    if Assigned(MF) then
    begin
      PDF.CurrentPage.Height := MF.Height;
      PDF.CurrentPage.Width := MF.Width;
      PDF.CurrentPage.PlayMetaFile(MF);
      MF.Free;
    end;
  end;
  PDF.EndDoc;
end;

procedure QRPDFExportReport(PDF: TPDFDocument; QRReport: TCustomQuickRep);
begin
  QRReport.Prepare;
  QRPDFExportPrinter(PDF, QRReport.QRPrinter);
end;

function QRPDFSavePrinterToPDF(PD: TPDFDocument; QRPrinter: TQRPrinter): Boolean;
var
  i, Count: Integer;
  MF: TMetafile;
begin
  if not Assigned(QRPrinter) then begin
    Result := False;
    Exit;
  end;
  Result := True;
  Count := QRPrinter.AvailablePages{PageCount};
  for i := 1 to Count do begin
    if i > 1 then
      PD.NewPage;
    MF := QRPrinter.GetPage(i);
    if Assigned(MF) then begin
      PD.CurrentPage.Height := MF.Height;
      PD.CurrentPage.Width := MF.Width;
      PD.CurrentPage.PlayMetaFile(MF);
    end;
  end;
end;

procedure QRPDFExportReport(PDF: TPDFDocument; QRReport: TQRCompositeReport);
var i: Integer;
    DC: HDC;
    prz: Boolean;
    SavePrinter: TQRPrinter;
begin
    PDF.Abort;
    DC := GetDC(0);
    PDF.OnePass:=True;
    PDF.Resolution := GetDeviceCaps(DC, LOGPIXELSX);
    QRReport.Prepare;
    PDF.BeginDoc;
    prz := False;
    SavePrinter := nil;
    for i := 0 to QRReport.Reports.Count - 1 do
      if Assigned(TCustomQuickRep(QRReport.Reports[i]).QRPrinter) and
         (SavePrinter <> TCustomQuickRep(QRReport.Reports[i]).QRPrinter) then begin
        if prz then
          PDF.NewPage;
        SavePrinter := TCustomQuickRep(QRReport.Reports[i]).QRPrinter;
        prz := QRPDFSavePrinterToPDF(PDF, TCustomQuickRep(QRReport.Reports[i]).QRPrinter)
      end;
    PDF.EndDoc;
end;


end.

