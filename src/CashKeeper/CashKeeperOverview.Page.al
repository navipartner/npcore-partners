page 6059961 "NPR CashKeeper Overview"
{
    // NPR5.43/CLVA/20180620 CASE 319764 Object created

    Caption = 'CashKeeper Overview';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR CashKeeper Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No."; "Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; "Total Amount")
                {
                    ApplicationArea = All;
                }
                field("Value In Cents"; "Value In Cents")
                {
                    ApplicationArea = All;
                }
                field(Salesperson; Salesperson)
                {
                    ApplicationArea = All;
                }
                field("User Id"; "User Id")
                {
                    ApplicationArea = All;
                }
                field("Lookup Timestamp"; "Lookup Timestamp")
                {
                    ApplicationArea = All;
                }
                field("CashKeeper IP"; "CashKeeper IP")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

