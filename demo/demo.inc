
{$ifdef CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 23.0}
    {$define USENAMESPACE}
  {$ifend}

{$endif}


{$A+}
{$J+}
{$R-}
{$Q-}

{$APPTYPE CONSOLE}
uses
{$IFNDEF USENAMESPACE}
  Windows, SysUtils, Classes, Graphics, Math,
{$ELSE}
  WinAPI.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math,
{$ENDIF}
  llPDFCanvas in '..\sources\llPDFCanvas.pas',
  llPDFDocument in '..\sources\llPDFDocument.pas',
  llPDFImage in '..\sources\llPDFImage.pas',
  llPDFTypes in '..\sources\llPDFTypes.pas',
  llPDFAction in '..\sources\llPDFAction.pas',
  llPDFAnnotation in '..\sources\llPDFAnnotation.pas',
  llPDFASN1 in '..\sources\llPDFASN1.pas',
  llPDFCCITT in '..\sources\llPDFCCITT.pas',
  llPDFCertKey in '..\sources\llPDFCertKey.pas',
  llPDFCrypt in '..\sources\llPDFCrypt.pas',
  llPDFEMF in '..\sources\llPDFEMF.pas',
  llPDFEngine in '..\sources\llPDFEngine.pas',
  llPDFFlate in '..\sources\llPDFFlate.pas',
  llPDFFont in '..\sources\llPDFFont.pas',
  llPDFJBIG2 in '..\sources\llPDFJBIG2.pas',
  llPDFMisc in '..\sources\llPDFMisc.pas',
  llPDFNames in '..\sources\llPDFNames.pas',
  llPDFOutline in '..\sources\llPDFOutline.pas',
  llPDFPFX in '..\sources\llPDFPFX.pas',
  llPDFResources in '..\sources\llPDFResources.pas',
  llPDFRSA in '..\sources\llPDFRSA.pas',
  llPDFSecurity in '..\sources\llPDFSecurity.pas',
  llPDFTrueType in '..\sources\llPDFTrueType.pas';

























