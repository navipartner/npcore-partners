/// <summary>
/// Classifies the virtual item subtype of an ecommerce sales line.
/// Item = regular item line (no virtual item processing).
/// </summary>
enum 6014581 "NPR Ecom Sales Line Subtype"
{
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Ticket)
    {
        Caption = 'Ticket';
    }
    value(2; Voucher)
    {
        Caption = 'Voucher';
    }
    value(3; Item)
    {
        Caption = 'Item';
    }
    value(4; Membership)
    {
        Caption = 'Membership';
    }
    value(5; Coupon)
    {
        Caption = 'Coupon';
    }
}
