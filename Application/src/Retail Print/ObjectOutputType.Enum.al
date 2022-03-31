enum 6014489 "NPR Object Output Type"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; "Printer Name")
    {
        Caption = 'Printer Name';
    }
    value(1; File)
    {
        Caption = '';
    }
    value(2; "Epson Web")
    {
        Caption = '';
    }
    value(3; "E-Mail")
    {
        Caption = '';
    }
    value(4; "Google Print")
    {
        Caption = '';
    }
    value(5; HTTP)
    {
        Caption = 'MPOS HTTP';
    }
    value(6; Bluetooth)
    {
        Caption = 'MPOS Bluetooth';
    }
    value(7; "PrintNode PDF")
    {
        Caption = '';
    }
    value(8; "PrintNode Raw")
    {
        Caption = 'PrintNode';
    }
}