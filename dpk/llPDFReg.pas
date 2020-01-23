{#header}

unit llPDFReg;

interface

uses
  Classes, llPDFDocument, llPDFTypes;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('llPDFLib', [TPDFDocument]);
end;

end.
 