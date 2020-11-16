page 6014409 "NPR Credit Card Trx Receipt"
{
    Caption = 'Credit Card Transaction Receipt';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR EFT Receipt";
    SourceTableView = WHERE(Type = FILTER(0 | 3));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction Time"; "Transaction Time")
                {
                    ApplicationArea = All;
                }
                field("Text"; Text)
                {
                    ApplicationArea = All;
                    Width = 250;
                }
            }
        }
    }

    actions
    {
    }
}

