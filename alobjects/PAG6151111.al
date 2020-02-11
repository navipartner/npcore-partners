page 6151111 "NpRi Sales Inv. Setup Subpage"
{
    // NPR5.53/MHA /20191104  CASE 364131 Object Created - NaviPartner Reimbursement - Sales Invoice

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpRi Sales Inv. Setup Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Invoice %";"Invoice %")
                {
                }
            }
        }
    }

    actions
    {
    }
}

