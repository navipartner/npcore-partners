page 6014409 "NPR Credit Card Trx Receipt"
{
    Caption = 'Credit Card Transaction Receipt';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Transaction Time field';
                }
                field("Text"; Text)
                {
                    ApplicationArea = All;
                    Width = 250;
                    ToolTip = 'Specifies the value of the Text field';
                }
            }
        }
    }

    actions
    {
    }
}

