{**************************************************
                                                  
                   llPDFLib                       
      Version  6.3.0.1377,   14.03.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit FR_E_PDF;
interface
uses llPDFDocument, llPDFTypes, FR_Class, Classes, windows, sysutils, Graphics;

type
  TfrPDFExport = class(TfrExportFilter)
  private
    FPDF: TPDFDocument;
    FP: Boolean;
    CurPage: Integer;
    Alpha: Extended;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnBeginPage; override;
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
    procedure OnData(x, y: Integer; View: TfrView); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('llPDFLib', [TfrPDFExport]);
end;


{ TfrPDFExport }

constructor TfrPDFExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPDF := TPDFDocument.Create(Self);
  if ClassName = 'TfrPDFExport' then
    frRegisterExportFilter(Self, 'Adobe Acrobat Documents (*.pdf)', '*.pdf');
end;

destructor TfrPDFExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  FPDF.Free;
  inherited;
end;

procedure TfrPDFExport.OnBeginDoc;
var
  DC: HDC;
begin
  inherited;
  if FPDF.Printing then FPDF.Abort;
  FPDF.FileName := FileName;
  FPDF.OutputStream := Stream;
  FPDF.Compression := ctFlate;
  FPDF.NonEmbeddedFont.Add('WingDings');
  FPDF.OnePass := True;
  DC := GetDC(0);
  FPDF.Resolution := GetDeviceCaps(dc, LOGPIXELSX);
  Alpha :=  FPDF.Resolution/91.4;
  ReleaseDC(0, DC);
  FPDF.BeginDoc;
  FP := True;
  CurPage := -1;
end;

procedure TfrPDFExport.OnBeginPage;
begin
  Inc(CurPage);
  if CurPage <> 0 then FPDF.NewPage;
  FPDF.CurrentPage.Width := Round(CurReport.EMFPages[CurPage].PrnInfo.Pgw * Alpha);
  FPDF.CurrentPage.Height := Round(CurReport.EMFPages[CurPage].PrnInfo.Pgh * Alpha);
end;

procedure TfrPDFExport.OnData(x, y: Integer; View: TfrView);
begin
  View.Draw(FPDF.Canvas);
end;

procedure TfrPDFExport.OnEndDoc;
begin
  FPDF.EndDoc;
end;


end.

