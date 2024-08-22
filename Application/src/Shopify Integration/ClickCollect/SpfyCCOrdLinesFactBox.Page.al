#if not BC17
page 6184562 "NPR Spfy C&C Ord.Lines FactBox"
{
    Extensible = false;
    Caption = 'Ordered Items';
    PageType = CardPart;
    SourceTable = "NPR Spfy C&C Order";
    UsageCategory = None;
    Editable = false;
    ObsoleteState = Pending;
    ObsoleteTag = '2024-08-25';
    ObsoleteReason = 'Moved to a PTE as it was a customization for a specific customer.';

    layout
    {
        area(content)
        {
            field(OrderLines; OrderLines)
            {
                ApplicationArea = NPRShopify;
                ShowCaption = false;
                MultiLine = true;
            }
        }
    }

    var
        OrderLines: Text;
}
#endif