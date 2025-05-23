page 6185064 "NPR External Payment Type IDs"
{
    Extensible = false;
    Caption = 'External Payment Type Identifiers';
    PageType = Worksheet;
    SourceTable = "NPR External Payment Type ID";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("External Payment Type ID"; Rec."External Payment Type ID")
                {
                    ToolTip = 'Specifies the ID of the external payment type that you want to set up.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the store from which the external payment originates.';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Gateway"; Rec."Payment Gateway")
                {
                    ToolTip = 'Specifies the name of the payment gateway for which you want to set up this external payment type identifier.';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Card Company"; Rec."Credit Card Company")
                {
                    ToolTip = 'Specifies the name of the credit card company for which you want to set up this external payment type identifier.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
