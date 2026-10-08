#if not BC17
enum 6014657 "NPR Spfy ID Type"
{
    Access = Public;
    Extensible = false;

    value(0; "Entry ID")
    {
        Caption = 'Entry ID';
    }
    value(1; "Inventory Item ID")
    {
        Caption = 'Inventory Item ID';
    }
    value(2; "Store Code")
    {
        Caption = 'Store Code';
    }
    value(3; "Default Address ID")
    {
        Caption = 'Default Address ID';
    }
    // 4 is kept for a Return ID, so return, refund and discount ids can sit together.
    value(5; "Refund ID")
    {
        Caption = 'Refund ID';
    }
    value(6; "Post-Sale Disc. Line Item ID")
    {
        Caption = 'Post-Sale Discount Line Item ID';
    }
}
#endif