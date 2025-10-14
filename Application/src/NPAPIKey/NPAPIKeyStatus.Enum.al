#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059924 "NPR NP API Key Status"
{
    Access = Internal;
    Extensible = false;
    Caption = 'NaviPartner API Key Status';

    value(0; _)
    {
        Caption = '';
    }
    value(1; Active)
    {
        Caption = 'Active';
    }
    value(2; Revoked)
    {
        Caption = 'Revoked';
    }
}
#endif