{**************************************************
                                                  
                   llPDFLib                       
      Version  6.3.0.1377,   14.03.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit frxExportllPDF4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, frxClass, llPDFDocument, llPDFTypes;

type
  TllPDFExportDialog = class(TForm)
    OkButton: TButton;
    CancelButton: TButton;
    blBottom: TBevel;
    pcSettings: TPageControl;
    stSettings: TTabSheet;
    tsFonts: TTabSheet;
    tsSecurity: TTabSheet;
    GroupPageRange: TGroupBox;
    DescrL: TLabel;
    AllRB: TRadioButton;
    CurPageRB: TRadioButton;
    PageNumbersRB: TRadioButton;
    PageNumbersE: TEdit;
    gbFileOptions: TGroupBox;
    cbOpenafterexport: TCheckBox;
    cbImagesasjpeg: TCheckBox;
    cbUrlDetection: TCheckBox;
    cbCompressed: TCheckBox;
    lbSMethod: TLabel;
    cbSecurityMethod: TComboBox;
    gbPasswords: TGroupBox;
    lbUser: TLabel;
    lbOwner: TLabel;
    edUser: TEdit;
    edOwner: TEdit;
    gbResources: TGroupBox;
    cbPrintTheDocument: TCheckBox;
    cbModifyContext: TCheckBox;
    cbCopyText: TCheckBox;
    cbAddAnnot: TCheckBox;
    cbFillForm: TCheckBox;
    cbExtractTextAndGraphics: TCheckBox;
    cbAssemble: TCheckBox;
    cbPrintHigh: TCheckBox;
    cbEmbedAllFonts: TCheckBox;
    cbEmulateStandard: TCheckBox;
    lbAlways: TLabel;
    lbNewer: TLabel;
    liboAlways: TListBox;
    liboNewer: TListBox;
    btnInOne: TButton;
    btnInAll: TButton;
    btnOutOne: TButton;
    btnOutAll: TButton;
    SaveDialog1: TSaveDialog;
    procedure cbSecurityMethodChange(Sender: TObject);
    procedure cbEmbedAllFontsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOutAllClick(Sender: TObject);
    procedure btnInAllClick(Sender: TObject);
    procedure btnInOneClick(Sender: TObject);
    procedure btnOutOneClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TllPDFExport = class(TfrxCustomExportFilter)
  private
    FCompressed: Boolean;
    FProtected:Boolean;
    FUserPassword:string;
    FOwnerPassword:string;
    FImagesAsJpeg:Boolean;
    FURLDetection:Boolean;
    FEmulateStandardFonts:Boolean;
    FKeyLength:TPDFSecurityState;
    FName: String;
    FOpenAfterExport: Boolean;
    FPDF: TPDFDocument;
    FNonEmbeddedFonts: TStringList;
    FPO: TPDFSecurityPermissions;
    FFirst:Boolean;

    procedure SetNonEmbeddedFonts(const Value: TStringList);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
    class function GetDescription: String; override;
    function ShowModal: TModalResult; override;
    function Start: Boolean; override;
    procedure ExportObject(Obj: TfrxComponent); override;
    procedure Finish; override;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); override;
  published
    property Compressed: Boolean read FCompressed write FCompressed default true;
    property NonEmbeddedFonts: TStringList read FNonEmbeddedFonts write SetNonEmbeddedFonts;
    property FileName: String read FName write FName;
    property OpenAfterExport: Boolean read FOpenAfterExport
      write FOpenAfterExport default true;
    property ProtectedPDF: Boolean read FProtected Write FProtected default false;
    property ImagesAsJpeg:Boolean read FImagesAsJpeg Write FImagesAsJpeg default true;
    property EmulateStandardFonts: Boolean read FEmulateStandardFonts Write FEmulateStandardFonts default False;
    property URLDetection:Boolean read FURLDetection Write FURLDetection default true;
    property KeyLength: TPDFSecurityState read FKeyLength Write FKeyLength default ssNone;
    property ProtectionOptions:TPDFSecurityPermissions read FPO Write FPO;
  end;

implementation



uses frxUtils, frxRes, frxrcExports;

{$R *.dfm}

procedure TllPDFExportDialog.cbSecurityMethodChange(Sender: TObject);
begin
 case cbSecurityMethod.ItemIndex of
 0:begin
     edUser.Enabled:=False;
     edOwner.Enabled:=False;
     cbPrintTheDocument.Enabled:=False;
     cbPrintHigh.Enabled:=False;
     cbAddAnnot.Enabled:=False;
     cbModifyContext.Enabled:=False;
     cbCopyText.Enabled:=False;
     cbFillForm.Enabled:=False;
     cbExtractTextAndGraphics.Enabled:=False;
     cbAssemble.Enabled:=False;
   end;
 1:begin
     edUser.Enabled:=True;
     edOwner.Enabled:=True;
     cbPrintTheDocument.Enabled:=True;
     cbPrintHigh.Enabled:=False;
     cbAddAnnot.Enabled:=True;
     cbModifyContext.Enabled:=True;
     cbCopyText.Enabled:=True;
     cbFillForm.Enabled:=False;
     cbExtractTextAndGraphics.Enabled:=False;
     cbAssemble.Enabled:=False;
   end;
 2:begin
     edUser.Enabled:=True;
     edOwner.Enabled:=True;
     cbPrintTheDocument.Enabled:=True;
     cbPrintHigh.Enabled:=True;
     cbAddAnnot.Enabled:=True;
     cbModifyContext.Enabled:=True;
     cbCopyText.Enabled:=True;
     cbFillForm.Enabled:=True;
     cbExtractTextAndGraphics.Enabled:=True;
     cbAssemble.Enabled:=True;
   end;
   end;
end;

procedure TllPDFExportDialog.cbEmbedAllFontsClick(Sender: TObject);
begin
  liboAlways.Enabled:=not cbEmbedAllFonts.Checked;
  liboNewer.Enabled:=not cbEmbedAllFonts.Checked;
  btnInOne.Enabled:=not cbEmbedAllFonts.Checked;
  btnInAll.Enabled:=not cbEmbedAllFonts.Checked;
  btnOutOne.Enabled:=not cbEmbedAllFonts.Checked;
  btnOutAll.Enabled:=not cbEmbedAllFonts.Checked;
end;

procedure TllPDFExportDialog.FormCreate(Sender: TObject);
begin
  cbSecurityMethod.ItemIndex:=0;
  liboAlways.Items.Assign(Screen.Fonts);
  liboAlways.ItemIndex:=0;
  pcSettings.ActivePageIndex:=0;

end;

procedure TllPDFExportDialog.btnOutAllClick(Sender: TObject);
begin
  liboAlways.Items.Assign(Screen.Fonts);
  liboAlways.ItemIndex:=0;
  liboNewer.Items.Clear;
end;

procedure TllPDFExportDialog.btnInAllClick(Sender: TObject);
begin
  liboNewer.Items.Assign(Screen.Fonts);
  liboNewer.ItemIndex:=0;
  liboAlways.Items.Clear;
end;

procedure TllPDFExportDialog.btnInOneClick(Sender: TObject);
var
  I:Integer;
begin
  I:=liboAlways.ItemIndex;
  liboNewer.Items.Add(liboAlways.Items[i]);
  liboAlways.Items.Delete(i);
end;

procedure TllPDFExportDialog.btnOutOneClick(Sender: TObject);
var
  I:Integer;
begin
  I:=liboNewer.ItemIndex;
  liboAlways.Items.Add(liboNewer.Items[i]);
  liboNewer.Items.Delete(i);
end;

{ TllPDFExport }

constructor TllPDFExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCompressed := True;
  FOpenAfterExport:=True;
  FImagesAsJpeg:=True;
  FURLDetection:=True;
  FEmulateStandardFonts:=False;
  FNonEmbeddedFonts:=TStringList.Create;
  FProtected:=False;
  FOwnerPassword:='';
  FUserPassword:='';
end;

destructor TllPDFExport.Destroy;
begin
  FNonEmbeddedFonts.Free;
  inherited;
end;

procedure TllPDFExport.ExportObject(Obj: TfrxComponent);
begin
  inherited;
    TfrxView(Obj).Draw(FPDF.Canvas, 1, 1, 0, 0);
end;

procedure TllPDFExport.Finish;
begin
  inherited;
  FPDF.DocumentInfo.Title := Report.ReportOptions.Name;
  if FPDF.Printing then FPDF.EndDoc;
  FPDF.Free;
end;

class function TllPDFExport.GetDescription: String;
begin
    Result := frxResources.Get('Advanced PDF Export');
end;

procedure TllPDFExport.SetNonEmbeddedFonts(const Value: TStringList);
begin
  FNonEmbeddedFonts.Assign(Value);
end;

function TllPDFExport.ShowModal: TModalResult;
begin
  with TllPDFExportDialog.Create(nil) do
  begin
    cbOpenafterexport.Checked := FOpenAfterExport;
    cbUrlDetection.Checked:=FURLDetection;
    cbCompressed.Checked:=FCompressed;
    cbImagesasjpeg.Checked:=FImagesAsJpeg;
    cbEmulateStandard.Checked:=FEmulateStandardFonts;
    if not FProtected then cbSecurityMethod.ItemIndex:=0 else
    begin
      cbSecurityMethod.ItemIndex := Ord(FKeyLength);
      cbPrintTheDocument.Checked := coPrint in FPO;
      cbPrintHigh.Checked :=coPrintHi in FPO;
      cbCopyText.Checked :=coCopyInformation in FPO;
      cbAddAnnot.Checked :=coModifyAnnotation in FPO;
      cbFillForm.Checked :=coFillAnnotation in FPO;
      cbExtractTextAndGraphics.Checked :=coExtractInfo in FPO;
      cbAssemble.Checked :=coAssemble in FPO;
      cbModifyContext.Checked :=coModifyStructure in FPO;
    end;
    edUser.Text:=FUserPassword;
    edOwner.Text:=FOwnerPassword;
    Result := ShowModal;
    if Result = mrOk then
    begin
      PageNumbers := '';
      CurPage := False;
      if CurPageRB.Checked then
        CurPage := True
      else if PageNumbersRB.Checked then
        PageNumbers := PageNumbersE.Text;
      FOpenAfterExport := cbOpenafterexport.Checked;
      FCompressed := cbCompressed.Checked;
      FImagesAsJpeg:=cbImagesasjpeg.Checked;
      FURLDetection:=cbUrlDetection.Checked;
      if cbEmbedAllFonts.Checked then FNonEmbeddedFonts.Clear
      else FNonEmbeddedFonts.Assign(liboNewer.Items);
      if cbSecurityMethod.ItemIndex=0 then FProtected:=false
      else
      begin
        FProtected:=True;
        FPO:=[];
        if cbPrintTheDocument.Checked then FPO:=FPO+[coPrint];
        if cbPrintHigh.Checked then FPO:=FPO+[coPrintHi];
        if cbCopyText.Checked then FPO:=FPO+[coCopyInformation];
        if cbAddAnnot.Checked then FPO:=FPO+[coModifyAnnotation];
        if cbFillForm.Checked then FPO:=FPO+[coFillAnnotation];
        if cbExtractTextAndGraphics.Checked then FPO:=FPO+[coExtractInfo];
        if cbAssemble.Checked then FPO:=FPO+[coAssemble];
        if cbModifyContext.Checked then FPO:=FPO+[coModifyStructure];
        FKeyLength := TPDFSecurityState(cbSecurityMethod.ItemIndex);
      end;
      FUserPassword:=edUser.Text;
      FOwnerPassword:=edOwner.Text;
      if SaveDialog1.Execute then FName := SaveDialog1.FileName
      else Result := mrCancel;
    end;
    Free;
  end;

end;

function TllPDFExport.Start: Boolean;
begin
  FFirst:=True;
  if FName <> '' then
  begin
    FPDF := TPDFDocument.Create(nil);
    if FCompressed then FPDF.Compression := ctFlate  else FPDF.Compression:=ctNone;
    FPDF.NonEmbeddedFonts.Assign(FNonEmbeddedFonts);
    FPDF.EMFOptions. ColorImagesAsJPEG:=FImagesAsJpeg;
    FPDF.Security.State:=FKeyLength;
    FPDF.Security.Permissions:=FPO;
    FPDF.EmulateStandardFont:=FEmulateStandardFonts;
    FPDF.Security.UserPassword:=FUserPassword;
    FPDF.Security.OwnerPassword:=FOwnerPassword;
    FPDF.AutoCreateURL:=FURLDetection;
    FPDF.FileName:=FName;
    FPDF.AutoLaunch:=FOpenAfterExport;
    Result := True;
    FPDF.Resolution:=Screen.PixelsPerInch;
  end
  else Result := False;
end;

procedure TllPDFExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  inherited;
  if FFirst then
  begin
    FFirst:=False;
    FPDF.BeginDoc;
  end else FPDF.NewPage;
  FPDF.CurrentPage.Width := round(Page.Width);
  FPDF.CurrentPage.Height := round(Page.Height);
end;


end.
