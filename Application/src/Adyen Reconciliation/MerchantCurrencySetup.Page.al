page 6185081 "NPR Merchant Currency Setup"
{
    Extensible = false;
    UsageCategory = none;
    Caption = 'Merchant Currency Setup';
    PageType = List;
    SourceTable = "NPR Merchant Currency Setup";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Merchant Account Name"; Rec."Merchant Account Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Merchant Account Name field.';
                }
                field("Reconciliation Account Type"; Rec."Reconciliation Account Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reconciliation Account Type field.';
                }
                field("Currency Code"; Rec."NP Pay Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Account Type field.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Merchant Account No. field.';
                    ShowMandatory = true;
                }
            }
        }
    }
}
