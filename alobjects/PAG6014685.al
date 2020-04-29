page 6014685 "Sales Price Maintenance Setupo"
{
    // NPR5.25/CLVA/20160628 CASE 244461 : Sales Price Maintenance

    AutoSplitKey = true;
    Caption = 'Sales Price Maintenance Setup';
    PageType = List;
    SourceTable = "Sales Price Maintenance Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id;Id)
                {
                }
                field("Sales Type";"Sales Type")
                {
                }
                field("Sales Code";"Sales Code")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Prices Including VAT";"Prices Including VAT")
                {
                }
                field("VAT Bus. Posting Gr. (Price)";"VAT Bus. Posting Gr. (Price)")
                {
                }
                field("Allow Invoice Disc.";"Allow Invoice Disc.")
                {
                }
                field("Allow Line Disc.";"Allow Line Disc.")
                {
                }
                field("Internal Unit Price";"Internal Unit Price")
                {
                }
                field(Factor;Factor)
                {
                }
            }
        }
    }

    actions
    {
    }
}

