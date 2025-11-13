#if not BC17
enum 6059874 "NPR Spfy Product Status"
{
    Caption = 'Shopify Product Status';
    Access = Public;
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; DRAFT)
    {
        Caption = 'Draft';
    }
    value(2; ACTIVE)
    {
        Caption = 'Active';
    }
    value(3; ARCHIVED)
    {
        Caption = 'Archived';
    }
    value(4; UNLISTED)
    {
        Caption = 'Unlisted';
    }
}
#endif