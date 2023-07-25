page 6150904 "NPR HC Payment Types"
{
    Extensible = False;
    Caption = 'HC Payment Types';
    ContextSensitiveHelpPage = 'retail/posunit/reference/payment_types.html';
    PageType = List;
    SourceTable = "NPR HC Payment Type POS";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR24.0';
    ObsoleteReason = 'HQ Connector will no longer be supported';


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the ID of the payment type.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies additional information about the payment type, such as its name.';
                    ApplicationArea = NPRRetail;
                }
                field("Account Type"; Rec."Account Type")
                {

                    ToolTip = 'Enable the interface between the payment type and the account type, and set how it will be treated in the accounts.';
                    ApplicationArea = NPRRetail;
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {

                    ToolTip = 'Depending on your selection in the previous field, the code used for identifying one of the listed entities will need to be provided.';
                    ApplicationArea = NPRRetail;
                }
                field("Bank Acc. No."; Rec."Bank Acc. No.")
                {

                    ToolTip = 'Specifies the value of the Bank field';
                    ApplicationArea = NPRRetail;
                }
                field("HQ Processing"; Rec."HQ Processing")
                {

                    ToolTip = 'Specifies the value of the HQ Processing field';
                    ApplicationArea = NPRRetail;
                }
                field("HQ Post Sales Document"; Rec."HQ Post Sales Document")
                {

                    ToolTip = 'Specifies the value of the HQ Post Sales Document field';
                    ApplicationArea = NPRRetail;
                }
                field("HQ Post Payment"; Rec."HQ Post Payment")
                {

                    ToolTip = 'Specifies the value of the HQ Post Payment field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {

                    ToolTip = 'Determines which payment method is used, and to which G/L account it is associated.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

