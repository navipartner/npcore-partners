#if not BC17
page 6184562 "NPR Spfy C&C Ord.Lines FactBox"
{
    Extensible = false;
    Caption = 'Ordered Items';
    PageType = CardPart;
    SourceTable = "NPR Spfy C&C Order";
    UsageCategory = None;
    Editable = false;

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

    trigger OnAfterGetRecord()
    begin
        OrderLines := Rec.GetOrderLines();
    end;

    var
        OrderLines: Text;
}
#endif