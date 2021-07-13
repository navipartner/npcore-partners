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

    SourceTable = "NPR CashKeeper Overview";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No."; Rec."Transaction No.")
                {

                    ToolTip = 'Specifies the value of the Transaction No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount"; Rec."Total Amount")
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Value In Cents"; Rec."Value In Cents")
                {

                    ToolTip = 'Specifies the value of the Value In Cents field';
                    ApplicationArea = NPRRetail;
                }
                field(Salesperson; Rec.Salesperson)
                {

                    ToolTip = 'Specifies the value of the Salesperson field';
                    ApplicationArea = NPRRetail;
                }
                field("User Id"; Rec."User Id")
                {

                    ToolTip = 'Specifies the value of the User Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Lookup Timestamp"; Rec."Lookup Timestamp")
                {

                    ToolTip = 'Specifies the value of the Lookup Timestamp field';
                    ApplicationArea = NPRRetail;
                }
                field("CashKeeper IP"; Rec."CashKeeper IP")
                {

                    ToolTip = 'Specifies the value of the CashKeeper IP field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

