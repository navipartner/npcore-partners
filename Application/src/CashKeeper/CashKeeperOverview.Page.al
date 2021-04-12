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
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR CashKeeper Overview";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction No. field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Value In Cents"; Rec."Value In Cents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value In Cents field';
                }
                field(Salesperson; Rec.Salesperson)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson field';
                }
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Id field';
                }
                field("Lookup Timestamp"; Rec."Lookup Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lookup Timestamp field';
                }
                field("CashKeeper IP"; Rec."CashKeeper IP")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CashKeeper IP field';
                }
            }
        }
    }

    actions
    {
    }
}

