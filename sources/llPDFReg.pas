{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}


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
 