//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("llPDFLibCB5.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("llPDFReg.pas");
USERES("llPDFReg.dcr");
USEPACKAGE("vcljpg50.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
