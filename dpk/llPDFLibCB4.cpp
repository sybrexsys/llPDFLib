//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("llPDFLibCB4.res");
USEPACKAGE("vcl40.bpi");
USEUNIT("llPDFReg.pas");
USERES("llPDFReg.dcr");
USEPACKAGE("vcljpg40.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------
//   Package source.
//---------------------------------------------------------------------------
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
