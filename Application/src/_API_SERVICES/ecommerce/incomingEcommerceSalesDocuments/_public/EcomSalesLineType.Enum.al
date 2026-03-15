/// <summary>
/// Defines line types for ecommerce sales documents.
/// Distinguishes between items, comments, and shipment fees on sales lines.
/// </summary>
enum 6059943 "NPR Ecom Sales Line Type"
{
    Extensible = false;
    value(0; "Comment")
    {
        Caption = 'Comment';
    }

    value(1; "Item")
    {
        Caption = 'Item';
    }

    value(3; "Shipment Fee")
    {
        Caption = 'Shipment Fee';
    }
    value(4; "Voucher")
    {
        Caption = 'Voucher';
    }
    value(5; "Ticket")
    {
        Caption = 'Ticket';
        ObsoleteState = Pending;
        ObsoleteTag = '2026-02-23';
        ObsoleteReason = 'Use Type::Item with Subtype::Ticket instead.';
    }
    value(6; "Membership")
    {
        Caption = 'Membership';
        ObsoleteState = Pending;
        ObsoleteTag = '2026-02-23';
        ObsoleteReason = 'Use Type::Item instead with Subtype::Membership instead.';
    }
}
