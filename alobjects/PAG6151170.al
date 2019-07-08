page 6151170 "NpGp Detailed POS S. Entries"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Detailed Global POS Sales Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NpGp Detailed POS Sales Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Time";"Entry Time")
                {
                }
                field("Entry Type";"Entry Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field(Open;Open)
                {
                }
                field("Remaining Quantity";"Remaining Quantity")
                {
                }
                field(Positive;Positive)
                {
                }
                field("Closed by Entry No.";"Closed by Entry No.")
                {
                }
                field("Applies to Store Code";"Applies to Store Code")
                {
                }
                field("Cross Store Application";"Cross Store Application")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

