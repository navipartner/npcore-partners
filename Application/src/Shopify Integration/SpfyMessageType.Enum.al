#if not BC17
enum 6059838 "NPR Spfy Message Type"
{
    Access = Internal;
    Extensible = false;

    value(0; Error)
    {
        Caption = 'Error';
    }
    value(10; Warning)
    {
        Caption = 'Warning';
    }
    value(20; Info)
    {
        Caption = 'Info';
    }
}
#endif